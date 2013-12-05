//
//  NewCausalLink.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/30/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "NewCausalLink.h"

@implementation NewCausalLink

@synthesize startPoint = _startPoint;
@synthesize endPoint   = _endPoint;

/// Initializes the view.
/// @param frame the frame the view is contained within.
/// @return an id of the newly created view
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.startPoint = CGPointMake(0, 0);
        self.endPoint   = CGPointMake(0, 0);
        self.opaque = NO;
    }
    return self;
}


/// Draws the receiver’s image within the passed-in rectangle.  This is an overridden method.
/// @param rect the frame of the view in which objects can be drawn.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context,    self.startPoint.x, self.startPoint.y);
    CGContextAddLineToPoint(context, self.endPoint.x,   self.endPoint.y);
    
    CGContextStrokePath(context);

}


@end
