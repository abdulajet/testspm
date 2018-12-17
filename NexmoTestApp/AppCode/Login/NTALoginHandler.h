//
//  NTALoginHandler.h
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/13/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTALoginHandlerObserver.h"
#import "NTAUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface NTALoginHandler : NSObject
+ (NTAUserInfo *)currentUser;

+ (void)loginCurrentUserWithCompletion:(void(^_Nullable)(NSError * _Nullable error, NTAUserInfo *userInfo))completion;

+ (void)loginWithUserName:(NSString *)userName andPassword:(NSString *)password completion:(void(^_Nullable)(NSError * _Nullable error, NTAUserInfo *userInfo))completion;

+ (void)logout;

+ (NSArray<id <NSObject>> *)subscribeToNotificationsWithObserver:(NSObject<NTALoginHandlerObserver> *)observer;

+ (void)unsubscribeToNotificationsWithObserver:(NSArray<id <NSObject>> *)observers;

@end

NS_ASSUME_NONNULL_END
