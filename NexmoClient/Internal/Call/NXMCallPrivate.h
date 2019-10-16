//
//  NXMCallPrivate.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMCall.h"
#import "NXMConversation.h"

@interface NXMCall (NXMCallPrivate) <NXMConversationDelegate>

- (nullable instancetype)initWithConversation:(nonnull NXMConversation *)conversation;

- (void)dialWithMember:(nonnull NXMMember *)member;
@end
