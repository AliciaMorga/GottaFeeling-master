//
//  HistoryViewController.h
//  GottaFeeling
//
//  Created by Denis on 20/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *fetchedResultsController;
    UIViewController *parentViewController;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIViewController *parentViewController;


@end