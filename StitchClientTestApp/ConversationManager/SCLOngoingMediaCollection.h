//
//  SCLOngoingMediaCollection.h
//  StitchTestApp
//
//  Created by Doron Biaz on 8/16/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCLOngoingMedia.h"
@interface SCLOngoingMediaCollection : NSObject
@property (nonatomic, strong, nullable) NSMutableArray<SCLOngoingMedia *> *ongoingCallsArray;
@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *,NSNumber *> *> *ongoingCallsMemberConversationToArrayIndex;
@property (nonatomic, readonly) long count;

-(long)countForConversation:(NSString *)conversationId;
-(bool)addMedia:(nonnull SCLOngoingMedia *)media ForMember:(nonnull NSString *)memberId inConversation:(nonnull NSString *)conversationId;
-(SCLOngoingMedia *)getMediaForMember:(nonnull NSString *)memberId inConversation:(nonnull NSString *)conversationId;
-(void)removeMediaForMember:(nonnull NSString *)memberId inConversation:(nonnull NSString *)conversationId;
-(SCLOngoingMedia *)getMediaForIndex:(nonnull NSNumber *)index;
@end
