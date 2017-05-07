//
//  FeelingsViewController.h
//  GottaFeeling
//
//  Created by Denis on 01/11/2010.
//  Copyright (c) 2010 Peer Assembly. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import <UIKit/UIKit.h>
#import "PATree.h"

@interface FeelingsViewController : UITableViewController <PATreeDelegate> {
    PATree *tree;
    UILabel *welcomeLabel;
    SystemSoundID soundWelcome;
}

@property (nonatomic, retain) PATree *tree;

@end