//
//  NXMUtils.h
//  StitchObjC
//
//  Created by Doron Biaz on 7/10/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMEnums.h"

@interface NXMUtils : NSObject
+ (nullable NSDate *)dateFromISOString:(NSString *)isoString;
@end
