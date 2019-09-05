//
//  NXMImageInfo.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 6/3/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMImageInfo.h"

@implementation NXMImageInfo

- (nullable instancetype)initWithId:(nonnull NSString *)imageId size:(NSInteger)size url:(nonnull NSURL *)url type:(NXMImageSize)type {
    if (self = [super init]) {
        self.imageUuid = imageId;
        self.sizeInBytes = size;
        self.url = url;
        self.size = type;
    }
    
    return self;
}
@end
