//
//  VariableEditMenuView.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/28/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "Constants.h"
#import "EventLogger.h"
#import "Variable.h"
#import "VariableEditMenuView.h"

@implementation VariableEditMenuView

@synthesize nameLabel     = _name;
@synthesize nameTextField = _varName;
@synthesize objectView    = _objectView;
@synthesize typeLabel     = _type;
@synthesize typeControls   = _typeName;

/// An enum that keeps track of where each type of the variable is in the segmented control.
enum varType
{
    NO_BOX_INDEX = 0,
    BOXED_INDEX  = 1
};

/// Initializes the view.
/// @param frame the frame the view is contained within.
/// @return an id of the newly created view.
-(id) initWithFrame:(CGRect)frame view:(UIView*) view
{
    self.objectView = (VariableView*)view;
    
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        
        //***********************************************************************************************************************
        // Set up the name label.
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  frame.size.width,
                                                                  LABEL_SIZE)];
        self.nameLabel.text            = VARIABLE_NAME_LABEL;
        self.nameLabel.opaque          = NO;
        self.nameLabel.textColor       = [UIColor whiteColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.nameLabel];
        
        // Set up the name text field.
        self.nameTextField = [[UITextField alloc]initWithFrame:CGRectMake(0,
                                                                          self.nameLabel.frame.size.height,
                                                                          frame.size.width,
                                                                          TEXT_FIELD_SIZE)];
        self.nameTextField.backgroundColor    = [UIColor whiteColor];
        self.nameTextField.text               = self.objectView.name;
        self.nameTextField.borderStyle        = UITextBorderStyleRoundedRect;
        self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.nameTextField.secureTextEntry    = NO;
        self.nameTextField.delegate           = self;
        self.nameTextField.returnKeyType      = UIReturnKeyDone;
        [self addSubview:self.nameTextField];
        
        //***********************************************************************************************************************
        // Set up the type label.
        self.typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                                  self.nameTextField.frame.origin.y + self.nameTextField.frame.size.height,
                                                                  frame.size.width,
                                                                  LABEL_SIZE)];
        self.typeLabel.text            = VARIABLE_TYPE_LABEL;
        self.typeLabel.opaque          = NO;
        self.typeLabel.textColor       = [UIColor whiteColor];
        self.typeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.typeLabel];
        
        // Set up the type controls.
        self.typeControls = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:NORMAL_LABEL, BOXED_LABEL, nil]];
        
        self.typeControls.frame = CGRectMake(0,
                                            self.typeLabel.frame.origin.y + self.typeLabel.frame.size.height,
                                            frame.size.width,
                                            SEGMENT_SIZE);

        int index = (self.objectView.isBoxed);
        [self.typeControls setSelectedSegmentIndex:index];
        self.typeControls.segmentedControlStyle = UISegmentedControlStyleBar;
        [self.typeControls addTarget:self action:@selector(typeControlChange) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.typeControls];

    }
    return self;
}

/// This method will be called when the save button is called to save the attributes.
-(void) updateVariable
{
    //***********************************************************************************************************************
    // Only log type change when the variable type changes.
    if(self.objectView.isBoxed != self.typeControls.selectedSegmentIndex)
    {
        NSString* details;
        if(self.objectView.isBoxed)
            details = [[NSString alloc] initWithFormat:FROM_TO, BOXED_LABEL, NORMAL_LABEL]; 
        else
            details =[[NSString alloc] initWithFormat:FROM_TO, NORMAL_LABEL, BOXED_LABEL];
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: VAR_TYPE_CHANGED
                                                                   andObjectID:[(Variable*)self.objectView.parent idNum]
                                                                    andDetails:details]];
    }
    
    [self.objectView setIsBoxed:(self.typeControls.selectedSegmentIndex == BOXED_INDEX)];
    
    //***********************************************************************************************************************
    // Only log name changed event when the name changes.
    if(![self.objectView.name isEqualToString:self.nameTextField.text])
    {
        NSString* details = [[NSString alloc] initWithFormat:FROM_TO, self.objectView.name, self.nameTextField.text];
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: VAR_NAME_CHANGED
                                                                   andObjectID:[(Variable*)self.objectView.parent idNum]
                                                                    andDetails:details]];
    }
    
    self.objectView.name = self.nameTextField.text;
    [self.objectView setNeedsDisplay];
}

/// Draws the receiver’s image within the passed-in rectangle.  This is an overridden method.
/// @param rect the frame of the view in which objects can be drawn.
- (void)drawRect:(CGRect)rect
{
}

/// Notifies the logger when a new option from the type segmented control has been changed.
-(void) typeControlChange
{
    NSString* details;
    switch(self.typeControls.selectedSegmentIndex)
    {  
        case NO_BOX_INDEX:
            details = NORMAL_VAR_SELECTED;
            break;
            
        case BOXED_INDEX:
            details = BOXED_VAR_SELECTED;
            break;
    }
    
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: VAR_TYPE_CONTROL_CHANGED
                                                               andObjectID:[(Variable*)self.objectView.parent idNum]
                                                                andDetails:details]];
}

/// Will log when the keyboard opens up for the user to edit.
/// @param textField the textfield that makes the call.
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: KEYBOARD_OPENED
                                                               andObjectID:[(Variable*)self.objectView.parent idNum]
                                                                andDetails:EDIT_VARIABLE_NAME]];
}

/// Will log when the keyboard closes. Cannot place event in textFieldShouldReturn becuase iOS 5 does not call the method.
/// @param textField the textfield that makes the call.
-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: KEYBOARD_CLOSED
                                                               andObjectID:[(Variable*)self.objectView.parent idNum]
                                                                andDetails:EDIT_VARIABLE_NAME]];
}

/// Determines whether the keyboard should close for the text field.
/// @param textField the textfield that makes the call.
/// @return will always be true and the keyboard will always close when the Done button is pressed.
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;    
}

@end
