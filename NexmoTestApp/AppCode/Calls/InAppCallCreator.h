//
//  CallBuilder.h
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/19/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTACallCreator.h"

@class NTAUserInfo;
@interface InAppCallCreator : NSObject <CallCreator>
- (instancetype)initWithUsers:(NSArray<NTAUserInfo *> *)users;
@end

