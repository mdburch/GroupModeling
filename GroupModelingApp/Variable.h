//
//  Variable.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 6/19/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "Component.h"
#import "VariableView.h"

/// A subclass of Component containing the data related to a variable of a causal loop diagram. ex. In a diagram on Childhood obesity, "Fast Food" may be a variable in the model influencing childhood obesity.
@interface Variable : Component

/// An array of CausalLink objects that point to this variable
@property NSMutableArray* indegreeLinks;

/// An array of CausalLink objects that extend from this variable
@property NSMutableArray* outdegreeLinks;

/// Where the text holding the variable name is located in relation to the variable object.
@property int textPosition;

/// The UIView that will contain the graphical representation of the variable.
@property VariableView* view;

-(void) addIndegreeLink:(id) link;
-(void) addOutdegreeLink:(id) link;
-(id)init:(NSArray*)data;
-(id)initWithLocation:(CGPoint) location;
-(int) getVariableHeight;
-(int) getVariableWidth;
-(void) removeIndgreeLink:(id) link;
-(void) removeOutdgreeLink:(id) link;
-(NSArray*) createVarMap;
-(NSString*) createVariableOutputString;
@end
