//
//  NXMMessageEvent.h
//  StitchObjC
//
//  Created by Iliya Barenboim on 29/08/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEvent.h"

@interface NXMMessageEvent : NXMEvent
@property (nonatomic, strong,nonnull) NSMutableDictionary<NSNumber *,NSMutableDictionary<NSString *, NSDate *> *> *state;
@end
