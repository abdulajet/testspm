//
//  NXMConversationPrivate.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversation.h"

@interface NXMConversation (Private)
-(instancetype)initWithConversationDetails:(nonnull NXMConversationDetails *)conversationDetails andStitchContext:(nonnull NXMStitchContext *)stitchContext;
@property (readwrite, nonatomic, nonnull) NXMConversationDetails *conversationDetails;
@end
