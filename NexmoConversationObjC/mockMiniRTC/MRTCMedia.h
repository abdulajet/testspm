//
//  CallObject.h
//  iOSFramework
//
//  Created by Guy Mininberg on 4/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTCMediaInfo : NSObject
- (instancetype)initWith:(NSString*)conversationId andWith:(NSString*)memeberId andWith:(NSString*)mediaId;

@property NSString* _conversationId;
@property NSString* _memberId;
@property NSString* _mediaId;
@end

@protocol MRTCMediaManagerDelegate
- (void)onMediaStatusChange:(NSString *)status;
- (void)sendSDP:(NSString*)sdp andMediaInfo:(MRTCMediaInfo*)mediaInfo andCompletionHandler:(void (^)(NSError *))completionHandler;
@end

@interface MRTCMediaManager : NSObject

typedef NS_ENUM(NSInteger, MRTCMediaManagerMediaType) {
    MRTCMediaManagerMediaType_Audio,
    MRTCMediaManagerMediaType_Video,
};

typedef NS_ENUM(NSInteger, MRTCMediaManagerRTPStramType) {
    MRTCMediaManagerRTPStramType_None,
    MRTCMediaManagerRTPStramType_Send,
    MRTCMediaManagerRTPStramType_Receive,
    MRTCMediaManagerRTPStramType_SendReceive
};

- (instancetype)init;

- (void)setDelegate:(id<MRTCMediaManagerDelegate>)delegate;

- (void)destroyRTCMediaManager;

- (void)enableMediaWithMediaID:(MRTCMediaInfo*)mediaInfo andWithAudio:(MRTCMediaManagerRTPStramType)audiostream andWithVideo:(MRTCMediaManagerRTPStramType)videoStream;
- (void) answerWithMediaId:(NSString*)mediaId andSDP:(NSString*)sdp;

- (void)addMemberWithMediaId:(NSString*)mediaId andSdp:(NSString*)sdp;
- (void)updateMediaMediaId:(NSString*)mediaId andWithAudio:(MRTCMediaManagerRTPStramType)audioStream andWithVideo:(MRTCMediaManagerRTPStramType)videoStream;

- (void)holdWithMediaId:(NSString*)mediaId;
- (void)suspendMediaId:(NSString*)mediaId andNedia:(MRTCMediaManagerMediaType)type;
- (void)resumeMediaId:(NSString*)mediaId andNedia:(MRTCMediaManagerMediaType)type;

@end

