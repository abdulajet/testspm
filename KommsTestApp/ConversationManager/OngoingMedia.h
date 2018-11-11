//
//  NXMCall.h
//  StitchTestApp
//
//  Created by Doron Biaz on 8/16/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OngoingMedia : NSObject
@property (nonatomic, strong, readonly, nonnull) NSString *memberId;
@property (nonatomic, strong, readonly, nonnull) NSString *conversationId;
@property (nonatomic) bool enabled;
@property (nonatomic) bool suspended;
@property (nonatomic, readonly, nonnull) NSDate *creationDate;
@property (nonatomic) long lastSeqNum;

-(instancetype)initWithMemberId:(nonnull NSString *)memberId andConversationId:(nonnull NSString *)conversationId  andSeqNum:(NSInteger)lastSeqNum;
@end
