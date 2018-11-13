//
//  NXMSocketClientDefine.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 2/22/18.
//  Copyright © 2018 Vonage. All rights reserved.
//


static NSString *const kNXMSocketEventConversationGet = @"conversation:get";
static NSString *const kNXMSocketEventLogin = @"session:login";
static NSString *const kNXMSocketEventLogout = @"session:logout";

// events
static NSString *const kNXMSocketEventLoginSuccess = @"session:success";
static NSString *const kNXMSocketEventSessionInvalid = @"session:invalid";
static NSString *const kNXMSocketEventInvalidToken = @"system:error:invalid-token";
static NSString *const kNXMSocketEventExpiredToken = @"system:error:expired-token";
static NSString *const kNXMSocketEventBadPermission = @"system:error:permission";
static NSString *const kNXMSocketEventInvalidEvent = @"system:error:invalid-event";
static NSString *const kNXMSocketEventUserNotFound = @"user:error:not-found";

static NSString *const kNXMSocketEventMemebrMedia = @"member:media"; //android
static NSString *const kNXMSocketEventMemberJoined = @"member:joined";
static NSString *const kNXMSocketEventMemberLeft = @"member:left"; //android
static NSString *const kNXMSocketEventMemberInvited = @"member:invited"; //android

static NSString *const kNXMSocketEventRtcAnswer = @"rtc:answer"; //android
static NSString *const kNXMSocketEventRtcIce = @"rtc:ice";
static NSString *const kNXMSocketEventRtcOffer = @"rtc:offer";
static NSString *const kNXMSocketEventRtcNew = @"rtc:new";
static NSString *const kNXMSocketEventRtcTerminate = @"rtc:terminate";

static NSString *const kNXMSocketEventTextDelivered = @"text:delivered"; //android
static NSString *const kNXMSocketEventTextSeen = @"text:seen"; //android
static NSString *const kNXMSocketEventText = @"text"; //android
static NSString *const kNXMSocketEventTextSuccess = @"text:success";//android
static NSString *const kNXMSocketEventTypingOn = @"text:typing:on"; //android
static NSString *const kNXMSocketEventTypingOff = @"text:typing:off"; //android

static NSString *const kNXMSocketEventImage = @"image"; //android
static NSString *const kNXMSocketEventImageDelivered = @"image:delivered"; //android
static NSString *const kNXMSocketEventImageSeen = @"image:seen"; //android

static NSString *const kNXMSocketEventMessageDelete = @"event:delete"; //android

static NSString *const kNXMSocketEventAudioMuteOn = @"audio:mute:on"; //android
static NSString *const kNXMSocketEventAudioMuteOff = @"audio:mute:off"; //android
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


static NSString *const kNXMSocketEventSipRinging = @"sip:ringing"; //android
static NSString *const kNXMSocketEventSipAnswered = @"sip:answered";
static NSString *const kNXMSocketEventSipHangup = @"sip:hangup";
static NSString *const kNXMSocketEventSipStatus = @"sip:status";

static NSString *const kNXMSocketEventError = @"event:error"; //android

// REST
static NSString *const kNXMConversationCreate = @"new:conversation";
static NSString *const kNXMConversationCreateDone = @"new:conversation:success";



