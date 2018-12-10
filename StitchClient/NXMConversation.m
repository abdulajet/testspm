//
//  NXMConversation.m
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationPrivate.h"
#import "NXMStitchContext.h"
#import "NXMConversationEventsControllerPrivate.h"
#import "NXMConversationMembersController.h"
#import "NXMConversationEventsQueue.h"

@interface NXMConversation () <NXMConversationEventsQueueDelegate>
@property (readwrite, nonatomic) NXMStitchContext *stitchContext;

@property (readwrite, nonatomic, nonnull) NXMConversationDetails *conversationDetails;
@property (readonly, nonatomic, nullable) NXMUser *currentUser;
@property (readwrite, nonatomic, nonnull) NXMConversationEventsQueue *eventsQueue;
@property (readwrite, nonatomic, nullable) NXMConversationMembersController *conversationMembersController;

- (instancetype)initWithConversationDetails:(nonnull NXMConversationDetails *)conversationDetails andStitchContext:(nonnull NXMStitchContext *)stitchContext;
@end

@implementation NXMConversation
- (instancetype)initWithConversationDetails:(NXMConversationDetails *)conversationDetails andStitchContext:(NXMStitchContext *)stitchContext
{
    self = [super init];
    if (self) {
        self.stitchContext = stitchContext;
        self.conversationDetails = conversationDetails;
        self.eventsQueue = [[NXMConversationEventsQueue alloc] initWithConversationDetails:self.conversationDetails stitchContext:self.stitchContext delegate:self];
        self.conversationMembersController = [[NXMConversationMembersController alloc] initWithConversationDetails:self.conversationDetails andCurrentUser:self.currentUser];
    }
    return self;
}

#pragma mark - Properties

- (NSString *)name {
    return self.conversationDetails.name;
}
- (NSString *)displayName {
    return self.conversationDetails.displayName;
}
- (NSString *)conversationId {
    return self.conversationDetails.conversationId;
}
- (NSInteger)lastEventId {
    return self.conversationDetails.sequence_number;
}
- (NSDate *)creationDate {
    return self.conversationDetails.created;
}

- (NXMMember *)myMember {
    return self.conversationMembersController.myMember;
}

- (NSArray<NXMMember *> *)otherMembers {
    return self.conversationMembersController.otherMembers;
}

#pragma mark Private Properties
-(NXMUser *)currentUser {
    return self.stitchContext.currentUser;
}

#pragma mark EventQueueDelegate

- (void)handleEvent:(NXMEvent*_Nonnull)event {
    [self.conversationMembersController handleEvent:event];
    
    switch (event.type) {
        case NXMEventTypeGeneral:
            break;
        case NXMEventTypeText:
            if([self.delegate respondsToSelector:@selector(textEvent:)]) {
                [self.delegate textEvent:(NXMMessageEvent *)event];
            }
            break;
        case NXMEventTypeImage:
            if([self.delegate respondsToSelector:@selector(attachmentEvent:)]) {
                [self.delegate attachmentEvent:(NXMMessageEvent *)event];
            }
            break;
        case NXMEventTypeMessageStatus:
            if([self.delegate respondsToSelector:@selector(messageStatusEvent:)]) {
                [self.delegate messageStatusEvent:(NXMMessageStatusEvent *)event];
            }
            break;
        case NXMEventTypeTextTyping:
            if([self.delegate respondsToSelector:@selector(typingEvent:)]) {
                [self.delegate typingEvent:(NXMTextTypingEvent *)event];
            }
            break;
        case NXMEventTypeMedia:
        case NXMEventTypeMediaAction:
        case NXMEventTypeSip:
            if([self.delegate respondsToSelector:@selector(mediaEvent:)]) {
                [self.delegate mediaEvent:(NXMMediaEvent *)event];
            }
            break;
        case NXMEventTypeMember:
            if([self.delegate respondsToSelector:@selector(memberEvent:)]) {
                [self.delegate memberEvent:(NXMMemberEvent *)event];
            }
            break;
        default:
            break;
    }
}

#pragma mark - Public Methods

#pragma mark members
- (void)joinWithCompletion:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completion {
    [self joinMemberWithUserId:self.currentUser.userId completion:completion];
}

- (void)joinMemberWithUserId:(nonnull NSString *)userId completion:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completion {
    [self.stitchContext.coreClient joinToConversation:self.conversationId
                                           withUserId:userId
                                            onSuccess:^(NSObject * _Nullable object) {
                                                if(completion) {
                                                    completion(nil, (NXMMember *)object);
                                                }
                                            }
                                              onError:^(NSError * _Nullable error) {
                                                  if(completion) {
                                                      completion(error, nil);
                                                  }
                                              }];
}

- (void)leaveWithCompletion:(void (^_Nullable)(NSError * _Nullable error))completion {
    NSError *validityError = [self validateMyMember];
    if (validityError) {
        if(completion) {
            completion(validityError);
        }
        return;
    }
    
    [self kickMemberWithMemberId:self.myMember.memberId completion:completion];
}


- (void)kickMemberWithMemberId:(nonnull NSString *)memberId completion:(void (^_Nullable)(NSError * _Nullable error))completion {
    [self.stitchContext.coreClient deleteMember:memberId
                         fromConversationWithId:self.conversationId
                                      onSuccess:^(NSString * _Nullable value) {
                                          if(completion) {
                                              completion(nil);
                                          }
                                      }
                                        onError:^(NSError * _Nullable error) {
                                            if(completion) {
                                                completion(error);
                                            }
                                        }];
}

-(void)sendText:(nonnull NSString *)text completion:(void (^_Nullable)(NSError * _Nullable error))completion {
    
    NSError *validityError = [self validateMyMember];
    if (validityError) {
        if(completion) {
            completion(validityError);
        }
        return;
    }
    
    [self.stitchContext.coreClient sendText:text
                             conversationId:self.conversationId
                               fromMemberId:self.myMember.memberId
                                  onSuccess:^(NSString * _Nullable value) {
                                      if(completion) {
                                          completion(nil);
                                      }
                                  }
                                    onError:^(NSError * _Nullable error) {
                                        if(completion) {
                                            completion(error);
                                        }
                                    }];
}

-(void)sendAttachmentOfType:(NXMAttachmentType)attachmentType WithName:(nonnull NSString *)name data:(nonnull NSData *)data  completion:(void (^_Nullable)(NSError * _Nullable error))completion {
    NSError *validityError = [self validateMyMember];
    if (validityError) {
        if(completion) {
            completion(validityError);
        }
        return;
    }
    
    if(attachmentType != NXMAttachmentTypeImage) {
        if(completion) {
            completion([NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeNotImplemented andUserInfo:nil]);
        }
        return;
    }
    
    [self.stitchContext.coreClient sendImageWithName:name image:data conversationId:self.conversationId fromMemberId:self.myMember.memberId onSuccess:^(NSString * _Nullable value) {
        if(completion) {
            completion(nil);
        }
    } onError:^(NSError * _Nullable error) {
        if(completion) {
            completion(error);
        }
    }];
}

- (void)sendStartTypingWithCompletion:(void (^_Nullable)(NSError * _Nullable error))completion {
    NSError *validityError = [self validateMyMember];
    if (validityError) {
        if(completion) {
            completion(validityError);
        }
        return;
    }
    
    [self.stitchContext.coreClient startTypingWithConversationId:self.conversationId memberId:self.myMember.memberId];
    completion(nil);
}

- (void)sendStopTypingWithCompletion:(void (^_Nullable)(NSError * _Nullable error))completion {
    NSError *validityError = [self validateMyMember];
    if (validityError) {
        if(completion) {
            completion(validityError);
        }
        return;
    }
    
    [self.stitchContext.coreClient stopTypingWithConversationId:self.conversationId memberId:self.myMember.memberId];
    completion(nil);
}
#pragma mark internal

- (void)inviteMemberWithUserId:(nonnull NSString *)userId withMedia:(bool)withMedia
                    completion:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completion {
    [self.stitchContext.coreClient inviteToConversation:self.conversationId withUserId:userId withMedia:withMedia onSuccess:^(NSObject * _Nullable object) {
        if(completion) {
            completion(nil, (NXMMember *)object);
        }
    } onError:^(NSError * _Nullable error) {
        if(completion) {
            completion(error, nil);
        }
    }];
}

- (void)inviteToConversationWithPhoneNumber:(NSString*)phoneNumber
                                 completion:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable knockingId))completion {
    [self.stitchContext.coreClient inviteToConversation:self.stitchContext.currentUser.name withPhoneNumber:phoneNumber onSuccess:^(NSString * _Nullable value) {
        completion(nil, value);
    } onError:^(NSError * _Nullable error) {
        completion(error,nil);
    }];
}
- (NXMStitchErrorCode)enableMedia:(NSString *)memberId {
    [self.stitchContext.coreClient enableMedia:self.conversationId memberId:memberId];
    return NXMStitchErrorCodeNone;
}

- (NXMStitchErrorCode)disableMedia {
    [self.stitchContext.coreClient disableMedia:self.conversationId];
    return NXMStitchErrorCodeNone;
}

- (void)hold:(BOOL)isHold {
    
}

- (void)mute:(BOOL)isMuted {
    
}

- (void)earmuff:(BOOL)isEarmuff {
    
}

#pragma mark events

- (nonnull NXMConversationEventsController *)eventsControllerWithTypes:(nonnull NSSet<NSNumber *> *)eventTypes andDelegate:(id   <NXMConversationEventsControllerDelegate>_Nullable)delegate{
    return [self createEventsControllerWithTypes:eventTypes andDelegate:delegate];
}

#pragma mark - Private Methods

- (nonnull NXMConversationEventsController *)createEventsControllerWithTypes:(nonnull NSSet<NSNumber *> *)eventTypes andDelegate:(id   <NXMConversationEventsControllerDelegate>_Nullable)delegate{
    return [[NXMConversationEventsController alloc] initWithSubscribedEventsType:eventTypes andConversationDetails:self.conversationDetails andStitchContext:self.stitchContext delegate:delegate];
}

- (void)finishHandleEventsSequence {
    [self.conversationMembersController finishHandleEventsSequence];
}

- (NSError *)validateMyMember {
    if (self.myMember.state == NXMMemberStateJoined) {
        return nil;
    }
    
    return [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeNotAMemberOfTheConversation andUserInfo:nil];
}
@end
