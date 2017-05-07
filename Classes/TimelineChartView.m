//
//  TimelineChartView.m
//  GottaFeeling
//
//  Created by Liam Hennessy on 02/12/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import "TimelineChartView.h"
#import "FeelingInfo.h"
#import "NSDate+Misc.h"

#define HEADING_FONT        "Helvetica"
#define HEADING_FONTSIZE    13
#define HEADING_HEIGHT      20

@implementation TimelineChartView
@synthesize dayWidth, firstDay, labelMode, lastDay;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        dayWidth = 10;
        self.firstDay = [NSDate date];
        self.lastDay = firstDay;
        
    }
    return self;
}

- (void)setLabelMode:(int)_labelMode {
    labelMode = _labelMode;
    [self setNeedsDisplay];
}

- (void)setDayWidth:(NSInteger)_dayWidth {
    dayWidth = _dayWidth;
    [self setNeedsDisplay];
}

// Find next index of day with any data, or -1 if none
- (int)findInterestingDayFrom:(int)iStart {
    int cDays = [firstDay differenceInDaysTo:lastDay] + 1;
    if (iStart >= cDays)
        return -1;
    
    for (int d=iStart;d<cDays;d++) {
        NSArray *values = [dayValues objectAtIndex:d];
        if (![values isKindOfClass:[NSNull class]]) {
            return d;
        }
    }
    
    return -1;
}

- (NSString *)labelForDate:(NSDate *)day {
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *dayComponents = [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:day];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    switch (labelMode) {
        case LABEL_MODE_DAYS:
            [formatter setDateFormat:@"EEE"];
            return [formatter stringFromDate:day];
        case LABEL_MODE_WEEKS:
            if ([dayComponents weekday] == 1) {  // 1=Sunday, 2=Monday, …
                [formatter setDateFormat:@"MMM d"];
                return [formatter stringFromDate:day];
            }
            break;
        case LABEL_MODE_MONTHS:
            if ([dayComponents day] == 1) {
                [formatter setDateFormat:@"MMM yyyy"];
                return [formatter stringFromDate:day];
            }
            break;
    }
    return nil;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat height = self.frame.size.height - HEADING_HEIGHT;
    CGFloat width = self.frame.size.width;

    NSArray *feelingInfo = [FeelingInfo allFeelings];
    int cFeelings = [feelingInfo count];
    
    int iCurDay = [self findInterestingDayFrom:0];
    if (iCurDay != -1) {
        int iNextDay = [self findInterestingDayFrom:iCurDay+1];
        if (iNextDay == -1) {
            // Only one day of data, draw as stacked bar graph
            NSArray *values = [dayValues objectAtIndex:iCurDay];
            CGFloat x = iCurDay * dayWidth;
            CGFloat y = HEADING_HEIGHT;
            for (int i=0;i<cFeelings;i++) {
                NSNumber *val = [values objectAtIndex:i];
                if ([val doubleValue] > 0.0) {
                    FeelingInfo *feeling = [feelingInfo objectAtIndex:i];
                    CGFloat h = height * [val doubleValue];
                    CGContextSetFillColorWithColor(ctx, feeling.color.CGColor); 
                    CGMutablePathRef path = CGPathCreateMutable();   
                    CGPathAddRect(path, NULL, CGRectMake(x, y, dayWidth, h));
                    CGContextAddPath(ctx, path); 
                    CGContextDrawPath(ctx, kCGPathFill);
                    CGPathRelease(path);
                    y += h;
                }
            }        
        } else {
            while (iNextDay != -1) {
                NSArray *curValues = [dayValues objectAtIndex:iCurDay];
                NSArray *nextValues = [dayValues objectAtIndex:iNextDay];
                CGFloat x0 = iCurDay * dayWidth + dayWidth/2;
                CGFloat x1 = iNextDay * dayWidth + dayWidth/2;
                CGFloat y0 = HEADING_HEIGHT;
                CGFloat y1 = HEADING_HEIGHT;;
                CGFloat h0 = 0;
                CGFloat h1 = 0;

                for (int i=0;i<cFeelings;i++) {
                    NSNumber *val = [curValues objectAtIndex:i];
                    h0 = height * [val doubleValue];
                    val = [nextValues objectAtIndex:i];
                    h1 = height * [val doubleValue];
                    if (h0 > 0.0 || h1 > 0.0) {
                        CGMutablePathRef path = CGPathCreateMutable();   
                        CGPathMoveToPoint(path, NULL, x0, y0); 
                        CGPathAddLineToPoint(path, NULL, x0, y0+h0); 
                        CGPathAddLineToPoint(path, NULL, x1, y1+h1); 
                        CGPathAddLineToPoint(path, NULL, x1, y1); 
                        CGPathCloseSubpath(path);
                        y0 += h0;
                        y1 += h1;
                        FeelingInfo *feeling = [feelingInfo objectAtIndex:i];
                        CGContextSetFillColorWithColor(ctx, feeling.color.CGColor); 
                        CGContextAddPath(ctx, path); 
                        CGContextFillPath(ctx);
                        CGPathRelease(path);
                    }
                }
                iCurDay = iNextDay;
                iNextDay = [self findInterestingDayFrom:iCurDay+1];
            }
        }
    }
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0, HEADING_HEIGHT);
    CGContextScaleCTM(ctx, 1, -1);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor); 
    CGMutablePathRef path = CGPathCreateMutable();   
    CGPathAddRect(path, NULL, CGRectMake(0, 0, width, HEADING_HEIGHT));
    CGContextAddPath(ctx, path); 
    CGContextDrawPath(ctx, kCGPathFill);
    CGPathRelease(path);
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, -height); 
    CGPathAddLineToPoint(path, NULL, width, -height); 
    CGContextAddPath(ctx, path); 
    CGContextDrawPath(ctx, kCGPathStroke);
    CGPathRelease(path);
    
    CGContextSetLineWidth(ctx, 0.5);
    for (int d=0;d<[self numberOfDays];d++) {
        NSDate *day = [firstDay dateByAddingDays:d];
        NSString *label = [self labelForDate:day];
        if (label) {
            CGFloat x = d * dayWidth;
            path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, x, -height); 
            CGPathAddLineToPoint(path, NULL, x, HEADING_HEIGHT); 
            CGContextAddPath(ctx, path); 
            CGContextDrawPath(ctx, kCGPathStroke);
            CGPathRelease(path);
            
            CGContextSelectFont(ctx, HEADING_FONT, HEADING_FONTSIZE, kCGEncodingMacRoman);
            CGContextSetTextDrawingMode(ctx, kCGTextFill); 
            CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);
            CGContextShowTextAtPoint(ctx, x+3, 4, [label cStringUsingEncoding:NSMacOSRomanStringEncoding], [label length]);
        }
    }
    CGContextRestoreGState(ctx);
}

- (int)numberOfDays {
    if (firstDay && lastDay) {
        return [firstDay differenceInDaysTo:lastDay] + 1;
    } else {
        return 0;
    }
}

- (void)clearValues {
    [dayValues release];
    dayValues = nil;
    if (firstDay && lastDay) {
        int cDays = [self numberOfDays];
        if (cDays > 0) {
            dayValues = [[NSMutableArray alloc] initWithCapacity:cDays];
            for (int i=0;i<cDays;i++)
                [dayValues addObject:[NSNull null]];
        }
    }
}

- (void)setFirstDay:(NSDate *)_firstDay {
    [firstDay release];
    firstDay = [[_firstDay dateAsDateWithoutTime] retain];
    [self clearValues];
}

- (void)setLastDay:(NSDate *)_lastDay {
    [lastDay release];
    lastDay = [[_lastDay dateAsDateWithoutTime] retain];
    [self clearValues];
}

- (void)setValues:(NSArray *)values forDay:(NSDate *)day {
    // Normalise all values into 0.0-1.0 range
    int total = 0;
    for (NSNumber *n in values)
        total += [n intValue];
    if (total == 0) {
        NSLog(@"Fatal: setValues called with all 0's");
        return;
    }
    NSMutableArray *normalisedValues = [NSMutableArray arrayWithCapacity:[values count]];
    for (NSNumber *n in values) {
        double val = [n doubleValue];
        [normalisedValues addObject:[NSNumber numberWithDouble:val/((double)total)]];
    }

    NSMutableString *str = [NSMutableString string];
    for (NSNumber *n in normalisedValues) {
        [str appendFormat:@"%.3f ", [n doubleValue]];
    }
    NSLog(@"%@ - %@", day, str);
    
    NSDate *simpleDay = [day dateAsDateWithoutTime];
    int i = [firstDay differenceInDaysTo:simpleDay];
    if (i < 0 || i >= [self numberOfDays]) {
        NSLog(@"setValues called for date outside view range - %@", day);
        return;
    }
    [dayValues replaceObjectAtIndex:i withObject:normalisedValues];
}

- (void)dealloc {
    [firstDay release];
    [lastDay release];
    [super dealloc];
}


@end
