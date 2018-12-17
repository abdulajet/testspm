//
//  NXMEventsDispatcherConnectionStatusModel.h
//  StitchObjC
//
//  Created by Doron Biaz on 9/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXMEventsDispatcherConnectionStatusModel : NSObject
@property (nonatomic) BOOL isConnected;
-(instancetype)initWithIsConnected:(BOOL)isConnected;
@end
