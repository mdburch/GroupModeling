//
//  EventLogger.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 8/7/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "Constants.h"
#import "EventLogger.h"

@implementation EventLogger

@synthesize events    = _events;
@synthesize eventsKey = _eventsKey;

/// Forces the EventLogger to be a singleton class.
/// @return a pointer to the single instance of the event logger.
+(EventLogger*)sharedEventLogger {
    static EventLogger *sharedEventLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEventLogger = [[self alloc] init];
        sharedEventLogger.events   = [[NSMutableArray alloc] init];
        [sharedEventLogger populateEventKey];
    });
    return sharedEventLogger;
}

/// Will add a record in the event log with the time stamp and the event that occurred.
/// @param newEvent an instance of an Event containing the details of the event that should be added.
-(void)addEvent:(Event*)newEvent
{
    [self.events addObject:newEvent];
}

/// Constructs the file of events for the analysis.
/// @return an array of events with formatted output.
-(NSMutableArray*)createEventsOutput
{
     NSMutableArray* file = [[NSMutableArray alloc]init];
    // Create a title.
    [file addObject:[NSString stringWithFormat:LOG_HEADER_SPACING,
                     [EVENT_ID    UTF8String],
                     [EVENT_TIME  UTF8String],
                     [DESC_ID     UTF8String],
                     [DESCRIPTION UTF8String],
                     [OBJECT_ID   UTF8String],
                     [DETAILS     UTF8String]]];
                     
    for(int i=0; i<self.events.count; ++i)
    {
        // Get the array at index i.
        Event* event = [self.events objectAtIndex:i];
        
        // Convert the first object to a string so we can format
        NSString *eventTime = [NSString stringWithFormat:@"%@",event.time];
        // Write the event to the file
        [file addObject:[NSString stringWithFormat:LOG_OUPUT_SPACING,
                         i,
                         [eventTime UTF8String],
                         event.descriptionID,
                         [[self.eventsKey objectForKey:[NSNumber numberWithInt:event.descriptionID]] UTF8String],
                         event.objectID,
                         event.details]];
    }
    
    return file;
}

/// Removes all of the events in the list.
/// @param num the last event that was saved to the database.
-(void)clearEventsList:(int)num
{
    // Ensuring we do not remove more objects than we have.
    if(self.events.count >= num)
    {
        NSRange range = NSMakeRange(0, num);
        [self.events removeObjectsInRange:range];
    }
}

/// Maps the event description to the corresponding description id and adds it to the events key array.
-(void)populateEventKey
{
    self.eventsKey = [[NSMutableDictionary alloc]init];

    // Messages for the App Delegate
    [self.eventsKey setObject:@"The application has loaded."                            forKey:[NSNumber numberWithInt: APP_LOADED]];
    [self.eventsKey setObject:@"The application has been placed in the background."     forKey:[NSNumber numberWithInt: APP_ENTERED_BACKGROUND]];
    [self.eventsKey setObject:@"The application has been resumed."                      forKey:[NSNumber numberWithInt: APP_ENTERED_FOREGROUND]];
    [self.eventsKey setObject:@"The application has been killed."                       forKey:[NSNumber numberWithInt: APP_TERMINATED]];
    [self.eventsKey setObject:@"The application has received a memory warning."         forKey:[NSNumber numberWithInt: MEMORY_WARNING]];
    [self.eventsKey setObject:@"User changed the device's orientation."                 forKey:[NSNumber numberWithInt: ORIENTATION_CHANGED]];
    
    // Messages for Causal Link
    [self.eventsKey setObject:@"Imported a causal link from a file."                    forKey:[NSNumber numberWithInt: IMPORTED_CAUSAL_LINK]];
    
    // Messages for CasualLinkEditMenuView
    [self.eventsKey setObject:@"User changed the color of a causal link."               forKey:[NSNumber numberWithInt: LINK_COLOR_CHANGED]];
    [self.eventsKey setObject:@"User changed the polarity of a causal link."            forKey:[NSNumber numberWithInt: LINK_POLARITY_CHANGED]];
    [self.eventsKey setObject:@"User changed the thickness of a causal link."           forKey:[NSNumber numberWithInt: LINK_THICKNESS_CHANGED]];
    [self.eventsKey setObject:@"User changed the time delay of a causal link."          forKey:[NSNumber numberWithInt: LINK_TIME_DELAY_CHANGED]];
    [self.eventsKey setObject:@"User selected a new option for the link time delay."    forKey:[NSNumber numberWithInt: LINK_TIME_DELAY_CONTROL_CHANGED]];    
    [self.eventsKey setObject:@"User selected a new option for the link thickness."     forKey:[NSNumber numberWithInt: LINK_THICKNESS_CONTROL_CHANGED]];
    [self.eventsKey setObject:@"User selected a new option for the link polarity."      forKey:[NSNumber numberWithInt: LINK_POLARITY_CONTROL_CHANGED]];
    [self.eventsKey setObject:@"User selected a new option for the link color."         forKey:[NSNumber numberWithInt: LINK_COLOR_CONTROL_CHANGED]];
    
    // Messages for CausalLinkView
    [self.eventsKey setObject:@"User began moving a causal link."                       forKey:[NSNumber numberWithInt: BEGIN_LINK_MOVE]];
    [self.eventsKey setObject:@"User is moving a causal link."                          forKey:[NSNumber numberWithInt: LINK_MOVE]];
    [self.eventsKey setObject:@"User stopped moving a causal link."                     forKey:[NSNumber numberWithInt: END_LINK_MOVE]];
    
    // Messages for FileIO.
    [self.eventsKey setObject:@"Failed sending data to Parse."                          forKey:[NSNumber numberWithInt: UPLOAD_TO_PARSE_FAILED]];
    
    // Messages for keyboard. Used in Loop and Variable.
    [self.eventsKey setObject:@"Keyboard opened."                                       forKey:[NSNumber numberWithInt: KEYBOARD_OPENED]];
    [self.eventsKey setObject:@"Keyboard closed."                                       forKey:[NSNumber numberWithInt: KEYBOARD_CLOSED]];
    
    // Messages for Loop
    [self.eventsKey setObject:@"Imported a loop from a file."                           forKey:[NSNumber numberWithInt: IMPORTED_LOOP]];
    
    // Messages for LoopEditMenuView
    [self.eventsKey setObject:@"User changed the name of a loop."                       forKey:[NSNumber numberWithInt: LOOP_NAME_CHANGED]];
    [self.eventsKey setObject:@"User changed the loop symbol."                          forKey:[NSNumber numberWithInt: LOOP_SYMBOL_CHANGED]];
    [self.eventsKey setObject:@"User selected a new option for the loop symbol."        forKey:[NSNumber numberWithInt: LOOP_SYMBOL_CONTROL_CHANGED]];
    
    // Messages for LoopView
    [self.eventsKey setObject:@"User began moving a loop."                              forKey:[NSNumber numberWithInt: BEGIN_LOOP_MOVE]];
    [self.eventsKey setObject:@"User is moving a loop."                                 forKey:[NSNumber numberWithInt: LOOP_MOVE]];
    [self.eventsKey setObject:@"User stopped moving a loop."                            forKey:[NSNumber numberWithInt: END_LOOP_MOVE]];
    
    // Messages for MFSideMenuViewController.
    [self.eventsKey setObject:@"The model design window has been opened."               forKey:[NSNumber numberWithInt: MODEL_VIEW_OPEN]];
    [self.eventsKey setObject:@"The help section window has been opened."               forKey:[NSNumber numberWithInt: HELP_VIEW_OPEN]];
    [self.eventsKey setObject:@"Left side menu closed."                                 forKey:[NSNumber numberWithInt: MENU_CLOSED]];
    
    // Messages for Model
    [self.eventsKey setObject:@"A deleted variable caused deletion of causal links. "   forKey:[NSNumber numberWithInt: REMOVED_LINKS]];//***
    
    // Messages for ModelSectionView
    [self.eventsKey setObject:@"Variable added."                                        forKey:[NSNumber numberWithInt: ADD_VARIABLE]];
    [self.eventsKey setObject:@"Loop added."                                            forKey:[NSNumber numberWithInt: ADD_LOOP]];
    [self.eventsKey setObject:@"User begins scrolling."                                 forKey:[NSNumber numberWithInt: USER_BEGIN_SCROLLING]];
    [self.eventsKey setObject:@"Window is scrolling."                                   forKey:[NSNumber numberWithInt: USER_SCROLLING]];
    [self.eventsKey setObject:@"User stopped scrolling."                                forKey:[NSNumber numberWithInt: USER_STOPPED_SCROLLING]];
    [self.eventsKey setObject:@"Scrolling window stopped moving."                       forKey:[NSNumber numberWithInt: SCROLLING_STOPPED]];
    
    // Messages for ModelSectionViewController
    [self.eventsKey setObject:@"User warned that they are about to create a new model." forKey:[NSNumber numberWithInt: NEW_MODEL_WARNING]];
    [self.eventsKey setObject:@"User cancelled out of creating a new model."            forKey:[NSNumber numberWithInt: NEW_MODEL_WARNING_DISMISSED]];
    [self.eventsKey setObject:@"User created a new model."                              forKey:[NSNumber numberWithInt: NEW_MODEL]];
    [self.eventsKey setObject:@"Left side menu opened."                                 forKey:[NSNumber numberWithInt: MENU_OPENED]];
    [self.eventsKey setObject:@"User pressed the create image of model button."         forKey:[NSNumber numberWithInt: SAVE_IMAGE_OF_MODEL]];
    [self.eventsKey setObject:@"Image of model saved."                                  forKey:[NSNumber numberWithInt: IMAGE_SAVED]];
    [self.eventsKey setObject:@"Image of model not successfully saved."                 forKey:[NSNumber numberWithInt: IMAGE_NOT_SAVED]];
    [self.eventsKey setObject:@"User notified that the image was not saved."            forKey:[NSNumber numberWithInt: NOTIFY_IMAGE_NOT_SAVED]];
    [self.eventsKey setObject:@"User notified that the image was saved."                forKey:[NSNumber numberWithInt: NOTIFY_IMAGE_SAVED]];
    [self.eventsKey setObject:@"User confirmed that the image was saved."               forKey:[NSNumber numberWithInt: CONFIRM_IMAGE_SAVED]];
    [self.eventsKey setObject:@"User confirmed that the image was not saved."           forKey:[NSNumber numberWithInt: CONFIRM_IMAGE_NOT_SAVED]];
    [self.eventsKey setObject:@"User pressed the save model button."                    forKey:[NSNumber numberWithInt: SAVE_MODEL]];
    [self.eventsKey setObject:@"Redirecting to external application to save. "          forKey:[NSNumber numberWithInt: REDIRECTED_TO]];
    [self.eventsKey setObject:@"The save model options window has opened."              forKey:[NSNumber numberWithInt: SAVE_OPTIONS_OPENED]];
    [self.eventsKey setObject:@"The save model options window has been closed."         forKey:[NSNumber numberWithInt: SAVE_OPTIONS_CLOSED]];
    [self.eventsKey setObject:@"User has requested to open a file."                     forKey:[NSNumber numberWithInt: OPEN_FILE_REQUEST]];
    [self.eventsKey setObject:@"User tried to open a file without a .mdl extension."    forKey:[NSNumber numberWithInt: INVALID_FILE]];
    [self.eventsKey setObject:@"User confirmed that they opened an invalid file."       forKey:[NSNumber numberWithInt: CONFIRM_INVALID_FILE]];
    [self.eventsKey setObject:@"User selected a .mdl file to open."                     forKey:[NSNumber numberWithInt: FILE_SELECTED]];
    [self.eventsKey setObject:@"User cancelled request to open a file."                 forKey:[NSNumber numberWithInt: OPEN_REQUEST_CANCELLED]];
    [self.eventsKey setObject:@"Update menu displayed."                                 forKey:[NSNumber numberWithInt: UPDATE_MENU_OPENED]];
    [self.eventsKey setObject:@"Update menu closed."                                    forKey:[NSNumber numberWithInt: UPDATE_MENU_CLOSED]];
    [self.eventsKey setObject:@"Edit menu displayed."                                   forKey:[NSNumber numberWithInt: EDIT_MENU_CREATED]];
    [self.eventsKey setObject:@"Edit menu closed because user saved changes."           forKey:[NSNumber numberWithInt: EDIT_MENU_SAVED]];
    [self.eventsKey setObject:@"Edit menu closed because user cancelled."               forKey:[NSNumber numberWithInt: EDIT_MENU_CANCELLED]];
    [self.eventsKey setObject:@"User warned that they are about to delete something."   forKey:[NSNumber numberWithInt: DELETE_WARNING]];
    [self.eventsKey setObject:@"User cancelled out of deleting"                         forKey:[NSNumber numberWithInt: DELETE_WARNING_DISMISSED]];
    [self.eventsKey setObject:@"A variable was deleted."                                forKey:[NSNumber numberWithInt: VARIABLE_DELETED]];
    [self.eventsKey setObject:@"A loop was deleted."                                    forKey:[NSNumber numberWithInt: LOOP_DELETED]];
    [self.eventsKey setObject:@"A causal link was deleted."                             forKey:[NSNumber numberWithInt: CAUSAL_LINK_DELETED]];
    [self.eventsKey setObject:@"User selected a new option for adding new objects."     forKey:[NSNumber numberWithInt: ADD_OBJECT_CONTROL_CHANGED]];
    [self.eventsKey setObject:@"There is internet connection!"                          forKey:[NSNumber numberWithInt: INTERNET_CONNECTION]];
    [self.eventsKey setObject:@"There is NO internet connection!"                       forKey:[NSNumber numberWithInt: NO_INTERNET_CONNECTION]];
    
    // Messages for Variable
    [self.eventsKey setObject:@"Imported a variable from a file."                       forKey:[NSNumber numberWithInt: IMPORTED_VARIABLE]];
    
    // Messages for VariableEditMenuView
    [self.eventsKey setObject:@"User changed the name of a variable."                   forKey:[NSNumber numberWithInt: VAR_NAME_CHANGED]];
    [self.eventsKey setObject:@"User changed the variable type."                        forKey:[NSNumber numberWithInt: VAR_TYPE_CHANGED]];
    [self.eventsKey setObject:@"User selected a new option for the variable type."      forKey:[NSNumber numberWithInt: VAR_TYPE_CONTROL_CHANGED]];
    
    // Messages for VariableView
    [self.eventsKey setObject:@"User has begun creating a new causal link."             forKey:[NSNumber numberWithInt: BEGIN_ADD_CAUSAL_LINK]];
    [self.eventsKey setObject:@"The causal link is in the process of being added."      forKey:[NSNumber numberWithInt: CAUSAL_LINK_ADD_IN_PROGRESS]];
    [self.eventsKey setObject:@"Causal link added."                                     forKey:[NSNumber numberWithInt: CAUSAL_LINK_ADDED]];
    [self.eventsKey setObject:@"User cancelled adding a new causal link."               forKey:[NSNumber numberWithInt: CASUAL_LINK_CANCELLED]];
    [self.eventsKey setObject:@"User began moving a variable."                          forKey:[NSNumber numberWithInt: BEGIN_VAR_MOVE]];
    [self.eventsKey setObject:@"User is moving a variable."                             forKey:[NSNumber numberWithInt: VAR_MOVE]];
    [self.eventsKey setObject:@"User stopped moving a variable."                        forKey:[NSNumber numberWithInt: END_VAR_MOVE]];
}
@end
