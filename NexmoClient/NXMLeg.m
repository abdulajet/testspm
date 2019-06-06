//
//  NXMLeg.m
//  NexmoClient
//
//  Created by Assaf Passal on 5/30/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMLegPrivate.h"
#import "NXMUtils.h"

@implementation NXMLeg

- (nullable instancetype) initWithConversationId:(nullable NSString *)conversationId
                                     andMemberId:(nullable NSString *)memberId
                                        andLegId:(nullable NSString *)legId
                                      andlegType:(nullable NSString *)legType
                                    andLegStatus:(nullable NSString *)legStatus
                                         andDate:(nullable NSString *)date {
    if (self = [super init]){
        self.legId = legId;
        self.legType = [NXMLeg getLegTypeFromString:legType];
        self.legStatus = [NXMLeg getLegStatusFromString:legStatus];
        self.conversationId = conversationId;
        self.memberId = memberId;
        self.date = [NXMUtils dateFromISOString:date];
    }
    
    return self;
}

- (nullable instancetype) initWithConversationId:(nullable NSString *) conversationId
                                     andMemberId:(nullable NSString *) memberId
                                      andLegData:(nullable NSDictionary *)legData
                                         andData:(nullable NSDictionary *)data {
    if (self = [super init]){
        self.legId          = legData[@"leg_id"];
        self.legType        = [NXMLeg getLegTypeFromString:data[@"type"]];
        self.legStatus      = [NXMLeg getLegStatusFromString:legData[@"status"]];
        
        self.conversationId = conversationId;
        self.memberId       = memberId;
    }
    
    return self;
    
}

- (nullable instancetype)initWithData:(nullable NSDictionary *)data
                            andLegData:(nullable NSDictionary *)legData {
    if (self = [super init]) {
        self.legId          = data[@"leg_id"];
        self.legType        = [NXMLeg getLegTypeFromString:data[@"type"]];
        self.legStatus      = [NXMLeg getLegStatusFromString:legData[@"status"]];
        
        self.conversationId = legData[@"convertsation_id"];
        self.memberId       = legData[@"member_id"];
        
        self.date           = [NXMUtils dateFromISOString:legData[@"date"]];
    }
    
    return self;
}


+ (NXMLegStatus)getLegStatusFromString:(nullable NSString*)statusString {
    return [statusString isEqualToString:@"riniging"] ? NXMLegStatusRinging :
            [statusString isEqualToString:@"answered"] ? NXMLegStatusAnswered :
            [statusString isEqualToString:@"started"] ? NXMLegStatusStarted :
            [statusString isEqualToString:@"completed"] ? NXMLegStatusCompleted :
            NXMLegStatusUnknown;
}

+ (NXMLegType)getLegTypeFromString:(nullable NSString*)typeString {
    return [typeString isEqualToString:@"app"] ? NXMLegTypeApp :
           [typeString isEqualToString:@"phone"] ? NXMLegTypeApp :
           NXMLegTypeUnknown;
}

@end
