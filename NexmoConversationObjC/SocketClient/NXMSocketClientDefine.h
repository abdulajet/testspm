//
//  NXMSocketClientDefine.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/22/18.
//  Copyright © 2018 Vonage. All rights reserved.
//


static NSString *const kNXMSocketEventConversationGet = @"conversation:get";
static NSString *const kNXMSocketEventLogin = @"session:login";

// events
static NSString *const kNXMSocketEventLoginSuccess = @"session:success";
static NSString *const kNXMSocketEventSessionInvalid = @"session:invalid";
static NSString *const kNXMSocketEventInvalidToken = @"system:error:invalid-token";
static NSString *const kNXMSocketEventExpiredToken = @"system:error:expired-token";
static NSString *const kNXMSocketEventBadPermission = @"system:error:permission";
static NSString *const kNXMSocketEventInvalidEvent = @"system:error:invalid-event";
static NSString *const kNXMSocketEventUserNotFound = @"user:error:not-found";

static NSString *const kNXMSocketEventMemebrMedia = @"member:media";
static NSString *const kNXMSocketEventMemberJoined = @"member:joined";
static NSString *const kNXMSocketEventMemberLeft = @"member:left";
static NSString *const kNXMSocketEventMemberInvited = @"member:invited";

static NSString *const kNXMSocketEventRtcAnswer = @"rtc:answer";
static NSString *const kNXMSocketEventRtcIce = @"rtc:ice";
static NSString *const kNXMSocketEventRtcOffer = @"rtc:offer";
static NSString *const kNXMSocketEventRtcNew = @"rtc:new";
static NSString *const kNXMSocketEventRtcTerminate = @"rtc:terminate";

static NSString *const kNXMSocketEventTextDelivered = @"text:delivered";
static NSString *const kNXMSocketEventTextSeen = @"text:seen";
static NSString *const kNXMSocketEventText = @"text";
static NSString *const kNXMSocketEventTypingOn = @"text:typing:on";
static NSString *const kNXMSocketEventTypingOff = @"text:typing:off";

static NSString *const kNXMSocketEventImage = @"image";
static NSString *const kNXMSocketEventImageDelivered = @"image:delivered";
static NSString *const kNXMSocketEventImageSeen = @"image:seen";

static NSString *const kNXMSocketEventAudioMuteOn = @"audio:mute:on";
static NSString *const kNXMSocketEventAudioMuteOff = @"audio:mute:off";
static NSString *const kNXMSocketEventAudioPlay = @"audio:play";
static NSString *const kNXMSocketEventAudioPlayDone = @"audio:play:done";
static NSString *const kNXMSocketEventAudioSay = @"audio:say";
static NSString *const kNXMSocketEventAudioSayDone = @"audio:say:done";
static NSString *const kNXMSocketEventAudioRecord = @"audio:record";
static NSString *const kNXMSocketEventAudioSayRecordDone = @"audio:record:done";
static NSString *const kNXMSocketEventAudioDtmf = @"audio:dtmf";
static NSString *const kNXMSocketEventAudioEarmuffOn = @"audio:earmuff:on";
static NSString *const kNXMSocketEventAudioEarmuffOff = @"audio:earmuff:off";
static NSString *const kNXMSocketEventAudioSpeakingOn = @"audio:speaking:on";
static NSString *const kNXMSocketEventAudioSpeakingOff = @"audio:speaking:off";

static NSString *const kNXMSocketEventSipHangup = @"sip:hangup";

static NSString *const kNXMSocketEventError = @"event:error";

static NSString *const kNXMSocketEventDelete = @"event:delete";

