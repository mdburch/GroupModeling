//
//  ControlParameters.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 6/28/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "ControlParameters.h"

@implementation ControlParameters

@synthesize params = _params;

/// Initializes the ControlParameters.
/// @return a pointer to the newly created ControlParameters object.
-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.params = [[NSMutableArray alloc]init];
    }
    
    return self;
}

/// Adds a new string of the control parameters to the params array.
/// @param str a string of the control parameters to be appended to the existing simulation control parameters.
-(void) addParameter:(NSString*) str
{
    [self.params addObject: str];
}

@end
