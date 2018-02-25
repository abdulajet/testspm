//
//  NXMSocketClient.m
//  NexmoConversationObjCTests
//
//  Created by Chen Lev on 2/14/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "NXMSocketClient.h"
#import "NXMSocketClientDelegate.h"

@interface NXMSocketClientTests : XCTestCase

@end

@implementation NXMSocketClientTests

static NSString *const SOCKET_URL = @"wss://ws.nexmo.com/rtc/?transport=websocket&EIO=3";


- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConnectionOpened {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTestExpectation *exp = [self expectationWithDescription:@"socket"];

    id delegateMock = OCMProtocolMock(@protocol(NXMSocketClientDelegate));

    NXMSocketClient *client = [NXMSocketClient new];
    client.delegate = delegateMock;
    
    OCMExpect([delegateMock connectionStatusChanged:YES])
    .andDo(^(NSInvocation *invocation) {
        [exp fulfill];
    });

    [client setupWithURL:[[NSURL alloc] initWithString:SOCKET_URL]];
    
    [self waitForExpectationsWithTimeout:500 handler:^(NSError *error) {
        // handle failure
    }];
    
    [delegateMock stopMocking];
}

- (void)testLogin {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTestExpectation *exp = [self expectationWithDescription:@"socket"];
    
    id delegateMock = OCMProtocolMock(@protocol(NXMSocketClientDelegate));
    
    NXMSocketClient *client = [NXMSocketClient new];
    client.delegate = delegateMock;
    
    OCMExpect([delegateMock connectionStatusChanged:YES])
    .andDo(^(NSInvocation *invocation) {
        [client loginWithToken:@"22"];
    });
    
    [client setupWithURL:[[NSURL alloc] initWithString:SOCKET_URL]];

    [self waitForExpectationsWithTimeout:15000 handler:^(NSError *error) {
        // handle failure
    }];
    
    [delegateMock stopMocking];

}

- (void)testGetConversationById {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTestExpectation *exp = [self expectationWithDescription:@"socket"];
    
    id delegateMock = OCMProtocolMock(@protocol(NXMSocketClientDelegate));
    
    NXMSocketClient *client = [NXMSocketClient new];
    client.delegate = delegateMock;
    
    OCMExpect([delegateMock connectionStatusChanged:YES])
    .andDo(^(NSInvocation *invocation) {
        [client getConversationWithId:@"22"];
    });
    
    [client setupWithURL:[[NSURL alloc] initWithString:SOCKET_URL]];
    
    [self waitForExpectationsWithTimeout:200 handler:^(NSError *error) {
        // handle failure
    }];
    
    [delegateMock stopMocking];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
