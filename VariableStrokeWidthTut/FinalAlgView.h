//
//  FinalAlgView.h
//  VariableStrokeWidthTut
//
//  Created by Le Tan Thang on 11/9/16.
//  Copyright © 2016 Le Tan Thang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinalAlgView : UIView

@property(weak, nonatomic) UIColor *color;
@property(weak, nonatomic) UIColor *bgColor;
@property(nonatomic) CGFloat lineWidth;

- (UIImage *)captureView;
- (void) setFillBG: (UIColor *)color;

@end
