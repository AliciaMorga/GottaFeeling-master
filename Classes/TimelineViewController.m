//
//  TimelineViewController.m
//  GottaFeeling
//
//  Created by Denis on 30/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import "GottaFeelingAppDelegate.h"
#import "TimelineViewController.h"
#import "Feeling.h"
#import "FeelingInfo.h"
#import "NSDate+Misc.h"
#import "Constants.h"

#define PICKER_DATE_TYPE_DAYS       30 // Set of 4 Days
#define PICKER_DATE_TYPE_WEEKS      31 // Set of 4 Weeks
#define PICKER_DATE_TYPE_MONTHS     32 // Set of 4 Months

#define DAYWIDTH_MODE_DAYS          40
#define DAYWIDTH_MODE_WEEKS         20
#define DAYWIDTH_MODE_MONTHS        10

@implementation TimelineViewController
@synthesize chartView, legendView, scrollView, tabView;

- (void)loadDataForView {
    chartView.dayWidth = DAYWIDTH_MODE_DAYS;
    chartView.labelMode = LABEL_MODE_DAYS;
    NSManagedObjectContext *managedObjectContext = [GottaFeelingAppDelegate managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:Feeling.entityName inManagedObjectContext:managedObjectContext]];
    
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortByDate]];
    [sortByDate release];

    NSError *error = nil;
    NSArray *feelings = [managedObjectContext executeFetchRequest:request error:&error];
    
    int cFeelings = [FeelingInfo count];
    chartView.lastDay = [NSDate dateWithoutTime];
    chartView.firstDay = [chartView.lastDay dateByAddingDays:-40];
    NSDate *currentDay = nil;
    NSMutableArray *counts = [NSMutableArray arrayWithCapacity:[FeelingInfo count]];
    for (int i=0;i<cFeelings;i++) {
        [counts addObject:[NSNumber numberWithInt:0]];
    }
    for (Feeling *feeling in feelings) {
        NSDate *day = [feeling.timeStamp dateAsDateWithoutTime];
        NSLog(@"Processing %@ - %@", feeling.timeStamp, feeling.category);
        if (currentDay == nil) {
            currentDay = day;
            chartView.firstDay = [chartView.firstDay earlierDate:day];
        }
        if (![currentDay isEqualToDate:day]) {
            [chartView setValues:counts forDay:currentDay];
            currentDay = day;
            for (int i=0;i<cFeelings;i++) {
                [counts replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
            }
        }
        for (int i=0;i<cFeelings;i++) {
            FeelingInfo *info = [[FeelingInfo allFeelings] objectAtIndex:i];
            if ([feeling.category isEqualToString:info.name]) {
                NSNumber *count = [counts objectAtIndex:i];
                count = [NSNumber numberWithInt:[count intValue]+1];
                [counts replaceObjectAtIndex:i withObject:count];
                break;
            }
        }
    }
    if (currentDay)
        [chartView setValues:counts forDay:currentDay];
}

- (void)updateScrollView {
    CGFloat timelineWidth = chartView.dayWidth * ([chartView.firstDay differenceInDaysTo:chartView.lastDay]+1);
    chartView.frame = CGRectMake(0, 0, timelineWidth, scrollView.frame.size.height);
    scrollView.contentSize = chartView.frame.size;
    scrollView.contentOffset = CGPointMake(chartView.frame.size.width-scrollView.frame.size.width, 0);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    tabView.baseMenuType = REPORT_MENU_ITEM_TIMELINE;
    tabView.selectedItem = PICKER_DATE_TYPE_WEEKS;
    tabView.tabTitles = [NSArray arrayWithObjects:NSLocalizedString(@"Days", @"Menu item indicating that the report will cover days"), NSLocalizedString(@"Weeks", @"Menu item indicating that the report will cover weeks"), NSLocalizedString(@"Months", @"Menu item indicating that the report will cover Months"), nil];
    tabView.delegate = self;
    
    for (int i=0;i<[[FeelingInfo allFeelings] count];i++) {
        FeelingInfo *feeling = [[FeelingInfo allFeelings] objectAtIndex:i];
        CGFloat x = 10 + (i % 3) * 100;
        CGFloat y = 6 + (i / 3) * 21;
        UIView *swatch = [[[UIView alloc] initWithFrame:CGRectMake(x, y+2, 12, 12)] autorelease];
        swatch.backgroundColor = feeling.color;
        [legendView addSubview:swatch];
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(x+16, y, 90, 16)] autorelease];
        label.text = NSLocalizedString(feeling.name, nil);
        label.font = [UIFont boldSystemFontOfSize:11];
        [legendView addSubview:label];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadDataForView];
    [self updateScrollView];
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

// TabViewDelegate

- (void)menuItemChanged:(NSInteger)previousItem newItem:(NSInteger)newItem {
    switch (newItem) {
        case PICKER_DATE_TYPE_DAYS:
            chartView.labelMode = LABEL_MODE_DAYS;
            chartView.dayWidth = DAYWIDTH_MODE_DAYS;
            break;
        case PICKER_DATE_TYPE_WEEKS:
            chartView.labelMode = LABEL_MODE_WEEKS;
            chartView.dayWidth = DAYWIDTH_MODE_WEEKS;
            break;
        case PICKER_DATE_TYPE_MONTHS:
            chartView.labelMode = LABEL_MODE_MONTHS;
            chartView.dayWidth = DAYWIDTH_MODE_MONTHS;
            break;
    }
    [self updateScrollView];
}

- (void)dealloc {
    [chartView release];
    [legendView dealloc];
    [super dealloc];
}


@end
