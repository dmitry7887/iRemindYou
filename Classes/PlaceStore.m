//
//  PlaceMarkStore.m
// 
//
//  Created by Dmitry Gankevich on 29.08.11.
//  Copyright 2011. All rights reserved.
//

#import "PlaceStore.h"
#import "SynthesizeSingleton.h"

@implementation PlaceStore
SYNTHESIZE_SINGLETON_FOR_CLASS(PlaceStore);

@synthesize placeList, reverseGeocoder, defaultCalendar, eventStore, placeToRemind;

- (id)init
{
    self = [super init];
    if (self) {
        placeList=[[NSMutableSet alloc] init];

        // Initialization code here.
        EditState=NO;
        // Initialize an event store object with the init method. Initilize the array for events.
        eventStore = [[EKEventStore alloc] init];
        
        // Get the default calendar from store.
        defaultCalendar = [eventStore defaultCalendarForNewEvents];
        [self resetPlaceToRemind];
        // Fetch today's event on selected calendar and put them into the eventsList array
        NSArray *eventsList = [self fetchEventsForToday];
        EKEvent *event;
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
                    
                    Place *p = [[Place alloc] init];
                    
                    p.latitude=[lat doubleValue];
                    p.longitude=[lon doubleValue];
                    
                    
                    
                    p.name=event.title;
                    p.description=event.notes;
                    p.event=event;
                    [placeList addObject:p];
                    //Does contain the substring
                }
            }
        }         
    }
    [self setPlaceToRemind];
    return self;
}

#pragma mark -
#pragma mark PlaceMark editiong

-(void) addPlace: (Place*) place;
{
    [placeList addObject:place];
    place.event  = [[EKEvent eventWithEventStore:eventStore] retain];
    place.event.location=[[NSString stringWithFormat:@"lat=%f",place.latitude] stringByAppendingString:[NSString stringWithFormat:@" lon=%f",place.longitude]];
    
    place.event.startDate = [NSDate date];
    place.event.endDate   = [NSDate dateWithTimeInterval:600 sinceDate:place.event.startDate];
    place.event.notes     = place.name;

    placeEdit=place;
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=place.latitude;
    coordinate.longitude=place.longitude;
    
    [self reverseGeocodeByLocation:coordinate]; 
}

-(void) editPlace: (Place*) place;
{
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    placeEdit=place; 
    EditState=YES;
    // set the addController's event store to the current event store.
    addController.eventStore = eventStore;
    addController.event=place.event;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showViewController" object:addController];
    
    addController.editViewDelegate = self;
    
    [addController release];
}

-(void) removePlace: (Place*) place;
{
    [placeList removeObject:place];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removePlaceMark" object:placeEdit];
    placeEdit=nil;
}

-(void) updatePlace: (Place*) place;
{
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    placeEdit=place; 
    EditState=YES;
    
    place.event.location=[[NSString stringWithFormat:@"lat=%f",place.latitude] stringByAppendingString:[NSString stringWithFormat:@" lon=%f",place.longitude]];
    // set the addController's event store to the current event store.
    addController.eventStore = eventStore;
    addController.event=place.event;
    NSError *error = nil;
    [addController.eventStore saveEvent:addController.event span:EKSpanThisEvent error:&error];
    [addController release];
}

#pragma mark -
#pragma mark placeRemind accessors
-(void) resetPlaceToRemind;
{
    placeToRemind=nil;
}

-(void) setPlaceToRemind;
{
    if (!placeToRemind){
        placeToRemind=[self getPlaceToRemind];
        NSLog(@"PlaceToRemind Title= %@",[placeToRemind name]);
    }
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
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=placeEdit.latitude;
    coordinate.longitude=placeEdit.longitude;
    reverseGeocoder =[[[MKReverseGeocoder alloc] initWithCoordinate:coordinate] autorelease];
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
    addController.event=placeEdit.event;
    
    // present EventsAddViewController as a modal view controller
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showViewController" object:addController];
    
    addController.editViewDelegate = self;
    
    [addController release];
    
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    
    NSString *placeDescription=[placemark title];

    placeEdit.event.notes=placeDescription;
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    // set the addController's event store to the current event store.
    addController.eventStore = eventStore;
    addController.event=placeEdit.event;
    
    // present EventsAddViewController as a modal view controller

    [[NSNotificationCenter defaultCenter] postNotificationName:@"showViewController" object:addController];
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
            if (placeEdit!=nil && !EditState){
                [placeList removeObject:placeEdit];
                [placeEdit release];
                placeEdit=nil;
            }
			break;
			
		case EKEventEditViewActionSaved:
			// When user hit "Done" button, save the newly created event to the event store, 
			// and reload table view.
			// If the new event is being added to the default calendar, then update its 
			// eventsList.
			if (defaultCalendar ==  thisEvent.calendar) {
				
                
                if (placeEdit!=nil){ 
                    placeEdit.event=thisEvent;
                    placeEdit.name=thisEvent.title;
                    placeEdit.description=thisEvent.notes;
                    placeEdit.event.location=[[NSString stringWithFormat:@"lat=%f",placeEdit.latitude] stringByAppendingString:[NSString stringWithFormat:@" lon=%f",placeEdit.longitude]];
                    if (placeEdit==placeToRemind){
                        [self resetPlaceToRemind];
                    }
                    if (EditState){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"removePlaceMark" object:placeEdit];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"addPlaceMark" object:placeEdit];
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
			if (defaultCalendar ==  thisEvent.calendar && placeEdit!=nil && EditState) {
                [placeList removeObject:placeEdit];
                if (placeEdit==placeToRemind){
                    [self resetPlaceToRemind];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removePlaceMark" object:placeEdit];
                [placeEdit release];
                placeEdit=nil;
			}
            [controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];

            break;
			
		default:
			break;
	}
    EditState=NO;
  
    
    [self setPlaceToRemind];
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
	NSDate *endDate = [NSDate distantFuture];
	
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

// Fetching events happening in the next 24 hours with a predicate, limiting to the default calendar 
- (Place *)getPlaceToRemind {
	
	NSDate *startDate = [NSDate date];
	NSDate *endDate = [NSDate distantFuture];
	
	// Create the predicate. Pass it the default calendar.
	NSArray *calendarArray = [NSArray arrayWithObject:defaultCalendar];
	NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate 
                                                               calendars:calendarArray]; 
	
	// Fetch all events that match the predicate.
	NSArray *events = [eventStore eventsMatchingPredicate:predicate];
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
                Place *p;
                for (p in placeList){
                    if (p.event.location==event.location){
                        return p;
                    }
                }
                break;
            }
        }
    }
    
    return nil;
}

@end
