//
//  DefaultParameters.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 6/28/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import <Foundation/Foundation.h>

/// This class currently holds a string with the default parameters, but was created to allow for expansion if we would want to parse the string into its individual pieces and be able to update them individually.
@interface DefaultParameters : NSObject

/// A string containing all of the default parameters including font, and size.
@property NSString* params;

-(id)init:(NSString*)data;
@end
