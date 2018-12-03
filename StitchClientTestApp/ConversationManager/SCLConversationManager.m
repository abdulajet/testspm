//
//  StitchWrapper.m
//  StitchTestApp
//
//  Created by Chen Lev on 5/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "SCLConversationManager.h"
#import "SCLStitchClients.h"
#import "SCLStitchClientWrapper.h"
#import "NXMStitchClient.h"
#import "SCLStitchClientWrapper+CoreExpose.h"

@interface SCLConversationManager ()
@property id<NXMStitchCoreDelegate> hackOriginalDelegate;
@end


@implementation SCLConversationManager
@synthesize stitchConversationClient = _stitchConversationClient;
@synthesize connectedUser = _connectedUser;

-(instancetype)initWithStitchCoreClient:(NXMStitchCore *)stitchCoreClient {
    if(self = [super init])
    {
        _stitchConversationClient = stitchCoreClient;
        self.conversationIdToMemberId = [NSMutableDictionary new];
        self.ongoingCalls =[SCLOngoingMediaCollection new];
        self.memberIdToName = [NSMutableDictionary<NSString *,NSString *> new];
    }
    return self;
}

+(instancetype)sharedInstance {
    static SCLConversationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //hack to get core conversation from the client while transfering the app to work with the object model
        id coreClient = [SCLStitchClients.sharedWrapperClient coreObject];
        sharedInstance = [[SCLConversationManager alloc] initWithStitchCoreClient:coreClient];
        
        sharedInstance.hackOriginalDelegate = [coreClient performSelector:NSSelectorFromString(@"delegate")];
        [(NXMStitchCore *)coreClient setDelgate:sharedInstance];
        
    });
    return sharedInstance;
}


-(void)addLookupMemberId:(NSString *)memberId forUser:(NSString *)userId inConversation:(NSString *)conversationId {
    [self.conversationIdToMemberId setObject:memberId forKey:conversationId];
}

-(bool)isCurrentUserThisMember:(NSString *)memberId {
    return [_connectedUser.name isEqualToString:[self.memberIdToName objectForKey:memberId]];
}



#pragma mark - StitchDelegate

- (void)actionOnMedia:(nonnull NXMMediaActionEvent *)mediaActionEvent {
    [self.hackOriginalDelegate actionOnMedia:mediaActionEvent];
    SCLOngoingMedia *media = nil;
    switch (mediaActionEvent.actionType) {
        case NXMMediaActionTypeSuspend://TODO: what happens when another member tells you to mute? should you change your local mute????
            if(media = [self.ongoingCalls getMediaForMember:mediaActionEvent.toMemberId inConversation:mediaActionEvent.conversationId]) {
                if(mediaActionEvent.sequenceId > media.lastSeqNum) {
                    media.suspended = ((NXMMediaSuspendEvent *)mediaActionEvent).isSuspended;
                    media.lastSeqNum = mediaActionEvent.sequenceId;
                }
            }
            break;
            
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"mediaActionEvent"
     object:nil userInfo:@{@"media":mediaActionEvent}];
}

- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error; {
    [self.hackOriginalDelegate loginStatusChanged:user loginStatus:isLoggedIn withError:error];
    if (user && isLoggedIn) {
        _connectedUser = user;
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil userInfo:@{@"user":user}];
    } else if (!isLoggedIn && user) {
        NSLog(@"User logged out: %@", [user description]) ;
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil userInfo:@{@"user":user}];
        _connectedUser = nil;
    } else if (error){
        _connectedUser = nil;
        NSLog(@"Authentication Error Occured: %@", [error description]);
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailure" object:nil userInfo:@{@"error":error}];
    }
}

- (void)imageDelivered:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self.hackOriginalDelegate imageDelivered:statusEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"statusEvent"
     object:nil userInfo:@{@"statusEvent":statusEvent}];
}

- (void)imageRecieved:(nonnull NXMImageEvent *)textEvent {
    [self.hackOriginalDelegate imageRecieved:textEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"imageEvent"
     object:nil userInfo:@{@"image":textEvent}];
}

- (void)imageSeen:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self.hackOriginalDelegate imageSeen:statusEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"statusEvent"
     object:nil userInfo:@{@"statusEvent":statusEvent}];
}

- (void)informOnMedia:(nonnull NXMMediaEvent *)mediaEvent { //assuming disabled does not come before enabled - not always true
    [self.hackOriginalDelegate informOnMedia:mediaEvent];
    if(mediaEvent.mediaSettings.isEnabled) {
        SCLOngoingMedia *media = [[SCLOngoingMedia alloc] initWithMemberId:mediaEvent.fromMemberId andConversationId:mediaEvent.conversationId andSeqNum:mediaEvent.sequenceId];
        media.enabled = mediaEvent.mediaSettings.isEnabled;
        media.suspended = mediaEvent.mediaSettings.isSuspended;
        
        [self.ongoingCalls addMedia:media ForMember:mediaEvent.fromMemberId inConversation:mediaEvent.conversationId];
    } else {
        [self.ongoingCalls removeMediaForMember:mediaEvent.fromMemberId inConversation:mediaEvent.conversationId];
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"mediaEvent"
     object:nil userInfo:@{@"media":mediaEvent}];
}

- (void)memberInvited:(nonnull NXMMemberEvent *)memberEvent {
    [self.hackOriginalDelegate memberInvited:memberEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"memberEvent"
     object:nil userInfo:@{@"member":memberEvent}];
    if (memberEvent.user.name){
        [self.memberIdToName setObject:memberEvent.user.name forKey:memberEvent.memberId];
    }
}

- (void)memberJoined:(nonnull NXMMemberEvent *)memberEvent {
    [self.hackOriginalDelegate memberJoined:memberEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"memberEvent"
     object:nil userInfo:@{@"member":memberEvent}];
    if (memberEvent.user.name){
        [self.memberIdToName setObject:memberEvent.user.name forKey:memberEvent.memberId];
    }
}

- (void)memberRemoved:(nonnull NXMMemberEvent *)memberEvent {
    [self.hackOriginalDelegate memberRemoved:memberEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"memberEvent"
     object:nil userInfo:@{@"member":memberEvent}];
}

- (void)connectionStatusChanged:(BOOL)isConnected {
    [self.hackOriginalDelegate connectionStatusChanged:isConnected];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"connectionStatusChanged" object:nil];
}

- (void)sipAnswered:(nonnull NXMSipEvent *)sipEvent {
    [self.hackOriginalDelegate sipAnswered:sipEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sipEvent"
     object:nil userInfo:@{@"sipEvent":sipEvent}];
}

- (void)sipHangup:(nonnull NXMSipEvent *)sipEvent {
    [self.hackOriginalDelegate sipHangup:sipEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sipEvent"
     object:nil userInfo:@{@"sipEvent":sipEvent}];
}

- (void)sipRinging:(nonnull NXMSipEvent *)sipEvent {
    [self.hackOriginalDelegate sipRinging:sipEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sipEvent"
     object:nil userInfo:@{@"sipEvent":sipEvent}];
}

- (void)sipStatus:(nonnull NXMSipEvent *)sipEvent {
    [self.hackOriginalDelegate sipStatus:sipEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sipEvent"
     object:nil userInfo:@{@"sipEvent":sipEvent}];
}

- (void)messageDeleted:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self.hackOriginalDelegate messageDeleted:statusEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"statusEvent"
     object:nil userInfo:@{@"statusEvent":statusEvent}];
}

- (void)textDelivered:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self.hackOriginalDelegate textDelivered:statusEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"statusEvent"
     object:nil userInfo:@{@"statusEvent":statusEvent}];
}

- (void)textRecieved:(nonnull NXMTextEvent *)textEvent {
    [self.hackOriginalDelegate textRecieved:textEvent];
    NSString *memberId = self.conversationIdToMemberId[textEvent.conversationId];
    if (memberId) {
        [self.stitchConversationClient markAsDelivered:textEvent.sequenceId conversationId:textEvent.conversationId fromMemberWithId:memberId onSuccess:^{
            
        } onError:^(NSError * _Nullable error) {
            NSLog(@"error markAsDelivered");
        }];
    } else {
        [self.stitchConversationClient getConversationDetails:textEvent.conversationId onSuccess:^(NXMConversationDetails * _Nullable conversationDetails) {
            NSString *currMember;
            for (NXMMember *member in conversationDetails.members) {
                if ([member.userId isEqualToString:self.stitchConversationClient.user.userId]){
                    currMember = member.memberId;
                    [self.conversationIdToMemberId setObject:member.memberId forKey:member.conversationId];
                    break;
                }
            }
            
            [self.stitchConversationClient markAsDelivered:textEvent.sequenceId conversationId:textEvent.conversationId fromMemberWithId:currMember onSuccess:^{
                
            } onError:^(NSError * _Nullable error) {
                NSLog(@"error markAsDelivered");
            }];
        } onError:^(NSError * _Nullable error) {
            
        }];
    }
    
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"textEvent"
     object:nil userInfo:@{@"text":textEvent}];
}

- (void)textSeen:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self.hackOriginalDelegate textSeen:statusEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"statusEvent"
     object:nil userInfo:@{@"statusEvent":statusEvent}];
}

- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textTypingEvent {
    [self.hackOriginalDelegate textTypingOff:textTypingEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"typingEvent"
     object:nil userInfo:@{@"typingEvent":textTypingEvent}];
}

- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textTypingEvent {
    [self.hackOriginalDelegate textTypingOn:textTypingEvent];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"typingEvent"
     object:nil userInfo:@{@"typingEvent":textTypingEvent}];
}

- (void)tokenExpired:(nullable NSString *)token withReason:(NXMStitchErrorCode)reason {

}

- (void)localActionOnMedia:(nonnull NXMMediaActionEvent *)mediaActionEvent {
    [self.hackOriginalDelegate localActionOnMedia:mediaActionEvent];
}


- (void)localInformOnMedia:(nonnull NXMMediaEvent *)mediaEvent {
    [self.hackOriginalDelegate localInformOnMedia:mediaEvent];
}


@end

