//
//  FeelingsViewController.m
//  GottaFeeling
//
//  Created by Denis on 01/11/2010.
//  Copyright (c) 2010 Peer Assembly. All rights reserved.
//

#import "GottaFeelingAppDelegate.h"
#import "FeelingsViewController.h"
#import "SettingsViewController.h"
#import "RecentViewController.h"
#import "WordsViewController.h"
#import "HintViewController.h"
#import "FeelingInfo.h"
#import "Constants.h"
#import "Feeling.h"
#import "ReviewRequest.h"

extern NSString *navBackground;

@implementation FeelingsViewController
@synthesize tree;

-(PATree*) getRandomFeeling:(PATree*)feelingTree {
    NSArray *feelings = [feelingTree children];
    if ([feelings count]>0) {
        int x = rand()%[feelings count];
        return [feelings objectAtIndex:x];
    }
    return nil;
}

-(NSDate*)getRandomDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];

    [dateComponents setDay:-rand()%250];      
    NSDate *date = [gregorian dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];      
    return date;
}

- (void)generateFeelings:(id)sender {

    NSManagedObjectContext *managedObjectContext = [GottaFeelingAppDelegate managedObjectContext];
    for (int i=0; i<100; i++) {
        PATree *category = [self getRandomFeeling:tree];
        if (category) {
            PATree *feeling = [self getRandomFeeling:category];                    
            if (feeling) { // Sometimes catches the 'My Most Recent Feelings'
                Feeling *newFeeling = (Feeling *)[NSEntityDescription insertNewObjectForEntityForName:@"Feeling" inManagedObjectContext:managedObjectContext];
                newFeeling.category = [category valueForKey:KEY_TITLE];
                newFeeling.feeling = [feeling valueForKey:KEY_TITLE];
                newFeeling.timeStamp = [self getRandomDate];

                CLLocationCoordinate2D loc = [GottaFeelingAppDelegate instance].myLocation;
                newFeeling.latitude = [NSNumber numberWithDouble:loc.latitude];
                newFeeling.longitude = [NSNumber numberWithDouble:loc.longitude];
                
                NSError *error = nil; 
                if (![managedObjectContext save:&error]) {
                    NSLog(@"Save error: %@, %@", error, [error userInfo]);
                    for (id errorObject in [[error userInfo] valueForKey:NSDetailedErrorsKey]) {
                        NSLog(@"Detailed error: %@", errorObject);
                    }
                    error = nil;
                }
            }
            NSLog(@"%@ - %@", [category valueForKey:KEY_TITLE], [feeling valueForKey:KEY_TITLE]);
        }
    }
}

#pragma mark -
#pragma mark Custom Cells

- (UITableViewCell *)tree:(PATree *)_tree createCellForIdentifier:(NSString *)cellIdentifier {
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_XOFFSET, 0, 320-(LABEL_XOFFSET+ICON_WIDTH), CELL_HEIGHT)];
    label.tag = TAG_LABEL;
    label.textAlignment = UITextAlignmentLeft;
    if ([[_tree valueForKey:KEY_STYLE] isEqualToString:STYLE_MAIN]) {
        label.font = [UIFont fontWithName:LABEL_FONT size:LABEL_FONTSIZE];
        label.textColor = [UIColor blackColor];
    } else {
        label.font = [UIFont fontWithName:RECENT_FONT size:RECENT_FONTSIZE];
        label.textColor = [UIColor colorWithRed:0.58 green:0.6 blue:0.6 alpha:1.0];
    }
    label.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:label];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(320-ICON_WIDTH, CELL_HEIGHT-ICON_HEIGHT, ICON_WIDTH, ICON_HEIGHT)];
    icon.tag = TAG_ICON;
    [cell.contentView addSubview:icon];
    
    return cell;
}

- (void)tree:(PATree *)_tree configureCell:(UITableViewCell *)cell {
    UILabel *label = (UILabel *) [cell.contentView viewWithTag:TAG_LABEL];
    label.text = NSLocalizedString([_tree valueForKey:KEY_TITLE], nil);
    cell.textLabel.text = nil;
    
    UIImageView *icon = (UIImageView *) [cell.contentView viewWithTag:TAG_ICON];
    NSString *assetName = [FeelingInfo feelingForName:[_tree valueForKey:KEY_TITLE]].assetName;
    icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"Swatch%@.png", assetName]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}


#pragma mark -
#pragma mark View lifecycle

- (BOOL)mapFields:(NSMutableDictionary *)dict {
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString *word = [dict valueForKey:@"Feeling"];
    word = [word stringByTrimmingCharactersInSet:charSet];
    [dict setValue:word forKey:KEY_TITLE];
    [dict setValue:STYLE_MAIN forKey:KEY_STYLE];

    return YES;
}

- (UIView *)createTableHeader {
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, HEADER_HEIGHT)] autorelease];
    view.backgroundColor = [UIColor colorWithRed:0.91 green:0.93 blue:0.93 alpha:1.0];
    welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_XOFFSET, LABEL_YOFFSET, 320-LABEL_XOFFSET, HEADER_HEIGHT-LABEL_YOFFSET)];
    welcomeLabel.backgroundColor = [UIColor clearColor];
    welcomeLabel.font = [UIFont fontWithName:HEADER_FONT size:HEADER_FONTSIZE];
    welcomeLabel.numberOfLines = 1;
    welcomeLabel.adjustsFontSizeToFitWidth = YES;
    welcomeLabel.lineBreakMode = UILineBreakModeWordWrap;
    [view addSubview:welcomeLabel];
    return view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tree = [[PATree alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Feelings" ofType:@"csv"];
    NSError *error = nil;
    [tree loadCSV:path error:&error target:self selector:@selector(mapFields:)];
    [tree removeLocalizedDuplicates];
    [tree groupBy:@"Category"];
    NSDictionary *recent = [NSDictionary dictionaryWithObjectsAndKeys:
                            NSLocalizedString(@"My Most Recent Feelings",@"Text to display above the list of 'My most recent feelings' a list of ~10 feelings"), KEY_TITLE,
                            STYLE_RECENT, KEY_STYLE,
                            nil];
    [tree addNode:recent];
    [self.navigationController.navigationBar setNeedsDisplay];
    tree.delegate = self;
    self.tableView.dataSource = tree;

    self.tableView.tableHeaderView = [self createTableHeader];
    NSString *name = [[NSUserDefaults standardUserDefaults] valueForKey:@"firstName"];
    if (name && [name length])
        welcomeLabel.text = [NSString stringWithFormat:STRING_HI_X_HOW_DO_YOU_FEEL, name];
    else
        welcomeLabel.text = STRING_HI_HOW_DO_YOU_FEEL;
    path = [[NSBundle mainBundle] pathForResource:@"welcome" ofType:@"caf"];
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundWelcome);
    
    if (ReviewRequest::ShouldAskForReviewAtLaunch())
        ReviewRequest::AskForReview();
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    navBackground = @"NavMain.png";
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:navBackground] forBarMetrics: UIBarMetricsDefault];
    } else {
        [self.navigationController.navigationBar setNeedsDisplay];
    }

    NSString *name = [[NSUserDefaults standardUserDefaults] valueForKey:@"firstName"];
    if (name && [name length])
        welcomeLabel.text = [NSString stringWithFormat:STRING_HI_X_HOW_DO_YOU_FEEL, name];
    else
        welcomeLabel.text = STRING_HI_HOW_DO_YOU_FEEL;
    
    BOOL playSounds = [[NSUserDefaults standardUserDefaults] boolForKey:@"playSounds"];
    if (playSounds)
        AudioServicesPlaySystemSound(soundWelcome);
}

- (void)viewDidAppear:(BOOL)animated {
    if ([HintViewController shouldDisplayHint]) {
        HintViewController *hintViewController = [[HintViewController alloc] initWithNibName:@"HintViewController" bundle:nil];
        [self presentModalViewController:hintViewController animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)showSettings {
    NSString *plist = [[NSBundle mainBundle] pathForResource:@"Root" ofType:@"plist"];
    SettingsViewController *settingsviewcontroller = [[SettingsViewController alloc] initWithConfigFile:plist];
    [self.navigationController pushViewController:settingsviewcontroller animated:YES];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PATree *node = [tree nodeAtIndexPath:indexPath];
    
    NSString *style = [node valueForKey:KEY_STYLE];
    if ([style isEqualToString:STYLE_RECENT]) {
        RecentViewController *detailViewController = [[RecentViewController alloc] initWithNibName:@"RecentViewController" bundle:nil];
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    } else {
        WordsViewController *detailViewController = [[WordsViewController alloc] initWithNibName:@"WordsViewController" bundle:nil];
        PATree *node = [tree nodeAtIndexPath:indexPath];
        detailViewController.tree = node;
        detailViewController.feelingDisplayName = [node valueForKey:KEY_TITLE];
        detailViewController.feelingName = [FeelingInfo feelingForName:[node valueForKey:KEY_TITLE]].name;
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    [tree release];
    tree = nil;
}

- (void)dealloc {
    AudioServicesDisposeSystemSoundID(soundWelcome);
    [welcomeLabel release];
    [tree release];
    [super dealloc];
}


@end

