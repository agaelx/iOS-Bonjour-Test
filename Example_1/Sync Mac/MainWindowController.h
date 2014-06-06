//
//  MainWindowController.h
//  Sync Demo App
//
//  Created by Michael on 14.07.08.
//  Copyright 2008 Bidli Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MainWindowController : NSWindowController {

	IBOutlet NSButton		*discoverButton;
	IBOutlet NSButton		*syncButton;
	IBOutlet NSTextField	*appDataField;
	IBOutlet NSTableView	*servicesTable;
	
	NSNetServiceBrowser		*browser;
	NSMutableArray			*services;
}

-(IBAction) discoverPhoneAction:(id) sender;
-(IBAction) syncAction:(id) sender;

@end
