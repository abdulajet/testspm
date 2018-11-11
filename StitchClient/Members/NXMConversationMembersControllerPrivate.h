//
//  NXMConversationMembersControllerPrivate.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationMembersController.h"

@interface NXMConversationMembersController (Private)
-(instancetype)initWithConversationDetails:(nonnull NXMConversationDetails *)conversationDetails  andStitchContext:(nonnull NXMStitchContext *)stitchContext;
-(instancetype)initWithConversationDetails:(nonnull NXMConversationDetails *)conversationDetails  andStitchContext:(nonnull NXMStitchContext *)stitchContext delegate:(id <NXMConversationMembersControllerDelegate> _Nullable)deleagte;
@end
