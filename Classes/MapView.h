//
//  MapViewController.h
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RegexKitLite.h"
#import "Place.h"
#import "PlaceMark.h"
#import "PlaceMarkStore.h"

@interface MapView : UIView<MKMapViewDelegate> {

	MKMapView* mapView;
	UIImageView* routeView;
	
	NSArray* routes;
	
	UIColor* lineColor;
    PlaceMarkStore* placeMarkStore;
}

@property (nonatomic, retain) UIColor* lineColor;
@property(nonatomic, retain) MKMapView *mapView;
@property(nonatomic, retain) PlaceMarkStore* placeMarkStore;

-(void) showRouteFrom: (Place*) f to:(Place*) t;


@end
