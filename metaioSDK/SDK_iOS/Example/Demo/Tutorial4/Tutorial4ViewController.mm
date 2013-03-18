
//  metaio SDK
//
//  Copyright metaio, GmbH 2012. All rights reserved.
//

#import "Tutorial4ViewController.h"
#import "EAGLView.h"

@interface Tutorial4ViewController ()

@end


@implementation Tutorial4ViewController


#pragma mark - UIViewController lifecycle


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    // load our tracking configuration
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast" ofType:@"xml" inDirectory:@"Assets4"];	
    
    
    // if you want to test the 3D tracking, please uncomment the line below and comment the line above
    //NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_ML3D" ofType:@"xml" inDirectory:@"Assets"];	
    
    
	if(trackingDataFile)
	{
		bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}
    
    
    
    // load content
    NSString* metaioManModel = [[NSBundle mainBundle] pathForResource:@"metaioman" ofType:@"md2" inDirectory:@"Assets4"];
    
	if(metaioManModel)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D model
        m_metaioMan =  m_metaioSDK->createGeometry([metaioManModel UTF8String]);
        if( m_metaioMan )
        {
            // scale it a bit up
             m_metaioMan->setScale(metaio::Vector3d(4.0,4.0,4.0));
        }
        else
        {
            NSLog(@"error, could not load %@", metaioManModel);            
        }
    }
    
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

#pragma mark - Rotation handling


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // allow rotation in all directions
    return YES;
}

#pragma mark - @protocol MobileDelegate

- (void) onAnimationEnd: (metaio::IGeometry*) geometry  andName:(NSString*) animationName
{
    // handle the metaio man animations
    if( geometry == m_metaioMan )
    {
        // check the previous animation name and act accordingly
        if( [animationName compare:@"shock_down"] == NSOrderedSame )
        {
            geometry->startAnimation( "shock_idle" , false);
        }
        else if( [animationName compare:@"shock_idle"] == NSOrderedSame  )
        {
            geometry->startAnimation( "shock_up" , false);
        }
        else if((  [animationName compare:@"shock_up"] == NSOrderedSame  ) || ( [animationName compare:@"close_up"] == NSOrderedSame  ) )
        {
            if( m_isCloseToModel )
            {
                geometry->startAnimation( "close_idle", true);
            }
            else
            {
                geometry->startAnimation( "idle", true );
            }
        }
        else if( [animationName compare:@"close_down"] == NSOrderedSame )
        {
            geometry->startAnimation( "close_idle", true);
        }
    }
    
}


#pragma mark - Handling Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Here's how to pick a geometry
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:glView];
	
    // get the scale factor (will be 2 for retina screens)
    float scale = glView.contentScaleFactor;
    
	// ask sdk if the user picked an object
	// the 'true' flag tells sdk to actually use the vertices for a hit-test, instead of just the bounding box
    metaio::IGeometry* model = m_metaioSDK->getGeometryFromScreenCoordinates(loc.x * scale, loc.y * scale, true);
	
    if ( model == m_metaioMan)
	{
		// we have touched the metaio man
		// let's start an animation
		model->startAnimation( "shock_down" , false);
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // ignore when we're using multitouch
    if( [touches count] == 1 )
    {
        UITouch *touch = [touches anyObject];
        CGPoint screenpoint = [touch locationInView:glView];
        
        // get the scale factor (will be 2 for retina screens)
        float scale = glView.contentScaleFactor;
        
        
        // if the metaio man is visible, let's move him
        if( m_metaioMan->isVisible() )
        {
            // lets move the object to the touched point
            // first get the 3D position based on the screen coordinates
            metaio::Vector3d translation = m_metaioSDK->get3DPositionFromScreenCoordinates(1, metaio::Vector2d(screenpoint.x * scale, screenpoint.y * scale));
            
            // and set the translation of scene 1 (= metaioman) to this translation
            m_metaioMan->setTranslation(translation);
        }
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
		float threshold = 800;
		
		// if we are already close to the model
		if( m_isCloseToModel )
		{
			// if our distance is larger than our threshold (+ a little)
			if( distanceToTarget > (threshold + 10) )
			{
				// we flip this variable again
				m_isCloseToModel = false;
				
				// and start the close_up animation
				m_metaioMan->startAnimation( "close_up" , false);
			}
		}
		else
		{
			// we're not close yet, let's check if we are now
			if( distanceToTarget < threshold )
			{
				// flip the variable
				m_isCloseToModel = true;
				
				// and start an animation
				m_metaioMan->startAnimation( "close_down" , false );
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
        if( m_metaioMan->isVisible() )
        {
            [self checkDistanceToTarget];
        }
    }
}


@end
