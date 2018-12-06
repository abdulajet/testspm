//
//  NXMMembersController.m
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//
#import <StitchCore/StitchCore.h>

#import "NXMConversationMembersController.h"

#import "NXMConversation.h"
#import "NXMStitchContext.h"

@interface NXMConversationMembersController ()
@property (nonatomic, readwrite, nullable) NXMMember *myMember;
@property (nonatomic, readwrite, nullable) NSMutableArray<NXMMember *> *mutableOtherMembers;
@property (nonatomic, readwrite, nullable) NSMutableDictionary<NSString *, NXMMember *> *membersDictionary;
@property (nonatomic, readwrite, nullable, weak) id <NXMConversationMembersControllerDelegate> delegate;
@property (nonatomic, readwrite, nonnull) NXMConversationDetails *conversationDetails;
@property (nonatomic, readwrite, nullable) NXMUser *currentUser;
@property (nonatomic, readwrite) BOOL contentChanging;
@end

@implementation NXMConversationMembersController

#pragma mark - init
- (instancetype)initWithConversationDetails:(nonnull NXMConversationDetails *)conversationDetails andCurrentUser:(nonnull NXMUser *)currentUser {
    return [self initWithConversationDetails:conversationDetails andCurrentUser:currentUser delegate:nil];
}

- (instancetype)initWithConversationDetails:(nonnull NXMConversationDetails *)conversationDetails  andCurrentUser:(nonnull NXMUser *)currentUser delegate:(id <NXMConversationMembersControllerDelegate> _Nullable)deleagte
{
    self = [super init];
    if (self) {
        self.conversationDetails = conversationDetails;
        self.currentUser = currentUser;
        self.mutableOtherMembers = [NSMutableArray<NXMMember *> new];
        self.membersDictionary = [NSMutableDictionary new];
        [self initMembersWithConversationDetails:conversationDetails];
    }
    return self;
}

- (void)initMembersWithConversationDetails:(NXMConversationDetails * _Nonnull)conversationDetails {
    for (NXMMember *member in conversationDetails.members) {
        if(member.state != NXMMemberStateJoined) {
            continue;
        }
        
        if([member.userId isEqualToString:self.currentUser.userId]) {
            self.myMember = member;
        } else {
            [self.mutableOtherMembers addObject:member];
        }
        
        self.membersDictionary[[member.memberId copy]] = member;
    }
}

#pragma mark - unsynthesized properties
-(NSArray<NXMMember *> *)otherMembers {
    return self.mutableOtherMembers;
}

#pragma mark - public
-(nullable NXMMember *)memberForMemberId:(nonnull NSString *)memberId {
    return self.membersDictionary[memberId];
}


#pragma mark - Private Updating Methods
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
        if([member.userId isEqualToString:self.currentUser.userId]) {
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
        if([memberToRemove.userId isEqualToString:self.currentUser.userId]) {
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
