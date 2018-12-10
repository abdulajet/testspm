//
//  NXMSocketClientTests.m
//  NexmoConversationObjCTests
//
//  Created by Chen Lev on 4/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "NXMUser.h"
#import "NXMErrors.h"
#import "NXMNetworkManager.h"
#import "NXMSocketClient.h"
#import "NXMSocketClientDelegate.h"
#import "NXMSocketClientDefine.h"
#import "VPSocketIOClient.h"
#import "VPSocketIOClientStub.h"


@interface NXMSocketClientTests : XCTestCase

@end

@implementation NXMSocketClientTests

#pragma mark - Login Tests
- (void)testLoginSuccessful {
    VPSocketIOClientStub *socketIOClientStub = [[VPSocketIOClientStub alloc] init];
    id socketIOClientMock = OCMClassMock([VPSocketIOClient class]);
    id socketClientDelegateMock = OCMProtocolMock(@protocol(NXMSocketClientDelegate));
    OCMStub([socketIOClientMock alloc]).andReturn(socketIOClientMock);
    OCMStub([socketIOClientMock init:OCMOCK_ANY withConfig:OCMOCK_ANY]).andReturn(socketIOClientMock);
    socketIOClientStub.testedEvent = kNXMSocketEventLogin;
    OCMStub([socketIOClientMock on:OCMOCK_ANY callback:OCMOCK_ANY]).andCall(socketIOClientStub, @selector(on:callback:));
    OCMStub([socketIOClientMock emit:OCMOCK_ANY items:OCMOCK_ANY]).andCall(socketIOClientStub, @selector(emit:items:));
    
    NXMSocketClient *socketClient = [[NXMSocketClient alloc] initWithHost:@"host"];
    [socketClient setDelegate:(id<NXMSocketClientDelegate>)socketClientDelegateMock];
    OCMStub([socketIOClientMock connect]).andCall(socketClient, @selector(onWSConnect));
    
    NSString * token = @"blabla";
//    NSDictionary* expectedResponse = @{@"body":@{
//                                                 @"user_id":@"1234",
//                                                 @"name":@"testuser",
//                                                 @"id":@"12345"
//                                                 }};
    
    OCMExpect([socketClientDelegateMock didLogin:[OCMArg checkWithBlock:^BOOL(NXMUser * usr){
        XCTAssertEqual(usr.name, @"testuser");
        XCTAssertEqual(usr.userId, @"1234");
        return ([usr.name isEqualToString:@"testuser"]) ? YES : NO;
    }] sessionId:[OCMArg isEqual:@"12345"]]);
    
    [socketClient loginWithToken:token];
    OCMVerifyAll(socketClientDelegateMock);
    [socketIOClientMock stopMocking];
    [socketClientDelegateMock stopMocking];
}

- (void)testLoginEventEmitted {
    id socketIOClientMock = OCMClassMock([VPSocketIOClient class]);
    OCMStub([socketIOClientMock alloc]).andReturn(socketIOClientMock);
    OCMStub([socketIOClientMock init:OCMOCK_ANY withConfig:OCMOCK_ANY]).andReturn(socketIOClientMock);
    
    NXMSocketClient *socketClient = [[NXMSocketClient alloc] initWithHost:@"host"];
    OCMStub([socketIOClientMock connect]).andCall(socketClient, @selector(onWSConnect));


    NSString *token = @"blabla";
    OCMExpect([socketIOClientMock emit:kNXMSocketEventLogin items:[OCMArg checkWithBlock:^BOOL(NSArray *data)
                                                                      {
                                                                          XCTAssertTrue([data[0] isKindOfClass:[NSDictionary class]]);
                                                                          XCTAssertEqual(data[0][@"body"][@"token"], token);
                                                                          
                                                                          return YES;
                                                                          
                                                                      }]]);

    [socketClient loginWithToken:token];
    OCMVerifyAll(socketIOClientMock);
    [socketIOClientMock stopMocking];
}

 - (void)testLoginFailedWith_ExpiredToken {
    VPSocketIOClientStub *socketIOClientStub = [[VPSocketIOClientStub alloc] init];
    id socketIOClientMock = OCMClassMock([VPSocketIOClient class]);
    id socketClientDelegateMock = OCMProtocolMock(@protocol(NXMSocketClientDelegate));
    OCMStub([socketIOClientMock alloc]).andReturn(socketIOClientMock);
    OCMStub([socketIOClientMock init:OCMOCK_ANY withConfig:OCMOCK_ANY]).andReturn(socketIOClientMock);
    socketIOClientStub.testedEvent = kNXMSocketEventExpiredToken;
    OCMStub([socketIOClientMock on:OCMOCK_ANY callback:OCMOCK_ANY]).andCall(socketIOClientStub, @selector(on:callback:));
    OCMStub([socketIOClientMock emit:OCMOCK_ANY items:OCMOCK_ANY]).andCall(socketIOClientStub, @selector(emit:items:));
     
    NXMSocketClient *socketClient = [[NXMSocketClient alloc] initWithHost:@"host"];
    [socketClient setDelegate:(id<NXMSocketClientDelegate>)socketClientDelegateMock];
    OCMStub([socketIOClientMock connect]).andCall(socketClient, @selector(onWSConnect));

    NSString * expiredToken = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODk2Nzk5OCwibmJmIjoxNTI4OTY3OTk4LCJleHAiOjE1Mjg5OTgwMjgsImp0aSI6MTUyODk2ODAyODk2NywiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJUaGVNYW5hZ2VyIn0.xrPVESnkhd438QqkEwoOOnfD776i3kehVAiGengajUj1g8qmR2tHEGekFrL_9YihSTYNLDT1vMEkumjJWfTM01BWgw8OO1nBdPR_0JCWC5_53RBEdrip3_IHjuhn7W0FqoqZMmZFT7nzRcCeS0Z6nyw_ERnE6XeXQop__4QwTX1detkoULWeFUrnWLeH5nfPy4BWdqgkUhlo3-e1xm3F5xMOrALk_2y0_fQYY00HYYUIz8nBODfZbrc35YvnQtXDhMi_oKk4srcjqMw7O_8Uu1-FeqjLuqrR0bgrCxYXFJaOvqLxX-1S3XBT_Wa4YuixHGyZk5lgVv4Lf-0pUJMQtg";

    
    OCMExpect([socketClientDelegateMock didFailAuthorization:[OCMArg checkWithBlock:^BOOL(NSError * err){
         XCTAssertEqual(err.code, NXMStitchErrorCodeTokenExpired);
         XCTAssertEqual(err.domain, NXMStitchErrorDomain);
         XCTAssertEqual(err.userInfo[@"token"], expiredToken);
         return ([err.userInfo[@"token"] isEqualToString:expiredToken]) ? YES : NO;
     }]]);

    [socketClient loginWithToken:expiredToken];
    OCMVerifyAll(socketClientDelegateMock);
    [socketIOClientMock stopMocking];
    [socketClientDelegateMock stopMocking];
}

- (void)testLoginFailedWith_InvalidToken {
    VPSocketIOClientStub *socketIOClientStub = [[VPSocketIOClientStub alloc] init];
    id socketIOClientMock = OCMClassMock([VPSocketIOClient class]);
    id socketClientDelegateMock = OCMProtocolMock(@protocol(NXMSocketClientDelegate));
    OCMStub([socketIOClientMock alloc]).andReturn(socketIOClientMock);
    OCMStub([socketIOClientMock init:OCMOCK_ANY withConfig:OCMOCK_ANY]).andReturn(socketIOClientMock);
    socketIOClientStub.testedEvent = kNXMSocketEventInvalidToken;
    OCMStub([socketIOClientMock on:OCMOCK_ANY callback:OCMOCK_ANY]).andCall(socketIOClientStub, @selector(on:callback:));
    OCMStub([socketIOClientMock emit:OCMOCK_ANY items:OCMOCK_ANY]).andCall(socketIOClientStub, @selector(emit:items:));
    
    NXMSocketClient *socketClient = [[NXMSocketClient alloc] initWithHost:@"host"];
    [socketClient setDelegate:(id<NXMSocketClientDelegate>)socketClientDelegateMock];
    OCMStub([socketIOClientMock connect]).andCall(socketClient, @selector(onWSConnect));
    
    NSString * invalidToken = @"blabla";
    
    
    OCMExpect([socketClientDelegateMock didFailAuthorization:[OCMArg checkWithBlock:^BOOL(NSError * err){
        XCTAssertEqual(err.code, NXMStitchErrorCodeTokenInvalid);
        XCTAssertEqual(err.domain, NXMStitchErrorDomain);
        XCTAssertEqual(err.userInfo[@"token"], invalidToken);
        return ([err.userInfo[@"token"] isEqualToString:invalidToken]) ? YES : NO;
    }]]);
    
    [socketClient loginWithToken:invalidToken];
    OCMVerifyAll(socketClientDelegateMock);
    [socketIOClientMock stopMocking];
    [socketClientDelegateMock stopMocking];
}
#pragma mark - Logout tests

- (void)testLogout{
    VPSocketIOClientStub *socketIOClientStub = [[VPSocketIOClientStub alloc] init];
    id socketIOClientMock = OCMClassMock([VPSocketIOClient class]);
    id socketClientDelegateMock = OCMProtocolMock(@protocol(NXMSocketClientDelegate));
    OCMStub([socketIOClientMock alloc]).andReturn(socketIOClientMock);
    OCMStub([socketIOClientMock init:OCMOCK_ANY withConfig:OCMOCK_ANY]).andReturn(socketIOClientMock);
    socketIOClientStub.testedEvent = kNXMSocketEventLogout;
    OCMStub([socketIOClientMock on:OCMOCK_ANY callback:OCMOCK_ANY]).andCall(socketIOClientStub, @selector(on:callback:));
    OCMStub([socketIOClientMock emit:OCMOCK_ANY items:OCMOCK_ANY]).andCall(socketIOClientStub, @selector(emit:items:));
    
    NXMSocketClient *socketClient = [[NXMSocketClient alloc] initWithHost:@"host"];
    [socketClient setDelegate:(id<NXMSocketClientDelegate>)socketClientDelegateMock];
    OCMStub([socketIOClientMock connect]).andCall(socketClient, @selector(onWSConnect));
    
    OCMExpect([socketIOClientMock disconnect]);
    OCMExpect([socketClientDelegateMock connectionStatusChanged:NO]);
    OCMExpect([socketClientDelegateMock didLogout:[OCMArg checkWithBlock:^BOOL(NXMUser * usr){
        XCTAssertEqual(usr.name, @"testuser");
        XCTAssertEqual(usr.userId, @"1234");
        return ([usr.name isEqualToString:@"testuser"]) ? YES : NO;
    }]]);
    
    [socketClient loginWithToken:@"blabla"];
    [socketClient logout];
    OCMVerifyAll(socketClientDelegateMock);
    OCMVerifyAll(socketIOClientMock);
    [socketIOClientMock stopMocking];
    [socketClientDelegateMock stopMocking];
}

- (void) testLogout_eventEmitted {
    id socketIOClientMock = OCMClassMock([VPSocketIOClient class]);
    OCMStub([socketIOClientMock alloc]).andReturn(socketIOClientMock);
    OCMStub([socketIOClientMock init:OCMOCK_ANY withConfig:OCMOCK_ANY]).andReturn(socketIOClientMock);
    
    NXMSocketClient *socketClient = [[NXMSocketClient alloc] initWithHost:@"host"];
    
    OCMExpect([socketIOClientMock emit:kNXMSocketEventLogout items:[OCMArg any]]);
    
    [socketClient logout];
    OCMVerifyAll(socketIOClientMock);
    [socketIOClientMock stopMocking];
}

#pragma mark - Conversation actions tests
- (void)testSeenTextEventEmitted {
    
    id socketIOClientMock = OCMClassMock([VPSocketIOClient class]);
    OCMStub([socketIOClientMock alloc]).andReturn(socketIOClientMock);
    OCMStub([socketIOClientMock init:OCMOCK_ANY withConfig:OCMOCK_ANY]).andReturn(socketIOClientMock);

    NXMSocketClient *socketClient = [[NXMSocketClient alloc] initWithHost:@"host"];
    
    NSString *conversationId = @"1234";
    NSString *memberId = @"mem-1234";
    OCMExpect([socketIOClientMock emit:kNXMSocketEventTextSeen items:[OCMArg checkWithBlock:^BOOL(NSArray *data)
                                                                      {
                                                                          XCTAssertTrue([data[0] isKindOfClass:[NSDictionary class]]);

                                                                          XCTAssertEqual(data[0][@"cid"], conversationId);
                                                                          XCTAssertEqual(data[0][@"from"], memberId);
                                                                          
                                                                          return YES;
                                                                          
                                                                      }]]);
    
    [socketClient seenTextEvent:conversationId memberId:memberId eventId:@"eee"];
    OCMVerifyAll(socketIOClientMock);
    
    [socketIOClientMock stopMocking];
}

- (void) testSeenTextEvent {
//    VPSocketIOClientStub *socketIOClientStub = [[VPSocketIOClientStub alloc] init];
//    id socketIOClientMock = OCMClassMock([VPSocketIOClient class]);
//    id socketClientDelegateMock = OCMProtocolMock(@protocol(NXMSocketClientDelegate));
//    OCMStub([socketIOClientMock alloc]).andReturn(socketIOClientMock);
//    OCMStub([socketIOClientMock init:OCMOCK_ANY withConfig:OCMOCK_ANY]).andReturn(socketIOClientMock);
//    socketIOClientStub.testedEvent = kNXMSocketEventTextSeen;
//    OCMStub([socketIOClientMock on:OCMOCK_ANY callback:OCMOCK_ANY]).andCall(socketIOClientStub, @selector(on:callback:));
//    OCMStub([socketIOClientMock emit:OCMOCK_ANY items:OCMOCK_ANY]).andCall(socketIOClientStub, @selector(emit:items:));
//    
//    NXMSocketClient *socketClient = [[NXMSocketClient alloc] initWithHost:@"host"];
//    [socketClient setDelegate:(id<NXMSocketClientDelegate>)socketClientDelegateMock];
//    
//    NXMMessageStatusEvent *expectedStatusEvent = [NXMMessageStatusEvent new];
//    expectedStatusEvent.eventId = 1234;
//    expectedStatusEvent.conversationId = @"CON-1234";
//    expectedStatusEvent.fromMemberId = @"MEM-1235";
//    expectedStatusEvent.creationDate = [NSDate dateWithTimeIntervalSince1970:0];
//    expectedStatusEvent.sequenceId = 111;
//    expectedStatusEvent.status = NXMMessageStatusTypeSeen;
//    expectedStatusEvent.type = NXMEventTypeMessageStatus;
//    
//    OCMExpect([socketClientDelegateMock textSeen:[OCMArg checkWithBlock:^BOOL(NXMMessageStatusEvent* statusEvent) {
//        XCTAssertEqual(statusEvent.eventId, expectedStatusEvent.eventId);
//        XCTAssertEqual(statusEvent.conversationId, expectedStatusEvent.conversationId);
//        XCTAssertEqual(statusEvent.fromMemberId, expectedStatusEvent.fromMemberId);
//        //XCTAssertEqual(statusEvent.creationDate, expectedStatusEvent.creationDate);
//        XCTAssertEqual(statusEvent.sequenceId, expectedStatusEvent.sequenceId);
//        XCTAssertEqual(statusEvent.type, expectedStatusEvent.type);
//        XCTAssertEqual(statusEvent.status, expectedStatusEvent.status);
//        return YES;
//        
//    }]]);
//    
//    OCMVerifyAll(socketClientDelegateMock);
//    [socketIOClientMock stopMocking];
//    [socketClientDelegateMock stopMocking];
//    
}

- (void)testDeliverTextEvent:(nonnull NSString *)conversationId
                memberId:(nonnull NSString *)memberId
                     eventId:(NSInteger)eventId {
    
}

- (void)testTextTypingOn:(nonnull NSString *)conversationId
                memberId:(nonnull NSString *)memberId {
    
}

- (void)testTextTypingOff:(nonnull NSString *)conversationId
                 memberId:(nonnull NSString *)memberId {
    
}

@end
