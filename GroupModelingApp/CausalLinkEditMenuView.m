//
//  CausalLinkEditMenuView.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/28/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "CausalLink.h"
#import "CausalLinkEditMenuView.h"
#import "Constants.h"
#import "EventLogger.h"

@implementation CausalLinkEditMenuView

@synthesize lineThicknessControls = _lineThicknessContols;
@synthesize lineThicknessLabel    = _lineThicknessLabel;
@synthesize objectView            = _objectView;
@synthesize polarityControls      = _polarityControls;
@synthesize polarityLabel         = _polarityLabel;
@synthesize timeDelayControls     = _timeDelayControls;
@synthesize timeDelayLabel        = _timeDelayLabel;
@synthesize colorPicker           = _colorPicker;
@synthesize colorPickerLabel      = _colorPickerLabel;

/// An enum that keeps track of the index of the polarity in the segmented control.
enum polarityIndex
{
    MINUS_INDEX = 0,
    PLUS_INDEX  = 1
};

/// An enum that keeps track of the index of the line thickness segmented control.
enum lineThicknessIndex
{
    NORM_INDEX = 0,
    BOLD_INDEX = 1
};

/// An enum that keeps track of the index of the whether there is a time delay.
enum timeDelayIndex
{
    NO_INDEX  = 0,
    YES_INDEX = 1
};

/// An enum that keeps track of the index of the color picker segmented control.
enum colorIndex
{
    BLACK_INDEX  = 0,
    RED_INDEX    = 1,
    GREEN_INDEX  = 2,
    BLUE_INDEX   = 3,
    ORANGE_INDEX = 4
};

/// Initializes the view.
/// @param frame the frame the view is contained within.
/// @param view the uiview of the object that the menu is being created for.
/// @return an id of the newly created view.
- (id)initWithFrame:(CGRect)frame view:(UIView*) view
{
    self.objectView = (CausalLinkView*)view;
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
        
        //***********************************************************************************************************************
        // Set up the line thickness label.
        self.lineThicknessLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           frame.size.width,
                                                                           LABEL_SIZE)];
        self.lineThicknessLabel.text            = LINE_THICKNESS_LABEL;
        self.lineThicknessLabel.opaque          = NO;
        self.lineThicknessLabel.textColor       = [UIColor whiteColor];
        self.lineThicknessLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.lineThicknessLabel];
        
        // Set up the line thickness controls.
        self.lineThicknessControls = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:NORMAL_LINE_THICKNESS, BOLD_LINE_THICKNESS, nil]];
        self.lineThicknessControls.frame = CGRectMake(0,
                                                     self.lineThicknessLabel.frame.origin.y +
                                                     self.lineThicknessLabel.frame.size.height,
                                                     frame.size.width,
                                                     SEGMENT_SIZE);
        
        int index = self.objectView.isBold;
        [self.lineThicknessControls setSelectedSegmentIndex:index];
        self.lineThicknessControls.segmentedControlStyle = UISegmentedControlStyleBar;
        [self.lineThicknessControls addTarget:self action:@selector(lineThicknessControlsChange) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.lineThicknessControls];

        //***********************************************************************************************************************
        // Set up the type label.
        self.polarityLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                                      self.lineThicknessControls.frame.origin.y +
                                                                      self.lineThicknessControls.frame.size.height,
                                                                      frame.size.width,
                                                                      LABEL_SIZE)];
        self.polarityLabel.text            = POLARITY_LABEL;
        self.polarityLabel.opaque          = NO;
        self.polarityLabel.textColor       = [UIColor whiteColor];
        self.polarityLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.polarityLabel];
        
        // Set up the type controls.
        self.polarityControls = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:MINUS_SYMBOL, PLUS_SYMBOL, nil]];
        
        self.polarityControls.frame = CGRectMake(0,
                                                 self.polarityLabel.frame.origin.y +
                                                 self.polarityLabel.frame.size.height,
                                                 frame.size.width,
                                                 SEGMENT_SIZE);
        
        index = ([self.objectView.polarity isEqual:PLUS_SYMBOL]);
        [self.polarityControls setSelectedSegmentIndex:index];
        self.polarityControls.segmentedControlStyle = UISegmentedControlStyleBar;
        [self.polarityControls addTarget:self action:@selector(polarityControlsChange) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.polarityControls];
        
        //***********************************************************************************************************************
        // Set up the time delay label.
        self.timeDelayLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                                      self.polarityControls.frame.origin.y +
                                                                      self.polarityControls.frame.size.height,
                                                                      frame.size.width,
                                                                      LABEL_SIZE)];
        self.timeDelayLabel.text            = TIME_DELAY_LABEL;
        self.timeDelayLabel.opaque          = NO;
        self.timeDelayLabel.textColor       = [UIColor whiteColor];
        self.timeDelayLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.timeDelayLabel];
        
        // Set up the type controls.
        self.timeDelayControls = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:NO_LABEL, YES_LABEL, nil]];
        
        self.timeDelayControls.frame = CGRectMake(0,
                                                 self.timeDelayLabel.frame.origin.y +
                                                 self.timeDelayLabel.frame.size.height,
                                                 frame.size.width,
                                                 SEGMENT_SIZE);
        
        [self.timeDelayControls setSelectedSegmentIndex:self.objectView.hasTimeDelay];
        self.timeDelayControls.segmentedControlStyle = UISegmentedControlStyleBar;
        [self.timeDelayControls addTarget:self action:@selector(timeDelayControlsChange) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.timeDelayControls];
        
        //***********************************************************************************************************************
        // Set up the color picker label 
        self.colorPickerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                                      self.timeDelayControls.frame.origin.y +
                                                                      self.timeDelayControls.frame.size.height,
                                                                      frame.size.width,
                                                                      LABEL_SIZE)];
        self.colorPickerLabel.text            = COLOR_PICKER_LABEL;
        self.colorPickerLabel.opaque          = NO;
        self.colorPickerLabel.textColor       = [UIColor whiteColor];
        self.colorPickerLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.colorPickerLabel];
        
        // Set up the color picker controls.
        self.colorPicker = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:BLACK_COLOR,
                                                                     RED_COLOR,
                                                                     GREEN_COLOR,
                                                                     BLUE_COLOR,
                                                                     ORANGE_COLOR,
                                                                     nil]];
        
        self.colorPicker.frame = CGRectMake(0,
                                            self.colorPickerLabel.frame.origin.y + self.colorPickerLabel.frame.size.height,
                                            frame.size.width,
                                            SEGMENT_SIZE);
        
        
        [self.colorPicker setSelectedSegmentIndex:[self getColorIndex]];
        self.colorPicker.segmentedControlStyle = UISegmentedControlStyleBar;
        [self.colorPicker addTarget:self action:@selector(colorPickerControlsChange) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.colorPicker];
    }
    return self;
}

/// This method will be called when the save button is called to save the attributes.
-(void) updateCausalLink
{
    //***********************************************************************************************************************
    // Update polarity
    NSString* polarity = (self.polarityControls.selectedSegmentIndex == PLUS_INDEX) ? PLUS_SYMBOL : MINUS_SYMBOL;
    // Log message if polarity has changed.
    if(![self.objectView.polarity isEqualToString:polarity])
    {
        NSString* details = [[NSString alloc] initWithFormat:FROM_TO, self.objectView.polarity, polarity];
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: LINK_POLARITY_CHANGED
                                                                   andObjectID:[(CausalLink*)self.objectView.parent idNum]
                                                                    andDetails:details]];
    }
    
    [self.objectView setPolarity: polarity];
    
    //***********************************************************************************************************************
    // Update the line thickness
    // Log message if line thickness has changed.
    if(self.objectView.isBold != self.lineThicknessControls.selectedSegmentIndex)
    {
        NSString* details;
        if(self.objectView.isBold)
            details = [[NSString alloc] initWithFormat:FROM_TO, BOLD_LINE_THICKNESS, NORMAL_LINE_THICKNESS];
        else
            details = [[NSString alloc] initWithFormat:FROM_TO, NORMAL_LINE_THICKNESS, BOLD_LINE_THICKNESS];
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: LINK_THICKNESS_CHANGED
                                                                   andObjectID:[(CausalLink*)self.objectView.parent idNum]
                                                                    andDetails:details]];
    }
    
    self.objectView.isBold = (self.lineThicknessControls.selectedSegmentIndex == BOLD_INDEX);
    
    //***********************************************************************************************************************
    // Updeate the time delay
    if(self.objectView.hasTimeDelay != self.timeDelayControls.selectedSegmentIndex)
    {
        NSString* details;
        if(self.objectView.hasTimeDelay)
            details = [[NSString alloc] initWithFormat:FROM_TO, YES_LABEL, NO_LABEL];
        else
            details = [[NSString alloc] initWithFormat:FROM_TO, NO_LABEL, YES_LABEL];
        
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: LINK_TIME_DELAY_CHANGED
                                                                   andObjectID:[(CausalLink*)self.objectView.parent idNum]
                                                                    andDetails:details]];
    }
    
    self.objectView.hasTimeDelay = self.timeDelayControls.selectedSegmentIndex;
    
    //***********************************************************************************************************************
    // Update the arc color.
    // Log message if color has changed.
    if(![self.objectView.arcColor isEqual:[self getColor]])
    {
        NSString* details = [[NSString alloc] initWithFormat:FROM_TO, [CausalLink getColorName:self.objectView.arcColor],
                                                                      [CausalLink getColorName:[self getColor]]];
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: LINK_COLOR_CHANGED
                                                                   andObjectID:[(CausalLink*)self.objectView.parent idNum]
                                                                    andDetails:details]];
    }
    
    self.objectView.arcColor = [self getColor];
    
    [self.objectView setNeedsDisplay];
}

/// Gets the corresponding UIColor related to the selected segment index.
/// @return an instance of a UIColor used to set the color of the arc.
-(UIColor*)getColor
{
    UIColor* color;
    
    switch (self.colorPicker.selectedSegmentIndex) {
        case RED_INDEX:
            color = [UIColor redColor];
            break;
            
        case GREEN_INDEX:
            color = [UIColor greenColor];
            break;
            
        case BLUE_INDEX:
            color = [UIColor blueColor];
            break;
            
        case ORANGE_INDEX:
            color = [UIColor orangeColor];
            break;
            
        case BLACK_INDEX:
        default:
            color = [UIColor blackColor];
            break;
    }
    return color;
}

/// Get the segement index based on the current color of the causal link.
/// @return an integer representing a index of the segmented control.
-(int) getColorIndex
{
    int index;
    
    if([self.objectView.arcColor isEqual:[UIColor redColor]])
        index = RED_INDEX;
    else if([self.objectView.arcColor isEqual:[UIColor greenColor]])
        index = GREEN_INDEX;
    else if([self.objectView.arcColor isEqual:[UIColor blueColor]])
        index = BLUE_INDEX;
    else if([self.objectView.arcColor isEqual:[UIColor orangeColor]])
        index = ORANGE_INDEX;
    else
        index = BLACK_INDEX;

    return index;

}

/// Draws the receiver’s image within the passed-in rectangle.  This is an overridden method.
/// @param rect the frame of the view in which objects can be drawn.
- (void)drawRect:(CGRect)rect
{
}

/// Notifies the logger when a new option from the polarity segmented control has been changed.
-(void) polarityControlsChange
{
    NSString* details;
    switch(self.polarityControls.selectedSegmentIndex)
    {
        case PLUS_INDEX:
            details = PLUS_POLARITY_SELECTED;
            break;
            
        case MINUS_INDEX:
            details = MINUS_POLARITY_SELECTED;
            break;
    }
    
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: LINK_POLARITY_CONTROL_CHANGED
                                                               andObjectID:[(CausalLink*)self.objectView.parent idNum]
                                                                andDetails:details]];
}

/// Notifies the logger when a new option from the line thickness segmented control has been changed.
-(void) lineThicknessControlsChange
{
    NSString* details;
    switch(self.lineThicknessControls.selectedSegmentIndex)
    {
        case NORM_INDEX:
            details = NORMAL_LINE_SELECTED;
            break;
            
        case BOLD_INDEX:
            details = BOLD_LINE_SELECTED;
            break;
    }
    
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: LINK_THICKNESS_CONTROL_CHANGED
                                                               andObjectID:[(CausalLink*)self.objectView.parent idNum]
                                                                andDetails:details]];
}

/// Notifies the logger when a new option from the time delay segmented control has been changed.
-(void) timeDelayControlsChange
{
    NSString* details;
    switch(self.timeDelayControls.selectedSegmentIndex)
    {
        case YES_INDEX:
            details = YES_LABEL;
            break;
            
        case NO_INDEX:
            details = NO_LABEL;
            break;
    }
    
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: LINK_TIME_DELAY_CONTROL_CHANGED
                                                               andObjectID:[(CausalLink*)self.objectView.parent idNum]
                                                                andDetails:details]];
}

/// Notifies the logger when a new option from the color picker segmented control has been changed.
-(void) colorPickerControlsChange
{
    NSString* details;
    switch (self.colorPicker.selectedSegmentIndex) {
        case RED_INDEX:
            details = RED_COLOR_SELECTED;
            break;
            
        case GREEN_INDEX:
            details = GREEN_COLOR_SELECTED;
            break;
            
        case BLUE_INDEX:
            details = BLUE_COLOR_SELECTED;
            break;
            
        case ORANGE_INDEX:
            details = ORANGE_COLOR_SELECTED;
            break;
            
        case BLACK_INDEX:
            details = BLACK_COLOR_SELECTED;
            break;
    }
    
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: LINK_COLOR_CONTROL_CHANGED
                                                               andObjectID:[(CausalLink*)self.objectView.parent idNum]
                                                                andDetails:details]];
}

@end
