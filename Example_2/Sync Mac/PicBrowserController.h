/* PicBrowserController */

#import <Cocoa/Cocoa.h>

@interface PicBrowserController : NSObject
{
    IBOutlet id hostNameField;
    IBOutlet id pictureServiceList;
	IBOutlet id ArtistList;
    IBOutlet NSProgressIndicator * progressIndicator;
	
    NSNetServiceBrowser * browser;
    NSMutableArray * services;
    NSMutableData * currentDownload;
    NSMutableArray *arrayy;
}
- (IBAction)serviceClicked:(id)sender;
@end
