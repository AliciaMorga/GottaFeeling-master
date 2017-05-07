//
//  NSDate+Misc.h
//  GottaFeeling
//
//  Created by Denis on 05/12/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate(Misc)
+ (NSDate *)dateWithoutTime;
- (NSDate *)dateByAddingDays:(NSInteger)numDays;
- (NSDate *)dateAsDateWithoutTime;
- (int)differenceInDaysTo:(NSDate *)toDate;
- (NSString *)formattedDateString;
- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat;
@end