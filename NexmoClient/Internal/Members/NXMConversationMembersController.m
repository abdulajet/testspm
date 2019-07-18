//
//  NXMMembersController.m
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationMembersController.h"

#import "NXMConversation.h"
#import "NXMStitchContext.h"
#import "NXMCoreEvents.h"
#import "NXMMemberPrivate.h"
#import "NXMLogger.h"
#import "NXMMediaSettingsInternal.h"

@interface NXMConversationMembersController ()
@property (nonatomic, readwrite, nullable) NXMMember *myMember;
@property (nonatomic, readwrite, nullable) NSMutableDictionary<NSString *, NXMMember *> *membersDictionary;
@property (nonatomic, readwrite, nullable, weak) id <NXMConversationMembersControllerDelegate> delegate;
@property (nonatomic, readwrite, nonnull) NXMConversationDetails *conversationDetails;
@property (nonatomic, readwrite, nullable) NXMUser *currentUser;
@end

@implementation NXMConversationMembersController

#pragma mark - init

- (instancetype)initWithConversationDetails:(nonnull NXMConversationDetails *)conversationDetails
                             andCurrentUser:(nonnull NXMUser *)currentUser
                                   delegate:(id <NXMConversationMembersControllerDelegate> _Nullable)deleagte
{
    self = [super init];
    if (self) {
        self.conversationDetails = conversationDetails;
        self.currentUser = currentUser;
        self.membersDictionary = [NSMutableDictionary new];
        self.delegate = deleagte;
        [self initMembersWithConversationDetails:conversationDetails];
    }
    return self;
}

- (void)initMembersWithConversationDetails:(NXMConversationDetails * _Nonnull)conversationDetails {
    [NXMLogger debugWithFormat:@"NXMConversationMembersController conversationDetails %@ %d",
     conversationDetails.conversationId,
     conversationDetails.members.count];

    for (NXMMember *member in conversationDetails.members) {
        if([member.user.userId isEqualToString:self.currentUser.userId]) {
            self.myMember = member;
        }
        
        self.membersDictionary[member.memberId] = member;
    }
}

#pragma mark - unsynthesized properties
-(NSArray<NXMMember *> *)allMembers {
    return self.membersDictionary.allValues;
}

#pragma mark - public
-(NXMMember *)memberForMemberId:(NSString *)memberId {
    return self.membersDictionary[memberId];
}


#pragma mark - Private Updating Methods
- (void)conversationExpired {
    [NXMLogger debugWithFormat:@"NXMConversationMembersController conversationExpired"];

    for (NXMMember *member in self.membersDictionary.allValues) {
        [member updateExpired];
        
        [self member:member changedWithType:NXMMemberUpdateTypeLeg];
    }
}

- (void)handleEvent:(NXMEvent *)event {
    if(self.conversationDetails.sequence_number >= event.sequenceId) {
        [NXMLogger debugWithFormat:@"NXMConversationMembersController sequenceId is lower %d %d memberId %d %@",
         self.conversationDetails.sequence_number,
         event.sequenceId,
         event.fromMemberId,
         event];

        return;
    }
    
    [NXMLogger debugWithFormat:@"NXMConversationMembersController handleEvent %@",event];
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleEvent:event];
        });
        return;
    }
   
    switch (event.type) {
        case NXMEventTypeMedia:
        case NXMEventTypeMediaAction:
            [self handleMediaEvent:(NXMMediaEvent *)event];
            break;
        case NXMEventTypeMember:
            [self handleMemberEvent:(NXMMemberEvent *)event];

            break;
        case NXMEventTypeLegStatus:
            [self handleLegEvent:(NXMLegStatusEvent *)event];
            break;
            
        default:
            break;
    }

    
}

-(void)handleLegEvent:(NXMLegStatusEvent *)legEvent {
    [NXMLogger debugWithFormat:@"NXMConversationMembersController legEvent %@ %@ %ld", legEvent.current.memberId, legEvent.current.legId, (long)legEvent.current.legStatus];
    
    NXMMember *member = self.membersDictionary[legEvent.current.memberId];
    if (!member) {
        [NXMLogger errorWithFormat:@"NXMConversationMembersController legEvent member not found %@ %@ %ld", legEvent.current.memberId, legEvent.current.legId, (long)legEvent.current.legStatus];
        return;
    }
    
    [member updateChannelWithLeg:(NXMLeg *)legEvent.current];
    
    [self member:member changedWithType:NXMMemberUpdateTypeLeg];
}

-(void)handleMediaEvent:(NXMEvent *)event {
    [NXMLogger debugWithFormat:@"NXMConversationMembersController mediaEvent %@", event.fromMemberId];
    NXMMember *member = self.membersDictionary[event.fromMemberId];
    if (!member) {
        [NXMLogger errorWithFormat:@"NXMConversationMembersController mediaEvent member not found %@ %@ %ld", event.fromMemberId];
        return;
    }
    
    if (event.type == NXMEventTypeMedia) {
        [member updateMedia:((NXMMediaEvent *)event).mediaSettings];
    } else if (event.type == NXMEventTypeMediaAction) {
        NXMMediaSettings *settings = [[NXMMediaSettings alloc] initWithEnabled:member.media.isEnabled
                                                                       suspend:((NXMMediaSuspendEvent *)event).isSuspended];
        [member updateMedia:settings];
    }
    
    [self member:member changedWithType:NXMMemberUpdateTypeMedia];
}

- (void)handleMemberEvent:(NXMMemberEvent *)memberEvent {
    [NXMLogger debugWithFormat:@"NXMConversationMembersController memberEvent %@ %ld", memberEvent.memberId, (long)memberEvent.state];
    
    NXMMember *member = self.membersDictionary[memberEvent.memberId];
    if(member) {
        [member updateState:memberEvent.state time:memberEvent.creationDate initiator:memberEvent.fromMemberId];
        
        [self member:member changedWithType:NXMMemberUpdateTypeState];
        return;
    }
    
    [NXMLogger debugWithFormat:@"NXMConversationMembersController member added %@ %ld", memberEvent.memberId, (long)memberEvent.state];
    
    member = [[NXMMember alloc] initWithMemberEvent:memberEvent];
    [self addMember:member];
    [self member:member changedWithType:NXMMemberUpdateTypeState];
}

- (void)addMember:(nonnull NXMMember *)member {
    self.membersDictionary[member.memberId] = member;
    if([member.user.userId isEqualToString:self.currentUser.userId]) {
        self.myMember = member;
    }
}

#pragma mark - delegate

-(void)member:(nonnull NXMMember *)member changedWithType:(NXMMemberUpdateType)type {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self member:member changedWithType:type];
        });
        return;
    }
    if([self.delegate respondsToSelector:@selector(nxmConversationMembersController:didChangeMember:forChangeType:)]) {
        [self.delegate nxmConversationMembersController:self didChangeMember:member forChangeType:type];
    }
}

@end
