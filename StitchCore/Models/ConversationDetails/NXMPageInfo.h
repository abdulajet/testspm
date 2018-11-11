//
//  NXMPageInfo.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 5/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXMPageInfo : NSObject
@property NSNumber *count;
@property NSNumber *pageSize;
@property NSNumber *recordIndex;

- (instancetype)initWithCount:(NSNumber *)count pageSize:(NSNumber *)pageSize recordIndex:(NSNumber *)recordIndex;
@end
