//
//  iOSMusicRemAppDelegate.h
//  iOSMusicRem
//
//  Created by Uriel on 03/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iOSMusicRemViewController;

@interface iOSMusicRemAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet iOSMusicRemViewController *viewController;

@end
