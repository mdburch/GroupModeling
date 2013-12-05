//
//  Variable.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 6/19/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "Constants.h"
#import "Event.h"
#import "EventLogger.h"
#import "Model.h"
#import "Variable.h"

@implementation Variable

/// Enum containing the indicies of an array of strings separated by commas in which the different attributes of a varaible in a Vensim mdl file are located.
enum IndexLocations
{
    TYPE    = 0,
    ID      = 1,
    NAME    = 2,
    XCOORD  = 3,
    YCOORD  = 4,
    SYMBOL  = 7,
    TEXTPOS = 11
};


@synthesize indegreeLinks  = _indegreeLinks;
@synthesize outdegreeLinks = _outdegreeLinks;
@synthesize textPosition   = _textPosition;
@synthesize view           = _view;


/// Initializes the Variable when you are loading data from a mdl file.
/// @param data an array of strings containing all of the data for the variable from a Vensim mdl file.
/// @return a pointer to the newly created Variable.
-(id)init:(NSArray*)data
{
    self = [super init];
    if(self)
    {
        self.objectType     = [[data objectAtIndex:TYPE] integerValue];
        self.idNum          = [[data objectAtIndex:ID] integerValue];
        self.textPosition   = [[data objectAtIndex:TEXTPOS] integerValue];
        self.indegreeLinks  = [[NSMutableArray alloc]init];
        self.outdegreeLinks = [[NSMutableArray alloc]init];
        
        // Create the view to add to the parent view.
        self.view = [[VariableView  alloc] initWithFrame:CGRectMake([[data objectAtIndex:XCOORD] integerValue],
                                                                    [[data objectAtIndex:YCOORD] integerValue],
                                                                    VAR_WIDTH,
                                                                    VAR_HEIGHT)
                                               andParent:self];

        // Set up the center point of the view so that the links can exist anywhere along the variable
        self.view.center = CGPointMake(self.view.frame.origin.x + (VAR_WIDTH/2), self.view.frame.origin.y + (VAR_HEIGHT/2.0));
        
        // Add a border to the variable if it is a boxed variable
        [self.view setIsBoxed:([[data objectAtIndex:SYMBOL] integerValue] == BOXED_VAR)];
        
        // Set the name of the variable, sanitizing escape characters
        [self.view setName:[Component sanitizeString:[data objectAtIndex:NAME]]];
        
        // Set the pointer to the parent object.
        [self.view setParent:self];

        // Get the root view controller view and add the Variable's view as a subview.
        [[[Model sharedModel] getViewControllerView] addSubview:self.view];
        
        // Log the import
        NSString* name     = [NSString stringWithFormat:OBJECT_NAME, self.view.name];
        NSString* location = [[Model sharedModel]constructLocationDetails:self.view.center];
        NSString* type     = [NSString stringWithFormat:OBJECT_TYPE,(self.view.isBoxed) ? BOXED_LABEL : NORMAL_LABEL];
        
        NSString* details = [NSString stringWithFormat:@"%@ %@ %@", name, type, location];
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID:IMPORTED_VARIABLE
                                                                   andObjectID:self.idNum
                                                                    andDetails:details]];
    }
    return self;
}

/// Initizlizes the Variable when you are adding a brand new variable.
/// @param location the location of the new object in the frame.
/// @return a pointer to the newly created Variable.
-(id)initWithLocation:(CGPoint) location
{
    self = [super init];
    if(self)
    {
        self.objectType     = VARIABLE;
        self.textPosition   = DEFAULT_TEXT_POS;
        self.indegreeLinks  = [[NSMutableArray alloc]init];
        self.outdegreeLinks = [[NSMutableArray alloc]init];
        
        self.view = [[VariableView  alloc] initWithFrame:CGRectMake(location.x,
                                                                    location.y,
                                                                    VAR_WIDTH,
                                                                    VAR_HEIGHT)
                                               andParent:self];
    
        // Set up the center point of the view so that the links can exist anywhere along the variable
        self.view.center = CGPointMake(self.view.frame.origin.x + (VAR_WIDTH/2), self.view.frame.origin.y + (VAR_HEIGHT/2.0));
    
        // Add a border to the variable if it is a boxed variable
        [self.view setIsBoxed:NO];
        
        // Set the pointer to the parent object.
        [self.view setParent:self];
    
        // Get the root view controller view and add the Variable's view as a subview.
        [[[Model sharedModel] getViewControllerView] addSubview:self.view];
    }
    
    return  self;
}

/// Add a CausalLink to the list of indegree links to this variable.
/// @param link the CausalLink that should be added.
-(void) addIndegreeLink:(id) link
{
    [self.indegreeLinks addObject:link];
}

/// Add a CausalLink to the list of outdegree links to this variable.
/// @param link the CausalLink that should be added.
-(void) addOutdegreeLink:(id) link
{
    [self.outdegreeLinks addObject:link];
}

/// Gets the height of the variable view.
/// @return the height of the variable view.
-(int) getVariableHeight
{
    return self.view.frame.size.height;
}

/// Gets the width of the variable view.
/// @return the width of the variable view.
-(int) getVariableWidth
{
    return self.view.frame.size.width;
}

/// Removes a CausalLink from the list of indegree links for this variable.
/// @param link the CausalLink that should be deleted.
-(void) removeIndgreeLink:(id) link
{
    [self.indegreeLinks removeObject:link];
}

/// Removes a CausalLink from the list of outdegree links for this variable.
/// @param link the CausalLink that should be deleted.
-(void) removeOutdgreeLink:(id) link
{
    [self.outdegreeLinks removeObject:link];
}

/// Constructs the variable map, identifying which variables influence the current variable.
/// Vensim constructs maps to display how the variables are related.
/// Example of the output created:
/// Big Variable  = A FUNCTION OF( variable 1,variable 2)
/// ~
/// ~		|
/// @return an array that contains the three lines that represent the map for the variable.
-(NSArray*) createVarMap
{
    
    NSString* construction = self.view.name;
    construction = [construction stringByAppendingString:FUNCTION_OF];

    // Iterate over the indegree links to get the names of where the links where derived.
    for(int i=0; i < self.indegreeLinks.count; ++i)
    {
        CausalLink* l = (CausalLink*)[self.indegreeLinks objectAtIndex:i];
        Variable* parent = l.parentObject;
        
        // Add the name of the parent of the link.
        construction = [construction stringByAppendingString:parent.view.name];
        
        // Determine if a comma needs to be added as long as there are more indegree links.
        if(i < self.indegreeLinks.count-1)
            construction = [construction stringByAppendingString:COMMA];
    }
    
    // Add closed paren.
    construction = [construction stringByAppendingString:CLOSED_PAREN];
    
    // Construct the array.
    NSArray* results = [[NSArray alloc]initWithObjects:construction,
                                                       TILDE,
                                                       TILDE_BAR,
                                                       nil];
    return results;
}

/// Constructs the output string for a Variable.
/// The string is constructed to be readable by Vensim.
/// Follows the string pattern:
/// [Object Type],[Object id],[Object Name],[X Location],[Y Location],?,?,[Variable Type],3,0,0,[Text Position],0,0,0
/// @return the string of data for the variable.
-(NSString*) createVariableOutputString
{
    // Initialize with the type.
    NSString* result = [NSString stringWithFormat:@"%d", VARIABLE];
    
    // Add the id number.
    result = [result stringByAppendingString:[NSString stringWithFormat:@",%d", self.idNum]];
    
    // Add the name.
    /// @todo I do not put the extra characters vensim uses for "
    result = [result stringByAppendingString:[NSString stringWithFormat:@",%@", self.view.name]];
    
    // Add x coordinate.
    result = [result stringByAppendingString:[NSString stringWithFormat:@",%d", (int)self.view.center.x]];
    
    // Add y coordinate.
    result = [result stringByAppendingString:[NSString stringWithFormat:@",%d", (int)self.view.center.y]];
    
    // Add whether or not the variable is boxed.
    if(self.view.isBoxed)
        result = [result stringByAppendingString:BOXED_VAR_NUMS];
    else
        result = [result stringByAppendingString:NORMAL_VAR_NUMS];
    
    // Add misc. defaults.
    result = [result stringByAppendingString:VAR_DEFAULTS];

    return result;
}

@end
