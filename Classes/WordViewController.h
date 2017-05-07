//
//  WordViewController.h
//  GottaFeeling
//
//  Created by Darragh Hennessy on 04/11/2010.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PATree.h"


@interface WordViewController : UITableViewController <PATreeDelegate> {
    PATree *tree;
}

@property (nonatomic, retain) PATree *tree;

@end