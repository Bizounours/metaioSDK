
//  metaio SDK
//
//  Copyright metaio, GmbH 2012. All rights reserved.
//

#import "MetaioSDKViewController.h"

@interface Tutorial4ViewController : MetaioSDKViewController
{
    metaio::IGeometry*       m_metaioMan;            // pointer to the metaio man model
   
    bool                     m_isCloseToModel;     // to keep track if we moved close to the 
}


/** This method is regularly called, calculates the distance between phone and target
 * and performs actions based on the distance 
 */
- (void) checkDistanceToTarget;
@end

