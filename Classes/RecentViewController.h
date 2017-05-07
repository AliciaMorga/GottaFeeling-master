//
//  RecentViewController.h
//  GottaFeeling
//
//  Created by Denis on 30/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RecentViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSArray *recentFeelings;
}

@property (nonatomic, retain) NSArray *recentFeelings;

@end