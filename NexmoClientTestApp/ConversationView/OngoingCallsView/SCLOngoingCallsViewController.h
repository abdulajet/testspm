//
//  OngoingCallsViewController.h
//  StitchTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXMConversationDetails;
@interface SCLOngoingCallsViewController : UIViewController <UICollectionViewDataSource>
-(void)updateWithConversation:(NXMConversationDetails *)conversation;
@end
