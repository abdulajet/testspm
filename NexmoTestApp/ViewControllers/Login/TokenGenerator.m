//
//  TokenGenerator.m
//  NexmoTestApp
//
//  Created by Assaf Passal on 2/19/20.
//  Copyright © 2020 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "TokenGenerator.h"

@interface TokenGenerator()
@property (nonatomic) NSString* username;
@property (nonatomic) tokenCallback_t callback;
@end

@implementation TokenGenerator:NSObject


- (instancetype _Nonnull ) initWithUsername:(NSString*_Nullable)username andCallback:(tokenCallback_t _Nonnull ) callback{
    self = [super init];
       if (self) {
           self.username = username;
           self.callback = callback;
       }
       return self;
}

- (void)getToken:(UIViewController*_Nonnull)viewController{
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:viewController.view.frame configuration:theConfiguration];
    webView.navigationDelegate = self;
    NSURL *url=[NSURL URLWithString:[self getUrlForUsername:self.username]];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    webView.customUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 13_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 Safari/604.1";

    [webView loadRequest:request];
    [webView setHidden:YES];
    [viewController.view addSubview:webView];
}

- (NSString*) getUrlForUsername:(nonnull NSString* )userName{
    NSString* appId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NPE_APP_ID"];
    if (userName){
        return [NSString stringWithFormat:@"https://gauth.npe.nexmo.io/token/%@/%@", appId, userName];
    }else{
        return [NSString stringWithFormat:@"https://gauth.npe.nexmo.io/token/%@", appId];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [webView evaluateJavaScript:@"document.documentElement.innerHTML"  completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                NSLog(@"html: %@",result);
        NSURL *url=[NSURL URLWithString:[self getUrlForUsername:self.username]];
        NSURLRequest *request=[NSURLRequest requestWithURL:url];
        if ([result containsString:@"Forwarding ..."]){
            [webView setHidden:NO];
        }
        else if ([result containsString:@"\"version\":\"0.0.1\""]){
            [webView loadRequest:request];
            [webView setHidden:YES];
        }else if ([result containsString:@"\"username\":"] && [result containsString:@"\"token\":"]){
            NSUInteger startLocation = [result rangeOfString:@"token"].location+8;
            NSUInteger endLocation = [result rangeOfString:@"\"}</pre>"].location;
            NSString *token = [result substringWithRange:NSMakeRange(startLocation,endLocation-startLocation)];
            NSLog(@"token is: %@", token);
            [webView setHidden:YES];
            self.callback(nil, token);
        }
    }];
    
}
@end
