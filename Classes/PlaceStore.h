//
//  PlaceMarkStore.h
//  
//
//  Created by Dmitry Gankevich on 29.08.11.
//  Copyright 2011 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaceMark.h"
#import <EventKitUI/EventKitUI.h>

@interface PlaceStore : NSObject<EKEventEditViewDelegate, MKReverseGeocoderDelegate>{

    NSMutableSet *placeList;
   
    EKEventStore *eventStore;
    EKCalendar *defaultCalendar;
    
    MKReverseGeocoder *reverseGeocoder;
    Place *placeEdit;
    BOOL EditState;
    Place * placeToRemind;
}

@property (nonatomic, readonly) NSMutableSet *placeList;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;
@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) EKCalendar *defaultCalendar;
@property (nonatomic, retain) Place * placeToRemind;


+ (PlaceStore *)sharedPlaceStore;
- (NSArray *) fetchEventsForToday;
- (Place *) getPlaceToRemind;

-(void) addPlace: (Place*) place;
-(void) editPlace: (Place*) place;
-(void) removePlace: (Place*) place;
-(void) updatePlace: (Place*) place;
-(void) resetPlaceToRemind;
-(void) setPlaceToRemind;

- (IBAction)reverseGeocodeCurrentLocation;
- (IBAction)reverseGeocodeByLocation:(CLLocationCoordinate2D) coordinate;

@end
