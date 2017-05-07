//
//  ReportViewController.h
//  GottaFeeling
//
//  Created by Liam Hennessy on 23/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryViewController.h"
#import "ChartViewController.h"
#import "TimelineViewController.h"
#import "MapViewController.h"


@interface ReportViewController : UIViewController <UIAlertViewDelegate> {
    NSInteger selectedMenu;  
    IBOutlet UIView *reportView;  

    HistoryViewController *historyViewController;
    ChartViewController *chartViewController;
    TimelineViewController *timeChartViewController;
    MapViewController *mapViewController;
    
    UIViewController *currentViewController;
}

@property (nonatomic) NSInteger selectedMenu;
@property (nonatomic, retain) UIView *reportView;  
@property (nonatomic, retain) HistoryViewController *historyViewController;  
@property (nonatomic, retain) ChartViewController *chartViewController;  
@property (nonatomic, retain) TimelineViewController *timeChartViewController;  

- (IBAction) menuItemSelected:(id)sender;

@end
