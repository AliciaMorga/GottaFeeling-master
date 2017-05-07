//
//  PurchaseViewController.m
//  GottaFeeling
//
//  Created by Denis on 31/12/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import "GottaFeelingAppDelegate.h"
#import "PurchaseViewController.h"


@implementation PurchaseViewController

- (IBAction)purchaseReports {
    [(GottaFeelingAppDelegate*)[[UIApplication sharedApplication] delegate] requestUpgradeProductReports];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
