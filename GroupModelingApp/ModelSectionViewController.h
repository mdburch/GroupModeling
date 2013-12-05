//
//  ModelSectionViewController.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 8/2/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "CausalLinkView.h"
#import "ModelSectionView.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>

/// The segemented control index locations.
enum Segcontrol
{
    VARIABLE_INDEX = 0,
    LINK_INDEX     = 1,
    LOOP_INDEX     = 2,
};

/// The view controller that handles interaction with the model section.
@interface ModelSectionViewController : UIViewController <UIDocumentInteractionControllerDelegate, UIPopoverControllerDelegate>

/// The menu of options to add new objects to the model.
@property UISegmentedControl* controls;

/// The button that will allow a user to create a new project.
@property UIBarButtonItem* createNewButton;

/// Segmented control for loading a model.  Need it so we can disable actions and change the image.
@property UISegmentedControl* loadSegControl;

/// The button that will load saved files.
@property UIBarButtonItem* loadButton;

/// The button that will save files.
@property UIBarButtonItem* takePictureButton;

/// Segmented control for saving a model.  Need it so we can disable actions and change the image.
@property UISegmentedControl* saveSegControl;

/// The button that will save files.
@property UIBarButtonItem* saveButton;

/// A pointer to a UIPopoverController which will contain the edit object menu.
@property UIPopoverController* popOverController;

/// A pointer to the view that has been selected for menu options.
@property UIView* selectedView;

/// A pointer to the Model view.
@property ModelSectionView* modelView;

/// A pointer to a check the internet connection of the device.
@property Reachability* internetReachability;

/// A pointer to the doc interaction controller to save the file.
@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

/// An asynchronous queue that will be used to push the log files to parse.
@property dispatch_queue_t logQueue;

/// Will specifiy if a log file is being pushed so we do not have the save button enabled.
@property bool isLogFileSaving;

-(id) init;
-(void) reachabilityChanged:(NSNotification *)note;
-(void) checkInternetConnection:(Reachability *)reachability;
-(void) loadModel;
-(void) newModel;
-(void) takePictureOfModel;
-(void) image:(UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo:(void*) contextInfo;
-(void) viewDidLoad;
-(void) reenableSaveButton;
-(void) saveModel;
-(MFSideMenuContainerViewController *)menuContainerViewController;
-(void) setupMenuBarButtonItems;
-(UIBarButtonItem *) leftMenuBarButtonItem;
-(NSArray*) rightMenuBarButtonItems;
-(void) leftSideMenuButtonPressed:(id)sender;

// Methods to handle the update menu.
-(BOOL) canBecomeFirstResponder;
-(BOOL) canPerformAction:(SEL)action withSender:(id)sender;
-(void) createUpdateMenu:(UIView*)view;
-(void) didHideUpdateMenu;
-(void) createEditMenu: (UIView*) sender;
-(CGRect) getVariableVertexView:(CausalLinkView*)view;
-(UIToolbar*) createEditMenuToolbar:(CGRect) frame;
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;
-(void) saveChanges;
-(void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(int) index;
-(void) showDeleteAlert: (UIView*) sender;
-(int) getSelectedViewIDNum;

// Method for logging events.
-(void) documentInteractionControllerWillPresentOpenInMenu: (UIDocumentInteractionController *) controller;
-(void) documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *) controller;
-(void) documentInteractionController: (UIDocumentInteractionController *) controller willBeginSendingToApplication: (NSString *) application;
-(void) menuChange;
-(NSString*)getMenuDetails;
@end
