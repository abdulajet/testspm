//
//  NXMMembersController.m
//  StitchObjC
//
//  Created by Doron Biaz on 10/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationMembersController.h"
#import "NXMConversationEventsQueue.h"

#import "NXMUser.h"
#import "NXMMember.h"
#import "NXMConversation.h"
#import "NXMStitchContext.h"

@interface NXMConversationMembersController () <NXMConversationEventsQueueDelegate>
@property (nonatomic, readwrite, nullable) NXMMember *myMember;
@property (nonatomic, readwrite, nullable) NSMutableSet<NXMMember *> *mutableOtherMembers;
@property (nonatomic, readwrite, nullable) NSMutableDictionary<NSString *, NXMMember *> *membersDictionary;
@property (nonatomic, readwrite, nullable, weak) id <NXMConversationMembersControllerDelegate> delegate;
@property (nonatomic, readwrite, nonnull) NXMConversationDetails *conversationDetails;
@property (nonatomic, readwrite, nullable) NXMUser *currentUser;
@property (nonatomic, readwrite) BOOL contentChanging;
@property (nonatomic, readwrite, nonnull) NXMConversationEventsQueue *eventsQueue;
@end

@implementation NXMConversationMembersController

#pragma mark - init
-(instancetype)initWithConversationDetails:(nonnull NXMConversationDetails *)conversationDetails  andStitchContext:(nonnull NXMStitchContext *)stitchContext {
    return [self initWithConversationDetails:conversationDetails andStitchContext:stitchContext delegate:nil];
}

-(instancetype)initWithConversationDetails:(nonnull NXMConversationDetails *)conversationDetails  andStitchContext:(nonnull NXMStitchContext *)stitchContext delegate:(id <NXMConversationMembersControllerDelegate> _Nullable)deleagte
{
    self = [super init];
    if (self) {
        self.conversationDetails = conversationDetails;
        self.currentUser = stitchContext.currentUser;
        self.mutableOtherMembers = [NSMutableSet<NXMMember *> new];
        self.membersDictionary = [NSMutableDictionary new];
        [self initMembersWithConversationDetails:conversationDetails];
        self.eventsQueue = [[NXMConversationEventsQueue alloc] initWithConversationDetails:conversationDetails stitchContext:stitchContext delegate:self];
    }
    return self;
}

- (void)initMembersWithConversationDetails:(NXMConversationDetails * _Nonnull)conversationDetails {
    for (NXMMember *member in conversationDetails.members) {
        if(self.currentUser && [member.userId isEqualToString:self.currentUser.uuid]) {
            self.myMember = member;
        } else {
            [self.mutableOtherMembers addObject:member];
        }
        
        self.membersDictionary[[member.memberId copy]] = member;
    }
}

#pragma mark - unsynthesized properties
-(NSSet<NXMMember *> *)otherMembers {
    return self.mutableOtherMembers;
}

#pragma mark - public
-(nullable NXMMember *)memberForMemberId:(nonnull NSString *)memberId {
    return self.membersDictionary[memberId];
}


#pragma mark - EventsQueueDelegate
- (void)handleEvent:(NXMEvent*_Nonnull)event {
    if(event.type != NXMEventTypeMember) {
        return;
    }
    
    if(self.conversationDetails.sequence_number >= event.sequenceId) {
        return;
    }
    
    [self handleMemberEvent:(NXMMemberEvent *)event];
}

- (void)finishHandleEventsSequence {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishHandleEventsSequence];
        });
        return;
    }
    self.contentChanging = NO;
    [self contentDidChange];
}

-(void)handleMemberEvent:(NXMMemberEvent *)memberEvent {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleMemberEvent:memberEvent];
        });
        return;
    }
    if(!self.contentChanging) {
        self.contentChanging = YES;
        [self contentWillChange];
    }
    NXMMember *member = [[NXMMember alloc] initWithMemberEvent:memberEvent];
    switch (member.state) {
        case NXMMemberStateJoined:
            [self addMember:member];
            break;
        case NXMMemberStateLeft:
            [self removeMember:member];
            break;
        case NXMMemberStateInvited:
        default:
            break;
    }
}

-(void)addMember:(NXMMember *)member {
    if(!self.membersDictionary[member.memberId]) {
        self.membersDictionary[member.memberId] = member;
        if([member.userId isEqualToString:self.currentUser.uuid]) {
            self.myMember = member;
        } else {
            [self.mutableOtherMembers addObject:member];
        }
        [self member:member changedWithType:NXMMembersControllerChangeTypeAdded];
    }
}

-(void)removeMember:(NXMMember *)member {
    [self removeMemberWithMemberId:member.memberId];
}

-(void)removeMemberWithMemberId:(NSString *)memberId {
    if(self.membersDictionary[memberId]) {
        NXMMember *memberToRemove = self.membersDictionary[memberId];
        [self.membersDictionary removeObjectForKey:memberId];
        if([memberToRemove.userId isEqualToString:self.currentUser.uuid]) {
            self.myMember = nil;
        } else {
            [self.mutableOtherMembers removeObject:memberToRemove];
        }
        [self member:memberToRemove changedWithType:NXMMembersControllerChangeTypeRemoved];
    }
}

#pragma mark - delegate
-(void)contentWillChange {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self contentWillChange];
        });
        return;
    }
    if([self.delegate respondsToSelector:@selector(nxmConversationMembersControllerWillChangeContent:)]) {
        [self.delegate nxmConversationMembersControllerWillChangeContent:self];
    }
}

-(void)contentDidChange {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self contentDidChange];
        });
        return;
    }
    if([self.delegate respondsToSelector:@selector(nxmConversationMembersControllerDidChangeContent:)]) {
        [self.delegate nxmConversationMembersControllerDidChangeContent:self];
    }
}

-(void)member:(nonnull NXMMember *)member changedWithType:(NXMMembersControllerChangeType)type {
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