//
//  NaiveVarWidthBGRenderingView.m
//  VariableStrokeWidthTut
//
//  Created by Le Tan Thang on 11/9/16.
//  Copyright © 2016 Le Tan Thang. All rights reserved.
//

#import "NaiveVarWidthBGRenderingView.h"

#define CAPACITY 100 // buffer capacity

@implementation NaiveVarWidthBGRenderingView
{
    
    UIImage *incrementalImage;
    CGPoint pts[5];
    uint ctr;
    CGPoint pointsBuffer[CAPACITY]; // ................. (1)
    uint bufIdx;
    dispatch_queue_t drawingQueue;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        drawingQueue = dispatch_queue_create("drawingQueue", NULL); // ................. (2)
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    bufIdx = 0;
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
        pointsBuffer[bufIdx] = pts[0];
        pointsBuffer[bufIdx + 1] = pts[1];
        pointsBuffer[bufIdx + 2] = pts[2];
        pointsBuffer[bufIdx + 3] = pts[3];
        
        bufIdx += 4;
        
        CGRect bounds = self.bounds;
        dispatch_async(drawingQueue, ^{ // ................. (3)
            if (bufIdx == 0) return; // ................. (4)
            UIBezierPath *path = [UIBezierPath bezierPath];
            for ( int i = 0; i < bufIdx; i += 4)
            {
                [path moveToPoint:pointsBuffer[i]];
                [path addCurveToPoint:pointsBuffer[i+3] controlPoint1:pointsBuffer[i+1] controlPoint2:pointsBuffer[i+2]];
            }
            
            UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 0.0);
            
            if (!incrementalImage) // first time; paint background white
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
            }
            
#define FUDGE_FACTOR 100 // emperically determined
            float width = FUDGE_FACTOR/speed;
            [path setLineWidth:width];
            [path stroke];
            incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{ // ................. (5)
                bufIdx = 0;
                [self setNeedsDisplay];
            });
        });
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
