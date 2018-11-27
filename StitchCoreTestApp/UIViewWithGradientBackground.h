//
//  UIViewWithGradientBackground.h
//  VInfrastructure
//
//  Created by May Ben Arie on 2/26/15.
//  Copyright (c) 2015 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewWithGradientBackground : UIView

@property (nonatomic, strong) IBInspectable UIColor *topColor;
@property (nonatomic) IBInspectable CGFloat topLocation;

@property (nonatomic, strong) IBInspectable UIColor *midTopColor;
@property (nonatomic) IBInspectable CGFloat midTopLocation;

@property (nonatomic, strong) IBInspectable UIColor *midBottomColor;
@property (nonatomic) IBInspectable CGFloat midBottomLocation;

@property (nonatomic, strong) IBInspectable UIColor *bottomColor;
@property (nonatomic) IBInspectable CGFloat bottomLocation;

@end


