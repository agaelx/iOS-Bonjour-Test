//
//  FirstViewController.h
//  Sync Demo
//
//  Created by Michael on 14.07.08.
//  Copyright Bidli Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SyncServiceController : UIViewController {

	NSNetService	*netService;
    NSFileHandle	*listeningSocket;
	bool			serviceStarted;
}

-(IBAction) toggleSyncService:(id) sender;

@end
