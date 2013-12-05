//
//  Event.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 8/12/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "Constants.h"
#import "Event.h"

@implementation Event
@synthesize time          = _time;
@synthesize descriptionID = _descriptionID;
@synthesize objectID      = _objectID;
@synthesize details       = _details;

/// Initializes the Event given the description id.  Will fill in the other aspects of the class with defaults.
/// Calls initWithDescID: andObjectID: andDetails:.
/// @param descID the identification number of the generic description message.
/// @return a pointer to the event object.
-(id) initWithDescID:(int)descID
{
    return [self initWithDescID:descID andObjectID:APPLICATION_ID andDetails:@""];
}

/// Initializes the Event given the description id and object id.  Will fill in the other aspects of the class with defaults.
/// Calls initWithDescID: andObjectID: andDetails:.
/// @param descID the identification number of the generic description message.
/// @param objId the identification number of the object changed.
/// @return a pointer to the event object.
-(id) initWithDescID:(int)descID andObjectID:(int) objID
{
    return [self initWithDescID:descID andObjectID:objID andDetails:@""];
}

/// Initializes the Event given the description id and details.  Will fill in the other aspects of the class with defaults.
/// Calls initWithDescID: andObjectID: andDetails:.
/// @param descID the identification number of the generic description message.
/// @param details details about the event not captured in the generic message.
/// @return a pointer to the event object.
-(id) initWithDescID:(int)descID andDetails:(NSString*) details
{
    return [self initWithDescID:descID andObjectID:APPLICATION_ID andDetails:details];
}

/// Initializes the Event given the description id, object id, and details.
/// @param descID the identification number of the generic description message.
/// @param objId the identification number of the object changed.
/// @param details details about the event not captured in the generic message.
/// @return a pointer to the event object.
-(id) initWithDescID:(int)descID andObjectID:(int) objID andDetails:(NSString*) details
{
    self = [super init];
 
    if(self)
    {
        NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
        self.time           = [NSNumber numberWithDouble:time];
        self.descriptionID  = descID;
        self.objectID       = objID;
        self.details        = details;
    }
    return self;
}
@end
