//
//  TimelineViewController.h
//  GottaFeeling
//
//  Created by Denis on 30/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelineChartView.h"
#import "TabView.h"


@interface TimelineViewController : UIViewController <TabViewDelegate> {
    TabView *tabView;
    UIScrollView *scrollView;
    TimelineChartView *chartView;
    UIView *legendView;
}

@property (nonatomic, retain) IBOutlet TabView *tabView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet TimelineChartView *chartView;
@property (nonatomic, retain) IBOutlet UIView *legendView;

@end
