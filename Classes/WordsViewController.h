//
//  FeelingsViewController.h
//  GottaFeeling
//
//  Created by Denis on 01/11/2010.
//  Copyright (c) 2010 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PATree.h"

@interface WordsViewController : UITableViewController <PATreeDelegate> {
    PATree *tree;
    UILabel *welcomeLabel;
    NSString *feelingName;
    NSString *feelingDisplayName;
}

@property (nonatomic, retain) PATree *tree;
@property (nonatomic, retain) NSString *feelingName;
@property (nonatomic, retain) NSString *feelingDisplayName;

@end