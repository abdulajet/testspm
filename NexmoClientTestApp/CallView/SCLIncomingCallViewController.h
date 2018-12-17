//
//  SCLIncomingCall.h
//  Stitch_iOS
//
//  Created by Assaf Passal on 12/9/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#ifndef SCLIncomingCall_h
#define SCLIncomingCall_h

#import <UIKit/UIKit.h>

@class NXMCall;

@interface SCLIncomingCallViewController : UIViewController

-(void)updateWithCall:(NXMCall *)call;

@end

#endif /* SCLIncomingCall_h */
