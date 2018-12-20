//
//  NTATokenProvider.h
//  NexmoTestApp
//
//  Created by Chen Lev on 12/9/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTAUserInfo.h"

@interface NTAUserInfoProvider : NSObject
+ (NTAUserInfo *)getDefaultUser;
+ (NTAUserInfo *)getRandomUser;
+ (NSArray<NTAUserInfo *> *)getAllUsers;
+ (NTAUserInfo *)getUserInfoForCSUserName:(nonnull NSString *)csUserName;

+ (void)getUserInfoForUserName:(nonnull NSString *)userName
               password:(NSString *)password
             completion:(void(^_Nullable)(NSError * _Nullable error, NTAUserInfo *userInfo))completion;

+ (NSString *)getUserNameForCSUserName:(nonnull NSString *)csUserName;
+ (NSString *)getUserDisplayNameForUserName:(NSString *)userName;
@end


