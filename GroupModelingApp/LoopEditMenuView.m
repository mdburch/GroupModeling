//
//  LoopEditMenuView.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/28/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "Constants.h"
#import "EventLogger.h"
#import "Loop.h"
#import "LoopEditMenuView.h"

@implementation LoopEditMenuView

@synthesize nameLabel     = _nameLabel;
@synthesize nameTextField = _nameTextField;
@synthesize objectView    = _objectView;
@synthesize symbolControls = _symbolContols;
@synthesize symbolLabel   = _symbolLabel;

/// An enum that keeps track of where each type of the loop is in the segmented control.
enum loopType
{
    COUNTER_CLOCKWISE_INDEX = 0,
    CLOCKWISE_LOOP_INDEX    = 1
};


/// Initializes the view.
/// @param frame the frame the view is contained within.
/// @return an id of the newly created view.
- (id)initWithFrame:(CGRect)frame view:(UIView*) view
{
    self.objectView = (LoopView*)view;
    
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        
        //***********************************************************************************************************************
        // Set up the name label.
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  frame.size.width,
                                                                  LABEL_SIZE)];
        self.nameLabel.text            = COMMENT_LABEL;
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
        self.nameTextField.delegate           = self;
        self.nameTextField.returnKeyType      = UIReturnKeyDone;
        self.nameTextField.secureTextEntry    = NO;
        [self addSubview:self.nameTextField];
        
        //***********************************************************************************************************************
        // Set up the type label.
        self.symbolLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                                  self.nameTextField.frame.origin.y + self.nameTextField.frame.size.height,
                                                                  frame.size.width,
                                                                  LABEL_SIZE)];
        self.symbolLabel.text            = COMMENT_SYMBOL_LABEL;
        self.symbolLabel.opaque          = NO;
        self.symbolLabel.textColor       = [UIColor whiteColor];
        self.symbolLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.symbolLabel];
        
        // Set up the type controls.
        self.symbolControls = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:COUNTER_CLOCKWISE_LABEL, CLOCKWISE_LABEL, nil]];
        
        self.symbolControls.frame = CGRectMake(0,
                                            self.symbolLabel.frame.origin.y + self.symbolLabel.frame.size.height,
                                            frame.size.width,
                                            SEGMENT_SIZE);
        
        int index = (self.objectView.isClockwise);
        [self.symbolControls setSelectedSegmentIndex:index];
        self.symbolControls.segmentedControlStyle = UISegmentedControlStyleBar;
        [self.symbolControls addTarget:self action:@selector(symbolControlChange) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.symbolControls];
        
    }
    return self;
}

/// This method will be called when the save button is called to save the attributes.
-(void) updateLoop
{
    //***********************************************************************************************************************
    // Only log type change when the variable type changes.
    if(self.objectView.isClockwise != self.symbolControls.selectedSegmentIndex)
    {
        NSString* details;
        if(self.objectView.isClockwise)
            details = [[NSString alloc] initWithFormat:FROM_TO, CLOCKWISE_LABEL, COUNTER_CLOCKWISE_LABEL];
        else
            details = [[NSString alloc] initWithFormat:FROM_TO, COUNTER_CLOCKWISE_LABEL, CLOCKWISE_LABEL];
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: LOOP_SYMBOL_CHANGED
                                                                   andObjectID:[(Loop*)self.objectView.parent idNum]
                                                                    andDetails:details]];
    }
    
    //***********************************************************************************************************************
    [self.objectView setIsClockwise:(self.symbolControls.selectedSegmentIndex == CLOCKWISE_LOOP_INDEX)];
    
    // Only log name changed event when the name changes.
    if(![self.objectView.name isEqualToString:self.nameTextField.text])
    {
        NSString* details = [[NSString alloc] initWithFormat:FROM_TO, self.objectView.name, self.nameTextField.text];
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: LOOP_NAME_CHANGED
                                                                   andObjectID:[(Loop*)self.objectView.parent idNum]
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

/// Notifies the logger when a new option from the symbol segmented control has been changed.
-(void) symbolControlChange
{
    NSString* details;
    switch(self.symbolControls.selectedSegmentIndex)
    {
        case COUNTER_CLOCKWISE_INDEX:
            details = COUNTER_CLOCKWISE_SELECTED;
            break;
            
        case CLOCKWISE_LOOP_INDEX:
            details = CLOCKWISE_SELECTED;
            break;
    }
    
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: LOOP_SYMBOL_CONTROL_CHANGED
                                                               andObjectID:[(Loop*)self.objectView.parent idNum]
                                                                andDetails:details]];
}

/// Will log when the keyboard opens up for the user to edit.
/// @param textField the textfield that makes the call.
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: KEYBOARD_OPENED
                                                               andObjectID:[(Loop*)self.objectView.parent idNum]
                                                                andDetails:EDIT_LOOP_NAME]];
}

/// Will log when the keyboard closes. Cannot place event in textFieldShouldReturn becuase iOS 5 does not call the method.
/// @param textField the textfield that makes the call.
-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: KEYBOARD_CLOSED
                                                               andObjectID:[(Loop*)self.objectView.parent idNum]
                                                                andDetails:EDIT_LOOP_NAME]];
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
