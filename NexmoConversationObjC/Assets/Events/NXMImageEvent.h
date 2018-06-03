//
//  NXMImageEvent.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 6/3/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEvent.h"
#import "NXMImageInfo.h"

@interface NXMImageEvent : NXMEvent
@property (nonatomic, strong, nonnull) NSString *imageId;
@property (nonatomic, strong, nonnull) NXMImageInfo *mediumImage;
@property (nonatomic, strong, nonnull) NXMImageInfo *originalImage;
@property (nonatomic, strong, nonnull) NXMImageInfo *thumbnailImage;
@end
