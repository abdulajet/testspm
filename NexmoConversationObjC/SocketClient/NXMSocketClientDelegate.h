//
//  NXMSocketClientDelegate.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

@protocol NXMSocketClientDelegate

- (void)connectionStatusChanged:(BOOL)isOpen;

@end
