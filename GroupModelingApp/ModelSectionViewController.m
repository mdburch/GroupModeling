//
//  ModelSectionViewController.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 8/2/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "CausalLinkEditMenuView.h"
#import "CausalLinkView.h"
#import "Constants.h"
#import <DBChooser/DBChooser.h>
#import "EventLogger.h"
#import "FileIO.h"
#import "LoopEditMenuView.h"
#import "Model.h"
#import "ModelSectionViewController.h"
#import "VariableEditMenuView.h"
@interface ModelSectionViewController ()

@end

@implementation ModelSectionViewController

@synthesize controls                      = _controls;
@synthesize createNewButton               = _createNewButton;
@synthesize takePictureButton             = _takePictureButton;
@synthesize loadSegControl                = _loadSegControl;
@synthesize loadButton                    = _loadButton;
@synthesize saveSegControl                = _saveSegControl;
@synthesize saveButton                    = _saveButton;
@synthesize popOverController             = _popOverController;
@synthesize selectedView                  = _selectedView;
@synthesize modelView                     = _modelView;
@synthesize internetReachability          = _internetReachability;
@synthesize documentInteractionController = _documentInteractionController;
@synthesize logQueue                      = _logQueue;
@synthesize isLogFileSaving               = _isLogFileSaving;

/// Initializes the View Controller.
/// Will create the views for all of the menu options.
/// @return an id of the newly created view controller.
-(id) init
{
    self = [super init];
    if (self) {
        self.modelView = [[ModelSectionView alloc]init];
        self.isLogFileSaving = NO;
        self.logQueue  = dispatch_queue_create(LOG_QUEUE, DISPATCH_QUEUE_SERIAL);
    }
 
    return self;
}

/// Used for iOS5 so that rotation can occur.  Will always return true.
/// @param toInterfaceOrientation the orientation of the device.
/// @return true. Will always want to rotate.
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return true;
}
/// Will receive notifications from Reachability and pass it off to check if the message is about internet connection.
/// @param note the notification.
- (void) reachabilityChanged:(NSNotification *)note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self checkInternetConnection:curReach];
}

/// Will handle Reachability notifications about internet connection.  Will disable the open and save model icons when there is no internet.
/// @param reachability the Reachablity notification.
- (void)checkInternetConnection:(Reachability *)reachability
{
	if (reachability == self.internetReachability)
	{
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        
        switch (netStatus)
        {
            case NotReachable:
                [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: NO_INTERNET_CONNECTION]];
                self.loadButton.enabled = NO;
                self.loadSegControl.userInteractionEnabled = NO;
                [self.loadSegControl setImage:[UIImage imageNamed:DISABLE_OPEN_MODEL_ICON] forSegmentAtIndex:0];
                
                self.saveButton.enabled = NO;
                self.saveSegControl.userInteractionEnabled = NO;
                [self.saveSegControl setImage:[UIImage imageNamed:DISABLE_SAVE_ICON] forSegmentAtIndex:0];
                break;
                
            default:
                [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: INTERNET_CONNECTION]];
                self.loadButton.enabled = YES;
                self.loadSegControl.userInteractionEnabled = YES;
                [self.loadSegControl setImage:[UIImage imageNamed:OPEN_MODEL_ICON] forSegmentAtIndex:0];
                
                // If a log file is saving and we regain internet connection, we do not want re-enable the button.
                if(!self.isLogFileSaving)
                {
                    self.saveButton.enabled = YES;
                    self.saveSegControl.userInteractionEnabled = YES;
                }
                
                // Can change the image even if a log file is being pushed since there is indeed internet.
                [self.saveSegControl setImage:[UIImage imageNamed:SAVE_ICON] forSegmentAtIndex:0];
                break;
        }
	}
}

/// Called when the load model button has been pressed.
/// This method will redirect the user to Dropbox to open a model file.
-(void)loadModel
{
//    NSArray * textFile =  [[file openFile] componentsSeparatedByString:@"\n"];
//    
//    // Read in the input file.
//
//    [[FileIO sharedFileIO] importModel:textFile];

// Commented out so that I can use the IOS simulator.
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: OPEN_FILE_REQUEST]];
    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect
                                    fromViewController:self completion:^(NSArray *results)
     {
         if ([results count]) {
             // Process results from Chooser
             DBChooserResult* myFile = [results objectAtIndex:0];
             if(![[myFile name] hasSuffix:MDL_EXTENSION] && ![[myFile name] hasSuffix:TXT_EXTENSION])
             {
                 [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: INVALID_FILE andDetails:[myFile name]]];
                 UIAlertView*  alert = [[UIAlertView alloc] initWithTitle: TITLE_SORRY
                                                                  message: BAD_FILE_MSG
                                                                 delegate: self
                                                        cancelButtonTitle: TITLE_OK
                                                        otherButtonTitles: nil];
                 alert.tag = INVALID_FILE_ALERT;
                 [alert show];
             }
             else
             {
                 // Clear anything from a previous model.
                 [[Model sharedModel] clearModel];
              
                 // Log the event.
                 [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: FILE_SELECTED andDetails:[myFile name]]];
                 
                 // Set the tile of the nav controller.
                 self.title = [myFile name];
                 
                 // Get the data from the url.
                 NSData *thedata = [NSData dataWithContentsOfURL:[myFile link]];
                 
                 // Take a hash of the original file for logging purposes.
                 NSData* hash = [FileIO sha1:thedata];
                 [[Model sharedModel] setStartingHash:hash];

                 // Parse the data into a string.
                 NSString* stringOfData = [[NSString alloc] initWithData:thedata encoding:NSUTF8StringEncoding];
                 
                 // Parse the string into an array separated by line breaks.
                 NSArray * textFile =  [stringOfData componentsSeparatedByString:@"\n"];
                 
                 // Read in the input file.
                 [[FileIO sharedFileIO] importModel:textFile];
             }
         } else {
             // User canceled the action
             [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: OPEN_REQUEST_CANCELLED]];
         }
     }];
}

/// Will create a blank sheet so that the user can create a new model.
-(void) newModel
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: NEW_MODEL_WARNING]];
    UIAlertView*  alert = [[UIAlertView alloc] initWithTitle: TITLE_WARNING
                                                     message: NEW_MODEL_MSG
                                                    delegate: self
                                           cancelButtonTitle: TITLE_NO
                                           otherButtonTitles: TITLE_YES, nil];
    
    alert.tag = NEW_MODEL_ALERT;
    [alert show];
}

/// Method that is called when the take picture of model button has been selected.
/// Will save the picture to the user's photo album.
-(void) takePictureOfModel
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: SAVE_IMAGE_OF_MODEL]];
    
    UIImage* image = nil;
    ModelSectionView* modelView = (ModelSectionView*)self.view; // Get the view of the model.
    CGRect pictureFrame = [[Model sharedModel] findModelFrame]; // Determine the size of the picture

    // Get the size of the context.
    CGSize contextSize = CGSizeMake(pictureFrame.size.width - pictureFrame.origin.x,
                                    pictureFrame.size.height);
    
    UIGraphicsBeginImageContext(contextSize);
    {
        // Save the model's content view frame and offset.
        CGPoint savedContentOffset = modelView.contentOffset;
        CGRect savedFrame = modelView.frame;
        
        // Move the context to the x origin of the image.
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM (ctx, -pictureFrame.origin.x, 0);

        // Set up the frame of the picture.
        modelView.contentOffset = CGPointZero;
        modelView.frame = CGRectMake(0,
                                     0,
                                     pictureFrame.size.width,
                                     pictureFrame.size.height);
  
        // Create the image.
        [modelView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
    
        // Places the image that was created in a reference the size of the model.
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], modelView.frame);
        image = [UIImage imageWithCGImage:imageRef];
        
        // Reset the model views frame.
        modelView.contentOffset = savedContentOffset;
        modelView.frame         = savedFrame;
    }
    
    // Save the image to the photo album.
    UIImageWriteToSavedPhotosAlbum(image,self,@selector(image:
                                                        didFinishSavingWithError:
                                                        contextInfo:),nil);
}

/// Called after an image of the model has been saved to notify the user if the image was successfully saved.
/// @param image the image that was saved.
/// @param didFinishSavingWithError whether or not there was an error when the picture was saved.
/// @param contextInfo an optional pointer to any context-specific data that you want passed to the completion selector.
- (void) image:(UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo:(void*) contextInfo
{
    NSString* title;
    NSString* message;
    int tag;
    
    // Print different messages based on whether the image was successfully saved.
    if(error)
    {
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: IMAGE_NOT_SAVED]];
        title   = TITLE_PICTURE_NOT_SAVED;
        message = PICTURE_NOT_SAVED_MSG;
        tag = IMAGE_NOSAVE_ALERT;
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: NOTIFY_IMAGE_NOT_SAVED]];
    }
    else
    {
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: IMAGE_SAVED]];
        title   = TITLE_PICUTRE_SAVED;
        message = PICTURE_SAVED_MSG;
        tag = IMAGE_SAVE_ALERT;
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: NOTIFY_IMAGE_SAVED]];
    }
    
    UIAlertView*  alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate: self
                                           cancelButtonTitle: TITLE_OK
                                           otherButtonTitles: nil];

    alert.tag = tag;
    [alert show];
}

/// Will be used to re-enable the save button when the log file has been sent to Parse.
/// We restrict the user from pushing more than one time when there is a event logging record on the queue trying to be pushed to Parse.
-(void) reenableSaveButton
{
    //NSLog(@"reanebleeee");
    self.isLogFileSaving = NO;
    // Will determine if the save button can be re-enabled if internet is available.
    [self checkInternetConnection:self.internetReachability];
}

/// Will save the current model.
-(void) saveModel
{
    // Log save button being pressed.
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: SAVE_MODEL]];
    
    NSURL* url = [[FileIO sharedFileIO] exportModel];
    
    if (url)
    {
        // Dismiss the document interaction controller if it happens to be open.  (If you have document interaction controller open and you try to show it again the app will crash).
        [self.documentInteractionController dismissMenuAnimated:NO];
        
        // Initialize Document Interaction Controller
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        
        // Set delegate for Document Interaction Controller to self.
        [self.documentInteractionController setDelegate:self];
    
        // Present Open In Menu
        bool didDisplay = [self.documentInteractionController presentOpenInMenuFromBarButtonItem:[self.navigationItem.rightBarButtonItems objectAtIndex:1]animated:YES];
        
        // If the menu did not find apps that can open the file, display other options.
        if(!didDisplay)
        {
            [self.documentInteractionController presentOptionsMenuFromBarButtonItem:[self.navigationItem.rightBarButtonItems objectAtIndex:1] animated:YES];
        }
    }
}

//================================================================================================================================
// Methods used solely for logging events.
//================================================================================================================================

/// Logs when the open in menu to save the file is presented.
/// @param controller the document interaction controller that will display the results.
-(void) documentInteractionControllerWillPresentOpenInMenu: (UIDocumentInteractionController *) controller
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: SAVE_OPTIONS_OPENED]];
}

/// Logs when the open in menu to save the file has been closed.
/// @param controller the document interaction controller that will display the results.
-(void) documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *) controller
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: SAVE_OPTIONS_CLOSED]];
}

/// Logs when an option in the open menu has been selected.
/// @param controller the document interaction controller that will display the results.
/// @param application a string of the application that we are being directed to.
-(void) documentInteractionController: (UIDocumentInteractionController *) controller willBeginSendingToApplication: (NSString *) application
{
    [[EventLogger sharedEventLogger]addEvent: [[Event alloc] initWithDescID:REDIRECTED_TO andDetails:application]];

    // Disable the save button while the log is being uploaded.
    self.isLogFileSaving = YES;
    self.saveButton.enabled = NO;
    self.saveSegControl.userInteractionEnabled = NO;
    
    dispatch_async(self.logQueue, ^{
        //NSLog(@"Starting job");
        [[FileIO sharedFileIO] exportEventLogging];
        //NSLog(@"Ending job");
        [self performSelectorOnMainThread:@selector(reenableSaveButton) withObject:nil waitUntilDone:NO];
    });
}

/// Notifies the logger when a new option from the segmented control has been changed.
-(void) menuChange
{
    NSString* details;
    switch(self.controls.selectedSegmentIndex)
    {
        case VARIABLE_INDEX:
            details = VAR_OPTION_SELECTED;
            break;
            
        case LINK_INDEX:
            details = LINK_OPTION_SELECTED;
            break;
            
        case LOOP_INDEX:
            details = LOOP_OPTION_SELECTED;
            break;
    }
    
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: ADD_OBJECT_CONTROL_CHANGED andDetails:details]];
}

/// Used to get the name of the class that an update/edit menu is being created for.  Will be either Variable, Causal Link, or Loop.
/// @return the name of the class that is being updated.
-(NSString*)getMenuDetails
{
    NSString* details;
    if([self.selectedView isMemberOfClass:[VariableView class]])
        details = VARIABLE_LABEL;
    else if([self.selectedView isMemberOfClass:[LoopView class]])
        details = LOOP_LABEL;
    else if([self.selectedView isMemberOfClass:[CausalLinkView class]])
        details = CAUSAL_LINK_LABEL;
    
    return details;
}
//================================================================================================================================
// Methods that handles creating the nav controller menus.
//================================================================================================================================

/// Called when the view finishes loading.
/// Will set the default shown view and other attrubutes.
-(void) viewDidLoad {
    [super viewDidLoad];
    if(!self.title) self.title = DEFAULT_TITLE;
    self.view = self.modelView;
    [self setupMenuBarButtonItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    /// A pointer to a variable to see if we have internet connection.
    self.internetReachability = [Reachability reachabilityForInternetConnection];
	[self.internetReachability startNotifier];
	[self checkInternetConnection:self.internetReachability];
}

/// Gets the menu container view controller.
/// @return the menu container view controller.
-(MFSideMenuContainerViewController *)menuContainerViewController
{
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

/// Sets up the menu bar of the view controller.
-(void) setupMenuBarButtonItems
{
    // Set up the left bar button item
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
    } else {
        /// @note Commented out because we do not need the menu right now.
        //self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
    
    // Show the menu items if you are in the design view
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithArray:[self rightMenuBarButtonItems]];
}

/// Creates the left menu bar button item.  This item will be responsible for opening the menu.
/// @return the left menu bar button item.
-(UIBarButtonItem *) leftMenuBarButtonItem
{
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:MENU_ICON]
            style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

/// Creates the left menu bar button item.  This item will be responsible for opening the menu.
/// @return an array of items contained in the right menu.
-(NSArray*) rightMenuBarButtonItems
{
    //################################################################################################################
    // Button to create a new model
    UISegmentedControl* newButton  = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                                 [UIImage imageNamed:NEW_MODEL_ICON],
                                                                                 nil]];
    newButton.momentary = TRUE;
    newButton.segmentedControlStyle = UISegmentedControlStyleBar; // this style allows me to update the tint color
    [newButton setTintColor: nil];
    
    // Register a selector callback when the button has changed to log it.
    [newButton addTarget:self action:@selector(newModel) forControlEvents:UIControlEventValueChanged];
    
    // Convert segmented control to a bar button item
    self.createNewButton = [[UIBarButtonItem alloc] initWithCustomView:newButton];

    //################################################################################################################
    // Button to load a model
    self.loadSegControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                                [UIImage imageNamed:OPEN_MODEL_ICON],
                                                                                nil]];
    
    self.loadSegControl.momentary = TRUE;
    self.loadSegControl.segmentedControlStyle = UISegmentedControlStyleBar; // this style allows me to update the tint color
    [self.loadSegControl setTintColor: nil];
    
    // Register a selector callback when the button has changed to log it.
    [self.loadSegControl addTarget:self action:@selector(loadModel) forControlEvents:UIControlEventValueChanged];
    
    // Convert segmented control to a bar button item
    self.loadButton = [[UIBarButtonItem alloc] initWithCustomView:self.loadSegControl];
    
    //################################################################################################################
    // Button to save an image of the model
    UISegmentedControl* picButton  = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                                 [UIImage imageNamed:PHOTO_ICON],
                                                                                 nil]];
    
    picButton.momentary = TRUE;
    picButton.segmentedControlStyle = UISegmentedControlStyleBar; // this style allows me to update the tint color
    [picButton setTintColor: nil];
    
    // Register a selector callback when the button has changed to log it.
    [picButton addTarget:self action:@selector(takePictureOfModel) forControlEvents:UIControlEventValueChanged];
    
    // Convert segmented control to a bar button item
    self.takePictureButton = [[UIBarButtonItem alloc] initWithCustomView:picButton];

    //################################################################################################################
    // Button to save a model
    self.saveSegControl  = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                                [UIImage imageNamed:SAVE_ICON],
                                                                                nil]];
    
    self.saveSegControl.momentary = TRUE;
    self.saveSegControl.segmentedControlStyle = UISegmentedControlStyleBar; // this style allows me to update the tint color
    [self.saveSegControl setTintColor: nil];
    
    // Register a selector callback when the button has changed to log it.
    [self.saveSegControl addTarget:self action:@selector(saveModel) forControlEvents:UIControlEventValueChanged];
    
    // Convert segmented control to a bar button item
    self.saveButton = [[UIBarButtonItem alloc] initWithCustomView:self.saveSegControl];

    //################################################################################################################
    // Controls to add new components to the model
    self.controls = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                               [UIImage imageNamed:VARIABLE_ICON],
                                                               [UIImage imageNamed:LINK_ICON],
                                                               [UIImage imageNamed:LOOP_ICON], nil]];
    
    self.controls.selectedSegmentIndex = VARIABLE_INDEX; // set the first item to be selected by default
    self.controls.segmentedControlStyle = UISegmentedControlStyleBar; // this style allows me to update the tint color
    [self.controls setTintColor: nil];
    
    // Register a selector callback when the button has changed to log it.
    [self.controls addTarget:self action:@selector(menuChange) forControlEvents:UIControlEventValueChanged];
    
    // Convert segmented control to a bar button item
    UIBarButtonItem *controlsMenu = [[UIBarButtonItem alloc] initWithCustomView:self.controls];
    
    return [[NSArray alloc] initWithObjects: controlsMenu, self.saveButton, self.takePictureButton, self.loadButton, self.createNewButton, nil];
}

/// Callback for when the left menu button is pressed.
/// @param sender the id of the sender object.
-(void) leftSideMenuButtonPressed:(id)sender
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: MENU_OPENED]];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

//================================================================================================================================
// Methods that handle the update menus.
//================================================================================================================================

/// Determines if the reveiver can become the first responder.
/// @return a Boolean value indicating whether the receiver can become first responder.
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

/// Requests the receiving responder to enable or disable the specified command in the user interface.
/// @param action a selector that identifies a method associated with a command.
/// @param sender object calling this method.
/// @return YES if the the command identified by action should be enabled or NO if it should be disabled.
-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    bool performsAction = NO;
    if(action == @selector(createEditMenu:) ||
       action == @selector(showDeleteAlert:))
    {
        performsAction = YES;
    }
    
    return performsAction;
}

/// Creates the menu that displays the options to update the object in the model. The current update options include edit and delete.
/// @param view the view containing the object in the model.
-(void) createUpdateMenu:(UIView*)view
{
    // Make the view controller the first responder if it can.
    if([self canBecomeFirstResponder])
        [self becomeFirstResponder];
    
    // Create the items for the menu.
    UIMenuItem* edit   = [[UIMenuItem alloc] initWithTitle: TITLE_EDIT   action:@selector(createEditMenu:)];
    UIMenuItem* delete = [[UIMenuItem alloc] initWithTitle: TITLE_DELETE action:@selector(showDeleteAlert:)];
    
    // Get the singleton uimenucontroller class.
    UIMenuController* mc = [UIMenuController sharedMenuController];
    [mc setMenuItems:[NSArray arrayWithObjects: edit, delete, nil]];
    
    // Notify me when the menu closes.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideUpdateMenu) name:UIMenuControllerDidHideMenuNotification object:mc];
    
    // Setting up the location of the menu will differ based on what object is being edited.
    if([view isKindOfClass:[CausalLinkView class]])
    {
        CausalLinkView* clv = (CausalLinkView*)view;
        // Place the menu over the vertex point.
        [mc setTargetRect:[self getVariableVertexView:clv]
                   inView: self.view];
        
    }
    else // if the object is a variable or loop.
    {
        [mc setTargetRect: CGRectMake(view.frame.origin.x,
                                      view.frame.origin.y,
                                      view.frame.size.width,
                                      view.frame.size.height)
                   inView: self.view];
    }
    
    // Show the menu.
    [mc setMenuVisible: YES animated: YES];
    
    // Save the selected view.
    self.selectedView = view;
    
    // Log that the update menu has opened.
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: UPDATE_MENU_OPENED
                                                               andObjectID:[self getSelectedViewIDNum]
                                                                andDetails:[self getMenuDetails]]];
}

/// Will log a message stating the update menu closed.
-(void) didHideUpdateMenu
{
   [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: UPDATE_MENU_CLOSED andObjectID:[self getSelectedViewIDNum]
                                                               andDetails:[self getMenuDetails]]];
    
    // Remove the notification so that we do not get the notification multiple times in the future.
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

/// Creates the menu for editing an object.
/// @param sender the view that called to create the menu.
-(void) createEditMenu: (UIView*) sender
{
    UIViewController* editMenuViewController = [[UIViewController alloc]init];
    UIView* editMenuView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, EDIT_MENU_WIDTH, EDIT_MENU_HEIGHT)];
    
    // Create the toolbar.
    UIToolbar* toolbar = [self createEditMenuToolbar:CGRectMake(editMenuView.frame.origin.x,
                                                                editMenuView.frame.origin.y,
                                                                editMenuView.frame.size.width,
                                                                TOOLBAR_HEIGHT)];
    
    // Create a view that will contain all of the attributes that can be edited for the object.
    UIView* view;
    CGRect viewRect = CGRectMake(editMenuView.frame.origin.x,
                                 editMenuView.frame.origin.y+TOOLBAR_HEIGHT,
                                 editMenuView.frame.size.width,
                                 editMenuView.frame.size.height-TOOLBAR_HEIGHT);
    
    // Set the view to a specific view related to the object that needs to be edited.
    if([self.selectedView isMemberOfClass:[VariableView class]])
    {
        view = [[VariableEditMenuView alloc]initWithFrame:viewRect view: (UIView*)self.selectedView];
    }
    else if([self.selectedView isMemberOfClass:[LoopView class]])
    {
        view = [[LoopEditMenuView alloc]initWithFrame:viewRect view:(UIView*) self.selectedView];
    }
    else if([self.selectedView isMemberOfClass:[CausalLinkView class]])
    {
        // The causal link has extra attributes that cause a larger edit menu.
        viewRect.size.height += EDIT_MENU_HEIGHT_EXTENSION;
        editMenuView.frame    = CGRectMake(0, 0, EDIT_MENU_WIDTH, EDIT_MENU_HEIGHT+EDIT_MENU_HEIGHT_EXTENSION);
        
        view = [[CausalLinkEditMenuView alloc]initWithFrame:viewRect view:(UIView*) self.selectedView];
    }
    
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: EDIT_MENU_CREATED
                                                               andObjectID:[self getSelectedViewIDNum]
                                                                andDetails:[self getMenuDetails]]];
    
    // Add the subviews to the edit menu view and then add the edit menu view to its controller.
    [editMenuView addSubview:view];
    [editMenuView addSubview:toolbar];
    [editMenuViewController setView:editMenuView];
    
    // Create the popover controller to handle the display of the window.
    self.popOverController = [[UIPopoverController alloc]initWithContentViewController:editMenuViewController];
    self.popOverController.popoverContentSize = CGSizeMake(editMenuView.frame.size.width,
                                                           editMenuView.frame.size.height);
    self.popOverController.delegate = self;
    
    // Create a rectangle to handle the view where we will present the popover.
    CGRect rect = self.selectedView.frame;
    
    // If we have a causal link we want the popup menu to appear over the vertex.
    if([self.selectedView isKindOfClass:[CausalLinkView class]])
    {
        CausalLinkView * clv = (CausalLinkView*)self.selectedView;
        rect = [self getVariableVertexView:clv];
    }
    
    [self.popOverController presentPopoverFromRect:rect
                                            inView:self.view
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
    
}

/// Sets up the view that will place the edit menu or update menu over the vertex.
/// @param view the casual link view of the obejct we want to have a menu appear over.
/// @return the rectangle frame over the vertex.
-(CGRect) getVariableVertexView:(CausalLinkView*)view
{
    return CGRectMake(view.frame.origin.x + view.vertexPoint.x,
                      view.frame.origin.y + view.vertexPoint.y,
                      1,
                      1);
}

/// Creates the toolbar for the edit menu.
/// @param frame the frame of the toolbar.
/// @return a toolbar for the edit menu containing a save and a cancel option.
-(UIToolbar*) createEditMenuToolbar:(CGRect) frame
{
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:frame];
    
    [toolbar setBarStyle:UIBarStyleDefault];
    
    // Currently not using the flexspace, but may need it again in the future.
    // Flex space button item used for spacing.
    //UIBarButtonItem* flexSpace  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target: nil action:nil];
    
    // A save button that will allow the user to save their changes.
    UIBarButtonItem* saveButton  = [[UIBarButtonItem alloc]initWithTitle:TITLE_SAVE style:UIBarButtonItemStyleBordered target: self action:@selector(saveChanges)];
    saveButton.width = toolbar.frame.size.width * .45;
    
    // A cancel button that will allow the user to discard their changes.
    UIBarButtonItem* cancelButton  = [[UIBarButtonItem alloc]initWithTitle:TITLE_CANCEL style:UIBarButtonItemStyleBordered target: self action:@selector(popoverControllerDidDismissPopover:)];
    cancelButton.width = toolbar.frame.size.width * .45;
    
    // Add buttons to the toolbar.
    [toolbar setItems:[NSArray arrayWithObjects: cancelButton, saveButton, nil]];
    
    // Update the style.
    toolbar.barStyle = UIBarStyleDefault;
    
    return toolbar;
}

/// Dismisses the edit menu popover window if the cancel button is pressed.
/// @param popoverController the popover controller that needs to be dismissed.
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: EDIT_MENU_CANCELLED andObjectID:[self getSelectedViewIDNum]
                                                                andDetails:[self getMenuDetails]]];
    [self.popOverController dismissPopoverAnimated:YES];
}

/// Will save the changes made by the user related to the object they changed.
-(void) saveChanges
{
    UIView* view = [[self.popOverController contentViewController] view];
    // Will iterate over all of the subviews in the popover controller.  (Should only be one)
    for(UIView* subview in view.subviews)
    {
        // Have to determine which type of object has been updated in order to know which method to call.
        // If a variable has been changed.
        if([subview isMemberOfClass:[VariableEditMenuView class]])
        {
            VariableEditMenuView* varView = (VariableEditMenuView*)subview;
            [varView updateVariable];
        }
        // If a loop has been changed.
        else if([subview isMemberOfClass:[LoopEditMenuView class]])
        {
            LoopEditMenuView* loopView = (LoopEditMenuView*)subview;
            [loopView updateLoop];
        }
        // If a link has been changed.
        else if([subview isMemberOfClass:[CausalLinkEditMenuView class]])
        {
            CausalLinkEditMenuView* linkView = (CausalLinkEditMenuView*)subview;
            [linkView updateCausalLink];
        }
    }
    
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: EDIT_MENU_SAVED andObjectID:[self getSelectedViewIDNum]
                                                                andDetails:[self getMenuDetails]]];
    
    // Dismiss the popover window.
    [self.popOverController dismissPopoverAnimated:YES];
}

/// Handles the action of the response from the alertviews which include deleting, creating an image and creating a new model.
/// @param alertView the alert that has registered an action.
/// @param index the index of the button selected.
-(void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(int) index
{
    if(alertView.tag == DELETE_ALERT)
    {
        // Dismisses the alert with no changes.
        if(index == NO)
        {
            [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: DELETE_WARNING_DISMISSED
                                                                       andObjectID:[self getSelectedViewIDNum]
                                                                        andDetails:[self getMenuDetails]]];
            [alertView dismissWithClickedButtonIndex:index animated:YES];
        }
    
        // Will delete the object based on which type of object it is.
        else if (index == YES)
        {
            if([self.selectedView isKindOfClass:[VariableView class]])
            {
                int idNum = [[Model sharedModel] deleteVariable:self.selectedView];
                [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: VARIABLE_DELETED andObjectID:idNum]];
            }
            else if([self.selectedView isKindOfClass:[LoopView class]])
            {
                int idNum = [[Model sharedModel] deleteLoop:self.selectedView];
                [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: LOOP_DELETED andObjectID:idNum]];
            }
            else if ([self.selectedView isKindOfClass:[CausalLinkView class]])
            {
                int idNum = [[Model sharedModel] deleteCausalLink:self.selectedView];
                [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: CAUSAL_LINK_DELETED andObjectID:idNum]];
            }
        }
    }
    // Handling alertview when the image of the model was saved.
    else if(alertView.tag == IMAGE_SAVE_ALERT)
    {
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: CONFIRM_IMAGE_SAVED]];
        [alertView dismissWithClickedButtonIndex:index animated:YES];
    }
    // Handling alertview when the image of the model was not saved.
    else if(alertView.tag == IMAGE_NOSAVE_ALERT)
    {
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: CONFIRM_IMAGE_NOT_SAVED]];
        [alertView dismissWithClickedButtonIndex:index animated:YES];
    }
    // Handling alertview when the user selects to create a new model.
    else if(alertView.tag == NEW_MODEL_ALERT)
    {
        if(index == NO)
        {
            [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: NEW_MODEL_WARNING_DISMISSED]];
            [alertView dismissWithClickedButtonIndex:index animated:YES];
        }
        else
        {
            [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: NEW_MODEL]];
            [[Model sharedModel] clearModel];
            [[[Model sharedModel]getViewControllerView] setNeedsDisplay];
            self.title = DEFAULT_TITLE;
        }
    }
    else if(alertView.tag == INVALID_FILE_ALERT)
    {
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: CONFIRM_INVALID_FILE]];
        [alertView dismissWithClickedButtonIndex:index animated:YES];
    }
}

/// Displays an alert message once a user has selected to delete an object.  This message will appear to confirm that user did indeed mean to delete the object.
/// @param sender the view that made the call to display the alert.
- (void) showDeleteAlert: (UIView*) sender
{
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: DELETE_WARNING
                                                               andObjectID:[self getSelectedViewIDNum]
                                                                andDetails:[self getMenuDetails]]];
    
//    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: DELETE_WARNING]];
    UIAlertView*  alert = [[UIAlertView alloc] initWithTitle:TITLE_WARNING
                                                     message:DELETE_OBJ_WARNING
                                                    delegate: self
                                           cancelButtonTitle: TITLE_NO
                                           otherButtonTitles: TITLE_YES, nil];
    
    alert.tag = DELETE_ALERT;
    [alert show];
}

/// Given the selected view, it will return the associated id number for the object associated with that view.
/// @return the id number of the selected view's parent.
-(int) getSelectedViewIDNum
{
    int idNum = 0;
    if([self.selectedView isKindOfClass:[VariableView class]])
    {
        Variable* var = (Variable*)[(VariableView*)self.selectedView parent];
        idNum = var.idNum;
    }
    else if([self.selectedView isKindOfClass:[LoopView class]])
    {
        Loop* loop = (Loop*)[(LoopView*)self.selectedView parent];
        idNum = loop.idNum;
    }
    else if ([self.selectedView isKindOfClass:[CausalLinkView class]])
    {
        CausalLink* link = (CausalLink*)[(CausalLinkView*)self.selectedView parent];
        idNum = link.idNum;
    }
    
    return idNum;
}
@end
