//
//  VariableEditMenuView.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/28/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VariableView.h"

/// The view that will contain the edit menu for Variables.
@interface VariableEditMenuView : UIView <UITextFieldDelegate>

/// The label that represents what nameTextField represents.
@property UILabel* nameLabel;

/// The text field that contains the name of the object.
@property UITextField* nameTextField;

/// The view of the object that you are editing.
@property VariableView* objectView;

/// The segmented control that allows the user to change the type of variable.
@property UISegmentedControl* typeControls;

/// The label that represents what typeContols represents.
@property UILabel* typeLabel;

-(id) initWithFrame:(CGRect)frame view:(UIView*) view;
-(void) typeControlChange;
-(void) updateVariable;
-(void) textFieldDidBeginEditing:(UITextField *)textField;
-(void) textFieldDidEndEditing:(UITextField *)textField;
-(BOOL) textFieldShouldReturn:(UITextField *)textField;

@end
