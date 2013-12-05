//
//  LoopView.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/13/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import <UIKit/UIKit.h>

/// A view that contains the graphical representation of a Loop.
@interface LoopView : UIView

/// The name of the loop.
@property NSString* name;

/// Determines if the symbol is a clockwise loop
@property bool isClockwise;

/// Pointer to the parent of this view.
@property id parent;

-(id)initWithFrame:(CGRect)frame andParent:(id)parent;
-(void)drawRect:(CGRect)rect;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)handleSingleTap:(UITapGestureRecognizer *)sender;
@end
