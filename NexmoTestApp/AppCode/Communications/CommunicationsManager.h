//
//  NexmoClientWrapper.h
//  NexmoTestApp
//
//  Created by Chen Lev on 12/9/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <NexmoClient/NexmoClient.h>

#import "CommunicationsManagerObserver.h"

@interface CommunicationsManager : NSObject <NXMClientDelegate>

@property (nonatomic, nonnull, readonly) NXMClient *client;
@property (nonatomic, readonly) CommunicationsManagerConnectionStatus connectionStatus;
+ (nonnull CommunicationsManager *)sharedInstance;

+ (NSString *)CommunicationsManagerConnectionStatusReasonToString:(CommunicationsManagerConnectionStatusReason)status;



/**
 subscribe to clientStatuses

 @param observer object confroming to NexmoClientStatusObserver protocol
 @return array of objects to supply when unsubscribing
 */
- (NSArray<id <NSObject>> *)subscribeToNotificationsWithObserver:(NSObject<CommunicationsManagerObserver> *)observer;


/**
 unsubscribe to clientStatuses


 @param observers array of objects returned from subscribing
 */
- (void)unsubscribeToNotificationsWithObserver:(NSArray<id <NSObject>> *)observers;

- (void)logout;
@end

