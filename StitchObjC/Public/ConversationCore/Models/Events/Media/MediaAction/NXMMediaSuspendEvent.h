//
//  NXMMediaSuspendEvent.h
//  StitchObjC
//
//  Created by Doron Biaz on 8/8/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMediaActionEvent.h"

@interface NXMMediaSuspendEvent : NXMMediaActionEvent
@property (nonatomic) bool isSuspended;
@end
