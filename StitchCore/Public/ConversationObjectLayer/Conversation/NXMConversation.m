//
//  NXMConversation.m
//  StitchObjC
//
//  Created by Doron Biaz on 9/20/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversation.h"

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
        
        for (NXMMember *member in conversationDetails.members) {
            if(member.userId == stitchContext.currentUser.uuid) {
                self.myMember = member;
            } else {
                //TODO: create a cloud collection where add remove are overriden to send http add remove?
            }
        }
        
        [self signToEventDispatcherEvents];
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
            case NXMEventGeneral:
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



-(void)addMemberWithUserId:(nonnull NSString *)userId completion:(void (^_Nullable)(NSError * _Nullable error))completion {
    [self.stitchContext.coreClient joinToConversation:self.conversationId
                                           withUserId:userId
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
@end
