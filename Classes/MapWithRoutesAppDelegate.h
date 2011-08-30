//
//  MapWithRoutesAppDelegate.h
//  MapWithRoutes
//
//

#import <UIKit/UIKit.h>

@class MapWithRoutesViewController;

@interface MapWithRoutesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MapWithRoutesViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MapWithRoutesViewController *viewController;

@end

