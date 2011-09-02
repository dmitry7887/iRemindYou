//
//  MapWithRoutesViewController.m
//  MapWithRoutes
//
//

#import "iRemindYouViewController.h"

@implementation iRemindYouViewController


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
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
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    needUpdate=YES;
    [locationManager startUpdatingLocation];
  	mapView = [[[MapView alloc] initWithFrame:
						 CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
	
	[self.view addSubview:mapView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showViewController:) 
                                                 name:@"showViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRoutes:) name:@"refreshRoutes" object:nil];
}

- (void)showViewController:(NSNotification *)notification {
    [self presentModalViewController:[notification object] animated:YES];
}

-(void) refreshRoutes:(NSNotification *)notification {
        needUpdate=YES;
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [mapView release];
    [locationManager release];
    [currentLocation release];
    [super dealloc];
}

#pragma mark -
#pragma marl Delegates
-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"Location updated to = %@",newLocation);
    CLLocationDistance distance;
    if (needUpdate){
        distance=1000;
    }
    else{
        distance=[currentLocation distanceFromLocation:newLocation];
    }

    if (distance>100 && mapView.canRouting) {
        NSLog(@"Recalc path...");
        if (currentLocation){
            [currentLocation release];
        }
        currentLocation=[newLocation copy];
        Place *placeFrom=[[[Place alloc] init] autorelease];
        placeFrom.latitude=currentLocation.coordinate.latitude;
        placeFrom.longitude=currentLocation.coordinate.longitude;
        Place *placeTo=[[PlaceStore sharedPlaceStore] placeToRemind];
        if (placeTo){
            [mapView showRouteFrom:placeFrom to:placeTo];
            needUpdate=NO;
        }
        
    }
    
}

@end
