//
//  ExtrasViewController.h
//  GottaFeeling
//
//  Created by Sheldon Conaty on 26/04/2011.
//  Copyright 2011 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectorTableController.h"
#import "NoteEditorViewController.h"

@interface ExtrasViewController : UITableViewController<NoteEditorViewControllerDelegate> {
    NSString *feelingWord;
    NSString *feelingName;
    NSString *feelingWho;
    NSString *feelingWhere;
    NSString *feelingNote;
    
	SelectorTableController *whoSelector;
	SelectorTableController *whereSelector;
    UIView *registerPanel;
    UIButton *registerButton;
}

@property (nonatomic, retain) NSString *feelingWord;
@property (nonatomic, retain) NSString *feelingName;
@property (nonatomic, retain) NSString *feelingWho;
@property (nonatomic, retain) NSString *feelingWhere;
@property (nonatomic, retain) NSString *feelingNote;

@end
