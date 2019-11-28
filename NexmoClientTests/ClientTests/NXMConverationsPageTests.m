//
//  NXMConverationsPageTests.m
//  NexmoClientTests
//
//  Created by Tamir Tuch on 25/11/2019.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "NXMTestingUtilities.h"
#import "NXMConversationPrivate.h"
#import "NXMConversationsPagePrivate.h"

@interface NXMPageResponse (Test)
- (nullable instancetype)initWithPageSize:(unsigned int)pageSize
                            andWithCursor:(nonnull NSString *)cursor
                              andWithData:(nonnull NSArray *)data
                         andWithPageLinks:(nonnull NXMPageLinks *)pageLink;
@end

@interface NXMConverationsPageTests : XCTestCase
@property (nonatomic, nonnull) id conversationsPageProxyMock;
@end

@implementation NXMConverationsPageTests

- (void)setUp {
    [super setUp];

    self.conversationsPageProxyMock = OCMProtocolMock(@protocol(NXMConversationsPageProxy));
}

- (void)tearDown {
    [self.conversationsPageProxyMock verify];

    [self.conversationsPageProxyMock stopMocking];

    [super tearDown];
}

- (void) testHasNextPageReturnsTrue_whenNextPageLinkIsNotNil {
    unsigned int size = 4;
    NXMPageResponse *response = [NXMConverationsPageTests pageResponseWithSize:size
                                                                       nextURL:[NSURL URLWithString:@"next"]
                                                                       prevURL:[NSURL URLWithString:@"prev"]];
    NXMConversationsPage *conversationsPage = [[NXMConversationsPage alloc] initWithSize:size
                                                                                   order:NXMPageOrderAsc
                                                                            pageResponse:response
                                                                conversationsPagingProxy:self.conversationsPageProxyMock
                                                                           conversations:[NSArray new]];
    XCTAssertTrue([conversationsPage hasNextPage]);
}

- (void) testHasNextPageReturnsFalse_whenNextPageLinkIsNil {
    unsigned int size = 4;
    NXMPageResponse *response = [NXMConverationsPageTests pageResponseWithSize:size
                                                                       nextURL:nil
                                                                       prevURL:[NSURL URLWithString:@"prev"]];
    NXMConversationsPage *conversationsPage = [[NXMConversationsPage alloc] initWithSize:size
                                                                                   order:NXMPageOrderAsc
                                                                            pageResponse:response
                                                                conversationsPagingProxy:self.conversationsPageProxyMock
                                                                           conversations:[NSArray new]];
    XCTAssertFalse([conversationsPage hasNextPage]);
}

- (void) testHasPreviousPageReturnsTrue_whenPreviousPageLinkIsNotNil {
    unsigned int size = 4;
    NXMPageResponse *response = [NXMConverationsPageTests pageResponseWithSize:size
                                                                       nextURL:[NSURL URLWithString:@"next"]
                                                                       prevURL:[NSURL URLWithString:@"prev"]];
    NXMConversationsPage *conversationsPage = [[NXMConversationsPage alloc] initWithSize:size
                                                                                   order:NXMPageOrderAsc
                                                                            pageResponse:response
                                                                conversationsPagingProxy:self.conversationsPageProxyMock
                                                                           conversations:[NSArray new]];
    XCTAssertTrue([conversationsPage hasPreviousPage]);
}

- (void) testHasPreviousPageReturnsFalse_whenPreviousPageLinkIsNil {
    unsigned int size = 4;
    NXMPageResponse *response = [NXMConverationsPageTests pageResponseWithSize:size
                                                                       nextURL:[NSURL URLWithString:@"next"]
                                                                       prevURL:nil];
    NXMConversationsPage *conversationsPage = [[NXMConversationsPage alloc] initWithSize:size
                                                                                   order:NXMPageOrderAsc
                                                                            pageResponse:response
                                                                conversationsPagingProxy:self.conversationsPageProxyMock
                                                                           conversations:[NSArray new]];
    XCTAssertFalse([conversationsPage hasPreviousPage]);
}

- (void) testNextPageCallsCompletionWithError_whenNextPageLinkIsNil {
    unsigned int size = 4;
    NXMPageResponse *response = [NXMConverationsPageTests pageResponseWithSize:size
                                                                       nextURL:nil
                                                                       prevURL:[NSURL URLWithString:@"prev"]];
    NXMConversationsPage *conversationsPage = [[NXMConversationsPage alloc] initWithSize:size
                                                                                   order:NXMPageOrderAsc
                                                                            pageResponse:response
                                                                conversationsPagingProxy:self.conversationsPageProxyMock
                                                                           conversations:[NSArray new]];
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [conversationsPage nextPage:^(NSError * _Nullable error, NXMConversationsPage * _Nullable page) {
        XCTAssertNotNil(error);
        XCTAssertNil(page);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void) testNextPageCallsProxyWithPageAndCompletion_whenNextPageLinkIsNotNil {
    unsigned int size = 4;
    NSURL *nextURL = [NSURL URLWithString:@"next"];
    NXMPageResponse *response = [NXMConverationsPageTests pageResponseWithSize:size
                                                                       nextURL:nextURL
                                                                       prevURL:[NSURL URLWithString:@"prev"]];
    NXMConversationsPage *conversationsPage = [[NXMConversationsPage alloc] initWithSize:size
                                                                                   order:NXMPageOrderAsc
                                                                            pageResponse:response
                                                                conversationsPagingProxy:self.conversationsPageProxyMock
                                                                           conversations:[NSArray new]];
    id completionHandler = ^(NSError * _Nullable error, NXMConversationsPage * _Nullable page) { };
    OCMExpect([self.conversationsPageProxyMock getConversationsPageForURL:nextURL
                                                        completionHandler:completionHandler]);
    [conversationsPage nextPage:completionHandler];
}

- (void) testPreviousPageCallsCompletionWithError_whenPreviousPageLinkIsNil {
    unsigned int size = 4;
    NXMPageResponse *response = [NXMConverationsPageTests pageResponseWithSize:size
                                                                       nextURL:[NSURL URLWithString:@"next"]
                                                                       prevURL:nil];
    NXMConversationsPage *conversationsPage = [[NXMConversationsPage alloc] initWithSize:size
                                                                                   order:NXMPageOrderAsc
                                                                            pageResponse:response
                                                                conversationsPagingProxy:self.conversationsPageProxyMock
                                                                           conversations:[NSArray new]];
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [conversationsPage previousPage:^(NSError * _Nullable error, NXMConversationsPage * _Nullable page) {
        XCTAssertNotNil(error);
        XCTAssertNil(page);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void) testPreviousPageCallsProxyWithPageAndCompletion_whenPreviousPageLinkIsNotNil {
    unsigned int size = 4;
    NSURL *prevURL = [NSURL URLWithString:@"prev"];
    NXMPageResponse *response = [NXMConverationsPageTests pageResponseWithSize:size
                                                                       nextURL:[NSURL URLWithString:@"next"]
                                                                       prevURL:prevURL];
    NXMConversationsPage *conversationsPage = [[NXMConversationsPage alloc] initWithSize:size
                                                                                   order:NXMPageOrderAsc
                                                                            pageResponse:response
                                                                conversationsPagingProxy:self.conversationsPageProxyMock
                                                                           conversations:[NSArray new]];
    id completionHandler = ^(NSError * _Nullable error, NXMConversationsPage * _Nullable page) { };
    OCMExpect([self.conversationsPageProxyMock getConversationsPageForURL:prevURL
                                                        completionHandler:completionHandler]);
    [conversationsPage previousPage:completionHandler];
}

+ (nonnull NXMPageResponse *)pageResponseWithSize:(unsigned int)size
                                          nextURL:(nullable NSURL *)nextURL
                                          prevURL:(nullable NSURL *)prevURL {
    NXMPageLinks *pageLinks = [[NXMPageLinks alloc] initWithFirst:[NSURL URLWithString:@"first"]
                                                        andWithMe:[NSURL URLWithString:@"me"]
                                                      andWithNext:nextURL
                                                      andWithPrev:prevURL];
    return [[NXMPageResponse alloc] initWithPageSize:size
                                       andWithCursor:@"cursor"
                                         andWithData:[NSArray new]
                                    andWithPageLinks:pageLinks];
}

@end
