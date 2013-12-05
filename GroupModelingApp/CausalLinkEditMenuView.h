//
//  CausalLinkEditMenuView.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/28/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "CausalLinkView.h"
#import <UIKit/UIKit.h>

/// The view that will contain the edit menu for CausalLinks.
@interface CausalLinkEditMenuView : UIView

/// The segmented control that allows the user to change the line thickness.
@property UISegmentedControl* lineThicknessControls;

/// The label that represents what lineThicknessControls represents.
@property UILabel* lineThicknessLabel;

/// The view of the object that you are editing.
@property CausalLinkView* objectView;

/// The segmented control that allows the user to change the polarity.
@property UISegmentedControl* polarityControls;

/// The label that represents what polarityControls represents.
@property UILabel* polarityLabel;

/// The segmented control that allows the user to turn on the time delay.
@property UISegmentedControl* timeDelayControls;

/// The label that represents what timeDelayControls represents.
@property UILabel* timeDelayLabel;

/// The label that represents what colorPicker represents.
@property UILabel* colorPickerLabel;

/// The segmented control that allows the user to change the polarity.
@property UISegmentedControl* colorPicker;

- (id)initWithFrame:(CGRect)frame view:(UIView*) view;
-(void) updateCausalLink;
-(UIColor*)getColor;
-(int) getColorIndex;
-(void) polarityControlsChange;
-(void) lineThicknessControlsChange;
-(void) timeDelayControlsChange;
-(void) colorPickerControlsChange;

@end
