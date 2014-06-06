//
//  iOSMusicRemViewController.m
//  iOSMusicRem
//
//  Created by Uriel on 03/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iOSMusicRemViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

@implementation iOSMusicRemViewController

- (void)dealloc
{
    if(netService) [netService stop];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{	
    toggleSharingButton.alpha = 1.0;
	[self toggleSharing:nil];
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}





- (IBAction)toggleSharing:(id)sender {
    uint16_t chosenPort = 0;
    
    if(!listeningSocket) {
        // Here, create the socket from traditional BSD socket calls, and then set up an NSFileHandle with that to listen for incoming connections.
        int fdForListening;
        struct sockaddr_in serverAddress;
        socklen_t namelen = sizeof(serverAddress);
		
        // In order to use NSFileHandle's acceptConnectionInBackgroundAndNotify method, we need to create a file descriptor that is itself a socket, bind that socket, and then set it up for listening. At this point, it's ready to be handed off to acceptConnectionInBackgroundAndNotify.
        if((fdForListening = socket(AF_INET, SOCK_STREAM, 0)) > 0) {
            memset(&serverAddress, 0, sizeof(serverAddress));
            serverAddress.sin_family = AF_INET;
            serverAddress.sin_addr.s_addr = htonl(INADDR_ANY);
            serverAddress.sin_port = 0; // allows the kernel to choose the port for us.
			
            if(bind(fdForListening, (struct sockaddr *)&serverAddress, sizeof(serverAddress)) < 0) {
                close(fdForListening);
                return;
            }
			
            // Find out what port number was chosen for us.
            if(getsockname(fdForListening, (struct sockaddr *)&serverAddress, &namelen) < 0) {
                close(fdForListening);
                return;
            }
			
            chosenPort = ntohs(serverAddress.sin_port);
            
            if(listen(fdForListening, 1) == 0) {
                listeningSocket = [[NSFileHandle alloc] initWithFileDescriptor:fdForListening closeOnDealloc:YES];
            }
        }
    }
    
    if(!netService) {
        // lazily instantiate the NSNetService object that will advertise on our behalf.
        netService = [[NSNetService alloc] initWithDomain:@"" type:@"_wwdcpic._tcp." name:@"" port:chosenPort];
        [netService setDelegate:self];
    }
	
	
    if(netService && listeningSocket) {	
        if(Estado) {
			
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionReceived:) name:NSFileHandleConnectionAcceptedNotification object:listeningSocket];
            [listeningSocket acceptConnectionInBackgroundAndNotify];
            [netService publish];
        } else {
            [netService stop];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleConnectionAcceptedNotification object:listeningSocket];
            // There is at present no way to get an NSFileHandle to -stop- listening for events, so we'll just have to tear it down and recreate it the next time we need it.
            [listeningSocket release];
            listeningSocket = nil;
        }
    }
}


// This object is the delegate of its NSNetService. It should implement the NSNetServiceDelegateMethods that are relevant for publication (see NSNetServices.h).
- (void)netServiceWillPublish:(NSNetService *)sender {
    toggleSharingButton.alpha = 0.5;
	Estado = FALSE;
    [shortStatusText setText:@"iPod Remote is ON."];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    // Display some meaningful error message here, using the longerStatusText as the explanation.
    toggleSharingButton.alpha = 1.0;
	Estado = TRUE;
    [shortStatusText setText:@"iPod Remote is OFF."];
    if([[errorDict objectForKey:NSNetServicesErrorCode] intValue] == NSNetServicesCollisionError) {
        //[serviceNameField setEnabled:YES];
    } else {
        
    }
    [listeningSocket release];
    listeningSocket = nil;
    [netService release];
    netService = nil;
}

- (void)netServiceDidStop:(NSNetService *)sender {
    toggleSharingButton.alpha = 1.0;
	Estado = TRUE;
    [shortStatusText setText:@"iPod Remote is OFF."];
    // We'll need to release the NSNetService sending this, since we want to recreate it in sync with the socket at the other end. Since there's only the one NSNetService in this application, we can just release it.
    [netService release];
    netService = nil;
}

// This object is also listening for notifications from its NSFileHandle.
// When an incoming connection is seen by the listeningSocket object, we get the NSFileHandle representing the near end of the connection. We write the thumbnail image to this NSFileHandle instance.
- (void)connectionReceived:(NSNotification *)aNotification {
    NSFileHandle * incomingConnection = [[aNotification userInfo] objectForKey:NSFileHandleNotificationFileHandleItem];	
    
    Artistas = [[NSMutableArray alloc]init];
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSString *songTitle;
    NSArray *itemsFromGenericQuery = [everything items];
    for (MPMediaItem *song in itemsFromGenericQuery) {
        songTitle = [song valueForProperty: MPMediaItemPropertyArtist];
        [Artistas addObject:songTitle];
    }

    NSData* myData = [NSKeyedArchiver archivedDataWithRootObject:Artistas];	
    [Artistas dealloc];
    
	[[aNotification object] acceptConnectionInBackgroundAndNotify];
    [incomingConnection writeData:myData];
    [incomingConnection closeFile];
    
//manejo de delegado recibe    
    
        NSInputStream * istream;
        [netService getInputStream:&istream outputStream:nil];
        [istream retain];
        [istream setDelegate:self];
        [istream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        //[istream open];
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
			//para recibir datos de artistas
			arrayy = [NSKeyedUnarchiver unarchiveObjectWithData:currentDownload];
            
			for (NSString *obj in arrayy){
				NSLog(@"%@", obj);
			}

            [currentDownload release];
            currentDownload = nil;
            break;
        default:
            break;
    }
}


@end
