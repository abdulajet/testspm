//
//  NXMErrors.h
//  StitchObjC
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * _Nonnull const NXMStitchErrorDomain;

typedef NS_ENUM(NSInteger, NXMStitchErrorCode) {
    NXMStitchErrorCodeNone,

    NXMStitchErrorCodeUnknown,
    
    NXMStitchErrorCodeSessionUnknown,
    NXMStitchErrorCodeSessionInvalid,           // @"system:error:invalid-session"
    
    NXMStitchErrorCodeTokenUnknown,
    NXMStitchErrorCodeTokenInvalid,             // @"system:error:invalid-token"
    NXMStitchErrorCodeTokenExpired,             // @"system:error:expired-token"
    
    NXMStitchErrorCodeMemberUnknown,
    NXMStitchErrorCodeMemberNotFound,           // @"member:error:not-found"
    NXMStitchErrorCodeMemberAlreadyRemoved,     // @"conversation:error:invalid-member-state"
    NXMStitchErrorCodeNotAMemberOfTheConversation,
    
    NXMStitchErrorCodeEventUnknown,
    NXMStitchErrorCodeEventUserNotFound,        // @"user:error:not-found"
    NXMStitchErrorCodeEventUserAlreadyJoined,   // @"conversation:error:member-already-joined"
    NXMStitchErrorCodeEventInvalid,             // @"conversation:error:invalid-event"
    NXMStitchErrorCodeEventBadPermission,
    NXMStitchErrorCodeEventNotFound,      
    
    NXMStitchErrorCodeConversationRetrievalFailed,
    NXMStitchErrorCodeConversationNotFound,
    NXMStitchErrorCodeConversationInvalidMember,
    
    NXMStitchErrorCodeMediaNotSupported,
    NXMStitchErrorCodeMediaNotFound,
    NXMStitchErrorCodeInvalidMediaRequest,
    NXMStitchErrorCodeMediaTooManyRequests,
    NXMStitchErrorCodeMediaBadRequest,
    NXMStitchErrorCodeMediaInternalError,
    
    NXMStitchErrorCodePushNotAStitchPush,
    NXMStitchErrorCodePushParsingFailed,
    
    NXMStitchErrorCodeNotImplemented,
    NXMStitchErrorCodePayloadTooBig

    
};


@interface NXMErrors : NSObject
+(NSError *)nxmStitchErrorWithErrorCode:(NXMStitchErrorCode)errorCode andUserInfo:(nullable NSDictionary<NSErrorUserInfoKey,id> *)userInfo;
@end
