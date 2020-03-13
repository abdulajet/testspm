//
//  NTALoginHandler.h
//  NexmoTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTALoginHandlerDefine.h"

NS_ASSUME_NONNULL_BEGIN


@interface NTALoginHandler : NSObject

+ (NSString*) currentUser;

+ (NSString*) currentToken;

+ (void)loginCurrentUserWithCompletion:(void(^_Nullable)(NSError * _Nullable error, NSString *username))completion;

+ (void)loginWithUserName:(NSString *)userName completion:(void(^_Nullable)(NSError * _Nullable error, NSString *userInfo))completion;

+ (void)logoutWithCompletion:(void(^_Nullable)(NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END

