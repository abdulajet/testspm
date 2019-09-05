//
//  NexmoClientWrapper.m
//  NexmoTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//


#import "CommunicationsManager.h"
#import "NTAUserInfo.h"
#import "NTALoginHandler.h"
#import "NTALogger.h"

@interface CommunicationsManager()
@property (nonatomic, nonnull, readwrite) NXMClient *client;
@end

@implementation CommunicationsManager

+ (nonnull CommunicationsManager *)sharedInstance {
    
    static CommunicationsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [CommunicationsManager new];
    });
    
    return sharedInstance;
}

+ (void)setLogger {
    [NXMLogger setLogLevel:NXMLoggerLevelVerbose];
}

#pragma mark - init
- (instancetype)init {
    if(self = [super init]) {        
        //notifications
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(NTADidLoginWithNSNotification:) name:kNTALoginHandlerNotificationNameUserDidLogin object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(NTADidLogoutWithNSNotification:) name:kNTALoginHandlerNotificationNameUserDidLogout object:nil];
        
        if (NTALoginHandler.currentUser) {
            [self setupClientWithUser:NTALoginHandler.currentUser];
            [self login];
        }
    }
    return self;
}

#pragma mark - properties
- (CommunicationsManagerConnectionStatus)connectionStatus {
    if(self.client.connectionStatus == NXMConnectionStatusDisconnected) {
        return CommunicationsManagerConnectionStatusNotConnected;
    }
    
    if(self.client.connectionStatus == NXMConnectionStatusConnecting) {
        return CommunicationsManagerConnectionStatusReconnecting;
    }
        
    return CommunicationsManagerConnectionStatusConnected;
}

#pragma public

+ (NSString *)CommunicationsManagerConnectionStatusReasonToString:(CommunicationsManagerConnectionStatusReason)status {
    switch (status) {
        case CommunicationsManagerConnectionStatusReasonUnknown:
            return @"ReasonUnknown";
        case CommunicationsManagerConnectionStatusReasonLogin:
            return @"ReasonLogin";
        case CommunicationsManagerConnectionStatusReasonLogout:
            return @"ReasonLogout";
        case CommunicationsManagerConnectionStatusReasonTokenInvalid:
            return @"ReasonTokenInvalid";
        case CommunicationsManagerConnectionStatusReasonTokenExpired:
            return @"ReasonTokenExpired";
        case CommunicationsManagerConnectionStatusReasonSessionInvalid:
            return @"ReasonSessionInvalid";
        case CommunicationsManagerConnectionStatusReasonMaxSessions:
            return @"ReasonMaxSessions";
        case CommunicationsManagerConnectionStatusReasonSessionTerminated:
            return @"ReasonSessionTerminated";
        default:
            break;
    }
    
    return @"invalid reason";
}

- (void)enablePushNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
                                     isPushKit:(BOOL)isPushKit
                                     isSandbox:(BOOL)isSandbox
                                    completion:(void(^_Nullable)(NSError * _Nullable error))completion {
    [self.client enablePushNotificationsWithDeviceToken:deviceToken
                                              isPushKit:isPushKit
                                              isSandbox:isSandbox
                                      completionHandler:completion];
}

- (void)disablePushNotificationsWithCompletion:(void(^_Nullable)(NSError * _Nullable error))completion {
    [self.client disablePushNotifications:completion];
}

- (BOOL)isClientPushWithUserInfo:(nonnull NSDictionary *)userInfo {
    return [self.client isNexmoPushWithUserInfo:userInfo];
}

- (void)processClientPushWithUserInfo:(nonnull NSDictionary *)userInfo
                           completion:(void(^_Nullable)(NSError * _Nullable error))completion {
    [self.client processNexmoPushWithUserInfo:userInfo
                            completionHandler:completion];
}

#pragma mark - post notifications

- (void)didChangeConnectionStatus:(CommunicationsManagerConnectionStatus)connectionStatus WithReason:(CommunicationsManagerConnectionStatusReason)reason {
    NSDictionary *userInfo = @{
                               kNTACommunicationsManagerNotificationKeyConnectionStatus:@(connectionStatus),
                               kNTACommunicationsManagerNotificationKeyConnectionStatusReason: @(reason)
                               };
    [NSNotificationCenter.defaultCenter postNotificationName:kNTACommunicationsManagerNotificationNameConnectionStatus object:nil userInfo:userInfo];
}

- (void)didgetIncomingCall:(NXMCall *)call {
    NSDictionary *userInfo = @{
                               kNTACommunicationsManagerNotificationKeyIncomingCall:call
                               };
    [NSNotificationCenter.defaultCenter postNotificationName:kNTACommunicationsManagerNotificationNameIncomingCall object:nil userInfo:userInfo];
}

#pragma mark - stitchClientDelegate

- (void)client:(nonnull NXMClient *)client didChangeConnectionStatus:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason {
    [self didChangeConnectionStatus:self.connectionStatus WithReason:[self connectionStatusReasonWithLoginStatus:reason]];
}

- (CommunicationsManagerConnectionStatusReason)connectionStatusReasonWithLoginStatus:(NXMConnectionStatusReason)statusReason {
    CommunicationsManagerConnectionStatusReason reason = CommunicationsManagerConnectionStatusReasonUnknown;
    

    switch (statusReason) {
        case NXMConnectionStatusReasonTerminated:
            reason = CommunicationsManagerConnectionStatusReasonSessionInvalid;
            break;
        case NXMConnectionStatusReasonTokenInvalid:
            reason = CommunicationsManagerConnectionStatusReasonTokenInvalid;
            break;
            case NXMConnectionStatusReasonTokenExpired:
            reason = CommunicationsManagerConnectionStatusReasonTokenExpired;
            break;
        default:
            break;
    }
    
    return reason;
}


- (void)tokenRefreshed {
    //TODO: add to observer
}

- (void)client:(nonnull NXMClient *)client didReceiveCall:(nonnull NXMCall *)call {
    [NTALogger info:@"Communications Manager - Nexmo Client incoming call"];
    [self didgetIncomingCall:call];
}

- (void)client:(nonnull NXMClient *)client didReceiveConversation:(nonnull NXMConversation *)conversation {
    
}

- (void)client:(nonnull NXMClient *)client didReceiveError:(nonnull NSError *)error {
    
}




#pragma mark - LoginHandler notifications
- (void)NTADidLoginWithNSNotification:(NSNotification *)note {
    NTAUserInfo *user = note.userInfo[kNTALoginHandlerNotificationKeyUser];
    [self setupClientWithUser:user];
}

- (void)NTADidLogoutWithNSNotification:(NSNotification *)note {
    [self logout];
}

- (void)login {
    //[self.client loginWithAuthToken:(NSString *)authToken];
}

- (void)logout {
    [self.client logout];
}

- (void)setupClientWithUser:(NTAUserInfo *)userInfo {
    if(self.client) { //TODO: this is because creating two clients without holding reference to both creates crashes in miniRTC. change after it is fixed
        return;
    }
    
    self.client = NXMClient.shared;
    [self.client setDelegate:self];
    [self.client loginWithAuthToken:userInfo.csUserToken];
}

@end

