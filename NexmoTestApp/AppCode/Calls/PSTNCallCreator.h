//
//  PSTNCallCreator.h
//  NexmoTestApp
//
//  Created by Chen Lev on 12/27/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NTACallCreator.h"

@interface PSTNCallCreator : NSObject <CallCreator>
- (instancetype)initWithNumber:(NSString *)number;
@end
