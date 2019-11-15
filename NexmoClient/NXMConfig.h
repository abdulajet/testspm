//
//  NXMConfig.h
//  NexmoClient
//
//  Created by Nicola Di Pol on 15/11/2019.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXMConfig : NSObject

@property (nonnull, nonatomic, readonly) NSString *apiUrl;
@property (nonnull, nonatomic, readonly) NSString *websocketUrl;
@property (nonnull, nonatomic, readonly) NSString *ipsUrl;

- (nonnull instancetype)initWithApiUrl:(nonnull NSString *)apiURL
                          websocketUrl:(nonnull NSString *)websocketUrl
                                ipsUrl:(nonnull NSString *)ipsUrl;

+ (nonnull NXMConfig *)LON;
+ (nonnull NXMConfig *)SNG;
+ (nonnull NXMConfig *)DAL;
+ (nonnull NXMConfig *)WDC;

+ (nonnull NXMConfig *)defaultConfiguration;

@end
