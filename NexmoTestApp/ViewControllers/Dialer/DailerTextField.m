//
//  DailerTextField.m
//  NexmoTestApp
//
//  Created by Chen Lev on 12/27/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "DailerTextField.h"

@implementation DailerTextField

NSString * const ASTERIX_SIGN = @"10";
NSString * const HASH_SIGN = @"11";

#pragma mark - Public

- (void)appendDigit:(NSString *)digitToAppend
{
    NSString *str = nil;
    NSInteger numOfDigitsToTheLeft = [self numOfDigitsToTheLeft];
    if ([digitToAppend isEqualToString:ASTERIX_SIGN]) {
        digitToAppend = @"*";
    }
    if ([digitToAppend isEqualToString:HASH_SIGN]) {
        digitToAppend = @"#";
    }
    
    // nothing is written - we just add the digit
    if (self.text == nil || [self.text length] == 0) {
        str = digitToAppend;
    }
    // the cursor is on - we append where the cursor is
    else if ([self cursorOn]) {
        NSMutableString *mu = [NSMutableString stringWithString:self.text];
        // no range chosen - we put the digit where the cursor is
        if ([self cursorBlinkingMode]) {
            [mu insertString:digitToAppend atIndex:[self cursorLocation]];
        }
        // range selected - we replace the selected range with our digit
        else {
            [mu replaceCharactersInRange:[self cursorRange]
                              withString:digitToAppend];
        }
        str = mu;
    }
    // the cursor is off - we append at the end
    else {
        str = [self.text stringByAppendingString:digitToAppend];
    }
    
    self.text = str;
    
    // updating the cursor location if needed
    [self setNewCursorLocationWithOffset:1
                       numOfDigitsBefore:numOfDigitsToTheLeft];
}

- (void)deleteDigit
{
    NSString *str = self.text;
    NSInteger numOfDigitsToTheLeft = [self numOfDigitsToTheLeft];
    NSInteger offsetForCursor = 0; // in some cases no need to update the cursor location
    
    if ([str length] > 0) {
        // the cursor is on - we delete where the cursor is
        if ([self cursorOn]) {
            // no range chosen - we delete the digit where the cursor is
            if ([self cursorBlinkingMode]) {
                str = [self deleteDigitWhenCursorBlinking];
                offsetForCursor = -1; // take the cursor 1 step left
            }
            // range selected - we delete the selected range
            else {
                str = [str stringByReplacingCharactersInRange:[self cursorRange] withString:@""];
            }
        }
        // the cursor is off - we delete at the end
        else {
            str = self.text;
            str = [str substringToIndex:([str length] - 1)];
        }
    }
    
    self.text = str;
    
    
    // updating the cursor location if needed
    [self setNewCursorLocationWithOffset:offsetForCursor
                       numOfDigitsBefore:numOfDigitsToTheLeft];
    
    if (![self.text length])
    {
        [self clearCursor];
    }
}

- (void)backupCursorLocation
{
    self.currentCursorRange = self.selectedTextRange;
}
- (void)restoreCursorLocation
{
    [self setSelectedTextRange:self.currentCursorRange];
}

- (void)clearCursor
{
    [self endEditing:YES];
}

- (NSString *)deleteDigitWhenCursorBlinking
{
    NSString *str = self.text;
    NSString *strBeforeDeleting = [NSString stringWithString:str];
    NSInteger location = [self cursorLocation];
    // we itterate until we delete an actual number (there is a way we delete a charachter from the phone formatting like '-')
    while (location && [str isEqualToString:strBeforeDeleting]) {
        str = [str stringByReplacingCharactersInRange:NSMakeRange(location - 1, 1) withString:@""];
        location--;
    }
    return str;
}

#pragma mark - UITextViewDelegate

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(paste:) && [self canPerformPaste])
    || (action == @selector(copy:) && [self canPerformCopy])
    || (action == @selector(select:) && [self canPerformSelect])
    || (action == @selector(selectAll:) && [self canPerformSelect])
    || (action == @selector(cut:) && [self canPerformCopy]);
}

- (void)cut:(id)sender
{
    NSInteger numOfDigitToTheLeft = [self numOfDigitsToTheLeft];
    [super cut:sender];
    
    [self.updateDialerDelegate updateInfoLabels];
    [self setNewCursorLocationWithOffset:0 numOfDigitsBefore:numOfDigitToTheLeft];
}

- (void)paste:(id)sender
{
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    
    NSString *boardString = [gpBoard string];
    
    if (boardString != nil)
    {
        NSInteger numOfDigitsToTheLeft = [self numOfDigitsToTheLeft];
        NSString *strippedString = [self strippedString:boardString];
        
        
        if ([strippedString length] > 0 && [self cursorOn])
        {
            NSMutableString *mu = [NSMutableString stringWithString:self.text];
            // no range
            if ([self cursorBlinkingMode]) {
                [mu insertString:strippedString
                         atIndex:[self cursorLocation]];
            }
            // range
            else {
                [mu replaceCharactersInRange:[self cursorRange]
                                  withString:strippedString];
            }

            [self setNewCursorLocationWithOffset:[strippedString length]
                               numOfDigitsBefore:numOfDigitsToTheLeft];
        }
      
    }
    
    
    if ([self.updateDialerDelegate respondsToSelector:@selector(updateInfoLabels)]) {
        [self.updateDialerDelegate updateInfoLabels];
    }
    
    //tells the delegate that the menu is not visible now
    if ([self.updateDialerDelegate respondsToSelector:@selector(menuDidHide)]) {
        [self.updateDialerDelegate menuDidHide];
    }
}

- (UIKeyboardType)keyboardType
{
    return UIKeyboardTypeASCIICapable;
}
#pragma mark - Private

- (BOOL)canPerformCopy
{
    return [self cursorOn] && [self cursorRangeLength];
}

- (BOOL)canPerformSelect
{
    return [self.text length] && ![self cursorRangeLength];
}

- (BOOL)canPerformPaste
{
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    BOOL containNumbers = NO;
    
    NSString *boardString = [gpBoard string];
    
    if (boardString != nil) {
        NSString *strippedString = [self strippedString:boardString];
        
        containNumbers = ([strippedString length] > 0);
    }
    
    return containNumbers;
}

- (NSString *)strippedString:(NSString *)unstrippedString
{
    NSMutableString *strippedString = [NSMutableString stringWithCapacity:unstrippedString.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:unstrippedString];
    NSString *buffer = nil;
    
    while ([scanner isAtEnd] == NO) {
        if ([scanner scanCharactersFromSet:self.acceptedCharacters
                                intoString:&buffer]) {
            [strippedString appendString:buffer];
        }
        else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    
    return strippedString;
}

#pragma mark - cursor controlling

- (BOOL)cursorOn
{
    BOOL editing = [self isEditing];
    return editing;
}

- (NSInteger)numOfDigitsToTheLeft
{
    UITextRange *cursorRange = self.selectedTextRange;
    if (![self cursorOn]) {
        return 0;
    }
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument
                                       toPosition:cursorRange.start];
    return [self numOfDigitFromStartOfString:self.text
                                    toOffset:location];
}

- (BOOL)cursorBlinkingMode
{
    UITextRange *cursorRange = self.selectedTextRange;
    if (![self cursorOn]) {
        return YES;
    }
    return ![self offsetFromPosition:cursorRange.start
                          toPosition:cursorRange.end];
}

- (NSInteger)cursorRangeLength
{
    UITextRange *cursorRange = self.selectedTextRange;
    if (![self cursorOn]) {
        return 0;
    }
    return [self offsetFromPosition:cursorRange.start
                         toPosition:cursorRange.end];
}

- (NSInteger)cursorLocation
{
    UITextRange *cursorRange = self.selectedTextRange;
    if (![self cursorOn]) {
        return [self.text length];
    }
    return [self offsetFromPosition:self.beginningOfDocument
                         toPosition:cursorRange.start];
}

- (void)setNewCursorLocationWithOffset:(NSInteger)offset numOfDigitsBefore:(NSInteger)numOfDigitsToTheLeft
{
    UITextRange *cursorRange = self.selectedTextRange;
    if ([self cursorOn]) {
        NSInteger location = [self newLocationForPhoneFormattedString:self.text
                                             withNumOfDigitsToTheLeft:numOfDigitsToTheLeft + offset];
        UITextPosition *cursorLocation = [self positionFromPosition:self.beginningOfDocument
                                                             offset:location];
        [self setSelectedTextRange:[self textRangeFromPosition:cursorLocation
                                                    toPosition:cursorLocation]];
    }
    self.currentCursorRange = cursorRange;
}

- (NSRange)cursorRange
{
    if (![self cursorOn]) {
        return NSMakeRange([self.text length], 0);
    }
    return NSMakeRange([self cursorLocation], [self cursorRangeLength]);
}

- (NSInteger)newLocationForPhoneFormattedString:(NSString *)str withNumOfDigitsToTheLeft:(NSInteger)numOfDigitsToTheLeft
{
    if (numOfDigitsToTheLeft < 0) {
        numOfDigitsToTheLeft = 0;
    }
    if (numOfDigitsToTheLeft > [str length]) {
        return [str length];
    }
    NSInteger newLocation = 0;
    
    while (numOfDigitsToTheLeft > 0 && newLocation < [str length]) {
        char c = [str characterAtIndex:newLocation];
        if ([self.acceptedCharacters characterIsMember:c]) {
            numOfDigitsToTheLeft--;
        }
        newLocation++;
    }
    
    return newLocation;
}

- (NSInteger)numOfDigitFromStartOfString:(NSString *)str toOffset:(NSInteger)location
{
    NSInteger numOfDigits = 0;
    
    for (int i = 0; i < location; i++) {
        char c = [str characterAtIndex:i];
        if ([self.acceptedCharacters characterIsMember:c]) {
            numOfDigits++;
        }
    }
    
    return numOfDigits;
}

@end
