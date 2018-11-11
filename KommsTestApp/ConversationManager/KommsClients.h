//
//  KommsClients.h
//  KommsTestApp
//
//  Created by Doron Biaz on 10/17/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KommsClientWrapper;

@interface KommsClients : NSObject
+(nullable KommsClientWrapper *)wrapperClientWithClientId:(nonnull NSString *)clientId;
+(nonnull KommsClientWrapper *)sharedWrapperClient;
@end
