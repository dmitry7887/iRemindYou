//
//  PlaceMark.h
//
//
#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <MapKit/MapKit.h>
#import "Place.h"

@interface PlaceMark : NSObject <MKAnnotation> {

	CLLocationCoordinate2D coordinate;
	Place* place;//Store place
    EKEvent* event;//Store event
	
    
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) Place* place;
@property (nonatomic, retain) EKEvent *event;


-(id) initWithPlace: (Place*) p;
-(id) initWithCoordinate: (CLLocationCoordinate2D) currentCoordinate;

@end
