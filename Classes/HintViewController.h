//
//  HintViewController.h
//  GottaFeeling
//
//  Created by Sheldon Conaty on 27/04/2011.
//  Copyright 2011 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HintViewController : UIViewController {
    UIButton *closeButton;
    UIImageView *hintImageView;
}

@property (nonatomic, retain) IBOutlet UIButton *closeButton;
@property (nonatomic, retain) IBOutlet UIImageView *hintImageView;

+ (void)applicationDidBecomeActive;
+ (BOOL)shouldDisplayHint;

- (IBAction)doClose;

@end
