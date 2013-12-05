//
//  LinkView.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/17/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import <UIKit/UIKit.h>

/// A view that containg the graphical representation of a CausalLink.
@interface CausalLinkView : UIView

/// The color of the arc.
@property UIColor* arcColor;

/// If the arc is bolded or not.
@property bool isBold;

/// If the arc has a time delay.
@property bool hasTimeDelay;

/// The point at which the shape of the arc is controlled.
@property CGPoint controlPoint;

/// The starting point of the arc.
@property CGPoint startPoint;

/// The ending point of the arc.
@property CGPoint endPoint;

/// The vertex point of the arc.
@property CGPoint vertexPoint;

/// Pointer to the parent of this view.
@property id parent;

/// The type of causal link.  + means that as one variable increases, so does the other. (ex. as a child eats more fast food, that child will gain more weight)  - means that as one variable increases, the other variable decreases. (ex. as a child eats healthier, the less weight gain will occur)
@property NSString* polarity;

/// The slope in the x direction of the vertex point.
@property float xSlopeChange;

/// The slope in the y direction of the vertex point.
@property float ySlopeChange;

// Methods that initialize the CausalLinkView.
-(id)initWithParent:(id)parent;

-(void) initMemberVars;

// Methods that handle drawing.
-(void)drawRect:(CGRect)rect;
-(void) drawArc;
-(void) drawArrowhead;
-(void) drawTimeDelay;
-(void) drawHandle;
-(void) drawPolarity;

// Methods that handle constructing the arrowhead.
+(float) distanceBetweenPoints:(CGPoint) point1
                   secondPoint:(CGPoint) point2;
-(float) findPointOnQuadBezierCurve:(float) t
                                 p0:(float) p0
                                 p1:(float) p1
                                 p2:(float) p2;
-(CGPoint) findBasePoint:(CGPoint) head
            startingTval:(float) t
                lineSize:(float) size;
-(CGPoint) rotateLine:(CGPoint) head
                 base:(CGPoint) base
              degrees:(float) degrees;

// Methods that handle the moving of the arc.
-(void) calculateFrame;
-(void) moveArc:(CGPoint)location previousLocation:(CGPoint)prevLocation;
-(void) moveVariable:(CGPoint) newCenter modifyStartPoint:(bool) isStartPoint;
-(void) calculateNewControlPoint;
-(void) calculateInitialArc;
-(CGPoint) findPointInBounds:(CGPoint)refPoint;
-(void) resizeFrame:(CGPoint) oldOrigin
          newOrigin:(CGPoint) newOrigin
              width:(float) sizeWidth
             height:(float) sizeHeight;
-(void) updatePointsInFrame:(float) xOffset yOffset:(float) yOffset;
-(void) updateSlope;
-(void) updateVertex;

// Methods to handle editing and deleting the arc.
-(void) updateLink;
-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end
