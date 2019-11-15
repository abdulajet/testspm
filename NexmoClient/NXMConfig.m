//
//  NXMConfig.m
//  NexmoClient
//
//  Created by Nicola Di Pol on 15/11/2019.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMConfig.h"

typedef enum {
    LON, SNG, DAL, WDC
} NXMRegion;


@implementation NXMConfig

- (instancetype)initWithApiUrl:(NSString *)apiURL
                  websocketUrl:(NSString *)websocketUrl
                        ipsUrl:(NSString *)ipsUrl {
    self = [super init];
    if (self) {
        _apiUrl = apiURL;
        _websocketUrl = websocketUrl;
        _ipsUrl = ipsUrl;
    }
    return self;
}

+ (NXMConfig *)LON {
    return [NXMConfig configFor:LON];
}

+ (NXMConfig *)SNG {
    return [NXMConfig configFor:SNG];
}

+ (NXMConfig *)DAL {
    return [NXMConfig configFor:DAL];
}

+ (NXMConfig *)WDC {
    return [NXMConfig configFor:WDC];
}

+ (NXMConfig *)defaultConfiguration {
    return [[NXMConfig alloc] initWithApiUrl:@"https://api.nexmo.com/"
                                websocketUrl:@"https://ws.nexmo.com/"
                                      ipsUrl:@"https://api.nexmo.com/v1/image/"];
}

+ (nonnull NXMConfig *)configFor:(NXMRegion)region {
    return [[NXMConfig alloc] initWithApiUrl:[NXMConfig apiUrlFor:region]
                                websocketUrl:[NXMConfig websocketUrlFor:region]
                                      ipsUrl:[NXMConfig ipsUrlFor:region]];
}

+ (nonnull NSString *)apiUrlFor:(NXMRegion)region {
    switch (region) {
        case LON:
            return @"https://api-eu-1.nexmo.com";
        case SNG:
            return @"https://api-sg-1.nexmo.com";
        case DAL:
            return @"https://api-us-2.nexmo.com";
        case WDC:
            return @"https://api-us-1.nexmo.com";
    }
}

+ (nonnull NSString *)websocketUrlFor:(NXMRegion)region {
    switch (region) {
        case LON:
            return @"https://ws-eu-1.nexmo.com";
        case SNG:
            return @"https://ws-sg-1.nexmo.com";
        case DAL:
            return @"https://ws-us-2.nexmo.com";
        case WDC:
            return @"https://ws-us-1.nexmo.com";
    }
}

+ (nonnull NSString *)ipsUrlFor:(NXMRegion)region {
    return [[NXMConfig apiUrlFor:region] stringByAppendingString:@"/v1/image"];
}

@end
