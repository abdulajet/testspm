//
//  CallObject.m
//  iOSFramework
//
//  Created by Guy Mininberg on 4/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "MRTCMedia.h"
//#import "MRTCCommonMediaManager.h"
//#import "VxLog.h"

//#undef __CLASS__
//#define __CLASS__ "MRTCMediaInfo"
@interface MRTCMediaInfo()
@end

@implementation MRTCMediaInfo
-(instancetype) initWith:(NSString *)conversationId andWith:(NSString *)memeberId andWith:(NSString *)mediaId
{
    //LOG_SCOPE();
    self = [super init];
    if(self)
    {
        self._conversationId = conversationId;
        self._memberId = memeberId;
        self._mediaId = mediaId;
    }
    return self;
}
@end

#undef __CLASS__
#define __CLASS__ "MRTCMediaManager"

@interface MRTCMediaManager()
{
  //  MRTCCommonMediaManagerPtr commonMediaManager;
}
@property (nonatomic, nullable, assign) id <MRTCMediaManagerDelegate> delegate;
@end

@implementation MRTCMediaManager
id thisClass;
@synthesize delegate = _delegate;

-(instancetype)init
{
//    LOG_SCOPE();
    self = [super init];
    if(self)
    {
//        commonMediaManager = std::make_shared<MRTCCommonMediaManager>(std::bind(&sendSDP, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3, std::placeholders::_4), std::bind(&mediaStatusChange, std::placeholders::_1));
//        _network = network;
//        thisClass = self;
    }
    return self;
}

-(void) sendSDP:(NSString*)sdp andConversationId:(NSString*)conversationId andMemberId:(NSString*)memeberId andMediaId:(NSString*)mediaId
{
//    if(!_network)
//    {
//        LOG_ERROR("network null");
//    }
//    MRTCMediaInfo* mediaInfo = [[MRTCMediaInfo alloc]initWith:conversationId andWith:memeberId andWith:mediaId];
//    [_network sendSDP:sdp andMediaInfo:mediaInfo andComplitionHandler:^(NSError * err) {
//
//    }];
}

-(void) mediaStatusChange:(NSString*)status
{
//    if(_delegate)
//    {
//        LOG_ERROR("delegate null");
//    }
//    [_delegate onMediaStatusChange:status];
}

void sendSDP(const char * sdp, const char * conversationId, const char * memeberId, const char * mediaId)
{
//    @autoreleasepool
//    {
//        if(thisClass)
//        {
//            [thisClass sendSDP:[NSString stringWithUTF8String:sdp] andConversationId:[NSString stringWithUTF8String:conversationId] andMemberId:[NSString stringWithUTF8String:memeberId] andMediaId:[NSString stringWithUTF8String:mediaId]];
//        }
//    }
}

void mediaStatusChange(const char * status)
{
    @autoreleasepool
    {
        if(thisClass)
        {
            [thisClass mediaStatusChange:[NSString stringWithUTF8String:status]];
        }
    }
}

-(void)setDelegate:(id<MRTCMediaManagerDelegate>)delegate
{
    _delegate = delegate;
}

-(void) destroyRTCMediaManager
{
//    LOG_SCOPE();
//    commonMediaManager = nullptr;
}

-(void) enableMediaWithMediaID:(MRTCMediaInfo *)mediaInfo andWithAudio:(MRTCMediaManagerRTPStramType)audiostream andWithVideo:(MRTCMediaManagerRTPStramType)videoStream
{
//    LOG_SCOPE([mediaId UTF8String], audiostream, videoStream);
//    commonMediaManager->enableMedia([[mediaInfo _memberId] UTF8String], audiostream, videoStream);
}

-(void) answerWithMediaId:(NSString *)mediaId andSDP:(NSString *)sdp
{
//    LOG_SCOPE([mediaId UTF8String], [sdp UTF8String]);
//    commonMediaManager->answer([mediaId UTF8String], [sdp UTF8String]);
}

-(void) addMemberWithMediaId:(NSString *)mediaId andSdp:(NSString *)sdp
{
//    LOG_SCOPE([mediaId UTF8String], [sdp UTF8String]);
//    commonMediaManager->addMember([mediaId UTF8String], [sdp UTF8String]);
}

-(void) updateMediaMediaId:(NSString *)mediaId andWithAudio:(MRTCMediaManagerRTPStramType)audioStream andWithVideo:(MRTCMediaManagerRTPStramType)videoStream
{
//    LOG_SCOPE([mediaId UTF8String], audioStream, videoStream);
//    commonMediaManager->updateMedia([mediaId UTF8String], audioStream, videoStream);
}

-(void) holdWithMediaId:(NSString *)mediaId
{
//    LOG_SCOPE([mediaId UTF8String]);
//    commonMediaManager->hold([mediaId UTF8String]);
}

-(void) suspendMediaId:(NSString *)mediaId andNedia:(MRTCMediaManagerMediaType)type
{
//    LOG_SCOPE([mediaId UTF8String], type);
//    commonMediaManager->suspendMedia([mediaId UTF8String], type == MRTCMediaManagerMediaType_Audio ? NSCommonRTC::Audio_e : NSCommonRTC::Video_e);
}

-(void) resumeMediaId:(NSString *)mediaId andNedia:(MRTCMediaManagerMediaType)type
{
//    LOG_SCOPE([mediaId UTF8String], type);
//    commonMediaManager->resumeMedia([mediaId UTF8String], type == MRTCMediaManagerMediaType_Audio ? NSCommonRTC::Audio_e : NSCommonRTC::Video_e);
}

@end
