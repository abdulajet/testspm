//
//  NXMTestAppUserInfo.h
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTAUserInfo : NSObject <NSCopying>
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *displayName;
@property (nonatomic) NSString *initials;
@property (nonatomic) NSString *csUserName;
@property (nonatomic) NSString *csUserId;
@property (nonatomic) NSString *csUserToken;
-(instancetype)initWithName:(NSString *)name password:(NSString *)password displayName:(NSString *)displayName csUserName:(NSString *)csUserName csUserId:(NSString *)csUserId csUserToken:(NSString *)csUserToken;
@end

NS_ASSUME_NONNULL_END
