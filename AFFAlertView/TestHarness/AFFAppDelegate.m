//
//  AFFAppDelegate.m
//  AF Apps
//
//  Created by Jeremy Fuellert on 2014-03-13.
//  Copyright (c) 2014 AFApps. All rights reserved.
//

#import "AFFAppDelegate.h"
#import "AFFViewController.h"

@implementation AFFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    AFFViewController *viewController = [[AFFViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController    = viewController;
    self.window.backgroundColor       = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end