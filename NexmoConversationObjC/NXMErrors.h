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
    
    NXMStitchErrorCodeSessionUnknown,
    NXMStitchErrorCodeSessionInvalid,           // @"system:error:invalid-session"
    
    NXMStitchErrorCodeTokenUnknown,
    NXMStitchErrorCodeTokenInvalid,             // @"system:error:invalid-token"
    NXMStitchErrorCodeTokenExpired,             // @"system:error:expired-token"
    
    NXMStitchErrorCodeMemberUnknown,
    NXMStitchErrorCodeMemberNotFound,           // @"member:error:not-found"
    NXMStitchErrorCodeMemberAlreadyRemoved,     // @"conversation:error:invalid-member-state"
    
    NXMStitchErrorCodeEventUnknown,
    NXMStitchErrorCodeEventUserNotFound,        // @"user:error:not-found"
    NXMStitchErrorCodeEventUserAlreadyJoined,   // @"conversation:error:member-already-joined"
    NXMStitchErrorCodeEventInvalid,             // @"conversation:error:invalid-event"
    NXMStitchErrorCodeEventBadPermission,       
    
    NXMStitchErrorCodeConversationUnknown,
    NXMStitchErrorCodeConversationNotFound
};
