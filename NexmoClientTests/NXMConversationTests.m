//
//  NXMConversationTests.m
//  StitchClientTests
//
//  Created by Doron Biaz on 11/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMOCK/OCMOCK.h>

#import "NXMConversationPrivate.h"

#import "NXMTestingUtilities.h"
#import "NXMStitchContext.h"
#import "NXMConversationEventsQueue.h"

@interface NXMConversationTests : XCTestCase
@property (nonatomic) id stitchContextMock;
@property (nonatomic) id stitchCoreMock;
@property (nonatomic) id eventsQueueMock;
@end

@implementation NXMConversationTests

- (void)setUp {
    [super setUp];

    self.stitchContextMock = OCMClassMock([NXMStitchContext class]);
    self.stitchCoreMock = OCMClassMock([NXMStitchCore class]);
    self.eventsQueueMock = OCMClassMock([NXMConversationEventsQueue class]);

    OCMStub([self.eventsQueueMock alloc]).andReturn(self.eventsQueueMock);
    OCMStub([self.eventsQueueMock initWithConversationDetails:[OCMArg any] stitchContext:[OCMArg any] delegate:[OCMArg any]])
        .andReturn(self.eventsQueueMock);
    
    OCMStub([self.stitchContextMock coreClient]).andReturn(self.stitchCoreMock);
}

- (void)tearDown {

    [self.stitchCoreMock stopMocking];
    [self.stitchContextMock stopMocking];
    [self.eventsQueueMock stopMocking];

    [super tearDown];
}

#pragma mark - helper methods
- (void)setContextWithUserId:(NSString *)userId {
    NSString *userName = [@"name_" stringByAppendingString:userId];
    NXMUser *user = [[NXMUser alloc] initWithId:userId name:userName displayName:userName];
    OCMStub([self.stitchContextMock currentUser]).andReturn(user);
}

#pragma mark - init tests
- (void)testInitWithConversationDetailsAndStitchContext_CurrentUserJoinedToConversation {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    NSString *user1Id = @"user1";
    NSString *user2Id = @"user2";
    NXMMember *currentMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateJoined];

    [self setContextWithUserId:currentUserId];
    NSArray<NXMMember *> *members = @[currentMember,
                                      [NXMTestingUtils memberWithConversationId:convId andUserId:user1Id state:NXMMemberStateJoined],
                                      [NXMTestingUtils memberWithConversationId:convId andUserId:user2Id state:NXMMemberStateLeft]];

    //Act
    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:members];

    //Assert
    XCTAssertEqualObjects(conversation.myMember, currentMember);
}

- (void)testInitWithConversationDetailsAndStitchContext_CurrentUserInvitedToConversation {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    NSString *user1Id = @"user1";
    NSString *user2Id = @"user2";
    NXMMember *currentMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateInvited];

    [self setContextWithUserId:currentUserId];
    NSArray<NXMMember *> *members = @[currentMember,
                                      [NXMTestingUtils memberWithConversationId:convId andUserId:user1Id state:NXMMemberStateJoined],
                                      [NXMTestingUtils memberWithConversationId:convId andUserId:user2Id state:NXMMemberStateLeft]];

    //Act
    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:members];

    //Assert
    XCTAssertNotNil(conversation);
    XCTAssertNil(conversation.myMember);
}

- (void)testInitWithConversationDetailsAndStitchContext_CurrentUserLeftConversation {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    NSString *user1Id = @"user1";
    NSString *user2Id = @"user2";
    NXMMember *currentMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateLeft];

    [self setContextWithUserId:currentUserId];
    NSArray<NXMMember *> *members = @[currentMember,
                                      [NXMTestingUtils memberWithConversationId:convId andUserId:user1Id state:NXMMemberStateJoined],
                                      [NXMTestingUtils memberWithConversationId:convId andUserId:user2Id state:NXMMemberStateLeft]];

    //Act
    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:members];

    //Assert
    XCTAssertNotNil(conversation);
    XCTAssertNil(conversation.myMember);
}

- (void)testInitWithConversationDetailsAndStitchContext_CurrentUserNotInConversation {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    NSString *user1Id = @"user1";
    NSString *user2Id = @"user2";

    [self setContextWithUserId:currentUserId];
    NSArray<NXMMember *> *members = @[[NXMTestingUtils memberWithConversationId:convId andUserId:user1Id state:NXMMemberStateJoined],
                                             [NXMTestingUtils memberWithConversationId:convId andUserId:user2Id state:NXMMemberStateLeft]];

    //Act
    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:members];

    //Assert
    XCTAssertNotNil(conversation);
    XCTAssertNil(conversation.myMember);
}

- (void)testInitWithConversationDetailsAndStitchContext_NoMembersInConversation {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";

    [self setContextWithUserId:currentUserId];

    //Act
    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:nil];

    //Assert
    XCTAssertNotNil(conversation);
    XCTAssertNil(conversation.myMember);
}

#pragma mark - members tests
#pragma mark JoineMemberWithUserId

- (void)testJoinMemberWithUserId_JoinSomeoneElseWithCompletion {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    NSString *anotherUserId = @"anotherUser";
    
    NXMMember *returnedMember = [NXMTestingUtils memberWithConversationId:convId andUserId:anotherUserId state:NXMMemberStateJoined];
    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:anotherUserId onSuccess:([OCMArg invokeBlockWithArgs:returnedMember, nil]) onError:[OCMArg any]]);
    
    [self setContextWithUserId:currentUserId];
    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:@[returnedMember]];
    
    //Act
    XCTestExpectation *expectation =
    [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [conversation joinMemberWithUserId:anotherUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
        //Assert
        XCTAssertNil(error);
        XCTAssertNotNil(member);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(conversation);
        XCTAssertNil(error);
    }];
}

- (void)testJoinMemberWithUserId_JoinSelfWithCompletion {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    
    NXMMember *returnedMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateJoined];
    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:currentUserId onSuccess:([OCMArg invokeBlockWithArgs:returnedMember, nil]) onError:[OCMArg any]]);
    
    [self setContextWithUserId:currentUserId];

    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:@[returnedMember]];
    
    //Act
    XCTestExpectation *expectation =
    [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [conversation joinMemberWithUserId:currentUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
        //Assert
        XCTAssertNil(error);
        XCTAssertNotNil(member);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(conversation);
        XCTAssertNil(error);
    }];
}

- (void)testJoinMemberWithUserId_JoinSomeoneElseWithNilCompletion {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    NSString *anotherUserId = @"anotherUser";
    
    XCTestExpectation *expectation =
    [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    NXMMember *returnedMember = [NXMTestingUtils memberWithConversationId:convId andUserId:anotherUserId state:NXMMemberStateJoined];
    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:anotherUserId onSuccess:([OCMArg invokeBlockWithArgs:returnedMember, nil]) onError:[OCMArg any]]).andDo(^(NSInvocation *invocation){
        [expectation fulfill];
    });
    
    [self setContextWithUserId:currentUserId];

    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:@[returnedMember]];
    
    //Act
    [conversation joinMemberWithUserId:anotherUserId completion:nil];
    
    //Assert
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(conversation);
        XCTAssertNil(error);
        }];
}

- (void)testJoinMemberWithUserId_JoinSelfWithNilCompletion {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    
    XCTestExpectation *expectation =
    [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    NXMMember *returnedMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateJoined];
    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:currentUserId onSuccess:([OCMArg invokeBlockWithArgs:returnedMember, nil]) onError:[OCMArg any]]).andDo(^(NSInvocation *invocation){
        [expectation fulfill];
    });
    
    [self setContextWithUserId:currentUserId];

    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:@[returnedMember]];
    
    //Act
    [conversation joinMemberWithUserId:currentUserId completion:nil];
    
    //Assert
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(conversation);
        XCTAssertNil(error);
    }];
}

- (void)testJoinMemberWithUserId_JoinSomeoneElseAndCoreReturnsError {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    NSString *anotherUserId = @"anotherUser";
    
    NSError *returnedError = [NSError new];
    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:anotherUserId onSuccess:[OCMArg any] onError:([OCMArg invokeBlockWithArgs:returnedError, nil])]);
    
    [self setContextWithUserId:currentUserId];

    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:nil];
    
    //Act
    XCTestExpectation *expectation =
    [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [conversation joinMemberWithUserId:anotherUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
        //Assert
        XCTAssertNil(member);
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(conversation);
        XCTAssertNil(error);
    }];
}

- (void)testJoinMemberWithUserId_JoinSelfAndCoreReturnsError {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    
    NSError *returnedError = [NSError new];
    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:currentUserId onSuccess:[OCMArg any] onError:([OCMArg invokeBlockWithArgs:returnedError, nil])]);
    
    [self setContextWithUserId:currentUserId];
    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:nil];
    
    //Act
    XCTestExpectation *expectation =
    [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [conversation joinMemberWithUserId:currentUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
        //Assert
        XCTAssertNil(member);
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(conversation);
        XCTAssertNil(error);
    }];
}

- (void)testJoinMemberWithUserId_JoinSomeoneElseWhoseAlreadyInTheConversation {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    NSString *anotherUserId = @"anotherUser";
    
    NSError *returnedError = [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeEventUserAlreadyJoined andUserInfo:nil];
    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:anotherUserId onSuccess:[OCMArg any] onError:([OCMArg invokeBlockWithArgs:returnedError, nil])]);
    
    [self setContextWithUserId:currentUserId];

    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:nil];
    
    //Act
    XCTestExpectation *expectation =
    [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [conversation joinMemberWithUserId:anotherUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
        //Assert
        XCTAssertNil(member);
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(conversation);
        XCTAssertNil(error);
    }];
}

- (void)testJoinMemberWithUserId_JoinSelfWhenAlreadyInTheConversation {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    
    NSError *returnedError = [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeEventUserAlreadyJoined andUserInfo:nil];
    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:currentUserId onSuccess:[OCMArg any] onError:([OCMArg invokeBlockWithArgs:returnedError, nil])]);
    
    [self setContextWithUserId:currentUserId];
    NXMMember *currentMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateJoined];
    
    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:@[currentMember]];
    
    //Act
    XCTestExpectation *expectation =
    [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [conversation joinMemberWithUserId:currentUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
        //Assert
        XCTAssertNil(member);
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(conversation);
        XCTAssertNil(error);
    }];
}

- (void)testJoinMemberWithUserId_JoinSelfWhenInvitedInTheConversation {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    
    NSError *returnedError = [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeEventUserAlreadyJoined andUserInfo:nil];
    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:currentUserId onSuccess:[OCMArg any] onError:([OCMArg invokeBlockWithArgs:returnedError, nil])]);
    
    [self setContextWithUserId:currentUserId];
    NXMMember *currentMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateInvited];
    
    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:@[currentMember]];
    
    //Act
    XCTestExpectation *expectation =
    [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [conversation joinMemberWithUserId:currentUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
        //Assert
        XCTAssertNil(member);
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(conversation);
        XCTAssertNil(error);
    }];
}

- (void)testJoinMemberWithUserId_JoinSelfAfterLeavingTheConversation {
    //Arrange
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    
    NSError *returnedError = [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeEventUserAlreadyJoined andUserInfo:nil];
    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:currentUserId onSuccess:[OCMArg any] onError:([OCMArg invokeBlockWithArgs:returnedError, nil])]);
    
    [self setContextWithUserId:currentUserId];
    NXMMember *currentMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateLeft];
    
    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:@[currentMember]];
    //Act
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [conversation joinMemberWithUserId:currentUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
        //Assert
        XCTAssertNil(member);
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(conversation);
        XCTAssertNil(error);
    }];
}

#pragma mark - typing tests
- (void)testSendStartTyping {
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    
    
    OCMExpect([self.stitchCoreMock startTypingWithConversationId:convId memberId:currentUserId]);
    
    [self setContextWithUserId:currentUserId];
    NXMMember *currentMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateJoined];
    
    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:@[currentMember]];
    
    //Act
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [conversation sendStartTypingWithCompletion:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:4 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(conversation);
        XCTAssertNil(error);
    }];
}

- (void)testSendStartTyping_SelfNotInConversation {
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    
    [self setContextWithUserId:currentUserId];
    
    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:nil];
    
    //Act
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [conversation sendStartTypingWithCompletion:^(NSError * _Nullable error) {
        XCTAssertEqual(error.code, NXMStitchErrorCodeNotAMemberOfTheConversation);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(conversation);
        XCTAssertNil(error);
    }];
}

- (void)testSendStopTyping {
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    
    OCMExpect([self.stitchCoreMock stopTypingWithConversationId:convId memberId:currentUserId]);
    
    [self setContextWithUserId:currentUserId];
    NXMMember *currentMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateJoined];
    
    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:@[currentMember]];
    
    //Act
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [conversation sendStopTypingWithCompletion:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(conversation);
        XCTAssertNil(error);
    }];
}

- (void)testSendStopTyping_SelfNotInConversation {
    NSString *convId = @"convId";
    NSString *currentUserId = @"currentUser";
    
    [self setContextWithUserId:currentUserId];
    
    NXMConversation *conversation = [self createDefaultConversationWithConvId:convId members:nil];
    
    //Act
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [conversation sendStopTypingWithCompletion:^(NSError * _Nullable error) {
        XCTAssertEqual(error.code, NXMStitchErrorCodeNotAMemberOfTheConversation);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(conversation);
        XCTAssertNil(error);
    }];
}


#pragma mark - helpers

- (NXMConversation *)createDefaultConversationWithConvId:(NSString *)convId members:(NSArray<NXMMember *> *)members {
    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:members];
    NXMConversation *conv = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
    
    return conv;
}

@end
