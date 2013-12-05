//
//  Constants.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/29/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#ifndef GroupModelingApp_Constants_h
#define GroupModelingApp_Constants_h
#import "AvailabilityInternal.h"

//===============================================================================================================================
// Constants related to the event logger.
//================================================================================================================================

// Constants for Event
#define APPLICATION_ID              0                                       // By default for logging ID 0 will be for the entire application.

// Generic Messages
#define LOG_HEADER_SPACING          @"%-10s , %-20s, %-10s, %55s, %-10s, %s"// Spacing for the header of the event logging file
#define LOG_OUPUT_SPACING           @"%-10d , %-20s, %-10d, %55s, %-10d, %@"// Spacing for the data in the event logging file
#define FROM_TO                     @"From: %@ To: %@"                      // Used to describe the old attribute and the new attribute of a component.
#define PARENT_CHILD                @"Parent: %@ (%d) Child: %@ (%d) | "    // Used to describe a causal link.
#define NUMBER_DELETED              @"Number deleted:%d | "                 // Used to describe the number of causal links deleted when a variable was deleted.
#define COORDINATES                 @"(%d;%d)"                              // Used to print out details of a location on a move.
#define OBJECT_NAME                 @"Name: %@"                             // Used to print out the name of an object.
#define OBJECT_TYPE                 @"Type: %@"                             // Used to print out the type of the object.
#define POLARITY_TYPE               @"Polarity: %@"                         // Used to print out the polarity of a causal link.
#define LINE_TYPE                   @"Line: %@"                             // Used to print out the line thickness of a causal link.
#define TIME_DELAY_TYPE             @"Time Delay: %@"                       // Used to print out the time delay of the causal link.
#define COLOR_TYPE                  @"Color: %@"                            // Used to print out the color of the causal link.

// Header Labels for the log
#define EVENT_ID                    @"Event ID"
#define EVENT_TIME                  @"Event time"
#define DESC_ID                     @"Desc ID"
#define DESCRIPTION                 @"Description"
#define OBJECT_ID                   @"Object ID"
#define DETAILS                     @"Details"

// Orientation Messages for AppDelegate.
#define LANDSCAPE_LEFT              @"Landscape left"
#define LANDSCAPE_RIGHT             @"Landscape right"
#define PORTRAIT                    @"Portrait"
#define PORTRAIT_UPSIDEDOWN         @"Portrait Upside Down"
#define FACE_UP                     @"Face Up"
#define FACE_DOWN                   @"Face Down"
#define UNKNOWN                     @"Unknown"

// CausalLinkEditMenuView Message Details.
#define NORMAL_LINE_SELECTED        @"Normal selected"
#define BOLD_LINE_SELECTED          @"Bold selected"
#define PLUS_POLARITY_SELECTED      @"+ selected"
#define MINUS_POLARITY_SELECTED     @"- selected"
#define BLACK_COLOR_SELECTED        @"Black selected"
#define BLUE_COLOR_SELECTED         @"Blue selected"
#define GREEN_COLOR_SELECTED        @"Green selected"
#define ORANGE_COLOR_SELECTED       @"Orange selected"
#define RED_COLOR_SELECTED          @"Red selected"

// FileIO Message Details.
#define NO_FILE_ID                  @"Could not find/create a file ID"
#define NO_USER_ID                  @"User was not successfully created."
#define NO_PARSE_CONNECTION         @"Issue in uploading to Parse. EndingHash: %@"

// LoopEditMenuView Message Details.
#define CLOCKWISE_SELECTED          @"Clockwise selected"
#define COUNTER_CLOCKWISE_SELECTED  @"Counter clockwise selected"

// ModelSectionViewController Message Details
#define VAR_OPTION_SELECTED         @"Variable option selected"
#define LINK_OPTION_SELECTED        @"Causal Link option selected"
#define LOOP_OPTION_SELECTED        @"Loop option selected"

// VariableEditMenuView Message Details
#define NORMAL_VAR_SELECTED         @"Normal selected"
#define BOXED_VAR_SELECTED          @"Boxed selected"

// Message Details for opening and closing the keyboard.
#define EDIT_LOOP_NAME              @"Edit Loop name"
#define EDIT_VARIABLE_NAME          @"Edit Variable name"

// Message details for creating, editing and closing the edit menus.
#define CAUSAL_LINK_LABEL           @"Causal link"
#define LOOP_LABEL                  @"Loop"
#define VARIABLE_LABEL              @"Variable"

// Enumeration to conatin all of the messages.
enum EventLoggingGenericMessages
{
    // Messages for the App Delegate
    APP_LOADED,
    APP_ENTERED_BACKGROUND,
    APP_ENTERED_FOREGROUND,
    APP_TERMINATED,
    MEMORY_WARNING,
    ORIENTATION_CHANGED,
    
    // Messages for CausalLink
    IMPORTED_CAUSAL_LINK,
    
    // Messages for CasualLinkEditMenuView
    LINK_COLOR_CHANGED,
    LINK_POLARITY_CHANGED,
    LINK_THICKNESS_CHANGED,
    LINK_TIME_DELAY_CHANGED,
    LINK_TIME_DELAY_CONTROL_CHANGED,
    LINK_THICKNESS_CONTROL_CHANGED,
    LINK_POLARITY_CONTROL_CHANGED,
    LINK_COLOR_CONTROL_CHANGED,
    
    // Messages for CausalLinkView
    BEGIN_LINK_MOVE,
    LINK_MOVE,
    END_LINK_MOVE,
    
    // Messages for FileIO
    UPLOAD_TO_PARSE_FAILED,
    
    // Messages for keyboard. Used in Loop and Variable.
    KEYBOARD_OPENED,
    KEYBOARD_CLOSED,
    
    // Messgaes for Loop
    IMPORTED_LOOP,
    
    // Messages for LoopEditMenuView
    LOOP_NAME_CHANGED,
    LOOP_SYMBOL_CHANGED,
    LOOP_SYMBOL_CONTROL_CHANGED,
    
    // Messages for LoopView
    BEGIN_LOOP_MOVE,
    LOOP_MOVE,
    END_LOOP_MOVE,
    
    // Messages for MFSideMenuViewController.
    MODEL_VIEW_OPEN,
    HELP_VIEW_OPEN,
    MENU_CLOSED,
    
    // Messages for Model
    REMOVED_LINKS,

    // Messages for ModelSectionView
    ADD_VARIABLE,
    ADD_LOOP,
    USER_BEGIN_SCROLLING,
    USER_SCROLLING,
    USER_STOPPED_SCROLLING,
    SCROLLING_STOPPED,

    // Messages for ModelSectionViewController
    NEW_MODEL_WARNING,
    NEW_MODEL_WARNING_DISMISSED,
    NEW_MODEL,
    MENU_OPENED,
    SAVE_IMAGE_OF_MODEL,
    IMAGE_SAVED,
    IMAGE_NOT_SAVED,
    NOTIFY_IMAGE_NOT_SAVED,
    NOTIFY_IMAGE_SAVED,
    CONFIRM_IMAGE_SAVED,
    CONFIRM_IMAGE_NOT_SAVED,
    SAVE_MODEL,
    REDIRECTED_TO,
    SAVE_OPTIONS_OPENED,
    SAVE_OPTIONS_CLOSED,
    OPEN_FILE_REQUEST,
    INVALID_FILE,
    CONFIRM_INVALID_FILE,
    FILE_SELECTED,
    OPEN_REQUEST_CANCELLED,
    UPDATE_MENU_OPENED,
    UPDATE_MENU_CLOSED,
    EDIT_MENU_CREATED,
    EDIT_MENU_SAVED,
    EDIT_MENU_CANCELLED,
    DELETE_WARNING,
    DELETE_WARNING_DISMISSED,
    VARIABLE_DELETED,
    LOOP_DELETED,
    CAUSAL_LINK_DELETED,
    ADD_OBJECT_CONTROL_CHANGED,
    INTERNET_CONNECTION,
    NO_INTERNET_CONNECTION,
    
    // Messgaes for Variable
    IMPORTED_VARIABLE,
    
    // Messages for VariableEditMenuView
    VAR_NAME_CHANGED,
    VAR_TYPE_CHANGED,
    VAR_TYPE_CONTROL_CHANGED,
    
    // Messages for VariableView
    BEGIN_ADD_CAUSAL_LINK,
    CAUSAL_LINK_ADD_IN_PROGRESS,
    CAUSAL_LINK_ADDED,
    CASUAL_LINK_CANCELLED,
    BEGIN_VAR_MOVE,
    VAR_MOVE,
    END_VAR_MOVE
};

//===============================================================================================================================
// Constants related to Vensim mdl files.
//===============================================================================================================================

/// Constants used for creating the export files.
#define ENCODING        @"{UTF-8}"             // the encoding of the mdl file.
#define FUNCTION_OF     @" = A FUNCTION OF( "  // Used to create the variable maps.
#define COMMA           @" , "
#define CLOSED_PAREN    @")"
#define TILDE           @"~"
#define TILDE_BAR       @"~|\n"
#define SKETCH_INFO     @"\\\\\\---/// Sketch information - do not modify anything except names"
#define V300            @"V300  Do not put anything below this section - it will be ignored"
#define VIEW            @"*View 1"
#define DEFAULT_PARAMS  @"$192-192-192,0,Times New Roman|12||0-0-0|0-0-0|0-0-255|-1--1--1|-1--1--1|72,72,100,0"
#define CONTROL_PARAMS  @"********************************************************\n.Control\n********************************************************~\nSimulation Control Parameters\n|\n\nFINAL TIME  = 100\n~	Month\n~	The final time for the simulation.\n|\n\nINITIAL TIME  = 0\n~	Month\n~	The initial time for the simulation.\n|\n\nSAVEPER  =\nTIME STEP\n~	Month [0,?]\n~	The frequency with which output is stored.\n|\n\nTIME STEP  = 1\n~	Month [0,?]\n~	The time step for the simulation.\n|\n\n"

// Constants for exporting variables.
#define BOXED_VAR_NUMS  @",40,20,3"
#define NORMAL_VAR_NUMS @",45,11,0"        /// @note unsure of what the first two numbers represent. May need to modify.
#define VAR_DEFAULTS    @",3,0,0,0,0,0,0"

// Constants for exporting causal links.
#define CAUSAL_LINK_DEFAULTS1   @",0,0"
#define COLOR_ON                @",3"       /// @note not sure what this really represents,but 3 makes it so color can be exported.
#define DEFAULT_LINK_COLOR      @",-1--1--1"
#define DEFAULT_LINK_FONT_SIZE  @",|0|"
#define DEFAULT_LINK_FONT_COLOR @"|-1--1--1,1"
#define BAR_PAREN               @"|("
#define PAREN_BAR               @")|"
#define UNKNOWN_CHAR            @",0" 

// Constants for exporting loops.
#define LOOP_DEFAULTS1         @",20,20"
#define LOOP_DEFAULTS2         @",7,0,0,0,0,0,0"

// Constants for importing the time delay
#define TIME_DELAY1             65         /// Time delay when polarity symbol located at arrowhead inside.
#define TIME_DELAY2             193        /// Time delay when polarity symbol located at arrowhead outside.
#define TIME_DELAY3             129        /// Time delay when polarity symbol located at handle outside.
#define TIME_DELAY4             1          /// Time delay when polarity symbol located at handle inside.

/// Numerical values Vensim uses to represent the different component types in a causal diagram.
enum ObjectType
{
    CAUSAL_LINK = 1,
    VARIABLE    = 10,
    LOOP        = 12
};

/// The numerical value that represents the type of variables.
enum VariableSymbol
{
    NORMAL_VAR = 0,
    BOXED_VAR  = 3
};

/// An enum to keep track of the values for the possible symbol images.
enum LoopShape
{
    CLOCKWISE         = 4,
    COUNTER_CLOCKWISE = 5
};

/// Enum containing the numerical values that represent how the polarity of a CausalLink is stored.
enum Polarity
{
    PLUS  = 43,
    MINUS = 45
};

/// An enum representing the Vensim values for line thickness.
enum LineThickness
{
    NORMAL     = 0,
    LIGHT_BOLD = 12,
    BOLD       = 13
};

// Constants for FileIO
#define EVENTS_EXPORT_FILE         @"eventLogging.csv"  // File name to save the event logging results.
#define CLASS_NAME                 @"EventLogger"       // The name of the class that Parse will store the event logging data.
#define USER_ID                    @"UserID"            // The name of the column that contains the unique user id.
#define STARTING_HASH              @"StartingHash"      // The name of the column that contains the starting hash of the file.
#define ENDING_HASH                @"EndingHash"        // The name of the column that contains the ending hash of the file.
#define EVENT_LOG                  @"EventLog"          // The name of the column that contains the event log file.
#define MODEL_FILE                 @"ModelFile"         // The name of the column that contains the model file.
#define GID                        @"gid"               // The name of the column that contains the unique file id for user file combination.

// Strings that specifiy where in the Vensim mdl file certain aspects of the model are located.
#define  COMPONENT_PREFIX          @"\\\\\\"   // The beginning of the line in the Vensim file that starts the component definitions.
#define  DEFAULT_PARAMS_PREFIX     @"$"        // The beginning character that starts the default params line.
#define  SIM_CONTROL_PARAMS_PREFIX @"****"     // The beginning prefix of the simulation control parameters section of the Vensim file.
#define  END_OF_COMPONENTS         @"///"      // The beginning prefix of the end of the components section of the Vensim file.
#define  LARGEST_COMPONENT_ID      @"-"        // Prefix of the line that will contain the largest component id. Not a Vensim standard.

//================================================================================================================================
// Constants realated to UI objects.
//================================================================================================================================

// Constants for display information.
#define FONT              @"TimesNewRomanPSMT" // The font of the comment of the loop.
#define FONT_SIZE         12                   // The size of the font for the comment.

// Constants for the edit menu views.
#define LABEL_SIZE        20                   // The size of the labels for the edit menu.
#define SEGMENT_SIZE      30                   // The size of the segment for the edit menu.
#define TEXT_FIELD_SIZE   30                   // The size of text field for the edit menu.
#define BUTTON_SIZE       30                   // The size of the edit menu buttons.

#define TOOLBAR_HEIGHT    44                   // The height of the toolbar for the edit menu.
#define EDIT_MENU_WIDTH   220                  // The width of the menu that allows you to edit the loop, causal link, and variable.
#define EDIT_MENU_HEIGHT  150                  // The height of the menu that allows you to edit the loop, causal link, and variable.
#define EDIT_MENU_HEIGHT_EXTENSION 100         // This extension is used for the link menu where there is an extra field.

// Other constants.
#define DEFAULT_TEXT_POS  0                    // Where in relationship to the object is text located. (ie above, below, center). For Vensim the default is set to 0.
#define DEFAULT_TITLE     @"New Model"

//================================================================================================================================
// Constants realated to views.
//================================================================================================================================

// Sizes of views.
#define VAR_WIDTH               100                 // Constant to keep track of the width of the variable view window.
#define VAR_HEIGHT              50                  // Constant to keep track of the width of the variable view window.
#define SIDE                    50                  // The loop will be created in a square window and this is the size of the side.

// Constants for CausalLinkeEditMenuView
#define LINE_THICKNESS_LABEL    @"Link Thickness"   // Label to display in the edit menu so the user knows what the segmented control is for.
#define POLARITY_LABEL          @"Polarity"         // Label to display in the edit menu so the user knows what the segmented control is for.
#define COLOR_PICKER_LABEL      @"Link Color"       // Label to display in the edit menu so the user know what the segmented control is for.
#define NORMAL_LINE_THICKNESS   @"Normal"           // Label for one of the segmented control options for line thickness controls.
#define BOLD_LINE_THICKNESS     @"Bold"             // Label for one of the segmented control options for line thickness controls.
#define PLUS_SYMBOL             @"+"                // Label for one of the segmented control options for polarity controls.
#define MINUS_SYMBOL            @"-"                // Label for one of the segmented control options for polarity controls.
#define TIME_DELAY_LABEL        @"Time Delay"       // Label to display in the edit menu so the user knows what the segmeneted control is for.
#define NO_LABEL                @"No"               // Label for one of the segemented control options for timeDelay controls.
#define YES_LABEL               @"Yes"              // Label for one of the segemented control options for timeDelay controls.
#define BLACK_COLOR             @"Black"
#define BLUE_COLOR              @"Blue"
#define GREEN_COLOR             @"Green"
#define ORANGE_COLOR            @"Orange"
#define RED_COLOR               @"Red"

// Constants for CausalLinkHandleView.
#define HANDLE_SIZE             8                    // The size of the handle on a causal link that the user moves to edit it.

// Constants for CausalLinkView.
#define ARROWHEAD_ANGLE         30.0                 // The angle at which the arrowhead is constructed.
#define ARROWHEAD_SIZE          15.0                 // The length of the arrowhead.
#define ARROWHEAD_LINE_WIDTH    1.0                  // The width of the lines to draw the arrowhead.  Should not matter much since it will be filled in with color.
#define BUFFER                  30                   // Used to created a buffer around the frame that will contain the arc.
#define DEG_TO_RAD              M_PI / 180           // The conversion factor from degrees to radians.
#define HANDLE_FRAME_SIZE       50                   // The size of the handle frame.
#define MAX_SLOPE_CHANGE        10.0                 // The max slope that will be allowed.  This will force all arcs to move up and down at around the same rate.
#define MAX_SIZE_DISTANCE       100                  // The maximum distance between two variables before the slope becomes near vertical or horizotnal.
#define POLARITY_SIZE           24                   // The size of the polarity frame and font size.
#define TIME_DELAY_SIZE         20                   // The length of the line used to rotate to construct the time delay.
#define TIME_DELAY_ANGLE        30.0                 // The angle at which the time delay is constructed.
#define TIME_DELAY_THICKNESS    4.0                  // The thickness of the time delay line.
#define TIME_DELAY_T_VAL        0.5                  // Used to find where the delay should be drawn.  0.5 is used as the point where the vertex is located.
#define T_INCREMENT             0.005                // Value in which t will be incremented to determine points on a Bezier curve.
#define T_MIN                   0.0                  // The minimum value that t for the Bezier quad curve equation can be.
#define T_MAX                   1.0                  // The maximum value that t for the Bezier quad curve equation can be.
#define VERTEX_OFFSET           12                   // Distance from the vertex to the polarity symbol.

// Constants for LoopEditMenuView
#define COMMENT_LABEL           @"Comment"           // Label to display in the edit menu so the user knows the text field is for the Loop name.
#define COMMENT_SYMBOL_LABEL    @"Comment Symbol"    // Label to display in the edit menu so that the user knows what the segmented control is for.
#define CLOCKWISE_LABEL         @"Clockwise"         // Label for one of the segmented control options for variable type.
#define COUNTER_CLOCKWISE_LABEL @"Counter Clockwise" // Label for one of the segmented control options for variable type.


// Constants for LoopView.
#define DEFAULT_LOOP_NAME       @"TXT"               // The default name of the loop when it is created.
#define ARROWHEAD_HEIGHT        15                   // The height of the arrowhead.
#define ARROWHEAD_WIDTH         10                   // The width of the arrowhead.
#define BUFFER_SPACE            5                    // The amount of space between the edge of the frame and the loop.
#define VERTEX_X                ARROWHEAD_WIDTH /2   // The vertex of the arrowhead is half of the width.

// Constants for ModelSectionViewController
enum ModelSectionViewAlerts
{
    DELETE_ALERT       = 1,
    IMAGE_SAVE_ALERT   = 2,
    IMAGE_NOSAVE_ALERT = 3,
    NEW_MODEL_ALERT    = 4,
    INVALID_FILE_ALERT = 5
};
#define MENU_ICON               @"menu_icon_black.png"      // Left side bar menu icon.
#define NEW_MODEL_ICON          @"new_model_black.png"      // Icon to create a new model.
#define DISABLE_OPEN_MODEL_ICON @"open_file_redX.png"       // Icon to display when there is no internet access.
#define OPEN_MODEL_ICON         @"open_file_black.png"      // Icon to open a model.
#define DISABLE_SAVE_ICON       @"save_model_redX.png"      // Icon to display when there is no internet access.
#define SAVE_ICON               @"save_model_black.png"     // Icon to save the model.
#define PHOTO_ICON              @"photo_icon_black.png"     // Icon to take a picture of the model.
#define VARIABLE_ICON           @"variable_icon_black.png"  // Icon to add a new variable.
#define LINK_ICON               @"link_icon_black.png"      // Icon to add a new causal link.
#define LOOP_ICON               @"loop_icon_black.png"      // Icon to add a new loop.
#define MDL_EXTENSION           @".mdl"                     // Accepted file extension.
#define TXT_EXTENSION           @".txt"                     // Accepted file extension.
#define LOG_QUEUE               "log_queue"                 // The name of the asynch queue used to push logs to Parse.

// Alert Messages.
#define NEW_MODEL_MSG           @"Are you sure you would like to create a new model? All unsaved changes will be lost."
#define BAD_FILE_MSG            @"I cannot open this file. Please open a .mdl or .txt file"
#define DELETE_OBJ_WARNING      @"Are you sure you would like to delete this object and any associated objects?"
#define PICTURE_SAVED_MSG       @"Your picture has been successfully saved to your photo album."
#define PICTURE_NOT_SAVED_MSG   @"There was an issue saving your picture to the photo album."

// Alert titles and button titles.
#define TITLE_CANCEL            @"Cancel"
#define TITLE_DELETE            @"Delete"
#define TITLE_EDIT              @"Edit"
#define TITLE_NO                @"No"
#define TITLE_OK                @"OK"
#define TITLE_PICTURE_NOT_SAVED @"Picture not Saved!"
#define TITLE_PICUTRE_SAVED     @"Picture Saved!"
#define TITLE_SAVE              @"Save"
#define TITLE_SORRY             @"Sorry!"
#define TITLE_WARNING           @"Warning!"
#define TITLE_YES               @"Yes"

// Constants for scrollview.
#define MIN_ZOOM                1                    // The minimum zoom for the scrollview. Using scrollview for a bigger canvas only.
#define MAX_ZOOM                1                    // The maximum zoom for the scrollview. Using scrollview for a bigger canvas only.
#define SCROLL_WIDTH            2000                 // Ths width of the scrollview canvas.
#define SCROLL_HEIGHT           2000                 // The height of the scrollveiw canvas.

// Constants for VariableEditMenuView
#define VARIABLE_NAME_LABEL     @"Variable Name"     // Label to display in the edit menu so the user knows the text field is for the Variable name.
#define VARIABLE_TYPE_LABEL     @"Variable Type"     // Label to display in the edit menu so that the user knows what the segmented control is for.
#define NORMAL_LABEL            @"Normal"            // Label for one of the segmented control options for variable type.
#define BOXED_LABEL             @"Boxed"             // Label for one of the segmented control options for variable type.

// Constants for VariableView
#define DEFAULT_VAR_NAME        @"New Variable"      // The default name of the variable when it is created.

#endif
