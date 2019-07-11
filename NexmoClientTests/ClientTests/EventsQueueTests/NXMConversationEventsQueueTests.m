//
//  NXMConversationEventsQueueTests.m
//  NexmoClientTests
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "NXMTestingUtilities.h"
#import "NXMEventsQueueDelegateHelper.h"

#import "NXMConversationEventsQueue.h"
#import "NXMStitchContext.h"
#import "NXMConversationDetails.h"
#import "NXMCoreEventsPrivate.h"

#pragma mark - Test Category
@interface NXMConversationEventsQueue (Test)
- (void)handleDispatchedEvent:(NXMEvent*)event;
- (void)handleDispatchedConnectionStatus:(NXMConnectionStatus)connectionStatus;
@end


#pragma mark - Tests

@interface NXMConversationEventsQueueTests : XCTestCase
@property (nonatomic) id stitchContextMock;
@property (nonatomic) id stitchCoreMock;
@end

@implementation NXMConversationEventsQueueTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.stitchContextMock = OCMClassMock([NXMStitchContext class]);
    self.stitchCoreMock = OCMClassMock([NXMCore class]);
    OCMStub([self.stitchContextMock coreClient]).andReturn(self.stitchCoreMock);
    OCMStub([self.stitchContextMock eventsDispatcher]).andReturn(nil); //returning nil to not crash on init - not using it for testing
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.stitchCoreMock stopMocking];
    [self.stitchContextMock stopMocking];
}

#pragma mark - Dispatch Only Tests
#pragma mark Single Event Tests
- (void)testDispatchNextEvent_EventProcessed {
    //Arrange
    NSInteger startingSequenceId = 1;
    NSInteger nextEventId = startingSequenceId + 1;
    NSString *convId = @"convId";
    NXMEvent *nextEvent = [[NXMEvent alloc] initWithConversationId:convId sequenceId:nextEventId fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];

    NXMEventsQueueDelegateHelper *delegateHelper = [NXMEventsQueueDelegateHelper SingleEventHelperWithExpectationDescription:NSStringFromSelector(_cmd)];
    NXMConversationEventsQueue *eventsQueue = [self eventsQueueWithConverstaionId:convId startingSequenceId:startingSequenceId delegate:delegateHelper];
    
    
    //Act
    [eventsQueue handleDispatchedEvent:nextEvent];
    
    //Assert
    NSArray<NSNumber *> *expectedHandledIds = @[@(nextEventId)];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:delegateHelper.expectations timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(expectedHandledIds, delegateHelper.handledEventsIds);
}


- (void)testDispatchAlreadyProcessedEvent_EventSkipped {
    //Arrange
    NSString *convId = @"convId";
    NSInteger startingSequenceId = 4;
    NSInteger nextEventId = startingSequenceId;
    NXMEvent *nextEvent = [[NXMEvent alloc] initWithConversationId:convId sequenceId:nextEventId fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];

    NXMEventsQueueDelegateHelper *delegateHelper = [NXMEventsQueueDelegateHelper SingleEventHelperWithExpectationDescription:NSStringFromSelector(_cmd)];
    NXMConversationEventsQueue *eventsQueue = [self eventsQueueWithConverstaionId:convId startingSequenceId:startingSequenceId delegate:delegateHelper];
    

    //Act
    [eventsQueue handleDispatchedEvent:nextEvent];
    
    //Assert
    NSArray<NSNumber *> *expectedHandledIds = @[];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:delegateHelper.expectations timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(expectedHandledIds, delegateHelper.handledEventsIds);
}

- (void)testDispatchAlreadyProcessedMessageStatusEvent_EventProcessed {
    //Arrange
    NSString *convId = @"convId";
    NSInteger startingSequenceId = 4;
    NSInteger nextEventId = startingSequenceId;
    NXMEvent *nextEvent = [[NXMEvent alloc] initWithConversationId:convId sequenceId:nextEventId fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];

    NXMEventsQueueDelegateHelper *delegateHelper = [NXMEventsQueueDelegateHelper SingleEventHelperWithExpectationDescription:NSStringFromSelector(_cmd)];
    NXMConversationEventsQueue *eventsQueue = [self eventsQueueWithConverstaionId:convId startingSequenceId:startingSequenceId delegate:delegateHelper];
    
    
    //Act
    [eventsQueue handleDispatchedEvent:nextEvent];
    
    //Assert
    NSArray<NSNumber *> *expectedHandledIds = @[@(nextEventId)];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:delegateHelper.expectations timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(expectedHandledIds, delegateHelper.handledEventsIds);
}

- (void)testDispatchBeforeSyncFromEvent_EventSkipped {
    //Arrange
    NSString *convId = @"convId";
    NSInteger startingSequenceId = 4;
    NSInteger nextEventId = startingSequenceId - 1;
    NXMEvent *nextEvent = [[NXMEvent alloc] initWithConversationId:convId sequenceId:nextEventId fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];

    NXMEventsQueueDelegateHelper *delegateHelper = [NXMEventsQueueDelegateHelper SingleEventHelperWithExpectationDescription:NSStringFromSelector(_cmd)];
    NXMConversationEventsQueue *eventsQueue = [self eventsQueueWithConverstaionId:convId startingSequenceId:startingSequenceId delegate:delegateHelper];
    
    //Act
    [eventsQueue handleDispatchedEvent:nextEvent];
    
    //Assert
    NSArray<NSNumber *> *expectedHandledIds = @[];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:delegateHelper.expectations timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(expectedHandledIds, delegateHelper.handledEventsIds);
}

#pragma mark Multi Event Tests

- (void)testDispatchMultiEventsNoGap_NeededEventsHandled {
    /* Start Id: 2,
    // Dispatch: {3(messageStatus), 4(member), 2(text), 3(messageStatus), 5(image), 1(messageStatus)}
    // Handle: {3, 4, 3, 5}
    */
    
    //Arrange
    NSString *convId = @"convId";
    NSInteger eventId1 = 1;
    NSInteger eventId2 = 2;
    NSInteger eventId3 = 3;
    NSInteger eventId4 = 4;
    NSInteger eventId5 = 5;
    NSInteger startingSequenceId = eventId2;
    
    NXMEvent *event1 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId1 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];
  
    NXMEvent *event2 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId2 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeText];
    NXMEvent *event3 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId3 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];
    NXMEvent *event4 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId4 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];
    NXMEvent *event5 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId5 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeImage];
    
    NSUInteger expectedNumberOfHandledEvents = 4;
    NXMEventsQueueDelegateHelper *delegateHelper = [NXMEventsQueueDelegateHelper multiEventHelperWithExpectedNumberOfHandledEvents:expectedNumberOfHandledEvents
                                andExpectationDescription:NSStringFromSelector(_cmd)];
    
    NXMConversationEventsQueue *eventsQueue = [self eventsQueueWithConverstaionId:convId startingSequenceId:startingSequenceId delegate:delegateHelper];
    
    //Act
    [eventsQueue handleDispatchedEvent:event3];
    [eventsQueue handleDispatchedEvent:event4];
    [eventsQueue handleDispatchedEvent:event2];
    [eventsQueue handleDispatchedEvent:event3];
    [eventsQueue handleDispatchedEvent:event5];
    [eventsQueue handleDispatchedEvent:event1];
    
    //Assert
    NSArray<NSNumber *> *expectedHandledIds = @[@(eventId3), @(eventId4), @(eventId3), @(eventId5)];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:delegateHelper.expectations timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(expectedHandledIds, delegateHelper.handledEventsIds);
}

#pragma mark - Gap Query Tests
- (void)testDispatchEventWithGap_AllMissingEventsQueriedAndProcessed {
    /* Start Id: 2,
     // Dispatch: 6
     // Query: 3-5 Get 3,4,5
     // Handle: {3, 4, 5, 6}
     */
    
    //Arrange
    NSString *convId = @"convId";
    NSInteger eventId2 = 2;
    NSInteger eventId3 = 3;
    NSInteger eventId4 = 4;
    NSInteger eventId5 = 5;
    NSInteger eventId6 = 6;

    NSInteger startingSequenceId = eventId2;
    
    
    NXMEvent *event3 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId3 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];
    NXMEvent *event4 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId4 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];
    NXMEvent *event5 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId5 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeImage];
    NXMEvent *event6 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId6 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];
    
    NSArray<NXMEvent *> *queriedEvents = @[event3, event4, event5];

    OCMStub([self.stitchCoreMock getEventsInConversation:convId startId:@(eventId3) endId:@(eventId5) onSuccess:([OCMArg invokeBlockWithArgs:queriedEvents, nil]) onError:[OCMArg any]]);
    
    NSUInteger expectedNumberOfHandledEvents = 4;
    NXMEventsQueueDelegateHelper *delegateHelper = [NXMEventsQueueDelegateHelper multiEventHelperWithExpectedNumberOfHandledEvents:expectedNumberOfHandledEvents
                                                                                                         andExpectationDescription:NSStringFromSelector(_cmd)];
    
    NXMConversationEventsQueue *eventsQueue = [self eventsQueueWithConverstaionId:convId startingSequenceId:startingSequenceId delegate:delegateHelper];
    
    //Act
    [eventsQueue handleDispatchedEvent:event6];
    
    
    //Assert
    NSArray<NSNumber *> *expectedHandledIds = @[@(eventId3), @(eventId4), @(eventId5), @(eventId6)];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:delegateHelper.expectations timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(expectedHandledIds, delegateHelper.handledEventsIds);
}

- (void)testDispatchEventWithGap_SomeMissingEventsQueriedAndProcessed {
    /* Start Id: 2,
     // Dispatch: 7
     // Query: 3-6 Get 3,5
     // Handle: {3, 5, 7}
     */
    
    //Arrange
    NSString *convId = @"convId";
    NSInteger eventId2 = 2;
    NSInteger eventId3 = 3;
    NSInteger eventId5 = 5;
    NSInteger eventId6 = 6;
    NSInteger eventId7 = 7;
    
    NSInteger startingSequenceId = eventId2;
    
    NXMEvent *event3 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId3 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];
    NXMEvent *event5 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId5 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeImage];
    NXMEvent *event7 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId7 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];
    
    NSArray<NXMEvent *> *queriedEvents = @[event3, event5];
    
    OCMStub([self.stitchCoreMock getEventsInConversation:convId startId:@(eventId3) endId:@(eventId6) onSuccess:([OCMArg invokeBlockWithArgs:queriedEvents, nil]) onError:[OCMArg any]]);
    
    NSUInteger expectedNumberOfHandledEvents = 3;
    NXMEventsQueueDelegateHelper *delegateHelper = [NXMEventsQueueDelegateHelper multiEventHelperWithExpectedNumberOfHandledEvents:expectedNumberOfHandledEvents
                                                                                                         andExpectationDescription:NSStringFromSelector(_cmd)];
    
    NXMConversationEventsQueue *eventsQueue = [self eventsQueueWithConverstaionId:convId startingSequenceId:startingSequenceId delegate:delegateHelper];
    
    //Act
    [eventsQueue handleDispatchedEvent:event7];
    
    
    //Assert
    NSArray<NSNumber *> *expectedHandledIds = @[@(eventId3), @(eventId5), @(eventId7)];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:delegateHelper.expectations timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(expectedHandledIds, delegateHelper.handledEventsIds);
}

#pragma mark - Network Query Tests

- (void)testDispatchNetworkConnected_SomeMissingEventsQueriedAndProcessed {
    /* Start Id: 2,
     // Dispatch: connecting, connected
     // Query: 3-end Get 3,5,8
     // Handle: {3, 5, 8}
     */
    
    //Arrange
    NSString *convId = @"convId";
    NSInteger eventId2 = 2;
    NSInteger eventId3 = 3;
    NSInteger eventId5 = 5;
    NSInteger eventId7 = 7;
    NSInteger eventId8 = 8;
    
    NSInteger startingSequenceId = eventId2;
    
    NXMEvent *event3 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId3 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];
    NXMEvent *event5 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId5 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeImage];
    NXMEvent *event8 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId8 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];

    
    NSArray<NXMEvent *> *queriedEvents = @[event3, event5];
    //LatestEvent
    OCMStub([self.stitchCoreMock getLatestEventInConversation:convId onSuccess:([OCMArg invokeBlockWithArgs:event8, nil]) onError:[OCMArg any]]);
    
    //Gap
    OCMStub([self.stitchCoreMock getEventsInConversation:convId startId:@(eventId3) endId:@(eventId7) onSuccess:([OCMArg invokeBlockWithArgs:queriedEvents, nil]) onError:[OCMArg any]]);
    
    NSUInteger expectedNumberOfHandledEvents = 3;
    NXMEventsQueueDelegateHelper *delegateHelper = [NXMEventsQueueDelegateHelper multiEventHelperWithExpectedNumberOfHandledEvents:expectedNumberOfHandledEvents
                                                                                                         andExpectationDescription:NSStringFromSelector(_cmd)];
    
    NXMConversationEventsQueue *eventsQueue = [self eventsQueueWithConverstaionId:convId startingSequenceId:startingSequenceId delegate:delegateHelper];
    
    //Act
    [eventsQueue handleDispatchedConnectionStatus:NXMConnectionStatusConnecting];
    [eventsQueue handleDispatchedConnectionStatus:NXMConnectionStatusConnected];
    
    
    //Assert
    NSArray<NSNumber *> *expectedHandledIds = @[@(eventId3), @(eventId5), @(eventId8)];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:delegateHelper.expectations timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(expectedHandledIds, delegateHelper.handledEventsIds);
}

#pragma mark - Flow Tests
- (void)testDispatchAndQeuryGapAndNetworkConcurrently_NetworkQueryReturnsFirst {
    /* Start Id: 2,
     // Events: 1(member), 3(text), 4(member), 6(messageStatus), 7(image), 8(member)
     // Dispatch: 3(text), 7(image)[Gap], disconnected, connected, 4(member), 1(member) 6(messageStatus),
     // Query: 4-6 Get 4,6 [returns second], Query 4-nil Get 4,6,7,8 [returns first]
     // Handle: {3, 4, 6, 6, 7, 8, 6}
     */
    
    //Arrange
    NSString *convId = @"convId";
    NSInteger eventId1 = 1;
    NSInteger eventId2 = 2;
    NSInteger eventId3 = 3;
    NSInteger eventId4 = 4;
    NSInteger eventId6 = 6;
    NSInteger eventId7 = 7;
    NSInteger eventId8 = 8;
    
    NSInteger startingSequenceId = eventId2;
    
    NXMEvent *event1 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId1 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];
    NXMEvent *event3 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId3 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeText];
    NXMEvent *event4 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId4 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];
    NXMEvent *event6 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId6 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];
    NXMEvent *event7 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId7 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeImage];

    
    //TODO: change to eventCopy when we have NSCopy on events
    NXMEvent *event4Gap = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId4 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];
    NXMEvent *event6Gap = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId6 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];
    NXMEvent *event4Network = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId4 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];
    NXMEvent *event6Network = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId6 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];
    NXMEvent *event7Network = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId7 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeImage];
    NXMEvent *event8Network = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId8 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];

    NSMutableArray<NXMEvent *> *queriedGapEvents = [@[event4Gap, event6Gap] mutableCopy];
    NSMutableArray<NXMEvent *> *queriedNetworkEvents = [@[event4Network, event6Network, event7Network] mutableCopy];
    
    XCTestExpectation *queryEventsExpectation = [[XCTestExpectation alloc] initWithDescription:@"queryEventsExpectation"];
    
    
    //LatestEvent
    OCMStub([self.stitchCoreMock getLatestEventInConversation:convId onSuccess:[OCMArg any] onError:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
                NXMSuccessCallbackWithEvent successBlock;
                [invocation getArgument:&successBlock atIndex:3];
                successBlock(event8Network);
                [queryEventsExpectation fulfill];
                NSLog(@"I getLatestEventInConversation success");
            });

    OCMStub([self.stitchCoreMock getEventsInConversation:convId startId:@(eventId4) endId:@(eventId6) onSuccess:[OCMArg any] onError:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        __block NXMSuccessCallbackWithEvents successBlock;
        [invocation getArgument:&successBlock atIndex:5];
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
            [XCTWaiter waitForExpectations:@[queryEventsExpectation] timeout:10];
            successBlock(queriedGapEvents);
            NSLog(@"I eventId4 to eventId6 success");
        });
    });
    
    NSUInteger expectedNumberOfHandledEvents = 5;
    NXMEventsQueueDelegateHelper *delegateHelper = [NXMEventsQueueDelegateHelper multiEventHelperWithExpectedNumberOfHandledEvents:expectedNumberOfHandledEvents
                                                                                                         andExpectationDescription:NSStringFromSelector(_cmd)];
    
    NXMConversationEventsQueue *eventsQueue = [self eventsQueueWithConverstaionId:convId startingSequenceId:startingSequenceId delegate:delegateHelper];
    
    //Act
    [eventsQueue handleDispatchedEvent:event3];
    [eventsQueue handleDispatchedEvent:event7];
    [eventsQueue handleDispatchedConnectionStatus:NXMConnectionStatusConnecting];
    [eventsQueue handleDispatchedConnectionStatus:NXMConnectionStatusConnected];
    [eventsQueue handleDispatchedEvent:event4];
    [eventsQueue handleDispatchedEvent:event1];
    
    
    
    //Assert
    NSArray<NSNumber *> *expectedHandledIds = @[@(eventId3), @(eventId4), @(eventId6), @(eventId7), @(eventId8)];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:delegateHelper.expectations timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(expectedHandledIds, delegateHelper.handledEventsIds);
}

- (void)testDispatchAndQeuryGapAndNetworkConcurrently_NetworkQueryReturnsSecond {
    /* Start Id: 2,
     // Events: 1(member), 3(text), 4(member), 6(messageStatus), 7(image), 8(member)
     // Dispatch: 3(text), 7(image)[Gap], disconnected, connected, 4(member), 1(member) 6(messageStatus),
     // Query: 4-6 Get 4,6 [returns second], Query 4-nil Get 4,6,7,8 [returns first]
     // Handle: {3, 4, 6, 7, 8, 6, 6}
     */
    
    //Arrange
    NSString *convId = @"convId";
    NSInteger eventId1 = 1;
    NSInteger eventId2 = 2;
    NSInteger eventId3 = 3;
    NSInteger eventId4 = 4;
    NSInteger eventId6 = 6;
    NSInteger eventId7 = 7;
    NSInteger eventId8 = 8;
    
    NSInteger startingSequenceId = eventId2;
    
    NXMEvent *event1 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId1 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];
    NXMEvent *event3 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId3 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeText];
    NXMEvent *event4 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId4 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];
    NXMEvent *event6 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId6 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];
    NXMEvent *event7 = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId7 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeImage];
    
    //TODO: change to eventCopy when we have NSCopy on events
    NXMEvent *event4Gap = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId4 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];
    NXMEvent *event6Gap = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId6 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];
    NXMEvent *event4Network = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId4 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];
    NXMEvent *event6Network = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId6 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMessageStatus];
    NXMEvent *event7Network = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId7 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];
    NXMEvent *event8Network = [[NXMEvent alloc] initWithConversationId:convId sequenceId:eventId8 fromMemberId:@"memberId" creationDate:nil type:NXMEventTypeMember];
    
    NSMutableArray<NXMEvent *> *queriedGapEvents = [@[event4Gap, event6Gap] mutableCopy];
    NSMutableArray<NXMEvent *> *queriedNetworkEvents = [@[event4Network, event6Network, event7Network, event8Network] mutableCopy];
    
    XCTestExpectation *queryEventsExpectation = [[XCTestExpectation alloc] initWithDescription:@"queryEventsExpectation"];
    
    //LatestEvent
    OCMStub([self.stitchCoreMock getLatestEventInConversation:convId onSuccess:[OCMArg any] onError:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        NXMSuccessCallbackWithEvent successBlock;
        [invocation getArgument:&successBlock atIndex:3];
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
            [XCTWaiter waitForExpectations:@[queryEventsExpectation] timeout:10];
            successBlock(event8Network);
        });
    });
    
    OCMStub([self.stitchCoreMock getEventsInConversation:convId startId:@(eventId4) endId:@(eventId6) onSuccess:[OCMArg any] onError:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        __block NXMSuccessCallbackWithEvents successBlock;
        [invocation getArgument:&successBlock atIndex:5];
        successBlock(queriedGapEvents);
        [queryEventsExpectation fulfill];
    });
    
    NSUInteger expectedNumberOfHandledEvents = 5;
    NXMEventsQueueDelegateHelper *delegateHelper = [NXMEventsQueueDelegateHelper multiEventHelperWithExpectedNumberOfHandledEvents:expectedNumberOfHandledEvents
                                                                                                         andExpectationDescription:NSStringFromSelector(_cmd)];
    
    NXMConversationEventsQueue *eventsQueue = [self eventsQueueWithConverstaionId:convId startingSequenceId:startingSequenceId delegate:delegateHelper];
    
    //Act
    [eventsQueue handleDispatchedEvent:event3];
    [eventsQueue handleDispatchedEvent:event7];
    [eventsQueue handleDispatchedConnectionStatus:NXMConnectionStatusConnecting];
    [eventsQueue handleDispatchedConnectionStatus:NXMConnectionStatusConnected];
    [eventsQueue handleDispatchedEvent:event4];
    [eventsQueue handleDispatchedEvent:event1];
    
    
    
    //Assert
    NSArray<NSNumber *> *expectedHandledIds = @[@(eventId3), @(eventId4), @(eventId6), @(eventId7), @(eventId8)];
    XCTWaiterResult waiterResult = [XCTWaiter waitForExpectations:delegateHelper.expectations timeout:10];
    XCTAssertEqual(waiterResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(expectedHandledIds, delegateHelper.handledEventsIds);
}


#pragma mark - helpers

- (NXMConversationEventsQueue *)eventsQueueWithConverstaionId:(NSString *)conversationId startingSequenceId:(NSInteger)startingSequenceId delegate:(id <NXMConversationEventsQueueDelegate>)delegate {
    NXMConversationDetails *convDetails = [NXMTestingUtils conversationDetailsWithConversationId:conversationId sequenceId:startingSequenceId members:nil];
    return [[NXMConversationEventsQueue alloc] initWithConversationDetails:convDetails stitchContext:self.stitchContextMock delegate:delegate];
}
@end
