//
//  MapViewController.m
//  GottaFeeling
//
//  Created by Denis on 28/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import "GottaFeelingAppDelegate.h"
#import "MapViewController.h"
#import "Feeling.h"

@implementation MapViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Set height to 337 to make sure google logo is visible
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 337)];
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    CLLocationCoordinate2D center = GottaFeelingAppDelegate.instance.myLocation;
    if (center.latitude == 0 && center.longitude == 0) {
        center = mapView.centerCoordinate;
    }
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(center, 20000, 20000);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:NO];
    [self.view addSubview:mapView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [mapView removeAnnotations:mapView.annotations];
    NSError *error = nil; 
    NSManagedObjectContext *managedObjectContext = [GottaFeelingAppDelegate managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:Feeling.entityName inManagedObjectContext:managedObjectContext]];
    NSArray *feelings = [managedObjectContext executeFetchRequest:request error:&error];
    for (Feeling *feeling in feelings) {
        if (feeling.latitude && [feeling.latitude floatValue] != 0 && feeling.longitude && [feeling.longitude longValue] != 0) {
            [mapView addAnnotation:feeling];
        }
    }
}

#pragma mark -
#pragma mark MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKPinAnnotationView *view = nil;
	
	if (annotation != _mapView.userLocation) {
		view = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
		
		if (nil == view) {
			view = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"identifier"] autorelease];
            [view setCanShowCallout:YES];
            [view setAnimatesDrop:YES];
		}
        
		[view setPinColor:MKPinAnnotationColorRed];
	}
	
	return view;
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
    [super dealloc];
}


@end
