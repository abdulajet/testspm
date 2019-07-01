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
#import <ClientInfrastructures/ClientInfrastructures.h>

@interface NXMCall() <NXMCallProxy,NXMConversationDelegate>

@property (readwrite, nonatomic) NXMConversation *conversation;
@property (readwrite, nonatomic) NSMutableArray<NXMCallMember *> *otherCallMembers;
@property (readwrite, nonatomic) NXMCallMember *myCallMember;

@property (readwrite, nonatomic, weak) id<NXMCallDelegate> delegate;
@property (readwrite, nonatomic) NXMConversationEventsQueue *eventsQueue;

@property NSInteger lastEventId;
@property NSObject *membersSyncToken;
@end

@implementation NXMCall

- (nullable instancetype)initWithConversation:(nonnull NXMConversation *)conversation {
    [NXMLog info:@"NXMCall::initWithConversation start"];
    [NXMLog info:[[NSString alloc] initWithFormat:@"NXMCall::initWithConversation::conversationId @%", conversation.conversationId]];
    if (self = [super init]) {
        self.membersSyncToken = [NSObject new];
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

- (void)reject:(NXMErrorCallback)completionHandler {
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
    
    if ([self isCallDone]) {
        [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                           completion:completionHandler]; // TODO: error;

        return;
    }
    
    [self.conversation inviteMemberWithUserId:userId withMedia:YES completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
        if (member) {
            NXMCallMember *diallingCallMember = [[NXMCallMember alloc] initWithMember:member andCallProxy:self];
            [self findOrAddCallMember:diallingCallMember];
            return;
        }
        
        [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                           completion:completionHandler]; // TODO: error;
    }];

}

- (void)addCallMemberWithNumber:(NSString *)number completionHandler:(NXMErrorCallback _Nullable)completionHandler {
    if ([self isCallDone]) {
        
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

- (void)sendDTMF:(NSString *)dtmf {
    if ([self isCallDone]) {
        return;
    }
    
    NSLog(@"DTMF");
    [self.conversation sendDTMF:dtmf];
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
    if ([self isCallDone]) { return; }
    
    if (![callMember.memberId isEqualToString:self.myCallMember.memberId]) {
        return;
    }
    
    [self.conversation mute:isMuted];
}

- (void)earmuff:(NXMCallMember *)callMember isEarmuff:(BOOL)isEarmuff {
    
}

- (void)hangup {
    if ([self isCallDone]) { return; }

    [self.myCallMember hangup];
}

#pragma mark - callProxy

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


- (void)mediaEvent:(NXMEvent *)mediaEvent {
    [self handleMediaEvent:mediaEvent];
}

- (void)memberEvent:(NXMMemberEvent *)memberEvent{
    [self handleMemberEvent:memberEvent];
}

- (void)conversationExpired {
    if ([self isCallDone]) {
        return;
    }
    
    [self.myCallMember callEnded];
}

#pragma mark - Private Methods

- (BOOL)isCallDone {
    if (self.myCallMember.status == NXMCallMemberStatusCompleted ||
        self.myCallMember.status == NXMCallMemberStatusCancelled) {
        return YES;
    }
    
    return NO;
}

- (void)dialWithMember:(NXMMember *)member {
    @synchronized (self.membersSyncToken) {
        if (!self.myCallMember) {
            self.myCallMember = [[NXMCallMember alloc] initWithMember:member andCallProxy:self];
        }
    }
    
    [self.conversation enableMedia:self.myCallMember.memberId];
}

- (void)handleMemberEvent:(NXMMemberEvent *)memberEvent {
    NXMCallMember *callMember = [self findOrAddCallMember:[[NXMCallMember alloc] initWithMemberEvent:memberEvent andCallProxy:self]];
    [callMember updateWithMemberEvent:memberEvent];
}

- (void)handleMediaEvent:(NXMEvent *)mediaEvent {
    NXMCallMember *callMember = [self findCallMember:mediaEvent.fromMemberId];
    
    if (mediaEvent.type == NXMEventDTMF) {
        if ([self.delegate respondsToSelector:@selector(DTMFReceived:callMember:)]) {
            [self.delegate DTMFReceived:((NXMDTMFEvent *)mediaEvent).digit callMember:callMember];
        }
    }
    
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

- (NXMCallMember *)findOrAddCallMember:(NXMCallMember *)callMember {
    NXMCallMember *foundCallMember = nil;
    
    @synchronized (self.membersSyncToken) {
        foundCallMember = [self findCallMember:callMember.memberId];
        if(!foundCallMember) {
            if([callMember.user.userId isEqualToString:self.conversation.currentUser.userId]) {
                self.myCallMember = callMember;
            } else {
                [self.otherCallMembers addObject:callMember];
            }
            
            foundCallMember = callMember;
        }
    }
    
    return foundCallMember;
}

- (BOOL)isEventTypeSupported:(NXMEvent *)event {
    return !(event.type == NXMEventTypeMember ||
             event.type == NXMEventTypeMedia);
}


@end
