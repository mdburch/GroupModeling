//
//  AppDelegate.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/2/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import <DBChooser/DBChooser.h>
#import "EventLogger.h"
#import "SideMenuViewController.h"
#import "ModelSectionViewController.h"
#import <Parse/Parse.h>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:[[UINavigationController alloc]initWithRootViewController:[[ModelSectionViewController alloc]init]]
                                                    leftMenuViewController:[[SideMenuViewController alloc] init]];
    self.window.rootViewController = self.container;
    
    [self.window makeKeyAndVisible];
    
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: APP_LOADED]];
    
    // Register notifications for device orientation.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    

    
    // Set up parse application.
    [Parse setApplicationId:@"ENTER YOUR APP ID HERE"
                  clientKey:@"ENTER YOUR CLIENT KEY HERE"];
    
    // Track metrics on using Parse.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: MEMORY_WARNING]];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: APP_ENTERED_BACKGROUND]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    UINavigationController* navView = self.container.centerViewController;
    if(navView.viewControllers.count >0)
    {
        ModelSectionViewController* modelView = navView.viewControllers.lastObject;
        [modelView checkInternetConnection:modelView.internetReachability];
    }
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: APP_ENTERED_FOREGROUND]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: APP_TERMINATED]];
}

/// Method used to handle the linkage between my app and Dropbox.
/// @param app the application making the call.
/// @param url the url of the file we would like to choose.
/// @param source the source application.
/// @param annotation
/// @return a boolean value if whether or not the url can be opened.
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation
{
    if ([[DBChooser defaultChooser] handleOpenURL:url]) {
        // This was a Chooser response and handleOpenURL automatically ran the
        // completion block
        return YES;
    }
    
    return NO;
}

/// Notifies the logger that the user is rotating the iPad.
-(void) detectOrientation
{
    NSString* details;
    switch([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationLandscapeLeft:
            details = LANDSCAPE_LEFT;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            details = LANDSCAPE_RIGHT;
            break;
            
        case UIDeviceOrientationPortrait:
            details = PORTRAIT;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            details = PORTRAIT_UPSIDEDOWN;
            break;
            
        case UIDeviceOrientationFaceUp:
            details = FACE_UP;
            break;
            
        case UIDeviceOrientationFaceDown:
            details = FACE_DOWN;
            break;
            
        case UIDeviceOrientationUnknown:
            details = UNKNOWN;
            break;
            
        default:
            break;
    }
    
     [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: ORIENTATION_CHANGED andDetails:details]];
}

@end
