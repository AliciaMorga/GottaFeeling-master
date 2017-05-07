//
//  TimelineChartView.h
//  GottaFeeling
//
//  Created by Liam Hennessy on 02/12/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LABEL_MODE_DAYS     0
#define LABEL_MODE_WEEKS    1
#define LABEL_MODE_MONTHS   2

#define CHART_PADDING       5
#define CHART_SECTIONS      4

@interface TimelineChartView : UIView {
    NSInteger dayWidth;
    int labelMode;
    NSDate *firstDay;
    NSDate *lastDay;
    NSMutableArray *dayValues;    
}

@property (nonatomic, assign) NSInteger dayWidth;
@property (nonatomic, retain) NSDate *firstDay;
@property (nonatomic, retain) NSDate *lastDay;
@property (nonatomic, readonly) int numberOfDays;
@property (nonatomic, assign) int labelMode;

- (void)setValues:(NSArray *)values forDay:(NSDate *)day;

@end
