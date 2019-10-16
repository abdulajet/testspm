//
//  NXMCallTests.m
//  NexmoClientTests
//
//  Created by Chen Lev on 10/16/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "NXMCallPrivate.h"
#import "NXMConversationPrivate.h"
#import "NXMCoreEventsPrivate.h"
#import "NXMConversationDelegate.h"

@interface NXMCallTests : XCTestCase

@end

@implementation NXMCallTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma DTMF tests

- (void)testSendDTMF {
    id conversationMock = OCMClassMock([NXMConversation class]);
    id callMemberMock = OCMClassMock([NXMCallMember class]);
    OCMStub([callMemberMock status]).andReturn(NXMCallMemberStatusAnswered);
    
    NSString *digit = @"4";
    OCMExpect([conversationMock sendDTMF:digit completion:OCMOCK_ANY]);

    NXMCall *call = [[NXMCall alloc] initWithConversation:conversationMock];
    
    id callPartialMock = OCMPartialMock(call);
    OCMStub([callPartialMock myCallMember]).andReturn(callMemberMock);

    [call sendDTMF:digit];

    [conversationMock verify];
    [conversationMock stopMocking];
    [callMemberMock stopMocking];
    [callPartialMock stopMocking];
}

- (void)testSendDTMFCallEnded {
    id conversationMock = OCMClassMock([NXMConversation class]);
    id callMemberMock = OCMClassMock([NXMCallMember class]);
    OCMStub([callMemberMock status]).andReturn(NXMCallMemberStatusCompleted);
    
    NSString *digit = @"4";
    OCMReject([conversationMock sendDTMF:digit completion:OCMOCK_ANY]);
    
    NXMCall *call = [[NXMCall alloc] initWithConversation:conversationMock];
    
    id callPartialMock = OCMPartialMock(call);
    OCMStub([callPartialMock myCallMember]).andReturn(callMemberMock);
    
    [call sendDTMF:digit];
    
    [conversationMock verify];
    [conversationMock stopMocking];
    [callMemberMock stopMocking];
    [callPartialMock stopMocking];
}

- (void)testReceiveDTMF {
    id conversationMock = OCMClassMock([NXMConversation class]);
    id callDelegateMock = OCMProtocolMock(@protocol(NXMCallDelegate));
    
    NSString *digit = @"4";
    NXMDTMFEvent *dtmfEvent = [[NXMDTMFEvent alloc] initWithDigit:digit andDuration:@(10)];
    
    NXMCall *call = [[NXMCall alloc] initWithConversation:conversationMock];
    [call setDelegate:callDelegateMock];
    
    OCMExpect([callDelegateMock call:call didReceive:digit fromCallMember:OCMOCK_ANY]);
    [call conversation:conversationMock didReceiveDTMFEvent:dtmfEvent];

    [callDelegateMock verify];
    [conversationMock stopMocking];
    [callDelegateMock stopMocking];
}

@end
