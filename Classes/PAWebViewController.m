//
//  PAWebViewController.m
//
//  Copyright (c) 2012 Peer Assembly. All rights reserved.
//

#import "PAWebViewController.h"

@interface PAWebViewController ()

@end

@implementation PAWebViewController
@synthesize URL;

- (id)initWithURL:(NSURL *)pageURL {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.URL = pageURL;
    }
    return self;
}

- (void)loadView {
    mainWebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    mainWebView.scalesPageToFit = YES;
    [mainWebView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    self.view = mainWebView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
