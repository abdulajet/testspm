//
//  NXMConversationEventsController.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMCoreEvents.h"

@class NXMConversationEventsController;

@protocol NXMConversationEventsControllerDelegate <NSObject>

typedef NS_ENUM(NSUInteger, NXMConversationEventsControllerChangeType) {
    NXMConversationEventsControllerChangeInsert = 1,
    NXMConversationEventsControllerChangeDelete = 2,
    NXMConversationEventsControllerChangeMove = 3,
    NXMConversationEventsControllerChangeUpdate = 4
};

@optional
- (void)nxmConversationEventsController:(NXMConversationEventsController *_Nonnull)controller didChangeEvent:(NXMEvent*_Nonnull)anEvent atIndex:(NSUInteger)index forChangeType:(NXMConversationEventsControllerChangeType)type newIndex:(NSUInteger)newIndex;

@optional
- (void)nxmConversationEventsControllerWillChangeContent:(NXMConversationEventsController *_Nonnull)controller;

@optional
- (void)nxmConversationEventsControllerDidChangeContent:(NXMConversationEventsController *_Nonnull)controller;

@end

@interface NXMConversationEventsController : NSObject

@property (nonatomic,weak) _Nullable id <NXMConversationEventsControllerDelegate> delegate;
@property (nonatomic,strong,readonly)NSArray<NXMEvent*>* _Nonnull events;

-(void)loadEarlierEventsWithMaxAmount:(NSUInteger)maxAmount completion:(void (^_Nullable)(NSError * _Nullable error))completion;
@end
