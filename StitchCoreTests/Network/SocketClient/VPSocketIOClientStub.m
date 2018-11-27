//
//  VPSocketIOClientStub.m
//  StitchObjCTests
//
//  Created by Tamir Tuch on 11/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VPSocketIOClient.h"
#import "VPSocketIOClientStub.h"
#import "NXMSocketClientDefine.h"
@interface VPSocketIOClientStub()
@property VPSocketOnEventCallback expiredTokenCallback;
@property VPSocketOnEventCallback invalidTokenCallback;
@property VPSocketOnEventCallback successfulLoginCallback;
@property VPSocketOnEventCallback textSeenCallback;
@end
@implementation VPSocketIOClientStub
-(NSUUID*) on:(NSString*)event callback:(VPSocketOnEventCallback) callback {
    if ([event isEqualToString:kNXMSocketEventExpiredToken]) {
        self.expiredTokenCallback = callback;
    } else if ([event isEqualToString:kNXMSocketEventInvalidToken]) {
        self.invalidTokenCallback = callback;
    } else if ([event isEqualToString:kNXMSocketEventLoginSuccess]) {
        self.successfulLoginCallback = callback;
    } else if ([event isEqualToString:kNXMSocketEventTextSeen]) {
        self.textSeenCallback = callback;
    }
    return nil;
}
-(void) emit:(NSString *)event items:(NSArray *)items {
    if ([self.testedEvent isEqualToString:kNXMSocketEventExpiredToken]) {
        self.expiredTokenCallback(nil, nil);
    } else if ([self.testedEvent isEqualToString:kNXMSocketEventInvalidToken]) {
        self.invalidTokenCallback(nil,nil);
    } else if ([self.testedEvent isEqualToString:kNXMSocketEventLogin] || [self.testedEvent isEqualToString:kNXMSocketEventLogout]) {
        NSDictionary* expectedResponse = @{@"body":@{
                                                     @"user_id":@"1234",
                                                     @"name":@"testuser",
                                                     @"id":@"12345"
                                                     }};
        NSArray* responseArr = @[expectedResponse];
        self.successfulLoginCallback(responseArr, nil);
    } else if ([self.testedEvent isEqualToString:kNXMSocketEventTextSeen]) {
        NSDateFormatter *isoDateFomatter = [[NSDateFormatter alloc] init];
        isoDateFomatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
        NSDictionary *expectedResponse = @{@"body":@{
                                                   @"event_id":@1234,
                                                   },
                                           @"cid":@"CON-1234",
                                           @"from":@"MEM-1235",
                                           @"timestamp":[isoDateFomatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:0]],
                                           @"id": @111
                                           };
    
        self.textSeenCallback(@[expectedResponse], nil);
    }
}

@end
