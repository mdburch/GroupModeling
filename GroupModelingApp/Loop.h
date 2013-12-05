//
//  Loop.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 6/23/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "Component.h"
#import "LoopView.h"

/// A subclass of Component containing the data related to a feedback loop of a causal loop diagram. ex. In a diagram on K-12 school attendance, a feedback loop would occur where as "Students Desire to Go to School" increases so does their "Mean daily attendance rate" and as their "Mean Daily attendance rate" increases so does a "Students Desire to Go to School"
@interface Loop : Component

/// Where the text holding the feedback loop name is located in relation to the feedback loop object.
@property int textPosition;

/// The UIView that will contain the graphical representation of the loop.
@property LoopView* view;

-(id)init:(NSArray*)data varName:(NSString*)name;

-(id) initWithLocation:(CGPoint) location;

-(NSString*)createLoopOutputString;

@end