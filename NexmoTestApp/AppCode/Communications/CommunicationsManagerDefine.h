//
//  NexmoClientWrapperDefine.h
//  Stitch_iOS
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#pragma mark - enums

typedef NS_ENUM(NSInteger, CommunicationsManagerConnectionStatus) {
    CommunicationsManagerConnectionStatusUnknown,
    CommunicationsManagerConnectionStatusNotConnected,
    CommunicationsManagerConnectionStatusReconnecting,
    CommunicationsManagerConnectionStatusConnected
};

typedef NS_ENUM(NSInteger, CommunicationsManagerConnectionStatusReason) {
    CommunicationsManagerConnectionStatusReasonUnknown,
    CommunicationsManagerConnectionStatusReasonLogin,
    CommunicationsManagerConnectionStatusReasonLogout,
    CommunicationsManagerConnectionStatusReasonTokenInvalid,
    CommunicationsManagerConnectionStatusReasonTokenExpired,
    CommunicationsManagerConnectionStatusReasonSessionInvalid,
    CommunicationsManagerConnectionStatusReasonMaxSessions,
    CommunicationsManagerConnectionStatusReasonSessionTerminated
};

#pragma mark - notifications
#define kNTACommunicationsManagerNotificationNameConnectionStatus @"NTACommunicationsManagerConnectionStatus"
#define kNTACommunicationsManagerNotificationKeyConnectionStatus @"connectionStatus"
#define kNTACommunicationsManagerNotificationKeyConnectionStatusReason @"connectionStatusReason"

#define kNTACommunicationsManagerNotificationNameIncomingCall @"NTACommunicationsManagerIncomingCall"
#define kNTACommunicationsManagerNotificationKeyIncomingCall @"call"


