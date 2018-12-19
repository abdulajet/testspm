//
//  NexmoClientWrapper.m
//  NexmoTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//


#import "CommunicationsManager.h"
#import "NTALoginHandler.h"
#import "NTALoginHandlerObserver.h"

NSString * const notificationConnectionStatusName = @"NTACommunicationsManagerConnectionStatus";
NSString * const notificationConnectionStatusKey = @"connectionStatus";
NSString * const notificationConnectionStatusReasonKey = @"connectionStatusReason";

@interface CommunicationsManager() <NTALoginHandlerObserver>
@property (nonatomic, nonnull, readwrite) NXMClient *client;
@end

@implementation CommunicationsManager

+ (nonnull CommunicationsManager *)sharedInstance {
    
    static CommunicationsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CommunicationsManager alloc] initWithNexmoClient:[NXMClient new]];
    });
    
    return sharedInstance;
}

+ (void)setLogger:(id<NXMLoggerDelegate>)delegate {
    [[CommunicationsManager sharedInstance].client setLoggerDelegate:delegate];
}

#pragma mark - init
- (instancetype)initWithNexmoClient:(NXMClient *)client {
    if(self = [super init]) {
        self.client = client;
        [client setDelegate:self];
        [NTALoginHandler subscribeToNotificationsWithObserver:self];
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

#pragma mark - notifications
-(NSArray<id <NSObject>> *)subscribeToNotificationsWithObserver:(NSObject<CommunicationsManagerObserver> *)observer {
    
    id <NSObject> connectionObserver = [self subscribeToConnectionStatusWithObserver:observer];
    
    return @[connectionObserver];
}

-(void)unsubscribeToNotificationsWithObserver:(NSArray<id <NSObject>> *)observers {
    for (id <NSObject> observer in observers) {
        if(observer) {
            [NSNotificationCenter.defaultCenter removeObserver:observer];
        }
    }
}

-(id <NSObject>)subscribeToConnectionStatusWithObserver:(NSObject<CommunicationsManagerObserver> *)observer {
    __weak NSObject<CommunicationsManagerObserver> *weakObserver = observer;
    return [NSNotificationCenter.defaultCenter addObserverForName:notificationConnectionStatusName object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        CommunicationsManagerConnectionStatus connectionStatus = (CommunicationsManagerConnectionStatus)([note.userInfo[notificationConnectionStatusKey] integerValue]);
        CommunicationsManagerConnectionStatusReason connectionStatusReason = (CommunicationsManagerConnectionStatusReason)([note.userInfo[notificationConnectionStatusReasonKey] integerValue]);
        
        if([weakObserver respondsToSelector:@selector(connectionStatusChanged:withReason:)]) {
            [weakObserver connectionStatusChanged:connectionStatus withReason:connectionStatusReason];
        }
    }];
}

- (void)didChangeConnectionStatus:(CommunicationsManagerConnectionStatus)connectionStatus WithReason:(CommunicationsManagerConnectionStatusReason)reason {
    NSDictionary *userInfo = @{
                               notificationConnectionStatusKey:@(connectionStatus),
                               notificationConnectionStatusReasonKey: @(reason)
                               };
    [NSNotificationCenter.defaultCenter postNotificationName:notificationConnectionStatusName object:nil userInfo:userInfo];
}

#pragma mark - stitchClientDelegate
- (void)connectionStatusChanged:(BOOL)isOnline {
    [self didChangeConnectionStatus:self.connectionStatus WithReason:CommunicationsManagerConnectionStatusReasonUnknown];
}

- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error {
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


#pragma mark - LoginHandlerObserver
- (void)NTADidLoginWithUserName:(NSString *)userName {
    [self loginWithUserInfo:NTALoginHandler.currentUser];
}

- (void)NTADidLogoutWithUserName:(NSString *)userName {
    [self logout];
}

- (void)loginWithUserInfo:(NTAUserInfo *)userInfo {
    [self.client loginWithAuthToken:userInfo.csUserToken];
}

- (void)logout {
    [self.client logout];
}

- (void)setupNexmoClient {
    self.client = [NXMClient new];
    [self.client setDelegate:self];
}

@end

