//
//  ControlParameters.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 6/28/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import <Foundation/Foundation.h>

/// This class currently holds an array with the control parameters, but was created to allow for expansion if we would want to parse the array into its individual control parameters and be able to update them individually.
@interface ControlParameters : NSObject

/// An array containing all of the simulation control parameters.
@property NSMutableArray* params;

-(id)init;
-(void) addParameter:(NSString*) str;
@end