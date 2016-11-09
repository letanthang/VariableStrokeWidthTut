//
//  NaiveVarWidthView.m
//  VariableStrokeWidthTut
//
//  Created by Le Tan Thang on 11/9/16.
//  Copyright © 2016 Le Tan Thang. All rights reserved.
//

#import "NaiveVarWidthView.h"

@implementation NaiveVarWidthView
{
    UIBezierPath *path;
    UIImage *incrementalImage;
    CGPoint pts[5];
    uint ctr;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        path = [UIBezierPath bezierPath];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0);
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0); // ................. (1)
        
        if (!incrementalImage)
        {
            UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
            [[UIColor whiteColor] setFill];
            [rectpath fill];
        }
        [incrementalImage drawAtPoint:CGPointZero];
        [[UIColor blackColor] setStroke];
        
        float speed = 0.0;
        
        for (int i = 0; i < 3; i++)
        {
            float dx = pts[i+1].x - pts[i].x;
            float dy = pts[i+1].y - pts[i].y;
            speed += sqrtf(dx * dx + dy * dy);
        } // ................. (2)
        
#define FUDGE_FACTOR 100 // emperically determined
        float width = FUDGE_FACTOR/speed; // ................. (3)
        
        [path setLineWidth:width];
        [path stroke];
        incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self setNeedsDisplay];
        
        [path removeAllPoints]; // ................. (4)
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
        
    }
}

- (void)drawRect:(CGRect)rect
{
    [incrementalImage drawInRect:rect];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setNeedsDisplay];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

@end
