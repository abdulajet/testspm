//
//  OngoingCallsViewController.h
//  StitchTestApp
//
//  Created by Doron Biaz on 8/14/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXMConversationDetails.h"
@interface OngoingCallsViewController : UIViewController <UICollectionViewDataSource>
-(void)updateWithConversation:(NXMConversationDetails *)conversation;
@end
