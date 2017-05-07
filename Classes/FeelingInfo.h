//
//  FeelingInfo.h
//  GottaFeeling
//
//  Created by Denis on 05/12/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FeelingInfo : UIView {
    NSString *name;
    NSString *webColor;
    UIColor *color;
}

@property (nonatomic, readonly) NSString *assetName;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) UIColor *color;
@property (nonatomic, readonly) NSString *webColor;

- (id)initWithName:(NSString *)_name red:(float)red green:(float)green blue:(float)blue;
+ (id)feelingInfoWithName:(NSString *)name red:(float)red green:(float)green blue:(float)blue;

+ (NSArray *)allFeelings;
+ (FeelingInfo *)feelingForName:(NSString *)name;
+ (NSInteger)count;

@end
