//
//  FeelingsViewController.m
//  GottaFeeling
//
//  Created by Denis on 01/11/2010.
//  Copyright (c) 2010 Peer Assembly. All rights reserved.
//

#import "GottaFeelingAppDelegate.h"
#import "WordsViewController.h"
#import "ExtrasViewController.h"
#import "Constants.h"

extern NSString *navBackground;

@implementation WordsViewController
@synthesize feelingName, feelingDisplayName, tree;

#pragma mark -
#pragma mark Custom Cells

- (UITableViewCell *)tree:(PATree *)_tree createCellForIdentifier:(NSString *)cellIdentifier {
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(LABEL_XOFFSET, 0, 320-(LABEL_XOFFSET+ICON_WIDTH), CELL_HEIGHT)] autorelease];
    label.tag = TAG_LABEL;
    label.textAlignment = UITextAlignmentLeft;
    label.font = [UIFont fontWithName:LABEL_FONT size:LABEL_FONTSIZE];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:label];
    
    return cell;
}

- (void)tree:(PATree *)_tree configureCell:(UITableViewCell *)cell {
    UILabel *label = (UILabel *) [cell.contentView viewWithTag:TAG_LABEL];
    label.text = [NSLocalizedString([_tree valueForKey:KEY_TITLE], nil) capitalizedString];
    cell.textLabel.text = nil;    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}


#pragma mark -
#pragma mark View lifecycle

- (UIView *)createTableHeader {
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, HEADER_HEIGHT)] autorelease];
    view.backgroundColor = [UIColor colorWithRed:0.91 green:0.93 blue:0.93 alpha:1.0];
    welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_XOFFSET, LABEL_YOFFSET, 320-(LABEL_XOFFSET*2), HEADER_HEIGHT-LABEL_YOFFSET)];
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

    tree.delegate = self;
    self.tableView.dataSource = tree;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.tableView.tableHeaderView = [self createTableHeader];
    welcomeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"What level of %@ do you feel?", @"Text asking to clarify the level of a particular feeling. e.g. What level of Angry do you feel"), 
                         NSLocalizedString(feelingDisplayName, nil)];
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

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *feelingWord = [[tree nodeAtIndexPath:indexPath] valueForKey:KEY_TITLE];
    
    ExtrasViewController *extrasViewController = [[ExtrasViewController alloc] initWithNibName:@"ExtrasViewController" bundle:nil];
    extrasViewController.feelingName = feelingName;
    extrasViewController.feelingWord = feelingWord;
    [self.navigationController pushViewController:extrasViewController animated:YES];
    [extrasViewController release];
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    [tree release];
    tree = nil;
}

- (void)dealloc {
    [feelingDisplayName release];
    [feelingName release];
    [welcomeLabel release];
    [tree release];
    [super dealloc];
}


@end

