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

- (void) dealloc
{
	[name release];
	[description release];
    [event release];
	[super dealloc];
}

@end
