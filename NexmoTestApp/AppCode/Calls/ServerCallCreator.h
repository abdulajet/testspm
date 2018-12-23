//
//  ServerCallCreator.h
//  NXMiOSSDK
//
//  Created by Assaf Passal on 12/23/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTACallCreator.h"

@class NTAUserInfo;
@interface ServerCallCreator : NSObject <CallCreator>
- (instancetype)initWithUsers:(NSArray<NTAUserInfo *> *)users;
@end
