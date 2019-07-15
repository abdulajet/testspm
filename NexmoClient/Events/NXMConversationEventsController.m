//
//  NXMConversationEventsController.m
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationEventsController.h"
#import "NXMConversationEventsQueue.h"
#import "NXMStitchContext.h"
#import "NXMMessageEvent.h"
#import "NXMMessageStatusEvent.h"

static NSString *const kNXMConversationEventsControllerQueueContentChanger = @"queueContentChanger";
static NSString *const kNXMConversationEventsControllerloadHistoryContentChanger = @"loadHistoryContentChanger";

typedef NS_ENUM(NSUInteger, NXMConversationEventsControllerInsertionSide) {
    NXMEventsControllerInsertionSideStart = 1,
    NXMEventsControllerInsertionSideEnd = 2
};


@interface NXMConversationEventsController()<NXMConversationEventsQueueDelegate>
@property (nonatomic,strong) NSMutableArray<NXMEvent*>* mutableEventsArray;
@property (nonatomic,strong) NSMutableDictionary<NSNumber*,NXMEvent*>*eventsDict;
@property (nonatomic, nonnull) NSMutableDictionary<NSString *, NSNumber *> *contentChangingDict;
@property (nonatomic) NSUInteger activeContentChangers;
@property (nonatomic,strong) NSSet <NSNumber*>*subscribedEventsType;
@property (nonatomic, nullable, strong) NXMConversationEventsQueue *eventsQueue;
@property (nonatomic, nonnull) NXMConversationDetails *conversationDetails;
@property (nonatomic, nonnull) NXMStitchContext *stitchContext;
@property (nonatomic) NSInteger earliestRequestedEventId;

@end

@implementation NXMConversationEventsController
- (instancetype _Nonnull)initWithSubscribedEventsType:(NSSet<NSNumber*>*_Nonnull)eventsType andConversationDetails:(NXMConversationDetails * _Nonnull)conversationDetails andStitchContext:(NXMStitchContext * _Nonnull)stitchContext{
    return [self initWithSubscribedEventsType:eventsType andConversationDetails:conversationDetails andStitchContext:stitchContext delegate:nil];
}

- (instancetype _Nonnull)initWithSubscribedEventsType:(NSSet* _Nonnull)eventsType andConversationDetails:(NXMConversationDetails * _Nonnull)conversationDetails andStitchContext:(NXMStitchContext * _Nonnull)stitchContext delegate:(id <NXMConversationEventsControllerDelegate> _Nullable)delegate {
    self = [super init];
    if(self){
        self.subscribedEventsType = eventsType;
        self.delegate = delegate;
        self.stitchContext = stitchContext;
        self.conversationDetails = conversationDetails;
        self.mutableEventsArray = [[NSMutableArray alloc] init];
        self.eventsDict = [[NSMutableDictionary alloc] init];
        self.activeContentChangers = 0;
        self.contentChangingDict =  [NSMutableDictionary new];
        self.eventsQueue = [[NXMConversationEventsQueue alloc] initWithConversationDetails:conversationDetails stitchContext:stitchContext delegate:self];
        self.earliestRequestedEventId = self.eventsQueue.sequenceIdSyncingFrom;
    }
    return self;
}

#pragma mark - public

- (NSArray<NXMEvent*>*)events{
    return self.mutableEventsArray;
}

-(void)loadEarlierEventsWithMaxAmount:(NSUInteger)maxAmount completion:(void (^_Nullable)(NSError * _Nullable error))completion {
    NSNumber *startId = self.earliestRequestedEventId-(NSInteger)maxAmount > 0 ? @(self.earliestRequestedEventId-maxAmount) : @(0);
    NSNumber *endId = self.earliestRequestedEventId > 0 ? @(self.earliestRequestedEventId) : @(0);
    [self.stitchContext.coreClient getEventsInConversation:self.conversationDetails.conversationId startId:startId endId:endId onSuccess:^(NSMutableArray<NXMEvent *> * _Nullable events) {
        [self handleEventsFromRequest:events withStartId:startId andEndId:endId];
        if(completion) {
            completion(nil);
        }
    } onError:^(NSError * _Nullable error) {
        if(completion) {
            completion(error);
        }
    }];
}


#pragma mark - NXMConversationEventsQueueDelegate

- (void)finishHandleEventsSequence{
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishHandleEventsSequence];
        });
        return;
    }
    if([self.contentChangingDict[kNXMConversationEventsControllerQueueContentChanger] boolValue]){
        [self setContentChangingStatus:FALSE WithContentChanger:kNXMConversationEventsControllerQueueContentChanger];
    }
}

- (void)handleEvent:(NXMEvent*_Nonnull)event{
    if(![self.subscribedEventsType containsObject:@(event.type)]){
        return;
    }

    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleEvent:event];
        });
        return;
    }
    
    switch (event.type) {
        case NXMEventTypeText:
        case NXMEventTypeImage:
        case NXMEventTypeTextTyping:
        case NXMEventTypeMedia:
        case NXMEventTypeMember:
        case NXMEventTypeSip:
            [self handleInsertEvent:event withInsertionSide:NXMEventsControllerInsertionSideEnd andContentChanger:kNXMConversationEventsControllerQueueContentChanger];
            break;
        case NXMEventTypeMessageStatus:
            [self handleStatusEvent:(NXMMessageStatusEvent*)event withContentChanger:kNXMConversationEventsControllerQueueContentChanger];
            break;
        case NXMEventTypeGeneral:
        default:
            break;
    }
}

- (void)conversationExpired {
    
}


#pragma mark - private methods

-(void)handleEventsFromRequest:(NSArray<NXMEvent *> *)events withStartId:(NSNumber *)startId andEndId:(NSNumber *)endId{
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleEventsFromRequest:events withStartId:startId andEndId:endId];
        });
        return;
    }
    
    NSSortDescriptor *sortLatestFirst = [NSSortDescriptor sortDescriptorWithKey:@"sequenceId" ascending:NO];
    NSArray<NXMEvent *> *sortedEventsArray = [events sortedArrayUsingDescriptors:@[sortLatestFirst]];
    for (int i =0; i<sortedEventsArray.count; i++) {
        if(![self.subscribedEventsType containsObject:@(sortedEventsArray[i].type)]){
            return;
        }
        switch (sortedEventsArray[i].type) {
            case NXMEventTypeText:
            case NXMEventTypeImage:
            case NXMEventTypeTextTyping:
            case NXMEventTypeMedia:
            case NXMEventTypeMember:
            case NXMEventTypeSip:
                [self handleInsertEvent:sortedEventsArray[i] withInsertionSide:NXMEventsControllerInsertionSideStart andContentChanger:kNXMConversationEventsControllerloadHistoryContentChanger];
                break;
            case NXMEventTypeMessageStatus:
            case NXMEventTypeGeneral:
            default:
                break;
        }
    }
    
    self.earliestRequestedEventId = startId.longValue;
    
    if([self.contentChangingDict[kNXMConversationEventsControllerloadHistoryContentChanger] boolValue]){
        [self setContentChangingStatus:FALSE WithContentChanger:kNXMConversationEventsControllerloadHistoryContentChanger];
    }
}

-(void)setContentChangingStatus:(BOOL)contentChangingStatus WithContentChanger:(NSString *)contentChanger {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setContentChangingStatus:contentChangingStatus WithContentChanger:contentChanger];
        });
        return;
    }
    
    self.contentChangingDict[contentChanger] = [NSNumber numberWithBool:contentChangingStatus];
    self.activeContentChangers = self.activeContentChangers + (contentChangingStatus ? 1 : - 1);
    
    if(!self.activeContentChangers) {
        [self didChangeContent];
        return;
    }
    
    if(contentChangingStatus && self.activeContentChangers == 1) {
        [self willChangeContent];
        return;
    }
    
    return;
}

- (void)handleInsertEvent:(NXMEvent*)event withInsertionSide:(NXMConversationEventsControllerInsertionSide)insertionSide andContentChanger:(NSString *)contentChanger{
    if(self.eventsDict[@(event.sequenceId)]){
        return;
    }
    
    if(![self.contentChangingDict[contentChanger] boolValue]){
        [self setContentChangingStatus:TRUE WithContentChanger:contentChanger];
    }
    
    self.eventsDict[@(event.sequenceId)] = event;
    NSUInteger insertedIndex;
    switch (insertionSide) {
        case NXMEventsControllerInsertionSideStart:
            [self.mutableEventsArray insertObject:event atIndex:0];
            insertedIndex = 0;
            break;
        case NXMEventsControllerInsertionSideEnd:
        default:
            [self.mutableEventsArray addObject:event];
            insertedIndex = [self.mutableEventsArray count] - 1;
            break;
    }
    
    if([self isDelegateRespondingToChangedEvents]) {
        [self didChangeEvent:event atIndex:insertedIndex forChangeType:NXMConversationEventsControllerChangeInsert newIndex:insertedIndex];
    }
}

- (void)handleStatusEvent:(NXMMessageStatusEvent *)statusEvent withContentChanger:(NSString *)contentChanger{
    NXMMessageEvent *updatedEvent = (NXMMessageEvent *)self.eventsDict[@(statusEvent.eventId)];
    if(!updatedEvent || ![updatedEvent isKindOfClass:NXMMessageEvent.class]){
        return;
    }
    
    if(!updatedEvent.state[@(statusEvent.status)]){
        updatedEvent.state[@(statusEvent.status)] = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableDictionary *membersDict = updatedEvent.state[@(statusEvent.status)];
    if(membersDict[statusEvent.fromMemberId]){
        return;
    }
    
    if(![self.contentChangingDict[contentChanger] boolValue]){
        [self setContentChangingStatus:TRUE WithContentChanger:contentChanger];
    }
    
    membersDict[statusEvent.fromMemberId] = statusEvent.creationDate;
    if([self isDelegateRespondingToChangedEvents]) {
        NSUInteger newIndex = [self.mutableEventsArray indexOfObject:updatedEvent];
        [self didChangeEvent:updatedEvent atIndex:newIndex forChangeType:NXMConversationEventsControllerChangeUpdate newIndex:newIndex];
    }
}

#pragma mark - delegate methods
-(BOOL)isDelegateRespondingToChangedEvents{
    return [self.delegate respondsToSelector:@selector(nxmConversationEventsController:didChangeEvent:atIndex:forChangeType:newIndex:)];
}

-(void)didChangeEvent:(NXMEvent*_Nonnull)event atIndex:(NSUInteger)index forChangeType:(NXMConversationEventsControllerChangeType)changeType newIndex:(NSUInteger)newIndex {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didChangeEvent:event atIndex:index forChangeType:changeType newIndex:newIndex];
        });
        return;
    }
    if([self.delegate respondsToSelector:@selector(nxmConversationEventsController:didChangeEvent:atIndex:forChangeType:newIndex:)]){
        [self.delegate nxmConversationEventsController:self didChangeEvent:event atIndex:index forChangeType:changeType newIndex:newIndex];
    }
}
-(void)willChangeContent {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self willChangeContent];
        });
        return;
    }
    if([self.delegate respondsToSelector:@selector(nxmConversationEventsControllerWillChangeContent:)]){
        [self.delegate nxmConversationEventsControllerWillChangeContent:self];
    }
}

-(void)didChangeContent {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didChangeContent];
        });
        return;
    }
    if([self.delegate respondsToSelector:@selector(nxmConversationEventsControllerDidChangeContent:)]){
        [self.delegate nxmConversationEventsControllerDidChangeContent:self];
    }
}

@end
