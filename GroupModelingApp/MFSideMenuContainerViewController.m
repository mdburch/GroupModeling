// MFSideMenuContainerViewController.m
// GroupModelingApp
//
//* Copyright (c) 2012, Michael Frederick
//* All rights reserved.
//*
//* Redistribution and use in source and binary forms, with or without
//* modification, are permitted provided that the following conditions are met:
//* Redistributions of source code must retain the above copyright
//* notice, this list of conditions and the following disclaimer.
//* Redistributions in binary form must reproduce the above copyright
//* notice, this list of conditions and the following disclaimer in the
//* documentation and/or other materials provided with the distribution.
//* * Neither the name of Michael Frederick nor the
//* names of its contributors may be used to endorse or promote products
//* derived from this software without specific prior written permission.
//*
//* THIS SOFTWARE IS PROVIDED BY Michael Frederick ''AS IS'' AND ANY
//* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//* DISCLAIMED. IN NO EVENT SHALL Michael Frederick BE LIABLE FOR ANY
//* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "Constants.h"
#import "EventLogger.h"
#import "HelpSectionViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "ModelSectionViewController.h"
#import <QuartzCore/QuartzCore.h>

NSString * const MFSideMenuStateNotificationEvent = @"MFSideMenuStateNotificationEvent";

typedef enum {
    MFSideMenuPanDirectionNone,
    MFSideMenuPanDirectionLeft,
    MFSideMenuPanDirectionRight
} MFSideMenuPanDirection;

@interface MFSideMenuContainerViewController ()
@property (nonatomic, strong) UIView *menuContainerView;

@property (nonatomic, assign) CGPoint panGestureOrigin;
@property (nonatomic, assign) CGFloat panGestureVelocity;
@property (nonatomic, assign) MFSideMenuPanDirection panDirection;
@end

@implementation MFSideMenuContainerViewController

@synthesize leftMenuViewController = _leftSideMenuViewController;
@synthesize centerViewController = _centerViewController;
@synthesize menuContainerView;
@synthesize panMode;
@synthesize panGestureOrigin;
@synthesize panGestureVelocity;
@synthesize menuState = _menuState;
@synthesize panDirection;
@synthesize shadowEnabled = _shadowEnabled;
@synthesize leftMenuWidth = _leftMenuWidth;
@synthesize shadowRadius = _shadowRadius;
@synthesize shadowColor = _shadowColor;
@synthesize shadowOpacity = _shadowOpacity;
@synthesize menuSlideAnimationEnabled;
@synthesize menuSlideAnimationFactor;
@synthesize menuAnimationDefaultDuration;
@synthesize menuAnimationMaxDuration;


#pragma mark -
#pragma mark - Initialization
/// Creates a container with a left side menu and a center working view controller.
/// @param centerViewController the view controller for the center.
/// @param leftMenuViewController the view controller for the side menu.
/// @return an instance of MFSideMenuContainerViewController.
+ (MFSideMenuContainerViewController *)containerWithCenterViewController:(id)centerViewController
                                                  leftMenuViewController:(id)leftMenuViewController{
    MFSideMenuContainerViewController *controller = [MFSideMenuContainerViewController new];
    controller.leftMenuViewController = leftMenuViewController;
    controller.centerViewController   = centerViewController;
    
    return controller;
}

- (id) init {
    self = [super init];
    if(self) {
        [self setDefaultSettings];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)inCoder {
    id coder = [super initWithCoder:inCoder];
    [self setDefaultSettings];
    return coder;
}

/// Sets up default settings for the nav controller and menu.
- (void)setDefaultSettings {
    if(self.menuContainerView) return;
    
    self.menuContainerView = [[UIView alloc] init];
    self.menuState = MFSideMenuStateClosed;
    self.menuWidth = 270.0f;
    self.shadowRadius = 10.0f;
    self.shadowOpacity = 0.75f;
    self.shadowColor = [UIColor blackColor];
    self.menuSlideAnimationFactor = 3.0f;
    self.shadowEnabled = YES;
    self.menuAnimationDefaultDuration = 0.2f;
    self.menuAnimationMaxDuration = 0.4f;
    self.panMode = MFSideMenuPanModeDefault;
}

- (void)setupMenuContainerView {
    if(self.menuContainerView.superview) return;
    
    self.menuContainerView.frame = self.view.bounds;
    self.menuContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [self.view insertSubview:menuContainerView atIndex:0];
    
    if(self.leftMenuViewController && !self.leftMenuViewController.view.superview) {
        [self.menuContainerView addSubview:self.leftMenuViewController.view];
    }
}

/// Pushes the help section view controller onto the stack making it visible.
-(void) openHelpSection
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: HELP_VIEW_OPEN]];
    [self.centerViewController pushViewController:[[HelpSectionViewController alloc]initWithStyle:UITableViewStyleGrouped] animated:YES];
}

/// Pops back to the root view controller which will be the model.
-(void) returnToRoot
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: MODEL_VIEW_OPEN]];
    [self.centerViewController popToRootViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark - View Lifecycle
/// Sets up the view controller, including setting up the menu, and adding gesture recognizers.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupMenuContainerView];
    [self setLeftSideMenuFrameToClosedPosition];
    
    [self drawMenuShadows];
    [self addGestureRecognizers];
}


#pragma mark -
#pragma mark - UIViewController Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if(self.centerViewController) return [self.centerViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.centerViewController view].layer.shadowPath = nil;
    [self.centerViewController view].layer.shouldRasterize = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self drawCenterControllerShadowPath];
    [self.centerViewController view].layer.shouldRasterize = NO;
}


#pragma mark -
#pragma mark - UIViewController Containment

- (void)setLeftMenuViewController:(UIViewController *)leftSideMenuViewController {
    [self removeChildViewControllerFromContainer:_leftSideMenuViewController];
    
    _leftSideMenuViewController = leftSideMenuViewController;
    if(!_leftSideMenuViewController) return;
    
    [self addChildViewController:_leftSideMenuViewController];
    if(self.menuContainerView.superview) {
        [self.menuContainerView insertSubview:[_leftSideMenuViewController view] atIndex:0];
    }
    [_leftSideMenuViewController didMoveToParentViewController:self];
    
    [self setLeftSideMenuFrameToClosedPosition];
}

- (void)setCenterViewController:(UINavigationController *)centerViewController {
    [self removeChildViewControllerFromContainer:_centerViewController];
    
    CGPoint origin = ((UIViewController *)_centerViewController).view.frame.origin;
    _centerViewController = centerViewController;
    if(!_centerViewController) return;
    
    [self addChildViewController:_centerViewController];
    [self.view addSubview:[_centerViewController view]];
    [((UIViewController *)_centerViewController) view].frame = (CGRect){.origin = origin, .size=centerViewController.view.frame.size};
    
    [_centerViewController didMoveToParentViewController:self];
    
    [self drawMenuShadows];
    [self addGestureRecognizers];
}

- (void)removeChildViewControllerFromContainer:(UIViewController *)childViewController {
    if(!childViewController) return;
    [childViewController willMoveToParentViewController:nil];
    [childViewController removeFromParentViewController];
    [childViewController.view removeFromSuperview];
}


#pragma mark -
#pragma mark - UIGestureRecognizer Helpers

- (void)addGestureRecognizers {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(centerViewControllerTapped:)];
    [tapRecognizer setDelegate:self];
    [[self.centerViewController view] addGestureRecognizer:tapRecognizer];
}

#pragma mark -
#pragma mark - Menu State

- (void)toggleLeftSideMenuCompletion:(void (^)(void))completion {
    if(self.menuState == MFSideMenuStateLeftMenuOpen) {
        [self setMenuState:MFSideMenuStateClosed completion:completion];
    } else {
        [self setMenuState:MFSideMenuStateLeftMenuOpen completion:completion];
    }
}

- (void)openLeftSideMenuCompletion:(void (^)(void))completion {
    if(!self.leftMenuViewController) return;
    [self.menuContainerView bringSubviewToFront:[self.leftMenuViewController view]];
    [self setCenterViewControllerOffset:self.leftMenuWidth animated:YES completion:completion];
}

- (void)closeSideMenuCompletion:(void (^)(void))completion {
    [self setCenterViewControllerOffset:0 animated:YES completion:completion];
}

- (void)setMenuState:(MFSideMenuState)menuState {
    [self setMenuState:menuState completion:nil];
}

- (void)setMenuState:(MFSideMenuState)menuState completion:(void (^)(void))completion {
    void (^innerCompletion)() = ^ {
        _menuState = menuState;
        
        [self setUserInteractionStateForCenterViewController];
        MFSideMenuStateEvent eventType = (_menuState == MFSideMenuStateClosed) ? MFSideMenuStateEventMenuDidClose : MFSideMenuStateEventMenuDidOpen;
        [self sendStateEventNotification:eventType];
        
        if(completion) completion();
    };
    
    switch (menuState) {
        case MFSideMenuStateClosed: {
            [self sendStateEventNotification:MFSideMenuStateEventMenuWillClose];
            [self closeSideMenuCompletion:^{
                [self.leftMenuViewController view].hidden = YES;
                innerCompletion();
            }];
            break;
        }
        case MFSideMenuStateLeftMenuOpen:
            if(!self.leftMenuViewController) return;
            [self sendStateEventNotification:MFSideMenuStateEventMenuWillOpen];
            [self leftMenuWillShow];
            [self openLeftSideMenuCompletion:innerCompletion];
            break;
        default:
            break;
    }
}

// these callbacks are called when the menu will become visible, not neccessarily when they will OPEN
- (void)leftMenuWillShow {
    [self.leftMenuViewController view].hidden = NO;
    [self.menuContainerView bringSubviewToFront:[self.leftMenuViewController view]];
}

#pragma mark -
#pragma mark - State Event Notification

- (void)sendStateEventNotification:(MFSideMenuStateEvent)event {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:event]
                                                         forKey:@"eventType"];
    [[NSNotificationCenter defaultCenter] postNotificationName:MFSideMenuStateNotificationEvent
                                                        object:self
                                                      userInfo:userInfo];
}


#pragma mark -
#pragma mark - Side Menu Positioning

- (void) setLeftSideMenuFrameToClosedPosition {
    if(!self.leftMenuViewController) return;
    CGRect leftFrame = [self.leftMenuViewController view].frame;
    leftFrame.size.width = self.leftMenuWidth;
    leftFrame.origin.x = (self.menuSlideAnimationEnabled) ? -1*leftFrame.size.width / self.menuSlideAnimationFactor : 0;
    leftFrame.origin.y = 0;
    [self.leftMenuViewController view].frame = leftFrame;
    [self.leftMenuViewController view].autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
}

- (void)alignLeftMenuControllerWithCenterViewController {
    CGRect leftMenuFrame = [self.leftMenuViewController view].frame;
    leftMenuFrame.size.width = _leftMenuWidth;
    CGFloat menuX = [self.centerViewController view].frame.origin.x - leftMenuFrame.size.width;
    leftMenuFrame.origin.x = menuX;
    [self.leftMenuViewController view].frame = leftMenuFrame;
}

#pragma mark -
#pragma mark - Shadows

- (void)setShadowEnabled:(BOOL)shadowEnabled {
    _shadowEnabled = shadowEnabled;
    
    if(_shadowEnabled) {
        [self drawMenuShadows];
    } else {
        [self.centerViewController view].layer.shadowOpacity = 0.0f;
        [self.centerViewController view].layer.shadowRadius = 0.0f;
    }
}

- (void)setShadowRadius:(CGFloat)shadowRadius {
    _shadowRadius = shadowRadius;
    [self drawMenuShadows];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
    [self drawMenuShadows];
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity {
    _shadowOpacity = shadowOpacity;
    [self drawMenuShadows];
}

- (void) drawMenuShadows {
    if(_shadowEnabled) {
        [self drawCenterControllerShadowPath];
        [self.centerViewController view].layer.shadowOpacity = self.shadowOpacity;
        [self.centerViewController view].layer.shadowRadius = self.shadowRadius;
        [self.centerViewController view].layer.shadowColor = [self.shadowColor CGColor];
    }
}

// draw a shadow between the navigation controller and the menu
- (void) drawCenterControllerShadowPath {
    if(_shadowEnabled) {
        CGRect pathRect = [self.centerViewController view].bounds;
        pathRect.size = [self.centerViewController view].frame.size;
        [self.centerViewController view].layer.shadowPath = [UIBezierPath bezierPathWithRect:pathRect].CGPath;
    }
}


#pragma mark -
#pragma mark - Side Menu Width

- (void)setMenuWidth:(CGFloat)menuWidth {
    [self setMenuWidth:menuWidth animated:YES];
}

- (void)setLeftMenuWidth:(CGFloat)leftMenuWidth {
    [self setLeftMenuWidth:leftMenuWidth animated:YES];
}
- (void)setMenuWidth:(CGFloat)menuWidth animated:(BOOL)animated {
    [self setLeftMenuWidth:menuWidth animated:animated];
}

- (void)setLeftMenuWidth:(CGFloat)leftMenuWidth animated:(BOOL)animated {
    _leftMenuWidth = leftMenuWidth;

    if(self.menuState != MFSideMenuStateLeftMenuOpen) {
        [self setLeftSideMenuFrameToClosedPosition];
        return;
    }
    
    CGFloat offset = _leftMenuWidth;
    void (^effects)() = ^ {
        [self alignLeftMenuControllerWithCenterViewController];
    };
    
    [self setCenterViewControllerOffset:offset additionalAnimations:effects animated:animated completion:nil];
}

#pragma mark -
#pragma mark - UIGestureRecognizer Callbacks

- (void)centerViewControllerTapped:(id)sender {
    if(self.menuState != MFSideMenuStateClosed) {
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: MENU_CLOSED]];
        [self setMenuState:MFSideMenuStateClosed];
    }
}

- (void)setUserInteractionStateForCenterViewController {
    // disable user interaction on the current stack of view controllers if the menu is visible
    if([self.centerViewController respondsToSelector:@selector(viewControllers)]) {
        NSArray *viewControllers = [self.centerViewController viewControllers];
        for(UIViewController* viewController in viewControllers) {
            viewController.view.userInteractionEnabled = (self.menuState == MFSideMenuStateClosed);
        }
    }
}

#pragma mark -
#pragma mark - Center View Controller Movement

- (void)setCenterViewControllerOffset:(CGFloat)offset animated:(BOOL)animated completion:(void (^)(void))completion {
    [self setCenterViewControllerOffset:offset additionalAnimations:nil
                               animated:animated completion:completion];
}

- (void)setCenterViewControllerOffset:(CGFloat)offset
                 additionalAnimations:(void (^)(void))additionalAnimations
                             animated:(BOOL)animated
                           completion:(void (^)(void))completion {
    void (^innerCompletion)() = ^ {
        if(completion) completion();
    };
    
    if(animated) {
        CGFloat centerViewControllerXPosition = ABS([self.centerViewController view].frame.origin.x);
        CGFloat duration = [self animationDurationFromStartPosition:centerViewControllerXPosition toEndPosition:offset];
        
        [UIView animateWithDuration:duration animations:^{
            [self setCenterViewControllerOffset:offset];
            if(additionalAnimations) additionalAnimations();
        } completion:^(BOOL finished) {
            innerCompletion();
        }];
    } else {
        [self setCenterViewControllerOffset:offset];
        if(additionalAnimations) additionalAnimations();
        innerCompletion();
    }
}

- (void) setCenterViewControllerOffset:(CGFloat)xOffset {
    CGRect frame = [self.centerViewController view].frame;
    frame.origin.x = xOffset;
    [self.centerViewController view].frame = frame;
    
    if(!self.menuSlideAnimationEnabled) return;
    
    if(xOffset > 0){
        [self alignLeftMenuControllerWithCenterViewController];
    } else if(xOffset < 0){
        [self setLeftSideMenuFrameToClosedPosition];
    } else {
        [self setLeftSideMenuFrameToClosedPosition];
    }
}

- (CGFloat)animationDurationFromStartPosition:(CGFloat)startPosition toEndPosition:(CGFloat)endPosition {
    CGFloat animationPositionDelta = ABS(endPosition - startPosition);
    
    CGFloat duration;
    if(ABS(self.panGestureVelocity) > 1.0) {
        // try to continue the animation at the speed the user was swiping
        duration = animationPositionDelta / ABS(self.panGestureVelocity);
    } else {
        // no swipe was used, user tapped the bar button item
        CGFloat menuWidth = _leftMenuWidth;
        CGFloat animationPerecent = (animationPositionDelta == 0) ? 0 : menuWidth / animationPositionDelta;
        duration = self.menuAnimationDefaultDuration * animationPerecent;
    }
    
    return MIN(duration, self.menuAnimationMaxDuration);
}

@end