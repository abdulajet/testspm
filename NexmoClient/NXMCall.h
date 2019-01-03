//
//  NXMCall.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMCallParticipant.h"
#import "NXMConversation.h"
#import "NXMBlocks.h"

@protocol NXMCallDelegate
- (void)statusChanged:(NXMCallParticipant *)participant;
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

@property (readonly, nonatomic) NSMutableArray<NXMCallParticipant *> *otherParticipants;
@property (nonatomic, readonly) NXMCallParticipant *myParticipant;
@property (nonatomic, readonly) NXMCallStatus status;
@property (nonatomic, readonly) NXMConversation* conversation;

- (void)setDelegate:(id<NXMCallDelegate>)delegate;

- (void)answer:(id<NXMCallDelegate>)delegate completionHandler:(NXMErrorCallback _Nullable)completionHandler;
- (void)decline:(NXMErrorCallback _Nullable)completionHandler;

- (void)addParticipantWithUserId:(NSString *)userId completionHandler:(NXMErrorCallback _Nullable)completionHandler;
- (void)addParticipantWithNumber:(NSString *)number completionHandler:(NXMErrorCallback _Nullable)completionHandler;

@end

