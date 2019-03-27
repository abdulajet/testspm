//
//  NXMMember.m
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMemberPrivate.h"

@interface NXMMember()
@property (nonatomic, readwrite) NXMUser *user;
@property (nonatomic, readwrite) NXMMediaSettings *mediaSettings;
@property (nonatomic, readwrite) NXMMemberState state;
@end

@implementation NXMMember

- (instancetype)initWithMemberId:(NSString *)memberId
                  conversationId:(NSString *)conversationId
                            user:(NXMUser *)user
                           state:(NXMMemberState)state {
    if (self = [super init]) {
        self.memberId = memberId;
        self.conversationId = conversationId;
        self.user = user;
        self.state = state;
    }
    
    return self;
}

- (instancetype)initWithMemberEvent:(NXMMemberEvent *)memberEvent
{
    self = [super init];
    if (self) {
        self.memberId = memberEvent.memberId;
        self.conversationId = memberEvent.conversationId;
        self.state = memberEvent.state;
        self.user = memberEvent.user;
    }
    return self;
}


- (nullable instancetype)initWithData:(NSDictionary *)data
                 andMemberIdFieldName:(NSString *)memberIdFieldName {
    return [self initWithData:data
         andMemberIdFieldName:memberIdFieldName
            andConversationId:data[@"conv_id"]];
}

- (nullable instancetype)initWithData:(NSDictionary *)data
                 andMemberIdFieldName:(NSString *)memberIdFieldName
                    andConversationId:(NSString *)convertaionId {
    self = [super init];
    if (self) {
        NXMUser *user = [[NXMUser alloc] initWithId:data[@"user_id"] name:data[@"name"]];
        
        self.memberId = data[memberIdFieldName];
        self.conversationId = convertaionId;
        self.user = user;
        self.state = [self parseMemberState:data[@"state"]];
        self.inviteDate = data[@"timestamp"][@"invited"]; // TODO: NSDate
        self.joinDate = data[@"timestamp"][@"joined"]; // TODO: NSDate
        self.leftDate = data[@"timestamp"][@"left"]; // TODO: NSDate
        
        self.mediaSettings = [[NXMMediaSettings alloc] initWithEnabled:[data[@"media"][@"audio_settings"][@"enabled"] boolValue]
                                                               suspend:[data[@"media"][@"audio_settings"][@"muted"] boolValue]];
        
        self.channelType = data[@"channel"][@"type"];
        self.phoneNumber = data[@"channel"][@"from"][@"number"];
    }
    return self;
}


#pragma Parser

- (NXMMemberState)parseMemberState:(NSString *)state {
    static NSDictionary *memberStateValues = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        memberStateValues = @{@"INVITED":@(NXMMemberStateInvited),
                              @"JOINED":@(NXMMemberStateJoined),
                              @"LEFT":@(NXMMemberStateLeft)};
    });
    return [memberStateValues[[state uppercaseString]] integerValue];
}


@end
