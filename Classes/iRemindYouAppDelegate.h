//
//  MapWithRoutesAppDelegate.h
//  MapWithRoutes
//
//

#import <UIKit/UIKit.h>

@class iRemindYouViewController;

@interface iRemindYouAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    iRemindYouViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iRemindYouViewController *viewController;

@end

