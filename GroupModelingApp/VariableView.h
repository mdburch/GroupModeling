//
//  VariableView.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/2/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "NewCausalLink.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

/// The view that will contain the graphical representation of a Variable.
@interface VariableView : UIView

/// The color of the variable box.  Used when creating new causal links.
@property UIColor* boxColor;

/// Whether the variable is boxed.
@property bool isBoxed;

/// The name of the variable.
@property NSString* name;

/// Pointer to the parent of this view.
@property id parent;

/// An instance of NewCausalLink which is used when creating a new causal link.
@property NewCausalLink* tempLink;

-(id)initWithFrame:(CGRect)frame andParent:(id)parent;
-(void)drawRect:(CGRect)rect;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)handleSingleTap:(UITapGestureRecognizer *)sender;
-(void)longPressDetected: (UILongPressGestureRecognizer*)sender;
-(void)setBoxColorBasedOnPoint:(CGPoint)point;

@end
