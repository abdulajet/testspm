//
//  NXMSendImageRequest.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 5/29/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMBaseRequest.h"

@interface NXMSendImageRequest : NXMBaseRequest

@property NSData *image;
@property NSString *conversationId;
@property NSString *memberId;

- (instancetype)initWithImage:(NSData *)image conversationId:(NSString *)conversationId memberId:(NSString *)memberId;
@end
