//
//  MainWindowController.m
//  Sync Demo App
//
//  Created by Michael on 14.07.08.
//  Copyright 2008 Bidli Software. All rights reserved.
//

#import "MainWindowController.h"


@implementation MainWindowController

-(void) awakeFromNib {
	browser = [[NSNetServiceBrowser alloc] init];
    services = [[NSMutableArray array] retain];
    [browser setDelegate:self];
    [browser searchForServicesOfType:@"_iPhoneSyncService._tcp." inDomain:@""];
}

#pragma mark Action Handler

-(IBAction) discoverPhoneAction:(id) sender {
	[services removeAllObjects];
	
	[browser stop];
	[browser searchForServicesOfType:@"_iPhoneSyncService._tcp." inDomain:@""];
}

-(IBAction) syncAction:(id) sender {
	NSNetService *service = [services objectAtIndex: [servicesTable selectedRow]];
	NSData *appData = [[appDataField stringValue] dataUsingEncoding:NSUTF8StringEncoding];
	
	if(service) {
		NSOutputStream *outStream;
		[service getInputStream:nil outputStream:&outStream];
		[outStream open];
		int bytes = [outStream write:[appData bytes] maxLength: [appData length]];
		[outStream close];
		
		NSLog(@"Wrote %d bytes", bytes);
	}
}

#pragma mark NSNetServiceBrowser delegates

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [services addObject:aNetService];
    [aNetService resolveWithTimeout:5.0];
    NSLog(@"published: %@",aNetService);
	[servicesTable reloadData];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [services removeObject:aNetService];
    [servicesTable reloadData];
}

#pragma mark NSTableView delegates

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	
	if([servicesTable selectedRow] >= 0)
		[syncButton setEnabled:YES];
	
	else
		[syncButton setEnabled:NO];
}

- (int)numberOfRowsInTableView:(NSTableView *)theTableView {
    return [services count];
}


- (id)tableView:(NSTableView *)theTableView objectValueForTableColumn:(NSTableColumn *)theColumn row:(int)rowIndex {
	NSLog(@"published: %@",[[services objectAtIndex:rowIndex]name]);
	NSLog(@"port: %d",[[services objectAtIndex:rowIndex]port]);
    return [[services objectAtIndex:rowIndex] name];
}

@end
