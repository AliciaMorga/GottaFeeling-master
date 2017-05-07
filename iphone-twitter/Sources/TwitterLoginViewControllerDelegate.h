//
//  TwitterLoginViewControllerDelegate.h
//  GottaFeeling
//
//  Created by Denis on 02/01/2011.
//  Copyright 2011 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TwitterConsumer;
@class TwitterToken;
@class TwitterLoginViewController;

@protocol TwitterLoginViewControllerDelegate
- (void) twitterLoginViewControllerDidCancel: (TwitterLoginViewController*) twitterLoginViewController;
- (void) twitterLoginViewController: (TwitterLoginViewController*) twitterLoginViewController didSucceedWithToken: (TwitterToken*) token;
- (void) twitterLoginViewController: (TwitterLoginViewController*) twitterLoginViewController didFailWithError: (NSError*) error;
@end
