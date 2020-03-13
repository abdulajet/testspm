//
//  TokenGenerator.h
//  NexmoTestApp
//
//  Created by Assaf Passal on 2/19/20.
//  Copyright © 2020 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^tokenCallback_t)(NSError * _Nullable error, NSString * _Nullable token);

@interface TokenGenerator: NSObject<WKNavigationDelegate>
- (instancetype _Nonnull ) initWithUsername:(NSString*_Nullable)username andCallback:(tokenCallback_t _Nonnull ) callback;
- (void)getToken:(UIViewController*_Nonnull)viewController;
@end

