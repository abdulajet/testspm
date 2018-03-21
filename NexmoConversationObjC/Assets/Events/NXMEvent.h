//
//  NXMEvent.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/21/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXMEvent : NSObject

@property (nonatomic, strong, nonnull) NSString *conversationId;
@property (nonatomic, strong, nonnull) NSString *msgId;
@property (nonatomic, strong, nonnull) NSString *type;
@property (nonatomic, strong, nonnull) NSString *fromMemberId;
@property (nonatomic, strong, nonnull) NSDate *creationDate;
@property (nonatomic, strong, nullable) NSDate *deletionDate;

@end
