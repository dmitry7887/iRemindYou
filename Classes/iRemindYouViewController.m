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

	MapView* mapView = [[[MapView alloc] initWithFrame:
						 CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
	
	[self.view addSubview:mapView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showViewController:) name:@"showViewController" object:nil];

	

    
    Place* home = [[[Place alloc] init] autorelease];
	home.name = @"Home";
	home.description = @"Sweet home";
	home.latitude = 45.029598;
	home.longitude = 28.972985;
	
	Place* office = [[[Place alloc] init] autorelease];
	office.name = @"Office";
	office.description = @"Bad office";
	office.latitude = 41.033586;
	office.longitude = 28.984546;
	
	Place* home2 = [[[Place alloc] init] autorelease];
	home2.name = @"Home2";
	home2.description = @"Bad home";
	home2.latitude = 45.029598;
	home2.longitude = 28.884546;
    
    
	[mapView showRouteFrom:home to:office];
//	[mapView showRouteFrom:office to:home2];

}

- (void)showViewController:(NSNotification *)notification {
    [self presentModalViewController:[notification object] animated:YES];
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
    [super dealloc];
}


@end
