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
                         
                         @"baby1":[[NTAUserInfo alloc] initWithName:@"baby1" password:@"Vocal123!" displayName:@"Ayelet Baby" csUserName:@"baby1" csUserId:baby1UserId csUserToken:baby1Token],
                         @"baby2":[[NTAUserInfo alloc] initWithName:@"baby2" password:@"Vocal123!" displayName:@"Shay Naftali" csUserName:@"baby2" csUserId:baby2UserId csUserToken:baby2Token],
                         @"baby3":[[NTAUserInfo alloc] initWithName:@"baby3" password:@"Vocal123!" displayName:@"Tomer Shmueli" csUserName:@"baby3" csUserId:baby3UserId csUserToken:baby3Token],
                         @"baby4":[[NTAUserInfo alloc] initWithName:@"baby4" password:@"Vocal123!" displayName:@"Matan Morano" csUserName:@"baby4" csUserId:baby4UserId csUserToken:baby4Token],
                         @"baby5":[[NTAUserInfo alloc] initWithName:@"baby5" password:@"Vocal123!" displayName:@"Edden Bitton" csUserName:@"baby5" csUserId:baby5UserId csUserToken:baby5Token],
                         
                         @"demo1":[[NTAUserInfo alloc] initWithName:@"demo1" password:@"Vocal123!" displayName:@"Brad Pitt" csUserName:@"demo1" csUserId:demo1UserId csUserToken:demo1Token],
                         @"demo2":[[NTAUserInfo alloc] initWithName:@"demo2" password:@"Vocal123!" displayName:@"Ron Shofman" csUserName:@"demo2" csUserId:demo2UserId csUserToken:demo2Token],
                         @"demo3":[[NTAUserInfo alloc] initWithName:@"demo3" password:@"Vocal123!" displayName:@"Doron Madali" csUserName:@"demo3" csUserId:demo3UserId csUserToken:demo3Token],
                         @"demo4":[[NTAUserInfo alloc] initWithName:@"demo4" password:@"Vocal123!" displayName:@"Erez Tal" csUserName:@"demo4" csUserId:demo4UserId csUserToken:demo4Token],
                         @"demo5":[[NTAUserInfo alloc] initWithName:@"demo5" password:@"Vocal123!" displayName:@"Asi Azar" csUserName:@"demo5" csUserId:demo5UserId csUserToken:demo5Token]
                         };
        
        csUserNameToTestAppUserName = @{
                                        @"testuser1":@"testuser1",
                                        @"testuser2":@"testuser2",
                                        @"testuser3":@"testuser3",
                                        @"testuser4":@"testuser4",
                                        @"testuser5":@"testuser5",
                                        @"testuser6":@"testuser6",
                                        @"testuser7":@"testuser7",
                                        @"testuser8":@"testuser8",
                                        @"baby1":@"baby1",
                                        @"baby2":@"baby2",
                                        @"baby3":@"baby3",
                                        @"baby4":@"baby4",
                                        @"baby5":@"baby5",
                                        @"demo1":@"demo1",
                                        @"demo2":@"demo2",
                                        @"demo3":@"demo3",
                                        @"demo4":@"demo4",
                                        @"demo5":@"demo5"
                                        };
        
        csUserNameToCSUserId = @{
                                 @"testuser1":testUser1UserId,
                                 @"testuser2":testUser2UserId,
                                 @"testuser3":testUser3UserId,
                                 @"testuser4":testUser4UserId,
                                 @"testuser5":testUser5UserId,
                                 @"testuser6":testUser6UserId,
                                 @"testuser7":testUser7UserId,
                                 @"testuser8":testUser8UserId,
                                 @"baby1":baby1UserId,
                                 @"baby2":baby2UserId,
                                 @"baby3":baby3UserId,
                                 @"baby4":baby4UserId,
                                 @"baby5":baby5UserId,
                                 @"demo1":demo1UserId,
                                 @"demo2":demo2UserId,
                                 @"demo3":demo3UserId,
                                 @"demo4":demo4UserId,
                                 @"demo5":demo5UserId
                                 };
        
        csUserIdToCSUserName = @{
                                 testUser1UserId:@"testuser1",
                                 testUser2UserId:@"testuser2",
                                 testUser3UserId:@"testuser3",
                                 testUser4UserId:@"testuser4",
                                 testUser5UserId:@"testuser5",
                                 testUser6UserId:@"testuser6",
                                 testUser7UserId:@"testuser7",
                                 testUser8UserId:@"testuser8",
                                 baby1UserId:@"baby1",
                                 baby2UserId:@"baby2",
                                 baby3UserId:@"baby3",
                                 baby4UserId:@"baby4",
                                 baby5UserId:@"baby5",
                                 demo1UserId:@"demo1",
                                 demo2UserId:@"demo2",
                                 demo3UserId:@"demo3",
                                 demo4UserId:@"demo4",
                                 demo5UserId:@"demo5"
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
