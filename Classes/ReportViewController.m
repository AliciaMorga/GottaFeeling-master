//
//  ReportViewController.m
//  GottaFeeling
//
//  Created by Liam Hennessy on 23/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import "GottaFeelingAppDelegate.h"
#import <MessageUI/MessageUI.h>
#import "ReportViewController.h"
#import "PurchaseViewController.h"
#import "Constants.h"

#define TAB_HEIGHT      30
#define REPORT_HEIGHT   342
#define IMMEDIATE_PURCHASE  1

extern NSString *navBackground;                         // Managed by UINavigationBar+CustomBackground.m


@interface TransparentToolbar : UIToolbar
@end

@implementation TransparentToolbar

- (void)drawRect:(CGRect)rect {
}

- (void) applyTranslucentBackground {
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	self.translucent = YES;
}

- (id) init {
	self = [super init];
	[self applyTranslucentBackground];
	return self;
}

- (id) initWithFrame:(CGRect) frame {
	self = [super initWithFrame:frame];
	[self applyTranslucentBackground];
	return self;
}

@end


@interface ReportViewController (hidden)

-(void) selectMenuItem:(int) menuItem;
-(void) switchInView:(UIViewController*)newVC andOutView:(UIViewController*)oldVC;

@end


@implementation ReportViewController

@synthesize selectedMenu, reportView, historyViewController, chartViewController, timeChartViewController;

-(ChartViewController*) chartViewController {
    if (!chartViewController) {
        chartViewController = [[ChartViewController alloc] initWithNibName:@"ChartViewController" bundle:nil];
        chartViewController.view.frame = CGRectMake(0, TAB_HEIGHT, 320, REPORT_HEIGHT);
    }
    return chartViewController;
}

-(TimelineViewController*) timeChartViewController {
    if (!timeChartViewController) {
        timeChartViewController = [[TimelineViewController alloc] initWithNibName:@"TimelineViewController" bundle:nil];
        timeChartViewController.view.frame = CGRectMake(0, TAB_HEIGHT, 320, REPORT_HEIGHT);
    }
    return timeChartViewController;
}

-(HistoryViewController*) historyViewController {
    if (!historyViewController) {
        historyViewController = [[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil];
        historyViewController.view.frame = CGRectMake(0, TAB_HEIGHT, 320, REPORT_HEIGHT);
        NSLog(@"historyViewController frame: %@", NSStringFromCGRect(self.historyViewController.view.frame));
        historyViewController.parentViewController = self;
    }
    return historyViewController;
}

-(MapViewController*) mapViewController {
    if (!mapViewController) {
        mapViewController = [[MapViewController alloc] init];
        mapViewController.view.frame = CGRectMake(0, TAB_HEIGHT, 320, REPORT_HEIGHT);
    }
    return mapViewController;
}

-(void) selectMenuItem:(int) menuItem {
    UIViewController *newViewController = nil;
    
    switch (menuItem) {
        case REPORT_MENU_ITEM_CHART:
            newViewController = self.chartViewController;
            self.navigationItem.leftBarButtonItem = nil;
            break;
        case REPORT_MENU_ITEM_MAP:
            newViewController = self.mapViewController;
            self.navigationItem.leftBarButtonItem = nil;
            break;
        case REPORT_MENU_ITEM_TIMELINE:
            newViewController = self.timeChartViewController;
            self.navigationItem.leftBarButtonItem = nil;
            break;
        case REPORT_MENU_ITEM_LIST:
            newViewController = self.historyViewController;
            self.navigationItem.leftBarButtonItem = historyViewController.editButtonItem;
        default:
            break;
    }
    if (currentViewController != newViewController) {
        [self switchInView:newViewController andOutView:currentViewController];
        currentViewController = newViewController;
    }
}

-(void) switchInView:(UIViewController*)newVC andOutView:(UIViewController*)oldVC {
    if(newVC.view.superview == nil) {
        BOOL removeOldView = oldVC.view.superview != nil;
        
        [newVC viewWillAppear:YES];
        if (removeOldView) {
            [oldVC viewWillDisappear:YES];
            [oldVC.view removeFromSuperview];
        }
        
        [self.view insertSubview:newVC.view atIndex:0];
        newVC.view.frame = reportView.frame;
        NSLog(@"New frame: %@", NSStringFromCGRect(reportView.frame));
        
        if (removeOldView) {
            [oldVC viewDidDisappear:YES];
        }
        [newVC viewDidAppear:YES];
    }
}

- (void) menuItemSelected:(id)sender {
    UIButton *menuItem = (UIButton*) sender;  
    
    if (self.selectedMenu == menuItem.tag) {
        return;
    }
    
    // Check to see if the reports are purchased
    BOOL reportsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:IN_APP_REPORTS_ENABLED];
    if (menuItem.tag != REPORT_MENU_ITEM_LIST && !reportsEnabled) {
#if IMMEDIATE_PURCHASE        
        [(GottaFeelingAppDelegate*)[[UIApplication sharedApplication] delegate] requestUpgradeProductReports];
#else        
        PurchaseViewController *purchaseViewController = [[[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:nil] autorelease];
        [self.navigationController pushViewController:purchaseViewController animated:YES];
#endif        
        return;
    } 

    NSLog(@"Old - %d New -%d",self.selectedMenu ,menuItem.tag);
    [self selectMenuItem:menuItem.tag];
    
    UIButton *previousItem = (UIButton*)[self.view viewWithTag:self.selectedMenu];
    if ([previousItem isKindOfClass:[UIButton class]]) {
        previousItem.selected=NO;
    }
    menuItem.selected=YES;
    self.selectedMenu = menuItem.tag;
    if ([currentViewController isKindOfClass:[ChartViewController class]]) {
        ((ChartViewController*)currentViewController).reportType = self.selectedMenu;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // reportView only used to determine position of subviews
    [reportView removeFromSuperview];
    
    UIButton *menuToSelect = (UIButton*)[self.view viewWithTag:REPORT_MENU_ITEM_LIST];
    [self menuItemSelected:menuToSelect];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.chartViewController viewWillAppear:animated];
    [self.timeChartViewController viewWillAppear:animated];

    // HACK - When the controller is initialized, it is the right size but when
    // it gets to here it has shrunk to 242 pixels. I couldn't find where that 
    // was happening so am explicitely setting it here
    self.historyViewController.view.frame = self.reportView.frame;
    [self.historyViewController viewWillAppear:animated];
    [self.mapViewController viewWillAppear:animated];
    
    // Sure navigation bar shows correct background image
    navBackground = @"NavMain.png";
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:navBackground] forBarMetrics: UIBarMetricsDefault];
    } else {
        [self.navigationController.navigationBar setNeedsDisplay];
    }
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
  [reportView release];
  [super dealloc];
}

@end
