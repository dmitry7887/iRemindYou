//
//  PlaceMarkStore.m
// 
//
//  Created by Dmitry Gankevich on 29.08.11.
//  Copyright 2011. All rights reserved.
//

#import "PlaceMarkStore.h"

@implementation PlaceMarkStore
@synthesize placeMarkList, viewController, reverseGeocoder, defaultCalendar, eventStore;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(id) initWithView:(MKMapView *)mapViewDelegate; 
{
	self = [super init];
    placeMarkList=[[NSMutableArray alloc] init];
	if (self != nil) {
		mapView=mapViewDelegate;
        EditState=NO;
        // Initialize an event store object with the init method. Initilize the array for events.
        eventStore = [[EKEventStore alloc] init];
        
        // Get the default calendar from store.
        defaultCalendar = [eventStore defaultCalendarForNewEvents];
        
        // Fetch today's event on selected calendar and put them into the eventsList array
        NSArray *eventsList = [self fetchEventsForToday];
        
        EKEvent *event;
        CLLocationCoordinate2D location; 
        for (event in eventsList){
            NSString *locate=event.location;
            if (locate){
                
                NSRange textRangeLat;
                textRangeLat =[locate rangeOfString:@"lat"];
                
                NSRange textRangeLon;
                textRangeLon =[locate rangeOfString:@" lon"];
                
                if(textRangeLat.location != NSNotFound)
                { 
                    textRangeLat.location=textRangeLat.location+4;
                    textRangeLat.length=textRangeLon.location-textRangeLat.location;
                    textRangeLon.location=textRangeLon.location+5;
                    textRangeLon.length=locate.length-textRangeLon.location;
                    
                    NSString *lon=[locate substringWithRange:textRangeLon];
                    NSString *lat=[locate substringWithRange:textRangeLat];
                 
                    location.latitude=[lat doubleValue];
                    location.longitude=[lon doubleValue];

                    PlaceMark *p = [[PlaceMark alloc] initWithCoordinate:location];
                    
                    
                    p.place.name=event.title;
                    p.place.description=event.notes;
                    p.event=event;
                    
                    [placeMarkList addObject:p];
                    
                    [mapView addAnnotation:p];
                    
                    //Does contain the substring
                }
            }
        }
        
	}
	return self;
}

#pragma mark -
#pragma mark PlaceMark editiong

-(void) addPlaceMark: (PlaceMark*) placeMark;
{
    [placeMarkList addObject:placeMark];
    placeMark.event  = [[EKEvent eventWithEventStore:eventStore] retain];
    placeMark.event.location=[[NSString stringWithFormat:@"lat=%f",placeMark.coordinate.latitude] stringByAppendingString:[NSString stringWithFormat:@" lon=%f",placeMark.coordinate.longitude]];
    
    placeMark.event.startDate = [NSDate date];
    placeMark.event.endDate   = [NSDate dateWithTimeInterval:600 sinceDate:placeMark.event.startDate];
    placeMark.event.notes=placeMark.title;

    placeMarkInEdit=placeMark; 
    [self reverseGeocodeByLocation:placeMarkInEdit.coordinate]; 
}

-(void) editPlaceMark: (PlaceMark*) placeMark;
{
    placeMarkInEdit=placeMark; 
    EditState=YES;
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    // set the addController's event store to the current event store.
    addController.eventStore = eventStore;
    addController.event=placeMark.event;
    
    [viewController  presentModalViewController:addController animated:YES];
    
    addController.editViewDelegate = self;
    
    [addController release];
}

-(void) removePlaceMark: (PlaceMark*) placeMark;
{
    [placeMarkList removeObject:placeMark];
    [mapView removeAnnotation:placeMark];
    placeMarkInEdit=nil;
}
#pragma mark -
#pragma mark ReverseGeocoderDelegate
- (IBAction)reverseGeocodeByLocation:(CLLocationCoordinate2D) coordinate
{
    reverseGeocoder =[[[MKReverseGeocoder alloc] initWithCoordinate:coordinate] autorelease];
    reverseGeocoder.delegate = self;
    [reverseGeocoder start];
}

- (IBAction)reverseGeocodeCurrentLocation
{
    reverseGeocoder =[[[MKReverseGeocoder alloc] initWithCoordinate:placeMarkInEdit.coordinate] autorelease];
    reverseGeocoder.delegate = self;
    [reverseGeocoder start];
    
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    NSLog(@"Cannot obtain address. %@s",errorMessage);
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    
    
    // set the addController's event store to the current event store.
    addController.eventStore = eventStore;
    addController.event=placeMarkInEdit.event;
    
    // present EventsAddViewController as a modal view controller
    [viewController presentModalViewController:addController animated:YES];
    
    addController.editViewDelegate = self;
    
    [addController release];
    
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    
    NSString *placeDescription=[placemark title];

    placeMarkInEdit.event.notes=placeDescription;
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    
    
    // set the addController's event store to the current event store.
    addController.eventStore = eventStore;
    addController.event=placeMarkInEdit.event;
    
    // present EventsAddViewController as a modal view controller
    [viewController presentModalViewController:addController animated:YES];
    
    addController.editViewDelegate = self;
    
    [addController release];
    
}

#pragma mark -
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller 
          didCompleteWithAction:(EKEventEditViewAction)action {
	
	NSError *error = nil;
	EKEvent *thisEvent = controller.event;
	switch (action) {
		case EKEventEditViewActionCanceled:
            if (placeMarkInEdit!=nil && !EditState){
                [placeMarkList removeObject:placeMarkInEdit];
                [placeMarkInEdit.event release];
                [placeMarkInEdit release];
                placeMarkList=nil;
            }
			break;
			
		case EKEventEditViewActionSaved:
			// When user hit "Done" button, save the newly created event to the event store, 
			// and reload table view.
			// If the new event is being added to the default calendar, then update its 
			// eventsList.
			if (defaultCalendar ==  thisEvent.calendar) {
				
                
                if (placeMarkInEdit!=nil){ 
                    placeMarkInEdit.event=thisEvent;
                    placeMarkInEdit.place.name=thisEvent.title;
                    placeMarkInEdit.place.description=thisEvent.notes;
                    placeMarkInEdit.event.location=[[NSString stringWithFormat:@"lat=%f",placeMarkInEdit.coordinate.latitude] stringByAppendingString:[NSString stringWithFormat:@" lon=%f",placeMarkInEdit.coordinate.longitude]];
                    if (EditState){
                        [mapView removeAnnotation:placeMarkInEdit];
                    }
                    [mapView addAnnotation:placeMarkInEdit];
                    
                }
			}
			[controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
			//[self.tableView reloadData];
            
			break;
			
		case EKEventEditViewActionDeleted:
			// When deleting an event, remove the event from the event store, 
			// and reload table view.
			// If deleting an event from the currenly default calendar, then update its 
			// eventsList.
			if (defaultCalendar ==  thisEvent.calendar && placeMarkInEdit!=nil && EditState) {
                [placeMarkList removeObject:placeMarkInEdit];
                [mapView removeAnnotation:placeMarkInEdit];
                [controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
                [placeMarkInEdit release];
                placeMarkInEdit=nil;
			}
            break;
			
		default:
			break;
	}
    EditState=NO;
	// Dismiss the modal view controller
	[controller dismissModalViewControllerAnimated:YES];
}


// Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar.
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
	EKCalendar *calendarForEdit = self.defaultCalendar;
	return calendarForEdit;
}

// Fetching events happening in the next 24 hours with a predicate, limiting to the default calendar 
- (NSArray *)fetchEventsForToday {
	
	NSDate *startDate = [NSDate date];
	
	// endDate is 1 day = 60*60*24 seconds = 86400 seconds from startDate
	NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:86400];
	
	// Create the predicate. Pass it the default calendar.
	NSArray *calendarArray = [NSArray arrayWithObject:defaultCalendar];
	NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate 
                                                                    calendars:calendarArray]; 
	
	// Fetch all events that match the predicate.
	NSArray *events = [eventStore eventsMatchingPredicate:predicate];
    
	NSMutableArray *eventsWithGeo=[[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    
    
    EKEvent *event;
    for (event in events){
        NSString *locate=event.location;
        if (locate && event.title){
            
            NSRange textRangeLat;
            textRangeLat =[locate rangeOfString:@"lat"];
            
            NSRange textRangeLon;
            textRangeLon =[locate rangeOfString:@" lon"];
            
            if(textRangeLat.location != NSNotFound && textRangeLon.location != NSNotFound)
            { 
                [eventsWithGeo addObject:event];
            }
        }
    }
    return eventsWithGeo;
}

@end
