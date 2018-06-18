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

@protocol RTCMediaWrapperDelegate

- (void)onMediaStatusChangedWithConversationId:(NSString *)conversationId andStatus:(NSString *)status;

- (void)sendSDP:(NSString *)sdp
   andMediaInfo:(MRTCMediaInfo *)mediaInfo
      onSuccess:(SuccessCallbackWithId)onSuccess
        onError:(ErrorCallback)onError;

- (void)terminateRtc:(MRTCMediaInfo *)mediaInfo rtcId:(NSString *)rtcId  completionHandler:(void (^)(NSError *))completionHandler;
@end

@interface RTCMediaWrapper : NSObject<MRTCMediaDelegate>

// TODO: network
//- (void)setNetworkDelegate:(id<MRTCMediaNetwork>)networkDelegate;

- (void)setDelegate:(id<RTCMediaWrapperDelegate>)delegate;

- (void)disableMedia:(NSString *)mediaId;

- (void)enableMediaWithMediaID:(NSString *)conversationId memberId:(NSString *)memberId andWithAudio:(NXMMediaStreamType)audiostream andWithVideo:(NXMMediaStreamType)videoStream;
- (void)answerWithMediaId:(NSString *)mediaId convId:(NSString *)convId andSDP:(NSString *)sdp;

//- (void)addMemberWithMediaId:(NSString *)mediaId andSdp:(NSString *)sdp;
//- (void)updateMediaMediaId:(NSString *)mediaId andWithAudio:(MRTCMediaManagerMediaType)audioStream andWithVideo:(MRTCMediaManagerRTPStramType)videoStream;

//- (void)holdWithMediaId:(NSString *)mediaId;
//- (void)suspendMediaId:(NSString *)mediaId andNedia:(MediaType)type;
//- (void)resumeMediaId:(NSString *)mediaId andNedia:(MediaType)type;

@end
