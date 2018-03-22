//
//  NXMErrors.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/22/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const NXMStitchErrorDomain;

typedef NS_ENUM(NSInteger, NXMStitchErrorCode) {
    NXMStitchErrorCodeUnknown,
    NXMStitchErrorCodeInvalidToken
};
