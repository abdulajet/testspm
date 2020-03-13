//
//  InCallViewController.h
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/19/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTACallCreator.h"

@interface CallViewController : UIViewController
- (void)updateWithNumber:(NSString *)number callCreator:(id<CallCreator>)callCreator andIsIncomingCall:(BOOL)isIncomingCall;
@end

