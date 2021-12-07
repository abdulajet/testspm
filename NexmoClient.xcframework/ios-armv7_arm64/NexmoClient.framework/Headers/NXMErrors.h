//
//  NXMErrors.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

@import Foundation;

/// The error domain
FOUNDATION_EXPORT NSString * _Nonnull const NXMErrorDomain;

/**
 * A list of the error codes.
 */
typedef NS_ENUM(NSInteger, NXMErrorCode) {
    /// No error code.
    NXMErrorCodeNone,

    /// Error code unknown.
    NXMErrorCodeUnknown,

    /// HTTP Not found 404 error code.
    NXMErrorCodeHttpNotFound,

    /// Unknown session error code.
    NXMErrorCodeSessionUnknown,
    /// Invalid session error code.
    NXMErrorCodeSessionInvalid,           // @"system:error:invalid-session"
    /// Disconnected session error code.
    NXMErrorCodeSessionDisconnected,
    /// Max open sessions error code.
    NXMErrorCodeMaxOpenedSessions,
    
    /// Unknown token error code.
    NXMErrorCodeTokenUnknown,
    /// Invalid token error code.
    NXMErrorCodeTokenInvalid,             // @"system:error:invalid-token"
    /// Expired token error code.
    NXMErrorCodeTokenExpired,             // @"system:error:expired-token"
    
    /// Unknown conversation member error code.
    NXMErrorCodeMemberUnknown,
    /// Conversation member not found error code.
    NXMErrorCodeMemberNotFound,           // @"member:error:not-found"
    /// Conversation member already removed error code.
    NXMErrorCodeMemberAlreadyRemoved,     // @"conversation:error:invalid-member-state"
    /// Member not in the conversation error code.
    NXMErrorCodeNotAMemberOfTheConversation,
    
    /// Unknown event error code.
    NXMErrorCodeEventUnknown,
    /// User not found error code.
    NXMErrorCodeEventUserNotFound,        // @"user:error:not-found"
    /// User already joined error code.
    NXMErrorCodeEventUserAlreadyJoined,   // @"conversation:error:member-already-joined"
    /// Invalid event error code.
    NXMErrorCodeEventInvalid,             // @"conversation:error:invalid-event"
    /// Bad permissions error code.
    NXMErrorCodeEventBadPermission,
    /// Event not found error code.
    NXMErrorCodeEventNotFound,
    /// Event's page not found error code.
    NXMErrorCodeEventsPageNotFound,
    
    /// Conversation retrieval failed error code.
    NXMErrorCodeConversationRetrievalFailed,
    /// Conversation not found error code.
    NXMErrorCodeConversationNotFound,
    /// Conversation invalid member error code.
    NXMErrorCodeConversationInvalidMember,
    /// Conversation expired error code.
    NXMErrorCodeConversationExpired,
    /// Conversation's page not found error code.
    NXMErrorCodeConversationsPageNotFound,
    
    /// Media not supported error code.
    NXMErrorCodeMediaNotSupported,
    /// Media not found error code.
    NXMErrorCodeMediaNotFound,
    /// Invalid media request error code.
    NXMErrorCodeInvalidMediaRequest,
    /// Too many media requests error code.
    NXMErrorCodeMediaTooManyRequests,
    /// Bad media request error code.
    NXMErrorCodeMediaBadRequest,
    /// Internal media error code.
    NXMErrorCodeMediaInternalError,
    
    /// Push not a Nexmo push error code.
    NXMErrorCodePushNotANexmoPush,
    /// Push parsing failed error code.
    NXMErrorCodePushParsingFailed,
    
    /// Not implemented error code.
    NXMErrorCodeNotImplemented,
    /// Missing delegate error code.
    NXMErrorCodeMissingDelegate,
    /// Payload too big error code.
    NXMErrorCodePayloadTooBig,
    
    /// SDK disconnected error code.
    NXMErrorCodeSDKDisconnected,
    /// User not found error code.
    NXMErrorCodeUserNotFound,   // @"user:error:not-found"
    
    /// Illegal DTMF error code.
    NXMErrorCodeDTMFIllegal
};
