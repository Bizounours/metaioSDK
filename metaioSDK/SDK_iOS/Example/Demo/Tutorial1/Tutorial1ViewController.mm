//
//  Tutorial1ViewController.m
//  Demo
//
//  Copyright (c) 2012 metaio GmbH. All rights reserved.
//

#import "Tutorial1ViewController.h"
#import "EAGLView.h"

@interface Tutorial1ViewController ()

@end

@implementation Tutorial1ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    // load our tracking configuration
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast" ofType:@"xml" inDirectory:@"Assets1"];
    
	if(trackingDataFile)
	{
		bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}
    
    
    // load content
    NSString* metaioManModel = [[NSBundle mainBundle] pathForResource:@"metaioman" ofType:@"md2" inDirectory:@"Assets1"];
    
	if(metaioManModel)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D model
        metaio::IGeometry* theLoadedModel =  m_metaioSDK->createGeometry([metaioManModel UTF8String]);
        if( theLoadedModel )
        {
            // scale it a bit up
            theLoadedModel->setScale(metaio::Vector3d(4.0,4.0,4.0));
        }
        else
        {
            NSLog(@"error, could not load %@", metaioManModel);
        }
    }
}

@end
