//
//  NXMConversationDelegate.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMCoreEvents.h"

@protocol NXMConversationDelegate <NSObject> //TODO: devrel this delegate
@optional
-(void)textEvent:(NXMMessageEvent *)textEvent;
-(void)attachmentEvent:(NXMMessageEvent *)attachmentEvent;
-(void)messageStatusEvent:(NXMMessageStatusEvent *)messageStatusEvent;
//TODO: I think this should change to -(void)mediaEvent:(NXMMediaEvent *)mediaEvent;
-(void)mediaEvent:(NXMEvent *)mediaEvent;
-(void)typingEvent:(NXMTextTypingEvent *)typingEvent;
-(void)memberEvent:(NXMMemberEvent *)memberEvent;
@end
