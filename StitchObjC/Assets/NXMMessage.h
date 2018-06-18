//
//  NXMMessage.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/12/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXMMessage : NSObject

@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic, strong) NSString *msgId;
@property (nonatomic, strong) NSString *type; // TODO: enum?
@property (nonatomic, strong) NSString *fromMemberId;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSDate *deletionDate;

@end
