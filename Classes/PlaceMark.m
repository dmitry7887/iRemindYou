//
//  PlaceMark.m
//
//

#import "PlaceMark.h"


@implementation PlaceMark

@synthesize coordinate;
@synthesize place;

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

- (NSString *)subtitle
{
	return self.place.description;
}
- (NSString *)title
{
	return self.place.name;
}
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
{
    coordinate=newCoordinate;
    place.latitude=coordinate.latitude;
    place.longitude=coordinate.longitude;
}
- (void) dealloc
{
	[place release];
	[super dealloc];
}


@end
