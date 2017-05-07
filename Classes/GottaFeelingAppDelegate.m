//
//  GottaFeelingAppDelegate.m
//  GottaFeeling
//
//  Created by Denis on 01/11/2010.
//  Copyright (c) 2010 Peer Assembly. All rights reserved.
//

#import "Flurry.h"
//#import "HTNotifier.h"
#import "Constants.h"
#import "HintViewController.h"
#import "GottaFeelingAppDelegate.h"
#import "SKProduct+LocalizedPrice.h"
#import <CommonCrypto/CommonDigest.h>                   // Required by AdMob tracking methods

// Constants controller when reminders are fired

#define MIN_HOUR        8
#define MAX_HOUR        20
#define MIN_DELAY       (60 * 15)
#define REMINDER_DAYS   2

//#define HOPTOAD_API_KEY @"b460cfb0720f5bafaa75528010c2a133"

@implementation GottaFeelingAppDelegate

@synthesize myLocation, tabBarController, window;

+ (GottaFeelingAppDelegate *)instance {
	return (GottaFeelingAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Load default defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
    
    // Uncomment the following line to enable all the reports
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:IN_APP_REPORTS_ENABLED];

    // Register an observer for any completed transactions
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    application.statusBarHidden = NO;
    application.statusBarStyle = UIStatusBarStyleBlackOpaque;
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBlank.png"] forBarMetrics: UIBarMetricsDefault];
    }
    
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];

    // Report crashes to hoptoad
//    [HTNotifier startNotifierWithAPIKey:HOPTOAD_API_KEY environmentName:HTNotifierDevelopmentEnvironment];
        
	myLocation.latitude = 0;
	myLocation.longitude = 0;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];

    [self updateReminders];
    
    [Flurry startSession:@"6B3B5IMZKT4Y2NJSCYBM"];

    // AdMob conversion tracking
//    [self performSelectorInBackground:@selector(reportAppOpenToAdMob) withObject:nil];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {

    [locationManager stopUpdatingLocation];
	[locationManager release];
	locationManager = nil;

    // Saves changes in the application's managed object context before the application terminates.
    NSError *error = nil;
    if (managedObjectContext) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Increment launch counter (so correct hint screen will be displayed)
    [HintViewController applicationDidBecomeActive];    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [locationManager stopUpdatingLocation];
	[locationManager release];
	locationManager = nil;
    [self updateReminders];
}

- (void)dealloc {

    [window release];
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [tabBarController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Local Notifications

- (void)cancelLocalNotifications {
    UIApplication *app = [UIApplication sharedApplication];
    if ([app respondsToSelector:@selector(cancelAllLocalNotifications)]) {
        NSLog(@"Local notifications cancelled");
        [app cancelAllLocalNotifications];
    }
}

- (void)scheduleNotificationWithMessage:(NSString *)message at:(NSDate *)fireDate {
	UILocalNotification *notif = [[NSClassFromString(@"UILocalNotification") alloc] init];    
	if (notif == nil)
		return;
	
	notif.timeZone = [NSTimeZone defaultTimeZone];
	notif.repeatCalendar = nil;
	notif.repeatInterval = 0;
	notif.fireDate = fireDate;
	
	notif.alertBody = message;
	
	notif.alertAction = NSLocalizedString(@"View", nil);
	notif.soundName = UILocalNotificationDefaultSoundName;
	[[UIApplication sharedApplication] scheduleLocalNotification:notif];
	[notif release];
	
	NSLog(@"Local notification created to fire at [%@] with message [%@]", fireDate, message);
}

- (void)updateReminders {
    [self cancelLocalNotifications];
    
    NSInteger numberPerDay = [[NSUserDefaults standardUserDefaults] integerForKey:@"reminderFreq"];
    if (numberPerDay == 0)
        return;
    
    // Calculate start and end time for todays reminders
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *dayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:now];
    NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
    [components setDay:[dayComponents day]];
    [components setMonth:[dayComponents month]];
    [components setYear:[dayComponents year]];
    [components setHour:MIN_HOUR];
    NSDate *startTime = [gregorian dateFromComponents:components];
    [components setHour:MAX_HOUR];
    NSDate *endTime = [gregorian dateFromComponents:components];
    
    // Calculate how many already recorded today
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feeling" inManagedObjectContext:[GottaFeelingAppDelegate managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSPredicate *predictate = [NSPredicate predicateWithFormat:@"timeStamp > %@", startTime];
    [fetchRequest setPredicate:predictate];
	NSError *error = nil;
    NSArray *feelings = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    NSInteger numberRecordedToday = [feelings count];
    
    // Create upcoming reminders
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSString *name = [[NSUserDefaults standardUserDefaults] valueForKey:@"firstName"];
    NSString *message;
    if (name && [name length])
        message = [NSString stringWithFormat:STRING_HI_X_HOW_DO_YOU_FEEL, name];
    else
        message = STRING_HI_HOW_DO_YOU_FEEL;

    for (int i=0;i<REMINDER_DAYS;i++) {
        NSTimeInterval startSecs = [startTime timeIntervalSince1970];
        if ([startTime compare:now] < 0) {
            startSecs = [now timeIntervalSince1970];
        }
        NSTimeInterval endSecs = [endTime timeIntervalSince1970];
        NSInteger nReminders = numberPerDay - numberRecordedToday;
        if (startSecs < endSecs && nReminders > 0) {
            NSTimeInterval available = (endSecs - startSecs) - MIN_DELAY * nReminders;
            if (available > 0) {
                NSTimeInterval span = available/nReminders;
                for (int j=0;j<nReminders;j++) {
                    NSTimeInterval offset = (span+MIN_DELAY)*j + arc4random() % (int)span;
                    NSDate *alarmTime = [NSDate dateWithTimeIntervalSince1970:startSecs+offset];
                    [self scheduleNotificationWithMessage:message at:alarmTime];
                }
            }
        }
        
        numberRecordedToday = 0;
        startTime = [startTime dateByAddingTimeInterval:secondsPerDay];
        endTime = [endTime dateByAddingTimeInterval:secondsPerDay];
    }
}


#pragma mark -
#pragma mark Core Data support

// Helper for any other class to access the managed object context
+ (NSManagedObjectContext *)managedObjectContext{
    GottaFeelingAppDelegate *appDelegate = (GottaFeelingAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by loading the versioned model in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel) {
        return managedObjectModel;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GottaFeeling2" ofType:@"momd"];
    NSURL *url = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];

    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"GottaFeeling.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible
         * The schema for the persistent store is incompatible with current managed object model
         Check the error message to determine what the actual problem was.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    myLocation = newLocation.coordinate;
//    NSLog(@"Location updated: %f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    [Flurry setLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude horizontalAccuracy:newLocation.horizontalAccuracy verticalAccuracy:newLocation.verticalAccuracy];
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)awakeFromNib {    
    
//    RootViewController *rootViewController = (RootViewController *)[navigationController topViewController];
//    rootViewController.managedObjectContext = self.managedObjectContext;
}

#pragma mark UIAlertViewDelegate methods
#pragma mark 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            if ([SKPaymentQueue canMakePayments]) {
                [self completePurchase];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Title of an alert to indicate that there was an error") message:NSLocalizedString(@"You do not have permission to complete this transaction",@"String indicating a problem with the transaction") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"OK Button") otherButtonTitles:nil];
                [alertView show];
                [alertView release];
            }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark In App Purchase methods

- (void)requestUpgradeProductReports {
    NSSet *productIdentifiers = [NSSet setWithObject:IN_APP_PURCHASE_REPORTS_APP_ID];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    
    // Display activity indicator while talking with Apple...
    purchaseHUD = [[MBProgressHUD alloc] initWithWindow:window];
    [window addSubview:purchaseHUD];
    [purchaseHUD show:YES];
    
    [productsRequest start];
}

- (void)completePurchase {
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:IN_APP_PURCHASE_REPORTS_APP_ID];
    [[SKPaymentQueue defaultQueue] addPayment:payment];    
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    [purchaseHUD hide:YES];
    [purchaseHUD release];
    
    NSArray *products = response.products;
    NSLog(@"%@", response);
    upgradeProduct = [products count] == 1 ? [[products objectAtIndex:0] retain] : nil;
    if (!upgradeProduct) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"In App Purchase",@"Title of an alert for an in app purchase") message:NSLocalizedString(@"There was a problem processing your request, please try later", @"Text indicating a problem with the in app purchase") delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        for (NSString *invalidProductId in response.invalidProductIdentifiers) {
            NSLog(@"Invalid product id: %@" , invalidProductId);
        }
    } else {
        [self completePurchase];
    }

    // finally release the request we alloc/init’ed in requestUpgradeProductReports
    [productsRequest release];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self completeTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction {
    // Your application should implement these two methods.
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:IN_APP_REPORTS_ENABLED];
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Title of an alert indicating an error") message:NSLocalizedString(@"There was a problem processing the purchase", @"Text indicating an error in the in app purchase") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button") otherButtonTitles:nil];
        [alertView show];
        [alertView release];    
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark - AdMob conversion tracking

#if 0

- (NSString *)hashedISU {
    NSString *result = nil;
    NSString *isu = [UIDevice currentDevice].uniqueIdentifier;

    if(isu) {
        unsigned char digest[16];
        NSData *data = [isu dataUsingEncoding:NSASCIIStringEncoding];
        CC_MD5([data bytes], [data length], digest);

        result = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                  digest[0], digest[1],
                  digest[2], digest[3],
                  digest[4], digest[5],
                  digest[6], digest[7],
                  digest[8], digest[9],
                  digest[10], digest[11],
                  digest[12], digest[13],
                  digest[14], digest[15]];
        result = [result uppercaseString];
    }
    
    return result;
}

- (void)reportAppOpenToAdMob {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // we're in a new thread here, so we need our own autorelease pool
    
    // Have we already reported an app open?
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                        NSUserDomainMask, YES) objectAtIndex:0];
    NSString *appOpenPath = [documentsDirectory stringByAppendingPathComponent:@"admob_app_open"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:appOpenPath]) {
        // Not yet reported -- report now
        NSString *appOpenEndpoint = [NSString stringWithFormat:@"http://a.admob.com/f0?isu=%@&md5=1&app_id=%@",
                                     [self hashedISU], @"393588721"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:appOpenEndpoint]];
        NSURLResponse *response;
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if((!error) && ([(NSHTTPURLResponse *)response statusCode] == 200) && ([responseData length] > 0)) {
            [fileManager createFileAtPath:appOpenPath contents:nil attributes:nil]; // successful report, mark it as such
        }
    }
    
    [pool release];
}
#endif


@end
