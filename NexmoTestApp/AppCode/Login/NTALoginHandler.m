//
//  NTALoginHandler.m
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/13/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NTALoginHandler.h"
#import "NTAUserInfo.h"
#import "NTAUserInfoProvider.h"
#import "NTALogger.h"
#import "NTAErrors.h"

static NTAUserInfo *_currentUser;
static NSString * const kNTACurrentUserNamePreferencesKey = @"NTACurrentUserName";
static NSString * const kNTACurrentUserPasswordPreferencesKey = @"NTACurrentUserPassword";

NSString *const kNTAUserDidLoginNoticiationName = @"NTADidUserLogin";
NSString *const kNTAUserDidLogoutNoticiationName = @"NTADidUserLogout";
NSString *const kNTAUserLoginNoticiationKey = @"NTAUserName";

@implementation NTALoginHandler
+ (NTAUserInfo *)currentUser {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
        
        if([preferences objectForKey:kNTACurrentUserNamePreferencesKey] && [preferences objectForKey:kNTACurrentUserPasswordPreferencesKey]) {
            NSString *userName = [preferences stringForKey:kNTACurrentUserNamePreferencesKey];
            NSString *password = [preferences stringForKey:kNTACurrentUserPasswordPreferencesKey];
            [NTAUserInfoProvider getUserInfoForUserName:userName password:password completion:^(NSError * _Nullable error, NTAUserInfo *userInfo) {
                if(error) {
                    [NTALogger errorWithFormat:@"User %@ with password %@ saved in preferences is invalid", userName, password];
                    _currentUser = nil;
                }
                
                _currentUser = userInfo;
            }];
        }
    });
    
    return _currentUser;
}

+ (void)loginCurrentUserWithCompletion:(void(^_Nullable)(NSError * _Nullable error, NTAUserInfo *userInfo))completion {
    NTAUserInfo *user = [self currentUser];
    if(!user) {
        [NTALogger error:@"NTALoginHandler failed login. loginCurrentUser called with no current user available"];
        NSError *error = [NTAErrors errorWithErrorCode:NXMTestAppErrorCodeTestAppCurrentUserNotFound andUserInfo:nil];
        if(completion) {
            completion(error, nil);
        }
    }
    
    [self loginWithUserName:user.name andPassword:user.password completion:completion];
}

+ (void)loginWithUserName:(NSString *)userName andPassword:(NSString *)password completion:(void(^_Nullable)(NSError * _Nullable error, NTAUserInfo *userInfo))completion {
    [NTAUserInfoProvider getUserInfoForUserName:userName password:password completion:^(NSError * _Nullable error, NTAUserInfo *userInfo) {
        
        if(error) {
            [NTALogger errorWithFormat:@"NTALoginHandler failed login. User or password is incorrect. Error: %@", error];
            if(completion) {
                completion(error, nil);
            }
            return;
        }
        
        [self setCurrentUserWithUserName:userName password:password andUserInfo:userInfo];
        if(completion) {
            completion(nil, _currentUser);
        }
        
        [NSNotificationCenter.defaultCenter postNotificationName:kNTAUserDidLoginNoticiationName object:nil];
    }];
}

+ (void)logout {
    NSString *currentUserName = [[self currentUser].name copy];
    [self removeCurrentUser];
    [NSNotificationCenter.defaultCenter postNotificationName:kNTAUserDidLogoutNoticiationName object:nil userInfo:@{kNTAUserLoginNoticiationKey : currentUserName}];
}

#pragma mark - Private
+ (void)removeCurrentUser {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences removeObjectForKey:kNTACurrentUserNamePreferencesKey];
    [preferences removeObjectForKey:kNTACurrentUserPasswordPreferencesKey];
    _currentUser = nil;
}

+ (void)setCurrentUserWithUserName:(NSString *)userName password:(NSString *)password andUserInfo:(NTAUserInfo *)userInfo {
    _currentUser = userInfo;
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences  setObject:userName forKey:kNTACurrentUserNamePreferencesKey];
    [preferences setObject:password forKey:kNTACurrentUserPasswordPreferencesKey];
    const BOOL didSave = [preferences synchronize];
    if(!didSave) {
        [NTALogger errorWithFormat:@"Failed saving User %@ with password %@ in preferences", userName, password];
    }
}

#pragma mark notifications
+ (NSArray<id <NSObject>> *)subscribeToNotificationsWithObserver:(NSObject<NTALoginHandlerObserver> *)observer {
    id <NSObject> loginObserver = [self subscribeToLoginWithObserver:observer];
    id <NSObject> logoutObserver = [self subscribeToLogoutWithObserver:observer];
    return @[loginObserver, logoutObserver];
}

+ (void)unsubscribeToNotificationsWithObserver:(NSArray<id <NSObject>> *)observers {
    for (id <NSObject> observer in observers) {
        if(observer) {
            [NSNotificationCenter.defaultCenter removeObserver:observer];
        }
    }
}

+ (id <NSObject>)subscribeToLoginWithObserver:(NSObject<NTALoginHandlerObserver> *)observer {
    __weak NSObject<NTALoginHandlerObserver> *weakObserver = observer;
    return [NSNotificationCenter.defaultCenter addObserverForName:kNTAUserDidLoginNoticiationName object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSString * userName = note.userInfo[kNTAUserLoginNoticiationKey];
        if([weakObserver respondsToSelector:@selector(NTADidLoginWithUserName:)]) {
            [weakObserver NTADidLoginWithUserName:userName];
        }
    }];
}

+ (id <NSObject>)subscribeToLogoutWithObserver:(NSObject<NTALoginHandlerObserver> *)observer {
    __weak NSObject<NTALoginHandlerObserver> *weakObserver = observer;
    return [NSNotificationCenter.defaultCenter addObserverForName:kNTAUserDidLogoutNoticiationName object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSString * userName = note.userInfo[kNTAUserLoginNoticiationKey];
        if([weakObserver respondsToSelector:@selector(NTADidLogoutWithUserName:)]) {
            [weakObserver NTADidLogoutWithUserName:userName];
        }
    }];
}
@end
