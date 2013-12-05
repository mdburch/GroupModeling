//
//  HelpSectionViewController.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/18/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//
///@note This view controller is currently not being used.
#import "MFSideMenuContainerViewController.h"
#import <UIKit/UIKit.h>

/// A Table view controller used to handle the help section.
@interface HelpSectionViewController : UITableViewController
{
    @private
        NSMutableArray* sectionTitles;
        NSMutableArray* questions;
}

-(MFSideMenuContainerViewController *)menuContainerViewController;
-(void) setupMenuBarButtonItems;
-(UIBarButtonItem *) leftMenuBarButtonItem;
-(void) leftSideMenuButtonPressed:(id)sender;
@end
