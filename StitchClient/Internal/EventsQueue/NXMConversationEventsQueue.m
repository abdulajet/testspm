//
//  ConversationEventsQueue.m
//  StitchObjC
//
//  Created by Iliya Barenboim on 26/08/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationEventsQueue.h"
#import "NXMEvent.h"
#import "NXMStitchContext.h"
#import "NXMConversationDetails.h"
#import "NXMEventsDispatcherNotificationHelper.h"

static NSInteger const sequenceIdNotDefine = -1;

@interface NXMConversationEventsQueue()

@property (strong,nonatomic)NSString *conversationId;
@property (strong,nonatomic)NSMutableArray<NXMEvent*>*eventsQueue;
@property (strong,nonatomic)NSOperationQueue *operationQueue;
@property (nonatomic)NSInteger currentHandledSequenceId;
@property (nonatomic, readwrite) NSInteger sequenceIdSyncingFrom;
@property (nonatomic)BOOL isProcessingRequest;
@property (strong,nonatomic)NSMutableArray <id <NSObject>>*observers;
@property (strong,nonatomic)NXMStitchContext *stitchContext;
@property int sucsessNumber;
@property int failNumber;

@end

@implementation NXMConversationEventsQueue

- (nullable instancetype)initWithConversationDetails:(nonnull NXMConversationDetails*)ConversationDetails
                                       stitchContext:(nonnull NXMStitchContext*)stitchContext {
    return [self initWithConversationDetails:ConversationDetails stitchContext:stitchContext delegate:nil];
}

- (nullable instancetype)initWithConversationDetails:(nonnull NXMConversationDetails*)ConversationDetails
                                    stitchContext:(nonnull NXMStitchContext*)stitchContext
                                            delegate:(_Nullable id <NXMConversationEventsQueueDelegate>)delegate{
    self = [super init];
    if(self){
        self.conversationId = ConversationDetails.uuid;
        self.eventsQueue = [[NSMutableArray alloc] init];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        self.currentHandledSequenceId = ConversationDetails.sequence_number - 1;
        self.sequenceIdSyncingFrom = ConversationDetails.sequence_number;
        self.observers = [[NSMutableArray alloc] init];
        self.stitchContext = stitchContext;
        self.delegate = delegate;
        [self registerSocketEventsNotifications];
    }
    return self;
}

- (void)dealloc{
    [self deregisterFromDispatchedEvents];
}

- (void)deregisterFromDispatchedEvents {
    for(id <NSObject> observer in self.observers){
        [self.stitchContext.eventsDispatcher.notificationCenter removeObserver:observer];
    }
}

- (void)registerToDispatchedEvent:(NSString *)eventName {
    __weak NXMConversationEventsQueue *weakSelf = self;
    id <NSObject> observer = [self.stitchContext.eventsDispatcher.notificationCenter addObserverForName:eventName object:nil queue:self.operationQueue usingBlock:^(NSNotification * _Nonnull note) {
        NXMEvent *event = [NXMEventsDispatcherNotificationHelper<NXMEvent *> nxmNotificationModelWithNotification:note];
        [weakSelf handleDisptchedEvent: event];
    }];
    [self.observers addObject:observer];
}

- (void)registerSocketEventsNotifications{
    [self registerToDispatchedEvent:kNXMEventsDispatcherNotificationMedia];
    [self registerToDispatchedEvent:kNXMEventsDispatcherNotificationMember];
    [self registerToDispatchedEvent:kNXMEventsDispatcherNotificationMessage];
    [self registerToDispatchedEvent:kNXMEventsDispatcherNotificationMessageStatus];
}

- (void)handleDisptchedEvent:(NXMEvent*)event{
    if(![event.conversationId isEqualToString:self.conversationId]){
        return;
    }
    [self insertEvent:event];
}

- (void)insertEvent:(NXMEvent*)event{
    [self.eventsQueue addObject:event];
    if(self.isProcessingRequest){
        return;
    }
    [self processNextEvent];
}

- (void)processNextEvent{
    NXMEvent *event = self.eventsQueue.firstObject;
    if(event == nil){
        [self finishHandleEventsSequence];
        return;
    }
    if(event.sequenceId < self.sequenceIdSyncingFrom) {
        [self doneProcessingEvent:event];
        return;
    }
    
    if(self.currentHandledSequenceId == sequenceIdNotDefine || 
       event.sequenceId == self.currentHandledSequenceId + 1){
        self.currentHandledSequenceId = event.sequenceId;
        [self handleEvent:event];
        [self doneProcessingEvent:event];
        return;
    }
    if(event.sequenceId <= self.currentHandledSequenceId){
        [self handleEvent:event];
        [self doneProcessingEvent:event];
        return;
    }
    

    
    //request events
    self.isProcessingRequest = YES;
    [self finishHandleEventsSequence];
    __weak NXMConversationEventsQueue *weakSelf = self;
    [self.stitchContext.coreClient getEventsInConversation:self.conversationId startId:@(self.currentHandledSequenceId + 1) endId:@(event.sequenceId - 1) onSuccess:^(NSMutableArray<NXMEvent *> * _Nullable events) {
        [weakSelf.operationQueue addOperationWithBlock:^{
            [weakSelf handleGetEventResponse:events updatedSequenceId:(event.sequenceId - 1)];
        }];
    } onError:^(NSError * _Nullable error) {
        [weakSelf.operationQueue addOperationWithBlock:^{
            weakSelf.isProcessingRequest = NO;
            //TODO handle spesific errors in case that we want handle next events
        }];
    }];
}

-(void)handleGetEventResponse:(NSArray<NXMEvent*>*)events updatedSequenceId:(NSInteger)updatedSequenceId{
    self.currentHandledSequenceId = updatedSequenceId;
    self.isProcessingRequest = NO;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sequenceId" ascending:YES];
    NSArray *sortedEventsArray = [events sortedArrayUsingDescriptors:@[sort]];
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sortedEventsArray.count)];
    [self.eventsQueue insertObjects:sortedEventsArray atIndexes:indexes];
    [self processNextEvent];
}

-(void)doneProcessingEvent:(NXMEvent*)event{
    [self.eventsQueue removeObject:event];
    [self processNextEvent];
}

- (void)handleEvent:(NXMEvent*)event{
    if([self.delegate respondsToSelector:@selector(handleEvent:)]){
        [self.delegate handleEvent:event];
    }
}

- (void)finishHandleEventsSequence{
    if([self.delegate respondsToSelector:@selector(finishHandleEventsSequence)]){
        [self.delegate finishHandleEventsSequence];
    }
}

@end
