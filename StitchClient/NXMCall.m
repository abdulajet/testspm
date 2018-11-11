//
//  NXMCall.m
//  StitcClient
//
//  Created by Chen Lev on 8/27/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMCall.h"
#import "NXMCallProxy.h"
#import "NXMErrors.h"
#import "NXMStitchContext.h"
#import "NXMConversationEventsQueue.h"
#import "NXMCallParticipantPrivate.h"


@interface NXMCall() <NXMCallProxy,NXMConversationEventsQueueDelegate>

@property (readwrite, nonatomic) NSString *conversationId;
@property (readwrite, nonatomic) NSMutableArray<NXMCallParticipant *> *otherParticipants;
@property (readwrite, nonatomic) NXMCallParticipant *myParticipant;

@property (readwrite, nonatomic) NXMStitchContext *stitchContext;
@property (readwrite, nonatomic) id<NXMCallDelegate> delegate;
@property (readwrite, nonatomic) NXMConversationEventsQueue *eventsQueue;

@property NSInteger lastEventId;
@end

@implementation NXMCall

- (nullable instancetype)initWithStitchContext:(nonnull NXMStitchContext *)stitchContext
                           conversationDetails:(nonnull NXMConversationDetails *)conversationDetails {
    if (self = [super init]) {
        self.lastEventId = 0;
        self.stitchContext = stitchContext;
        self.conversationId = conversationDetails.uuid;
        self.eventsQueue = [[NXMConversationEventsQueue alloc] initWithConversationDetails:conversationDetails stitchContext:stitchContext delegate:self];
    }
    
    return self;
}

#pragma mark - public

- (void)setDelegate:(id<NXMCallDelegate>)delegate {
    self.delegate = delegate;
}

- (void)addParticipantWithUserId:(NSString *)userId completionHandler:(ErrorCallback _Nullable)completionHandler {
    if (self.status == NXMCallStatusDisconnected) {
        completionHandler(nil); // TODO: error;
        return;
    }
    
    [self.stitchContext.coreClient inviteToConversation:self.conversationId withUserId:userId onSuccess:^(NSObject * _Nullable object) {
        NXMCallParticipant *participant = [[NXMCallParticipant alloc] initWithMemberId:((NXMMember *)object).memberId
                                                                    andCallProxy:self];
        if (userId == self.stitchContext.currentUser.uuid) {
            self.myParticipant = participant;
        } else {
            [self.otherParticipants addObject:participant];
        }
        
        completionHandler(nil);
    } onError:^(NSError * _Nullable error) {
        completionHandler(error);
    }];
}

- (void)addParticipantWithNumber:(NSString *)number completionHandler:(ErrorCallback _Nullable)completionHandler {
    if (self.status == NXMCallStatusDisconnected) {
        completionHandler(nil); // TODO: error;
        return;
    }
    
    [self.stitchContext.coreClient inviteToConversation:self.stitchContext.currentUser.name withPhoneNumber:number onSuccess:^(NSString * _Nullable value) {
        NXMCallParticipant *participant = [[NXMCallParticipant alloc] initWithMemberId:value
                                                                          andCallProxy:self];
        [self.otherParticipants addObject:participant];
    } onError:^(NSError * _Nullable error) {
        completionHandler(error);
    }];
}

- (void)turnOff {
    if (self.status == NXMCallStatusDisconnected) {
        return;
    }
    
    [self.stitchContext.coreClient disableMedia:self.conversationId];
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



#pragma mark - NXMConversationEventsQueueDelegate

- (void)handleEvent:(NXMEvent *)event {
    if ([self isEventTypeSupported:event]) {
        return;
    }
    
    if (event.type == NXMEventTypeMember) {
       [self handleMemberEvent:(NXMMemberEvent *)event];
        return;
    }
    
    if (event.type == NXMEventTypeMedia) {
        [self handleMediaEvent:(NXMMediaEvent *)event];
        return;
    }
}

#pragma mark - callProxy

- (void)hold:(NXMCallParticipant *)participant isHold:(BOOL)isHold {
    
}

- (void)mute:(NXMCallParticipant *)participant isMuted:(BOOL)isMuted {
    if (self.status == NXMCallStatusDisconnected) { return; }
    
    [self.stitchContext.coreClient suspendMyMedia:NXMMediaTypeAudio inConversation:self.conversationId];
}

- (void)earmuff:(NXMCallParticipant *)participant isEarmuff:(BOOL)isEarmuff {
    
}

- (void)onChange {
    [self.delegate statusChanged];
}

#pragma mark - private

- (void)handleMemberEvent:(NXMMemberEvent *)member {
    NXMCallParticipant *participant = [self findParticipant:member];
    [participant updateWithMemberEvent:member];
}

- (void)handleMediaEvent:(NXMMediaEvent *)media {
    NXMCallParticipant *participant = [self findParticipant:media];
    [participant updateWithMedia:media];
}

- (NXMCallParticipant *)findParticipant:(NXMEvent *)event {
    if (event.fromMemberId == self.myParticipant.participantId) {
        return self.myParticipant;
    }
    
    for (NXMCallParticipant *participant in self.otherParticipants) {
        if (participant.participantId != event.fromMemberId) {
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
