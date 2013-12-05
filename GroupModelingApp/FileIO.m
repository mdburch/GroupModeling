//
//  FileIO.m
//  TextParseTest
//
//  Created by Matthew Burch on 6/20/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "CausalLink.h"
#import "Component.h"
#import "Constants.h"
#import <CommonCrypto/CommonDigest.h>
#import "DefaultParameters.h"
#import "EventLogger.h"
#import "Loop.h"
#import "FileIO.h"
#import "Model.h"
#import "Reachability.h"
#import "Variable.h"

NSString* MODEL_EXPORT_FILE = @"model.mdl";


@implementation FileIO

/// Forces the Model to be a singleton class.
/// @return a pointer to the single instance of the model.
+ (FileIO*)sharedFileIO {
    static FileIO *sharedFileIO = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFileIO = [[self alloc] init];
        // iOS 6.0 or later
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
        {
            MODEL_EXPORT_FILE = @"model.mdl";         // File name to save the model output.
        }
        else
        {
            // iOS 5.X or earlier
            MODEL_EXPORT_FILE = @"model.txt";         // File name to save the model output.
        }
    });
    return sharedFileIO;
}

/// Opens a Vensim mdl file and parses through it to populate the model.
/// Will update the Model object with its simulation control parameters, default model parameters, and all components including any Variable, CausalLink, and Loop.
-(void) importModel:(NSArray*)lines
{
    //NSString* content = [self openFile];
    
    // Split up the textfile by line
    //NSArray* lines = [content componentsSeparatedByString:@"\n"];
    
    bool readComponents = false; // Flag determining when to read components from the file
    bool readControls   = false; // Flag determining when to read simulation control parameters from the file
    
    for(NSString* string in lines)
    {
        // Determine when to read controls and when to  read components
        if(string.length > COMPONENT_PREFIX.length && [string hasPrefix:(NSString*)COMPONENT_PREFIX])
        {
            readControls   = false;
            readComponents = true;
        }
        
        // Read in default parameters
        if(string.length >= DEFAULT_PARAMS_PREFIX.length && [string hasPrefix:(NSString*)DEFAULT_PARAMS_PREFIX])
        {
            [[[Model sharedModel] defaultParams] setParams:string];
        }
        
        // Read in the simulation control parameters
        if([string hasPrefix:(NSString*)SIM_CONTROL_PARAMS_PREFIX] || readControls)
        {
            readControls = true;
            [[[Model sharedModel] controlParams] addParameter:string];
        }
        
        // Read in the components
        if(readComponents && ![string hasPrefix:(NSString*)END_OF_COMPONENTS])
        {
            // Get the largest component id, if it is there.  The id will only exist if the the file being loaded had been saved previously from the app.
            // Otherwise if the file was originally created from Vensim, the last object will have the highest id and the largestIDNum will be set automatically.
            // This string will actually exist after all components.
            if([string hasPrefix:(NSString*)LARGEST_COMPONENT_ID])
            {
                int idNum = [[[string componentsSeparatedByString:@"-"]objectAtIndex:1] integerValue];
                [Component setLargestIDNum:idNum];
            }
            else // Read the component.
            {
                /// @todo The name of the loop being on the next line kind of a pain
                NSString* loopName = ([lines indexOfObject:string]+1 > lines.count-1) ? @"" : lines[[lines indexOfObject:string]+1];
                [self processComponent:string loopName:loopName];
            }
        }
        else // stop reading components data when there are no more. Vensim sometimes outputs more information at the end of the file.
        {
            readComponents = false;
        }
    }

    // Now that the file is completely read in, we can point the causal links to their parent and child objects.
    [self updateCausalLinkConnections];
}

/// Will open the selected Vensim file to import and use.
/// @note this is only used when wanting to test in the simulator.
/// @return a string contraining the entire file
-(NSString*) openFile
{
    // Path to the file
    NSString* path = [[NSBundle mainBundle] pathForResource: @"smallModelTest" ofType: @"mdl"];
    
    // Check if the file can be found
    if(!path)
    {
        NSLog(@"Unable to find file in bundle");
    }
    
    // Take the contents of a file and return it as string
    return [NSString stringWithContentsOfFile:path
            encoding:NSUTF8StringEncoding
            error: NULL];

}

/// Will export the model and write it to a file output.mdl.
/// @return the url location of the file.
-(NSURL*) exportModel
{
    NSMutableArray* file = [[NSMutableArray alloc]init];
    
    // Add the encoding schem
    [file addObject:ENCODING]; // The encoding scheme
    
    // Add the variable maps.
    [file addObjectsFromArray:[[Model sharedModel] createVariableMap]];

    // Add the control params.
    if([Model sharedModel].controlParams.params.count > 0)
    {
        [file addObjectsFromArray:[Model sharedModel].controlParams.params];
    }
    else
    {
         // If no control params have been created (ie model created on the app itself) add default control params.
        [file addObject:CONTROL_PARAMS];
    }
    
    // Add standard lines.
    [file addObject:SKETCH_INFO];
    [file addObject:V300];
    [file addObject:VIEW];
    
    // Add the default params.
    NSString* defaultParams = [Model sharedModel].defaultParams.params;
    if([defaultParams isEqualToString:@""])
    {
        // If no params have been created (ie model created on the app itself) add default params.
        [file addObject:DEFAULT_PARAMS];
    }
    else
    {
        [file addObject:defaultParams];
    }
    
    // Add all of the components in the model.
    [file addObjectsFromArray:[[Model sharedModel] createComponentsExport]];
    
    /// Add the current max ID, used for tracking events. Stored as -##.
    [file addObject:[NSString stringWithFormat:@"-%d", [Component getLargestIDNum]]];

    // Get the file location to save the file.
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docsDir = [dirPaths objectAtIndex:0];
    docsDir =  [docsDir stringByAppendingPathComponent:MODEL_EXPORT_FILE];
    
    // Split up the file by the end of line character and write it to the file.
    NSError* error;
    [[file componentsJoinedByString:@"\n"] writeToFile:docsDir atomically:NO encoding:NSUTF8StringEncoding error:&error];
    
    // Set the ending hash.
    NSData* hash = [FileIO sha1:[[NSFileManager defaultManager]contentsAtPath:docsDir]];
    [[Model sharedModel] setEndingHash:hash];

    // Return the url to the file so that Dropbox can use it.
    return [[NSURL alloc]initFileURLWithPath:docsDir];
}

/// Will export the model event logging data and write it to a file eventLogging.txt.
-(void) exportEventLogging
{
    // Get the number of events in the log. Will be used later to only remove the events that existed at this point.
    int numEvents = [EventLogger sharedEventLogger].events.count;
    
    // Get the event log file and save it.
    NSMutableArray* events = [[EventLogger sharedEventLogger] createEventsOutput];
    NSData *data = [[events componentsJoinedByString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
    PFFile *log = [PFFile fileWithName:EVENTS_EXPORT_FILE data:data];
    
    // Get the mdl file to save as well.
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docsDir = [dirPaths objectAtIndex:0];
    docsDir =  [docsDir stringByAppendingPathComponent:MODEL_EXPORT_FILE];
    
    data =[NSData dataWithContentsOfURL:[[NSURL alloc]initFileURLWithPath:docsDir]];
    PFFile* model = [PFFile fileWithName:MODEL_EXPORT_FILE data:data];
    
    // Get the current user.
    [PFUser enableAutomaticUser];
    [[PFUser currentUser] save];
    
    // Make sure the user has a name prior to uploading the data.
    if([PFUser currentUser].username != NULL)
    {
        PFObject *eventLog = [PFObject objectWithClassName:CLASS_NAME];
        [eventLog setObject:[PFUser currentUser].username    forKey:USER_ID];
        [eventLog setObject:[Model sharedModel].startingHash forKey:STARTING_HASH];
        [eventLog setObject:[Model sharedModel].endingHash   forKey:ENDING_HASH];
        [eventLog setObject:log                              forKey:EVENT_LOG];
        [eventLog setObject:model                            forKey:MODEL_FILE];
        
        NSNumber* fileID = [self getFileID];
        if(fileID.integerValue > 0)
        {
            [eventLog setObject:fileID                           forKey:GID];
            // Save the record to the database.
            bool succeeded = [eventLog save];
            if(succeeded)
            {
                // Clear the events list to start a new list.
                [[EventLogger sharedEventLogger]clearEventsList:numEvents];
                        
                // Set the starting hash to the end hash. Now the user can continue working.
                // The end hash will be recomputed and set again prior to the next record being saved.
                [Model sharedModel].startingHash = [[Model sharedModel] endingHash];
            }
            else
            {
                [[EventLogger sharedEventLogger]addEvent: [[Event alloc] initWithDescID:UPLOAD_TO_PARSE_FAILED
                                                                            andDetails:[[NSString alloc]initWithFormat:NO_PARSE_CONNECTION, [FileIO base64forData:[Model sharedModel].endingHash]]]];
            }
        }
        else
        {
            [[EventLogger sharedEventLogger]addEvent: [[Event alloc] initWithDescID:UPLOAD_TO_PARSE_FAILED
                                                                         andDetails:NO_FILE_ID]];
        }
    }
    else
    {
        [PFUser logOut]; //Log out user because the anonymous user could not be created.
        [[EventLogger sharedEventLogger]addEvent: [[Event alloc] initWithDescID:UPLOAD_TO_PARSE_FAILED
                                                                     andDetails:NO_USER_ID]];
    }
}

/// Get the parent file global idenitifer (gid) so we can keep track of when a specific user modifies the same file or any derivative of the original file.
/// The gid will be unique per user + parent file combination.
/// @return a gid value for this eventlog record.
-(NSNumber*) getFileID
{
    NSNumber* fileID = [NSNumber numberWithInt:-1];
    
    // Perform a query on the database to get the id of the parent file so we can keep track of how a model progresses.
    // Will create a new value if an id does not exist or it is a new model.
    NSString* hashVal = [FileIO base64forData:[Model sharedModel].startingHash];
    PFQuery *query = [PFQuery queryWithClassName:CLASS_NAME];
    [query whereKey:ENDING_HASH equalTo: hashVal];
    [query whereKey:USER_ID     equalTo:[PFUser currentUser].username];
    
    NSError * __autoreleasing *error = NULL;
    PFObject* object = [query getFirstObject:error];
    // If there is an error, Parse failed for some reason and the fileID can remain invalid.
    if(!error)
    {
        if (!object) {
            // Object could be nil becuase there is internet which means we want to abort the save so we need to check for internet
            Reachability *r = [Reachability reachabilityForInternetConnection];
            NetworkStatus netStat = [r currentReachabilityStatus];
            if (netStat != NotReachable)
            {
                // There is no parent file, therefore we need to create a new gid.
                fileID = [self getNextAvailableFileID];
            }
        }
        else
        {
            // The find succeeded, need to find the parent file's gid.
            fileID = [object objectForKey:GID];
        }
    }
    
    return fileID;
}

/// If a new file has been created, or a user has not edited an existing file before, we will need to create a new gid for this user/file combination.
/// @return the next available file gid in the database.
-(NSNumber*)getNextAvailableFileID
{
    NSNumber* fileID = [NSNumber numberWithInt:-1];
    PFQuery *query = [PFQuery queryWithClassName:CLASS_NAME];
    query.limit = 1;                // only need the highest value
    [query orderByDescending:GID];
    
    NSError * __autoreleasing *error = NULL;
    PFObject* object = [query getFirstObject:error];
    if(!error)
    {
        // Object could be nil becuase there is internet which means we want to abort the save so we need to check for internet
        Reachability *r = [Reachability reachabilityForInternetConnection];
        NetworkStatus netStat = [r currentReachabilityStatus];
        if (netStat != NotReachable)
        {
            NSNumber* gid = [object objectForKey:GID];
            int intVal = [gid intValue];
            intVal++;

            fileID = [NSNumber numberWithInt:intVal];
        }
    }

    return fileID;
}

/// Will create a new component of type CausalLink, Variable, or Loop and add it to the model.
/// @param string the input string from the Vensim mdl file that provides specification for the component.
/// @param loopName the provided name for a loop.  This will be ignored for causal links and variables.
-(void) processComponent: (NSString*) string loopName:(NSString*) loopName
{
    // Take each line and parse the data. Unfortunately realatiships do not have a comma between all values
    // and we need to the position which is the last parameter
    NSArray* subString = [string componentsSeparatedByString:@","];
    int value = [[subString objectAtIndex:0] integerValue];
    
    // This switch statement in the future would create an instance of each object class and fill in its information
    switch(value)
    {
        case CAUSAL_LINK:
            [[Model sharedModel] addComponent:[[CausalLink alloc] init:subString]];
            break;
            
        case VARIABLE:
        {
            [[Model sharedModel] addComponent:[[Variable alloc]init:subString]];
            break;
        }
            
        case LOOP:
        {
            [[Model sharedModel] addComponent:[[Loop alloc] init:subString varName:loopName]];
            break;
        }
            
        default:
            //Do nothing because we are only looking for the three types of components subclasses.
            break;
    }
}

/// Once the file has been read in completely we can finish processing the data.  The causal link parent and child objects upon import point to a string id of the parent and child, instead we would like the parent and child to point to the instance of those Variables.  Likewise, each variable would like to keep track of which CausalLinks are indegree and outdegree.
-(void) updateCausalLinkConnections
{
    // Iterate over all ofthe components in the model.
    for(id obj in [[Model sharedModel] components])
    {
        // Only look at objects that are CausalLinks
        if([obj isMemberOfClass:[CausalLink class]])
        {
            // Ensuring the parent and child objects were previously of type NSNumber because they are holding the id.
            if([[obj parentObject] isKindOfClass:[NSNumber class]])
            {
                // Get the parent variable object.  Assign the CausalLink's parent to that object, and update the Varable's list of outdegree links with this CausalLink.
                Variable* var = [[Model sharedModel] getVariable:[obj parentObject]];
                [obj setParentObject:var];
                [var addOutdegreeLink:obj];
            }
            
            if([[obj childObject] isKindOfClass:[NSNumber class]])
            {
                // Get the child variable object.  Assign the CausalLink's child to that object, and update the Varable's list of indegree links with this CausalLink.
                Variable* var = [[Model sharedModel] getVariable:[obj childObject]];
                [obj setChildObject:var];
                [var addIndegreeLink:obj];
            }
            
            // Now that the parent and child objects have been updated, we have access to the parent and child locations, so we can create the view that displays the CausalLink.
            [obj createView];
        }
    }
}

/// Will compute a sha1 hash function on some data.
/// @param data the data to be hashed.
/// @param a sha1 hash of data.
+(NSData*)sha1:(NSData *)data
{
    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    if ( CC_SHA1([data bytes], [data length], hash) ) {
        NSData *sha1 = [NSData dataWithBytes:hash length:CC_SHA1_DIGEST_LENGTH];
        return sha1;
    }
    return nil;
}

/// Converts the hashed dat to a base64 string for comparison with what is stored in the database.
/// @param theData the hash value to be converted.
/// @return the converted nsdata to base64 string
+ (NSString*)base64forData:(NSData*)theData
{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}


@end
