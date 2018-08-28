//
//  MediaInfo.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 4/25/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXMMediaInfo : NSObject

@property NSString *mediaId;
@property NSString *conversationId;
@property NSString *rtcId;
@property NSString *memberId;

-(instancetype)initWithMediaId:(NSString *)mediaId conversationId:(NSString *)conversationId rtcId:(NSString *)rtcId memberId:(NSString *)memberid;

@end
