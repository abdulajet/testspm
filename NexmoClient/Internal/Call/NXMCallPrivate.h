//
//  NXMCallPrivate.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMCall.h"

@interface NXMCall (NXMCallPrivate)

- (nullable instancetype)initWithConversation:(nonnull NXMConversation *)conversation;

- (void)dialWithMember:(nonnull NXMMember *)member;
@end
