//
//  IconRegistry.m
//  GottaFeeling
//
//  Created by Denis Hennessy on 05/11/2012.
//  Copyright (c) 2012 Peer Assembly. All rights reserved.
//

#import "IconRegistry.h"

@implementation IconRegistry

+ (UIImage *)iconForKey:(NSString *)key {
    NSString *lowerKey = [key lowercaseString];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"whoAlone", @"alone",
        @"whoFriends", @"friends",
        @"whoFamily", @"family",
        @"whoSpouse", @"spouse",
        @"whoColleagues", @"colleagues",
        @"whoOther", @"other",
        @"whereHOME", @"home",
        @"whereWORK", @"work",
        @"whereGYM", @"gym",
        @"whereRESTAURANT", @"restaurant",
        @"whereEVENT", @"event",
        @"whereFRIENDSHOUSE", @"friend’s house",
        @"whereOUTDOORS", @"outdoors",
        @"whereSTORE", @"store",
        @"whereCOMMUTE", @"commuting",
        @"whereELSEWHERE", @"elsewhere",
        nil];
    NSString *imageName = [dict objectForKey:lowerKey];
    if (!imageName) {
        NSLog(@"No icon for %@", key);
        return nil;
    }
    UIImage *image = [UIImage imageNamed:imageName];
    if (!imageName) {
        NSLog(@"Can't load icon for %@", imageName);
        return nil;
    }
    return image;
}

@end
