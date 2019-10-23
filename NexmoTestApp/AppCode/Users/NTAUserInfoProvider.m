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
                         @"testuser1":[[NTAUserInfo alloc] initWithName:@"testuser1" password:@"Vocal123!" displayName:@"Ayelet Levy" csUserName:@"testuser1" csUserId:testuser1UserId csUserToken:testuser1Token userGroup:@"testUser"],
                         @"testuser2":[[NTAUserInfo alloc] initWithName:@"testuser2" password:@"Vocal123!" displayName:@"Ilana Goldman" csUserName:@"testuser2" csUserId:testuser2UserId csUserToken:testuser2Token  userGroup:@"testUser"],
                         @"testuser3":[[NTAUserInfo alloc] initWithName:@"testuser3" password:@"Vocal123!" displayName:@"Tom Barkan" csUserName:@"testuser3" csUserId:testuser3UserId csUserToken:testuser3Token userGroup:@"testUser"],
                         @"testuser4":[[NTAUserInfo alloc] initWithName:@"testuser4" password:@"Vocal123!" displayName:@"Chen Lev" csUserName:@"testuser4" csUserId:testuser4UserId csUserToken:testuser4Token userGroup:@"testUser"],
                         @"testuser5":[[NTAUserInfo alloc] initWithName:@"testuser5" password:@"Vocal123!" displayName:@"Guy Mini" csUserName:@"testuser5" csUserId:testuser5UserId csUserToken:testuser5Token userGroup:@"testUser"],
                         @"testuser6":[[NTAUserInfo alloc] initWithName:@"testuser6" password:@"Vocal123!" displayName:@"Yonatan Rosenberg" csUserName:@"testuser6" csUserId:testuser6UserId csUserToken:testuser6Token userGroup:@"testUser"],
                         @"testuser7":[[NTAUserInfo alloc] initWithName:@"testuser7" password:@"Vocal123!" displayName:@"Sagi Cohen" csUserName:@"testuser7" csUserId:testuser7UserId csUserToken:testuser7Token userGroup:@"testUser"],
                         @"testuser8":[[NTAUserInfo alloc] initWithName:@"testuser8" password:@"Vocal123!" displayName:@"Daniel Levi" csUserName:@"testuser8" csUserId:testuser8UserId csUserToken:testuser8Token userGroup:@"testUser"],
                         
                         @"baby1":[[NTAUserInfo alloc] initWithName:@"baby1" password:@"Vocal123!" displayName:@"Ayelet Baby" csUserName:@"baby1" csUserId:baby1UserId csUserToken:baby1Token userGroup:@"baby"],
                         @"baby2":[[NTAUserInfo alloc] initWithName:@"baby2" password:@"Vocal123!" displayName:@"Shay Naftali" csUserName:@"baby2" csUserId:baby2UserId csUserToken:baby2Token userGroup:@"baby"],
                         @"baby3":[[NTAUserInfo alloc] initWithName:@"baby3" password:@"Vocal123!" displayName:@"Tomer Shmueli" csUserName:@"baby3" csUserId:baby3UserId csUserToken:baby3Token userGroup:@"baby"],
                         @"baby4":[[NTAUserInfo alloc] initWithName:@"baby4" password:@"Vocal123!" displayName:@"Matan Morano" csUserName:@"baby4" csUserId:baby4UserId csUserToken:baby4Token userGroup:@"baby"],
                         @"baby5":[[NTAUserInfo alloc] initWithName:@"baby5" password:@"Vocal123!" displayName:@"Edden Bitton" csUserName:@"baby5" csUserId:baby5UserId csUserToken:baby5Token userGroup:@"baby"],
                         
                         @"demo1":[[NTAUserInfo alloc] initWithName:@"demo1" password:@"Vocal123!" displayName:@"Brad Pitt" csUserName:@"demo1" csUserId:demo1UserId csUserToken:demo1Token userGroup:@"demo"],
                         @"demo2":[[NTAUserInfo alloc] initWithName:@"demo2" password:@"Vocal123!" displayName:@"Ron Shofman" csUserName:@"demo2" csUserId:demo2UserId csUserToken:demo2Token userGroup:@"demo"],
                         @"demo3":[[NTAUserInfo alloc] initWithName:@"demo3" password:@"Vocal123!" displayName:@"Doron Madali" csUserName:@"demo3" csUserId:demo3UserId csUserToken:demo3Token userGroup:@"demo"],
                         @"demo4":[[NTAUserInfo alloc] initWithName:@"demo4" password:@"Vocal123!" displayName:@"Erez Tal" csUserName:@"demo4" csUserId:demo4UserId csUserToken:demo4Token userGroup:@"demo"],
                         @"demo5":[[NTAUserInfo alloc] initWithName:@"demo5" password:@"Vocal123!" displayName:@"Asi Azar" csUserName:@"demo5" csUserId:demo5UserId csUserToken:demo5Token userGroup:@"demo"]
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
                                 @"testuser1":testuser1UserId,
                                 @"testuser2":testuser2UserId,
                                 @"testuser3":testuser3UserId,
                                 @"testuser4":testuser4UserId,
                                 @"testuser5":testuser5UserId,
                                 @"testuser6":testuser6UserId,
                                 @"testuser7":testuser7UserId,
                                 @"testuser8":testuser8UserId,
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
                                 testuser1UserId:@"testuser1",
                                 testuser2UserId:@"testuser2",
                                 testuser3UserId:@"testuser3",
                                 testuser4UserId:@"testuser4",
                                 testuser5UserId:@"testuser5",
                                 testuser6UserId:@"testuser6",
                                 testuser7UserId:@"testuser7",
                                 testuser8UserId:@"testuser8",
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


+ (NTAUserInfo *)getRandomUserForTestGroup {
    return [self getRandomUserForGroup:@"testUser"];
}

+ (NTAUserInfo *)getRandomUserForBabyGroup {
    return [self getRandomUserForGroup:@"baby"];
}

+ (NTAUserInfo *)getRandomUserForDemoGroup {
    return [self getRandomUserForGroup:@"demo"];
}

+ (NTAUserInfo *)getRandomUserForGroup:(NSString *)group {
    NSArray<NTAUserInfo *> *groupedUsers = [self getAllUsersForGroup:group];
    NSUInteger index = arc4random_uniform((int)groupedUsers.count);
    return groupedUsers[index];
}

+ (NSArray<NTAUserInfo *> *)getAllUsersWithRequestingUser:(NTAUserInfo *)requestingUser {
    return [self getAllUsersForGroup:requestingUser.userGroup];
}

+ (NSArray<NTAUserInfo *> *)getAllUsersForGroup:(NSString *)group {
    NSMutableArray<NTAUserInfo *> *groupedUsers = [NSMutableArray new];
    for (NSString *key in testAppUsers.allKeys) {
        if([testAppUsers[key].userGroup isEqualToString:group]) {
            [groupedUsers addObject:testAppUsers[key]];
        }
    }
    
    return groupedUsers;
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

