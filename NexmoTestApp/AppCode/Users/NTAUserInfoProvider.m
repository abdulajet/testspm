//
//  NTATokenProvider.m
//  NexmoTestApp
//
//  Created by Chen Lev on 12/9/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NTAUserInfoProvider.h"
#import "NXMTokens.h"
#import "NTAErrors.h"
#import "NTALogger.h"


static NSDictionary<NSString *, NTAUserInfo *> *testAppUsers;
static NSDictionary<NSString *, NSString *> *csUserNameToTestAppUserName;
static NSDictionary<NSString *, NSString *> *csUserNameToCSUserId;
static NSDictionary<NSString *, NSString *> *csUserIdToCSUserName;

@implementation NTAUserInfoProvider
+ (void)initialize {
    if(self == [NTAUserInfoProvider self]) {
        testAppUsers = @{
                         @"testuser1":[[NTAUserInfo alloc] initWithName:@"testuser1" password:@"Vocal123!" displayName:@"Ayelet Levy" csUserName:@"testuser1" csUserId:testUser1UserId csUserToken:testUser1Token],
                         @"testuser2":[[NTAUserInfo alloc] initWithName:@"testuser2" password:@"11111111" displayName:@"Ilana Goldman" csUserName:@"testuser2" csUserId:testUser2UserId csUserToken:testUser2Token],
                         @"testuser3":[[NTAUserInfo alloc] initWithName:@"testuser3" password:@"Aa123456" displayName:@"Tom Barkan" csUserName:@"testuser3" csUserId:testUser3UserId csUserToken:testUser3Token],
                         @"testuser4":[[NTAUserInfo alloc] initWithName:@"testuser4" password:@"@yeLet97" displayName:@"Chen Lev" csUserName:@"testuser4" csUserId:testUser4UserId csUserToken:testUser4Token],
                         @"testuser5":[[NTAUserInfo alloc] initWithName:@"testuser5" password:@"V0n@ge098" displayName:@"Guy Mini" csUserName:@"testuser5" csUserId:testUser5UserId csUserToken:testUser5Token],
                         @"testuser6":[[NTAUserInfo alloc] initWithName:@"testuser6" password:@"Vocal123!" displayName:@"Yonatan Rosenberg" csUserName:@"testuser6" csUserId:testUser6UserId csUserToken:testUser6Token],
                         @"testuser7":[[NTAUserInfo alloc] initWithName:@"testuser7" password:@"12345678" displayName:@"Sagi Cohen" csUserName:@"testuser7" csUserId:testUser7UserId csUserToken:testUser7Token],
                         @"testuser8":[[NTAUserInfo alloc] initWithName:@"testuser8" password:@"Vocal123!" displayName:@"Daniel Levi" csUserName:@"testuser8" csUserId:testUser8UserId csUserToken:testUser8Token],
                         };
        
        csUserNameToTestAppUserName = @{
                                        @"testuser1":@"testuser1",
                                        @"testuser2":@"testuser2",
                                        @"testuser3":@"testuser3",
                                        @"testuser4":@"testuser4",
                                        @"testuser5":@"testuser5",
                                        @"testuser6":@"testuser6",
                                        @"testuser7":@"testuser7",
                                        @"testuser8":@"testuser8"
                                        };
        
        csUserNameToCSUserId = @{
                                 @"testuser1":testUser1UserId,
                                 @"testuser2":testUser2UserId,
                                 @"testuser3":testUser3UserId,
                                 @"testuser4":testUser4UserId,
                                 @"testuser5":testUser5UserId,
                                 @"testuser6":testUser6UserId,
                                 @"testuser7":testUser7UserId,
                                 @"testuser8":testUser8UserId
                                 };
        
        csUserIdToCSUserName = @{
                                 testUser1UserId:@"testuser1",
                                 testUser2UserId:@"testuser2",
                                 testUser3UserId:@"testuser3",
                                 testUser4UserId:@"testuser4",
                                 testUser5UserId:@"testuser5",
                                 testUser6UserId:@"testuser6",
                                 testUser7UserId:@"testuser7",
                                 testUser8UserId:@"testuser8"
                                 };
    }
}

+ (NTAUserInfo *)getDefaultUser {
    return testAppUsers[@"testuser3"];
}

+ (NTAUserInfo *)getRandomUser {
    NSUInteger index = arc4random_uniform((int)testAppUsers.count);
    return testAppUsers[[testAppUsers allKeys][index]];
}

+ (NSArray<NTAUserInfo *> *)getAllUsers {
    return testAppUsers.allValues;
}

+ (NTAUserInfo *)getUserInfoForCSUserName:(nonnull NSString *)csUserName {
    return testAppUsers[[self getUserNameForCSUserName:csUserName]];
}

+ (void)getUserInfoForUserName:(nonnull NSString *)userName
               password:(nonnull NSString *)password
             completion:(void(^_Nullable)(NSError * _Nullable error, NTAUserInfo *userInfo))completion {
    
    if(!completion) {
        [NTALogger errorWithFormat: @"%@ - missing parameter: completion", NSStringFromSelector(_cmd)];
        return;
    }
    
    NTAUserInfo *testAppUser = testAppUsers[userName];
    if(!testAppUser) {
        [NTALogger warningWithFormat: @"%@ - user %@ not found", NSStringFromSelector(_cmd), userName];
        completion([NTAErrors errorWithErrorCode:NXMTestAppErrorCodeTestAppUserNotFound andUserInfo:nil], nil);
        return;
    }
    
    if(![password isEqualToString:testAppUser.password]) {
        [NTALogger warningWithFormat: @"%@ - password for user %@ is not correct", NSStringFromSelector(_cmd), userName];
        completion([NTAErrors errorWithErrorCode:NXMTestAppErrorCodeTestAppPasswordNotCorrect andUserInfo:nil], nil);
        return;
    }
    
    completion(nil, testAppUser);
}

+ (NSString *)getUserNameForCSUserName:(nonnull NSString *)csUserName {
    return csUserNameToTestAppUserName[csUserName];
}

+ (NSString *)getUserDisplayNameForUserName:(NSString *)userName {
    return testAppUsers[userName].displayName;
}
@end
