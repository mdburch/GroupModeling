//
//  AppDelegate.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/2/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import <DBChooser/DBChooser.h>
#import "MFSideMenuContainerViewController.h"
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

///The UIResponder class defines an interface for objects that respond to and handle events. It is the superclass of UIApplication, UIView and its subclasses (which include UIWindow). Instances of these classes are sometimes referred to as responder objects or, simply, responders.
@interface AppDelegate : UIResponder <UIApplicationDelegate>

/// A pointer to our canvas to create models.
@property MFSideMenuContainerViewController *container;

/// The window of the application.
@property (strong, nonatomic) UIWindow *window;

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation;
-(void) detectOrientation;
@end
