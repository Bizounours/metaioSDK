// metaio SDK
//
//  Copyright metaio, GmbH 2012. All rights reserved.
//

#import "MetaioSDKViewController.h"

@interface Tutorial6ViewController : MetaioSDKViewController
{
    metaio::IGeometry*       m_tigerModel;            // pointer to the metaio man model
    bool                     m_isCloseToModel;     // to keep track if we moved close to the

}

/* Handle segment control */
- (IBAction)onSegmentControlChanged:(UISegmentedControl*)sender;
- (void) checkDistanceToTarget;

@end

