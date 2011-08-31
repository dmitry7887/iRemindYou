//
//  Place.h
//
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface Place : NSObject {

	NSString* name;
	NSString* description;
	double latitude;
	double longitude;
    EKEvent* event;//Store event

}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, retain) EKEvent *event;

@end
