//
//  MapViewController.h
//
//


#import <MapKit/MapKit.h>
#import "RegexKitLite.h"
#import "Place.h"
#import "PlaceMark.h"
#import "PlaceStore.h"

@interface MapView : UIView<MKMapViewDelegate> {

	MKMapView* mapView;
	UIImageView* routeView;
	
	NSArray* routes;
	
	UIColor* lineColor;
    PlaceStore* placeStore;
    NSString* timeToPlaceMark;
}

@property (nonatomic, retain) UIColor* lineColor;
@property(nonatomic, retain) MKMapView *mapView;
@property(nonatomic, retain) PlaceStore* placeStore;

-(void) showRouteFrom: (Place*) f to:(Place*) t;
-(PlaceMark *) findPlaceMarkByPlace:(Place *) p;


@end
