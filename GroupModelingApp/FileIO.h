//
//  FileIO.h
//  TextParseTest
//
//  Created by Matthew Burch on 6/20/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import <Foundation/Foundation.h>

/// A class that handles the parsing of mdl files to import into the application.  Also is responsible for exporting the model back into a Vensim file for saving state and for use in Vensim again.
@interface FileIO : NSObject

+ (FileIO*)sharedFileIO;
-(void) importModel:(NSArray*)lines;
-(NSString*) openFile;
-(NSURL*) exportModel;
-(void) exportEventLogging;
-(NSNumber*) getFileID;
-(NSNumber*) getNextAvailableFileID;
-(void) processComponent:(NSString*) string loopName:(NSString*) loopName;
-(void) updateCausalLinkConnections;
+(NSData*)sha1:(NSData *)data;
+ (NSString*)base64forData:(NSData*)theData;

@end
