/*
     File: simplefmAppDelegate.h
 Abstract: 
  Version: 1.8
 
 Disclaimer: 
 
 */

#import <UIKit/UIKit.h>
#import "MyViewController.h"

@class MyViewController;

@interface simplefmAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	MyViewController *myViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MyViewController *myViewController;

@end
