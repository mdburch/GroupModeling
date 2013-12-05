//
//  LoopEditMenuView.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/28/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "LoopView.h"
#import <UIKit/UIKit.h>

/// The view that will contain the edit menu for Loops.
@interface LoopEditMenuView : UIView <UITextFieldDelegate>

/// The label that represents what nameTextField represents.
@property UILabel* nameLabel;

/// The text field that contains the name of the object.
@property UITextField* nameTextField;

/// The view of the object that you are editing.
@property LoopView* objectView;

/// The segmented control that allows the user to change the symbol.
@property UISegmentedControl* symbolControls;

/// The label that represents what symbolControls represents.
@property UILabel* symbolLabel;

- (id)initWithFrame:(CGRect)frame view:(UIView*) view;
-(void) updateLoop;
-(void) symbolControlChange;
-(void) textFieldDidBeginEditing:(UITextField *)textField;
-(void) textFieldDidEndEditing:(UITextField *)textField;
-(BOOL) textFieldShouldReturn:(UITextField *)textField;
@end
