//
//  MapWithRoutesViewController.h
//  MapWithRoutes
//
//

#import <UIKit/UIKit.h>
#import "MapView.h"
#import "PlaceStore.h"


@interface iRemindYouViewController : UIViewController<CLLocationManagerDelegate> {
    UIToolbar *toolbar;
    CLLocation* currentLocation;
    MapView* mapView;
    BOOL needUpdate;
@public
    CLLocationManager     *locationManager;
@private
    BOOL                  isExecutingInBackground;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isExecutingInBackground;
@end

