
//  metaio SDK
//
//  Copyright metaio, GmbH 2012. All rights reserved.
//

#import "Tutorial3ViewController.h"
#import "EAGLView.h"

@interface Tutorial3ViewController ()
- (void) setActiveTrackingConfig: (int) index;
@end


@implementation Tutorial3ViewController


#pragma mark - UIViewController lifecycle


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // TODO: Add Multiple References Tracking
    // load our tracking configuration
    trackingConfigFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast" ofType:@"xml" inDirectory:@"Assets3"];
    
	if(trackingConfigFile)
	{
		bool success = m_metaioSDK->setTrackingConfiguration([trackingConfigFile UTF8String]);
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}
    
    
    // load content
    NSString* metaioManModel = [[NSBundle mainBundle] pathForResource:@"metaioman" ofType:@"md2" inDirectory:@"Assets3"];
    
	if(metaioManModel)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D model
        m_metaioMan =  m_metaioSDK->createGeometry([metaioManModel UTF8String]);
        if( m_metaioMan )
        {
            // scale it a bit down
            m_metaioMan->setScale(metaio::Vector3d(4.0,4.0,4.0));
        }
        else
        {
            NSLog(@"error, could not load %@", metaioManModel);
        }
    }
    
  
    // start with markerless tracking
    [self setActiveTrackingConfig:2];
}



- (void)viewWillAppear:(BOOL)animated
{	
    [super viewWillAppear:animated];
}



- (void) viewDidAppear:(BOOL)animated
{	
	[super viewDidAppear:animated];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];	
}


- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [super viewDidUnload];
}


#pragma mark - App Logic
- (void) setActiveTrackingConfig:(int)index
{
    switch ( index )
    {
        case 0:
            trackingConfigFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_Marker" ofType:@"xml" inDirectory:@"Assets3"];
            
            if(trackingConfigFile)
            {
                m_metaioMan->setScale(metaio::Vector3d(2.0,2.0,2.0));
                bool success = m_metaioSDK->setTrackingConfiguration([trackingConfigFile UTF8String]);
                if( !success)
                    NSLog(@"No success loading the tracking configuration");
            }
            break;
            
            
        case 1:
            trackingConfigFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_PictureMarker" ofType:@"xml" inDirectory:@"Assets3"];
            
            if(trackingConfigFile)
            {
                m_metaioMan->setScale(metaio::Vector3d(8.0,8.0,8.0));
                bool success = m_metaioSDK->setTrackingConfiguration([trackingConfigFile UTF8String]);
                if( !success)
                    NSLog(@"No success loading the tracking configuration");
            }
            break;
            
            
        case 2:
            trackingConfigFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast" ofType:@"xml" inDirectory:@"Assets3"];
            
            if(trackingConfigFile)
            {
                m_metaioMan->setScale(metaio::Vector3d(4.0,4.0,4.0));
                bool success = m_metaioSDK->setTrackingConfiguration([trackingConfigFile UTF8String]);
                if( !success)
                    NSLog(@"No success loading the tracking configuration");
            }
            break;
            
    }
    
}

- (IBAction)onSegmentControlChanged:(UISegmentedControl*)sender 
{
    [self setActiveTrackingConfig:sender.selectedSegmentIndex];
}

- (void)drawFrame
{
    [super drawFrame];
    
    // return if the metaio SDK has not been initialiyed yet
    if( !m_metaioSDK )
        return;
    
    // get all the detected poses/targets
    std::vector<metaio::TrackingValues> poses = m_metaioSDK->getTrackingValues();
    
    //if we have detected one, attach our metaioman to this coordinate system ID
    if(poses.size())
        m_metaioMan->setCoordinateSystemID( poses[0].coordinateSystemID );
}

#pragma mark - Rotation handling


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // allow rotation in all directions
    return YES;
}


@end
