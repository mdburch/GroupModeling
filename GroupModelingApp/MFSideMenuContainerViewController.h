//
//  MFSideMenuContainerViewController.h
//  GroupModelingApp
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

#import <UIKit/UIKit.h>

extern NSString * const MFSideMenuStateNotificationEvent;

typedef enum {
    MFSideMenuPanModeNone = 0, // pan disabled
    MFSideMenuPanModeCenterViewController = 1 << 0, // enable panning on the centerViewController
    MFSideMenuPanModeSideMenu = 1 << 1, // enable panning on side menus
    MFSideMenuPanModeDefault = MFSideMenuPanModeCenterViewController | MFSideMenuPanModeSideMenu
} MFSideMenuPanMode;

typedef enum {
    MFSideMenuStateClosed, // the menu is closed
    MFSideMenuStateLeftMenuOpen, // the left-hand menu is open
    MFSideMenuStateRightMenuOpen
} MFSideMenuState;

typedef enum {
    MFSideMenuStateEventMenuWillOpen, // the menu is going to open
    MFSideMenuStateEventMenuDidOpen, // the menu finished opening
    MFSideMenuStateEventMenuWillClose, // the menu is going to close
    MFSideMenuStateEventMenuDidClose // the menu finished closing
} MFSideMenuStateEvent;


@interface MFSideMenuContainerViewController : UIViewController<UIGestureRecognizerDelegate>

+ (MFSideMenuContainerViewController *)containerWithCenterViewController:(id)centerViewController
                                                  leftMenuViewController:(id)leftMenuViewController;

@property (nonatomic, strong) UINavigationController* centerViewController;
@property (nonatomic, strong) UIViewController *leftMenuViewController;

@property (nonatomic, assign) MFSideMenuState menuState;
@property (nonatomic, assign) MFSideMenuPanMode panMode;

// menu open/close animation duration -- user can pan faster than default duration, max duration sets the limit
@property (nonatomic, assign) CGFloat menuAnimationDefaultDuration;
@property (nonatomic, assign) CGFloat menuAnimationMaxDuration;

// width of the side menus
@property (nonatomic, assign) CGFloat menuWidth;
@property (nonatomic, assign) CGFloat leftMenuWidth;

// shadow
@property (nonatomic, assign) BOOL shadowEnabled;
@property (nonatomic, assign) CGFloat shadowRadius;
@property (nonatomic, assign) CGFloat shadowOpacity;
@property (nonatomic, strong) UIColor *shadowColor;

// menu slide-in animation
@property (nonatomic, assign) BOOL menuSlideAnimationEnabled;
@property (nonatomic, assign) CGFloat menuSlideAnimationFactor; // higher = less menu movement on animation

- (void) openHelpSection;
- (void) returnToRoot;
- (void)toggleLeftSideMenuCompletion:(void (^)(void))completion;
- (void)setMenuState:(MFSideMenuState)menuState completion:(void (^)(void))completion;
- (void)setMenuWidth:(CGFloat)menuWidth animated:(BOOL)animated;
- (void)setLeftMenuWidth:(CGFloat)leftMenuWidth animated:(BOOL)animated;

@end
