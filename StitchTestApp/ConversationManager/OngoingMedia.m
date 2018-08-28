//
//  NXMCall.m
//  StitchTestApp
//
//  Created by Doron Biaz on 8/16/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "OngoingMedia.h"

@implementation OngoingMedia
@synthesize memberId = _memberId;
@synthesize conversationId = _conversationId;
@synthesize creationDate = _creationDate;

-(instancetype)initWithMemberId:(NSString *)memberId andConversationId:(NSString *)conversationId andSeqNum:(NSInteger)lastSeqNum {
    if(self = [super init]) {
        _memberId = memberId;
        _conversationId = conversationId;
        self.enabled = false;
        self.suspended = false;
        _creationDate = [NSDate date];
        self.lastSeqNum = -1;
    }
    return self;
}
@end
