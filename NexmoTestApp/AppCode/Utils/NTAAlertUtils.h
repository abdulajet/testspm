//
//  AlertUtils.h
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface NTAAlertUtils : NSObject
+ (void)displayAlertForController:(UIViewController *)controller WithTitle:(NSString *)title andMessage:(NSString *)message;

+ (void)displayAlertForController:(nonnull UIViewController *)controller WithTitle:(nonnull NSString *)title andMessage:(nonnull NSString *)message andDismissAfterSeconds:(NSUInteger)seconds;
@end

NS_ASSUME_NONNULL_END
