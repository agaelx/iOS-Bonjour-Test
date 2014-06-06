//
//  iOSMusicRemViewController.h
//  iOSMusicRem
//
//  Created by Uriel on 03/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface iOSMusicRemViewController : UIViewController <NSNetServiceDelegate,NSStreamDelegate>{
    
    IBOutlet UILabel *shortStatusText;
    IBOutlet UIButton *toggleSharingButton;
	BOOL Estado;
	NSNetService * netService;
    NSFileHandle * listeningSocket;
    NSMutableArray *Artistas;
    NSMutableData * currentDownload;
    NSMutableArray *arrayy;
}

- (IBAction)toggleSharing:(id)sender;

@end
