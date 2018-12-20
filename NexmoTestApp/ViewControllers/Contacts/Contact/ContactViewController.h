//
//  ContactViewController.h
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTAUserInfo;
@interface ContactViewController : UIViewController
- (void)updateWithContactUserInfo:(NTAUserInfo *)contactUserInfo;
@end

