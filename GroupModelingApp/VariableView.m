//
//  VariableView.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/2/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "Constants.h"
#import "EventLogger.h"
#import "Model.h"
#import "ModelSectionViewController.h"
#import "NewCausalLink.h"
#import "VariableView.h"

@implementation VariableView

@synthesize boxColor = _boxColor;
@synthesize isBoxed  = _isBoxed;
@synthesize name     = _name;
@synthesize parent   = _parent;
@synthesize tempLink = _tempLink;

/// Initializes the view.
/// @param frame the frame the view is contained within.
/// @param parent a pointer to the parent object that holds the view.
/// @return an id of the newly created view
-(id)initWithFrame:(CGRect)frame andParent:(id)parent
{
    self = [super initWithFrame:frame];
    if (self) {
        self.name     = DEFAULT_VAR_NAME;
        self.parent   = parent;
        self.boxColor = [UIColor whiteColor];
        self.opaque   = NO;
        // Register a single tap recognizer
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
         initWithTarget:self
         action:@selector(longPressDetected:)];
        longPressRecognizer.minimumPressDuration = .25;
        [self addGestureRecognizer:longPressRecognizer];
        
        self.tempLink = [[NewCausalLink alloc]init];
    }
    return self;
}

/// Draws the receiver’s image within the passed-in rectangle.  This is an overridden method.
/// @param rect the frame of the view in which objects can be drawn. 
-(void)drawRect:(CGRect)rect
{
    self.layer.borderWidth = (self.isBoxed) ? 1.0 : 0.0;
    
    // Draw the variable on the screen.
    self.layer.borderColor = [UIColor blackColor].CGColor;
    [self.boxColor set];
    UIRectFill(self.bounds);
    
    // Add the variable name onto the rectangle.
    //Set offset based on whether the variable is boxed.
    CGFloat yOffset = (self.isBoxed)? 5: (self.frame.size.height -15) / 2.0;
    CGRect textRect = CGRectMake(0, yOffset, self.frame.size.width, self.frame.size.height);
    [[UIColor blackColor] set];
    [self.name drawInRect: textRect
           withFont:[UIFont fontWithName:FONT size:FONT_SIZE]
      lineBreakMode: NSLineBreakByTruncatingTail
          alignment: NSTextAlignmentCenter];
}

/// Logs event at the beginning of moving the variable.
/// @param touches the set of touch events registered by the application.
/// @param event the UIEvent that fired the the method call.
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID:BEGIN_VAR_MOVE
                                                               andObjectID:[(Variable*)self.parent idNum]
                                                                andDetails:[[Model sharedModel] constructLocationDetails:[touches.anyObject locationInView:self.superview]]]];
}

/// Handles moving the variable object across the view when the user drags the object
/// @param touches the set of touch events registered by the application
/// @param event the UIEvent that fired the the method call
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Get any touch event and reset the center of the view
    UITouch* touch = touches.anyObject;
    self.center = CGPointMake([touch locationInView:self.superview].x, [touch locationInView:self.superview].y);

    // Update the associated causal links because the variable has moved.
    [[Model sharedModel] moveVariable:self];

    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID:VAR_MOVE
                                                               andObjectID:[(Variable*)self.parent idNum]
                                                                andDetails:[[Model sharedModel] constructLocationDetails:self.center]]];
}

/// Logs event at the end of moving the variable.
/// @param touches the set of touch events registered by the application.
/// @param event the UIEvent that fired the the method call.
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID:END_VAR_MOVE
                                                               andObjectID:[(Variable*)self.parent idNum]
                                                                andDetails:[[Model sharedModel] constructLocationDetails:[touches.anyObject locationInView:self.superview]]]];
}

/// Will open up the menu of options for the object on a single tap.
/// @param sender the recognizer that fired the method call.
-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    ModelSectionViewController* vc = (ModelSectionViewController*) [[Model sharedModel] getViewController];
    [vc createUpdateMenu:self];
}

/// The long press is used to determine when a user wants to add a new causalLink.
/// A user can only add a causalLink from clicking on a variable.
/// @param sender the recognizer that fired the method call.
-(void)longPressDetected: (UILongPressGestureRecognizer*)sender
{
    ModelSectionViewController* vc = (ModelSectionViewController*)[[Model sharedModel] getViewController];
    
    if(vc.controls.selectedSegmentIndex == LINK_INDEX)
    {
        // Get the touch event of the user.
        CGPoint touch =  [sender locationOfTouch:0 inView:self.superview];
        
        // Log the event of what is occurring whether the link has just begun being added or is in the process.
        if(sender.state == UIGestureRecognizerStateBegan)
        {
            [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: BEGIN_ADD_CAUSAL_LINK
                                                                        andDetails:[[Model sharedModel] constructLocationDetails:touch]]];
        }
        else if(sender.state == UIGestureRecognizerStateChanged)
        {
            [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: CAUSAL_LINK_ADD_IN_PROGRESS
                                                      andDetails:[[Model sharedModel] constructLocationDetails:touch]]];
        }
        
        // Make the origin of the
        CGPoint origin = CGPointMake(MIN(touch.x, self.center.x),
                                     MIN(touch.y, self.center.y));
        
        // Update the tempLink that contains the guiding line for the user with.
        // Update the frame
        [self.tempLink setFrame:CGRectMake(origin.x,
                                           origin.y,
                                           MAX(touch.x, self.center.x),
                                           MAX(touch.y, self.center.y))];

        // Update the starting and ending points.
        [self.tempLink setStartPoint:CGPointMake(self.center.x - origin.x,
                                                 self.center.y - origin.y)];
        
        [self.tempLink setEndPoint:CGPointMake(touch.x - origin.x,
                                               touch.y - origin.y)];
        
        // Add the tempLink to the superview and redisplay.  (NOTE: When this method gets called multiple times, it does not keep readding the templink but in fact overwrites it.
        [self.superview addSubview:self.tempLink];
        [self.tempLink setNeedsDisplay];
        
        // Will update the color of a variable if the touch point from the user is in the variable's view.
        [[Model sharedModel] setVariableColor:touch];
        
        // Set own view of Variable to a gray color so the user knows they are working from that variable.
        self.boxColor = [UIColor lightGrayColor];
        
        // Recognize if the gesture has ended.
        if (sender.state == UIGestureRecognizerStateCancelled ||
            sender.state == UIGestureRecognizerStateFailed ||
            sender.state == UIGestureRecognizerStateEnded)
        {
            // Remove tempLink becuase we no longer needed.
            [self.tempLink removeFromSuperview];
            
            // Create temp parent and child variables
            Variable* parent = [[Model sharedModel] getVariableAtPoint:self.center];
            Variable* child  = [[Model sharedModel] getVariableAtPoint:touch];
            
            // If one of the temp variables is null, the user stopped the drag not on a variable and the action gets ignored.
            if(parent != nil && child != nil && parent != child)
            {
                // Add new causalLink
                int idNum = [[Model sharedModel] addCasualLinkWithParent:parent andChild:child];
                NSString* details = [[NSString alloc] initWithFormat:PARENT_CHILD,
                                                                    parent.view.name,
                                                                    parent.idNum,
                                                                    child.view.name,
                                                                    child.idNum];
                [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: CAUSAL_LINK_ADDED andObjectID:idNum andDetails:details]];
            }
            else // log the cancelation of the addition.
            {
                [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: CASUAL_LINK_CANCELLED]];
            }
            
            // Update the color of all the variables
            [[Model sharedModel] setVariableColor:CGPointMake(-100, -100)]; // Set to an arbitrary number.
            [self setNeedsDisplay];
        }
    }
}

/// Will set the color of the frame based on a point.  If the provided point falls within the bounds of the variable, the color will be different than if the point does not lie within the bounds.
/// This method is used to highlight variables when the user is trying to add new causal links.
/// @param point the reference point to determine what the color of the view should be.
-(void)setBoxColorBasedOnPoint:(CGPoint)point
{
    // Create a local variable to keep track of the location in frame of the view as opposed to the superview.
    CGPoint locInFrame = CGPointMake(point.x - self.frame.origin.x,
                                     point.y - self.frame.origin.y);
    
    // Check to see if the point is in the frame.
    if((locInFrame.x > 0 && locInFrame.x <= self.frame.size.width) &&
       (locInFrame.y > 0 && locInFrame.y <= self.frame.size.height))
    {
        self.boxColor = [UIColor lightGrayColor];
    }
    else
    {
        self.boxColor = [UIColor whiteColor];
    }
    
    [self setNeedsDisplay];
}
@end
