
//  metaio SDK
//
//  Copyright metaio, GmbH 2012. All rights reserved.
//

#import "MetaioSDKViewController.h"

@interface Tutorial2ViewController : MetaioSDKViewController
{
	metaio::IGeometry*       m_imagePlane;           // pointer to the image plane
    metaio::IGeometry*       m_metaioMan;            // pointer to the metaio man model
    metaio::IGeometry*       m_moviePlane;           // pointer to our movie plane
    metaio::IGeometry*       m_truck;
    
    
}

/** Handle segment control */
- (IBAction)onSegmentControlChanged:(UISegmentedControl*)sender;


@end

