//
//  Component.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 6/18/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "Component.h"
#import "Constants.h"

@implementation Component

@synthesize idNum       = _idNum;
@synthesize objectType  = _objectType;
static int idIter = 0;

/// Initialize the Component.
/// This init contains default values that will be overwritten by the subclasses for any object imported from a Vensim mdl file.
/// For imported objects, the generated id should be the same value as the one read in from the file.  For any user created object, the idNum will not be overwritten from this init.
/// @return the unique id for the component.
-(id)init
{
    self = [super init];
    if(self)
    {
        self.idNum        = [Component generateID];
        self.objectType   = VARIABLE;
    }
    
    return self;
}

/// Called for every subclass instance to keep track of how many objects there are currently in the model.
/// The main use of this method will be to generate identification numbers for newly created objects by the user.
/// Should only be called once by the component model in the init.
/// @return the unique id for the component.
+(int)generateID
{
    return ++idIter;
}

/// Called to set the id counter back to zero when either a new file is created or opened.
+(void)resetIDCounter
{
    idIter = 0;
}

/// Returns the largest id number.
/// @return the largest id number which will be the value of idIter.
+(int) getLargestIDNum
{
    return  idIter;
}

/// Sets the idIter to the current largest id num on import.
/// @param num the largest id number.
+(void) setLargestIDNum:(int)num
{
    idIter = num;
}

/// Used to sanitize strings that may contain extraneous escape characters.
/// @param str the string that needs to be returned.
/// @return a string that does not contain any extra backslashes or double-quotes.
+(NSString*) sanitizeString:(NSString*)str
{
    NSString* tempString = str;
    tempString = [tempString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    tempString = [tempString stringByReplacingOccurrencesOfString:@"\"\"" withString:@"\""];
    
    return tempString;
}

@end
