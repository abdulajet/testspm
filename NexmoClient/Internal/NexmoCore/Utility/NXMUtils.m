//
//  NXMUtils.m
//  StitchObjC
//
//  Created by Doron Biaz on 7/10/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMUtils.h"

//@interface NXMUtils ()

//@property NSISO8601DateFormatter* dateFormatter;

//@end

@implementation NXMUtils : NSObject
static NSMutableDictionary<NSString*, NSNumber*>* statusMap = nil;
static NSMutableDictionary<NSString*, NSNumber*>* typeMap = nil;

+ (NSDate *)dateFromISOString:(NSString *)isoString {
    NSDateFormatter *isoDateFomatter = [[NSDateFormatter alloc] init];
    isoDateFomatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    return [isoDateFomatter dateFromString:isoString];
}

@end
