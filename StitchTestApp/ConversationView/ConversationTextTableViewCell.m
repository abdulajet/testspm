//
//  ConversationTextTableViewCell.m
//  StitchTestApp
//
//  Created by Chen Lev on 5/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ConversationTextTableViewCell.h"
#import "NXMTextEvent.h"
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSUInteger, BubbleColor) {
    BubbleColorBlue,
    BubbleColorOrange
};

@interface ConversationTextTableViewCell()

@property (strong, nonatomic) IBOutlet UILabel *fromLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageText;
@property (strong, nonatomic) IBOutlet UIImageView *bubbleImage;

//@property (nonatomic, assign) BubbleColor bubbleColor;
@property (nonatomic, assign) SenderType senderType;

@end
@implementation ConversationTextTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
//        _bubbleView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        _bubbleView.userInteractionEnabled = YES;
//        [self.contentView addSubview:_bubbleView];
//        self.bubbleImage.userInteractionEnabled = YES;
        
        self.fromLabel.backgroundColor = [UIColor clearColor];
        self.fromLabel.numberOfLines = 0;
        self.fromLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.fromLabel.textColor = [UIColor blackColor];
        self.fromLabel.font = [self nameFont];
        
        self.messageText.backgroundColor = [UIColor clearColor];
        self.messageText.numberOfLines = 0;
        self.messageText.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageText.textColor = [UIColor blackColor];
        self.messageText.font = [self textFont];
        
//        self.imageView.userInteractionEnabled = YES;
//        self.imageView.layer.cornerRadius = 5.0;
//        self.imageView.layer.masksToBounds = YES;
        
//        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
//        [_bubbleView addGestureRecognizer:longPressRecognizer];
        
//        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//        [self.imageView addGestureRecognizer:tapRecognizer];
        
        // Defaults
//        _selectedBubbleColor = STBubbleTableViewCellBubbleColorAqua;
//        _canCopyContents = YES;
//        _selectionAdjustsColor = YES;
    }
    
    return self;
}

- (void)layoutSubviews {
    [self updateFrames];
}

- (void)updateFrames {
    [self setImageForSenderType:self.senderType];
    
//    CGFloat minInset = 50.0f;
//    if([self.dataSource respondsToSelector:@selector(minInsetForCell:atIndexPath:)])
//    {
//        minInset = [self.dataSource minInsetForCell:self atIndexPath:[[self tableView] indexPathForCell:self]];
//    }
    
//    CGSize size = [self.messageText.text boundingRectWithSize:CGSizeMake(self.frame.size.width - minInset - kBubbleWidthOffset, CGFLOAT_MAX)
//                                                      options:NSStringDrawingUsesLineFragmentOrigin
//                                                   attributes:@{NSFontAttributeName:self.messageText.font}
//                                                      context:nil].size;
    CGSize nameSize = CGSizeZero;
    if (self.fromLabel.text.length) {
        nameSize = [self.fromLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:[self nameFont]}
                                                     context:nil].size;
    }
    
    CGSize textSize = [self.messageText.text boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:[self textFont]}
                                                          context:nil].size;
    
    CGFloat labelsWidth = nameSize.width > textSize.width ? nameSize.width : textSize.width;
    CGSize totalSize = CGSizeMake(labelsWidth, nameSize.height + textSize.height);
    if (self.senderType == SenderTypeOther) {
        self.bubbleImage.frame = CGRectMake(self.frame.size.width - (totalSize.width + kBubbleWidthOffset), 0.0f, totalSize.width + kBubbleWidthOffset, totalSize.height + 20.0f);
        //    self.textLabel.frame = CGRectMake(self.frame.size.width - (size.width + STBubbleWidthOffset - 10.0f), 6.0f, size.width + STBubbleWidthOffset - 23.0f, size.height);
        self.fromLabel.frame = CGRectMake(self.frame.size.width - (totalSize.width + kBubbleWidthOffset - 10.0f), 6.0f, totalSize.width, totalSize.height);
        self.messageText.frame = CGRectMake(self.frame.size.width - (totalSize.width + kBubbleWidthOffset - 10.0f), 26.0f, totalSize.width, totalSize.height);
//        self.messageText.frame = CGRectMake(20.0f, 26.0f, totalSize.width, totalSize.height);
        
        self.fromLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.messageText.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.bubbleImage.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.bubbleImage.transform = CGAffineTransformIdentity;
    } else {
//        self.bubbleImage.frame = CGRectMake(0.0f, 0.0f, size.width + kBubbleWidthOffset, size.height + 15.0f);
//        self.messageText.frame = CGRectMake(16.0f, 6.0f, size.width + kBubbleWidthOffset - 23.0f, size.height);
        self.bubbleImage.frame = CGRectMake(0.0f, 0.0f, totalSize.width + kBubbleWidthOffset, totalSize.height + 20.0f);
        self.fromLabel.frame = CGRectZero; // CGRectMake(20.0f, 6.0f, totalSize.width, totalSize.height);
//        self.messageText.frame = CGRectMake(20.0f, 26.0f, totalSize.width, totalSize.height);
        self.messageText.frame = CGRectMake(20.0f, 6.0f, totalSize.width, totalSize.height);
        
        self.fromLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.messageText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.bubbleImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.bubbleImage.transform = CGAffineTransformIdentity;
        self.bubbleImage.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
    }
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

- (void)updateWithEvent:(NXMEvent *)event senderType:(SenderType)senderType {
//    NSString* str = [[NSString alloc] initWithFormat:@"conversationId:%@ type:%ld id:%@",event.conversationId,(long)event.type,event.sequenceId];
//    self.messageText.text = str;
//    if (event.type == NXMEventTypeText) {
//        self.toText.text = ((NXMTextEvent *)event).text;
//    }
    
    self.fromLabel.text = [self userNameForMemberId:event.fromMemberId];
    if (event.type == NXMEventTypeText) {
        self.messageText.text = ((NXMTextEvent *)event).text;
        self.senderType = senderType;
    }
}

#pragma mark - Setters

- (void)setSenderType:(SenderType)senderType {
    _senderType = senderType;
    [self setImageForSenderType:_senderType];
}

#pragma mark - Helper Methods

- (void)setImageForSenderType:(SenderType)senderType {
    NSString *imageName = (senderType == SenderTypeSelf) ? @"bubbleBlue" : @"bubbleOrange";
    UIEdgeInsets insets = UIEdgeInsetsMake(12.0f, 20.0f, 12.0f, 20.0f);
    self.bubbleImage.image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:insets];
}

- (NSString *)userNameForMemberId:(NSString *)memberId {
    return (self.senderType == SenderTypeSelf) ? @"" : memberId;
}

- (UIFont *)textFont {
    return [UIFont systemFontOfSize:14.0];
}

- (UIFont *)nameFont {
    return [UIFont boldSystemFontOfSize:14.0];
}

@end
