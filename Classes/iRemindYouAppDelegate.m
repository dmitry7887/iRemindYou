//
//  MapWithRoutesAppDelegate.m
//  MapWithRoutes
//
//

#import "iRemindYouAppDelegate.h"
#import "iRemindYouViewController.h"

@implementation iRemindYouAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
