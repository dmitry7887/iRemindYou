//
//  Place.m
//
//

#import "Place.h"


@implementation Place

@synthesize name;
@synthesize description;
@synthesize latitude;
@synthesize longitude;
@synthesize event;
@synthesize timeToPlace;


- (void) dealloc
{
	[name release];
	[description release];
    [event release];
    [timeToPlace release];
	[super dealloc];
}

@end
