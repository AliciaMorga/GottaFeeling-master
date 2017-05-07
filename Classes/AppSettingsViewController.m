//
//  AppSettingsViewController.m
//  GottaFeeling
//
//  Created by Sheldon Conaty on 25/07/2011.
//  Copyright 2011 Peer Assembly. All rights reserved.
//

#import "AppSettingsViewController.h"
#import "GottaFeelingAppDelegate.h"
#import "PAWebViewController.h"
#import "Feeling.h"
#import "Constants.h"

extern NSString *navBackground;


@implementation AppSettingsViewController

#pragma mark - Utility methods

- (void)displayExportViaMailDialog {
    if ([MFMailComposeViewController canSendMail] == NO) {
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Mail not Configured", @"Alert title, displayed when mail is not available on the device")
                              message:NSLocalizedString(@"Please setup a mail account in your device's settings to be able to send emails", @"Alert message, displayed when mail is not available on the device")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Alert cancel button title, displayed when mail is not available on the device")
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    // Query the feelings from the database
    
    NSManagedObjectContext *managedObjectContext = [GottaFeelingAppDelegate managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[Feeling entityName]
                                                         inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    
    NSError *error = nil;
    NSArray *feelings = [managedObjectContext executeFetchRequest:request error:&error];
    
    // Build the message body
    
    NSMutableString *body = [NSMutableString stringWithCapacity:256];
    [body setString:NSLocalizedString(@"My gottaFeeling recordings, sorted by date:", @"Start of email used to export recorded data")];
    [body appendString:@"\n"];
    
    // Build csv content
    
    NSMutableString *csv = [NSMutableString stringWithCapacity:2000];
    [csv appendString:NSLocalizedString(@"Date,Category,Feeling,Where,Who,Notes", @"Titles of data columns in email used to export recorded data")];
    [csv appendString:@"\n"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MMM-dd HH:mm:ss"];
    
    for (Feeling *feeling in feelings) {
        NSString *notes = feeling.notes;
        if (notes) {
            notes = [notes stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
            notes = [NSString stringWithFormat:@"\"%@\"", notes];
        } else {
            notes = @"";
        }
        [csv appendFormat:@"%@,%@,%@,%@,%@,%@\n",
         [formatter stringFromDate:feeling.timeStamp],
         [NSLocalizedString(feeling.category, nil) lowercaseString],
         [NSLocalizedString(feeling.feeling, nil) lowercaseString],
         [NSLocalizedString(feeling.where, nil) lowercaseString],
         [NSLocalizedString(feeling.who, nil) lowercaseString],
         notes];
    }
    
    NSData *csvData = [csv dataUsingEncoding:NSUTF8StringEncoding];
    
    navBackground = @"NavBlank.png";                    // Ensure composer will have no navigation bar background image
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:navBackground] forBarMetrics: UIBarMetricsDefault];
    } else {
        [self.navigationController.navigationBar setNeedsDisplay];
    }
    
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setSubject:NSLocalizedString(@"My gottaFeeling data", @"Title of email used to export recorded data")];
    [mailViewController setMessageBody:body isHTML:NO];
    [mailViewController addAttachmentData:csvData mimeType:@"text/csv" fileName:NSLocalizedString(@"feelings.csv", nil)];
    
    [self presentModalViewController:mailViewController animated:YES];
    
    [mailViewController release];
}

#pragma mark - UIViewController methods

- (void)viewDidLoad {
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];

    // Since controller is instanstiated via the nib there is no clean way to call initWithConfig, so we
    // handle the initialization here
    
    if (settingsdatasource == nil) {
        NSString *configFile = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"]; 
        settingsdatasource = [[SettingsMetadataSource alloc] initWithConfigFile:configFile];
        
        settingsdatasource.viewcontroller = self;
        settingsdatasource.delegate = self;
    }

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    navBackground = @"NavMain.png";
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:navBackground] forBarMetrics: UIBarMetricsDefault];
    } else {
        [self.navigationController.navigationBar setNeedsDisplay];
    }
    
    // We could be returning from a popped settings view (like how often to trigger notificatiosn).
    // Take oppertunity to resave settings and update local notifications
    
	[settingsdatasource save];
    [[GottaFeelingAppDelegate instance] updateReminders];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    navBackground = @"NavBlank.png";
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:navBackground] forBarMetrics: UIBarMetricsDefault];
    } else {
        [self.navigationController.navigationBar setNeedsDisplay];
    }
}



#pragma mark - SettingsDelegate methods

- (void)customCellWasSelectedAtIndexPath:(NSIndexPath *)indexpath {
    NSLog(@"%d:%d", indexpath.section, indexpath.row);
    
    if (indexpath.section == 2) {
        BOOL reportsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:IN_APP_REPORTS_ENABLED];
        if (reportsEnabled) {
            [self displayExportViaMailDialog];
        } else {
            UIAlertView* alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Export not available", @"Alert title, displayed when export is not available on the device")
                                  message:NSLocalizedString(@"The Export feature is available when you purchase the Advanced Reports feature", @"Alert message, displayed when export is not available on the device")
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Alert cancel button title, displayed when mail is not available on the device")
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    if (indexpath.section == 3) {
        if (indexpath.row == 0) {
            NSString *faqName = NSLocalizedString(@"faq_en", nil);
            NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:faqName ofType:@"html"]];
            PAWebViewController *webViewController = [[PAWebViewController alloc] initWithURL:url];
            webViewController.title = NSLocalizedString(@"Frequently Asked Questions", nil);
            [self.navigationController pushViewController:webViewController animated:YES];
        } else {
            if (![MFMailComposeViewController canSendMail]) {
                UIAlertView* alert = [[UIAlertView alloc]
                                      initWithTitle:NSLocalizedString(@"Mail not Configured", @"Alert title, displayed when mail is not available on the device")
                                      message:NSLocalizedString(@"Please setup a mail account in your device's settings to be able to send emails", @"Alert message, displayed when mail is not available on the device")
                                      delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Alert cancel button title, displayed when mail is not available on the device")
                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
            } else {
                navBackground = @"NavBlank.png";                    // Ensure composer will have no navigation bar background image
                float version = [[[UIDevice currentDevice] systemVersion] floatValue];
                if (version >= 5.0) {
                    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:navBackground] forBarMetrics: UIBarMetricsDefault];
                } else {
                    [self.navigationController.navigationBar setNeedsDisplay];
                }
                MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
                [composer setToRecipients:[NSArray arrayWithObject:@"gottaFeelingapp@gmail.com"]];
                [composer setSubject:NSLocalizedString(@"gottaFeeling", nil)];
                composer.mailComposeDelegate = self;                
                [self presentModalViewController:composer animated:YES];                
            }

        }
    }
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}


@end
