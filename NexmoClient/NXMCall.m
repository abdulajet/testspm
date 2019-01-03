//
//  NXMCall.m
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMCall.h"
#import "NXMCallProxy.h"
#import "NXMErrors.h"
#import "NXMStitchContext.h"
#import "NXMConversationEventsQueue.h"
#import "NXMCallParticipantPrivate.h"
#import "NXMConversation.h"
#import "NXMConversationPrivate.h"
#import "NXMBlocksHelper.h"


@interface NXMCall() <NXMCallProxy,NXMConversationDelegate>

@property (readwrite, nonatomic) NXMConversation *conversation;
@property (readwrite, nonatomic) NSMutableArray<NXMCallParticipant *> *otherParticipants;
@property (readwrite, nonatomic) NXMCallParticipant *myParticipant;

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
            self.myParticipant = [[NXMCallParticipant alloc] initWithMember:self.conversation.myMember andCallProxy:self];
        }
        self.otherParticipants = [[NSMutableArray<NXMCallParticipant*>  alloc] init];
        if (self.conversation.otherMembers){
            for (id member in self.conversation.otherMembers){
                [self.otherParticipants addObject: [[NXMCallParticipant alloc] initWithMember:member andCallProxy:self]];
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
    if (self.myParticipant.status != NXMParticipantStatusCalling) {
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
        [self.conversation enableMedia:self.myParticipant.participantId];
        [NXMBlocksHelper runWithError:nil completion:completionHandler];
    }];
}

- (void)decline:(NXMErrorCallback)completionHandler {
    if (self.myParticipant.status != NXMParticipantStatusCalling) {
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

- (void)addParticipantWithUserId:(NSString *)userId completionHandler:(NXMErrorCallback _Nullable)completionHandler {
    if (userId == self.conversation.myMember.userId){
        
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
            NXMCallParticipant *participant = [[NXMCallParticipant alloc] initWithMemberId:member.memberId
                                                                              andCallProxy:self];
            [self.otherParticipants addObject:participant];
            return;
        }
        
        [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                           completion:completionHandler]; // TODO: error;
    }];

}

- (void)addParticipantWithNumber:(NSString *)number completionHandler:(NXMErrorCallback _Nullable)completionHandler {
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
    if (self.myParticipant.status == NXMParticipantStatusCompleted || self.myParticipant.status == NXMParticipantStatusCancelled) {
        return NXMCallStatusDisconnected;
    }
    
    for (NXMCallParticipant *participant in self.otherParticipants) {
        if (participant.status != NXMParticipantStatusCompleted && participant.status != NXMParticipantStatusCancelled) {
            return NXMCallStatusConnected;
        }
    }
    
    return NXMCallStatusDisconnected;
}

#pragma mark - callProxy

- (void)hangup:(NXMCallParticipant *)participant {
    if (participant != self.myParticipant) {
        // TODO: error
        return;
    }
    
    [self.conversation disableMedia];
}

- (void)hold:(NXMCallParticipant *)participant isHold:(BOOL)isHold {
    
}

- (void)mute:(NXMCallParticipant *)participant isMuted:(BOOL)isMuted {
    if (self.status == NXMCallStatusDisconnected) { return; }
    
    if (![participant.userId isEqualToString:self.myParticipant.userId]) {
        return;
    }
    
    [self.conversation mute:isMuted];
}

- (void)earmuff:(NXMCallParticipant *)participant isEarmuff:(BOOL)isEarmuff {
    
}

- (void)onChange:(NXMCallParticipant *)participant {
    if (participant == self.myParticipant &&
        participant.status == NXMParticipantStatusCompleted) {
        
        [self.conversation leaveWithCompletion:^(NSError * _Nullable error) {
            // TODO:
        }];
    }
    
    [self.delegate statusChanged:participant];
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

- (void)setMyParticipant:(NXMCallParticipant *)participant {
    _myParticipant = participant;
}

- (void)handleMemberEvent:(NXMMemberEvent *)member {
    NXMCallParticipant *participant = [self findParticipant:member.memberId];
    [participant updateWithMemberEvent:member];
}

- (void)handleMediaEvent:(NXMEvent *)media {
    NXMCallParticipant *participant = [self findParticipant:media.fromMemberId];
    [participant updateWithMedia:media];
}

- (NXMCallParticipant *)findParticipant:(NSString *)memberId {
    if ([memberId isEqual:self.myParticipant.participantId]) {
        return self.myParticipant;
    }
    
    for (NXMCallParticipant *participant in self.otherParticipants) {
        if (![participant.participantId isEqual:memberId]) {
            continue;
        }
        
        return participant;
    }
    
    return nil;
}


- (BOOL)isEventTypeSupported:(NXMEvent *)event {
    return !(event.type == NXMEventTypeMember ||
             event.type == NXMEventTypeMedia);
}


@end
