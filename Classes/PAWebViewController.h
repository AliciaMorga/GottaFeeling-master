//
//  PAWebViewController.h
//
//  Copyright (c) 2012 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAWebViewController : UIViewController {
    UIWebView *mainWebView;
}

@property (nonatomic, retain) NSURL *URL;

- (id)initWithURL:(NSURL *)URL;

@end
