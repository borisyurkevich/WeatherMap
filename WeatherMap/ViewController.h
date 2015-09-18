//
//  ViewController.h
//  WeatherMap
//
//  Created by Boris Yurkevich on 09/09/2015.
//  Copyright (c) 2015 Boris Yurkevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

