//
//  ExtrasViewController.m
//  GottaFeeling
//
//  Created by Sheldon Conaty on 26/04/2011.
//  Copyright 2011 Peer Assembly. All rights reserved.
//

#import "GottaFeelingAppDelegate.h"
#import "ExtrasViewController.h"
#import "RecordViewController.h"
#import "Feeling.h"
#import "FeelingInfo.h"
#import "Flurry.h"
#import "Constants.h"
#import "ReviewRequest.h"
#import "IconRegistry.h"

#define PANEL_HEIGHT        88
#define BUTTON_WIDTH        204
#define BUTTON_HEIGHT       44

#define SECTION_WHO         0
#define SECTION_WHERE       1
#define SECTION_NOTES       2
#define SECTION_REGISTER    3
#define NUM_SECTIONS        3

#define TAG_IMAGE           1

static NSArray *whoKeys = [NSArray arrayWithObjects:
                           @"alone",
                           @"friends",
                           @"family",
                           @"spouse",
                           @"colleagues",
                           @"other",
                           nil];
static NSArray *whereKeys = [NSArray arrayWithObjects:
                      @"home",
                      @"work",
                      @"gym",
                      @"restaurant",
                      @"event",
                      @"friend’s house",
                      @"outdoors",
                      @"store",
                      @"commuting",
                      @"elsewhere",
                      nil];

extern NSString *navBackground;


@implementation ExtrasViewController

@synthesize feelingWord, feelingName, feelingWho, feelingWhere, feelingNote;

#pragma mark - Utility methods

- (void)recordFeeling {
    // First, save the feeling
    // Create a new Message object and add it to the Managed Object Context. 
    NSManagedObjectContext *managedObjectContext = [GottaFeelingAppDelegate managedObjectContext];
    Feeling *feeling = (Feeling *)[NSEntityDescription insertNewObjectForEntityForName:@"Feeling" inManagedObjectContext:managedObjectContext];
    feeling.category = feelingName;
    feeling.feeling = feelingWord;
    feeling.who = feelingWho;
    feeling.where = feelingWhere;
    feeling.notes = feelingNote;
    feeling.timeStamp = [NSDate date];
    int imageChoice = ((arc4random()/100) % 3) + 1;
    FeelingInfo *feelingInfo = [FeelingInfo feelingForName:feelingName];
    feeling.image = [NSString stringWithFormat:@"%@%d", feelingInfo.assetName, imageChoice];
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
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:feelingWord, @"feeling", feeling.who, @"with", feeling.where, @"where", nil];
    [Flurry logEvent:feelingName withParameters:dict];
    
    [[GottaFeelingAppDelegate instance] updateReminders];
    
    // Then, send the user to the detail view
    RecordViewController *detailViewController = [[RecordViewController alloc] initWithNibName:@"RecordViewController" bundle:nil];
    detailViewController.feeling = feeling;
    detailViewController.allowDeletion = YES;
    detailViewController.allowNewFeeling = YES;
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
    if (ReviewRequest::ShouldAskForReview())
        ReviewRequest::AskForReview();    
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUM_SECTIONS;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    BOOL isSpanish = [language hasPrefix:@"es"];
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:TAG_IMAGE];
    switch (indexPath.section) {
        case SECTION_WHO: {
            cell.textLabel.text = [NSLocalizedString(feelingWho, nil) capitalizedString];
            cell.imageView.image = [IconRegistry iconForKey:feelingWho];
            break;
        }
        case SECTION_WHERE: {
            cell.textLabel.text = [NSLocalizedString(feelingWhere, nil) capitalizedString];
            cell.imageView.image = [IconRegistry iconForKey:feelingWhere];
            break;
        }
        case SECTION_NOTES: {
            cell.textLabel.text = [NSLocalizedString(@"Add a Note", nil) capitalizedString];
            cell.imageView.image = [UIImage imageNamed:@"iconNote"];
            break;
        }
        case SECTION_REGISTER: {
            imageView.image = [UIImage imageNamed:isSpanish ? @"buttonRegisterNewSP" : @"buttonRegisterNew"];
            cell.textLabel.text = @"";
            cell.imageView.image = nil;
            break;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SECTION_WHO:
            return NSLocalizedString(@"Who are you with?", nil);
        case SECTION_WHERE:
            return NSLocalizedString(@"Where are you?", nil);
        case SECTION_NOTES:
            return NSLocalizedString(@"Add a Note?", nil);
        default:
            return @"";
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = cellIdentifier = @"ExtraCellForward";
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        
        if ([cellIdentifier isEqualToString:@"ExtraCellForward"])
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.textAlignment = UITextAlignmentLeft;
        cell.textLabel.font = [UIFont fontWithName:LABEL_FONT size:LABEL_FONTSIZE];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 265, 23)];
        imageView.tag = TAG_IMAGE;
        [cell.contentView addSubview:imageView];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == SECTION_NOTES) {
        return registerPanel;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == SECTION_NOTES) {
        return PANEL_HEIGHT;
    }
    return nil;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SECTION_WHO: {
            [self.navigationController pushViewController:whoSelector animated:YES];
            break;
        }
        case SECTION_WHERE: {
            [self.navigationController pushViewController:whereSelector animated:YES];
            break;
        }
        case SECTION_NOTES: {
            NoteEditorViewController *noteEditor = [[[NoteEditorViewController alloc] init] autorelease];
            noteEditor.delegate = self;
            noteEditor.text = feelingNote;
            UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:noteEditor] autorelease];
            [self presentModalViewController:navController animated:YES];
            break;
        }
        case SECTION_REGISTER: {
            [self recordFeeling];
            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

#pragma mark - NoteEditorViewControllerDelegate

- (void)noteEditorDidCancel:(NoteEditorViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)noteEditorDidDone:(NoteEditorViewController *)controller {
    [feelingNote release];
    feelingNote = [controller.text copy];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    BOOL isSpanish = [language hasPrefix:@"es"];

    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    self.feelingWho = DEFAULT_WHO;
    self.feelingWhere = DEFAULT_WHERE;
    
    // Initialize 'who' selector
    
    NSMutableArray *whoLabels = [NSMutableArray arrayWithCapacity:[whoKeys count]];
    for (NSString *key in whoKeys)
        [whoLabels addObject:[NSLocalizedString(key, nil) capitalizedString]];
    
    whoSelector = [[SelectorTableController alloc] initWithStyle:UITableViewStylePlain labels:whoLabels keys:whoKeys activeKey:DEFAULT_WHO prompt:nil target:self action:@selector(whoSelected:)];

    // Initialize 'where' selector
    
    NSMutableArray *whereLabels = [NSMutableArray arrayWithCapacity:[whereKeys count]];
    for (NSString *key in whereKeys)
        [whereLabels addObject:[NSLocalizedString(key, nil) capitalizedString]];

    whereSelector = [[SelectorTableController alloc] initWithStyle:UITableViewStylePlain labels:whereLabels keys:whereKeys activeKey:DEFAULT_WHERE prompt:nil target:self action:@selector(whereSelected:)];
    
    registerPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, PANEL_HEIGHT)];
    registerButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    NSString *buttonName = isSpanish ? @"buttonRegisterNewSP" : @"buttonRegisterNew";
    [registerButton setImage:[UIImage imageNamed:buttonName] forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(recordFeeling) forControlEvents:UIControlEventTouchUpInside];
    registerButton.frame = CGRectMake((320-BUTTON_WIDTH)/2, (PANEL_HEIGHT-BUTTON_HEIGHT)/2, BUTTON_WIDTH, BUTTON_HEIGHT);
    [registerPanel addSubview:registerButton];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [whoSelector release];
    [whereSelector release];
    [registerButton release];
    registerButton = nil;
    [registerPanel release];
    registerPanel = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *navImage = [NSString stringWithFormat:@"Nav%@.png", feelingName];
    if ([feelingName isEqualToString:@"Guilt/Shame"])
        navImage = [NSString stringWithFormat:@"NavGuilt.png"];
    navBackground = [navImage retain];
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:navBackground] forBarMetrics: UIBarMetricsDefault];
    } else {
        [self.navigationController.navigationBar setNeedsDisplay];
    }
}


#pragma mark - Action methods

- (void)whoSelected:(NSString *)key {
    self.feelingWho = key;
    [self.tableView reloadData];
}

- (void)whereSelected:(NSString *)key {
    self.feelingWhere = key;
    [self.tableView reloadData];
}


#pragma mark - Memory management methods

- (void)dealloc {
    self.feelingName = nil;
    self.feelingWord = nil;
    self.feelingWho = nil;
    self.feelingWhere = nil;
    self.feelingNote = nil;
    
    [super dealloc];
}

@end
