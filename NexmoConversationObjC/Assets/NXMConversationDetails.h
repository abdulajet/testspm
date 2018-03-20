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
@property int *sequence_number;
@property NSString *name;
@property NSArray<NXMMember *> *members;
@property NSDate *created;
@property NSData *metaInfo;


@end
