//
//  ViewController.m
//  testApp
//
//  Created by Chen Lev on 2/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ViewController.h"

#import "NXMSocketClient.h"

@interface ViewController ()

@property NXMSocketClient *client;

@end

@implementation ViewController

static NSString *const URL = @"https://ws.nexmo.com/";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.client = [NXMSocketClient new];
    [self.client setDelegate:self];
    [self.client setupWitHost:URL];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connectionStatusChanged:(BOOL)isOpen {
    NSString *token = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE1MTkyOTEzNDcsImp0aSI6ImU2Nzk3NTkwLTE3YjEtMTFlOC1hMWY4LWJkNDA3MmU2MGYzMSIsInN1YiI6InRlc3R1c2VyMSIsImV4cCI6IjE1MjAxNTUzNDciLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJhcHBsaWNhdGlvbl9pZCI6IjI0MGIxYTY4LTg3NDItNDY4Yy1iNjJjLWZhYzNlNjkyNTMxMCJ9.iSbAIgtF4iVT1xAkFK4hlnQ0Ro9p0vsf3QfG-kutrVCxxlCDZlCQK5Wr0qccWmM_N9iZyfMqSIZRkD11draoRUjOENj2lbba8eqKkiYHGFqbsL3DdFzmq62Cf8Bl4yNTEwhO8olVgI4jnaxa65JRs79WbG5Z_nCY3l9b0NIQrAl0jiiC3HREU6h31AHwTBiJJEDftQ9xRpFu_z2qsuQ-KEey-LilPHmXmZLN-eUoZm6in3G1w0QKUykikQqILoXMP7ooFp5_ctSoEqW2kiYVquAPm1H6pToa_9wHxitQTxyNBB1w2e5PB93xjAV09L5GaG-NWcntrzz0ZJcyar1ODg";
    [self.client loginWithToken:token];
}



@end
