#import "PicBrowserController.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

@implementation PicBrowserController

-(void)dealloc{
    [arrayy dealloc];
    [super dealloc];
}

- (IBAction)serviceClicked:(id)sender {
    // The row that was clicked corresponds to the object in services we wish to contact.
    int index = [sender selectedRow];
    if (-1 != index && currentDownload == nil) {
        NSNetService * clickedService = [services objectAtIndex:index];
        [hostNameField setStringValue:[clickedService hostName]];
        NSInputStream * istream;
        [clickedService getInputStream:&istream outputStream:nil];
        [istream retain];
        [istream setDelegate:self];
        [istream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [progressIndicator startAnimation:nil];
        [istream open];
    }
}

- (void)awakeFromNib {
    browser = [[NSNetServiceBrowser alloc] init];
    services = [[NSMutableArray array] retain];
    [browser setDelegate:self];
    
    // Passing in "" for the domain causes us to browse in the default browse domain
    [browser searchForServicesOfType:@"_wwdcpic._tcp." inDomain:@""];
    [hostNameField setStringValue:@""];
}

// This object is the delegate of its NSNetServiceBrowser object. We're only interested in services-related methods, so that's what we'll call.
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [services addObject:aNetService];
    [aNetService resolveWithTimeout:5.0];
    
    if(!moreComing) {
        [pictureServiceList reloadData];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [services removeObject:aNetService];
    arrayy = nil;
    if(!moreComing) {
        [pictureServiceList reloadData]; 
			[ArtistList reloadData];  
    }
}

// This object is the data source of its NSTableView. servicesList is the NSArray containing all those services that have been discovered.
- (int)numberOfRowsInTableView:(NSTableView *)theTableView {
	if (theTableView == pictureServiceList) {
	    return [services count];	
	}else {
		return [arrayy count];
	}

}


- (id)tableView:(NSTableView *)theTableView objectValueForTableColumn:(NSTableColumn *)theColumn row:(int)rowIndex {
	if (theTableView == pictureServiceList) {
		return [[services objectAtIndex:rowIndex] name];	
	}else {
        NSLog(@"%@, %d",[arrayy objectAtIndex:rowIndex],rowIndex);
		return [arrayy objectAtIndex:rowIndex];
	}
}

//RECIBE DATOS
#pragma mark NSStream delegate method

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)event {
    switch(event) {
        case NSStreamEventHasBytesAvailable:
            if (!currentDownload) {
                currentDownload = [[NSMutableData alloc] initWithCapacity:409600];
            }
            uint8_t readBuffer[40966];
            int amountRead = 0;
            NSInputStream * is = (NSInputStream *)aStream;
            amountRead = [is read:readBuffer maxLength:40966];
            [currentDownload appendBytes:readBuffer length:amountRead];
            break;
        case NSStreamEventEndEncountered:
            [(NSInputStream *)aStream close];
            arrayy = [[NSMutableArray alloc]init];
			arrayy = [NSKeyedUnarchiver unarchiveObjectWithData:currentDownload];

			//for (NSString *obj in arrayy){
			//	NSLog(@"%@", obj);
			//}
            
			[ArtistList reloadData];  
            [currentDownload release];
            currentDownload = nil;
            break;
        default:
            break;
    }
}

//ENVIA DATOS


@end
