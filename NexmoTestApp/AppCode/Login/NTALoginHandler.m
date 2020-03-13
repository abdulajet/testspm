//
//  NTALoginHandler.m
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/13/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NTALogger.h"
#import "NTAErrors.h"
#import "CommunicationsManager.h"
#import "AppDelegate.h"
#import "NTALoginHandler.h"

static NSString *_currentUser;
static NSString *_currentToken;
static BOOL _registeredForNexmoPushNotifications;

@implementation NTALoginHandler
#pragma mark - initialize
+(void)initialize {
    if(self != [NTALoginHandler self]) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self loadStateFromUserDefaults:defaults];
    
    //notifications
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(connectionStatusChangedWithNSNotification:) name:kNTACommunicationsManagerNotificationNameConnectionStatus object:nil];
}

+ (void)loadStateFromUserDefaults:(NSUserDefaults *)userDefaults {
    [self loadCurrentUserWithUserDefaults:userDefaults];
    [self loadPushRegistrationWithUserDefaults:userDefaults];
}

+ (void)loadCurrentUserWithUserDefaults:(NSUserDefaults *)defaults {
    if([defaults objectForKey:kNTALoginHandlerCurrentUserNamePreferencesKey]) {
        _currentUser = [defaults stringForKey:kNTALoginHandlerCurrentUserNamePreferencesKey];
        _currentToken = [defaults stringForKey:kNTALoginHandlerCurrentUserTokenPreferencesKey];
        
    }
}

+ (void)loadPushRegistrationWithUserDefaults:(NSUserDefaults *)defaults {
    _registeredForNexmoPushNotifications = [defaults objectForKey:kNTALoginHandlerDidRegisterForNexmoPushPreferencesKey] ? YES : NO;
}


+ (NSString *)currentUser {
    return _currentUser;
}

+ (NSString *)currentToken {
    return _currentToken;
}

+ (void)loginCurrentUserWithCompletion:(void(^_Nullable)(NSError * _Nullable error, NSString *username))completion {
    NSString *user = [self currentUser];
    if(!user) {
        [NTALogger error:@"NTALoginHandler failed login. loginCurrentUser called with no current user available"];
        NSError *error = [NTAErrors errorWithErrorCode:NXMTestAppErrorCodeTestAppCurrentUserNotFound andUserInfo:nil];
        if(completion) {
            completion(error, nil);
        }
    }
    
    [self loginWithUserName:_currentUser completion:^(NSError * _Nullable error, NSString *username) {
        completion(error, username);
    
        if (!error && _currentToken) {
            [CommunicationsManager.sharedInstance loginWithUserToken:_currentToken];
        }
    }];
}

+ (void)loginWithUserName:(NSString *)userName completion:(void(^_Nullable)(NSError * _Nullable error, NSString *userInfo))completion {
    [self setCurrentUserWithUserName:userName];

    [NSNotificationCenter.defaultCenter postNotificationName:kNTALoginHandlerNotificationNameUserDidLogin object:nil userInfo:@{@"username":self.currentUser}];

    completion(nil, _currentUser);
   
}

+ (void)logoutWithCompletion:(void(^_Nullable)(NSError * _Nullable error))completion {
    NSString *currentUser = [[self currentUser] copy];
    [self removeCurrentUser];
    [NSNotificationCenter.defaultCenter postNotificationName:kNTALoginHandlerNotificationNameUserDidLogout object:nil userInfo:@{kNTALoginHandlerNotificationKeyUser : currentUser}];
    
    if(_registeredForNexmoPushNotifications) {
        [self setNexmoPushRegistrationState:FALSE];
    }
    
    if(completion) {
        completion(nil);
    }
}

#pragma mark - Private
+ (void)removeCurrentUser {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences removeObjectForKey:kNTALoginHandlerCurrentUserNamePreferencesKey];
    _currentUser = nil;
}

+ (void)setCurrentUserWithUserName:(NSString *)userName  {
    _currentUser = userName;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults  setObject:userName forKey:kNTALoginHandlerCurrentUserNamePreferencesKey];
    const BOOL didSave = [userDefaults synchronize];
    if(!didSave) {
        [NTALogger errorWithFormat:@"Failed saving User %@  in userDefaults", userName];
    }
}

#pragma mark nexmo push
+ (void)setNexmoPushRegistrationState:(BOOL)state {
    _registeredForNexmoPushNotifications = state;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if(state) {
        [userDefaults setObject:@(_registeredForNexmoPushNotifications) forKey:kNTALoginHandlerDidRegisterForNexmoPushPreferencesKey];
    } else {
        [userDefaults removeObjectForKey:kNTALoginHandlerDidRegisterForNexmoPushPreferencesKey];
    }
    
    const BOOL didSave = [userDefaults synchronize];
    if(!didSave) {
        [NTALogger errorWithFormat:@"Failed saving nexmo push state %@ in userDefaults", state];
    }
}

+ (void)disableNexmoPushWithCompletion:(void(^_Nullable)(NSError * _Nullable error))completion {
    [CommunicationsManager.sharedInstance disablePushNotificationsWithCompletion:^(NSError * _Nullable error) {
        if(error) {
            NSString *errorString  = [NSString stringWithFormat:@"Failed disabling Nexmo push with error: %@", error];
            [NTALogger error:errorString];
            
            if(completion) {
                completion([NTAErrors errorWithErrorCode:NXMTestAppErrorCodeFailedDisablingPush andUserInfo:nil]);
            }
            
            return;
        }
        
        [self setNexmoPushRegistrationState:FALSE];
        
        if(completion) {
            completion(nil);
        }
    }];
}

+ (void)connectionStatusChangedWithNSNotification:(NSNotification *)note {
    // TODO...
}

@end
