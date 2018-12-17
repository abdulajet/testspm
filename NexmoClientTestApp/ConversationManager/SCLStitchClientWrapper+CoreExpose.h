//
//  SCLStitchClientWrapper+CoreExpose.h
//  StitchClientTestApp
//
//  Created by Doron Biaz on 11/25/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "SCLStitchClientWrapper.h"

@interface SCLStitchClientWrapper (CoreExpose)
- (id)coreObject;

- (void)getConversationsForUser:(nonnull NSString *)userId
                      onSuccess:(void(^ _Nullable)(NSArray<NXMConversationDetails *> * _Nullable conversationsDetails, NXMPageInfo * _Nullable pageInfo))onSuccess
                        onError:(void(^ _Nullable)(NSError * _Nullable error))onError;
@end
