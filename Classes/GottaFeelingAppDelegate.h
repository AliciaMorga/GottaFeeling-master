//
//  GottaFeelingAppDelegate.h
//  GottaFeeling
//
//  Created by Denis on 01/11/2010.
//  Copyright (c) 2010 Peer Assembly. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface GottaFeelingAppDelegate : NSObject <SKPaymentTransactionObserver, CLLocationManagerDelegate, UIApplicationDelegate, UITabBarControllerDelegate, SKProductsRequestDelegate> {
    SKProduct *upgradeProduct;
    SKProductsRequest *productsRequest;
    MBProgressHUD *purchaseHUD;
    
    UIWindow *window;
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    UITabBarController *tabBarController;
    CLLocationManager *locationManager;
	CLLocationCoordinate2D myLocation;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic) CLLocationCoordinate2D myLocation;

+ (GottaFeelingAppDelegate *)instance;
+ (NSManagedObjectContext *)managedObjectContext;

- (NSString *)applicationDocumentsDirectory;
- (void)updateReminders;

- (void)requestUpgradeProductReports;
- (void)completePurchase;

- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

@end
