//
//  NXMCallSubclass.h
//  Stitch_iOS
//
//  Created by Chen Lev on 11/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMCall.h"

@interface NXMCall (NXMCallPrivate)

- (nullable instancetype)initWithStitchContext:(nonnull NXMStitchContext *)stitchContext
                           conversationDetails:(nonnull NXMConversationDetails *)conversationDetails;
@end
