//
//  NXMImageInfo.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 6/3/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NXMImageType) {
    NXMImageTypeMedium,
    NXMImageTypeOriginal,
    NXMImageTypeThumbnail
};

@interface NXMImageInfo : NSObject
@property (nonatomic, strong, nonnull) NSString *uuid;
@property (nonatomic, strong, nonnull) NSURL *url;
@property NSInteger size;
@property NXMImageType type;

- (nullable instancetype)initWithUuid:(nonnull NSString *)uuid size:(NSInteger)size url:(nonnull NSURL *)url type:(NXMImageType)type;

@end
