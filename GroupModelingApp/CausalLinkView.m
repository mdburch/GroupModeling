//
//  LinkView.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/17/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "CausalLinkView.h"
#import "CausalLinkHandleView.h"
#import "Constants.h"
#import "Model.h"
#import "ModelSectionViewController.h"
#import "Variable.h"

@implementation CausalLinkView

@synthesize arcColor     = _arcColor;
@synthesize isBold       = _isBold;
@synthesize hasTimeDelay = _hasTimeDelay;
@synthesize controlPoint = _controlPoint;
@synthesize startPoint   = _startPoint;
@synthesize endPoint     = _endPoint;
@synthesize vertexPoint  = _vertexPoint;
@synthesize xSlopeChange = _xSlopeChange;
@synthesize ySlopeChange = _ySlopeChange;
@synthesize parent       = _parent;
@synthesize polarity     = _polarity;

/// Initializes the view.
/// @param parent a pointer to the parent object that holds the view.
/// @return an id of the newly created view.
-(id)initWithParent:(id)parent
{
    self = [super init];
    if(self)
    {
        [self initMemberVars];
        self.parent = parent;
    }
    return self;
}

/// Initializes all of the member variables.
-(void) initMemberVars
{
    self.arcColor     = [UIColor blackColor];
    self.isBold       = NO;
    self.hasTimeDelay = NO;
    self.controlPoint = CGPointMake(0,0);
    self.startPoint   = CGPointMake(0,0);
    self.endPoint     = CGPointMake(0,0);
    self.vertexPoint  = CGPointMake(0,0);
    self.xSlopeChange = 0;
    self.ySlopeChange = 0;
    self.polarity     = @"";
    self.opaque       = NO;
    
    // Add the handle for the causal link.
    CausalLinkHandleView* handleView = [[CausalLinkHandleView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    handleView.parent = self;
    [self addSubview:handleView];
}

/// Draws the receiver’s image within the passed-in rectangle.  This is an overridden method.
/// @param rect the frame of the view in which objects can be drawn.
- (void)drawRect:(CGRect)rect
{
    [self.arcColor set];

    // Draw the arc.
    [self drawArc];

    // Draw the handle for controling the link.
    [self drawHandle];
    
    // Draw time delay symbol if it exists.
    [self drawTimeDelay];

    // Draw the polarity symbol.
    [self drawPolarity];
   
    // Draw the arrowhead
    [self drawArrowhead];
}

//================================================================================================================================
// Methods that handle drawing.
//================================================================================================================================

/// Draws the CausalLink arc by creating a quad curve Bezier path.
-(void) drawArc
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = (self.isBold) ? 2 : 1;
    [path moveToPoint:self.startPoint];
    [path addQuadCurveToPoint:self.endPoint controlPoint:self.controlPoint];
    [path stroke];
}

/// Draws that arrowhead of the CausalLink.
/// To draw the arrow head, we follow the path of the bezier curve from the ending point, until it reaches a point outside the bounds of the view of the ending variable.  This point is called the head of the arrow.  Then we find a point further down the bezier curve that has a distance of ARROWHEAD_SIZE from the head of the arrow. This point is called the base.  Then the arrowhead will be drawn from these two points with a specified ARROWHEAD_ANGLE.
-(void) drawArrowhead
{
    // Initially set the arrow location to the endpoint.
    CGPoint arrowLoc = CGPointMake(self.endPoint.x, self.endPoint.y);
    
    // Get the size of the Variable view, so that we can determine where the Variable view ends and where the arrow head should be drawn.
    Variable* childObject = [(CausalLink*)self.parent childObject];
    
    int varHeight = [childObject getVariableHeight],
        varWidth  = [childObject getVariableWidth];
    
    // t is the time parameter of the caclulating the bezier curve. It varies from 0.0-1.0.
    float t = T_MAX;
    
    // Create four variables to keep track of the bounds of the Variable view to determine where the arrowhead should be drawn along the quad curve.
    float upperX = self.endPoint.x + (varWidth/2),
          lowerX = self.endPoint.x - (varWidth/2),
          upperY = self.endPoint.y + (varHeight/2),
          lowerY = self.endPoint.y - (varHeight/2);
    
    // While we have not found the first coordinate point outside of the Variable view, we will continue to work our way away from the ending point on the bezier curve.
    while (((arrowLoc.x < upperX) && (arrowLoc.x > lowerX)) &&
           ((arrowLoc.y < upperY) && (arrowLoc.y > lowerY)))
        
    {
        t -= T_INCREMENT;  // Drop the value of t to move further away from the ending point.
        
        // Compute the new x coordinate on the bezier curve.
        arrowLoc.x = [self findPointOnQuadBezierCurve:t
                                                   p0: self.startPoint.x
                                                   p1: self.controlPoint.x
                                                   p2: self.endPoint.x];

        // Compute the new y coordinate on the bezier curve.
        arrowLoc.y = [self findPointOnQuadBezierCurve:t
                                                   p0: self.startPoint.y
                                                   p1: self.controlPoint.y
                                                   p2: self.endPoint.y];
    }
    
    // Find the base of the arrowhead
    CGPoint base = [self findBasePoint:arrowLoc startingTval:t lineSize:ARROWHEAD_SIZE];
    
    // Find the two corner points of the arrowhead with the specified angle.
    CGPoint point1 = [self rotateLine:arrowLoc base: base degrees:ARROWHEAD_ANGLE];
    CGPoint point2 = [self rotateLine:arrowLoc base: base degrees:-ARROWHEAD_ANGLE];
    
    // Draw the arrowhead where arrowLoc is the head of the arrow, and point1 and point2 are the corner points.
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, ARROWHEAD_LINE_WIDTH);    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context,    arrowLoc.x, arrowLoc.y);
    CGContextAddLineToPoint(context, point1.x,   point1.y);
    CGContextAddLineToPoint(context, point2.x,   point2.y);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

/// Draws the time delay for the causal link if one exists.
/// To draw this line the same algorithm is followed for drawing the arrowhead. We start at the vertex point and find another point along the curve of a specified size. Then we rotate the line to find two end points.  We then use these two points to draw the line.
-(void) drawTimeDelay
{
    // Draw time delay only if the causal link has one.
    if(self.hasTimeDelay)
    {
        // Set the starting location to the vertex point.
        CGPoint delayLoc = CGPointMake(self.vertexPoint.x, self.vertexPoint.y);
    
        // Find the base point.
        CGPoint base = [self findBasePoint:delayLoc startingTval:TIME_DELAY_T_VAL lineSize:TIME_DELAY_SIZE];
    
        // Rotate the line from delayLoc to the base to find the two end points.
        CGPoint point1 = [self rotateLine:delayLoc base: base degrees:TIME_DELAY_ANGLE];
        CGPoint point2 = [self rotateLine:delayLoc base: base degrees:-TIME_DELAY_ANGLE];
    
        // Draw a line from point1 to point2.
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, TIME_DELAY_THICKNESS);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context,    point1.x,   point1.y);
        CGContextAddLineToPoint(context, point2.x,   point2.y);
        CGContextStrokePath(context);
    }
}

/// Draws the handle of the CausalLink.
/// The handle will be used to control the size of the arc.
-(void) drawHandle
{
    UIView* handle = self.subviews.lastObject;
    handle.transform = CGAffineTransformIdentity;
    handle.frame = CGRectMake(self.vertexPoint.x-(HANDLE_FRAME_SIZE/2),
                              self.vertexPoint.y-(HANDLE_FRAME_SIZE/2),
                              HANDLE_FRAME_SIZE,
                              HANDLE_FRAME_SIZE);
    [handle setNeedsDisplay];
}

/// Draws the polarity symbol (+, -) outside of the arc at the vertex.
-(void) drawPolarity
{
    // yMidpoint is the midpoint of the y values of the starting and ending points to determine if the arc opens upward or downwards.
    float yMidpoint = (self.startPoint.y + self.endPoint.y)/2;
    
    // the y offset will vary depending on if the arc opens upward or downward.
    int yOffset;
    
    // Creating an offset so that the symbol is located inside of the arc.
    if(self.vertexPoint.y <= yMidpoint) // opens downward
    {
        yOffset = VERTEX_OFFSET;
    }
    else // opens upward
    {
        yOffset = -(POLARITY_SIZE+VERTEX_OFFSET);
    }
    
    // Default x offset. Will be modified if it is determined that the arc is opening to the left/right as opposed to up or down.
    int xOffset = -VERTEX_OFFSET;
    
    // The x difference between the start and end points to determine if we have an arc opening to the left/right.
    float xDifference = abs(self.startPoint.x - self.endPoint.x);
    
    // Check if the x difference is close, within one half of the variable width.
    if(xDifference < VAR_WIDTH/2)
    {
        // xMidpoint is the midpoint of the x values of the starting and ending points to determine if the arc opens left or right.
        float xMidpoint = (self.startPoint.x + self.endPoint.x)/2;
        if(self.vertexPoint.x <= xMidpoint) // opens to the right
        {
            xOffset += VERTEX_OFFSET;
        }
        else // opens to the left
        {
            xOffset -= VERTEX_OFFSET;
        }
    }
    
    // Create a rectangle to contain the polarity text.
    CGRect textRect = CGRectMake(self.vertexPoint.x + xOffset,
                                 self.vertexPoint.y + yOffset,
                                 POLARITY_SIZE,
                                 POLARITY_SIZE);
    
    // Draw the polarity symbol.
    [self.polarity drawInRect:textRect
                     withFont:[UIFont fontWithName:FONT size:POLARITY_SIZE]
                lineBreakMode: NSLineBreakByTruncatingTail
                    alignment: NSTextAlignmentCenter];
}

//================================================================================================================================
// Methods that handle constructing the arrowhead.
//================================================================================================================================

/// Determines the distance between two coordinate points using the standard distance formula.
/// @param point1 the first coordinate point.
/// @param point2 the second coordinate point.
/// @return the distance between point1 and point2.
+(float) distanceBetweenPoints:(CGPoint) point1
                   secondPoint:(CGPoint) point2
{
    return sqrtf(powf(point2.x-point1.x, 2) + powf(point2.y-point1.y, 2));
}

/// Finds the x or y coordinate location on the quad bezier curve based on the value of t.
/// Note that you will only pass all x coordinates or all y coordinates. You will not mix coordinates.
/// Uses the equation B(t) = (1-t)^2 P0 + 2(1-t) * t * P1 + t^2 * P2
/// @param t the time parameter. Will have a value between 0 and 1.
/// @param p0 the x or y coordinate of the startingPoint on the bezier curve.
/// @param p1 the x or y coordinate of the controlPoint on the bezier curve.
/// @param p2 the x or y coordinate of the endPoint on the bezier curve.
/// @return the x or y coordinate of the coordinate point that lies along the bezier curve.
-(float) findPointOnQuadBezierCurve:(float) t
                                 p0:(float) p0
                                 p1:(float) p1
                                 p2:(float) p2
{
    return (pow((1-t),2)  * p0) +
           (2 * (1-t) * t * p1) +
           (pow(t,2)      * p2);
}

/// Will find the base coordinate point of the arrowhead.
/// We want all arrowheads to be the same size and also want them to be perpendicular to the arc. In order to accomplish this, we follow the bezier arc path away from the head point of the arrowhead. We continue down the path until we reach the desired ARROWHEAD_SIZE distance away from the head point. 
/// @param head the coordinate location of the head of arrowhead.
/// @param t the time parameter of the quad bezier curve equation to begin searching from. Should be set to the t value associated with the head of the arrow.
/// @param size the size of the line you are looking for.
/// @return a coordinate point that will serve as the base of the arrowhead.
-(CGPoint) findBasePoint:(CGPoint) head
            startingTval:(float) t
            lineSize:(float)size
{
    // Initially set the base point to the location of the head of the arrowhead.  
    CGPoint base = head;
    
    // While we have not reached the size of the arrowhead we would like, we will continue to move down the bezier curve, decrementing t as we move away from the end point.
    while ([CausalLinkView distanceBetweenPoints:head secondPoint:base] < size)
    {
        // Decrement t as we are moving away from the end point.
        t -=T_INCREMENT;
        
        // Get the new x coordinate of the base.
        base.x = [self findPointOnQuadBezierCurve:t
                                               p0: self.startPoint.x
                                               p1: self.controlPoint.x
                                               p2: self.endPoint.x];
        
        // Get the new y coordinate of the base.
        base.y = [self findPointOnQuadBezierCurve:t
                                               p0: self.startPoint.y
                                               p1: self.controlPoint.y
                                               p2: self.endPoint.y];
    }
    return base;
}

/// This will rotate the line that extends from the head point to the base point by a passed in number of degrees.
/// This method is used to find the corner points of the arrowhead by utilizing a linear algebra rotation matrix to perform rotation in Euclidian space.
/// @param head the head point of the arrowhead.
/// @param base the base point of the arrowhead.
/// @param degrees the number of degree we would like to rotate the line from the head to the base to get the corner point of the arrow.
/// @return the corner point of the rotated line, that is rotated around the head point.
-(CGPoint) rotateLine:(CGPoint) head
                 base:(CGPoint) base
              degrees:(float) degrees
{
    CGPoint rotatedBase;
    
    rotatedBase.x = head.x + ((base.x - head.x) * cos(degrees * DEG_TO_RAD)) +
                             ((base.y - head.y) * sin(degrees * DEG_TO_RAD));
    
    rotatedBase.y = head.y + ((base.y - head.y) * cos(degrees * DEG_TO_RAD)) -
                             ((base.x - head.x) * sin(degrees * DEG_TO_RAD));
    
    return rotatedBase;
}

//================================================================================================================================
// Methods that handle the moving of the arc.
//================================================================================================================================

/// Will calculate  what the frame of the view should be based on where the three points of the arc are located.
/// This method will then make a call to resize the frame and then update the points within the frame to take into account the changes.
-(void) calculateFrame
{
    float minX = MIN(MIN(self.startPoint.x, self.endPoint.x), self.controlPoint.x) - BUFFER;
    float minY = MIN(MIN(self.startPoint.y, self.endPoint.y), self.controlPoint.y) - BUFFER;
    CGPoint newOrigin = CGPointMake(self.frame.origin.x + minX,
                                    self.frame.origin.y + minY);
    
    float newSizeX = MAX(MAX(self.startPoint.x, self.endPoint.x), self.controlPoint.x)- minX + BUFFER;
    float newSizeY = MAX(MAX(self.startPoint.y, self.endPoint.y), self.controlPoint.y)- minY + BUFFER;
    
    [self resizeFrame:self.frame.origin
            newOrigin:newOrigin
                width:newSizeX
               height:newSizeY];
}

/// Will handle the moving of the arc up and down.
/// After modifiying the control point, a method call will be made to adjust the frame.
/// @param location the coordinate location of where the user's finger is located.
/// @param prevLocation the coordinate location of where the user's finger use to be located.
-(void) moveArc:(CGPoint)location previousLocation:(CGPoint)prevLocation
{
    // Check to see if the variables are closed to being aligned vertically.  Will need to handle left and right touch events as opposed to up and down. 
    if(abs(self.startPoint.x - self.endPoint.x) < MAX_SIZE_DISTANCE)
    {
        // Create temporary slope variables that we can modify.
        float tempXSlope = self.xSlopeChange;
        float tempYSlope = self.ySlopeChange;
        
        // Check to see if the upper variable is also to the left of the other variable.
        // If it is we may need to modifiy the slope so that it aligns with the user's finger movement.
        if((self.startPoint.x > self.endPoint.x && self.startPoint.y > self.endPoint.y) ||
           (self.startPoint.x < self.endPoint.x && self.startPoint.y < self.endPoint.y))
        {
            // Moving the arc left will require ySlope to be poistive.
            if(tempYSlope < 0)
            {
                tempYSlope = - tempYSlope;
            }
            // Moving the arc to the left will require xSlope to be negative.
            if(tempXSlope > 0)
            {
                tempXSlope = - tempXSlope;
            }
        }
        
        if(location.x - prevLocation.x < 0) // move arc to the left
        {
            [self setControlPoint:CGPointMake(self.controlPoint.x + tempXSlope,
                                              self.controlPoint.y + tempYSlope)];
        }
        else if (location.x - prevLocation.x > 0) // move arc to the right
        {
            [self setControlPoint:CGPointMake(self.controlPoint.x - tempXSlope,
                                              self.controlPoint.y - tempYSlope)];
        }
    }
    else // we can use the standard moving up and down touch events.
    {
        if(location.y -prevLocation.y < 0) // need to move the arc up
        {
            [self setControlPoint:CGPointMake(self.controlPoint.x + self.xSlopeChange,
                                              self.controlPoint.y + self.ySlopeChange)];
        }
        else if(location.y -prevLocation.y > 0) // need to move the arc down
        {
            [self setControlPoint:CGPointMake(self.controlPoint.x - self.xSlopeChange,
                                              self.controlPoint.y - self.ySlopeChange)];
        }
    }
    
    // Calculate new frame based on the changes.
    [self calculateFrame];
    [self setNeedsDisplay];
}

/// This method updates the arc when either the starting or ending point variable has moved.
/// @param newCenter the center point location of the variable that moved.
/// @param isStartPoint whether or not the variable that changed was the startPoint.
-(void) moveVariable:(CGPoint) newCenter modifyStartPoint:(bool) isStartPoint
{
    // The newCenter provides coordinates in refernce to the superview, so we need to convert it to our frame.
    CGPoint newPoint = CGPointMake(newCenter.x - self.frame.origin.x,
                                   newCenter.y - self.frame.origin.y);
    // Updates the correct point.
    if(isStartPoint)
    {
        self.startPoint = newPoint;
    }
    else
    {
        self.endPoint = newPoint;
    }

    // Need to update the controlPoint to make sure the point is still in the center of the arc.
    [self calculateNewControlPoint];
    
    // Need to update the frame now that the points have moved.
    [self calculateFrame];
    [self setNeedsDisplay];
}

/// Calculates a new control point because one of the variables related to the link has moved.
-(void) calculateNewControlPoint
{
    // Find the new control point.
    [self setControlPoint:[self findPointInBounds:self.controlPoint]];
}

/// Used on the initial import of the Vensim file.  The .mdl file contains the handle location, but I handle all movement and the drawing of the causal links with a control point. I use the vertex point provided by the vensim file to calculate the inital control point and then any modification of the arc beyond this point will be handled by the control point.
-(void) calculateInitialArc
{
    // Update the vertex point to make sure it will appear on the screen correctly.  
    [self setVertexPoint:[self findPointInBounds:self.vertexPoint]];

    // Find the midpoint between the starting and end the ending point.
    CGPoint midpoint = CGPointMake((self.startPoint.x + self.endPoint.x)/2, (self.startPoint.y + self.endPoint.y)/2);
    
    // Set the inital control point. Using the midpoint formula to find the control point based on the vertex point and the midpoint.
    // Those are the other two points that lie along that line.
    float controlPointX = self.vertexPoint.x * 2 - midpoint.x;
    float controlPointY = self.vertexPoint.y * 2 - midpoint.y;

    [self setControlPoint:CGPointMake(controlPointX, controlPointY)];
}

/// Used to compute new control and vertex points on the arc to make sure the arc will stay in bounds of the application.
/// @param refPoint the reference point that we are trying to modify.
/// @return the new point location for the reference point.
-(CGPoint) findPointInBounds:(CGPoint)refPoint
{
    // Find the midpoint between the starting and end the ending point.
    CGPoint midpoint = CGPointMake((self.startPoint.x + self.endPoint.x)/2, (self.startPoint.y + self.endPoint.y)/2);
    
    // Update the slope, just to make sure we have the correct slope.
    [self updateSlope];
    
    // Take the results from the slope update to find the single float value of the slope.
    // Set slope to 1 if you divide by 0.
    float slope = (self.xSlopeChange == 0) ? 1 : self.ySlopeChange / self.xSlopeChange;
    
    // Solve for the constant.
    // c = y - mx;
    float c = midpoint.y - (slope * midpoint.x);
    
    CGPoint newPoint;
    // If the two variables are almost aligned vertically the slope is going to approach x = # making the translation of the control point near inf or nan.
    // By solving for a new y value as opposed to a new x value will help prevent the app from crashing.
    if(abs(self.startPoint.x - self.endPoint.x) < MAX_SIZE_DISTANCE)
    {
        float newY = slope * refPoint.x + c;
        newPoint = CGPointMake(refPoint.x, newY);
    }
    else // we are in safe bounds and can update a new x values.
    {
        // Finding the new x for the control point.
        // x = (y-c) / m;
        float newX = (refPoint.y - c) / slope;
        newPoint = CGPointMake(newX, refPoint.y);
    }
    
    return newPoint;
}

/// Will set the frame based on the given parameters. Will determine what the transalation of the old frame and the new frame is and then will make a method call to update all of the points within the frame.
/// @param oldOrigin the old origin of the frame.
/// @param newOrigin the new origin of the frame.
/// @param sizeWidth the new width of the frame.
/// @param sizeHeight the new height of the frame.
-(void) resizeFrame:(CGPoint) oldOrigin
          newOrigin:(CGPoint) newOrigin
              width:(float) sizeWidth
             height:(float) sizeHeight

{
    // Set the frame to its new size.
    [self setFrame:CGRectMake(newOrigin.x,
                              newOrigin.y,
                              sizeWidth,
                              sizeHeight)];
    
    
    // Need to detemine the translation of the old frame to the new frame.
    // negative result = moved frame to the right, so need to move points to the left so they are in the same spot.
    // positive result = moved frame to the left, so need to move points to the right so they are in the same spot.
    float shiftX = oldOrigin.x - newOrigin.x;
    
    // negative result = moved frame to the down, so need to move points up so they are in the same spot.
    // positive result = moved frame to the up, so need to move points down so they are in the same spot.
    float shiftY = oldOrigin.y - newOrigin.y;
    
    // Need to update all of the points in the frame.
    [self updatePointsInFrame:shiftX yOffset:shiftY];    
}

/// Will translate all of the points in the frame based on the offset of the frame changes.
/// @param xOffset the change in the x coordinate between the old and new frames.
/// @param yOffset the change in the y coordinate between the old and new frames.
-(void) updatePointsInFrame:(float) xOffset yOffset:(float) yOffset
{
    // Update the points on bezier curve. 
    [self setStartPoint:CGPointMake(  self.startPoint.x   + xOffset, self.startPoint.y   + yOffset)];
    [self setEndPoint:CGPointMake(    self.endPoint.x     + xOffset, self.endPoint.y     + yOffset)];
    [self setControlPoint:CGPointMake(self.controlPoint.x + xOffset, self.controlPoint.y + yOffset)];
    [self updateVertex];
    
    // Update the slope 
    [self updateSlope];
}


/// This will update the slope of the arc.
/// It will iteratively decrease the size of the slope until it is within range of normal movement of a finger gesture.
-(void)updateSlope
{
    // Get what the slope of the line between the starting and ending points
    self.xSlopeChange = self.startPoint.x - self.endPoint.x;
    self.ySlopeChange = self.startPoint.y - self.endPoint.y;
    
    // Take the negative reciprocal to get the slope of a line perpendicular to the line between starting and ending point.
    // The controlPoint will lie along a perpendicular line to the line between the starting and ending point.
    int temp = self.xSlopeChange;
    self.xSlopeChange = self.ySlopeChange;
    self.ySlopeChange = -temp;
    
    // Making sure the slope does not extend beyond the max slope change.
    // A large slope will cause the arc to go shooting off in a direction and not actually follow the users finger.
    while(abs(self.ySlopeChange) > MAX_SLOPE_CHANGE || abs(self.xSlopeChange) > MAX_SLOPE_CHANGE)
    {
        self.ySlopeChange /= 2.0;
        self.xSlopeChange /= 2.0;
    }
    
    // Want the y slope to be negative by default because when we move the arc,
    // if the touch is moving up we will add the slope to the arc and negative y means towards the top of the screen.
    if(self.ySlopeChange > 0)
    {
        self.ySlopeChange = -self.ySlopeChange;
        self.xSlopeChange = -self.xSlopeChange;
    }
    
    //NSLog(@"The Slope is: %f/%f", self.ySlopeChange, self.xSlopeChange);
}

/// This method will recompute the vertex based on the starting point, ending point, and control point.
/// This method should be called any time any one of the three points moves.
-(void)updateVertex
{
    // Find the midpoint between the starting and end the ending point.
    CGPoint midpoint = CGPointMake((self.startPoint.x + self.endPoint.x)/2, (self.startPoint.y + self.endPoint.y)/2);
    
    // The vertex is the midpoint between the control point and the midpoint of start and end point.
    self.vertexPoint = CGPointMake((self.controlPoint.x + midpoint.x)/2, (self.controlPoint.y + midpoint.y)/2);
}

//================================================================================================================================
// Methods to handle editing and deleting the arc.
//================================================================================================================================

/// Will make a call to create the menu of update options for the link.
-(void) updateLink
{
    ModelSectionViewController* vc = (ModelSectionViewController*)[[Model sharedModel] getViewController];
    [vc createUpdateMenu:self];
}

/// Will allow any of the children of the view to receive touches but the view itself will be transparent to events.
/// @param point the point where the event occurred.
/// @param event the associated event initiated by the user.
/// @return whether or not this view handled the event.
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    bool answer = NO;
    // Will pass down the event to its children views to see if they can handle the touch event
    for (UIView *view in self.subviews)
    {
        if (!view.hidden &&
            view.userInteractionEnabled &&
            [view pointInside:[self convertPoint:point toView:view] withEvent:event])
                answer = YES;
    }
    return answer;
}

@end
