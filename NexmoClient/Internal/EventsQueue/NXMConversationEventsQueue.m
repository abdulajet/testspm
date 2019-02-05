//
//  ConversationEventsQueue.m
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationEventsQueue.h"
#import "NXMStitchContext.h"
#import "NXMEventsDispatcherNotificationHelper.h"
#import "NXMLogger.h"

@interface NXMConversationEventsQueue()

@property (strong,nonatomic)NSString *conversationId;
@property (strong,nonatomic)NSMutableArray<NXMEvent*>*eventsQueue;
@property (strong,nonatomic)NSOperationQueue *operationQueue;
@property (nonatomic, readwrite) NSInteger currentHandledSequenceId;
@property (nonatomic, readwrite) NSInteger sequenceIdSyncingFrom;
@property (nonatomic, readwrite) NSInteger highestQueriedSequenceId;
@property (nonatomic) NSUInteger numOfProcessingRequests;
@property (nonatomic, readonly, getter=getIsProcessingRequests) BOOL isProcessingRequests;

@property (strong,nonatomic)NSMutableArray <id <NSObject>>*observers;
@property (strong,nonatomic)NXMStitchContext *stitchContext;
@property int sucsessNumber;
@property int failNumber;

@end

@implementation NXMConversationEventsQueue
#pragma mark - Init
- (nullable instancetype)initWithConversationDetails:(nonnull NXMConversationDetails*)ConversationDetails
                                       stitchContext:(nonnull NXMStitchContext*)stitchContext {
    return [self initWithConversationDetails:ConversationDetails stitchContext:stitchContext delegate:nil];
}

- (nullable instancetype)initWithConversationDetails:(nonnull NXMConversationDetails*)ConversationDetails
                                    stitchContext:(nonnull NXMStitchContext*)stitchContext
                                            delegate:(_Nullable id <NXMConversationEventsQueueDelegate>)delegate{
    self = [super init];
    if(self){
        self.conversationId = ConversationDetails.conversationId;
        self.eventsQueue = [[NSMutableArray alloc] init];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        self.currentHandledSequenceId = ConversationDetails.sequence_number;
        self.sequenceIdSyncingFrom = ConversationDetails.sequence_number;
        self.highestQueriedSequenceId = ConversationDetails.sequence_number;
        self.stitchContext = stitchContext;
        self.delegate = delegate;
        [self registerSocketEventsNotifications];
    }
    return self;
}

- (void)dealloc{
    [self unregisterFromDispatchedEvents];
}

- (BOOL)getIsProcessingRequests {
    return self.numOfProcessingRequests != 0;
}

#pragma mark - Dispatcher Registration
- (void)unregisterFromDispatchedEvents {
    [self.stitchContext.eventsDispatcher.notificationCenter removeObserver:self];
}

- (void)registerToDispatchedEvent:(NSString *)eventName {
    [self.stitchContext.eventsDispatcher.notificationCenter addObserver:self selector:@selector(handleDispatchedEventWithNotification:) name:eventName object:nil];
}

- (void)registerToDispatchedConnectionStatus:(NSString *)eventName {
    [self.stitchContext.eventsDispatcher.notificationCenter addObserver:self selector:@selector(handleDispatchedConnectionStatusWithNotification:) name:eventName object:nil];
}

- (void)registerSocketEventsNotifications{
    [self registerToDispatchedEvent:kNXMEventsDispatcherNotificationMedia];
    [self registerToDispatchedEvent:kNXMEventsDispatcherNotificationMember];
    [self registerToDispatchedEvent:kNXMEventsDispatcherNotificationMessage];
    [self registerToDispatchedEvent:kNXMEventsDispatcherNotificationMessageStatus];
    
    [self registerToDispatchedConnectionStatus:kNXMEventsDispatcherNotificationConnectionStatus];
}

#pragma mark - Dispatch Handlers
- (void)handleDispatchedConnectionStatusWithNotification:(NSNotification *)notification {
    NXMEventsDispatcherConnectionStatusModel *connectionStatusModel = [NXMEventsDispatcherNotificationHelper<NXMEventsDispatcherConnectionStatusModel *> nxmNotificationModelWithNotification:notification];
    
    __weak NXMConversationEventsQueue *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        [weakSelf handleDispatchedConnectionStatus:connectionStatusModel.status];
    }];
}

- (void)handleDispatchedEventWithNotification:(NSNotification *)notification {
    NXMEvent *event = [NXMEventsDispatcherNotificationHelper<NXMEvent *> nxmNotificationModelWithNotification:notification];
    __weak NXMConversationEventsQueue *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        [weakSelf handleDispatchedEvent: event];
    }];
}

- (void)handleDispatchedConnectionStatus:(NXMConnectionStatus)connectionStatus {
    if(connectionStatus != NXMConnectionStatusConnected) {
        return;
    }
    
    [self queryEventsFromServerUpToLastEvent];
}

- (void)handleDispatchedEvent:(NXMEvent*)event{
    if(![event.conversationId isEqualToString:self.conversationId]){
        return;
    }
    [self startProcessingRequest];
    [self.eventsQueue addObject:event];
    [self endProcessingRequest];
}

#pragma mark - Process Queued Events

- (void)processNextEvent{
    NXMEvent *event = self.eventsQueue.firstObject;
    if(event == nil){
        [self finishHandleEventsSequence];
        return;
    }
    
    [NXMLogger infoWithFormat:@"### Processing #%li of type %li, syncingFrom: %li, currentHandled: %li, maxQueried: %li",event.sequenceId, event.type, self.sequenceIdSyncingFrom, self.currentHandledSequenceId, self.highestQueriedSequenceId];
    
    if(event.sequenceId < self.sequenceIdSyncingFrom) {
        [self doneProcessingEvent:event];
        return;
    }
    
    if([self isMissingEventsWithNextEvent:event]) {
        [self queryEventsFromServerUpToEndId:@(event.sequenceId - 1)];
        return;
    }
    
    [self handleEvent:event];
}

- (BOOL)isMissingEventsWithNextEvent:(NXMEvent *)event {
    return event.sequenceId > self.currentHandledSequenceId + 1 && event.sequenceId > self.highestQueriedSequenceId + 1;
}

- (void)handleEvent:(NXMEvent*)event {
    BOOL shouldHandleEvent = event.sequenceId > self.currentHandledSequenceId ||
                             event.type == NXMEventTypeMessageStatus;
    
    if(shouldHandleEvent &&
       [self.delegate respondsToSelector:@selector(handleEvent:)]) {
        [NXMLogger infoWithFormat:@"### Handeling #%li of type %li",event.sequenceId, event.type];
        [self.delegate handleEvent:event];
    }
    
    if(event.sequenceId > self.currentHandledSequenceId) {
        self.currentHandledSequenceId = event.sequenceId;
    }
    
    [self doneProcessingEvent:event];
}

-(void)doneProcessingEvent:(NXMEvent*)event{
    [self.eventsQueue removeObject:event];
    [self processNextEvent];
}

- (void)finishHandleEventsSequence{
    if([self.delegate respondsToSelector:@selector(finishHandleEventsSequence)]){
        [self.delegate finishHandleEventsSequence];
    }
}

#pragma mark - Query Event Sequence

- (void)queryEventsFromServerUpToLastEvent {
    [NXMLogger info:@"Querying events up to last event"];
    [self queryEventsFromServerUpToEndId:nil];
}

- (void)queryEventsFromServerUpToEndId:(NSNumber *)endId {
    [self startProcessingRequest];
    __weak NXMConversationEventsQueue *weakSelf = self;
    [self.stitchContext.coreClient getEventsInConversation:self.conversationId startId:@(self.currentHandledSequenceId + 1) endId:endId onSuccess:^(NSMutableArray<NXMEvent *> * _Nullable events) {
        [weakSelf.operationQueue addOperationWithBlock:^{
            NSNumber * highestQueriedWithResponse = [weakSelf handleGetEventResponse:events];
            
            NSNumber *highestQueriedUpdate = endId ?: highestQueriedWithResponse;
            if(highestQueriedUpdate) {
                [self updateHighestQueriedWithSequenceId:[highestQueriedUpdate integerValue]];
            }
            
            [self endProcessingRequest];
        }];
    } onError:^(NSError * _Nullable error) {
        [weakSelf.operationQueue addOperationWithBlock:^{
            [NXMLogger warningWithFormat:@"ConversationEventsQueue failed querying events from server with error: %@", error];
            [self endProcessingRequest];
            return;
            //TODO: handle specific errors in case that we want handle next events
            //right now we stop handeling events until another event arrives or connection status changes to connected
        }];
    }];
}

- (void)startProcessingRequest {
    self.numOfProcessingRequests++;
}

- (void)endProcessingRequest {
    self.numOfProcessingRequests--;
    if(self.numOfProcessingRequests == 0) {
        [self processNextEvent];
    }
}

- (void)updateHighestQueriedWithSequenceId:(NSInteger)sequenceId {
    if(sequenceId > self.highestQueriedSequenceId) {
        self.highestQueriedSequenceId = sequenceId;
    }
}

- (NSNumber *)handleGetEventResponse:(NSArray<NXMEvent*>*)events {
    NSArray<NXMEvent*> *sortedEventsArray = [self sortWithEvents:events];
    [self insertToEventsQueueWithEvents:sortedEventsArray];
    return [self highestEventIdWithSortedEvents:sortedEventsArray];
}

- (NSArray<NXMEvent*> *)sortWithEvents:(NSArray<NXMEvent*>*)events {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sequenceId" ascending:YES];
    return [events sortedArrayUsingDescriptors:@[sort]];
}

- (void)insertToEventsQueueWithEvents:(NSArray<NXMEvent*> *)events {
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, events.count)];
    [self.eventsQueue insertObjects:events atIndexes:indexes];
}

- (nullable NSNumber *)highestEventIdWithSortedEvents:(NSArray<NXMEvent*> *)sortedEvents {
    NSNumber *highestEventId = nil;
    NXMEvent *highestEvent = sortedEvents.lastObject;
    
    if(highestEvent) {
        highestEventId = [NSNumber numberWithInteger:highestEvent.sequenceId];
    }
    
    return highestEventId;
}

@end
