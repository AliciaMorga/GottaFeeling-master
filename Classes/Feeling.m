//
//  Feeling.m
//  GottaFeeling
//
//  Created by Denis on 17/11/2010.
//  Copyright (c) 2010 Peer Assembly. All rights reserved.
//

#import "Feeling.h"

@implementation Feeling
@dynamic timeStamp;
@dynamic category;
@dynamic feeling;
@dynamic image;
@dynamic longitude;
@dynamic latitude;
@dynamic where;
@dynamic who;
@dynamic notes;

+ (NSString *)entityName {
    return @"Feeling";
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (NSString *)title {
    return NSLocalizedString(self.feeling, nil);
}

- (NSString *)subtitle {
    return NSLocalizedString(self.category, nil);
}

@end
