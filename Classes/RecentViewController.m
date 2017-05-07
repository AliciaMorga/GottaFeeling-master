//
//  RecentViewController.m
//  GottaFeeling
//
//  Created by Denis on 30/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import "Flurry.h"
#import "GottaFeelingAppDelegate.h"
#import "RecentViewController.h"
#import "RecordViewController.h"
#import "Feeling.h"
#import "FeelingInfo.h"

@implementation RecentViewController
@synthesize recentFeelings;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.recentFeelings = nil;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.recentFeelings count];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *feeling = [self.recentFeelings objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSLocalizedString([feeling valueForKey:@"feeling"], nil) capitalizedString];
    FeelingInfo *feelingInfo = [FeelingInfo feelingForName:[feeling valueForKey:@"category"]];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Swatch%@.png", feelingInfo.assetName]];
    
    NSString *who   = NSLocalizedString([feeling valueForKey:@"who"], nil);
    NSString *where = NSLocalizedString([feeling valueForKey:@"where"], nil);
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@@%@", who, where];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"HistoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    // Retrieve the selected feeling
    NSDictionary *recentFeeling = [self.recentFeelings objectAtIndex:indexPath.row];
    
    // First, save the feeling (create a duplicate of the selected recent feeling)
    // Create a new Message object and add it to the Managed Object Context. 
    NSManagedObjectContext *managedObjectContext = [GottaFeelingAppDelegate managedObjectContext];
    Feeling *feeling = (Feeling *)[NSEntityDescription insertNewObjectForEntityForName:@"Feeling" inManagedObjectContext:managedObjectContext];
    feeling.category = [recentFeeling valueForKey:@"category"];
    feeling.feeling = [recentFeeling valueForKey:@"feeling"];
    feeling.who = [recentFeeling valueForKey:@"who"];
    feeling.where = [recentFeeling valueForKey:@"where"];
    feeling.timeStamp = [NSDate date];
    int imageChoice = (arc4random() & 2) + 1;
    feeling.image = [NSString stringWithFormat:@"%@%d", feeling.category, imageChoice];
    CLLocationCoordinate2D loc = [GottaFeelingAppDelegate instance].myLocation;
    feeling.latitude = [NSNumber numberWithDouble:loc.latitude];
    feeling.longitude = [NSNumber numberWithDouble:loc.longitude];
    
    NSError *error = nil; 
    if (![managedObjectContext save:&error]) {
        NSLog(@"Save error: %@, %@", error, [error userInfo]);
        for (id errorObject in [[error userInfo] valueForKey:NSDetailedErrorsKey]) {
            NSLog(@"Detailed error: %@", errorObject);
        }
        error = nil;
        // TODO: Alert user?
    }
    
    // Log new feeling to Flurry (event type is category, feeling parameter is specific feeling)
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:feeling.feeling, @"feeling", nil];
    [Flurry logEvent:feeling.category withParameters:dict];
    
    [[GottaFeelingAppDelegate instance] updateReminders];

    // Then, send the user to the detail view
    RecordViewController *detailViewController = [[RecordViewController alloc] initWithNibName:@"RecordViewController" bundle:nil];
    detailViewController.feeling = feeling;
    detailViewController.allowDeletion = YES;
    detailViewController.allowNewFeeling = YES;
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (NSArray *)recentFeelings {
    if (recentFeelings != nil)
        return recentFeelings;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feeling" inManagedObjectContext:[GottaFeelingAppDelegate managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSPropertyDescription *categoryProp = [[entity propertiesByName] objectForKey:@"category"];
    NSPropertyDescription *feelingProp = [[entity propertiesByName] objectForKey:@"feeling"];
    NSPropertyDescription *whoProp = [[entity propertiesByName] objectForKey:@"who"];
    NSPropertyDescription *whereProp = [[entity propertiesByName] objectForKey:@"where"];
    [fetchRequest setResultType:NSDictionaryResultType];
    NSArray *properties = [NSArray arrayWithObjects:categoryProp, feelingProp, whoProp, whereProp, nil];
    [fetchRequest setPropertiesToFetch:properties];
    [fetchRequest setReturnsDistinctResults:YES];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO] autorelease];
    NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
	NSError *error = nil;
    recentFeelings = [[[GottaFeelingAppDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error] retain];
    return recentFeelings;
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

