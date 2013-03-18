// metaio SDK
//
//  Copyright metaio, GmbH 2012. All rights reserved.
//

#import "Tutorial6ViewController.h"
#import "EAGLView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface Tutorial6ViewController ()
{
    SystemSoundID catSound;
}
- (void) setActiveTrackingConfig: (int) index;
@end


@implementation Tutorial6ViewController


#pragma mark - UIViewController lifecycle


- (void) viewDidLoad
{
    [super viewDidLoad];
  
    // load content
    NSString* tigerModelPath = [[NSBundle mainBundle] pathForResource:@"tiger" ofType:@"md2" inDirectory:@"Assets6"];
    
	if(tigerModelPath)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D model
        m_tigerModel =  m_metaioSDK->createGeometry([tigerModelPath UTF8String]);
        if( m_tigerModel )
        {
            m_tigerModel->setScale(metaio::Vector3d(8.0,8.0,8.0));
        }
        else
        {
            NSLog(@"error, could not load %@", tigerModelPath);
        }
    }
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"meow" ofType:@"aif" inDirectory:@"Assets6"];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath: soundPath]), &catSound);
  
    // start with markerless tracking
    [self setActiveTrackingConfig:0];
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
            m_tigerModel->setRotation(metaio::Rotation(metaio::Vector3d(0, 0, M_PI)));
            m_metaioSDK->startInstantTracking("INSTANT_2D");
            NSLog(@"Instant tracking snapshot is done");
            break;
            
            
        case 1:
			m_tigerModel->setRotation(metaio::Rotation(metaio::Vector3d(0, 0, -M_PI)));
            m_metaioSDK->startInstantTracking("INSTANT_2D_GRAVITY");
            NSLog(@"Instant rectified tracking snapshot is done");
            break;
            
            
        case 2:
            m_metaioSDK->startInstantTracking("INSTANT_3D");
            NSLog(@"SLAM is started");
            break;
    }
    
}

- (IBAction)onSegmentControlChanged:(UISegmentedControl*)sender 
{
    [self setActiveTrackingConfig:sender.selectedSegmentIndex];
}

- (void) onInstantTrackingEvent: (bool)success file:(const std::string&) file
{
    
    // load the tacking configuration
    if(success)
    {
        m_metaioSDK->setTrackingConfiguration(file);
    }
    else
    {
        NSLog(@"SLAM has timed out!");
    }
    
}

#pragma mark -
#pragma mark Distance checking


- (void) checkDistanceToTarget
{
	// get the current tracking values for cos 1
    
    metaio::TrackingValues currentPose = m_metaioSDK->getTrackingValues(1);
    
    
	// if the quality value > 0, it means we're currently tracking
	// Note, you can use this mechanism also to detect if something is tracking or not.
	// (e.g. for triggering an action as soon as some target is visible on screen)
	if( currentPose.quality > 0 )
	{
		// get the translation part of the pose
		metaio::Vector3d poseTranslation = currentPose.translation;
		
		// calculate the distance as sqrt( x^2 + y^2 + z^2 )
		float distanceToTarget = sqrt(poseTranslation.x * poseTranslation.x +
									  poseTranslation.y * poseTranslation.y +
									  poseTranslation.z * poseTranslation.z
									  );
		
		// define a threshold distance
		float threshold = 250;
		
		// if we are already close to the model
		if( m_isCloseToModel )
		{
			// if our distance is larger than our threshold (+ a little)
			if( distanceToTarget > (threshold + 10) )
			{
				// we flip this variable again
				m_isCloseToModel = false;
				
				// play sound
                AudioServicesPlaySystemSound(catSound);
                m_tigerModel->startAnimation("meow", false);
			}
		}
		else
		{
			// we're not close yet, let's check if we are now
			if( distanceToTarget < threshold )
			{
				// flip the variable
				m_isCloseToModel = true;
				
				//play sound again
                AudioServicesPlaySystemSound(catSound);
                m_tigerModel->startAnimation("meow", false);
			}
		}
	}
}

- (void)drawFrame
{
    [super drawFrame];
    
    // tell sdk to render
    if( m_metaioSDK )
    {
        // only do that, if we're currently viewing the metaio man
        if( m_tigerModel->isVisible() )
        {
            [self checkDistanceToTarget];
        }
    }
}

#pragma mark - Rotation handling


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // allow rotation in all directions
    return YES;
}


@end
