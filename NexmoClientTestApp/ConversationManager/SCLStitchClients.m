//
//  KommsClients.m
//  KommsTestApp
//
//  Created by Doron Biaz on 10/17/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "SCLStitchClients.h"
#import "SCLStitchClientWrapper.h"

@interface SCLStitchClients ()

@end

@implementation SCLStitchClients
+(SCLStitchClientWrapper *)wrapperClientWithClientId:(nonnull NSString *)clientId {
    static NSMutableDictionary<NSString *, SCLStitchClientWrapper *> *clients;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        clients = [NSMutableDictionary new];
    });
    
    if(!clients[clientId]) {
        clients[clientId] = [[SCLStitchClientWrapper alloc] initWithKommsClient:[NXMStitchClient new]];
    }
    
    return clients[clientId];
}

+(SCLStitchClientWrapper *)sharedWrapperClient {
    static SCLStitchClientWrapper *sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[SCLStitchClientWrapper alloc] initWithKommsClient:[NXMStitchClient new]];
    });
    
    return sharedClient;
}

@end
