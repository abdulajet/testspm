//
//  OngoingMediaCollection.h
//  StitchTestApp
//
//  Created by Doron Biaz on 8/16/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OngoingMedia.h"
@interface OngoingMediaCollection : NSObject
@property (nonatomic, strong, nullable) NSMutableArray<OngoingMedia *> *ongoingCallsArray;
@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *,NSNumber *> *> *ongoingCallsMemberConversationToArrayIndex;
@property (nonatomic, readonly) long count;

-(long)countForConversation:(NSString *)conversationId;
-(bool)addMedia:(nonnull OngoingMedia *)media ForMember:(nonnull NSString *)memberId inConversation:(nonnull NSString *)conversationId;
-(OngoingMedia *)getMediaForMember:(nonnull NSString *)memberId inConversation:(nonnull NSString *)conversationId;
-(void)removeMediaForMember:(nonnull NSString *)memberId inConversation:(nonnull NSString *)conversationId;
-(OngoingMedia *)getMediaForIndex:(nonnull NSNumber *)index;
@end
