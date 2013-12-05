//
//  Loop.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 6/23/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "Constants.h"
#import "Event.h"
#import "EventLogger.h"
#import "Loop.h"
#import "Model.h"

@implementation Loop

/// Enum containing the indicies of an array of strings separated by commas in which the different attributes of a feedback loop in a Vensim mdl file are located.
enum IndexLocations
{
    TYPE    = 0,
    ID      = 1,
    XCOORD  = 3,
    YCOORD  = 4,
    SYMBOL  = 7,
    TEXTPOS = 11
};

@synthesize textPosition = _textPosition;
@synthesize view         = _view;

/// Initializes the Loop when you are reading from an mdl file.
/// @param data an array of strings containing all of the data for the feedback loop from a Vensim mdl file.
/// @param myName the name associated with the feedback loop.  Unlike Variables and CausalLinks, Loop names are located on a different line in the Vensim mdl file from the rest of the loop attributes.
/// @return a pointer to the newly created Loop.
-(id)init:(NSArray*)data varName:(NSString*)myName
{
    self = [super init];
    if(self)
    {
        self.objectType   = [[data objectAtIndex:TYPE] integerValue];
        self.idNum        = [[data objectAtIndex:ID] integerValue];
        self.textPosition = [[data objectAtIndex:TEXTPOS] integerValue];
        
        
        // Create the view to add to the parentView.
        self.view = [[LoopView  alloc] initWithFrame:CGRectMake([[data objectAtIndex:XCOORD] integerValue],
                                                                [[data objectAtIndex:YCOORD] integerValue],
                                                                SIDE,
                                                                SIDE)
                                           andParent:self];
        
        // Determines which symbol to display.
        [self.view setIsClockwise:([[data objectAtIndex:SYMBOL] integerValue] == CLOCKWISE)];
        
        // Set the name of the variable, sanitizing escape characters.
        [self.view setName:[Component sanitizeString:myName]];
        
        // Get the root view controller view and add the Variable's view as a subview.
        [[[Model sharedModel] getViewControllerView] addSubview:self.view];
        
        // Log the import
        NSString* name     = [NSString stringWithFormat:OBJECT_NAME, self.view.name];
        NSString* location = [[Model sharedModel]constructLocationDetails:self.view.center];
        NSString* type     = [NSString stringWithFormat:OBJECT_TYPE,(self.view.isClockwise) ? CLOCKWISE_LABEL : COUNTER_CLOCKWISE_LABEL];
        
        NSString* details = [NSString stringWithFormat:@"%@ %@ %@", name, type, location];
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID:IMPORTED_LOOP
                                                                   andObjectID:self.idNum
                                                                    andDetails:details]];
    }
    return self;
}

/// Initizlizes the Loop when you are adding a brand new variable.
/// @param location the location of the new object in the frame.
/// @return a pointer to the newly created Loop.
-(id) initWithLocation:(CGPoint) location
{
    self = [super init];
    if(self)
    {
        self.objectType   = LOOP;
        self.textPosition = DEFAULT_TEXT_POS;
        
        // Create the view to add to the parentView.
        self.view = [[LoopView  alloc] initWithFrame:CGRectMake(location.x,
                                                                location.y,
                                                                SIDE,
                                                                SIDE)
                                           andParent:self];
        
        // Determines which symbol to display.
        [self.view setIsClockwise:(YES)];
    
        // Get the root view controller view and add the Variable's view as a subview.
        [[[Model sharedModel] getViewControllerView] addSubview:self.view];
    }
    return self;
}

/// Constructs the output string for a Loop.
/// The string is constructed to be readable by Vensim.
/// Follows the string pattern:
/// [Object Type],[Object id],0,[X Location],[Y Location],20,20,[Symbol],7,0,0,[Text Position],0,0,0,[Shape color],[Background Color]
/// [Comment]
/// @return the string of data for the variable.
-(NSString*)createLoopOutputString
{
    // Initialize with the type.
    NSString* result = [NSString stringWithFormat:@"%d", LOOP];
    
    // Add the id number.
    result = [result stringByAppendingString:[NSString stringWithFormat:@",%d", self.idNum]];
    
    // Add misc default.
    result = [result stringByAppendingString:@",0"];
    
    // Add x coordinate.
    result = [result stringByAppendingString:[NSString stringWithFormat:@",%d", (int)self.view.center.x]];
    
    // Add y coordinate.
    result = [result stringByAppendingString:[NSString stringWithFormat:@",%d", (int)self.view.center.y]];
    
    // Add misc. defaults.
    result = [result stringByAppendingString:LOOP_DEFAULTS1];
    
    // Add symbol
    if(self.view.isClockwise)
        result = [result stringByAppendingString:[NSString stringWithFormat:@",%d",CLOCKWISE]];
    else
        result = [result stringByAppendingString:[NSString stringWithFormat:@",%d",COUNTER_CLOCKWISE]];
    
    // Add misc. defaults.
    result = [result stringByAppendingString:LOOP_DEFAULTS2];
    
    // Add the name.
    result = [result stringByAppendingString:[NSString stringWithFormat:@"\n%@", self.view.name]];
    
    return result;
}

@end