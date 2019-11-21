//
//  NXMRouterTests.m
//  NexmoClientTests
//
//  Created by Chen Lev on 10/23/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "NXMRouter.h"

@interface NXMRouter(NXMRouterTests)
- (void)executeRequest:(NSURLRequest *)request  responseBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary *      _Nullable data))responseBlock;

@end
@interface NXMRouterTests : XCTestCase

@end

@implementation NXMRouterTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma create conversation tests
- (void)testCreateConversation {
    NSString *host = @"vv";
    NSString *ips = @"vv";
    NSString *token = @"myToken";
    NSString *displayName = @"myConvName";
    NSString *expectedConvId = @"q2";
    NXMRouter *router = [[NXMRouter alloc] initWithHost:host ipsURL:[NSURL URLWithString:ips]];
    
    [router setToken:token];
    __block NSString *convID = nil;
    
    id routerPartialMock = OCMPartialMock(router);
    OCMStub([routerPartialMock executeRequest:OCMOCK_ANY
                                responseBlock:([OCMArg invokeBlockWithArgs:[NSNull null], @{@"id":expectedConvId}, nil])]);
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testCreateConversation"];
    
    NXMCreateConversationRequest *convRequest = [[NXMCreateConversationRequest alloc] initWithDisplayName:displayName];
    [router createConversation:convRequest onSuccess:^(NSString * _Nullable value) {
        convID = value;
        [expectation fulfill];
    } onError:^(NSError * _Nullable error) {
        XCTFail(@"create conversation failed");
    }];
    
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:1];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
    XCTAssertEqual(convID, expectedConvId);
    
    [routerPartialMock verify];
    [routerPartialMock stopMocking];
}

- (void)testCreateConversationFailed {
    NSString *host = @"vv";
    NSString *ips = @"vv";
    NSString *token = @"myToken";
    NSString *displayName = @"myConvName";

    NXMRouter *router = [[NXMRouter alloc] initWithHost:host ipsURL:[NSURL URLWithString:ips]];
    [router setToken:token];
    
    id routerPartialMock = OCMPartialMock(router);
    OCMStub([routerPartialMock executeRequest:[OCMArg checkWithBlock:^BOOL(id param){
            NSURLRequest *request = param;
            return [request.URL.baseURL.absoluteString isEqualToString:host] &&
                [request.URL.relativeString isEqualToString:@"beta/conversations"];
            }]
                                responseBlock:([OCMArg invokeBlockWithArgs:[NSNull null], [NSNull null], nil])]);
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testCreateConversation"];
    
    NXMCreateConversationRequest *convRequest = [[NXMCreateConversationRequest alloc] initWithDisplayName:displayName];
    [router createConversation:convRequest onSuccess:^(NSString * _Nullable value) {
        XCTFail(@"create conversation should fail");
    } onError:^(NSError * _Nullable error) {
        [expectation fulfill];
        XCTAssertNotNil(error);
    }];
    
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:1];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
    
    [routerPartialMock verify];
    [routerPartialMock stopMocking];
}

#pragma join conversation tests
@end

