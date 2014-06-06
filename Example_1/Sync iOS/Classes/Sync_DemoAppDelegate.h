//
//  Sync_DemoAppDelegate.h
//  Sync Demo
//
//  Created by Michael on 14.07.08.
//  Copyright Bidli Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Sync_DemoAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;

@end
