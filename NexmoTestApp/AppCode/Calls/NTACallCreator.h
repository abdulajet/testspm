//
//  CallCreator.h
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/19/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <NexmoClient/NexmoClient.h>

@protocol CallCreator
- (void)callWithDelegate:(id<NXMCallDelegate>_Nullable)delegate completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completion;
@end

