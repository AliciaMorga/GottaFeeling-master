//
//  RecordViewController.m
//  GottaFeeling
//
//  Created by Denis on 12/11/2010.
//  Copyright (c) 2010 Peer Assembly. All rights reserved.
//

#import "RecordViewController.h"
#import "GottaFeelingAppDelegate.h"
#include "Constants.h"
#import "Feeling.h"
#import "TwitterToken.h"
#import "TwitterConsumer.h"
#import "TwitterLoginViewController.h"
#import "TwitterComposeViewController.h"

#define TWITTER_KEY     @"3Kh9l9BSHdpJrvgGqvrA"
#define TWITTER_SECRET  @"oazpox1DM2DBfNcbSRHuvgjznQO9pHGPTOcdbjtEw"

extern NSString *navBackground;

#pragma mark VerticalAlign

@interface UILabel (VerticalAlign)
- (void)alignTop;
@end


@implementation UILabel (VerticalAlign)
- (void)alignTop {
    CGSize fontSize = [self.text sizeWithFont:self.font];
    
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    
    CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    
    for(int i=0; i< newLinesToPad; i++) {
        self.text = [self.text stringByAppendingString:@"\n "];
    }
}

@end

@implementation RecordViewController
@synthesize allowDeletion, allowNewFeeling, deleteButton, feeling, feelingImageView, feelingLabel, newFeelingButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    feelingLabel.text = NSLocalizedString(feeling.feeling, nil);
    feelingImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Drawing%@.png", feeling.image]];
    
    if (!allowDeletion)
        deleteButton.hidden = YES;
    if (!allowNewFeeling)
        newFeelingButton.hidden = YES;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"feeling" ofType:@"caf"];    
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundFeeling);
    
	_consumer = [[TwitterConsumer alloc] initWithKey:TWITTER_KEY secret:TWITTER_SECRET];
   
	NSData* tokenData = [[NSUserDefaults standardUserDefaults] dataForKey: @"Token"];
	if (tokenData != nil) {
		_token = (TwitterToken*) [[NSKeyedUnarchiver unarchiveObjectWithData: tokenData] retain];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"playSounds"])
        AudioServicesPlaySystemSound(soundFeeling);
}

- (IBAction)newFeeling {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)deleteFeeling {
    // Delete the managed object for the given index path
    NSManagedObjectContext *context = [GottaFeelingAppDelegate managedObjectContext];
    [context deleteObject:feeling];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self newFeeling];
}


#pragma mark -
#pragma Share a Feeling

- (IBAction)shareFeeling {
	UIActionSheet *sheet = [[UIActionSheet alloc] 
                            initWithTitle:nil
                            delegate:self 
                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button") 
                            destructiveButtonTitle:nil 
                            otherButtonTitles:NSLocalizedString(@"Share by Email",@"Share by Email button"), NSLocalizedString(@"Share on Facebook",@"Share on Facebook button"), NSLocalizedString(@"Share on Twitter",@"Share on Twitter button"), nil ];
	sheet.actionSheetStyle = UIActionSheetStyleDefault;
	[sheet showInView:[self.view superview]];
}

- (IBAction)showNote:(id)sender {
    NoteEditorViewController *noteEditor = [[[NoteEditorViewController alloc] init] autorelease];
    noteEditor.delegate = self;
    noteEditor.text = feeling.notes;
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:noteEditor] autorelease];
    [self presentModalViewController:navController animated:YES];
}

#pragma mark - NoteEditorViewControllerDelegate

- (void)noteEditorDidCancel:(NoteEditorViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)noteEditorDidDone:(NoteEditorViewController *)controller {
    feeling.notes = [controller.text copy];
    NSManagedObjectContext *context = [GottaFeelingAppDelegate managedObjectContext];
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Save error: %@, %@", error, [error userInfo]);
        for (id errorObject in [[error userInfo] valueForKey:NSDetailedErrorsKey]) {
            NSLog(@"Detailed error: %@", errorObject);
        }
        error = nil;
        // TODO: Alert user?
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)openTweetComposerWith:(NSString *)msg {
	TwitterComposeViewController* twitterComposeViewController = [[TwitterComposeViewController new] autorelease];
	if (twitterComposeViewController != nil)
	{
		twitterComposeViewController.consumer = _consumer;
		twitterComposeViewController.token = _token;
		twitterComposeViewController.message = msg;
		twitterComposeViewController.delegate = self;

		UINavigationController* navigationController = [[[UINavigationController alloc] initWithRootViewController: twitterComposeViewController] autorelease];
		if (navigationController != nil) {
			[self presentModalViewController: navigationController animated: YES];
		}
	}
}


- (void)shareAsTweet:(NSString *)msg {
	if (_token == nil) {
		TwitterLoginViewController* twitterLoginViewController = [[TwitterLoginViewController new] autorelease];
		if (twitterLoginViewController != nil)
		{
			twitterLoginViewController.consumer = _consumer;
			twitterLoginViewController.delegate = self;

			UINavigationController* navigationController = [[[UINavigationController alloc] initWithRootViewController: twitterLoginViewController] autorelease];
			if (navigationController != nil) {
				[self presentModalViewController: navigationController animated: YES];
			}
		}
	} else {
		[self openTweetComposerWith:msg];
	}
}

#pragma mark -

- (void) twitterLoginViewControllerDidCancel: (TwitterLoginViewController*) twitterLoginViewController
{
	[twitterLoginViewController dismissModalViewControllerAnimated: YES];
}

- (void) twitterLoginViewController: (TwitterLoginViewController*) twitterLoginViewController didSucceedWithToken: (TwitterToken*) token
{
	_token = [token retain];

	// Save the token to the user defaults

	[[NSUserDefaults standardUserDefaults] setObject: [NSKeyedArchiver archivedDataWithRootObject: _token] forKey: @"Token"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// Open the tweet composer and dismiss the login screen

    NSString *subject = [NSString stringWithFormat:NSLocalizedString(@"I'm feeling %@",@"String send to twitter to indicate what the user is feeling"), NSLocalizedString(feeling.feeling, nil)];
    subject = [subject stringByAppendingString:@"\n@gottafeelingapp"];
	TwitterComposeViewController* twitterComposeViewController = [[TwitterComposeViewController new] autorelease];
	if (twitterComposeViewController != nil)
	{
		twitterComposeViewController.consumer = _consumer;
		twitterComposeViewController.token = _token;
		twitterComposeViewController.message = subject;
		twitterComposeViewController.delegate = self;
		
		[twitterLoginViewController.navigationController pushViewController: twitterComposeViewController animated: YES];
	}
}

- (void) twitterLoginViewController: (TwitterLoginViewController*) twitterLoginViewController didFailWithError: (NSError*) error
{
	NSLog(@"twitterLoginViewController: %@ didFailWithError: %@", self, error);
}

#pragma mark -

- (void) twitterComposeViewControllerDidCancel: (TwitterComposeViewController*) twitterComposeViewController
{
	[twitterComposeViewController dismissModalViewControllerAnimated: YES];
}

- (void) twitterComposeViewControllerDidSucceed: (TwitterComposeViewController*) twitterComposeViewController
{
	[twitterComposeViewController dismissModalViewControllerAnimated: YES];
}

- (void) twitterComposeViewController: (TwitterComposeViewController*) twitterComposeViewController didFailWithError: (NSError*) error
{
	[twitterComposeViewController dismissModalViewControllerAnimated: YES];
}

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *subject = [NSString stringWithFormat:NSLocalizedString(@"I'm feeling %@",@"String send as an email to indicate what the user is feeling"), NSLocalizedString(feeling.feeling, nil)];
	switch (buttonIndex) {
		case 0:	{					// Share by Email
                navBackground = @"NavBlank.png";        // Ensure composer will have no navigation bar background image
                float version = [[[UIDevice currentDevice] systemVersion] floatValue];
                if (version >= 5.0) {
                    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:navBackground] forBarMetrics: UIBarMetricsDefault];
                } else {
                    [self.navigationController.navigationBar setNeedsDisplay];
                }
                MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
                controller.mailComposeDelegate = self;
                [controller setSubject:subject];
                [controller setMessageBody:subject isHTML:NO]; 
                [self presentModalViewController:controller animated:YES];
                [controller release];
            }
			break;
		case 1:	{					// Share on Facebook
                NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               FB_APP_ID, @"api_key",
                                               subject, @"message",
                                               NSLocalizedString(@"Share on Facebook",@"Text that appears to share on facebook"),  @"user_message_prompt",
                                               nil];
                Facebook *facebook = [[Facebook alloc] init];
                [facebook dialog:@"stream.publish" andParams:params andDelegate:self];
            }
			break;
		case 2:						// Share on Twitter
            subject = [subject stringByAppendingString:@"\n@gottafeelingapp"];
            [self shareAsTweet:subject];
            navBackground = nil;
			break;
		default:
			break;
	}
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    NSLog(@"Menu cancelled");
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    AudioServicesDisposeSystemSoundID(soundFeeling);
    [feeling release];
    [super dealloc];
}

@end
