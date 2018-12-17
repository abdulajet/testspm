//
//  CoversationViewController.h
//  StitchTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXMConversation;

@interface SCLConversationViewController : UIViewController

-(void)updateWithConversation:(NXMConversation *)conversation;

@end
