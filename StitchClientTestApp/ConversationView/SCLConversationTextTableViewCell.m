//
//  ConversationTextTableViewCell.m
//  StitchTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "SCLConversationTextTableViewCell.h"

#import <QuartzCore/QuartzCore.h>
#import <StitchClient/StitchClient.h>


typedef NS_ENUM(NSUInteger, SCLBubbleColor) {
    SCLBubbleColorBlue,
    SCLBubbleColorOrange
};

@interface SCLConversationTextTableViewCell()

@property (strong, nonatomic) IBOutlet UILabel *fromLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageText;
@property (strong, nonatomic) IBOutlet UIImageView *bubbleImage;
@property (weak, nonatomic) IBOutlet UIImageView *messageStatusImage;
@property (weak, nonatomic) IBOutlet UILabel *messageStatusLabel;

//@property (nonatomic, assign) BubbleColor bubbleColor;
@property (nonatomic, assign) SCLSenderType senderType;

@end
@implementation SCLConversationTextTableViewCell

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
    CGSize boundSize = CGSizeMake(self.frame.size.width / 2.0f, CGFLOAT_MAX);
    if (self.fromLabel.text.length) {
        nameSize = [self.fromLabel.text boundingRectWithSize:boundSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:[self nameFont]}
                                                     context:nil].size;
    }
    
    CGSize textSize = [self.messageText.text boundingRectWithSize:boundSize
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:[self textFont]}
                                                          context:nil].size;
    
    CGFloat labelsWidth = nameSize.width > textSize.width ? nameSize.width : textSize.width;
    CGSize totalSize = CGSizeMake(labelsWidth + 10.0f, nameSize.height + textSize.height);
    if (self.senderType == SCLSenderTypeOther) {
        self.bubbleImage.frame = CGRectMake(self.frame.size.width - (totalSize.width + kBubbleWidthOffset), 0.0f, totalSize.width + kBubbleWidthOffset, totalSize.height + 20.0f);

        self.fromLabel.frame = CGRectMake(self.frame.size.width - (totalSize.width + kBubbleWidthOffset - 10.0f), 6.0f, totalSize.width, nameSize.height);
        self.messageText.frame = CGRectMake(self.frame.size.width - (totalSize.width + kBubbleWidthOffset - 10.0f), self.fromLabel.frame.size.height + 5.0f, totalSize.width, textSize.height);
        
        self.fromLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.messageText.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.bubbleImage.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.bubbleImage.transform = CGAffineTransformIdentity;
    } else {

        self.bubbleImage.frame = CGRectMake(0.0f, 0.0f, totalSize.width + kBubbleWidthOffset, totalSize.height + 20.0f);
        self.fromLabel.frame = CGRectZero; // CGRectMake(20.0f, 6.0f, totalSize.width, totalSize.height);
        self.messageText.frame = CGRectMake(10.0f, 6.0f, totalSize.width, totalSize.height + 5.0f);
        
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


- (void)updateWithEvent:(NXMEvent *)event
             senderType:(SCLSenderType)senderType
             memberName:(NSString *)memberName
          messageStatus:(SCLConversationTableCellMessageStatus)status {
    if (event.type == NXMEventTypeText) {
        NXMTextEvent *eventText = ((NXMTextEvent *)event);
        self.messageText.text = eventText.text;
        self.senderType = senderType;
        self.fromLabel.text = (senderType == SCLSenderTypeSelf) ? @"" : ([memberName length] == 0 ? eventText.fromMemberId : memberName);
        
        self.messageStatusImage.image = [[UIImage alloc] init];
        self.messageStatusLabel.text = @"";
        if (status == SCLConversationTableCellMessageStatusSeen) {
            self.messageStatusImage.image = [UIImage imageNamed:@"messageStatusSeen"];
            self.messageStatusLabel.text = @"Seen";
        } else if (status == SCLConversationTableCellMessageStatusDelivered) {
            self.messageStatusImage.image = [UIImage imageNamed:@"messageStatusDelivered"];
            self.messageStatusLabel.text = @"Delivered";
        } else
        if (status == SCLConversationTableCellMessageStatusDeleted) {
            self.messageText.text = @"Deleted";
        }
    }
    //TODO:make this present images
    if (event.type == NXMEventTypeImage) {
        NXMImageEvent *eventText = ((NXMImageEvent *)event);
        self.messageText.text = @"image: ";
        self.senderType = senderType;
        self.fromLabel.text = (senderType == SCLSenderTypeSelf) ? @"" : ([memberName length] == 0 ? eventText.fromMemberId : memberName);
        
        self.messageStatusImage.image = [[UIImage alloc] init];
        self.messageStatusLabel.text = @"";
        if (status == SCLConversationTableCellMessageStatusSeen) {
            self.messageStatusImage.image = [UIImage imageNamed:@"messageStatusSeen"];
            self.messageStatusLabel.text = @"Seen";
        } else if (status == SCLConversationTableCellMessageStatusDelivered) {
            self.messageStatusImage.image = [UIImage imageNamed:@"messageStatusDelivered"];
            self.messageStatusLabel.text = @"Delivered";
        } else
        if (status == SCLConversationTableCellMessageStatusDeleted) {
            self.messageText.text = @"Deleted";
            [self.messageText setTextColor:UIColor.grayColor];
        }
    }

}

#pragma mark - Setters

- (void)setSenderType:(SCLSenderType)senderType {
    _senderType = senderType;
    [self setImageForSenderType:_senderType];
}

#pragma mark - Helper Methods

- (void)setImageForSenderType:(SCLSenderType)senderType {
    NSString *imageName = (senderType == SCLSenderTypeSelf) ? @"bubbleDefault" : @"bubbleBlue";
    UIEdgeInsets insets = UIEdgeInsetsMake(12.0f, 20.0f, 12.0f, 20.0f);
    self.bubbleImage.image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:insets];
}

- (UIFont *)textFont {
    return [UIFont systemFontOfSize:14.0];
}

- (UIFont *)nameFont {
    return [UIFont boldSystemFontOfSize:14.0];
}

@end
