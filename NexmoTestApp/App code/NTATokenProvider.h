//
//  NTATokenProvider.h
//  NexmoTestApp
//
//  Created by Chen Lev on 12/9/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTATokenProvider : NSObject

+ (void)getTokenForUser:(NSString *)user
               password:(NSString *)password
             completion:(void(^_Nullable)(NSError * _Nullable error, NSString *token))completion;

@end


