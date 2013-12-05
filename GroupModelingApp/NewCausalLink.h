//
//  NewCausalLink.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/30/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Creates the temporary line that represents where the link is going to connect to variables.  This is used only when the user is dragging a new link from one variable to a new one.  
@interface NewCausalLink : UIView

/// The starting point of the line.
@property CGPoint startPoint;

/// The ending point of the line.
@property CGPoint endPoint;

-(id)initWithFrame:(CGRect)frame;
-(void)drawRect:(CGRect)rect;
@end
