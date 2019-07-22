//
//  VPSocketAnyEvent.h
//  VPSocketIO
//
//  Created by Vasily Popov on 9/19/17.
//  Copyright © 2017 Vasily Popov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPSocketIOClientProtocol.h"

@interface VPSocketAnyEvent : NSObject

@property (nonatomic, strong, readonly) NSString* event;
@property (nonatomic, strong, readonly) NSArray *items;

-(instancetype)initWithEvent:(NSString*)event andItems:(NSArray*)items;

@end


@interface VPSocketEventHandler : NSObject

@property (nonatomic, strong, readonly) NSString* event;
@property (nonatomic, strong, readonly) NSUUID *uuid;
@property (nonatomic, strong, readonly) VPSocketOnEventCallback callback;
@property (nonatomic, readonly) BOOL prefix;

-(instancetype)initWithEvent:(NSString*)event uuid:(NSUUID*)uuid andCallback:(VPSocketOnEventCallback)callback;
-(instancetype)initWithPrefixEvent:(NSString*)event uuid:(NSUUID*)uuid andCallback:(VPSocketOnEventCallback)callback;

-(void)executeCallbackWith:(NSString *)event items:(NSArray*)items withAck:(int)ack withSocket:(id<VPSocketIOClientProtocol>)socket;
@end
