//
//  NXMConversation.m
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationPrivate.h"
#import "NXMStitchContext.h"
#import "NXMConversationMembersController.h"
#import "NXMConversationEventsQueue.h"
#import "NXMBlocksHelper.h"
#import "NXMErrorsPrivate.h"
#import "NXMConversationMembersController.h"
#import "NXMLoggerInternal.h"


@interface NXMConversation () <NXMConversationEventsQueueDelegate,NXMConversationMembersControllerDelegate>
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
        self.conversationMembersController = [[NXMConversationMembersController alloc]
                                              initWithConversationDetails:self.conversationDetails
                                              andCurrentUser:self.currentUser
                                              delegate:self];
        
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

- (NSArray<NXMMember *> *)allMembers {
    return self.conversationMembersController.allMembers;
}

#pragma mark Private Properties
- (NXMUser *)currentUser {
    return self.stitchContext.currentUser;
}

#pragma mark EventQueueDelegate

- (void)handleEvent:(NXMEvent*_Nonnull)event {
    [self.conversationMembersController handleEvent:event];
    
    switch (event.type) {
        case NXMEventTypeGeneral:
            break;
        case NXMEventTypeCustom:
            if([self.delegate respondsToSelector:@selector(didReceiveCustomEvent:)]) {
                [self.delegate didReceiveCustomEvent:(NXMCustomEvent *)event];
            }
            break;
        case NXMEventTypeText:
            if([self.delegate respondsToSelector:@selector(didReceiveTextEvent:)]) {
                [self.delegate didReceiveTextEvent:(NXMTextEvent *)event];
            }
            break;
        case NXMEventTypeImage:
            if([self.delegate respondsToSelector:@selector(didReceiveImageEvent:)]) {
                [self.delegate didReceiveImageEvent:(NXMImageEvent *)event];
            }
            break;
        case NXMEventTypeMessageStatus:
            if([self.delegate respondsToSelector:@selector(didReceiveMessageStatusEvent:)]) {
                [self.delegate didReceiveMessageStatusEvent:(NXMMessageStatusEvent *)event];
            }
            break;
        case NXMEventTypeTextTyping:
            if([self.delegate respondsToSelector:@selector(didReceiveTypingEvent:)]) {
                [self.delegate didReceiveTypingEvent:(NXMTextTypingEvent *)event];
            }
            break;
        case NXMEventTypeMedia:
        case NXMEventTypeMediaAction:
        case NXMEventTypeDTMF:
            if([self.delegate respondsToSelector:@selector(didReceiveMediaEvent:)]) {
                [self.delegate didReceiveMediaEvent:event];
            }
            break;
        case NXMEventTypeMember:
            if([self.delegate respondsToSelector:@selector(didReceiveMemberEvent:)]) {
                [self.delegate didReceiveMemberEvent:(NXMMemberEvent *)event];
            }
            break;
        case NXMEventTypeLegStatus:
            if([self.delegate respondsToSelector:@selector(didReceiveLegStatusEvent:)]) {
                [self.delegate didReceiveLegStatusEvent:(NXMLegStatusEvent *)event];
            }
        case NXMEventTypeSip:
            break;
        default:
            break;
    }
}

- (void)conversationExpired {
    [self.conversationMembersController conversationExpired];
    if([self.delegate respondsToSelector:@selector(conversationExpired)]) {
        [self.delegate conversationExpired];
    }
}

#pragma mark - Public Methods

#pragma mark members
- (void)join:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completion {
    [self joinMemberWithUsername:self.currentUser.name completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
        [NXMBlocksHelper runWithError:error value:member completion:completion];
    }];
}

- (void)joinMemberWithUsername:(nonnull NSString *)username
                  completion:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completion {
    [self.stitchContext.coreClient joinToConversation:self.conversationId
                                           withUsername:username
                                            onSuccess:^(NSObject * _Nullable object) {
                                                [NXMBlocksHelper runWithError:nil value:object completion:completion];
                                            }
                                              onError:^(NSError * _Nullable error) {
                                                  [NXMBlocksHelper runWithError:error value:nil completion:completion];

                                              }];
}

- (void)leave:(void (^_Nullable)(NSError * _Nullable error))completion {
    [self kickMemberWithMemberId:self.myMember.memberId completion:completion];
}


- (void)kickMemberWithMemberId:(nonnull NSString *)memberId completion:(void (^_Nullable)(NSError * _Nullable error))completion {
    [self.stitchContext.coreClient deleteMember:memberId
                         fromConversationWithId:self.conversationId
                                      onSuccess:^(NSString * _Nullable value) {
                                          [NXMBlocksHelper runWithError:nil completion:completion];

                                      }
                                        onError:^(NSError * _Nullable error) {
                                            [NXMBlocksHelper runWithError:error completion:completion];

                                        }];
}

- (void)sendCustomWithEvent:(nonnull NSString *)customType
                   data:(nonnull NSDictionary *)data
             completionHandler:(void (^_Nullable)(NSError * _Nullable error))completion {
    NSError *validityError = [self validateMyMemberJoined];
    if (validityError) {
        [NXMBlocksHelper runWithError:validityError completion:completion];
        
        return;
    }
    
    [self.stitchContext.coreClient sendCustomEvent:customType
                                              body:data
                                    conversationId:self.conversationId
                                      fromMemberId:self.myMember.memberId
                                         onSuccess:^(NSString * _Nullable value) {
                                             [NXMBlocksHelper runWithError:nil completion:completion];
                                         }
                                           onError:^(NSError * _Nullable error) {
                                               [NXMBlocksHelper runWithError:error completion:completion];
                                           }];
    
}

- (void)sendDTMF:(NSString *)dtmf  completion:(void (^_Nullable)(NSError * _Nullable error))completion {
    NSError *validityError = [self validateMyMemberJoined];
    if (validityError) {
        [NXMBlocksHelper runWithError:validityError completion:completion];
        
        return;
    }
    validityError = [self validateDTMF:dtmf];
    if (validityError) {
        [NXMBlocksHelper runWithError:validityError completion:completion];
        
        return;
    }
    [self.stitchContext.coreClient sendDTMF:dtmf conversationId:self.conversationId fromMemberId:self.myMember.memberId onSuccess:^(NSString * _Nullable value) {
        [NXMBlocksHelper runWithError:nil completion:completion];
    } onError:^(NSError * _Nullable error) {
        [NXMBlocksHelper runWithError:error completion:completion];
    }];
}

-(void)sendText:(nonnull NSString *)text completionHandler:(void (^_Nullable)(NSError * _Nullable error))completion {
    
    NSError *validityError = [self validateMyMemberJoined];
    if (validityError) {
        [NXMBlocksHelper runWithError:validityError completion:completion];

        return;
    }
    
    [self.stitchContext.coreClient sendText:text
                             conversationId:self.conversationId
                               fromMemberId:self.myMember.memberId
                                  onSuccess:^(NSString * _Nullable value) {
                                      [NXMBlocksHelper runWithError:nil completion:completion];
                                  }
                                    onError:^(NSError * _Nullable error) {
                                        [NXMBlocksHelper runWithError:error completion:completion];
                                    }];
}


-(void)sendAttachmentWithType:(NXMAttachmentType)attachmentType name:(nonnull NSString *)name data:(nonnull NSData *)data  completionHandler:(void (^_Nullable)(NSError * _Nullable error))completion {
    NSError *validityError = [self validateMyMemberJoined];
    if (validityError) {
        [NXMBlocksHelper runWithError:validityError completion:completion];

        return;
    }
    
    if(attachmentType != NXMAttachmentTypeImage) {
        [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeNotImplemented andUserInfo:nil] completion:completion];

        return;
    }
    
    [self.stitchContext.coreClient sendImageWithName:name image:data conversationId:self.conversationId fromMemberId:self.myMember.memberId onSuccess:^(NSString * _Nullable value) {
        [NXMBlocksHelper runWithError:nil completion:completion];

    } onError:^(NSError * _Nullable error) {
        [NXMBlocksHelper runWithError:error completion:completion];

    }];
}

- (void)sendMarkSeenMessage:(NSInteger)messageId
            completionHandler:(void (^_Nullable)(NSError * _Nullable error))completion{
    
    NSError *validityError = [self validateMyMemberJoined];
    if (validityError) {
        [NXMBlocksHelper runWithError:validityError completion:completion];
        
        return;
    }
    
    [self.stitchContext.coreClient markAsSeen:messageId
                               conversationId:self.conversationId
                             fromMemberWithId:self.myMember.memberId
                                    onSuccess:^{
                                        [NXMBlocksHelper runWithError:nil completion:completion];
                                    }
                                      onError:^(NSError * _Nullable error) {
                                          [NXMBlocksHelper runWithError:error completion:completion];
                                      }];
}

- (void)sendStartTyping:(void (^_Nullable)(NSError * _Nullable error))completion {
    NSError *validityError = [self validateMyMemberJoined];
    if (validityError) {
        [NXMBlocksHelper runWithError:validityError completion:completion];

        return;
    }
    
    [self.stitchContext.coreClient startTypingWithConversationId:self.conversationId memberId:self.myMember.memberId];
    [NXMBlocksHelper runWithError:nil completion:completion];
}

- (void)sendStopTyping:(void (^_Nullable)(NSError * _Nullable error))completion {
    NSError *validityError = [self validateMyMemberJoined];
    if (validityError) {
        [NXMBlocksHelper runWithError:validityError completion:completion];

        return;
    }
    
    [self.stitchContext.coreClient stopTypingWithConversationId:self.conversationId memberId:self.myMember.memberId];
    [NXMBlocksHelper runWithError:nil completion:completion];
}
#pragma mark internal

- (void)inviteMemberWithUsername:(nonnull NSString *)username
                      completion:(void (^_Nullable)(NSError * _Nullable error))completion {
    [self.stitchContext.coreClient inviteToConversation:self.conversationId
                                           withUsername:username
                                              withMedia:NO
                                              onSuccess:^(NSObject * _Nullable object) {
                                                  [NXMBlocksHelper runWithError:nil completion:completion];
                                                  
                                              } onError:^(NSError * _Nullable error) {
                                                  [NXMBlocksHelper runWithError:error completion:completion];
                                                  
                                              }];
}

- (void)inviteMemberWithUsername:(nonnull NSString *)username withMedia:(bool)withMedia
                    completion:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completion {
    [self.stitchContext.coreClient inviteToConversation:self.conversationId withUsername:username withMedia:withMedia
                                              onSuccess:^(NSObject * _Nullable object) {
                                                    [NXMBlocksHelper runWithError:nil value:object completion:completion];

                                                } onError:^(NSError * _Nullable error) {
                                                    [NXMBlocksHelper runWithError:error value:nil completion:completion];

                                                }];
}

- (void)inviteToConversationWithPhoneNumber:(NSString*)phoneNumber
                                 completion:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable knockingId))completion {
    [self.stitchContext.coreClient inviteToConversation:self.stitchContext.currentUser.name withPhoneNumber:phoneNumber
                                              onSuccess:^(NSString * _Nullable value) {
                                                  [NXMBlocksHelper runWithError:nil value:value completion:completion];
                                              } onError:^(NSError * _Nullable error) {
                                                    [NXMBlocksHelper runWithError:error value:nil completion:completion];
                                                }];
}

- (void)enableMedia {
    [self.stitchContext.coreClient enableMedia:self.conversationId memberId:self.myMember.memberId];
}

- (void)disableMedia {
    LOG_DEBUG([self.conversationId UTF8String]);

    [self.stitchContext.coreClient disableMedia:self.conversationId];
}

- (void)hold:(BOOL)isHold {
    
}

- (void)mute:(BOOL)isMuted {
    if (isMuted) {
        [self.stitchContext.coreClient suspendMyMedia:NXMMediaTypeAudio inConversation:self.conversationId];
        return;
    }
    
    [self.stitchContext.coreClient resumeMyMedia:NXMMediaTypeAudio inConversation:self.conversationId];
}

- (void)earmuff:(BOOL)isEarmuff {
    
}

- (void)getEvents:(void (^_Nullable)(NSError * _Nullable error, NSArray<NXMEvent *> *))completionHandler; {
    [self.stitchContext.coreClient getEventsInConversation:self.conversationId
                                                 onSuccess:^(NSMutableArray<NXMEvent *> * _Nullable events) {
                                                     completionHandler(nil, events);
                                                 } onError:^(NSError * _Nullable error) {
                                                     completionHandler(error, nil);
                                                 }];
}

#pragma mark - Private Methods

- (void)finishHandleEventsSequence {
//    [self.conversationMembersController finishHandleEventsSequence];
}

- (NSError *)validateMyMemberJoined {
    if (self.myMember.state == NXMMemberStateJoined) {
        return nil;
    }
    
    return [NXMErrors nxmErrorWithErrorCode:NXMErrorCodeNotAMemberOfTheConversation andUserInfo:nil];
}

- (NSError *)validateDTMF:dtmf {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[\\da-dA-D#*pP]{1,45}$$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:dtmf
                                                        options:0
                                                          range:NSMakeRange(0, [dtmf length])];
    if (numberOfMatches > 0){
        return nil;
    }
    return [NXMErrors nxmErrorWithErrorCode:NXMErrorCodeDTMFIllegal andUserInfo:nil];
}

#pragma member controller delegate

- (void)nxmConversationMembersController:(NXMConversationMembersController * _Nonnull)controller didChangeMember:(nonnull NXMMember *)member forChangeType:(NXMMemberUpdateType)type {
    if([self.updatesDelegate respondsToSelector:@selector(memberUpdated:forUpdateType:)]) {
        [self.updatesDelegate memberUpdated:member forUpdateType:type];
    }
}

#pragma description
- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> convId=%@ name=%@ displayName=%@ lastEventId=%ld creationDate=%@ myMember=%@ otherMembers=%@",
            NSStringFromClass([self class]),
            self,
            self.conversationId,
            self.name,
            self.displayName,
            self.lastEventId,
            self.creationDate,
            self.myMember,
            self.allMembers];
}

@end
