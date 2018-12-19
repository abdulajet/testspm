//
//  NXMPushParser.m
//  StitchObjC
//
//  Created by Doron Biaz on 11/1/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMPushParserManager.h"
#import "NXMPushParsers.h"

static const NSString *stitchPushIdentifier = @"nexmo";
@interface NXMPushParserManager ()
@property (nonatomic, nonnull) NSMutableDictionary<NSString *, id<NXMPushParsing>> *parsers;
-(nullable NSDictionary *)stitchPushInfoWithUserInfo:(nonnull NSDictionary *)userInfo;
@end

@implementation NXMPushParserManager

+(nonnull instancetype)sharedInstance {
    static NXMPushParserManager *sharedParser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedParser = [[NXMPushParserManager alloc] init];
    });
    return sharedParser;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initParsers];
    }
    return self;
}

-(void)initParsers {
    self.parsers = [NSMutableDictionary new];
    self.parsers[[NXMPushParserTextEvent eventTypeIdentifier]] = [[NXMPushParserTextEvent alloc] init];
    self.parsers[[NXMPushParserImageEvent eventTypeIdentifier]] = [[NXMPushParserImageEvent alloc] init];
    self.parsers[[NXMPushParserInviteEvent eventTypeIdentifier]] = [[NXMPushParserInviteEvent alloc] init];
}

-(BOOL)isStitchPushWithUserInfo:(nonnull NSDictionary *)userInfo {
    return userInfo[stitchPushIdentifier] ? true : false;
}

-(nullable NSDictionary *)stitchPushInfoWithUserInfo:(nonnull NSDictionary *)userInfo {
    return userInfo[stitchPushIdentifier];
}

-(nullable NXMEvent *)parseStitchPushEventWithUserInfo:(nonnull NSDictionary *)userInfo {
    if([self isStitchPushWithUserInfo:userInfo]) {
        return nil;
    }
    
    return [self.parsers[userInfo[@"event_type"]] parseStitchPushEventWithStitchPushInfo:[self stitchPushInfoWithUserInfo:userInfo]];
}
@end
