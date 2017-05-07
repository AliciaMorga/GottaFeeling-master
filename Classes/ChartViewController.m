//
//  ChartViewController.m
//  GottaFeeling
//
//  Created by Liam Hennessy on 25/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import "ChartViewController.h"
#import "GottaFeelingAppDelegate.h"
#import "Constants.h"
#import "Feeling.h"


@implementation ChartViewController

@synthesize datePickerView = _datePickerView;
@synthesize pieChartViewController = _pieChartViewController;
@synthesize timelineViewController = _timelineViewController;
@synthesize summaryLabel = _summaryLabel;
@synthesize reportType = _reportType;
@synthesize isTimeline;


-(NSDictionary*) getResultsDataForStartDate:(NSDate*)startDate endDate:(NSDate*)endDate {
    NSError *error;
    NSManagedObjectContext *managedObjectContext = [GottaFeelingAppDelegate managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:Feeling.entityName inManagedObjectContext:managedObjectContext]];

    NSMutableDictionary *data = [[[NSMutableDictionary alloc] init] autorelease]; // Main container for the results
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"timeStamp > %@ AND timeStamp < %@",startDate, endDate]; 
    [request setPredicate:predicate];
    NSArray *feelings = [managedObjectContext executeFetchRequest:request error:&error];
    
    // Some helpful information for the chart
    [data setObject:[NSNumber numberWithInt:[feelings count]] forKey:REPORT_DATA_TOTAL];
    [data setObject:startDate forKey:REPORT_DATA_DATE];
    
    NSMutableDictionary *feelingContainer = [[NSMutableDictionary alloc] init];
    for (Feeling *feeling in feelings) {
        NSMutableArray *array = [feelingContainer objectForKey:feeling.category];
        if (!array) {
            array = [[[NSMutableArray alloc] init] autorelease];
        }
        [array addObject:feeling];
        [feelingContainer removeObjectForKey:feeling.feeling];
        [feelingContainer setObject:array forKey:feeling.category];
    }
    
    // Add the main report data
    [data setObject:feelingContainer forKey:REPORT_DATA_FEELINGS];
    [feelingContainer release];
    return [NSMutableDictionary dictionaryWithDictionary:data];
}


-(void) setReportType:(NSInteger)type {
    if (_reportType != type) {
        _reportType = type;
        self.datePickerView.reportType = type;
        [self.datePickerView setNeedsLayout];
    }
}

-(PieChartViewController*) pieChartViewController {
    if (!_pieChartViewController) {
        _pieChartViewController = [[PieChartViewController alloc] initWithNibName:@"PieChartViewController" bundle:nil];
        CGRect frame = self.view.frame;
        
        frame.origin.y = self.datePickerView.frame.size.height+self.summaryLabel.frame.size.height;
        frame.size.height -= (self.datePickerView.frame.size.height+self.summaryLabel.frame.size.height);
        
        _pieChartViewController.view.frame = frame;
        [self.view addSubview:_pieChartViewController.view];
    }
    return _pieChartViewController;
}

-(TimelineViewController *) timeChartViewController {
    if (!_timelineViewController) {
        _timelineViewController = [[TimelineViewController alloc] initWithNibName:@"TimelineViewController" bundle:nil];
        CGRect frame = self.view.frame;
        
        frame.origin.y = self.datePickerView.frame.size.height+self.summaryLabel.frame.size.height;
        frame.size.height -= (self.datePickerView.frame.size.height+self.summaryLabel.frame.size.height);

        _timelineViewController.view.frame = frame;
        [self.view addSubview:_timelineViewController.view];
    }
    return _timelineViewController;
}

#pragma
#pragma mark DatePickerViewDelegate method
- (void)updatedReportStartDate:(NSDate*)startDate endDate:(NSDate*)endDate forReport:(NSInteger)reportType {
    NSError *error = nil; 
    
    // Temp fix to prevent crash
    if (startDate == nil || endDate == nil)
        return;
    
    NSManagedObjectContext *managedObjectContext = [GottaFeelingAppDelegate managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:Feeling.entityName inManagedObjectContext:managedObjectContext]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"timeStamp > %@ AND timeStamp < %@",startDate, endDate]; 
    [request setPredicate:predicate];
    NSArray *feelings = [managedObjectContext executeFetchRequest:request error:&error];

    NSString *summary = [feelings count] == 1?NSLocalizedString(@"1 Feeling Recorded", @"Text to indicate that there was only one Feeling Recorded"):NSLocalizedString(@"%d Feelings Recorded", @"Text to indicate the number of Feelings Recorded");
    
    self.summaryLabel.text = [NSString stringWithFormat:summary, [feelings count]];
    
    if (isTimeline) {
        NSMutableArray *reportData = [[[NSMutableArray alloc] init] autorelease];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:1]; // 
        
        NSDate *dailyStartDate = startDate;
        NSDate *dailyEndDate = [gregorian dateByAddingComponents:dateComponents toDate:startDate options:0];      
        while ([dailyEndDate timeIntervalSinceDate:endDate]<0) {
            [reportData addObject:[self getResultsDataForStartDate:dailyStartDate endDate:dailyEndDate]];
            dailyStartDate = dailyEndDate;
            dailyEndDate = [gregorian dateByAddingComponents:dateComponents toDate:dailyStartDate options:0];
        }
        // At this point the original end date should be the corect end date for this day
        dailyEndDate = endDate;
        [reportData addObject:[self getResultsDataForStartDate:dailyStartDate endDate:dailyEndDate]];
        for (NSDictionary *data in reportData) {
            NSLog(@"Date %@, Total Feelings %d, Unique Feelings %d",
                  [data objectForKey:REPORT_DATA_DATE],
                  [(NSNumber*)[data objectForKey:REPORT_DATA_TOTAL] intValue],
                  [(NSArray*)[data objectForKey:REPORT_DATA_FEELINGS] count]);
        }
        [gregorian release];
        [dateComponents release];
    } else {        
        NSMutableDictionary *feelingContainer = [[[NSMutableDictionary alloc] init] autorelease];
        for (Feeling *feeling in feelings) {
            NSMutableArray *array = [feelingContainer objectForKey:feeling.category];
            if (!array) {
                array = [[[NSMutableArray alloc] init] autorelease];
            }
            [array addObject:feeling];
            [feelingContainer removeObjectForKey:feeling.category];
            [feelingContainer setObject:array forKey:feeling.category];
        }
        
        NSMutableArray *data = [[[NSMutableArray alloc] init] autorelease];
        NSArray *keys = [feelingContainer allKeys];
        for (NSString *key in keys) {
            NSArray *values = [feelingContainer objectForKey:key];
            NSNumber *numberInCategory = [NSNumber numberWithInt:[values count]];
            [data addObject:numberInCategory];
        }
        
        self.pieChartViewController.chartDataTitles = [NSArray arrayWithArray:keys];
        self.pieChartViewController.chartData = [NSArray arrayWithArray:data];
        
        [self.pieChartViewController redraw];
    }
}




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    self.datePickerView.endDate = [NSDate date];
    self.view.backgroundColor = [UIColor whiteColor];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    if (isTimeline) {
        [self.timeChartViewController viewWillAppear:animated];
    } else {
        [self.pieChartViewController viewWillAppear:animated];
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    [_datePickerView release];
    [_pieChartViewController release];
    [_timelineViewController release];
    [_summaryLabel release];
    [super dealloc];
}


@end
