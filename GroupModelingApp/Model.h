//
//  Model.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 6/23/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CausalLink.h"
#import "ControlParameters.h"
#import "DefaultParameters.h"
#import "Loop.h"
#import "Variable.h"


/// This class is responsible for holding all aspects of a causal loop diagram model. This includes all causal links, variables, feedback loops, simulation parameters, and default parameters.
@interface Model : NSObject

/// An array that contains all variables, causal links, and feedback loops of the model.
@property NSMutableArray* components;

/// An instance of DefaultParameters which contains the Vensim default parameters for the model such as font and size.
@property DefaultParameters* defaultParams;

/// An instance of ControlParameters which contains the Vensim control parameters which specify how the simulation runs.
@property ControlParameters* controlParams;

/// A hash string of the file that was imported from Dropbox. Will be null if brand new file.
@property NSData* startingHash;

/// A hash string of the file that was exported to Dropbox.
@property NSData* endingHash;

// Methods for the entire model.
+(Model*) sharedModel;
-(void) clearModel;
-(NSString*) constructLocationDetails:(CGPoint) location;

// Export methods.
-(NSMutableArray*) createVariableMap;
-(NSMutableArray*) createComponentsExport;

// Adding objects.
-(int) addCasualLinkWithParent:(Variable*) parent andChild:(Variable*) child;
-(void) addComponent:(id) var;

// Deleting objects.
-(int) deleteCausalLink:(id) linkView;
-(int) deleteLoop:(id) loopView;
-(int) deleteVariable:(id) variableView;

// Getters.
-(UIView*) getViewControllerView;
-(UIViewController*) getViewController;
-(Variable*) getVariable:(NSNumber*) idNumber;
-(Variable*) getVariableAtPoint:(CGPoint) point;

// Misc methods
-(void) moveVariable:(id) variableView;
-(void) setVariableColor:(CGPoint) location;
-(CGRect)findModelFrame;
@end