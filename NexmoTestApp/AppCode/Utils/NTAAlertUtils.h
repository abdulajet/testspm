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
+ (void)displayAlertForController:(UIViewController *)controller withTitle:(NSString *)title andMessage:(NSString *)message;

+ (void)displayAlertForController:(UIViewController *)controller withTitle:(NSString *)title andMessage:(NSString *)message andActionBlock:(void (^ __nullable)(UIAlertAction *action))actionBlock;

+ (void)displayAlertForController:(nonnull UIViewController *)controller withTitle:(nonnull NSString *)title andMessage:(nonnull NSString *)message andDismissAfterSeconds:(NSUInteger)seconds;
@end

NS_ASSUME_NONNULL_END
