//
//  ChartViewController.h
//  GottaFeeling
//
//  Created by Liam Hennessy on 25/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PieChartViewController.h"
#import "TimelineViewController.h"
#import "DatePickerView.h"

@interface ChartViewController : UIViewController {
    PieChartViewController *_pieChartViewController;
    TimelineViewController *_timelineViewController;
    IBOutlet DatePickerView *_datePickerView;
    IBOutlet UILabel *_summaryLabel;
    BOOL isTimeline;
    
    NSInteger _reportType;
}

@property (nonatomic, retain) DatePickerView *datePickerView;
@property (nonatomic, retain) PieChartViewController *pieChartViewController;
@property (nonatomic, retain) TimelineViewController *timelineViewController;
@property (nonatomic, retain) UILabel *summaryLabel;
@property (nonatomic, assign) BOOL isTimeline;

@property (nonatomic) NSInteger reportType;

@end
