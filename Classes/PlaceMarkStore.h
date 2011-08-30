//
//  PlaceMarkStore.h
//  
//
//  Created by Dmitry Gankevich on 29.08.11.
//  Copyright 2011 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaceMark.h"
#import <MapKit/MapKit.h>


@interface PlaceMarkStore : NSObject<EKEventEditViewDelegate, MKReverseGeocoderDelegate>{

    NSMutableArray *placeMarkList;
    MKMapView* mapView;
    UIViewController *viewController;
    
    EKEventStore *eventStore;
    EKCalendar *defaultCalendar;
    
    MKReverseGeocoder *reverseGeocoder;
    PlaceMark *placeMarkInEdit;
    BOOL EditState;

}

@property (nonatomic, readonly) NSMutableArray *placeMarkList;
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;
@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) EKCalendar *defaultCalendar;


- (NSArray *) fetchEventsForToday;

-(id) initWithView: (MKMapView*) mapViewDelegate;
-(void) addPlaceMark: (PlaceMark*) placeMark;
-(void) editPlaceMark: (PlaceMark*) placeMark;
-(void) removePlaceMark: (PlaceMark*) placeMark;


- (IBAction)reverseGeocodeCurrentLocation;
- (IBAction)reverseGeocodeByLocation:(CLLocationCoordinate2D) coordinate;

@end
