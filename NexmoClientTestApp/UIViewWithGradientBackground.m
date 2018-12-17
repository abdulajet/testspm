//
//  UIViewWithGradientBackground.m
//  StitchClientTestApp
//
//  Copyright (c) 2015 Vonage. All rights reserved.
//

#import "UIViewWithGradientBackground.h"

@interface UIViewWithGradientBackground()

@end

@implementation UIViewWithGradientBackground

//override
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSArray *gradientColors = [NSArray arrayWithObjects:(id) self.topColor.CGColor, self.midTopColor.CGColor,self.midBottomColor.CGColor,self.bottomColor.CGColor, nil];
    CGFloat gradientLocations[] = {self.topLocation, self.midTopLocation,self.midBottomLocation,self.bottomLocation};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) gradientColors, gradientLocations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
}


@end
