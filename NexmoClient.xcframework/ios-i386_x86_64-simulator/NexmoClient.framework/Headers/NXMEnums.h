//
//  NXMEnums.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

@import Foundation;

/**
 * A list of the `NXMClient` connection statuses.
 */
typedef NS_ENUM(NSInteger, NXMConnectionStatus) {
    /// The client is disconnected.
    NXMConnectionStatusDisconnected,
    /// The client is connecting.
    NXMConnectionStatusConnecting,
    /// The client is connected.
    NXMConnectionStatusConnected
};

/**
 * A list of the `NXMClient` connection reasons.
 */
typedef NS_ENUM(NSInteger, NXMConnectionStatusReason) {
    /// Unknown connection reason.
    NXMConnectionStatusReasonUnknown,
    /// The client connection updated due to a login.
    NXMConnectionStatusReasonLogin,
    /// The client connection updated due to a logout.
    NXMConnectionStatusReasonLogout,
    /// The client connection updated due to the token being refreshed.
    NXMConnectionStatusReasonTokenRefreshed,
    /// The client connection updated due to the token being invalid.
    NXMConnectionStatusReasonTokenInvalid,
    /// The client connection updated due to an expired token.
    NXMConnectionStatusReasonTokenExpired,
    /// The client connection updated due to the user not being found.
    NXMConnectionStatusReasonUserNotFound,
    /// The client connection updated due to the connection being terminated.
    NXMConnectionStatusReasonTerminated,
    /// The client connection updated due to an SSL pinning error.
    NXMConnectionStatusReasonSSLPinningError
};

/**
 * A list of push notification templates.
 */
typedef NS_ENUM(NSInteger, NXMPushTemplate) {
    /// Default push notification template.
    NXMPushTemplateDefault,
    /// A custom push notification template.
    NXMPushTemplateCustom
};

/**
 * A list of `NXMMember` update types.
 */
typedef NS_ENUM(NSInteger, NXMMemberUpdateType) {
    /// Member state update.
    NXMMemberUpdateTypeState,
    /// Member media update.
    NXMMemberUpdateTypeMedia,
    /// Member leg update.
    NXMMemberUpdateTypeLeg
};

/**
 * A list of `NXMMedia` update types.
 */
typedef NS_ENUM(NSInteger, NXMMediaType) {
    /// No media type.
    NXMMediaTypeNone = (0),
    /// Audio media type.
    NXMMediaTypeAudio = (1 << 0),
    /// Video media type.
    NXMMediaTypeVideo = (1 << 1)
};

/**
 * A list of `NXMEvent` types.
 */
typedef NS_ENUM(NSInteger, NXMEventType) {
    /// General event type case.
    NXMEventTypeGeneral,
    /// `NXMCustomEvent` type case.
    NXMEventTypeCustom,
    /// `NXMTextEvent` type case.
    NXMEventTypeText,
    /// `NXMImageEvent` type case.
    NXMEventTypeImage,
    /// `NXMMessageEvent` type case.
    NXMEventTypeMessage,
    /// `NXMMessageStatusEvent` type case.
    NXMEventTypeMessageStatus,
    /// `NXMTextTypingEvent` type case.
    NXMEventTypeTextTyping,
    /// `NXMMediaEvent` type case.
    NXMEventTypeMedia,
    /// `NXMMemberEvent` type case.
    NXMEventTypeMember,
    /// `NXMEventTypeRTC` type case.
    NXMEventTypeRTC,
    /// `NXMSipEvent` type case.
    NXMEventTypeSip,
    /// `NXMDTMFEvent` type case.
    NXMEventTypeDTMF,
    /// `NXMLegStatusEvent` type case.
    NXMEventTypeLegStatus,
    /// `NXMMemberMessageStatusEvent` type case.
    NXMEventTypeMemberMessageStatus,
    /// Unknown event type case.
    NXMEventTypeUnknown
};

/**
 * A list of `NXMMessageEvent` types.
 */
typedef NS_ENUM(NSInteger, NXMMessageType) {
    /// Text message.
    NXMMessageTypeText,
    /// Image message.
    NXMMessageTypeImage,
    /// Audio message.
    NXMMessageTypeAudio,
    /// Video message.
    NXMMessageTypeVideo,
    /// File message.
    NXMMessageTypeFile,
    /// Template message.
    NXMMessageTypeTemplate,
    /// Vcard message.
    NXMMessageTypeVcard,
    /// Location message.
    NXMMessageTypeLocation,
    /// Custom message.
    NXMMessageTypeCustom,
    /// Unknown message.
    NXMMessageTypeUnknown
};

/**
 * A list of SIP statuses.
 */
typedef NS_ENUM(NSInteger, NXMSipStatus){
    /// Ringing SIP status.
    NXMSipEventRinging,
    /// Answered SIP status.
    NXMSipEventAnswered,
    /// SIP status update.
    NXMSipEventStatus,
    /// Hangup SIP status.
    NXMSipEventHangup
};

/**
 * A list of message status types.
 */
typedef NS_ENUM(NSInteger, NXMMessageStatusType) {
    /// No message status.
    NXMMessageStatusTypeNone,
    /// Message marked as seen.
    NXMMessageStatusTypeSeen,
    /// Message marked as delivered.
    NXMMessageStatusTypeDelivered,
    /// Message marked as deleted.
    NXMMessageStatusTypeDeleted
};

/**
 * A list of typing events statuses.
 */
typedef NS_ENUM(NSInteger, NXMTextTypingEventStatus) {
    /// Typing status on.
    NXMTextTypingEventStatusOn,
    /// Typing status off.
    NXMTextTypingEventStatusOff
};

/**
 * A list of `NXMMember` states.
 */
typedef NS_ENUM(NSInteger, NXMMemberState) {
    /// Member state of invited to a `NXMConversation`.
    NXMMemberStateInvited,
    /// Member state of joined a `NXMConversation`.
    NXMMemberStateJoined,
    /// Member state of left a `NXMConversation`.
    NXMMemberStateLeft,
    /// Member state unknown.
    NXMMemberStateUnknown
};

/**
 * A list of `NXMChannel` types.
 */
typedef NS_ENUM(NSInteger, NXMChannelType){
    /// An app direction type.
    NXMChannelTypeApp,
    /// A phone direction type.
    NXMChannelTypePhone,
    /// A SIP direction type.
    NXMChannelTypeSIP,
    /// A WebSocket direction type.
    NXMChannelTypeWebsocket,
    /// A VBC direction type.
    NXMChannelTypeVBC,
    /// A Sms direction type.
    NXMChannelTypeSms,
    /// A Mms direction type.
    NXMChannelTypeMms,
    /// A WhatsApp direction type.
    NXMChannelTypeWhatsapp,
    /// A Viber direction type.
    NXMChannelTypeViber,
    /// A Messenger direction type.
    NXMChannelTypeMessenger,
    /// An unknown direction type.
    NXMChannelTypeUnknown
};

/**
 * A list of media stream types.
 */
typedef NS_ENUM(NSInteger, NXMMediaStreamType) {
    /// No stream type.
    NXMMediaStreamTypeNone,
    /// Send stream type.
    NXMMediaStreamTypeSend,
    /// Receive stream type.
    NXMMediaStreamTypeReceive,
    /// Send and receive stream type.
    NXMMediaStreamTypeSendReceive
};

/**
 * A list of `NXMLeg` statuses.
 */
typedef NS_ENUM(NSInteger, NXMLegStatus) {
    /// Ringing leg status.
    NXMLegStatusRinging,
    /// Leg started status.
    NXMLegStatusStarted,
    /// Answered leg status.
    NXMLegStatusAnswered,
    /// Cancelled leg status.
    NXMLegStatusCancelled,
    /// Failed leg status.
    NXMLegStatusFailed,
    /// Busy leg status.
    NXMLegStatusBusy,
    /// Leg timeout status.
    NXMLegStatusTimeout,
    /// Rejected leg status.
    NXMLegStatusRejected,
    /// Completed leg status.
    NXMLegStatusCompleted
};

/**
 * A list of `NXMLeg` types.
 */
typedef NS_ENUM(NSInteger, NXMLegType) {
    /// App leg type.
    NXMLegTypeApp,
    /// Phone leg type.
    NXMLegTypePhone,
    /// Leg type unknown.
    NXMLegTypeUnknown
};

/**
 * A list of `NXMPageOrder` types.
 */
typedef NS_ENUM(NSInteger, NXMPageOrder) {
    /// Ascending page order.
    NXMPageOrderAsc,
    /// Descending page order.
    NXMPageOrderDesc
};

/**
 * A list of the call member statuses.
 */
typedef NS_ENUM(NSInteger, NXMCallMemberStatus) {
    /// The call is initialized.
    NXMCallMemberStatusRinging,
    /// The server started the call.
    NXMCallMemberStatusStarted,
    /// The call is answered.
    NXMCallMemberStatusAnswered,
    /// The call is cancelled.
    NXMCallMemberStatusCancelled,
    /// The call failed.
    NXMCallMemberStatusFailed,
    /// The member being called is busy.
    NXMCallMemberStatusBusy,
    /// The member is unreachable within the timeout.
    NXMCallMemberStatusTimeout,
    /// The member rejected the call.
    NXMCallMemberStatusRejected,
    /// The call is completed.
    NXMCallMemberStatusCompleted
};

/**
 * A list of the media connection statuses.
 */
typedef NS_ENUM(NSInteger, NXMMediaConnectionStatus) {
    /// Media is now being exchanged.
    NXMMediaConnectionStatusConnected,
    /// Temporary network problem: no direct action needed, will try to reconnect.
    NXMMediaConnectionStatusDisconnected,
    /// Media Connection has been closed.
    NXMMediaConnectionStatusClosed
};
