//
//  KommsClients.h
//  KommsTestApp
//
//  Created by Doron Biaz on 10/17/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SCLStitchClientWrapper;

@interface SCLStitchClients : NSObject
+(nullable SCLStitchClientWrapper *)wrapperClientWithClientId:(nonnull NSString *)clientId;
+(nonnull SCLStitchClientWrapper *)sharedWrapperClient;
@end
