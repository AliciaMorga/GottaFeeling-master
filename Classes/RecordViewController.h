//
//  RecordViewController.h
//  GottaFeeling
//
//  Created by Denis on 12/11/2010.
//  Copyright (c) 2010 Peer Assembly. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "FBConnect.h"
#import "TwitterLoginViewControllerDelegate.h"
#import "TwitterComposeViewControllerDelegate.h"
#import "Feeling.h"
#import "NoteEditorViewController.h"

@interface RecordViewController : UIViewController <FBDialogDelegate, MFMailComposeViewControllerDelegate, NoteEditorViewControllerDelegate, UIActionSheetDelegate, TwitterLoginViewControllerDelegate,TwitterComposeViewControllerDelegate> {
    Feeling *feeling;
    BOOL allowDeletion;
    BOOL allowNewFeeling;
    UILabel *feelingLabel;
    UIImageView *feelingImageView;
    UIButton *deleteButton;
    UIButton *newFeelingButton;
    SystemSoundID soundFeeling;

	TwitterConsumer* _consumer;
	TwitterToken* _token;
}

@property (nonatomic, retain) IBOutlet UILabel *feelingLabel;
@property (nonatomic, retain) IBOutlet UIImageView *feelingImageView;
@property (nonatomic, retain) IBOutlet UIButton *deleteButton;
@property (nonatomic, retain) IBOutlet UIButton *newFeelingButton;
@property (nonatomic, retain) Feeling *feeling;
@property (nonatomic, assign) BOOL allowNewFeeling;
@property (nonatomic, assign) BOOL allowDeletion;

- (IBAction)newFeeling;
- (IBAction)deleteFeeling;
- (IBAction)shareFeeling;
- (IBAction)showNote:(id)sender;

@end
