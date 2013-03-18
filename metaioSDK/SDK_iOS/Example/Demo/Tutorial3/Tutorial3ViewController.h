
//  metaio SDK
//
//  Copyright metaio, GmbH 2012. All rights reserved.
//

#import "MetaioSDKViewController.h"

@interface Tutorial3ViewController : MetaioSDKViewController
{
    metaio::IGeometry*       m_metaioMan;            // pointer to the metaio man model
    NSString *trackingConfigFile;
}

/* Handle segment control */
- (IBAction)onSegmentControlChanged:(UISegmentedControl*)sender;

@end

