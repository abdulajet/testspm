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
@end

@interface NXMClientTests : XCTestCase
@property (nonatomic) id stitchContextMock;
@property (nonatomic) id stitchCoreMock;
@property (nonatomic) id eventsQueueMock;
@end

@implementation NXMClientTests

- (void)setUp {
    [super setUp];
    
    self.stitchContextMock = OCMClassMock([NXMStitchContext class]);
    self.stitchCoreMock = OCMClassMock([NXMCore class]);
    
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

- (void)testOnMemberJoinedEventWithoutAudio_IncomingConversation {
    [self incomingConversationWithMemberState:@"joined"];
}

- (void)testOnMemberInvitedEventWithoutAudio_IncomingConversation {
    [self incomingConversationWithMemberState:@"invited"];
}

- (void)testOnMemberLeftEventWithoutAudio_IncomingConversation {
    [self noIncomingConversationWithMemberState:@"left" fromMe:NO];
}

- (void)testOnMemberJoinedHimselfEventWithoutAudio_NoIncomingConversation {
    [self noIncomingConversationWithMemberState:@"joined" fromMe:YES];
}

- (void)testOnMemberInvitedHimselfEventWithoutAudio_NoIncomingConversation {
    [self noIncomingConversationWithMemberState:@"invited" fromMe:YES];
}

- (void)testOnMemberKickHimselfEventWithoutAudio_NoIncomingConversation {
    [self noIncomingConversationWithMemberState:@"left" fromMe:YES];
}

- (void)testOnMemberInvitedWithAudio_IncomingCall {
    NSString *convId = @"1";
    NSString *userId = @"2";
    NXMConversationDetails *conversationDetailes = [[NXMConversationDetails alloc] init];
    conversationDetailes.displayName = @"CALL_AAA";
    NXMMemberEvent *event = [NXMTestingUtils memberEventWithConvId:convId
                                                              user:userId
                                                             state:@"invited"
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
    
    NXMClient *client = [[NXMClient alloc] init];
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

- (void)testOnMemberInvitedWithAudioWithoutCallPrefix_NoIncomingCall {
    NSString *convId = @"1";
    NSString *userId = @"2";
    NXMConversationDetails *conversationDetailes = [[NXMConversationDetails alloc] init];
    conversationDetailes.displayName = @"AAA";
    NXMMemberEvent *event = [NXMTestingUtils memberEventWithConvId:convId
                                                              user:userId
                                                             state:@"invited"
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
    
    NXMClient *client = [[NXMClient alloc] init];
    [client setDelegate:clientDelegateMock];
    
    NSNotification *notification  = [[NSNotification alloc] initWithName:@"dd"
                                                                  object:nil
                                                                userInfo:@{@"NXMDispatchUserInfoEventKey" :event}];
    [client onMemberEvent:notification];
    [XCTWaiter waitForExpectations:@[expectation] timeout:1];

    [clientDelegateMock verify];
    [clientDelegateMock stopMocking];
}



- (void)incomingConversationWithMemberState:(NSString *)memberState {
    NSString *convId = @"1";
    NSString *userId = @"2";
    NXMConversationDetails *conversationDetailes = [[NXMConversationDetails alloc] init];
    NXMMemberEvent *event = [NXMTestingUtils memberEventWithConvId:convId
                                                              user:userId
                                                             state:memberState
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
    
    
    NXMClient *client = [[NXMClient alloc] init];
    [client setDelegate:clientDelegateMock];
    
    
    
    NSNotification *notification  = [[NSNotification alloc] initWithName:@"dd"
                                                                  object:nil
                                                                userInfo:@{@"NXMDispatchUserInfoEventKey" :event}];
    [client onMemberEvent:notification];
    
    [XCTWaiter waitForExpectations:@[expectation] timeout:1];
    
    [clientDelegateMock verify];
    [clientDelegateMock stopMocking];
}

- (void)noIncomingConversationWithMemberState:(NSString *)memberState fromMe:(BOOL)fromMe {
    NSString *convId = @"1";
    NSString *userId = @"2";
    NXMConversationDetails *conversationDetailes = [[NXMConversationDetails alloc] init];
    NXMMemberEvent *event = [NXMTestingUtils memberEventWithConvId:convId
                                                              user:userId
                                                             state:memberState
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
    
    
    NXMClient *client = [[NXMClient alloc] init];
    [client setDelegate:clientDelegateMock];
    
    NSNotification *notification  = [[NSNotification alloc] initWithName:@"dd"
                                                                  object:nil
                                                                userInfo:@{@"NXMDispatchUserInfoEventKey" :event}];
    [client onMemberEvent:notification];
    
    [clientDelegateMock verify];
    [clientDelegateMock stopMocking];
}

@end

