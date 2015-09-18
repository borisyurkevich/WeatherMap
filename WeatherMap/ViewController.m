//
//  ViewController.m
//  WeatherMap
//
//  Created by Boris Yurkevich on 09/09/2015.
//  Copyright (c) 2015 Boris Yurkevich. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+ColorAtPixel.h"

static double const kelvinDiff = 273.15;

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *myLocation;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Create the core location manager object
	_locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	
	// This is the most important property to set for the manager. It ultimately determines how the manager will
	// attempt to acquire location and thus, the amount of power that will be consumed.
	self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	
	[self.locationManager requestWhenInUseAuthorization];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	self.myLocation = newLocation;
	[self moveMap];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	// The location "unknown" error simply means the manager is currently unable to get the location.
	// We can ignore this error for the scenario of getting a single location fix, because we already have a
	// timeout that will stop the location manager to save power.
	//
	if ([error code] != kCLErrorLocationUnknown) {
		[self stopUpdatingLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
		self.mapView.showsUserLocation = YES;
		
		[self.locationManager startUpdatingLocation];
		
		[self performSelector:@selector(stopUpdatingLocation)
				   withObject:nil
				   afterDelay:20.0];
	}
}

- (void)stopUpdatingLocation {
	[self.locationManager stopUpdatingLocation];
	self.locationManager.delegate = nil;
}

#pragma mark - Alert delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
	}
}

#pragma mark - Other

- (IBAction)localHandler:(UIBarButtonItem *)sender {
	if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"No access."
							  message:@"You can allow it in the Settings."
							  delegate:self
							  cancelButtonTitle:@"Cancel"
							  otherButtonTitles:@"Settings", nil];
		[alert show];
	} else {
		[self moveMap];
	}
}

- (IBAction)getWeather:(id)sender {
	CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.mapView.region.center.latitude longitude:self.mapView.region.center.longitude];
	[self updateTemperatureForLocation:loc];
}

- (void) moveMap {
	CLLocationCoordinate2D loc = self.myLocation.coordinate;
	MKCoordinateSpan span = MKCoordinateSpanMake(0.3, 0.3);
	MKCoordinateRegion reg = MKCoordinateRegionMake(loc, span);
	[self.mapView setRegion:reg animated:YES];
	// Deleay is needed to make sure map finished scrolling
	[self performSelector:@selector(getWeather:) withObject:nil afterDelay:2.0];
}

- (void)updateTemperatureForLocation:(CLLocation *)newLocation {
	NSString *query = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%g&lon=%g'", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
	
	NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:query]];
	NSError *jsonError = [NSError new];
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
														 options:NSJSONReadingMutableContainers
														   error:&jsonError];
	if (json) {
		NSDictionary *main = [json valueForKey:@"main"];
		if (main) {
			NSString *temp = [main valueForKey:@"temp"];
			double t = [temp doubleValue];
			double tCelcius = t - kelvinDiff;
			
			// Location name
			NSString *namePlaceholder = @"";
			NSString *name = [json valueForKey:@"name"];
			if (name) {
				namePlaceholder = [NSString stringWithFormat:@"%@ - ", name];
			}
			
			// Set weather description
			NSDictionary *weather = [json valueForKey:@"weather"];
			NSString *descriptionPlaceholder = @"";
			if (weather) {
				NSArray *mainDescription = [weather valueForKey:@"main"];
				if (mainDescription) {
					descriptionPlaceholder = mainDescription[0];
				}
			}
			
			self.title = [NSString stringWithFormat:@"%@%.f° %@",namePlaceholder, tCelcius, descriptionPlaceholder];
			// Showing zero places after decimel
			
			UIImage *colors = [UIImage imageNamed:@"rainbow.png"];
			CGFloat fahreinheitT = ((tCelcius * 9) / 5) + 32;
			UIColor *tempColor = [colors colorForTemperature:fahreinheitT];
			self.view.backgroundColor = tempColor;
		}
	}
}

@end
