//
//  HintViewController.m
//  GottaFeeling
//
//  Created by Sheldon Conaty on 27/04/2011.
//  Copyright 2011 Peer Assembly. All rights reserved.
//

#import "HintViewController.h"

#define USER_KEY_COUNTER    @"launchHintCounter"
#define COUNTER_WHY         2
#define COUNTER_THOUGHTS    3
#define COUNTER_SHARE       4
#define COUNTER_STOP        5                           // Don't increment pass this (for future hint support)

static BOOL hintAlreadyChecked;


@implementation HintViewController
@synthesize closeButton, hintImageView;

+ (void)applicationDidBecomeActive {
    hintAlreadyChecked = NO;
}

+ (void)incrementLaunchCounter {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger counter = [userDefaults integerForKey:USER_KEY_COUNTER];
    if (counter < COUNTER_STOP)
        [userDefaults setInteger:counter+1 forKey:USER_KEY_COUNTER];
    NSLog(@"incrementLaunchCounter called, count = %d", counter);
}

+ (BOOL)shouldDisplayHint {
    if (hintAlreadyChecked)
        return NO;
    hintAlreadyChecked = YES;
    
    [HintViewController incrementLaunchCounter];
    
    NSInteger counter = [[NSUserDefaults standardUserDefaults] integerForKey:USER_KEY_COUNTER];
    
    if ((counter == COUNTER_WHY) || (counter == COUNTER_THOUGHTS) || (counter == COUNTER_SHARE))
        return YES;
    else
        return NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (IBAction)doClose {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger counter = [[NSUserDefaults standardUserDefaults] integerForKey:USER_KEY_COUNTER];

    NSString *langCode = @"";
    NSArray *languages = [NSLocale preferredLanguages];
    for (NSString *language in languages) {
        if ([language isEqualToString:@"en"]) {
            break;
        }
        if ([language isEqualToString:@"es"]) {
            langCode = @"SP";
            break;
        }
    }

    NSString *filePrefix = @"";
    switch (counter) {
        case COUNTER_WHY:
            filePrefix = @"helpScreenWhyTrack";
            break;
        case COUNTER_THOUGHTS:
            filePrefix = @"helpScreenThoughtsVs";
            break;
        case COUNTER_SHARE:
            filePrefix = @"helpScreenShare";
            break;
    }
    
    hintImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png", filePrefix, langCode]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
