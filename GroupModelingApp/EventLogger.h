//
//  EventLogger.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 8/7/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "Event.h"
#import <Foundation/Foundation.h>

/// A class used to keep a record of all of the events the user makes during a modeling session.
@interface EventLogger : NSObject

/// An array containing all of the events that occur in the app.
@property NSMutableArray* events;

/// An array containing the mapping of event ids to their description.
@property NSMutableDictionary* eventsKey;

+(EventLogger*)sharedEventLogger;
-(void)addEvent:(Event*)newEvent;
-(NSMutableArray*)createEventsOutput;
-(void)clearEventsList:(int)num;
-(void)populateEventKey;
@end
