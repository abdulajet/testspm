//
//  NXMSocketClientTests.m
//  NexmoConversationObjCTests
//
//  Created by Chen Lev on 4/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "NXMSocketClient.h"
#import "NXMSocketClientDefine.h"
#import "VPSocketIOClient.h"

@interface NXMSocketClientTests : XCTestCase

@end

@implementation NXMSocketClientTests

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
    
    [socketIOClientMock stopMocking];
}

@end
