//
//  AppDataViewController.h
//  Sync Demo
//
//  Created by Michael on 14.07.08.
//  Copyright 2008 Bidli Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppDataViewController : UIViewController {

	IBOutlet UITextField *appDataField;
}

-(IBAction) refreshAction:(id)sender;
@end
