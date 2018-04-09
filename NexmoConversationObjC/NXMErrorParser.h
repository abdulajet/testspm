//
//  NXMErrorParser.h
//  NexmoConversationObjC
//
//  Created by user on 22/03/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#ifndef NXMErrorParser_h
#define NXMErrorParser_h

#import "NXMErrors.h"

@interface NXMErrorParser : NSObject
+ (int) parseError:(nonnull NSData*) data;
+ (NSString* _Nonnull) toString:(int) errorResult;
@end

#endif /* NXMErrorParser_h */
