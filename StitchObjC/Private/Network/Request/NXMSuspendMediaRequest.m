//
//  NXMMuteAudioRequest.m
//  StitchObjC
//
//  Created by Doron Biaz on 8/27/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMSuspendResumeMediaRequest.h"

@implementation NXMSuspendResumeMediaRequest
- (instancetype)initWithConversationId:(nonnull NSString *)conversationId fromMemberId:(nonnull NSString *)fromMemberId toMemberId:(nonnull NSString *)toMemberId rtcId:(nullable NSString *)rtcId mediaType:(NXMMediaType)mediaType {
    if(self = [super init]) {
        self.conversationId = conversationId;
        self.fromMemberId = fromMemberId;
        self.toMemberId = toMemberId;
        self.rtcId = rtcId;
        self.mediaType = mediaType;
    }
    return self;
}
@end
