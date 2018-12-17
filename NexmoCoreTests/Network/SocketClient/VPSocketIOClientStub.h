//
//  VPSocketIOClientStub.h
//  StitchObjCTests
//
//  Created by Tamir Tuch on 11/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//
#import "VPSocketIOClient.h"
#import "NXMSocketClientDefine.h"

@interface VPSocketIOClientStub : VPSocketIOClient
-(NSUUID*) on:(NSString*)event callback:(VPSocketOnEventCallback) callback;
-(void) emit:(NSString *)event items:(NSArray *)items;
@property NSString* testedEvent;
@end
