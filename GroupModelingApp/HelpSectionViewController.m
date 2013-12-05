//
//  HelpSectionViewController.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/18/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//
///@note this view controller is currently not being used.
#import "Constants.h"
#import "EventLogger.h"
#import "DetailedHelpSectionViewController.h"
#import "HelpSectionViewController.h"
#import "MFSideMenuContainerViewController.h"

@interface HelpSectionViewController ()

@end

@implementation HelpSectionViewController 

/// Initializes the view controller.
/// @param style the style of the view controller.
/// @return an id of the newly created view controller.
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self loadDatabase];
    }
    return self;
}

/// Loads the questions and answers
- (void) loadDatabase {
    questions = [[NSMutableArray alloc] initWithObjects:@"What is system dymaics?", @"How do I add a variable?", @"How do I add a causal link?", @"How do I add a loop?", @"How do I save my changes?",nil];
}

//================================================================================================================================
// Methods that handles creating the nav controller menus.
//================================================================================================================================

/// Called when the view finishes loading.
/// Will set the default shown view and other attrubutes.
-(void) viewDidLoad {
    [super viewDidLoad];
    if(!self.title) self.title = @"Help!";
    [self setupMenuBarButtonItems];
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
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

/// Creates the left menu bar button item.  This item will be responsible for opening the menu.
/// @return the left menu bar button item.
-(UIBarButtonItem *) leftMenuBarButtonItem
{
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon.png"]
            style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
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

/// Called when there is low memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/// Returns the number of sections in the table view.
/// @param tableView the reference table view.
/// @return the number of the sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

/// Returns the number of rows in a section in the table view.
/// @param tableView the reference table view.
/// @param section the current section of the table view.
/// @return the number of the sections in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [questions count];
}

/// Sets the label text of the cell based on what is contained in the database.
/// @param tableView the reference table view.
/// @param indexPath the index path that contains where in the list you are.
/// @return the newly created/reused cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Make the cell with the chevron for more information.
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    // Set up the text title.
	cell.textLabel.text = [questions objectAtIndex:indexPath.row];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"General Help";
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

/// Handles the action to be completed when an item in the table view has been selected.
/// @param tableView the reference table view.
/// @param indexPath the index path that contains where in the list you are.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Make it in did select row");
//	NSString *name = [questions objectAtIndex:indexPath.row];
//    NSString *title = [NSString stringWithFormat:@"You selected %@.", name];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"Now what?" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//    [alertView show];
//    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DetailedHelpSectionViewController* details = [[DetailedHelpSectionViewController alloc]init];
    [self.navigationController pushViewController:details animated:YES];
}
//
//- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor greenColor];
//    return YES;
//}
@end
