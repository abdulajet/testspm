//
//  NXMConversation.m
//  StitchObjC
//
//  Created by Doron Biaz on 9/20/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversation.h"
#import "NXMConversationEventsControllerPrivate.h"
#import "NXMConversationMembersControllerPrivate.h"
#import "NXMErrors.h"

@interface NXMConversation ()
@property (readwrite, nonatomic) NSObject<NXMConversationDelegate> *delegate;
@property (readwrite, nonatomic) NXMStitchContext *stitchContext;

@property (readwrite, nonatomic, nullable) NXMMember *myMember;
@property (readwrite, nonatomic, nonnull) NXMConversationDetails *conversationDetails;

-(instancetype)initWithConversationDetails:(nonnull NXMConversationDetails *)conversationDetails andStitchContext:(nonnull NXMStitchContext *)stitchContext;
@end

@implementation NXMConversation
- (instancetype)initWithConversationDetails:(NXMConversationDetails *)conversationDetails andStitchContext:(NXMStitchContext *)stitchContext
{
    self = [super init];
    if (self) {
        self.stitchContext = stitchContext;
        self.conversationDetails = conversationDetails;        
        [self signToEventDispatcherEvents];
        for (NXMMember *member in self.conversationDetails.members) {
            if(member.state == NXMMemberStateJoined && [member.userId isEqualToString:self.stitchContext.currentUser.uuid]) {
                self.myMember = member;
            }
        }
    }
    return self;
}

#pragma mark - unsynthesized properties
-(NSString *)name {
    return self.conversationDetails.name;
}
-(NSString *)displayName {
    return self.conversationDetails.displayName;
}
-(NSString *)conversationId {
    return self.conversationDetails.uuid;
}
-(NSInteger)lastEventId {
    return self.conversationDetails.sequence_number;
}
-(NSDate *)creationDate {
    return self.conversationDetails.created;
}

#pragma mark - delegate methods
-(void)signToEventDispatcherEvents {
    [self.stitchContext.eventsDispatcher.notificationCenter addObserver:self selector:@selector(didReceiveEventNotification:) name:kNXMEventsDispatcherNotificationMedia object:nil];
    [self.stitchContext.eventsDispatcher.notificationCenter addObserver:self selector:@selector(didReceiveEventNotification:) name:kNXMEventsDispatcherNotificationMember object:nil];
    [self.stitchContext.eventsDispatcher.notificationCenter addObserver:self selector:@selector(didReceiveEventNotification:) name:kNXMEventsDispatcherNotificationMessage object:nil];
    [self.stitchContext.eventsDispatcher.notificationCenter addObserver:self selector:@selector(didReceiveEventNotification:) name:kNXMEventsDispatcherNotificationMessageStatus object:nil];
    [self.stitchContext.eventsDispatcher.notificationCenter addObserver:self selector:@selector(didReceiveEventNotification:) name:kNXMEventsDispatcherNotificationTyping object:nil];
}

-(void)didReceiveEventNotification:(NSNotification *)notification {
    NXMEvent *event = [NXMEventsDispatcherNotificationHelper<NXMEvent *> nxmNotificationModelWithNotification:notification];
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

-(void)setDelegate:(nonnull NSObject<NXMConversationDelegate> *)delegate {
    self.delegate = delegate;
}

#pragma mark - public methods
-(void)joinWithCompletion:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completion {
    [self addMemberWithUserId:self.stitchContext.currentUser.uuid completion:completion];
}

-(void)addMemberWithUserId:(nonnull NSString *)userId completion:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completion {
    __weak NXMConversation *weakSelf = self;
    [self.stitchContext.coreClient joinToConversation:self.conversationId
                                           withUserId:userId
                                            onSuccess:^(NSObject * _Nullable object) {
                                                NXMMember *newMember = (NXMMember *)object;
                                                if([weakSelf.stitchContext.currentUser.uuid isEqualToString:newMember.userId]) {
                                                    weakSelf.myMember = newMember;
                                                }
                                                
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

-(void)removeMemberWithMemberId:(nonnull NSString *)memberId completion:(void (^_Nullable)(NSError * _Nullable error))completion {
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

-(nonnull NXMConversationEventsController *)eventsControllerWithTypes:(nonnull NSSet<NSNumber *> *)eventTypes andDelegate:(id   <NXMConversationEventsControllerDelegate>_Nullable)delegate{
    return [[NXMConversationEventsController alloc] initWithSubscribedEventsType:eventTypes andConversationDetails:self.conversationDetails andStitchContext:self.stitchContext delegate:delegate];
}

-(nonnull NXMConversationMembersController *)membersControllerWithDelegate:(id <NXMConversationMembersControllerDelegate> _Nullable)delegate {
    return [[NXMConversationMembersController alloc] initWithConversationDetails:self.conversationDetails andStitchContext:self.stitchContext delegate:delegate];
}
@end
