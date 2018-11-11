//
//  MediaInfo.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 4/25/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMediaInfo.h"

@implementation NXMMediaInfo
-(instancetype)initWithMediaId:(NSString *)mediaId conversationId:(NSString *)conversationId rtcId:(NSString *)rtcId memberId:(NSString *)memberid {
    if(self = [super init]) {
        self.mediaId = mediaId;
        self.conversationId = conversationId;
        self.rtcId = rtcId;
        self.memberId = memberid;
    }
    return self;
}
@end
