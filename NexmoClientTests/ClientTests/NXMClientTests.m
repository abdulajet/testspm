//
//  NXMClientTests.h
//  NXMiOSSDK
//
//  Created by Chen Lev on 8/7/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "NXMClient.h"
#import "NXMTestingUtils.h"
#import "NXMTestingUtilities.h"

#import "NXMStitchContext.h"
#import "NXMConversationEventsQueue.h"
#import "NXMCore.h"
#import "NXMConversationDetails.h"
#import "NXMMemberEventPrivate.h"
#import "NXMUserPrivate.h"

//
//@interface NXMConversationTests : XCTestCase
//@property (nonatomic) id stitchContextMock;
//@property (nonatomic) id stitchCoreMock;
//@property (nonatomic) id eventsQueueMock;
//@end
@interface NXMClient(NXMClientTest)
- (void)onMemberEvent:(NSNotification* )notification;
- (BOOL)isConnected;
- (instancetype)initWithConfiguration:(NXMClientConfig *)configuration;
+ (void)destory;
- (BOOL)tryUpdateConversationSequenceId:(NSNumber*) sequenceId conversationId:(NSString*)conversationId;
@end

@interface NXMClientTests : XCTestCase
@property (nonatomic) id stitchContextMock;
@property (nonatomic) id stitchCoreMock;
@property (nonatomic) id eventsQueueMock;
@end

@implementation NXMClientTests

- (void)setUp {
    [super setUp];
    
    [NXMClient destory]; // reset singleton
    
    self.stitchContextMock = OCMClassMock([NXMStitchContext class]);
    self.stitchCoreMock = OCMPartialMock([[NXMCore alloc] init]);
    
    OCMStub([self.stitchContextMock alloc]).andReturn(self.stitchContextMock);
    OCMStub([self.stitchContextMock initWithCoreClient:OCMOCK_ANY]).andReturn(self.stitchContextMock);
    
    OCMStub([self.stitchContextMock coreClient]).andReturn(self.stitchCoreMock);
}



- (void)tearDown {
    
    [self.stitchCoreMock verify];
    [self.stitchContextMock verify];
    
    [self.stitchCoreMock stopMocking];
    [self.stitchContextMock stopMocking];
    
    [super tearDown];
}

- (void)setContextWithUserId:(NSString *)userId {
    NSString *userName = [@"name_" stringByAppendingString:userId];
    NXMUser *user = [[NXMUser alloc] initWithData:@{@"id":userId, @"name":userName}];
    OCMStub([self.stitchContextMock currentUser]).andReturn(user);
}

#pragma setConfig tests

- (void)testSetDefaultConfiguration {
    NXMClientConfig *expected = [NXMClientConfig new];
    NXMClientConfig *sharedConfig = NXMClient.shared.configuration;
    
    XCTAssertEqual(expected.apiUrl, sharedConfig.apiUrl);
    XCTAssertEqual(expected.websocketUrl, sharedConfig.websocketUrl);
    XCTAssertEqual(expected.ipsUrl, sharedConfig.ipsUrl);
}

- (void)testSetLONConfiguration {
    NXMClientConfig *expected = NXMClientConfig.LON;
    [NXMClient setConfiguration:expected];
    NXMClientConfig *sharedConfig = NXMClient.shared.configuration;
    
    XCTAssertEqual(expected, sharedConfig);
}

- (void)testSetCustomConfiguration {
    NXMClientConfig *expected = [[NXMClientConfig alloc] initWithApiUrl:@"aa" websocketUrl:@"bb" ipsUrl:@"cc"];
    [NXMClient setConfiguration:expected];
    NXMClientConfig *sharedConfig = NXMClient.shared.configuration;
    
    XCTAssertEqual(expected, sharedConfig);
}

- (void)testSetLONConfigAndThanCustomConfiguration {
    NXMClientConfig *expected = [[NXMClientConfig alloc] initWithApiUrl:@"aa" websocketUrl:@"bb" ipsUrl:@"cc"];
    [NXMClient setConfiguration:NXMClientConfig.LON];
    [NXMClient setConfiguration:expected];
    NXMClientConfig *sharedConfig = NXMClient.shared.configuration;
    
    XCTAssertEqual(expected, sharedConfig);
}

- (void)testSetConfigAfterCallShared {
    NXMClientConfig *expected = [NXMClientConfig new];
    NXMClientConfig *sharedConfig = NXMClient.shared.configuration;
    BOOL didCatch = false;
    @try {
        [NXMClient setConfiguration:NXMClientConfig.LON];
    } @catch (NSException *exception) {
        XCTAssertEqual(expected.apiUrl, sharedConfig.apiUrl);
        XCTAssertEqual(expected.websocketUrl, sharedConfig.websocketUrl);
        XCTAssertEqual(expected.ipsUrl, sharedConfig.ipsUrl);
        didCatch = true;
    }
    
    XCTAssertTrue(didCatch);
}

#pragma login tests

- (void)testLoginMultipleTimes {
    NSString *dummyToken = @"unknown";
    
    __block int callCount = 0;
    OCMStub([self.stitchCoreMock token]).andForwardToRealObject();
    OCMStub([self.stitchCoreMock login]).andDo(^(NSInvocation *invocation) {
        ++callCount;
    });
    
    [[NXMClient shared] loginWithAuthToken:dummyToken];    
    [[NXMClient shared] loginWithAuthToken:dummyToken];
    [[NXMClient shared] loginWithAuthToken:dummyToken];

    int expectedNumberOfCalls = 1;
    XCTAssertEqual(callCount, expectedNumberOfCalls);
}

#pragma client delegate (onMemberEvent) tests

- (void)testOnMemberJoinedEventWithoutAudio_IncomingConversation {
    [self incomingConversationWithMemberState:@"joined" clientRef:@"test_client_ref"];
}

- (void)testOnMemberInvitedEventWithoutAudio_IncomingConversation {
    [self incomingConversationWithMemberState:@"invited" clientRef:@"test_client_ref"];
}

- (void)testOnMemberLeftEventWithoutAudio_IncomingConversation {
    [self noIncomingConversationWithMemberState:@"left" fromMe:NO clientRef:nil];
}

- (void)testOnMemberJoinedHimselfEventWithoutAudio_NoIncomingConversation {
    [self noIncomingConversationWithMemberState:@"joined" fromMe:YES clientRef:nil];
}

- (void)testOnMemberInvitedHimselfEventWithoutAudio_NoIncomingConversation {
    [self noIncomingConversationWithMemberState:@"invited" fromMe:YES clientRef:nil];
}

- (void)testOnMemberKickHimselfEventWithoutAudio_NoIncomingConversation {
    [self noIncomingConversationWithMemberState:@"left" fromMe:YES clientRef:nil];
}

- (void)testOnMemberInvitedWithAudio_IncomingCall {
    NSString *convId = @"1";
    NSString *userId = @"2";
    NXMConversationDetails *conversationDetailes = [[NXMConversationDetails alloc] init];
    conversationDetailes.displayName = @"CALL_AAA";
    NXMMemberEvent *event = [NXMTestingUtils memberEventWithConvId:convId
                                                              user:userId
                                                             state:@"invited"
                                                   clientRef:nil
                                                          memberId:userId
                                                      fromMemberId:@"3"
                                                             media:YES];
    [self setContextWithUserId:userId];
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testOnMemberJoinedEventWithoutAudio"];
    
    id clientDelegateMock = [OCMockObject mockForProtocol:@protocol(NXMClientDelegate)];
    OCMExpect([clientDelegateMock client:OCMOCK_ANY didReceiveCall:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        [expectation fulfill];
    });
    
    OCMStub([self.stitchCoreMock connectionStatus]).andReturn(NXMConnectionStatusConnected);
    OCMStub([self.stitchCoreMock getConversationDetails:convId
                                              onSuccess:([OCMArg invokeBlockWithArgs:conversationDetailes, nil])
                                                onError:[OCMArg any]]);
    
    NXMClient *client = [[NXMClient alloc] initWithConfiguration:[NXMClientConfig new]];
    [client setDelegate:clientDelegateMock];
    
    NSNotification *notification  = [[NSNotification alloc] initWithName:@"dd"
                                                                  object:nil
                                                                userInfo:@{@"NXMDispatchUserInfoEventKey" :event}];
    [client onMemberEvent:notification];
    
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:1];
    
    [clientDelegateMock verify];
    [clientDelegateMock stopMocking];
    
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}
- (void)testCheckAndUpdateSequenceId{
    NSString* convId = @"conv1";
    NXMClient *client = [[NXMClient alloc] initWithConfiguration:[NXMClientConfig new]];
    
    id clientDelegateMock = [OCMockObject mockForProtocol:@protocol(NXMClientDelegate)];
    
    [client setDelegate:clientDelegateMock];
    
    bool firstEventFirstTime = [client tryUpdateConversationSequenceId:[NSNumber numberWithInteger:1]
                               conversationId:convId];
    bool firstEventSecondTime = [client tryUpdateConversationSequenceId:[NSNumber numberWithInteger:1] conversationId:convId];
    bool thirdEventFirstTime = [client tryUpdateConversationSequenceId:[NSNumber numberWithInteger:3]
                                                 conversationId:convId];
    bool secondEventFirstTime = [client tryUpdateConversationSequenceId:[NSNumber numberWithInteger:1] conversationId:convId];
    
    XCTAssertEqual(firstEventFirstTime, NO);
    XCTAssertEqual(firstEventSecondTime, YES);
    XCTAssertEqual(thirdEventFirstTime, NO);
    XCTAssertEqual(secondEventFirstTime, YES);
}

- (void)testOnMemberInvitedWithAudioWithoutCallPrefix_NoIncomingCall {
    NSString *convId = @"1";
    NSString *userId = @"2";
    NXMConversationDetails *conversationDetailes = [[NXMConversationDetails alloc] init];
    conversationDetailes.displayName = @"AAA";
    NXMMemberEvent *event = [NXMTestingUtils memberEventWithConvId:convId
                                                              user:userId
                                                             state:@"invited"
                                                        clientRef:nil
                                                          memberId:userId
                                                      fromMemberId:@"3"
                                                             media:YES];
    [self setContextWithUserId:userId];
    
    id clientDelegateMock = [OCMockObject mockForProtocol:@protocol(NXMClientDelegate)];
    OCMReject([clientDelegateMock client:OCMOCK_ANY didReceiveCall:OCMOCK_ANY]);
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testOnMemberJoinedEventWithoutAudio"];

    OCMStub([self.stitchCoreMock connectionStatus]).andReturn(NXMConnectionStatusConnected);
    OCMStub([self.stitchCoreMock getConversationDetails:convId
                                              onSuccess:([OCMArg invokeBlockWithArgs:conversationDetailes, nil])
                                                  onError:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        [expectation fulfill];
    });;
    
    NXMClient *client = [[NXMClient alloc] initWithConfiguration:[NXMClientConfig new]];
    [client setDelegate:clientDelegateMock];
    
    NSNotification *notification  = [[NSNotification alloc] initWithName:@"dd"
                                                                  object:nil
                                                                userInfo:@{@"NXMDispatchUserInfoEventKey" :event}];
    [client onMemberEvent:notification];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:1];

    [clientDelegateMock verify];
    [clientDelegateMock stopMocking];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}



- (void)incomingConversationWithMemberState:(NSString *)memberState clientRef:(NSString *)clientRef {
    NSString *convId = @"1";
    NSString *userId = @"2";
    NXMConversationDetails *conversationDetailes = [[NXMConversationDetails alloc] init];
    NXMMemberEvent *event = [NXMTestingUtils memberEventWithConvId:convId
                                                              user:userId
                                                             state:memberState
                                                        clientRef:clientRef
                                                          memberId:userId
                                                      fromMemberId:@"3"
                                                             media:NO];
    [self setContextWithUserId:userId];
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testOnMemberJoinedEventWithoutAudio"];
    
    id clientDelegateMock = [OCMockObject mockForProtocol:@protocol(NXMClientDelegate)];
    OCMExpect([clientDelegateMock client:OCMOCK_ANY didReceiveConversation:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        [expectation fulfill];
    });
    
    OCMStub([self.stitchCoreMock connectionStatus]).andReturn(NXMConnectionStatusConnected);
    OCMStub([self.stitchCoreMock getConversationDetails:convId
                                              onSuccess:([OCMArg invokeBlockWithArgs:conversationDetailes, nil])
                                                onError:[OCMArg any]]);
    
    
    NXMClient *client = [[NXMClient alloc] initWithConfiguration:[NXMClientConfig new]];
    [client setDelegate:clientDelegateMock];
    
    
    
    NSNotification *notification  = [[NSNotification alloc] initWithName:@"dd"
                                                                  object:nil
                                                                userInfo:@{@"NXMDispatchUserInfoEventKey" :event}];
    [client onMemberEvent:notification];
    
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:1];
    XCTAssertEqual(result, XCTWaiterResultCompleted);

    
    [clientDelegateMock verify];
    [clientDelegateMock stopMocking];
}

- (void)noIncomingConversationWithMemberState:(NSString *)memberState fromMe:(BOOL)fromMe clientRef:(NSString *)clientRef {
    NSString *convId = @"1";
    NSString *userId = @"2";
    NXMConversationDetails *conversationDetailes = [[NXMConversationDetails alloc] init];
    NXMMemberEvent *event = [NXMTestingUtils memberEventWithConvId:convId
                                                              user:userId
                                                             state:memberState
                                                   clientRef:clientRef
                                                          memberId:userId
                                                      fromMemberId:fromMe ? userId : @"3"
                                                             media:NO];
    [self setContextWithUserId:userId];
    
    id clientDelegateMock = [OCMockObject mockForProtocol:@protocol(NXMClientDelegate)];
    OCMReject([clientDelegateMock client:OCMOCK_ANY didReceiveCall:OCMOCK_ANY]);
    
    OCMStub([self.stitchCoreMock connectionStatus]).andReturn(NXMConnectionStatusConnected);
    OCMReject([self.stitchCoreMock getConversationDetails:convId
                                                onSuccess:([OCMArg invokeBlockWithArgs:conversationDetailes, nil])
                                                  onError:[OCMArg any]]);
    
    
    NXMClient *client = [[NXMClient alloc] initWithConfiguration:[NXMClientConfig new]];
    [client setDelegate:clientDelegateMock];
    
    NSNotification *notification  = [[NSNotification alloc] initWithName:@"dd"
                                                                  object:nil
                                                                userInfo:@{@"NXMDispatchUserInfoEventKey" :event}];
    [client onMemberEvent:notification];
    
    [clientDelegateMock verify];
    [clientDelegateMock stopMocking];
}

@end

