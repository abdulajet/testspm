//
//  NXMCall.m
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMCall.h"
#import "NXMCallProxy.h"
#import "NXMErrorsPrivate.h"
#import "NXMStitchContext.h"
#import "NXMConversationEventsQueue.h"
#import "NXMCallMemberPrivate.h"
#import "NXMConversation.h"
#import "NXMConversationPrivate.h"
#import "NXMBlocksHelper.h"


@interface NXMCall() <NXMCallProxy,NXMConversationDelegate>

@property (readwrite, nonatomic) NXMConversation *conversation;
@property (readwrite, nonatomic) NSMutableArray<NXMCallMember *> *otherCallMembers;
@property (readwrite, nonatomic) NXMCallMember *myCallMember;

@property (readwrite, nonatomic) id<NXMCallDelegate> delegate;
@property (readwrite, nonatomic) NXMConversationEventsQueue *eventsQueue;

@property NSInteger lastEventId;
@end

@implementation NXMCall

- (nullable instancetype)initWithConversation:(nonnull NXMConversation *)conversation {
    if (self = [super init]) {
        self.lastEventId = conversation.lastEventId;
        self.conversation = conversation;
        if (self.conversation.myMember){
            self.myCallMember = [[NXMCallMember alloc] initWithMember:self.conversation.myMember andCallProxy:self];
        }
        self.otherCallMembers = [[NSMutableArray<NXMCallMember *>  alloc] init];
        if (self.conversation.otherMembers){
            for (id member in self.conversation.otherMembers){
                [self.otherCallMembers addObject: [[NXMCallMember alloc] initWithMember:member andCallProxy:self]];
            }
        }
        [conversation setDelegate:self];
    }
    return self;
}

#pragma mark - public

- (void)setDelegate:(id<NXMCallDelegate>)delegate {
    _delegate = delegate;
}

- (void)answer:(id<NXMCallDelegate>)delegate completionHandler:(NXMErrorCallback _Nullable)completionHandler {
    if (self.myCallMember.status != NXMCallMemberStatusCalling) {
        [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                           completion:completionHandler]; // TODO: error;
        return;
    }
    
    [self.conversation joinWithCompletion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
        if (error || !member) {
            [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                           completion:completionHandler]; // TODO: error;
            return;
        }
        self.delegate = delegate;
        [self.conversation enableMedia:self.myCallMember.memberId];
        [NXMBlocksHelper runWithError:nil completion:completionHandler];
    }];
}

- (void)decline:(NXMErrorCallback)completionHandler {
    if (self.myCallMember.status != NXMCallMemberStatusCalling) {
        [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                           completion:completionHandler]; // TODO: error;
        return;
    }

    [self.conversation leaveWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                               completion:completionHandler]; // TODO: error;
            return;
        }
        
        [NXMBlocksHelper runWithError:nil completion:completionHandler];
    }];
}

- (void)addCallMemberWithUserId:(NSString *)userId completionHandler:(NXMErrorCallback _Nullable)completionHandler {
    if (userId == self.conversation.myMember.user.userId){
        
        [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                           completion:completionHandler]; // TODO: error;

        return;
    }
    
    if (self.status == NXMCallStatusDisconnected) {
        [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                           completion:completionHandler]; // TODO: error;

        return;
    }
    [self.conversation inviteMemberWithUserId:userId withMedia:YES completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
        if (member) {
            NXMCallMember *callMember = [[NXMCallMember alloc] initWithMemberId:member.memberId
                                                                              andCallProxy:self];
            [self.otherCallMembers addObject:callMember];
            return;
        }
        
        [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                           completion:completionHandler]; // TODO: error;
    }];

}

- (void)addCallMemberWithNumber:(NSString *)number completionHandler:(NXMErrorCallback _Nullable)completionHandler {
    if (self.status == NXMCallStatusDisconnected) {
        
        [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                           completion:completionHandler]; // TODO: error;

        return;
    }
    
    [self.conversation inviteToConversationWithPhoneNumber:number completion:^(NSError * _Nullable error, NSString * _Nullable knockingId) {
        if (knockingId){
            //TODO: register the knockingId with the call object
            return;
        }
        
        [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                           completion:completionHandler]; // TODO: error;
    }];
}

- (NXMCallStatus)callStatus {
    if (self.myCallMember.status == NXMCallMemberStatusCompleted || self.myCallMember.status == NXMCallMemberStatusCancelled) {
        return NXMCallStatusDisconnected;
    }
    
    for (NXMCallMember *callMember in self.otherCallMembers) {
        if (callMember.status != NXMCallMemberStatusCompleted && callMember.status != NXMCallMemberStatusCancelled) {
            return NXMCallStatusConnected;
        }
    }
    
    return NXMCallStatusDisconnected;
}

#pragma mark - callProxy

- (void)hangup:(NXMCallMember *)callMember {
    if (callMember != self.myCallMember) {
        // TODO: error
        return;
    }
    
    [self.conversation disableMedia];
}

- (void)hold:(NXMCallMember *)callMember isHold:(BOOL)isHold {
    
}

- (void)mute:(NXMCallMember *)callMember isMuted:(BOOL)isMuted {
    if (self.status == NXMCallStatusDisconnected) { return; }
    
    if (![callMember.user.userId isEqualToString:self.myCallMember.user.userId]) {
        return;
    }
    
    [self.conversation mute:isMuted];
}

- (void)earmuff:(NXMCallMember *)callMember isEarmuff:(BOOL)isEarmuff {
    
}

- (void)onChange:(NXMCallMember *)callMember {
    if (callMember == self.myCallMember &&
        callMember.status == NXMCallMemberStatusCompleted) {
        
        [self.conversation leaveWithCompletion:^(NSError * _Nullable error) {
            // TODO:
        }];
    }
    
    [self.delegate statusChanged:callMember];
}

#pragma mark - NXMConversationDelegate


- (void)textEvent:(NXMMessageEvent *)textEvent {
    
}

- (void)attachmentEvent:(NXMMessageEvent *)attachmentEvent {
    
}

- (void)messageStatusEvent:(NXMMessageStatusEvent *)messageStatusEvent {
    
}

- (void)mediaEvent:(NXMEvent *)mediaEvent {
    [self handleMediaEvent:mediaEvent];
}

- (void)typingEvent:(NXMTextTypingEvent *)typingEvent{
    
}

- (void)memberEvent:(NXMMemberEvent *)memberEvent{
    [self handleMemberEvent:memberEvent];
}

#pragma mark - private

- (void)setMyCallMember:(NXMCallMember *)callMember {
    _myCallMember = callMember;
}

- (void)handleMemberEvent:(NXMMemberEvent *)memberEvent {
    NXMCallMember *callMember = [self findCallMember:memberEvent.memberId];
    [callMember updateWithMemberEvent:memberEvent];
}

- (void)handleMediaEvent:(NXMEvent *)mediaEvent {
    NXMCallMember *callMember = [self findCallMember:mediaEvent.fromMemberId];
    [callMember updateWithMediaEvent:mediaEvent];
}

- (NXMCallMember *)findCallMember:(NSString *)memberId {
    if ([memberId isEqualToString:self.myCallMember.memberId]) {
        return self.myCallMember;
    }
    
    for (NXMCallMember *callMember in self.otherCallMembers) {
        if (![callMember.memberId isEqualToString:memberId]) {
            continue;
        }
        
        return callMember;
    }
    
    return nil;
}


- (BOOL)isEventTypeSupported:(NXMEvent *)event {
    return !(event.type == NXMEventTypeMember ||
             event.type == NXMEventTypeMedia);
}


@end
