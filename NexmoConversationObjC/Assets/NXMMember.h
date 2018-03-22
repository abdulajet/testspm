//
//  NXMMember.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMUser.h"
@interface NXMMember : NSObject


@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic, strong) NSString *memberId;
@property (nonatomic, strong) NSString *joinDate;
@property (nonatomic, strong) NSString *inviteDate;
@property (nonatomic, strong) NSString *leftDate;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *state;

- (instancetype)initWithMemberId:(NSString *)memberId conversationId:(NSString *)conversationId
                          user:(NSString *)userId name:(NSString *)name state:(NSString *)state;

@end
