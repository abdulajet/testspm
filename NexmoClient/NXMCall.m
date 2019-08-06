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
#import "NXMLoggerInternal.h"


@interface NXMCall() <NXMCallProxy,NXMConversationDelegate, NXMConversationUpdatesDelegate>

@property (readwrite, nonatomic) NXMConversation *conversation;
@property (readwrite, nonatomic) NSMutableArray<NXMCallMember *> *otherCallMembers;
@property (readwrite, nonatomic) NXMCallMember *myCallMember;

@property (readwrite, nonatomic, weak) id<NXMCallDelegate> delegate;
@property (readwrite, nonatomic) NXMConversationEventsQueue *eventsQueue;

@property NSInteger lastEventId;
@property NSObject *membersSyncToken;
@property BOOL pendingToAnswer;
@end

@implementation NXMCall

- (nullable instancetype)initWithConversation:(nonnull NXMConversation *)conversation {
    LOG_DEBUG([conversation.conversationId UTF8String]);
    
    if (self = [super init]) {
        self.membersSyncToken = [NSObject new];
        self.lastEventId = conversation.lastEventId;
        self.conversation = conversation;
        self.pendingToAnswer = NO;
        self.otherCallMembers = [[NSMutableArray<NXMCallMember *>  alloc] init];
        
        if (self.conversation.allMembers){
            for (NXMMember *member in self.conversation.allMembers) {
                [self findOrAddCallMember:member];
            }
        }
        
        [conversation setDelegate:self];
        conversation.updatesDelegate = self;
    }
    return self;
}

#pragma mark - public

- (void)setDelegate:(id<NXMCallDelegate>)delegate {
    _delegate = delegate;
}

- (void)answer:(id<NXMCallDelegate>)delegate completionHandler:(NXMErrorCallback _Nullable)completionHandler {
    LOG_DEBUG("");
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
        [NXMBlocksHelper runWithError:nil completion:completionHandler];
    }];
}

- (void)rejectWithCompletionHandler:(NXMErrorCallback _Nullable)completionHandler {
    LOG_DEBUG("");
    
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

- (void)addCallMemberWithUsername:(NSString *)username completionHandler:(NXMErrorCallback _Nullable)completionHandler {
    if (username == self.conversation.myMember.user.name){
        
        [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                           completion:completionHandler]; // TODO: error;

        return;
    }
    
    if ([self isCallDone]) {
        [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                           completion:completionHandler]; // TODO: error;

        return;
    }
    
    [self.conversation inviteMemberWithUsername:username withMedia:YES completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
        if (member) {
            [NXMBlocksHelper runWithError:nil completion:completionHandler];
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
    LOG_DEBUG([dtmf UTF8String]);

    if ([self isCallDone]) {
        return;
    }
    
    [self.conversation sendDTMF:dtmf];
}

#pragma mark - callProxy

- (void)hangup:(NXMCallMember *)callMember {
    LOG_DEBUG([callMember.description UTF8String]);
    if (callMember != self.myCallMember) {
        // TODO: error
        return;
    }
    
    [self.conversation disableMedia];
}

- (void)hold:(NXMCallMember *)callMember isHold:(BOOL)isHold {
    
}

- (void)mute:(NXMCallMember *)callMember isMuted:(BOOL)isMuted {
    LOG_DEBUG("%s %i", [callMember.description UTF8String], isMuted);
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

- (void)memberUpdated:(NXMMember *)member forUpdateType:(NXMMemberUpdateType)type {
    LOG_DEBUG([member.description UTF8String]);
    NXMCallMember *callMember = [self findOrAddCallMember:member];
    
    if (type == NXMMemberUpdateTypeState &&
        member.state == NXMMemberStateJoined &&
        [callMember isEqual:self.myCallMember]) {
        [self.conversation enableMedia:callMember.memberId];
    }

    [callMember memberUpdated];
}


- (void)conversationExpired {
    [self.myCallMember hangup];
}


#pragma mark - Private Methods

- (BOOL)isCallDone {
    return self.myCallMember.status == NXMCallMemberStatusCompleted;
}

- (NXMCallMember *)findCallMember:(NSString *)memberId {
    if ([memberId isEqualToString:self.myCallMember.memberId]) {
        return self.myCallMember;
    }
    
    for (NXMCallMember *callMember in self.otherCallMembers) {
        if ([callMember.memberId isEqualToString:memberId]) {
            return callMember;
        }
    }
    
    return nil;
}

- (NXMCallMember *)findOrAddCallMember:(NXMMember *)member {
    NXMCallMember *callMember = nil;

    @synchronized (self.membersSyncToken) {
        callMember = [self findCallMember:member.memberId];
        if(!callMember) {

            callMember = [[NXMCallMember alloc] initWithMember:member andCallProxy:self];
            if([callMember.user.userId isEqualToString:self.conversation.currentUser.userId]) {
                self.myCallMember = callMember;
            } else {
                [self.otherCallMembers addObject:callMember];
            }
        }
    }

    return callMember;
}

- (BOOL)isEventTypeSupported:(NXMEvent *)event {
    return !(event.type == NXMEventTypeMember ||
             event.type == NXMEventTypeMedia);
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> otherCallMembers=%@ myCallMember=%@",
            NSStringFromClass([self class]),
            self,
            self.otherCallMembers,
            self.myCallMember];
}

@end
