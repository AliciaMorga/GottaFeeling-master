//
//  TwitterComposeViewControllerDelegate.h
//  GottaFeeling
//
//  Created by Denis on 02/01/2011.
//  Copyright 2011 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TwitterToken;
@class TwitterConsumer;
@class TwitterComposeViewController;

@protocol TwitterComposeViewControllerDelegate
- (void) twitterComposeViewControllerDidCancel: (TwitterComposeViewController*) twitterComposeViewController;
- (void) twitterComposeViewControllerDidSucceed: (TwitterComposeViewController*) twitterComposeViewController;
- (void) twitterComposeViewController: (TwitterComposeViewController*) twitterComposeViewController didFailWithError: (NSError*) error;
@end
