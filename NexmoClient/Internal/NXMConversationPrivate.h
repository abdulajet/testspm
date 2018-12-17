//
//  NXMConversationPrivate.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversation.h"
#import "NXMStitchContext.h"

@interface NXMConversation (Private)
-(instancetype)initWithConversationDetails:(nonnull NXMConversationDetails *)conversationDetails andStitchContext:(nonnull NXMStitchContext *)stitchContext;
@property (readwrite, nonatomic, nonnull) NXMConversationDetails *conversationDetails;

- (void)inviteMemberWithUserId:(nonnull NSString *)userId withMedia:(bool)withMedia
                    completion:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completion;

- (void)inviteToConversationWithPhoneNumber:(NSString*)phoneNumber
                    completion:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable knockingId))completion;

- (NXMStitchErrorCode)enableMedia:(NSString *)memberId;
- (NXMStitchErrorCode)disableMedia;
- (void)hold:(BOOL)isHold;
- (void)mute:(BOOL)isMuted;
- (void)earmuff:(BOOL)isEarmuff;

@end
