//
//  Feeling.h
//  GottaFeeling
//
//  Created by Denis on 17/11/2010.
//  Copyright (c) 2010 Peer Assembly. All rights reserved.
//

#import <MapKit/MapKit.h>

#define DEFAULT_WHERE   @"elsewhere"
#define DEFAULT_WHO     @"other"


@interface Feeling : NSManagedObject <MKAnnotation> {
@private
}
@property (nonatomic, retain) NSDate *timeStamp;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *feeling;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSString *where;
@property (nonatomic, retain) NSString *who;
@property (nonatomic, retain) NSString *notes;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

+ (NSString *)entityName;

@end
