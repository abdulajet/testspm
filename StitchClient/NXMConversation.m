//
//  NXMConversation.m
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversation.h"
#import "NXMStitchContext.h"
#import "NXMConversationEventsControllerPrivate.h"
#import "NXMConversationMembersController.h"
#import "NXMConversationEventsQueue.h"

@interface NXMConversation () <NXMConversationEventsQueueDelegate>
@property (readwrite, nonatomic) NSObject<NXMConversationDelegate> *delegate;
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
        [self signToEventDispatcherEvents];
    }
    return self;
}

#pragma mark - Unsynthesized Properties
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

#pragma mark Private Unsynthesized Properties
-(NXMUser *)currentUser {
    return self.stitchContext.currentUser;
}

#pragma mark - Delegate Methods
- (void)signToEventDispatcherEvents {
    [self.stitchContext.eventsDispatcher.notificationCenter addObserver:self selector:@selector(didReceiveEventNotification:) name:kNXMEventsDispatcherNotificationMedia object:nil];
    [self.stitchContext.eventsDispatcher.notificationCenter addObserver:self selector:@selector(didReceiveEventNotification:) name:kNXMEventsDispatcherNotificationMember object:nil];
    [self.stitchContext.eventsDispatcher.notificationCenter addObserver:self selector:@selector(didReceiveEventNotification:) name:kNXMEventsDispatcherNotificationMessage object:nil];
    [self.stitchContext.eventsDispatcher.notificationCenter addObserver:self selector:@selector(didReceiveEventNotification:) name:kNXMEventsDispatcherNotificationMessageStatus object:nil];
    [self.stitchContext.eventsDispatcher.notificationCenter addObserver:self selector:@selector(didReceiveEventNotification:) name:kNXMEventsDispatcherNotificationTyping object:nil];
}

- (void)didReceiveEventNotification:(NSNotification *)notification {
    NXMEvent *event = [NXMEventsDispatcherNotificationHelper<NXMEvent *> nxmNotificationModelWithNotification:notification];
    if(![event.conversationId isEqualToString:self.conversationId]) {
        return;
    }
    
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        switch (event.type) {
            case NXMEventTypeGeneral:
                break;
            case NXMEventTypeText:
                [self.delegate textEvent:(NXMMessageEvent *)event];
                break;
            case NXMEventTypeImage:
                [self.delegate attachmentEvent:(NXMMessageEvent *)event];
                break;
            case NXMEventTypeMessageStatus:
                [self.delegate messageStatusEvent:(NXMMessageStatusEvent *)event];
                break;
            case NXMEventTypeTextTyping:
                [self.delegate typingEvent:(NXMTextTypingEvent *)event];
                break;
            case NXMEventTypeMedia:
            case NXMEventTypeMediaAction:
            case NXMEventTypeSip:
                [self.delegate mediaEvent:event];
                break;
            case NXMEventTypeMember:
                [self.delegate memberEvent:(NXMMemberEvent *)event];
                break;
            default:
                break;
        }
    }];
}

- (void)setDelegate:(nonnull NSObject<NXMConversationDelegate> *)delegate {
    self.delegate = delegate;
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
    if(!self.myMember) {
        if(completion) {
            completion([NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeNotAMemberOfTheConversation andUserInfo:nil]);
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

#pragma mark messages
- (void)sendText:(nonnull NSString *)text completion:(void (^_Nullable)(NSError * _Nullable error))completion {
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

- (void)sendAttachmentOfType:(NXMAttachmentType)attachmentType WithName:(nonnull NSString *)name data:(nonnull NSData *)data  completion:(void (^_Nullable)(NSError * _Nullable error))completion {
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

#pragma mark events

- (nonnull NXMConversationEventsController *)eventsControllerWithTypes:(nonnull NSSet<NSNumber *> *)eventTypes andDelegate:(id   <NXMConversationEventsControllerDelegate>_Nullable)delegate{
    return [self createEventsControllerWithTypes:eventTypes andDelegate:delegate];
}

#pragma mark - Private Methods
- (nonnull NXMConversationEventsController *)createEventsControllerWithTypes:(nonnull NSSet<NSNumber *> *)eventTypes andDelegate:(id   <NXMConversationEventsControllerDelegate>_Nullable)delegate{
    return [[NXMConversationEventsController alloc] initWithSubscribedEventsType:eventTypes andConversationDetails:self.conversationDetails andStitchContext:self.stitchContext delegate:delegate];
}

#pragma mark EventQueueDelegate
- (void)handleEvent:(NXMEvent*_Nonnull)event {
    [self.conversationMembersController handleEvent:event];
}


- (void)finishHandleEventsSequence {
    [self.conversationMembersController finishHandleEventsSequence];
}
@end
