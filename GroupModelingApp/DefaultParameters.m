//
//  DefaultParameters.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 6/28/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "DefaultParameters.h"

@implementation DefaultParameters

@synthesize params = _params;

/// Initializes the DefaultParameters.
/// @param data the string of data containing the default parameters of the model.
/// @return a pointer to the newly created DefaultParameters object.
-(id)init:(NSString*)data
{
    self = [super init];
    
    if(self)
    {
        self.params = data;
    }
    
    return self;
}


@end
