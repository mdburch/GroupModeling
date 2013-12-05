//
//  CausalLinkHandleView.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/23/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "CausalLink.h"
#import "CausalLinkHandleView.h"
#import "Constants.h"
#import "Event.h"
#import "EventLogger.h"
#import "Model.h"

@implementation CausalLinkHandleView

@synthesize parent = _parent;

/// Initializes the view.
/// @param frame the frame the view is contained within.
/// @return an id of the newly created view.
-(id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        self.parent = nil;
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        self.opaque = NO;
    }
    return self;
}

/// Draws the receiver’s image within the passed-in rectangle.  This is an overridden method.
/// @param rect the frame of the view in which objects can be drawn.
-(void)drawRect:(CGRect)rect
{
    [[UIColor whiteColor] set];

    // Set up the frame for the handle which will be of size HANDLE_SIZE x HANDLE_SIZE
    CGRect frame = CGRectMake(self.frame.size.width/2-(HANDLE_SIZE/2),
                              self.frame.size.height/2-(HANDLE_SIZE/2),
                              HANDLE_SIZE,
                              HANDLE_SIZE);
    
    
    // Set up the graphics and set the color of the outline.
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, [self.parent.arcColor CGColor]);
    CGContextBeginPath(ctx);
    
    // Add a circular handle in the frame.
    CGContextAddEllipseInRect(ctx, frame);
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor whiteColor] CGColor]));
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

/// Logs event at the beginning of moving the link.
/// @param touches the set of touch events registered by the application.
/// @param event the UIEvent that fired the the method call.
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CausalLinkView* view = (CausalLinkView*)self.parent;
    // Using vertex point as opposed to touches, because the causal links do not follow the touch but move towards the at direction.
    CGPoint point = CGPointMake(self.parent.vertexPoint.x + self.parent.frame.origin.x,
                                self.parent.vertexPoint.y + self.parent.frame.origin.y);
    
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID:BEGIN_LINK_MOVE
                                                               andObjectID:[(CausalLink*)view.parent idNum]
                                                                andDetails:[[Model sharedModel] constructLocationDetails:point]]];
}

/// Handles moving the pivot point of the causal link handle
/// @param touches the set of touch events registered by the application
/// @param event the UIEvent that fired the the method call
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Get the touch event.
    UITouch* touch = touches.anyObject;
    CGPoint location = [touch locationInView:self];
    CGPoint prevLocation = [touch previousLocationInView:self];

    // Move the CausalLink in accordance with the touch event
    [self.parent moveArc:location previousLocation:prevLocation];
    [self setNeedsDisplay];
    
    CausalLinkView* view = (CausalLinkView*)self.parent;
    // Using vertex point as opposed to touches, because the causal links do not follow the touch but move towards the at direction.
    CGPoint point = CGPointMake(self.parent.vertexPoint.x + self.parent.frame.origin.x,
                                self.parent.vertexPoint.y + self.parent.frame.origin.y);
    
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID:LINK_MOVE
                                                               andObjectID:[(CausalLink*)view.parent idNum]
                                                                andDetails:[[Model sharedModel] constructLocationDetails:point]]];
}

/// Logs event at the end of moving the link.
/// @param touches the set of touch events registered by the application.
/// @param event the UIEvent that fired the the method call.
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CausalLinkView* view = (CausalLinkView*)self.parent;
    // Using vertex point as opposed to touches, because the causal links do not follow the touch but move towards the at direction.
    CGPoint point = CGPointMake(self.parent.vertexPoint.x + self.parent.frame.origin.x,
                                self.parent.vertexPoint.y + self.parent.frame.origin.y);

     [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID:END_LINK_MOVE
                                                                andObjectID:[(CausalLink*)view.parent idNum]
                                                                 andDetails:[[Model sharedModel] constructLocationDetails:point]]];
}


/// Will open up the menu of options for the object on a single tap.
/// @param sender the recognizer that fired the method call.
-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.parent updateLink];
}
@end
