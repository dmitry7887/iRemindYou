//
//  PlaceMark.m
//
//

#import "PlaceMark.h"


@implementation PlaceMark

@synthesize coordinate;
@synthesize place, event;

-(id) initWithPlace: (Place*) p
{
	self = [super init];
	if (self != nil) {
		coordinate.latitude = p.latitude;
		coordinate.longitude = p.longitude;
		self.place = p;
        
	}
	return self;
}

-(id) initWithCoordinate: (CLLocationCoordinate2D) currentCoordinate;
{
	self = [super init];
	if (self != nil) {
		coordinate=currentCoordinate;
        Place* p = [[[Place alloc] init] autorelease];
        p.name = @"123";
        p.description = @"13";
        p.latitude = 45.029598;
        p.longitude = 28.884546;
        self.place = p;

	}
	return self;
}

- (NSString *)subtitle
{
	return self.place.description;
}
- (NSString *)title
{
	return self.place.name;
}

- (void) dealloc
{
	[place release];
    [event release];
	[super dealloc];
}


@end
