
//  metaio SDK
//
//  Copyright metaio, GmbH 2012. All rights reserved.
//

#import "MetaioSDKViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

namespace metaio
{
    class IGeometry;   // forward declaration
}

@interface Tutorial5ViewController : MetaioSDKViewController <CLLocationManagerDelegate>
{	
    metaio::IBillboardGroup*   billboardGroup;   //!< Our default billboard group
    metaio::IGeometry* southBillboard;
    metaio::IGeometry* northBillBoard;
    metaio::IGeometry* metaioMan;
    metaio::IRadar* m_radar;
    
    UIImage* northImage;
    UIImage* southImage;
}
@property (nonatomic, retain) CLLocation* currentLocation;				//!< Contains the current location

@end
