//
//  CausalLink.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 6/23/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "CausalLinkView.h"
#import "Component.h"
#import "Variable.h"

/// A subclass of Component containing the data related to a causal link between two variables of a causal loop diagram. ex. In a diagram on Childhood obesity, there may exist a relationship between the "Fast Food Consumption" variable and the "Weight Gain" variable.  This class represents that causal link.
@interface CausalLink : Component

/// A pointer to the source variable of the causal link.
@property id parentObject;

/// A pointer to the influenced variable of the causal link.
@property id childObject;

/// The UIView that will contain the graphical representation of the causal link.
@property CausalLinkView* view;

-(id)init:(NSArray*)data;

-(id) initWithParent:(Variable*)parent andChild:(Variable*) child;

-(void)createView;

-(NSString*) createCausalLinkOutputString;

-(UIColor*)convertToUIColor:(int) red andGreen:(int) green andBlue:(int) blue;

-(NSString*)convertFromUIColor:(UIColor*) color;

+(NSString*) getColorName:(UIColor*)color;

@end