//
//  Component.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 6/18/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "MFSideMenuContainerViewController.h"

/// A superclass that holds all generic data about all objects in the causal diagram model.
@interface Component : NSObject

/// The id number of the component in the model.  This should be unique for every instance of the component in the model.
@property int idNum;

/// Specifiying the type of the object.  Should be a Variable = 10, CausalLink = 1, or a Loop = 12.
@property int objectType;

-(id)init;

/// @todo would be nice to remove this static variable
/// Called for every subclass instance to keep track of how many objects there are currently in the model.
/// The main use of this method will be to generate identification numbers for newly created objects by the user.
/// Should only be called once by the component model in the init.
/// @return the unique id number for the component.
+(int)generateID;

/// Called to set the id counter back to zero when either a new file is created or opened.
+(void)resetIDCounter;

/// Returns the largest id number.
/// @return the largest id number which will be the value of idIter.
+(int) getLargestIDNum;

/// Sets the idIter to the current largest id num on import.
/// @param num the largest id number.
+(void) setLargestIDNum:(int)num;

/// @todo For some reason stringByReplacingOccurrencesOfString causes Doxygen to not be able to find the .m file.  So i have documentation duplicated in both files right now... 
/// Used to sanitize strings that may contain extraneous escape characters.
/// @param str the string that needs to be returned.
/// @return a string that does not contain any extra backslashes or double-quotes.
+(NSString*) sanitizeString:(NSString*)str;

@end