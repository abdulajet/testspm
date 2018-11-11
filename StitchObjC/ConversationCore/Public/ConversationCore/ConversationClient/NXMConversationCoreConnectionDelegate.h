//
//  NXMConversationCoreConnectionDelegate.h
//  StitchObjC
//
//  Created by Doron Biaz on 9/17/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMUser.h"
@protocol NXMConversationCoreConnectionDelegate <NSObject>
- (void)connectionStatusChanged:(BOOL)isOnline;
- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error;
@end
