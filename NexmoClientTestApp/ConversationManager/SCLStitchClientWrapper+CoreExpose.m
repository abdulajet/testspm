//
//  SCLStitchClientWrapper+CoreExpose.m
//  StitchClientTestApp
//
//  Created by Doron Biaz on 11/25/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "SCLStitchClientWrapper+CoreExpose.h"

@implementation SCLStitchClientWrapper (CoreExpose)
- (id)coreObject {
    id stitchContext = [self.kommsClient performSelector:NSSelectorFromString(@"stitchContext")];
    id coreClient = [stitchContext performSelector:NSSelectorFromString(@"coreClient")];
    return coreClient;
}

- (void)getConversationsForUser:(nonnull NSString *)userId
                      onSuccess:(void(^ _Nullable)(NSArray<NXMConversationDetails *> * _Nullable conversationsDetails, NXMPageInfo * _Nullable pageInfo))onSuccess
                        onError:(void(^ _Nullable)(NSError * _Nullable error))onError {
    [[self coreObject] getConversationsForUser:userId onSuccess:onSuccess onError:onError];
}
@end
