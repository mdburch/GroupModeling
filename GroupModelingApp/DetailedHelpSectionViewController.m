//
//  DetailedHelpSectionViewController.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 8/4/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//
///@note this view controller is currently not being used.
#import "DetailedHelpSectionViewController.h"

@interface DetailedHelpSectionViewController ()

@end

@implementation DetailedHelpSectionViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
//        UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(backPressed:)];
//        [self.navigationItem.backBarButtonItem setAction:@selector(backPressed:)];
//        [self.navigationItem.backBarButtonItem setEnabled:YES];
//        self.navigationItem.backBarButtonItem.title =@"Title";
//                self.navigationController.navigationItem.backBarButtonItem.enabled = YES;
//        self.navigationController.navigationItem.leftBarButtonItem = self.navigationController.navigationItem.backBarButtonItem;
//        NSLog(@"back button enabled: %d",    self.navigationItem.backBarButtonItem.enabled);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set title
    self.navigationItem.title = @"Help";
//    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"Part 1"
//                                                                  style:UIBarButtonItemStyleBordered
//                                                                 target:self
//                                                                 action:@selector(backPressed:)];
//    self.navigationItem.leftBarButtonItem = barBtnItem;
    // add label
    UILabel* label = [[UILabel alloc]init];
    [label setText: @"More details about help"];
    label.frame = CGRectMake(40,100, 300, 40);
    [self.view addSubview:label];
}

-(void)backPressed: (id)sender
{
    NSLog(@"make it in backPressed");
    [self.navigationController popViewControllerAnimated: YES]; // or popToRoot... if required.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
