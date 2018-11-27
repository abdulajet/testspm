//
//  OnGoingCallsCollectionViewCell.m
//  StitchTestApp
//
//  Created by Doron Biaz on 8/13/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "OnGoingCallsCollectionViewCell.h"

@interface OnGoingCallsCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property BOOL isAudioEnabled;
@property OngoingMedia *media;
@end


@implementation OnGoingCallsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)updateWithConversationManager:(ConversationManager *)conversationManager andOngoingMedia:(OngoingMedia *)media{
    self.conversationManager = conversationManager;
    self.media = media;
    self.nameLabel.text = self.conversationManager.memberIdToName[media.memberId];
    self.isAudioEnabled = media.enabled && !media.suspended;
    [self.audioButton setImage: [UIImage imageNamed:self.isAudioEnabled ? @"ongoingCallsMemberAudioMuteOff" : @"ongoingCallsMemberAudioMuteOn"] forState:UIControlStateNormal];
    self.backgroundColor = [UIColor greenColor];
    if([self isCurrentUser]) {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"ongoingCallsCurrentUserIcon"]];
    } else {
        [self.backgroundImageView setImage:nil];
    }
}


- (IBAction)didAudioButtonPressed:(id)sender {
    if(self.isAudioEnabled) {
        [self sendMute];
    } else {
        [self sendUnMute];
    }
}

-(void)sendMute {
    if([self isCurrentUser]) {
        [self.conversationManager.stitchConversationClient suspendMyMedia:NXMMediaTypeAudio inConversation:self.media.conversationId];
    } else {
        [self.conversationManager.stitchConversationClient suspendMedia:NXMMediaTypeAudio ofMember:self.media.memberId inConversation:self.media.conversationId fromMember:[self getCurrentMember]
            onSuccess:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.backgroundColor = [UIColor greenColor];
                });
            }
            onError:^(NSError * _Nullable error) {
                self.backgroundColor = [UIColor yellowColor];
            }];
    }
}

-(void)sendUnMute {
    if([self isCurrentUser]) {
        [self.conversationManager.stitchConversationClient resumeMyMedia:NXMMediaTypeAudio inConversation:self.media.conversationId];
    } else {
        [self.conversationManager.stitchConversationClient resumeMedia:NXMMediaTypeAudio ofMember:self.media.memberId inConversation:self.media.conversationId fromMember:[self getCurrentMember]
            onSuccess:^{
              dispatch_async(dispatch_get_main_queue(), ^{
                  self.backgroundColor = [UIColor greenColor];
              });
            }
            onError:^(NSError * _Nullable error) {
                self.backgroundColor = [UIColor redColor]; //TODO make it animated flashing yellow for one second and then turn back to green
        }];
    }
}

-(bool)isCurrentUser {
    return [self.conversationManager isCurrentUserThisMember:self.media.memberId];
}

-(NSString *)getCurrentMember {
    return [self.conversationManager.conversationIdToMemberId objectForKey:self.media.conversationId];
}
@end
