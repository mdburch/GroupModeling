//
//  Event.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 8/12/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import <Foundation/Foundation.h>

/// A class used to construct events that occur in the simulation.
@interface Event : NSObject

/// The time the event occurred.
@property NSNumber* time;

/// The id number of the generic event.
@property int descriptionID;

/// The id number of the object that was affected by the change.
@property int objectID;

/// Any details regarding the change.
@property NSString* details;

-(id) initWithDescID:(int)descID;
-(id) initWithDescID:(int)descID andObjectID:(int) objID;
-(id) initWithDescID:(int)descID andDetails:(NSString*) details;
-(id) initWithDescID:(int)descID andObjectID:(int) objID andDetails:(NSString*) details;
@end
