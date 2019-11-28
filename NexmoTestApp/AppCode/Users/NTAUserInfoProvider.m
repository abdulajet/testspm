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


static NSMutableDictionary<NSString *, NTAUserInfo *> *testAppUsersMutable;
static NSMutableDictionary<NSString *, NSString *> *csUserNameToTestAppUserNameMutable;
static NSMutableDictionary<NSString *, NSString *> *csUserNameToCSUserIdMutable;
static NSMutableDictionary<NSString *, NSString *> *csUserIdToCSUserNameMutable;

@implementation NTAUserInfoProvider
+ (void)initialize {
    if(self == [NTAUserInfoProvider self]) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"users" ofType:@"plist"];
        NSDictionary *appsHardCodedDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSArray* pUsersIds = (NSArray*)(appsHardCodedDict[@"users_ids"]);
        NSArray* pUsersNames = (NSArray*)(appsHardCodedDict[@"users_names"]);
        NSArray* pUsersTokens = (NSArray*)(appsHardCodedDict[@"users_tokens"]);
        testAppUsersMutable = [[NSMutableDictionary alloc] init];
        csUserNameToTestAppUserNameMutable = [[NSMutableDictionary alloc] init];
        csUserNameToCSUserIdMutable = [[NSMutableDictionary alloc] init];
        csUserIdToCSUserNameMutable = [[NSMutableDictionary alloc] init];
        for (int i = 0 ; i < [pUsersIds count] ; i++){
            [testAppUsersMutable setObject:[[NTAUserInfo alloc] initWithName:pUsersNames[i] password:@"Vocal123!" displayName:pUsersNames[i] csUserName:pUsersNames[i] csUserId:pUsersIds[i] csUserToken:pUsersTokens[i] userGroup:@"testUser"] forKey:pUsersNames[i]];
            [csUserNameToTestAppUserNameMutable setObject:pUsersNames[i] forKey:pUsersNames[i]];
            [csUserNameToCSUserIdMutable setObject:pUsersIds[i] forKey:pUsersNames[i]];
            [csUserIdToCSUserNameMutable setObject:pUsersNames[i] forKey:pUsersIds[i]];
        }
    }
}

+ (NTAUserInfo *)getDefaultUser {
    return testAppUsersMutable[@"testuser3"];
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
    for (NSString *key in testAppUsersMutable.allKeys) {
        if([testAppUsersMutable[key].userGroup isEqualToString:group]) {
            [groupedUsers addObject:testAppUsersMutable[key]];
        }
    }
    
    return groupedUsers;
}

+ (NTAUserInfo *)getUserInfoForCSUserName:(nonnull NSString *)csUserName {
    return testAppUsersMutable[[self getUserNameForCSUserName:csUserName]];
}

+ (void)getUserInfoForUserName:(nonnull NSString *)userName
                      password:(nonnull NSString *)password
                    completion:(void(^_Nullable)(NSError * _Nullable error, NTAUserInfo *userInfo))completion {
    
    if(!completion) {
        [NTALogger errorWithFormat: @"%@ - missing parameter: completion", NSStringFromSelector(_cmd)];
        return;
    }
    
    NTAUserInfo *testAppUser = testAppUsersMutable[userName];
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
    return csUserNameToTestAppUserNameMutable[csUserName];
}

+ (NSString *)getUserDisplayNameForUserName:(NSString *)userName {
    return testAppUsersMutable[userName].displayName;
}
@end

