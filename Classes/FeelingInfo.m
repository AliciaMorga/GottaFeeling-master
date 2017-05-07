//
//  FeelingInfo.m
//  GottaFeeling
//
//  Created by Denis on 05/12/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import "FeelingInfo.h"


@implementation FeelingInfo
@synthesize assetName, color, name, webColor;

+ (id)feelingInfoWithName:(NSString *)name red:(float)red green:(float)green blue:(float)blue {
    return [[[FeelingInfo alloc] initWithName:name red:red green:green blue:blue] autorelease];
}

- (id)initWithName:(NSString *)_name red:(float)red green:(float)green blue:(float)blue {
    if ((self = [super init])) {
        name = [_name retain];
        color = [[UIColor colorWithRed:red green:green blue:blue alpha:1.0] retain];
        webColor = [[NSString stringWithFormat:@"#%02X%02X%02X", (int)(255.0*red), (int)(255.0*green), (int)(255.0*blue)] retain];
//        NSLog(@"Color for %@ is %@", name, webColor);
    }
    return self;
}

+ (NSArray *)allFeelings {
    static NSArray *_allFeelings;
    if (_allFeelings == nil) {
        _allFeelings = [[NSArray alloc] initWithObjects:
                        [FeelingInfo feelingInfoWithName:@"Happy"       red:.99 green:.91 blue:.57], 
                        [FeelingInfo feelingInfoWithName:@"Caring"      red:.99 green:.73 blue:.66], 
                        [FeelingInfo feelingInfoWithName:@"Confused"    red:.87 green:.94 blue:.67], 
                        [FeelingInfo feelingInfoWithName:@"Sad"         red:.62 green:.75 blue:.89], 
                        [FeelingInfo feelingInfoWithName:@"Angry"       red:.97 green:.57 blue:.59], 
                        [FeelingInfo feelingInfoWithName:@"Inadequate"  red:.64 green:.90 blue:.91], 
                        [FeelingInfo feelingInfoWithName:@"Hurt"        red:.55 green:.74 blue:.77], 
                        [FeelingInfo feelingInfoWithName:@"Fearful"     red:.80 green:.83 blue:.71], 
                        [FeelingInfo feelingInfoWithName:@"Lonely"      red:.92 green:.86 blue:.93], 
                        [FeelingInfo feelingInfoWithName:@"Guilt/Shame" red:.71 green:.68 blue:.89], 
                        nil ];
    }
    
    return _allFeelings;
}

+ (NSInteger)count {
    return [[self allFeelings] count];
}

+ (FeelingInfo *)feelingForName:(NSString *)name {    
    for (FeelingInfo *feeling in [self allFeelings]) {
        if ([feeling.name isEqualToString:name])
            return feeling;
    }
    NSLog(@"WARNING: Feeling named %@ not found", name);
    return nil;
}

- (NSString *)assetName {
    if ([name isEqualToString:@"Guilt/Shame"])
        return @"Guilt";
    else
        return name;
}

- (void)dealloc {
    [super dealloc];
}


@end
