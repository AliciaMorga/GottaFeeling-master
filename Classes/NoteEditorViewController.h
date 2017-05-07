//
//  NoteEditorViewController.h
//  GottaFeeling
//
//  Created by Denis Hennessy on 25/10/2012.
//  Copyright (c) 2012 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NoteEditorViewController;

@protocol NoteEditorViewControllerDelegate <NSObject>
- (void)noteEditorDidCancel:(NoteEditorViewController *)controller;
- (void)noteEditorDidDone:(NoteEditorViewController *)controller;
@end

@interface NoteEditorViewController : UIViewController {
    UITextView *textView;
}

@property (readwrite, retain) NSString *text;
@property (assign) id<NoteEditorViewControllerDelegate> delegate;

@end
