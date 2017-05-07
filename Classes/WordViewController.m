//
//  WordViewController.m
//  GottaFeeling
//
//  Created by Darragh Hennessy on 04/11/2010.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "WordViewController.h"
#import "RecordViewController.h"


@implementation WordViewController
@synthesize tree;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [tree valueForKey:KEY_TITLE];
    tree.delegate = self;
    self.tableView.dataSource = tree;
}


#pragma mark -
#pragma mark Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	 RecordViewController *detailViewController = [[RecordViewController alloc] initWithNibName:@"RecordViewController" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     PATree *node = [tree nodeAtIndexPath:indexPath];
     detailViewController.feeling = [node valueForKey:KEY_TITLE];
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

