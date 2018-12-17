//
//  NXMMembersController.m
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//
#import <NexmoCore/NexmoCore.h>

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
        case NXMMemberStateInvited:
            [self handleInvitedMember:member];
        case NXMMemberStateJoined:
            [self handleJoinedMember:member];
            break;
        case NXMMemberStateLeft:
            [self handleLeftMember:member];
            break;
        default:
            break;
    }
}

//TODO: for now assuming memebr has the following flow invited->joined->removed -> if it's a different flow we'll need to do conflict resolution with sequenceId, if not we'll need to remove this comment 🧔🏻

- (void)handleInvitedMember:(NXMMember *)member {
    if(self.membersDictionary[member.memberId]) {
        return;
    }
    
    [self addMember:member];
    [self member:member changedWithType:NXMMembersControllerChangeTypeInvited];
}

- (void)handleJoinedMember:(NXMMember *)member {
    if(self.membersDictionary[member.memberId].state == NXMMemberStateJoined || self.membersDictionary[member.memberId].state == NXMMemberStateLeft) {
        return;
    }
    
    if(self.membersDictionary[member.memberId]) {
        [self updateMember:member];
    } else {
        [self addMember:member];
    }
    
    [self member:member changedWithType:NXMMembersControllerChangeTypeJoined];
}

- (void)handleLeftMember:(NXMMember *)member {
    if(self.membersDictionary[member.memberId].state == NXMMemberStateLeft) {
        return;
    }
    
    if(self.membersDictionary[member.memberId]) {
        [self updateMember:member];
    } else {
        [self addMember:member];
    }
    
    [self member:member changedWithType:NXMMembersControllerChangeTypeLeft];
}

- (void)addMember:(nonnull NXMMember *)member {
    self.membersDictionary[[member.memberId copy]] = member;
    if([member.userId isEqualToString:self.currentUser.userId]) {
        self.myMember = member;
    } else {
        [self.mutableOtherMembers addObject:member];
    }
}

- (void)updateMember:(nonnull NXMMember *)member {
    NSUInteger indexOfMember = [self.mutableOtherMembers indexOfObject:self.membersDictionary[member.memberId]];
    if(indexOfMember == NSNotFound) {
        return;
    }
    
    self.membersDictionary[member.memberId] = member;
    [self.mutableOtherMembers replaceObjectAtIndex:indexOfMember withObject:member];
}

//-(void)addMember:(NXMMember *)member {
//    if(!self.membersDictionary[member.memberId]) {
//        self.membersDictionary[member.memberId] = member;
//        if([member.userId isEqualToString:self.currentUser.userId]) {
//            self.myMember = member;
//        } else {
//            [self.mutableOtherMembers addObject:member];
//        }
//        [self member:member changedWithType:NXMMembersControllerChangeTypeJoined];
//    }
//}
//
//-(void)removeMember:(NXMMember *)member {
//    [self removeMemberWithMemberId:member.memberId];
//}
//
//-(void)removeMemberWithMemberId:(NSString *)memberId {
//    if(self.membersDictionary[memberId]) {
//        NXMMember *memberToRemove = self.membersDictionary[memberId];
//        [self.membersDictionary removeObjectForKey:memberId];
//        if([memberToRemove.userId isEqualToString:self.currentUser.userId]) {
//            self.myMember = nil;
//        } else {
//            [self.mutableOtherMembers removeObject:memberToRemove];
//        }
//        [self member:memberToRemove changedWithType:NXMMembersControllerChangeTypeLeft];
//    }
//}

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
