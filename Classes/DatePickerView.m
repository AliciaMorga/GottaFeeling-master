//
//  DatePickerView.m
//  GottaFeeling
//
//  Created by Liam Hennessy on 26/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import "DatePickerView.h"
#import "Constants.h"


@interface DatePickerView (hidden)
-(CGRect) updateFrame:(CGRect)frame withXPos:(CGFloat)xPos;
-(NSDate*) roundDateForSearch:(NSDate*)date forEnd:(BOOL)end;

@end

@implementation DatePickerView

@synthesize incrementDate   = _incrementDate;
@synthesize decrementDate   = _decrementDate;
@synthesize dateRangeLabel  = _dateRangeLabel;
@synthesize summaryLabel    = _summaryLabel;
@synthesize startDate       = _startDate;
@synthesize endDate         = _endDate;
@synthesize reportType      = _reportType;
@synthesize dateRangeType   = _dateRangeType;
@synthesize dateTypeTabView = _dateTypeTabView;
@synthesize delegate        = _delegate;


/*
 * Method to round the date for search purposes. If it's an end date add 
 * 23:59:59, otherwise it's a start date and make it 00:00:00
 */
-(NSDate*) roundDateForSearch:(NSDate*)date forEnd:(BOOL)end {
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *dateComponents = [gregorian components:unitFlags fromDate:date];
    if (end) {
        [dateComponents setHour:23];
        [dateComponents setMinute:59];
        [dateComponents setSecond:59];
    } else {
        [dateComponents setHour:0];
        [dateComponents setMinute:0];
        [dateComponents setSecond:0];
    }
    return [gregorian dateFromComponents:dateComponents];
}


-(CGRect) updateFrame:(CGRect)frame withXPos:(CGFloat)xPos {
  frame.origin.x=xPos;
  return frame;
}

-(void) updateDisplay {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:DATE_FORMAT];
    switch (self.dateRangeType) {
        case PICKER_DATE_TYPE_DAILY: { // Only display the day
            self.dateRangeLabel.text = [dateFormatter stringFromDate:self.endDate]; 
            break;
        }
        case PICKER_DATE_TYPE_ALL_TIME: { // Only display the day
            self.dateRangeLabel.text = NSLocalizedString(@"All", nil); 
            break;
        }
        default: {
            self.dateRangeLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:self.startDate], [dateFormatter stringFromDate:self.endDate]]; 
            break;
        }
    }

    CGFloat textSize          = [self.dateRangeLabel.text sizeWithFont:self.dateRangeLabel.font].width;
    CGFloat fieldSize         = self.frame.size.width;

    CGFloat leftArrowXPos     = roundf((fieldSize-textSize-2*ARROW_PADDING-self.decrementDate.frame.size.width-self.incrementDate.frame.size.width)/2);
    CGFloat labelXPos         = leftArrowXPos+ARROW_PADDING+self.decrementDate.frame.size.width;
    CGFloat rightArrowXPos    = labelXPos+ARROW_PADDING+textSize;

    CGRect labelFrame = self.dateRangeLabel.frame;
    self.dateRangeLabel.frame = CGRectMake(labelXPos, labelFrame.origin.y, textSize, labelFrame.size.height);
    
    self.decrementDate.frame  = [self updateFrame:self.decrementDate.frame withXPos:leftArrowXPos];
    self.incrementDate.frame  = [self updateFrame:self.incrementDate.frame withXPos:rightArrowXPos];
}

-(void) updateDatesByAmount:(NSInteger)amount {
    
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    [gregorian setFirstWeekday:1];
    NSDate *today = [NSDate date];
    
    switch (self.dateRangeType) {
        case PICKER_DATE_TYPE_DAILY: {
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setDay:amount];      
            NSDate *newDate = [self roundDateForSearch:[gregorian dateByAddingComponents:dateComponents toDate:self.endDate options:0] forEnd:YES];
            if ([newDate timeIntervalSinceDate:[self roundDateForSearch:today forEnd:YES]]>0) {
                newDate = today;
            }
            self.endDate = newDate;
            self.startDate = [self roundDateForSearch:self.endDate forEnd:NO];      
            [dateComponents release];
            self.incrementDate.hidden = NO;
            self.decrementDate.hidden = NO;
            break;
        }

        case PICKER_DATE_TYPE_WEEKLY: {
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setWeek:amount];      

            NSDate *newDate = [self roundDateForSearch:[gregorian dateByAddingComponents:dateComponents toDate:self.endDate options:0] forEnd:YES];      

            /* Ensure that if the user has changed the end date to be more than
             * a week just use today as the base
             */            
            if ([newDate timeIntervalSinceDate:today]>0) {
                newDate = today;
            }
            
            NSDate *sDate;
            // start of the period
            [gregorian rangeOfUnit:NSWeekCalendarUnit
                         startDate:&sDate
                          interval:0
                           forDate:newDate];

            self.startDate = [self roundDateForSearch:sDate forEnd:NO];

            NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
            [endDateComponents setDay:6];
            self.endDate = [self roundDateForSearch:[gregorian dateByAddingComponents:endDateComponents toDate:self.startDate options:0] forEnd:YES];      
            
            [endDateComponents release];
            [dateComponents release];
            self.incrementDate.hidden = NO;
            self.decrementDate.hidden = NO;
            break;
        }

        case PICKER_DATE_TYPE_MONTHLY: {
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit;
            
            [dateComponents setMonth:amount];      
            
            NSDate *newDate = [self roundDateForSearch:[gregorian dateByAddingComponents:dateComponents toDate:self.endDate options:0] forEnd:YES];      
            if ([newDate timeIntervalSinceNow]>0) { // If the date is after now, don't allow them to progress
                NSDateComponents *monthComponents = [gregorian components:unitFlags fromDate:today];
                NSRange rng = [gregorian rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:newDate];                
                [monthComponents setDay:rng.length];
                self.endDate = [self roundDateForSearch:[gregorian dateFromComponents:monthComponents] forEnd:YES];
            } else { // Calculate the number of days in the month and use that for the end date
                NSDateComponents *monthComponents = [gregorian components:unitFlags fromDate:newDate];
                NSRange rng = [gregorian rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:newDate];                
                [monthComponents setDay:rng.length];
                
                self.endDate = [self roundDateForSearch:[gregorian dateFromComponents:monthComponents] forEnd:YES];
            }
                        
            NSDateComponents *startDateComponents = [gregorian components:unitFlags fromDate:self.endDate];
            [startDateComponents setDay:1];
            [startDateComponents setHour:0];
            [startDateComponents setMinute:0];
            [startDateComponents setSecond:0];
            
            self.startDate = [gregorian dateFromComponents:startDateComponents];
            [dateComponents release];
            self.incrementDate.hidden = NO;
            self.decrementDate.hidden = NO;
            break;
        }
            
        case PICKER_DATE_TYPE_ALL_TIME: {
            self.endDate = today;
            
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            [startDateComponents setYear:2009];
            
            self.startDate = [gregorian dateFromComponents:startDateComponents];
            [startDateComponents release];
            self.incrementDate.hidden = YES;
            self.decrementDate.hidden = YES;
            break;
        }
        default:
            break;
    }
    [self updateDisplay];    
    if (self.delegate) {
        [self.delegate updatedReportStartDate:self.startDate endDate:self.endDate forReport:self.reportType];
    }
}

-(IBAction) increment:(id)sender {
  [self updateDatesByAmount:1];
}

-(IBAction) decrement:(id)sender {
  [self updateDatesByAmount:-1];
}

#pragma 
#pragma mark TabViewDelegate methods

- (void)menuItemChanged:(NSInteger)previousItem newItem:(NSInteger)newItem {
    self.dateRangeType = newItem;
    
    // Set up the dates to match the new menuItem
    [self updateDatesByAmount:0];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

-(void) setReportType:(NSInteger)type {
    _reportType = type;
    
    // Update the tabView to have the base Menu
    self.dateTypeTabView.baseMenuType = type;
    
    // Default the menu item selected to the first one
    self.dateRangeType=type;
    
    switch (self.reportType) {
        case REPORT_MENU_ITEM_CHART:
            self.dateTypeTabView.tabTitles = [NSArray arrayWithObjects:@"Daily", @"Weekly", @"Monthly", @"All Time", nil];
            break;
        case REPORT_MENU_ITEM_TIMELINE:
            self.dateTypeTabView.tabTitles = [NSArray arrayWithObjects:@"Days", @"Weeks", @"Months", nil];
            break;
        default:
            break;
    }
    [self updateDatesByAmount:0];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
  [_incrementDate release];
  [_decrementDate release];
  [_dateRangeLabel release];
  [_summaryLabel release];
  [_startDate release];
  [_endDate release];
  [_dateTypeTabView release];
  [super dealloc];
}


@end
