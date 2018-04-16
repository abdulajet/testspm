//
//  NXMCreateConversationRequest.h
//  NexmoConversationObjC
//
//  Created by user on 16/04/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#ifndef NXMCreateConversationRequest_h
#define NXMCreateConversationRequest_h

#import "NXMBaseRequest.h"

@interface NXMCreateConversationRequest : NXMBaseRequest

@property (nonatomic, strong, nonnull) NSString *displayName;
@property (nonatomic, strong, nullable) NSString *uniqueName;
//Need to add Image
//@property (nonatomic, strong, nullable) NSImage *image;

@end


#endif /* NXMCreateConversationRequest_h */
