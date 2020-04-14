//
//  NXMClientConfig.m
//  NexmoClient
//
//  Created by Nicola Di Pol on 15/11/2019.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMClientConfig.h"

typedef NS_ENUM(NSInteger, NXMRegion) {
    NXMRegionLON,
    NXMRegionSNG,
    NXMRegionDAL,
    NXMRegionWDC
};


@implementation NXMClientConfig

- (instancetype)init {
    return [[NXMClientConfig alloc] initWithApiUrl:@"https://api.nexmo.com/"
                                      websocketUrl:@"https://ws.nexmo.com/"
                                            ipsUrl:@"https://api.nexmo.com/v1/image/"
                                     iceServerUrls:[NXMClientConfig defaultIceServerUrls]
                              useFirstIceCandidate:NO];
}

- (instancetype)initWithApiUrl:(NSString *)apiURL
                  websocketUrl:(NSString *)websocketUrl
                        ipsUrl:(NSString *)ipsUrl{
    return [[NXMClientConfig alloc] initWithApiUrl:apiURL
                                      websocketUrl:websocketUrl
                                            ipsUrl:ipsUrl
                                     iceServerUrls:[NXMClientConfig defaultIceServerUrls]
                              useFirstIceCandidate:NO];
}

- (nonnull instancetype)initWithApiUrl:(nonnull NSString *)apiURL
                          websocketUrl:(nonnull NSString *)websocketUrl
                                ipsUrl:(nonnull NSString *)ipsUrl
                         iceServerUrls:(nonnull NSArray<NSString *> *)iceServerUrls {
    return [[NXMClientConfig alloc] initWithApiUrl:apiURL
                                      websocketUrl:websocketUrl
                                            ipsUrl:ipsUrl
                                     iceServerUrls:iceServerUrls
                              useFirstIceCandidate:NO];
}

- (instancetype)initWithApiUrl:(nonnull NSString *)apiURL
                  websocketUrl:(nonnull NSString *)websocketUrl
                        ipsUrl:(nonnull NSString *)ipsUrl
          useFirstIceCandidate:(BOOL) useFirstIceCandidate {
    return [[NXMClientConfig alloc] initWithApiUrl:apiURL
                                      websocketUrl:websocketUrl
                                            ipsUrl:ipsUrl
                                     iceServerUrls:[NXMClientConfig defaultIceServerUrls]
                              useFirstIceCandidate:useFirstIceCandidate];
}

- (instancetype)initWithApiUrl:(NSString *)apiURL
                  websocketUrl:(NSString *)websocketUrl
                        ipsUrl:(NSString *)ipsUrl
                 iceServerUrls:(nonnull NSArray<NSString *> *)iceServerUrls
          useFirstIceCandidate:(BOOL) useFirstIceCandidate {
    
    self = [super init];
    if (self) {
        _apiUrl = apiURL;
        _websocketUrl = websocketUrl;
        _ipsUrl = ipsUrl;
        _iceServerUrls = iceServerUrls;
        _useFirstIceCandidate = useFirstIceCandidate;
    }
    return self;
}


+ (NXMClientConfig *)LON {
    return [NXMClientConfig configFor:NXMRegionLON];
}

+ (NXMClientConfig *)SNG {
    return [NXMClientConfig configFor:NXMRegionSNG];
}

+ (NXMClientConfig *)DAL {
    return [NXMClientConfig configFor:NXMRegionDAL];
}

+ (NXMClientConfig *)WDC {
    return [NXMClientConfig configFor:NXMRegionWDC];
}

+ (nonnull NXMClientConfig *)configFor:(NXMRegion)region {
    return [[NXMClientConfig alloc] initWithApiUrl:[NXMClientConfig apiUrlFor:region]
                                      websocketUrl:[NXMClientConfig websocketUrlFor:region]
                                            ipsUrl:[NXMClientConfig ipsUrlFor:region]
                                     iceServerUrls:[NXMClientConfig defaultIceServerUrls]];
}

+ (nonnull NSString *)apiUrlFor:(NXMRegion)region {
    switch (region) {
        case NXMRegionLON:
            return @"https://api-eu-1.nexmo.com/";
        case NXMRegionSNG:
            return @"https://api-sg-1.nexmo.com/";
        case NXMRegionDAL:
            return @"https://api-us-2.nexmo.com/";
        case NXMRegionWDC:
            return @"https://api-us-1.nexmo.com/";
    }
}

+ (nonnull NSString *)websocketUrlFor:(NXMRegion)region {
    switch (region) {
        case NXMRegionLON:
            return @"https://ws-eu-1.nexmo.com/";
        case NXMRegionSNG:
            return @"https://ws-sg-1.nexmo.com/";
        case NXMRegionDAL:
            return @"https://ws-us-2.nexmo.com/";
        case NXMRegionWDC:
            return @"https://ws-us-1.nexmo.com/";
    }
}

+ (nonnull NSString *)ipsUrlFor:(NXMRegion)region {
    return [[NXMClientConfig apiUrlFor:region] stringByAppendingString:@"/v1/image/"];
}

+ (nonnull NSArray<NSString*>*)defaultIceServerUrls {
    return @[@"stun:stun.l.google.com:19302"];
}

@end
