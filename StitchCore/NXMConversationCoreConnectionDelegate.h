//
//  NXMConversationCoreConnectionDelegate.h
//  StitchCore
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMUser.h"

@protocol NXMConversationCoreConnectionDelegate <NSObject>
- (void)connectionStatusChanged:(BOOL)isOnline;
- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error;
@end
