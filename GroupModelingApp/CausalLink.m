//
//  CausalLink.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 6/23/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "CausalLink.h"
#import "Constants.h"
#import "Event.h"
#import "EventLogger.h"
#import "Model.h"

@implementation CausalLink

/// Enum containing the indicies of an array of strings separated by commas in which the different attributes of a causal link in a Vensim mdl file are located.
enum IndexLocations
{
    TYPE              = 0,
    ID                = 1,
    PARENT            = 2,
    CHILD             = 3,
    POLARITY          = 6,
    LINE_THICKNESS    = 7,
    DELAY             = 9,
    ARC_COLOR         = 11,
    XCOORD            = 13,
    YCOORD            = 14
};

@synthesize parentObject     = _parentObject;
@synthesize childObject      = _childObject;
@synthesize view             = _view;

/// Initializes the CausalLink.
/// @param data an array of strings containing all of the data for the causal link from a Vensim mdl file.
/// @return a pointer to the newly created causal link.
-(id)init:(NSArray*)data
{
    self = [super init];
    if(self)
    {
        self.objectType       = [[data objectAtIndex:TYPE] integerValue];
        self.idNum            = [[data objectAtIndex:ID] integerValue];
        
        /// The parent and child objects will point to integers initially. Once the entire model is parsed, the FileIO class will update these objects to point to the associated variable objects.
        self.parentObject     = [[NSNumber alloc]initWithInt:[[data objectAtIndex:PARENT]integerValue]];
        self.childObject      = [[NSNumber alloc]initWithInt:[[data objectAtIndex:CHILD]integerValue]];
        
        // The line below will be how we handle the view initially.  Setting frame and starting, ending, and control points will be handled in the create view method.
        self.view = [[CausalLinkView  alloc] initWithParent:self];
        
        
        // The view holds the polarity value.
        int polarity = [[data objectAtIndex:POLARITY] integerValue];
        [self.view setPolarity: (polarity == PLUS) ? PLUS_SYMBOL : MINUS_SYMBOL];
        
        // The view holds the line thickness.
        int lineThickness = [[data objectAtIndex:LINE_THICKNESS] integerValue];
        [self.view setIsBold:(lineThickness == NORMAL)?  NO : YES];
        
        // The view holds the time delay value.
        int delayVal = [[data objectAtIndex:DELAY]integerValue];
        // There are four different situations where time delay can exist.
        if( delayVal == TIME_DELAY1 || delayVal == TIME_DELAY2 || delayVal == TIME_DELAY3 || delayVal == TIME_DELAY4)
        {
            [self.view setHasTimeDelay:YES];
        }
        else
        {
            [self.view setHasTimeDelay:NO];
        }
        
        // The arc color will be in the format R-G-B
        NSString* rgb =[data objectAtIndex:ARC_COLOR];
        
        // the default ouptut from vensim
        if([rgb isEqualToString:DEFAULT_LINK_COLOR])
            self.view.arcColor = [UIColor blackColor];
        else
        {
            int red   = [[[rgb componentsSeparatedByString:@"-"] objectAtIndex:0] integerValue];
            int green = [[[rgb componentsSeparatedByString:@"-"] objectAtIndex:1] integerValue];
            int blue  = [[[rgb componentsSeparatedByString:@"-"] objectAtIndex:2] integerValue];
            
            self.view.arcColor = [self convertToUIColor:red andGreen:green andBlue:blue];
        }
        
        // Turns out vensim stores the handles location not the center point. Although we can still use this point to create some initial arc.
        // The X coord string will be in a format like: 1|(###
        int xcoord = [[[[data objectAtIndex:XCOORD] componentsSeparatedByString:@"("]objectAtIndex:1] integerValue];
        // The Y coord string will be in a format like: ###)|
        int ycoord = [[[[data objectAtIndex:YCOORD] componentsSeparatedByString:@")"]objectAtIndex:0] integerValue];
        [self.view setVertexPoint:CGPointMake(xcoord, ycoord)];
    }
    return self;
}

/// Initializes the CausalLink.
/// @param parent the parent variable object that the causal link begins from.
/// @param child the child object that the causal link points to.
/// @return a pointer to the newly created causal link.
-(id) initWithParent:(Variable*)parent andChild:(Variable*) child
{
    self = [super init];
    if(self)
    {
        self.objectType       = CAUSAL_LINK;
        self.parentObject     = parent;
        self.childObject      = child;

        // The line below will be how we handle the view initially.  Setting frame and starting, ending, and control points will be handled in the create view method.
        self.view = [[CausalLinkView  alloc] initWithParent:self];
        
        [self.view setStartPoint:parent.view.center];
        [self.view setEndPoint:child.view.center];
        
        // This needs to be the control point because initially we want the causal link to be a straight line.
        [self.view setControlPoint:CGPointMake(([self.view startPoint].x + [self.view endPoint].x) / 2.0,
                                               ([self.view startPoint].y + [self.view endPoint].y) / 2.0)];
        
        // The view holds the polarity value
        [self.view setPolarity: PLUS_SYMBOL];
  
        // Determine the appropriate frame for this view.
        [self.view calculateFrame];
    
        // Add the view and redisplay.
        // Get the root view controller view and add the Variable's view as a subview.
        UIView* parentView = [[Model sharedModel] getViewControllerView];
    
        [parentView insertSubview:self.view atIndex:0];
        [parentView setNeedsDisplay];
    }
    
    return self;
}

/// When initially importing the file, a CausalLink does not know the location of its parent and child, but knows the id of the parent and child.  Once the file has been parsed through completely, FileIO will revisit the CausalLinks and set the parentObject and the childObject to the corresponding Variable instances.
/// This method updates the startPoint, endPoint, controlPoint located in the view based on the updated parent and child objects.
/// After the points of the arc have been set, the frame of the view will be calculated and the view will be added to the parentview.
/// @param parentView the superview that the CausalLink view will be added as a subview.
-(void) createView
{
    CGPoint parentCenter = [[self.parentObject view]center];
    CGPoint childCenter  = [[self.childObject view]center];

    // Update the starting point.
    if([self.parentObject isKindOfClass:[Variable class]])
    {
        [self.view setStartPoint:CGPointMake(parentCenter.x, 
                                             parentCenter.y)];
    }
    // Update the end point.
    if([self.childObject isKindOfClass:[Variable class]])
    {
        [self.view setEndPoint:CGPointMake(childCenter.x,
                                           childCenter.y)];
    }
    
    // Update the control point now that we know where the origin is located.
    [self.view setVertexPoint:CGPointMake([self.view vertexPoint].x - self.view.frame.origin.x,
                                           [self.view vertexPoint].y - self.view.frame.origin.y)];
    
    // Call this calculate to ensure that the control point is aligned with the vertex.
    [self.view calculateInitialArc];

    // Determine the appropriate frame for this view.
    [self.view calculateFrame];
    
    // Add the view and redisplay.
    // Get the root view controller view and add the Variable's view as a subview.
    UIView* parentView = [[Model sharedModel] getViewControllerView];
    
    [parentView insertSubview:self.view atIndex:0];
    [parentView setNeedsDisplay];
    
    // Log the import
    NSString* parentChild = [NSString stringWithFormat:PARENT_CHILD, [(Variable*)self.parentObject view].name,
                                                                     [(Variable*)self.parentObject idNum],
                                                                     [(Variable*)self.childObject view].name,
                                                                     [(Variable*)self.childObject idNum]];
    
    NSString* type  = [NSString stringWithFormat:POLARITY_TYPE,(self.view.polarity)];
    NSString* line  = [NSString stringWithFormat:LINE_TYPE,(self.view.isBold) ? BOLD_LINE_THICKNESS: NORMAL_LINE_THICKNESS];
    NSString* delay = [NSString stringWithFormat:TIME_DELAY_TYPE,(self.view.hasTimeDelay) ? YES_LABEL: NO_LABEL];
    NSString* color = [NSString stringWithFormat:COLOR_TYPE, [CausalLink getColorName:self.view.arcColor]];
    
    NSString* details = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", parentChild, type, line, delay, color];
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID:IMPORTED_CAUSAL_LINK
                                                               andObjectID:self.idNum
                                                                andDetails:details]];
}

/// Constructs the output string for a CausalLink.
/// The string is constructed to be readable by Vensim.
/// Follows the string pattern:
/// [Object Type],[Object id], [Starting Object id],[Ending Object id],1,0,[Polarity],[Line thickness],3,[Delay/Polarity Position],0,[Arrow Color],[Font Size],[Font Color],[Handle Position]
/// @return the Vensim string of data for the CausalLink.
-(NSString*) createCausalLinkOutputString
{
    // Initialize with the type.
    NSString* result = [NSString stringWithFormat:@"%d", CAUSAL_LINK];
    
    // Add the id number.
    result = [result stringByAppendingString:[NSString stringWithFormat:@",%d", self.idNum]];
    
    // Add the parent id.
    result = [result stringByAppendingString:[NSString stringWithFormat:@",%d",[self.parentObject idNum]]];

    // Add the child id.
    result = [result stringByAppendingString:[NSString stringWithFormat:@",%d",[self.childObject idNum]]];
    
    // Add misc. defaults.
    result = [result stringByAppendingString:CAUSAL_LINK_DEFAULTS1];
    
    // Add the polarity.
    if([self.view.polarity isEqualToString:PLUS_SYMBOL])
        result = [result stringByAppendingString:[NSString stringWithFormat:@",%d",PLUS]];
    else
        result = [result stringByAppendingString:[NSString stringWithFormat:@",%d",MINUS]];
    
    // Add the line thickness
    if(self.view.isBold)
        result = [result stringByAppendingString:[NSString stringWithFormat:@",%d",LIGHT_BOLD]];
    else
        result = [result stringByAppendingString:[NSString stringWithFormat:@",%d",NORMAL]];
    
    // Add the ability to export color.
    result = [result stringByAppendingString:COLOR_ON];
    
    // Add the time delay /polarity position. By default I do not care what the polarity position is.
    result = [result stringByAppendingString:[NSString stringWithFormat:@",%d",self.view.hasTimeDelay]];
    
    // Character with unknown meaning.
    result = [result stringByAppendingString:UNKNOWN_CHAR];
    
    // Add causal link color.
    result = [result stringByAppendingString:[self convertFromUIColor:self.view.arcColor]];
    
    // Add font size.
    result = [result stringByAppendingString:DEFAULT_LINK_FONT_SIZE];
    
    // Add font color.
    result = [result stringByAppendingString:DEFAULT_LINK_FONT_COLOR];
    
    // Add the handle position.
    result = [result stringByAppendingString:[NSString stringWithFormat:@"%@%d,%d%@", BAR_PAREN,
                                              (int)self.view.vertexPoint.x + (int)self.view.frame.origin.x,
                                              (int)self.view.vertexPoint.y + (int)self.view.frame.origin.y,
                                              PAREN_BAR]];
    return result;
}

/// Converts an RGB value to a UIColor.  The RGB values used in the code are the RGB equivalent of colors used in Vensim.
/// @param red the red value from 0-255.
/// @param green the green value from 0-255.
/// @param blue the blue value from 0-255.
/// @return the UIColor associated with the RGB values passed in, black if a match not found.
-(UIColor*)convertToUIColor:(int) red andGreen:(int) green andBlue:(int) blue
{
    UIColor* color;
    
    if((red == 255 && green == 0   && blue == 0)  || // Red
       (red == 128 && green == 0   && blue == 0)  || // Maroon
       (red == 255 && green == 0   && blue == 255)|| // Magenta
       (red == 255 && green == 128 && blue == 192)|| // Pink
       (red == 192 && green == 128 && blue == 192)|| // Light Purple
       (red == 128 && green == 0   && blue == 64) || // Rose
       (red == 128 && green == 0   && blue == 128))  // Purple
        color = [UIColor redColor];
    
    else if((red == 0   && green == 255 && blue == 0)  || // Green
            (red == 0   && green == 64  && blue == 0)  || // Forest Green
            (red == 128 && green == 192 && blue == 0)  || // Green yellow
            (red == 0   && green == 128 && blue == 0)  || // Dark green
            (red == 64  && green == 160 && blue == 98) || // Blue green
            (red == 192 && green == 255 && blue == 192)|| // Pale green
            (red == 64  && green == 128 && blue == 128))  // Teal
        color = [UIColor greenColor];
    
    else if((red == 0   && green == 0   && blue == 255)|| // Blue
            (red == 0   && green == 128 && blue == 255)|| // Bright blue
            (red == 0   && green == 64  && blue == 128)|| // Midnight blue
            (red == 0   && green == 0   && blue == 128)|| // Dark blue
            (red == 0   && green == 192 && blue == 255)|| // Sky blue
            (red == 0   && green == 255 && blue == 255)|| // Cyan
            (red == 128 && green == 192 && blue == 255)|| // Pale blue
            (red == 0   && green == 192 && blue == 192)|| // Blue Green
            (red == 192 && green == 255 && blue == 255)|| // Robins egg blue
            (red == 128 && green == 128 && blue == 192)|| // Blue purple
            (red == 64  && green == 64  && blue == 128))  // Dark blue purple
        color = [UIColor blueColor];
    
    
    else if((red == 255 && green == 128 && blue == 0)  || // Orange
            (red == 128 && green == 64  && blue == 0)  || // Brown
            (red == 255 && green == 160 && blue == 0)  || // Light Orange
            (red == 255 && green == 192 && blue == 0)  || // Golden rod
            (red == 255 && green == 255 && blue == 128)|| // Pale yellow
            (red == 255 && green == 192 && blue == 128)|| // Peach
            (red == 255 && green == 255 && blue == 0)  || // Yellow
            (red == 64  && green == 64  && blue == 0)  || // Dark brown
            (red == 128 && green == 128 && blue == 0))    // Yellow brown
        color = [UIColor orangeColor];
    else
        color = [UIColor blackColor];
    
    return color;
}

/// Converts a UIColor to its RGB equivalent.
/// @param color the UIColor you want to get the corresponding RGB value for.
/// @return an rgb string value for color ,R-G-B.
-(NSString*)convertFromUIColor:(UIColor*) color
{
    NSString* colorName;
    if([color isEqual:[UIColor redColor]])
        colorName = @",255-0-0";
    else if([color isEqual:[UIColor greenColor]])
        colorName = @",0-255-0";
    else if([color isEqual:[UIColor blueColor]])
        colorName = @",0-0-255";
    else if([color isEqual:[UIColor orangeColor]])
        colorName = @",255-128-0";
    else
        colorName = @",0-0-0";
    
    return colorName;
}

/// Gets the textual representation of a color.
/// @param color the uicolor that you want to get the name of.
/// @return the name of the color as a string.
+(NSString*) getColorName:(UIColor*)color
{
    NSString* colorName;
    if([color isEqual:[UIColor redColor]])
        colorName = RED_COLOR;
    else if([color isEqual:[UIColor greenColor]])
        colorName = GREEN_COLOR;
    else if([color isEqual:[UIColor blueColor]])
        colorName = BLUE_COLOR;
    else if([color isEqual:[UIColor orangeColor]])
        colorName = ORANGE_COLOR;
    else
        colorName = BLACK_COLOR;
    
    return colorName;
}


@end