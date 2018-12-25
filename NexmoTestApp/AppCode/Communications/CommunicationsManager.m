//
//  NexmoClientWrapper.m
//  NexmoTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//


#import "CommunicationsManager.h"
#import "NTAUserInfo.h"
#import "NTALoginHandler.h"

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

+ (void)setLogger:(id<NXMLoggerDelegate>)delegate {
    [[CommunicationsManager sharedInstance].client setLoggerDelegate:delegate];
}

#pragma mark - init
- (instancetype)init {
    if(self = [super init]) {
        [self setupClient];
        
        //notifications
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(NTADidLoginWithNSNotification:) name:kNTALoginHandlerNotificationNameUserDidLogin object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(NTADidLogoutWithNSNotification:) name:kNTALoginHandlerNotificationNameUserDidLogout object:nil];
        
        if(NTALoginHandler.currentUser) {
            [self loginWithUserInfo:NTALoginHandler.currentUser];
        }
    }
    return self;
}

#pragma mark - properties
- (CommunicationsManagerConnectionStatus)connectionStatus {
    if(!self.client.isLoggedIn) {
        return CommunicationsManagerConnectionStatusNotConnected;
    }
    
    if(!self.client.isConnected) {
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
    [self.client enablePushNotificationsWithDeviceToken:deviceToken isPushKit:isPushKit
                                              isSandbox:isSandbox completion:completion];
}

- (void)disablePushNotificationsWithCompletion:(void(^_Nullable)(NSError * _Nullable error))completion {
    [self.client disablePushNotificationsWithCompletion:completion];
}

- (BOOL)isClientPushWithUserInfo:(nonnull NSDictionary *)userInfo {
    return [self.client isNexmoPushWithUserInfo:userInfo];
}

- (void)processClientPushWithUserInfo:(nonnull NSDictionary *)userInfo
                           completion:(void(^_Nullable)(NSError * _Nullable error))completion {
    [self.client processNexmoPushWithUserInfo:userInfo completion:completion];
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
- (void)connectionStatusChanged:(BOOL)isOnline {
    [self didChangeConnectionStatus:self.connectionStatus WithReason:CommunicationsManagerConnectionStatusReasonUnknown];
}

- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error {
    if(!isLoggedIn) {
        [self setupClient];
    }
    
    [self didChangeConnectionStatus:self.connectionStatus WithReason:[self connectionStatusReasonWithLoginStatus:isLoggedIn andError:error]];
}

- (CommunicationsManagerConnectionStatusReason)connectionStatusReasonWithLoginStatus:(BOOL)loginStatus andError:(NSError *)error {
    CommunicationsManagerConnectionStatusReason reason = CommunicationsManagerConnectionStatusReasonUnknown;
    
    if(!error) {
        reason = loginStatus ? CommunicationsManagerConnectionStatusReasonLogin : CommunicationsManagerConnectionStatusReasonLogout;
    } else {
        switch (error.code) {
            case NXMErrorCodeSessionInvalid:
                reason = CommunicationsManagerConnectionStatusReasonSessionInvalid;
                break;
            case NXMErrorCodeMaxOpenedSessions:
                reason = CommunicationsManagerConnectionStatusReasonMaxSessions;
                break;
            case NXMErrorCodeTokenInvalid:
                reason = CommunicationsManagerConnectionStatusReasonTokenInvalid;
                break;
                case NXMErrorCodeTokenExpired:
                reason = CommunicationsManagerConnectionStatusReasonTokenExpired;
                break;
            default:
                break;
        }
    }
    
    return reason;
}


- (void)tokenRefreshed {
    //TODO: add to observer
}

- (void)incomingCall:(nonnull NXMCall *)call {
    [self didgetIncomingCall:call];
}

- (void)addedToConversation:(nonnull NXMConversation *)conversation {
    
}

#pragma mark - LoginHandler notifications
- (void)NTADidLoginWithNSNotification:(NSNotification *)note {
    NTAUserInfo *user = note.userInfo[kNTALoginHandlerNotificationKeyUser];
    [self loginWithUserInfo:user];
}

- (void)NTADidLogoutWithNSNotification:(NSNotification *)note {
    [self logout];
}

- (void)loginWithUserInfo:(NTAUserInfo *)userInfo {
    [self.client loginWithAuthToken:userInfo.csUserToken];
}

- (void)logout {
    [self.client logout];
}

- (void)setupClient {
    [self setupWithNexmoClient:[NXMClient new]];
}

- (void)setupWithNexmoClient:(NXMClient *)client {
    self.client = client;
    [self.client setDelegate:self];
}

@end

