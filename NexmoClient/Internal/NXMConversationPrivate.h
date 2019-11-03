//
//  NXMConversationPrivate.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversation.h"
#import "NXMStitchContext.h"

@interface NXMConversation (Private)
-(nullable instancetype)initWithConversationDetails:(nonnull NXMConversationDetails *)conversationDetails andStitchContext:(nonnull NXMStitchContext *)stitchContext;
@property (readwrite, nonatomic, nonnull) NXMConversationDetails * conversationDetails;

- (nonnull NSString *)joinClientRef:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completionHandler;

- (void)inviteMemberWithUsername:(nonnull NSString *)userId withMedia:(bool)withMedia
                      completion:(void (^_Nullable)(NSError * _Nullable error, NXMMember * _Nullable member))completion;

- (void)inviteToConversationWithPhoneNumber:(nullable NSString *)phoneNumber
                                 completion:(void (^_Nullable)(NSError *  _Nullable error , NSString * _Nullable knockingId))completion;

- (void)hold:(BOOL)isHold;
- (void)mute:(BOOL)isMuted;
- (void)earmuff:(BOOL)isEarmuff;
- (void)sendDTMF:(nonnull NSString *)dtmf completion:(void (^_Nullable)(NSError * _Nullable error))completion;

- (nullable NXMUser *)currentUser; //TODO: remove after some refactoring - exposed for now to fix bug CSI-1009
@end
