//
//  DatePickerView.h
//  GottaFeeling
//
//  Created by Liam Hennessy on 26/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TabView.h"

#define DATE_FORMAT               @"MMM d"

#define TIMELINE_GROUP_SIZE         4 // For timeline we need to get 'x' times to display e.g. 4 days, 4 weeks, 4 months

#define PICKER_DATE_TYPE_DAILY      10 // Single Day
#define PICKER_DATE_TYPE_WEEKLY     11 // Single Week (01 - 07)
#define PICKER_DATE_TYPE_MONTHLY    12 // Single Month (01 - 31)
#define PICKER_DATE_TYPE_ALL_TIME   13 // All records

#define DEFAULT_PICKER_DATE_TYPE    PICKER_DATE_TYPE_MONTHLY

#define ARROW_WIDTH                 16
#define ARROW_PADDING               10

@protocol DatePickerViewDelegate;

@interface DatePickerView : UIView <TabViewDelegate> {
    IBOutlet UIButton *_decrementDate;
    IBOutlet UIButton *_incrementDate;

    IBOutlet UILabel *_dateRangeLabel;
    IBOutlet UILabel *_summaryLabel;

    IBOutlet TabView *_dateTypeTabView;

    NSInteger _reportType; // Main report types (Chart, Map, Timeline)
    NSInteger _dateRangeType; // Date ranges (Days, Weeks, Months etc)

    NSDate *_startDate;
    NSDate *_endDate;

    id <DatePickerViewDelegate> _delegate;
}

@property (nonatomic, retain) UIButton *decrementDate;
@property (nonatomic, retain) UIButton *incrementDate;

@property (nonatomic, retain) UILabel *dateRangeLabel;
@property (nonatomic, retain) UILabel *summaryLabel;

@property (nonatomic, retain) TabView *dateTypeTabView;

@property (nonatomic) NSInteger reportType;
@property (nonatomic) NSInteger dateRangeType;

@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;

@property (nonatomic, assign) IBOutlet id <DatePickerViewDelegate> delegate;

-(IBAction) increment:(id)sender;
-(IBAction) decrement:(id)sender;

-(void) updateDisplay;
-(void) updateDatesByAmount:(NSInteger)amount;
@end

@protocol DatePickerViewDelegate <NSObject>
@optional
- (void)updatedReportStartDate:(NSDate*)startDate endDate:(NSDate*)endDate forReport:(NSInteger)reportType;
@end

