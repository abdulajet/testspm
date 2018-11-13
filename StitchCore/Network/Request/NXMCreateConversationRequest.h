//
//  NXMCreateConversationRequest.h
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMBaseRequest.h"

@interface NXMCreateConversationRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSString *displayName;

- (nullable instancetype)initWithDisplayName:(nonnull NSString *)displayName;

@end

