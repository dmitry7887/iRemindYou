//
//  MapWithRoutesViewController.h
//  MapWithRoutes
//
//

#import <UIKit/UIKit.h>
#import "MapView.h"
#import "PlaceStore.h"


@interface iRemindYouViewController : UIViewController<CLLocationManagerDelegate> {
    CLLocationManager* locationManager;
    CLLocation* currentLocation;
    MapView* mapView;
    BOOL needUpdate;
}
@end

