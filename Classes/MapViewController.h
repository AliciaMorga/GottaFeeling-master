//
//  MapViewController.h
//  GottaFeeling
//
//  Created by Denis on 28/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface MapViewController : UIViewController <MKMapViewDelegate> {
    MKMapView *mapView;
}

@end
