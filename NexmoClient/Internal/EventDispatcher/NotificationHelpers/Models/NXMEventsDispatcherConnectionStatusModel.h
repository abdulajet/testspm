//
//  NXMEventsDispatcherConnectionStatusModel.h
//  StitchObjC
//
//  Created by Doron Biaz on 9/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMEnums.h"

@interface NXMEventsDispatcherConnectionStatusModel : NSObject
@property (nonatomic) NXMConnectionStatus status;
@property (nonatomic) NXMConnectionStatusReason reason;
-(instancetype)initWithStatus:(NXMConnectionStatus)status andReason:(NXMConnectionStatusReason)reason;
@end
