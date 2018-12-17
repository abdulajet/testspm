//
//  NTALoginHandlerObserver.h
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/16/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NTALoginHandlerObserver <NSObject>
@optional
- (void)NTADidLoginWithUserName:(NSString *)userName;
- (void)NTADidLogoutWithUserName:(NSString *)userName;
@end

NS_ASSUME_NONNULL_END
