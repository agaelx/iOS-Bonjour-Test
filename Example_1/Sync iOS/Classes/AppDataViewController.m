//
//  AppDataViewController.m
//  Sync Demo
//
//  Created by Michael on 14.07.08.
//  Copyright 2008 Bidli Software. All rights reserved.
//

#import "AppDataViewController.h"


@implementation AppDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

-(IBAction) refreshAction:(id)sender {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
	
	if([paths count] > 0) {
		NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"appData.txt"];
		
		if([fm fileExistsAtPath:path]) {
			[appDataField setText:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]];
		}
		else
			NSLog(@"File %@ does not exist", path);
		}
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

- (void)viewDidLoad {
	[self refreshAction:nil];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}


@end
