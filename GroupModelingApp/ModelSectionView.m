//
//  ModelSectionView.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/18/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "EventLogger.h"
#import "FileIO.h"
#import "MFSideMenuContainerViewController.h"
#import "Model.h"
#import "ModelSectionView.h"
#import "ModelSectionViewController.h"

@implementation ModelSectionView

/// Initializes the view.
/// @param frame the frame the view is contained within.
/// @return an id of the newly created view.
-(id)init
{
    self = [super init];
    if (self)
    {
        // Setting up the scroll view
        self.delegate = self;
        [self setScrollEnabled:YES];

        self.maximumZoomScale               = MAX_ZOOM;
        self.minimumZoomScale               = MIN_ZOOM;
        self.showsHorizontalScrollIndicator = YES;
        self.delaysContentTouches           = YES;
        self.canCancelContentTouches        = YES;
        self.clipsToBounds                  = YES;
        [self setContentSize:CGSizeMake(SCROLL_WIDTH, SCROLL_HEIGHT)];
        
//        self.canvas = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCROLL_WIDTH, SCROLL_HEIGHT)];
//        [self addSubview:self.canvas];
        
        UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
    }
    
    return self;
}

// Code to handle zooming.
//-(void)addSubview:(UIView *)view
//{
//    NSLog(@"Made it in addSubview");
//    if(![view isEqual:self.canvas])
//        [self.canvas addSubview:view];
//    else
//        [super addSubview:view];
//}
//
//- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index
//{
//    [self.canvas insertSubview:view atIndex:index];
//}

//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
//{
//    // Used to ensure we can scroll after the zooming has occurred.
//    
//    self.contentSize = CGSizeMake(SCROLL_WIDTH*scale, SCROLL_HEIGHT*scale);
//}
//
///// Gets the view that the zooming will occur within.
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return self.canvas;
//}

/// Draws the receiver’s image within the passed-in rectangle.  This is an overridden method.
/// @param rect the frame of the view in which objects can be drawn.
-(void)drawRect:(CGRect)rect
{
    // Drawing code
    [[UIColor whiteColor]set];
    UIRectFill(self.bounds);
}

/// Will add a new object on a double tap.
/// @param sender the recognizer that fired the method call.
-(void)handleDoubleTap:(UITapGestureRecognizer *)sender
{
    CGPoint touchLoc = [sender locationInView:self];
    
    ModelSectionViewController* vc = (ModelSectionViewController*) [[Model sharedModel] getViewController];
    switch(vc.controls.selectedSegmentIndex)
    {
        case VARIABLE_INDEX:
        {
            Variable* newVar = [[Variable alloc]initWithLocation:touchLoc];
            [[Model sharedModel] addComponent:newVar];
            [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: ADD_VARIABLE andObjectID:newVar.idNum]];
            break;
        }
        case LOOP_INDEX:
        {
            Loop* newLoop = [[Loop alloc]initWithLocation:touchLoc];
            [[Model sharedModel] addComponent:newLoop];
            [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: ADD_LOOP andObjectID:newLoop.idNum]];
            break;
        }
        case LINK_INDEX: // This will be handled by the VariableView class since we only want to add links to variables, and not anywhere on the screen.
        default:
            break;
    }
}

/// Used to determine if the event is for the scroll view or any associated subview
/// @param point the point at which the user has touched.
/// @param event the event that triggered this method call.
/// @return the view object that is the farthest descendent the current view and contains point. Returns nil if the point lies completely outside the receiver’s view hierarchy.
-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* result = [super hitTest:point withEvent:event];
    
    // If the result is the scrollview class than we want to scroll.
    if ([result isKindOfClass:[UIScrollView class]])
    {
        self.scrollEnabled = YES;
    }
    else // the event occured on another subview that can handle the event.
    {
        self.scrollEnabled = NO;
    }
    return result;
}

/// Notifies the logger that the user has begun scrolling.
/// @param scrollView the scrollview for which the event has occured.
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: USER_BEGIN_SCROLLING
                                                                andDetails:[[Model sharedModel] constructLocationDetails:scrollView.contentOffset]]];
}

/// Notifies the logger that the user is scrolling.
/// @param scrollView the scrollview for which the event has occured.
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: USER_SCROLLING
                                                                andDetails:[[Model sharedModel] constructLocationDetails:scrollView.contentOffset]]];
}

/// Notifies the logger that the user has stopped dragging the scrollview.
/// @param scrollView the scrollview for which the event has occured.
/// @param decelerate TRUE if the scrolling will continue because the user has swiped their finger.  FALSE if the user simply released their finger.
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: USER_STOPPED_SCROLLING
                                                                andDetails:[[Model sharedModel] constructLocationDetails:scrollView.contentOffset]]];
}

/// Notifies the logger that the scroll window has stopped scrolling.  The user may have simply released their finger or swiped their finger.
/// @param scrollView the scrollview for which the event has occured.
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: SCROLLING_STOPPED
                                                                andDetails:[[Model sharedModel] constructLocationDetails:scrollView.contentOffset]]];
}
@end
