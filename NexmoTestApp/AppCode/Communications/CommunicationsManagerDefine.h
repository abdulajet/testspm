//
//  NexmoClientWrapperDefine.h
//  Stitch_iOS
//
//  Created by Doron Biaz on 12/13/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

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

