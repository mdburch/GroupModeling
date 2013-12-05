//
//  SideMenuViewController.m
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

#import "Constants.h"
#import "EventLogger.h"
#import "SideMenuViewController.h"

@implementation SideMenuViewController

const int HELP_INDEX = 1;
/// Gets the menu container view controller.
/// @return the menu container view controller.
- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.parentViewController;
}

/// Initializes the view controller.
/// @param style the style of the view controller.
/// @return an id of the newly created view controller.
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self loadDatabase];
    }
    return self;
}

/// Loads the menu items 
- (void) loadDatabase {
    menuOptions = [[NSMutableArray alloc] initWithObjects:@"Model", @"Help",nil];
}

#pragma mark -
#pragma mark - UITableViewDataSource
/// Returns the title of the section header for the table.
/// @param tableView the reference table view.
/// @param section the integer representing the section.
/// @return a string values to set for the header title.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Menu"];
}

/// Returns the number of sections in the table view.
/// @param tableView the reference table view.
/// @return the number of the sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/// Returns the number of rows in a section in the table view.
/// @param tableView the reference table view.
/// @param section the current section of the table view.
/// @return the number of the sections in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [menuOptions count];
}

/// Sets the label text of the cell based on what is contained in the database.
/// @param tableView the reference table view.
/// @param indexPath the index path that contains where in the list you are.
/// @return the newly created/reused cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [menuOptions objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate
/// Will update the view that is showing when a new menu option is selected.
/// @param tableView the reference table view.
/// @param indexPath the index path that contains where in the list you are.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == HELP_INDEX)
        [self.menuContainerViewController openHelpSection];
    else
        [self.menuContainerViewController returnToRoot];

    // Log that the menu will close as well.
    [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID: MENU_CLOSED]];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

@end
