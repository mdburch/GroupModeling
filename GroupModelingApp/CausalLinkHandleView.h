//
//  CausalLinkHandleView.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/23/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "CausalLinkView.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

/// A view that display the vertex of the CausalLink.  This view is also used to move and modify the CausalLink.
@interface CausalLinkHandleView : UIView

/// A pointer to the parent CausalLinkView that the handle is attached to.
@property CausalLinkView* parent;

-(id)initWithFrame:(CGRect)frame;
-(void)drawRect:(CGRect)rect;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)handleSingleTap:(UITapGestureRecognizer *)sender;

@end
