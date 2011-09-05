//
//  MapWithRoutesViewController.m
//  MapWithRoutes
//
//

#import "iRemindYouViewController.h"
e
@implementation iRemindYouViewController

@synthesize isExecutingInBackground, locationManager;

- (BOOL) isMultitaskingSupported{
    
    BOOL result = NO;
    
    UIDevice *device = [UIDevice currentDevice];
    
    if (device != nil){
        if ([device respondsToSelector:
             @selector(isMultitaskingSupported)] == YES){
            /* Make sure this only gets compiled on iOS SDK 4.0 and
             later so we won't get any compile-time warnings */
#ifdef __IPHONE_4_0
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0)
            result = [device isMultitaskingSupported];
#endif
#endif
        }
    }
    
    return(result);
    
}

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
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
    needUpdate=YES;

    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showViewController:) 
                                                 name:@"showViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRoutes:) name:@"refreshRoutes" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localNotify:) name:@"localNotify" object:nil];
    if ([self isMultitaskingSupported] == YES){
        
        [[NSNotificationCenter defaultCenter] 
         addObserver:self
         selector:@selector(handleEnteringBackground:)
         name:UIApplicationDidEnterBackgroundNotification
         object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(handleEnteringForeground:)
         name:UIApplicationWillEnterForegroundNotification
         object:nil];
        
    } else {
        NSLog(@"Multitasking is not enabled.");
    }
     /* Now let's create the location manager and start getting
     location change messages */
    CLLocationManager *newManager = [[CLLocationManager alloc] init];
    self.locationManager = newManager;
    [newManager release];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
  	mapView = [[[MapView alloc] initWithFrame:
						 CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
   [self.view addSubview:mapView];
    //create toolbar using new
    toolbar = [UIToolbar new];
    toolbar.barStyle = UIBarStyleDefault;
    [toolbar sizeToFit];
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [toolbar frame].size.height;
        
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.view.bounds;
        
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
        
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
  
    CGFloat toolBarTop = rootViewHeight-toolbarHeight;
    
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, toolBarTop, rootViewWidth, toolbarHeight);
    
    //Reposition and resize the receiver
    [toolbar setFrame:rectArea];
        
    //Create a button
    UIBarButtonItem *locationButton = [[UIBarButtonItem alloc] initWithTitle:@"Location" style:UIBarButtonItemStyleBordered target:self action:@selector(locationClicked:)];
    UIBarButtonItem *drivingModeButton = [[UIBarButtonItem alloc] initWithTitle:@"Driving" style:UIBarButtonItemStyleBordered target:self action:@selector(travelModeClicked:)];
    UIBarButtonItem *dalkingModeButton = [[UIBarButtonItem alloc] initWithTitle:@"Walking" style:UIBarButtonItemStyleBordered target:self action:@selector(travelModeClicked:)];
    UIBarButtonItem *bicycingModeButton = [[UIBarButtonItem alloc] initWithTitle:@"Bicycling" style:UIBarButtonItemStyleBordered target:self action:@selector(travelModeClicked:)];
    
    
    [toolbar setItems:[NSArray arrayWithObjects:locationButton,drivingModeButton, dalkingModeButton, bicycingModeButton, nil]];
    
    //Add the toolbar as a subview to the navigation controller.
    [self.view addSubview:toolbar];
}
- (void)showViewController:(NSNotification *)notification {
    [self presentModalViewController:[notification object] animated:YES];
}

- (void) travelModeClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"travelMode" object:[NSNumber numberWithUnsignedInt:[[toolbar items] indexOfObject:sender]]];
    needUpdate=YES;
}

- (void) locationClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoLocation" object:[NSNumber numberWithUnsignedInt:[[toolbar items] indexOfObject:sender]]];
}

-(void) refreshRoutes:(NSNotification *)notification {
        needUpdate=YES;
}

-(void) localNotify:(NSNotification *)notification;
{
    Place * place=[notification object];
    NSTimeInterval ss =-[place.timeToPlace intValue];
    NSLog(@"startdate= %@",place.event.startDate);
    NSLog(@"ss= %f",ss);
    
    NSDate *notificationDate = [NSDate dateWithTimeInterval:ss sinceDate:place.event.startDate];
    NSLog(@"notifyDate= %@",notificationDate);
    
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = notificationDate; note.timeZone = [NSTimeZone defaultTimeZone];
    note.alertBody = [@"Let's go to place: " stringByAppendingString:place.name];
    note.alertAction = @"View";
    note.soundName = UILocalNotificationDefaultSoundName;
    note.applicationIconBadgeNumber= 1;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"User" forKey:@"username"];
    note.userInfo = dict;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
    [note release];
}

- (void) handleEnteringBackground:(NSNotification *)paramNotification{
    
    /* We have entered background */
    NSLog(@"Going to background.");
    
    self.isExecutingInBackground = YES;
    
    if (locationManager != nil){
        /* If we are going to the background, let's reduce the accuracy
         of the location manager so that we use less system resources */
        locationManager.desiredAccuracy = 
        kCLLocationAccuracyHundredMeters;
    }
    
}

- (void) handleEnteringForeground:(NSNotification *)paramNotification{
    
    /* We have entered foreground */
    NSLog(@"Coming to foreground");
    
    self.isExecutingInBackground = NO;
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    
    if (locationManager != nil){
        /* Now that we are in the foreground, we can increase the accuracy
         of the location manager */
        locationManager.desiredAccuracy = 
        kCLLocationAccuracyBest;
    }
    
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
    if ([self isMultitaskingSupported] == YES){
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showViewController" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshRoutes" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"localNotify" object:nil];
    }
    /* Get rid of the location manager in cases such as
     a low memory warning */
    if (self.locationManager != nil){
        [self.locationManager stopUpdatingLocation];
    }
    self.locationManager = nil;
    mapView=nil;
}

- (void)dealloc {
    [mapView release];
    /* make sure we also deallocate our location manager here */
    if (locationManager != nil){
        [locationManager stopUpdatingLocation];
    }
    [locationManager release];
    [currentLocation release];
    [super dealloc];
}

#pragma mark -
#pragma marl Delegates
-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocationDistance distance;
    if (needUpdate){
        distance=1000;
    }
    else{
        distance=[currentLocation distanceFromLocation:newLocation];
    }
    NSLog(@"distance= %f",distance); 
    if (distance>100 && mapView.canRouting) {
        if (currentLocation){
            [currentLocation release];
        }
        currentLocation=[newLocation copy];
        Place *placeFrom=[[[Place alloc] init] autorelease];
        placeFrom.latitude=currentLocation.coordinate.latitude;
        placeFrom.longitude=currentLocation.coordinate.longitude;
        Place *placeTo=[[PlaceStore sharedPlaceStore] placeToRemind];
        if (placeTo){
            if (self.isExecutingInBackground == YES){
                /* Just process the location and do not do any
                 heavy processing here */
                NSLog(@"Calc time to remind...");
                [mapView calculateTimeFrom:placeFrom to: placeTo];
            } else {
                /* Display messages, alerts and etc if needed because
                 we are not in the background */
                NSLog(@"Refresh routes...");
                [mapView showRouteFrom:placeFrom to:placeTo];
            }
            needUpdate=NO;
            if ([placeTo.event.startDate timeIntervalSinceNow]>0){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"localNotify" object:placeTo];
            }    
        }
    }
}

@end
