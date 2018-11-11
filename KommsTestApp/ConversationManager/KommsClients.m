//
//  KommsClients.m
//  KommsTestApp
//
//  Created by Doron Biaz on 10/17/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "KommsClients.h"
#import "NXMStitchClient.h"
#import "KommsClientWrapper.h"

@interface KommsClients ()

@end

@implementation KommsClients
+(KommsClientWrapper *)wrapperClientWithClientId:(nonnull NSString *)clientId {
    static NSMutableDictionary<NSString *, KommsClientWrapper *> *clients;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        clients = [NSMutableDictionary new];
    });
    
    if(!clients[clientId]) {
        clients[clientId] = [[KommsClientWrapper alloc] initWithKommsClient:[NXMStitchClient new]];
    }
    
    return clients[clientId];
}

+(KommsClientWrapper *)sharedWrapperClient {
    static KommsClientWrapper *sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[KommsClientWrapper alloc] initWithKommsClient:[NXMStitchClient new]];
    });
    
    return sharedClient;
}

@end
