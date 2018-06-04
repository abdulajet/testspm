//
//  NXMConversation.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMember.h"

@interface NXMConversationDetails : NSObject

@property NSString *uuid;
@property NSInteger sequence_number;
@property NSString *name;
@property NSString *displayName;
@property NSArray<NXMMember *> *members;
@property NSDate *created;
@property NSData *properties;

- (instancetype)initWithId:(NSString *)uuid;

@end
