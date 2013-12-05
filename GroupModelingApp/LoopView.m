//
//  LoopView.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/13/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "Constants.h"
#import "EventLogger.h"
#import "LoopView.h"
#import "Model.h"
#import "ModelSectionViewController.h"

@implementation LoopView

@synthesize name        = _name;
@synthesize isClockwise = _isClockwise;
@synthesize parent      = _parent;

/// Initializes the view.
/// @param frame the frame the view is contained within.
/// @param parent a pointer to the parent object that holds the view.
/// @return an id of the newly created view
-(id)initWithFrame:(CGRect)frame andParent:(id)parent
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.name        = DEFAULT_LOOP_NAME;
        self.parent      = parent;
        self.isClockwise = YES;
        self.opaque      = NO;
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
    }
    return self;
}

/// Draws the receiver’s image within the passed-in rectangle.  This is an overridden method.
/// @param rect the frame of the view in which objects can be drawn.
-(void)drawRect:(CGRect)rect
{
    // Set up the context with which the loop will be drawn
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextBeginPath(context);
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    if(self.isClockwise)
    {
        // Draw arrow head
        CGContextMoveToPoint(context,    VERTEX_X,        height/2-ARROWHEAD_HEIGHT);
        CGContextAddLineToPoint(context, 0,               height/2);
        CGContextAddLineToPoint(context, ARROWHEAD_WIDTH, height/2);
        CGContextClosePath(context);
        CGContextFillPath(context);
        
        // Draw clockwise loop
        CGContextMoveToPoint(context, width/2, BUFFER_SPACE);
        CGContextAddArc(context,
                        width/2,
                        height/2,
                        width/2-BUFFER_SPACE,
                        3 * M_PI / 2,
                        M_PI,
                        0);
    }
    else
    {
        // Draw arrow head
        CGContextMoveToPoint(context,    width-VERTEX_X,        height/2-ARROWHEAD_HEIGHT);
        CGContextAddLineToPoint(context, width,                 height/2);
        CGContextAddLineToPoint(context, width-ARROWHEAD_WIDTH, height/2);
        CGContextClosePath(context);
        CGContextFillPath(context);
    
        // Draw counterclockwise Loop 
        CGContextMoveToPoint(context, width/2, BUFFER_SPACE);
        CGContextAddArc(context,
                        width/2,
                        height/2,
                        width/2-BUFFER_SPACE,
                        3 * M_PI / 2,
                        2 * M_PI,
                        1);
    }

    CGContextStrokePath(context);

    // Create a text box to center vertically
    CGFloat yOffset = (self.frame.size.height-FONT_SIZE) / 2.0;
    CGRect textRect = CGRectMake(0, yOffset, self.frame.size.width, self.frame.size.height);

    // Add the loop name in the circle
    [[UIColor blackColor] set];
    [self.name drawInRect:textRect
            withFont:[UIFont fontWithName:FONT size:FONT_SIZE]
       lineBreakMode: NSLineBreakByTruncatingTail
           alignment: NSTextAlignmentCenter];
}

/// Logs event at the beginning of moving the loop.
/// @param touches the set of touch events registered by the application.
/// @param event the UIEvent that fired the the method call.
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID:BEGIN_LOOP_MOVE
                                                               andObjectID:[(Loop*)self.parent idNum]
                                                                andDetails:[[Model sharedModel] constructLocationDetails:[touches.anyObject locationInView:self.superview]]]];
}

/// Handles moving the loop object across the view when the user drags the object.
/// @param touches the set of touch events registered by the application.
/// @param event the UIEvent that fired the the method call.
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Get any touch event and reset the center of the view
    UITouch* touch = touches.anyObject;
    self.center = CGPointMake([touch locationInView:self.superview].x, [touch locationInView:self.superview].y);
    
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID:LOOP_MOVE
                                                               andObjectID:[(Loop*)self.parent idNum]
                                                                andDetails:[[Model sharedModel] constructLocationDetails:self.center]]];
}

/// Logs event at the end of moving the loop.
/// @param touches the set of touch events registered by the application.
/// @param event the UIEvent that fired the the method call.
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID:END_LOOP_MOVE
                                                               andObjectID:[(Loop*)self.parent idNum]
                                                                andDetails:[[Model sharedModel] constructLocationDetails:[touches.anyObject locationInView:self.superview]]]];
}

/// Will open up the menu of options for the object on a single tap.
/// @param sender the recognizer that fired the method call.
-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    ModelSectionViewController* vc = (ModelSectionViewController*) [[Model sharedModel] getViewController];
    [vc createUpdateMenu:self];
}
@end
