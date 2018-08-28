//
//  RTCMediaWrapper.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 4/23/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iOSFramework/iOSFramework.h>

#import "NXMEnums.h"
#import "NXMNetworkCallbacks.h"
#import "RTCMediaWrapperDelegate.h"
#import "NXMErrors.h"

@interface RTCMediaWrapper : NSObject<MRTCMediaDelegate>

// TODO: network
//- (void)setNetworkDelegate:(id<MRTCMediaNetwork>)networkDelegate;

- (void)setDelegate:(id<RTCMediaWrapperDelegate>)delegate;

- (void)disableMedia:(NSString *)mediaId;

- (void)enableMediaWithMediaID:(NSString *)conversationId memberId:(NSString *)memberId andWithAudio:(NXMMediaStreamType)audiostream andWithVideo:(NXMMediaStreamType)videoStream;
- (void)answerWithMediaId:(NSString *)mediaId convId:(NSString *)convId andSDP:(NSString *)sdp;

- (NXMStitchErrorCode)suspendMediaWithMediaId:(nonnull NSString *)conversationId andMediaType:(NXMMediaType)type; //the error is only if we failed to send to mini, if no error it does not mean that we succeeded, will be handled later.
- (NXMStitchErrorCode)resumeMediaWithMediaId:(nonnull NSString *)conversationId andMediaType:(NXMMediaType)type;

//- (void)addMemberWithMediaId:(NSString *)mediaId andSdp:(NSString *)sdp;
//- (void)updateMediaMediaId:(NSString *)mediaId andWithAudio:(MRTCMediaManagerMediaType)audioStream andWithVideo:(MRTCMediaManagerRTPStramType)videoStream;

//- (void)holdWithMediaId:(NSString *)mediaId;

@end
