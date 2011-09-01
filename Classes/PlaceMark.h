//
//  PlaceMark.h
//
//
#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>
#import "Place.h"

@interface PlaceMark : NSObject <MKAnnotation> {

	CLLocationCoordinate2D coordinate;
	Place* place;//Store place
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) Place* place;



-(id) initWithPlace: (Place*) p;

// Called as a result of dragging an annotation view.
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
