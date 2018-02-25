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
@property (nonatomic, strong) NXMUser *user;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSNumber *eventId;

- (instancetype)initWithMemberId:(NSString *)memberId conversationId:(NSString *)conversationId joinDate:(NSDate *)joinDate
                          user:(NXMUser *)user name:(NSString *)name state:(NSString *)state;

@end
