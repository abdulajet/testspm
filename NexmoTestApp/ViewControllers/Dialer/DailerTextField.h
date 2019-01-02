//
//  DailerTextField.h
//  NexmoTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DialerCopyLabelUpdatedDelegate <NSObject>

@optional
- (void)updateInfoLabels;
- (void)menuDidShow;
- (void)menuDidHide;

@end


@interface DailerTextField : UITextField

@property (weak, nonatomic) id <DialerCopyLabelUpdatedDelegate> updateDialerDelegate;
@property (strong, nonatomic) NSCharacterSet *acceptedCharacters;
@property (strong, nonatomic) UITextRange *currentCursorRange;

- (void)appendDigit:(NSString *)digitToAppend;
- (void)deleteDigit;
- (void)backupCursorLocation;
- (void)restoreCursorLocation;
- (void)clearCursor;


@end

