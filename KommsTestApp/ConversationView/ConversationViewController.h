//
//  CoversationViewController.h
//  StitchTestApp
//
//  Created by Chen Lev on 5/27/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXMConversation;

@interface ConversationViewController : UIViewController

-(void)updateWithConversation:(NXMConversation *)conversation;

@end
