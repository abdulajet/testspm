//
//  AlertUtils.m
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//
#import "NTAAlertUtils.h"

@implementation NTAAlertUtils
+ (void)displayAlertForController:(nonnull UIViewController *)controller WithTitle:(nonnull NSString *)title andMessage:(nonnull NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [controller presentViewController:alert animated:YES completion:nil];
    });
}

+ (void)displayAlertForController:(nonnull UIViewController *)controller WithTitle:(nonnull NSString *)title andMessage:(nonnull NSString *)message andDismissAfterSeconds:(NSUInteger)seconds {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alertController addAction:defaultAction];
        [controller presentViewController:alertController animated:YES completion:nil];

        __weak UIViewController *weakController = controller;
        __weak UIViewController *weakAlertController = alertController;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(weakController.presentedViewController == weakAlertController) {
                [weakController dismissViewControllerAnimated:YES completion:nil];
            }
        });
    });
}
@end
