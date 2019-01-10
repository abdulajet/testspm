//
//  NXMCall.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMCallMember.h"
#import "NXMConversation.h"
#import "NXMBlocks.h"

@protocol NXMCallDelegate
- (void)statusChanged:(NXMCallMember *)callMember;
@end

typedef NS_ENUM(NSInteger, NXMCallType) {
    NXMCallTypeInApp,
    NXMCallTypeServer
};
typedef NS_ENUM(NSInteger, NXMCallStatus) {
    NXMCallStatusConnected,
    NXMCallStatusDisconnected
};


@interface NXMCall : NSObject

@property (readonly, nonatomic) NSMutableArray<NXMCallMember *> *otherCallMembers;
@property (nonatomic, readonly) NXMCallMember *myCallMember;
@property (nonatomic, readonly) NXMCallStatus status;
@property (nonatomic, readonly) NXMConversation* conversation;

- (void)setDelegate:(id<NXMCallDelegate>)delegate;

- (void)answer:(id<NXMCallDelegate>)delegate completionHandler:(NXMErrorCallback _Nullable)completionHandler;
- (void)decline:(NXMErrorCallback _Nullable)completionHandler;

- (void)addCallMemberWithUserId:(NSString *)userId completionHandler:(NXMErrorCallback _Nullable)completionHandler;
- (void)addCallMemberWithNumber:(NSString *)number completionHandler:(NXMErrorCallback _Nullable)completionHandler;

@end

