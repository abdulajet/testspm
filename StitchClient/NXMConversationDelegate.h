//
//  NXMConversationDelegate.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StitchCore/StitchCore.h>

@protocol NXMConversationDelegate <NSObject> //TODO: devrel this delegate
@optional
-(void)textEvent:(NXMMessageEvent *)textEvent;
-(void)attachmentEvent:(NXMMessageEvent *)attachmentEvent;
-(void)messageStatusEvent:(NXMMessageStatusEvent *)messageStatusEvent;
-(void)mediaEvent:(NXMEvent *)mediaEvent;
-(void)typingEvent:(NXMTextTypingEvent *)typingEvent;
-(void)memberEvent:(NXMMemberEvent *)memberEvent;
@end
