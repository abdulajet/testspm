//
//  NXMConversationPrivate.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversation.h"
#import "NXMStitchContext.h"

@interface NXMConversation (Private)
-(instancetype)initWithConversationDetails:(NXMConversationDetails *)conversationDetails andStitchContext:(NXMStitchContext *)stitchContext;
@property (readwrite, nonatomic) NXMConversationDetails *conversationDetails;

- (void)inviteMemberWithUsername:(NSString *)userId withMedia:(bool)withMedia
                    completion:(void (^)(NSError * error, NXMMember * member))completion;

- (void)inviteToConversationWithPhoneNumber:(NSString*)phoneNumber
                    completion:(void (^)(NSError *  error, NSString *  knockingId))completion;

- (NXMErrorCode)enableMedia:(NSString *)memberId;
- (NXMErrorCode)disableMedia;
- (void)hold:(BOOL)isHold;
- (void)mute:(BOOL)isMuted;
- (void)earmuff:(BOOL)isEarmuff;
- (void)sendDTMF:(NSString *)dtmf completion:(void (^_Nullable)(NSError * _Nullable error))completion;

- (NXMUser *)currentUser; //TODO: remove after some refactoring - exposed for now to fix bug CSI-1009
@end
