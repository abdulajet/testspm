//
//  NXMConversationTests.m
//  StitchClientTests
//
//  Created by Doron Biaz on 11/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMOCK/OCMOCK.h>

#import "NXMStitchContext.h"
#import "NXMConversation.h"
#import "NXMConversationPrivate.h"

#import "NXMTestingUtilities.h"

@interface NXMConversationTests : XCTestCase
@property (nonatomic) id stitchContextMock;
@property (nonatomic) id stitchCoreMock;
@property (nonatomic) id eventsDispatcherMock;
@property (nonatomic) id notificationCenterMock;
@end

@implementation NXMConversationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.stitchContextMock = OCMClassMock([NXMStitchContext class]);
    self.stitchCoreMock = OCMClassMock([NXMStitchCore class]);
    self.eventsDispatcherMock = OCMClassMock([NXMEventsDispatcher class]);
    self.notificationCenterMock = OCMClassMock([NSNotificationCenter class]);

    OCMStub([self.notificationCenterMock addObserver:[OCMArg any] selector:[OCMArg anySelector]  name:[OCMArg isKindOfClass:[NSString class]] object:[OCMArg any]]);
    OCMStub([self.eventsDispatcherMock notificationCenter]).andReturn(self.notificationCenterMock);
    OCMStub([self.stitchContextMock eventsDispatcher]).andReturn(self.eventsDispatcherMock);
    OCMStub([self.stitchContextMock coreClient]).andReturn(self.stitchCoreMock);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.stitchCoreMock stopMocking];
    [self.stitchContextMock stopMocking];
    [self.eventsDispatcherMock stopMocking];
    [self.notificationCenterMock stopMocking];
    [super tearDown];
}

#pragma mark - helper methods
- (void)setContextWithUserId:(NSString *)userId {
    NSString *userName = [@"name_" stringByAppendingString:userId];
    NXMUser *user = [[NXMUser alloc] initWithId:userId name:userName displayName:userName];
    OCMStub([self.stitchContextMock currentUser]).andReturn(user);
}

- (void)verifySignToEventsDispatcher {
    OCMVerify([self.notificationCenterMock addObserver:[OCMArg any] selector:[OCMArg anySelector] name:kNXMEventsDispatcherNotificationMedia object:[OCMArg any]]);
    OCMVerify([self.notificationCenterMock addObserver:[OCMArg any] selector:[OCMArg anySelector] name:kNXMEventsDispatcherNotificationMember object:[OCMArg any]]);
    OCMVerify([self.notificationCenterMock addObserver:[OCMArg any] selector:[OCMArg anySelector] name:kNXMEventsDispatcherNotificationMessage object:[OCMArg any]]);
    OCMVerify([self.notificationCenterMock addObserver:[OCMArg any] selector:[OCMArg anySelector] name:kNXMEventsDispatcherNotificationMessageStatus object:[OCMArg any]]);
    OCMVerify([self.notificationCenterMock addObserver:[OCMArg any] selector:[OCMArg anySelector] name:kNXMEventsDispatcherNotificationTyping object:[OCMArg any]]);

}

#pragma mark - init tests
//- (void)testInitWithConversationDetailsAndStitchContext_CurrentUserJoinedToConversation {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//    NSString *user1Id = @"user1";
//    NSString *user2Id = @"user2";
//    NXMMember *currentMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateJoined];
//
//    [self setContextWithUserId:currentUserId];
//    NSArray<NXMMember *> *members = @[currentMember,
//                                      [NXMTestingUtils memberWithConversationId:convId andUserId:user1Id state:NXMMemberStateJoined],
//                                      [NXMTestingUtils memberWithConversationId:convId andUserId:user2Id state:NXMMemberStateLeft]];
//
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:members];
//
//    //Act
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//
//    //Assert
//    XCTAssertNotNil(conversation);
//    XCTAssertEqualObjects(conversation.myMember, currentMember);
//    [self verifySignToEventsDispatcher];
//}
//
//- (void)testInitWithConversationDetailsAndStitchContext_CurrentUserInvitedToConversation {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//    NSString *user1Id = @"user1";
//    NSString *user2Id = @"user2";
//    NXMMember *currentMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateInvited];
//
//    [self setContextWithUserId:currentUserId];
//    NSArray<NXMMember *> *members = @[currentMember,
//                                      [NXMTestingUtils memberWithConversationId:convId andUserId:user1Id state:NXMMemberStateJoined],
//                                      [NXMTestingUtils memberWithConversationId:convId andUserId:user2Id state:NXMMemberStateLeft]];
//
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:members];
//
//    //Act
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//
//    //Assert
//    XCTAssertNotNil(conversation);
//    XCTAssertNil(conversation.myMember);
//    [self verifySignToEventsDispatcher];
//}
//
//- (void)testInitWithConversationDetailsAndStitchContext_CurrentUserLeftConversation {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//    NSString *user1Id = @"user1";
//    NSString *user2Id = @"user2";
//    NXMMember *currentMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateLeft];
//
//    [self setContextWithUserId:currentUserId];
//    NSArray<NXMMember *> *members = @[currentMember,
//                                      [NXMTestingUtils memberWithConversationId:convId andUserId:user1Id state:NXMMemberStateJoined],
//                                      [NXMTestingUtils memberWithConversationId:convId andUserId:user2Id state:NXMMemberStateLeft]];
//
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:members];
//
//    //Act
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//
//    //Assert
//    XCTAssertNotNil(conversation);
//    XCTAssertNil(conversation.myMember);
//    [self verifySignToEventsDispatcher];
//}
//
//- (void)testInitWithConversationDetailsAndStitchContext_CurrentUserNotInConversation {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//    NSString *user1Id = @"user1";
//    NSString *user2Id = @"user2";
//
//    [self setContextWithUserId:currentUserId];
//    NSArray<NXMMember *> *members = @[[NXMTestingUtils memberWithConversationId:convId andUserId:user1Id state:NXMMemberStateJoined],
//                                             [NXMTestingUtils memberWithConversationId:convId andUserId:user2Id state:NXMMemberStateLeft]];
//
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:members];
//
//    //Act
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//
//    //Assert
//    XCTAssertNotNil(conversation);
//    XCTAssertNil(conversation.myMember);
//    [self verifySignToEventsDispatcher];
//}
//
//- (void)testInitWithConversationDetailsAndStitchContext_NoMembersInConversation {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//
//    [self setContextWithUserId:currentUserId];
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:nil];
//
//    //Act
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//
//    //Assert
//    XCTAssertNotNil(conversation);
//    XCTAssertNil(conversation.myMember);
//    [self verifySignToEventsDispatcher];
//}

#pragma mark - members tests
#pragma mark JoineMemberWithUserId

//- (void)testJoinMemberWithUserId_JoinSomeoneElseWithCompletion {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//    NSString *anotherUserId = @"anotherUser";
//    
//    NXMMember *returnedMember = [NXMTestingUtils memberWithConversationId:convId andUserId:anotherUserId state:NXMMemberStateJoined];
//    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:anotherUserId onSuccess:([OCMArg invokeBlockWithArgs:returnedMember, nil]) onError:[OCMArg any]]);
//    
//    [self setContextWithUserId:currentUserId];
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:nil];
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//    
//    //Act
//    XCTestExpectation *expectation =
//    [self expectationWithDescription:NSStringFromSelector(_cmd)];
//    
//    [conversation joinMemberWithUserId:anotherUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
//        //Assert
//        XCTAssertNil(error);
//        XCTAssertNotNil(member);
//        XCTAssertEqualObjects(member, returnedMember);
//        XCTAssertNil(conversation.myMember);
//        [expectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
//        XCTAssertNotNil(conversation);
//        XCTAssertNil(error);
//    }];
//}
//
//- (void)testJoinMemberWithUserId_JoinSelfWithCompletion {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//    
//    NXMMember *returnedMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateJoined];
//    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:currentUserId onSuccess:([OCMArg invokeBlockWithArgs:returnedMember, nil]) onError:[OCMArg any]]);
//    
//    [self setContextWithUserId:currentUserId];
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:nil];
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//    
//    //Act
//    XCTestExpectation *expectation =
//    [self expectationWithDescription:NSStringFromSelector(_cmd)];
//    
//    [conversation joinMemberWithUserId:currentUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
//        //Assert
//        XCTAssertNil(error);
//        XCTAssertNotNil(member);
//        XCTAssertEqualObjects(member, returnedMember);
//        XCTAssertEqualObjects(conversation.myMember, returnedMember);
//        [expectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
//        XCTAssertNotNil(conversation);
//        XCTAssertNil(error);
//    }];
//}
//
//- (void)testJoinMemberWithUserId_JoinSomeoneElseWithNilCompletion {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//    NSString *anotherUserId = @"anotherUser";
//    
//    XCTestExpectation *expectation =
//    [self expectationWithDescription:NSStringFromSelector(_cmd)];
//    
//    NXMMember *returnedMember = [NXMTestingUtils memberWithConversationId:convId andUserId:anotherUserId state:NXMMemberStateJoined];
//    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:anotherUserId onSuccess:([OCMArg invokeBlockWithArgs:returnedMember, nil]) onError:[OCMArg any]]).andDo(^(NSInvocation *invocation){
//        [expectation fulfill];
//    });
//    
//    [self setContextWithUserId:currentUserId];
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:nil];
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//    
//    //Act
//    [conversation joinMemberWithUserId:anotherUserId completion:nil];
//    
//    //Assert
//    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
//        XCTAssertNotNil(conversation);
//        XCTAssertNil(error);
//        XCTAssertNil(conversation.myMember);
//        }];
//}
//
//- (void)testJoinMemberWithUserId_JoinSelfWithNilCompletion {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//    
//    XCTestExpectation *expectation =
//    [self expectationWithDescription:NSStringFromSelector(_cmd)];
//    
//    NXMMember *returnedMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateJoined];
//    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:currentUserId onSuccess:([OCMArg invokeBlockWithArgs:returnedMember, nil]) onError:[OCMArg any]]).andDo(^(NSInvocation *invocation){
//        [expectation fulfill];
//    });
//    
//    [self setContextWithUserId:currentUserId];
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:nil];
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//    
//    //Act
//    [conversation joinMemberWithUserId:currentUserId completion:nil];
//    
//    //Assert
//    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
//        XCTAssertNotNil(conversation);
//        XCTAssertNil(error);
//        XCTAssertNotNil(conversation.myMember);
//        XCTAssertEqualObjects(conversation.myMember, returnedMember);
//    }];
//}
//
//- (void)testJoinMemberWithUserId_JoinSomeoneElseAndCoreReturnsError {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//    NSString *anotherUserId = @"anotherUser";
//    
//    NSError *returnedError = [NSError new];
//    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:anotherUserId onSuccess:[OCMArg any] onError:([OCMArg invokeBlockWithArgs:returnedError, nil])]);
//    
//    [self setContextWithUserId:currentUserId];
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:nil];
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//    
//    //Act
//    XCTestExpectation *expectation =
//    [self expectationWithDescription:NSStringFromSelector(_cmd)];
//    
//    [conversation joinMemberWithUserId:anotherUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
//        //Assert
//        XCTAssertNil(member);
//        XCTAssertNotNil(error);
//        XCTAssertNil(conversation.myMember);
//        [expectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
//        XCTAssertNotNil(conversation);
//        XCTAssertNil(error);
//    }];
//}
//
//- (void)testJoinMemberWithUserId_JoinSelfAndCoreReturnsError {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//    
//    NSError *returnedError = [NSError new];
//    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:currentUserId onSuccess:[OCMArg any] onError:([OCMArg invokeBlockWithArgs:returnedError, nil])]);
//    
//    [self setContextWithUserId:currentUserId];
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:nil];
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//    
//    //Act
//    XCTestExpectation *expectation =
//    [self expectationWithDescription:NSStringFromSelector(_cmd)];
//    
//    [conversation joinMemberWithUserId:currentUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
//        //Assert
//        XCTAssertNil(member);
//        XCTAssertNotNil(error);
//        XCTAssertNil(conversation.myMember);
//        [expectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
//        XCTAssertNotNil(conversation);
//        XCTAssertNil(error);
//    }];
//}
//
//- (void)testJoinMemberWithUserId_JoinSomeoneElseWhoseAlreadyInTheConversation {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//    NSString *anotherUserId = @"anotherUser";
//    
//    NSError *returnedError = [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeEventUserAlreadyJoined andUserInfo:nil];
//    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:anotherUserId onSuccess:[OCMArg any] onError:([OCMArg invokeBlockWithArgs:returnedError, nil])]);
//    
//    [self setContextWithUserId:currentUserId];
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:nil];
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//    
//    //Act
//    XCTestExpectation *expectation =
//    [self expectationWithDescription:NSStringFromSelector(_cmd)];
//    
//    [conversation joinMemberWithUserId:anotherUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
//        //Assert
//        XCTAssertNil(member);
//        XCTAssertNotNil(error);
//        XCTAssertNil(conversation.myMember);
//        [expectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
//        XCTAssertNotNil(conversation);
//        XCTAssertNil(error);
//    }];
//}
//
//- (void)testJoinMemberWithUserId_JoinSelfWhenAlreadyInTheConversation {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//    
//    NSError *returnedError = [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeEventUserAlreadyJoined andUserInfo:nil];
//    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:currentUserId onSuccess:[OCMArg any] onError:([OCMArg invokeBlockWithArgs:returnedError, nil])]);
//    
//    [self setContextWithUserId:currentUserId];
//    NXMMember *currentMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateJoined];
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:@[currentMember]];
//    
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//    
//    //Act
//    XCTestExpectation *expectation =
//    [self expectationWithDescription:NSStringFromSelector(_cmd)];
//    
//    [conversation joinMemberWithUserId:currentUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
//        //Assert
//        XCTAssertNil(member);
//        XCTAssertNotNil(error);
//        XCTAssertNotNil(conversation.myMember);
//        XCTAssertEqualObjects(conversation.myMember, currentMember);
//        [expectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
//        XCTAssertNotNil(conversation);
//        XCTAssertNil(error);
//    }];
//}
//
//- (void)testJoinMemberWithUserId_JoinSelfWhenInvitedInTheConversation {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//    
//    NSError *returnedError = [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeEventUserAlreadyJoined andUserInfo:nil];
//    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:currentUserId onSuccess:[OCMArg any] onError:([OCMArg invokeBlockWithArgs:returnedError, nil])]);
//    
//    [self setContextWithUserId:currentUserId];
//    NXMMember *currentMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateInvited];
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:@[currentMember]];
//    
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//    
//    //Act
//    XCTestExpectation *expectation =
//    [self expectationWithDescription:NSStringFromSelector(_cmd)];
//    
//    [conversation joinMemberWithUserId:currentUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
//        //Assert
//        XCTAssertNil(member);
//        XCTAssertNotNil(error);
//        XCTAssertNil(conversation.myMember);
//        [expectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
//        XCTAssertNotNil(conversation);
//        XCTAssertNil(error);
//    }];
//}
//
//- (void)testJoinMemberWithUserId_JoinSelfAfterLeavingTheConversation {
//    //Arrange
//    NSString *convId = @"convId";
//    NSString *currentUserId = @"currentUser";
//    
//    NSError *returnedError = [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeEventUserAlreadyJoined andUserInfo:nil];
//    OCMStub([self.stitchCoreMock joinToConversation:convId withUserId:currentUserId onSuccess:[OCMArg any] onError:([OCMArg invokeBlockWithArgs:returnedError, nil])]);
//    
//    [self setContextWithUserId:currentUserId];
//    NXMMember *currentMember = [NXMTestingUtils memberWithConversationId:convId andUserId:currentUserId state:NXMMemberStateLeft];
//    NXMConversationDetails *conversationDetails = [NXMTestingUtils conversationDetailsWithConversationId:convId sequenceId:10 members:@[currentMember]];
//    
//    NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContextMock];
//    
//    //Act
//    XCTestExpectation *expectation =
//    [self expectationWithDescription:NSStringFromSelector(_cmd)];
//    
//    [conversation joinMemberWithUserId:currentUserId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
//        //Assert
//        XCTAssertNil(member);
//        XCTAssertNotNil(error);
//        XCTAssertNil(conversation.myMember);
//        [expectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
//        XCTAssertNotNil(conversation);
//        XCTAssertNil(error);
//    }];
//}
@end
