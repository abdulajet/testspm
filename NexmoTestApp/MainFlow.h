//
//  MainFlow.h
//  NexmoTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface MainFlow : NSObject

+ (MainFlow *)sharedInstance;
- (void)startMainFlowWithAppWindow:(UIWindow *)appWindow;


@end

