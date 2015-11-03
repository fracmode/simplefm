/*
     File: simplefmAppDelegate.m
 Abstract: 
  Version: 1.8
 
 Disclaimer: 
 
 */

#import "simplefmAppDelegate.h"

@implementation simplefmAppDelegate

@synthesize window;
@synthesize myViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Set up the view controller
	MyViewController *aViewController = [[MyViewController alloc] initWithNibName:@"simplefm" bundle:[NSBundle mainBundle]];
	self.myViewController = aViewController;
	[aViewController release];
    
	window.rootViewController = [UIViewController new];
    // [window addSubview:myViewController.view];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	// Add the view controller's view as a subview of the window
	UIView *controllersView = [myViewController view];
	[self.window addSubview:controllersView];
	[self.window makeKeyAndVisible];
}


- (void)dealloc {
	[myViewController release];
	[window release];
	[super dealloc];
}

@end
