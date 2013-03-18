//
//  Tutorial7ViewController.m
//  Example
//
//  Created by  on 10/24/12.
//  Copyright 2007-2012 metaio GmbH. All rights reserved.
//

#import "Tutorial7ViewController.h"
#import "EAGLView.h"

@interface Tutorial7ViewController ()

@end

@implementation Tutorial7ViewController

// gesture masks to specify which gesture(s) is enabled
//int GESTURE_DRAG = 1<<0;
//int GESTURE_ROTATE = 2<<0;
//int GESTURE_PINCH = 4<<0;
//int GESTURE_ALL = 0xFF;

#pragma - UIViewController lifecycle


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    m_gestures = 0xFF; //enables all gestures
    m_gestureHandler = [[GestureHandlerIOS alloc] initWithSDK:m_metaioSDK withView:glView withGestures:m_gestures];
    
    m_imageTaken = false;
    
    // load our tracking configuration
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_GPSCompass" ofType:@"xml" inDirectory:@"Assets7"];
    
    
	if(trackingDataFile)
	{
		bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
        NSLog(@"GPS tracking has been loaded: %d", (int)success);
	}
    
    //set the geometries somewhere visible on the screen
    metaio::TrackingValues pose;
    pose.translation = metaio::Vector3d(0.0, 0.0, -140.0);
    
    m_metaioSDK->setCosOffset(1, pose);
    
    
    // load content
    // load metaio man
    NSString* manPath = [[NSBundle mainBundle] pathForResource:@"metaioman" ofType:@"md2" inDirectory:@"Assets7"];
    
	if(manPath)
	{
		// if this call was successful, m_metaioMan will contain a pointer to the 3D model
        m_metaioMan =  m_metaioSDK->createGeometry([manPath UTF8String]);
        if(m_metaioMan)
        {
            // scale it a bit up
            m_metaioMan->setScale(metaio::Vector3d(1.0,1.0,1.0));
            // add it to the gesture handler.
            [m_gestureHandler addObject:m_metaioMan andGroup:1 andPickability:true];
        }
        else
        {
            NSLog(@"Error loading the metaio man model: %@", manPath);
        }
    }
    // hide the metaio man at the beginning
    [self setVisibleMan:false];
    
    // load chair
    NSString* chairPath = [[NSBundle mainBundle] pathForResource:@"stuhl" ofType:@"obj" inDirectory:@"Assets7"];
    if (chairPath)
    {
        m_chair = m_metaioSDK->createGeometry([chairPath UTF8String]);
        if (m_chair)
        {
            m_chair->setScale(metaio::Vector3d(10.0, 10.0, 10.0));
            //rotate the chair to be upright
            m_chair->setRotation(metaio::Rotation(M_PI_2, 0.0, 0.0));
            m_chair->setTranslation(metaio::Vector3d(0.0, 0.0, 0.0));
            [m_gestureHandler addObject:m_chair andGroup:2 andPickability:true];
        }
        else
        {
            NSLog(@"Error loading the chair: %@", chairPath);
        }
    }
    [self setVisibleChair:false];
    
    // load tv
    NSString* tvPath = [[NSBundle mainBundle] pathForResource:@"tv" ofType:@"obj" inDirectory:@"Assets7"];
    if (tvPath)
    {
        m_tv = m_metaioSDK->createGeometry([tvPath UTF8String]);
        if (m_tv)
        {
            m_tv->setScale(metaio::Vector3d(10.0, 10.0, 10.0));
            m_tv->setRotation(metaio::Rotation(M_PI_2, 0.0, -M_PI_2));
            m_tv->setTranslation(metaio::Vector3d(0.0, 10.0, 0.0));
            [m_gestureHandler addObject:m_tv andGroup:3 andPickability:true];
        }
        else
        {
            NSLog(@"Error loading the TV: %@", tvPath);
        }
    }
    
    // load screen
    NSString* screenPath = [[NSBundle mainBundle] pathForResource:@"screen" ofType:@"obj" inDirectory:@"Assets7"];
    if (screenPath)
    {
        m_screen = m_metaioSDK->createGeometry([screenPath UTF8String]);
        if (m_screen)
        {
            m_screen->setScale(metaio::Vector3d(10.0, 10.0, 10.0));
            m_screen->setRotation(metaio::Rotation(M_PI_2, 0.0, -M_PI_2));
            m_screen->setTranslation(metaio::Vector3d(0.0, 10.0, 0.0));
			
			// set the screen to the same group as the TV since it should be scaled/moved/rotated the same way as the TV is
            [m_gestureHandler addObject:m_screen andGroup:3 andPickability:true];
        }
        else
        {
            NSLog(@"Error loading the screen: %@", screenPath);
        }
    }
    [self setVisibleTV:false];
	
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Rotation handling


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)InterfaceOrientation
{
    // allow rotation in all directions
    return YES;
}

- (void)drawFrame
{
    [super drawFrame];
    
    // laod the dummy tracking config file once a camera image has been taken and move the geometries to a certain location on the screen
    if (m_imageTaken)
    {
        NSString* configPath = [[NSBundle mainBundle] pathForResource:@"TrackingData_Dummy" ofType:@"xml" inDirectory:@"Assets7"];
        bool result = m_metaioSDK->setTrackingConfiguration([configPath UTF8String]);
        NSLog(@"Tracking data dummy loaded: %d", (int)result);
        
		// set the previously loaded pose
		m_metaioSDK->setCosOffset(1, m_pose);
		
        // reset the location of geometries
        metaio::Vector3d translation;
        CGRect screen = [[UIScreen mainScreen] bounds];
        CGFloat width = screen.size.width * [UIScreen mainScreen].scale;
        CGFloat height = screen.size.height * [UIScreen mainScreen].scale;
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        {
            translation = m_metaioSDK->get3DPositionFromScreenCoordinates(1, metaio::Vector2d(width/2, height/2));
        }
        else
            translation = m_metaioSDK->get3DPositionFromScreenCoordinates(1, metaio::Vector2d(height/2, width/2));
        m_tv->setTranslation(translation);
        m_screen->setTranslation(translation);
        m_chair->setTranslation(translation);
        m_metaioMan->setTranslation(translation);
        m_imageTaken = false;
    }
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
        else if( [animationName compare:@"close_down"] == NSOrderedSame )
        {
            geometry->startAnimation( "close_idle", true);
        }
    }
    
}

#pragma mark - Handling Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // record the initial states of the geometries with the gesture handler
    [m_gestureHandler touchesBegan:touches withEvent:event withView:glView];
    
    // Here's how to pick a geometry
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:glView];
	
    // get the scale factor (will be 2 for retina screens)
    float scale = glView.contentScaleFactor;
    
	// ask sdk if the user picked an object
	// the 'true' flag tells sdk to actually use the vertices for a hit-test, instead of just the bounding box
    metaio::IGeometry* model = m_metaioSDK->getGeometryFromScreenCoordinates(loc.x * scale, loc.y * scale, false);
	
    if (model == m_metaioMan)
	{
		// we have touched the metaio man
		// let's start an animation
		model->startAnimation( "shock_down" , false);
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // handles the drag touch
    [m_gestureHandler touchesMoved:touches withEvent:event withView:glView];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [m_gestureHandler touchesEnded:touches withEvent:event withView:glView];
}

// handles the reactions from touching the geometry buttons. it not only show/hide the geometries, it also resets the location and the scale
- (IBAction)onTVButtonClick:(id)sender
{
    UIButton* button = (UIButton*)sender;
    // if the button is already selected, change its state to unselected, and hide the geometry
    if ([button isSelected])
    {
        [button setSelected:false];
        [self setVisibleTV:false];
        
        // set the image for the button state
        [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"button_tv_unselected" ofType:@"png" inDirectory:@"Assets7"]] forState:UIControlStateNormal];
    }
    else
    {
        [button setSelected:true];
        [self setVisibleTV:true];
        
        // reset the location of the geometry
        metaio::Vector3d translation;
        CGRect screen = [[UIScreen mainScreen] bounds];
        CGFloat width = screen.size.width * [UIScreen mainScreen].scale;
        CGFloat height = screen.size.height * [UIScreen mainScreen].scale;
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        {
            translation = m_metaioSDK->get3DPositionFromScreenCoordinates(1, metaio::Vector2d(width/2, height/2));
        }
        else
            translation = m_metaioSDK->get3DPositionFromScreenCoordinates(1, metaio::Vector2d(height/2, width/2));
        m_tv->setTranslation(translation);
        m_screen->setTranslation(translation);
		
		// start the movie
		NSString* moviePath = [[NSBundle mainBundle] pathForResource:@"sintel" ofType:@"3g2" inDirectory:@"Assets7"];
		m_screen->setMovieTexture([moviePath UTF8String]);
		m_screen->startMovieTexture();
        
        // reset the scale of the geometry
        m_tv->setScale(metaio::Vector3d(10.0, 10.0, 10.0));
        m_screen->setScale(metaio::Vector3d(10.0, 10.0, 10.0));
        
        // set the image for the button state
        [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"button_tv_selected" ofType:@"png" inDirectory:@"Assets7"]] forState:UIControlStateNormal];
    }
}

- (IBAction)onChairButtonClick:(id)sender
{
    UIButton* button = (UIButton*)sender;
    if ([button isSelected])
    {
        [button setSelected:false];
        [self setVisibleChair:false];
        
        [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"button_chair_unselected" ofType:@"png" inDirectory:@"Assets7"]] forState:UIControlStateNormal];
    }
    else
    {
        [button setSelected:true];
        [self setVisibleChair:true];
        
        metaio::Vector3d translation;
        CGRect screen = [[UIScreen mainScreen] bounds];
        CGFloat width = screen.size.width * [UIScreen mainScreen].scale;
        CGFloat height = screen.size.height * [UIScreen mainScreen].scale;
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        {
            translation = m_metaioSDK->get3DPositionFromScreenCoordinates(1, metaio::Vector2d(width/2, height/2));
        }
        else
            translation = m_metaioSDK->get3DPositionFromScreenCoordinates(1, metaio::Vector2d(height/2, width/2));
        
        m_chair->setTranslation(translation);
        m_chair->setScale(metaio::Vector3d(10.0, 10.0, 10.0));
        
        [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"button_chair_selected" ofType:@"png" inDirectory:@"Assets7"]] forState:UIControlStateNormal];
    }
}

- (IBAction)onManButtonClick:(id)sender
{
    UIButton* button = (UIButton*)sender;
    if ([button isSelected])
    {
        [button setSelected:false];
        [self setVisibleMan:false];

        [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"button_man_unselected" ofType:@"png" inDirectory:@"Assets7"]] forState:UIControlStateNormal];
    }
    else
    {
        [button setSelected:true];
        [self setVisibleMan:true];
        
        metaio::Vector3d translation;
        CGRect screen = [[UIScreen mainScreen] bounds];
        CGFloat width = screen.size.width * [UIScreen mainScreen].scale;
        CGFloat height = screen.size.height * [UIScreen mainScreen].scale;
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        {
            translation = m_metaioSDK->get3DPositionFromScreenCoordinates(1, metaio::Vector2d(width/2, height/2));
        }
        else
            translation = m_metaioSDK->get3DPositionFromScreenCoordinates(1, metaio::Vector2d(height/2, width/2));
        
        m_metaioMan->setTranslation(translation);
        m_metaioMan->setScale(metaio::Vector3d(1.0, 1.0, 1.0));
        
        [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"button_man_selected" ofType:@"png" inDirectory:@"Assets7"]] forState:UIControlStateNormal];
    }
}

- (void) setActiveConfig:(int)index
{
    switch ( index )
    {
        case 0:
            [self onTakePicture:nil];
            break;
            
            
        case 1:
			[self onSaveScreen:nil];
            break;
            
            
        case 2:
            [self onClearScreen:nil];
            break;
    }
    
}

- (IBAction)onSegmentControlChanged:(UISegmentedControl*)sender
{
    [self setActiveConfig:sender.selectedSegmentIndex];
}

// save screenshot button pressed
- (void)onSaveScreen:(id)sender
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* publicDocumentsDir = [paths objectAtIndex:0];
    
    NSError* docerror;
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:publicDocumentsDir error:&docerror];
    if (files == nil)
    {
        NSLog(@"Error reading contents of documents directory: %@", [docerror localizedDescription]);
    }
    
    NSDate* now = [NSDate date];
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* dateComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
    NSString* year = [NSString stringWithFormat:@"%d",[dateComponents year]];
    NSString* month = [NSString stringWithFormat:@"%d",[dateComponents month]];
    NSString* day = [NSString stringWithFormat:@"%d",[dateComponents day]];
    NSString* hour = [NSString stringWithFormat:@"%d",[dateComponents hour]];
    NSString* minute = [NSString stringWithFormat:@"%d",[dateComponents minute]];
    NSString* second = [NSString stringWithFormat:@"%d",[dateComponents second]];
    //        [gregorian release];
    
    NSString* fileName = [NSString stringWithFormat:@"%@_%@_%@_%@_%@_%@.jpg", year, month, day, hour, minute, second];
    
    
    NSString* fullPath = [publicDocumentsDir stringByAppendingPathComponent:fileName];
    
    
    
    m_metaioSDK->requestScreenshot([fullPath UTF8String], glView->defaultFramebuffer, glView->colorRenderbuffer);
    NSLog(@"framebuffer = %d",glView->defaultFramebuffer);

    // generate an alert to notify the user of screenshot saving
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"ATTENTION"
                                                      message:@"The screenshot has been saved to the document folder."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

// take picture button pressed.
- (void)onTakePicture:(id)sender
{
    NSString* dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [NSString stringWithFormat:@"%@/targetImage.jpg", dir];
    m_metaioSDK->requestCameraImage([filePath UTF8String], 320, 240);
}

// reset the app -- reactivate the camera, hide the geometries and change the button images to "unselected"
- (void)onClearScreen:(id)sender
{
    // reactivate the camera
    m_metaioSDK->startCamera(0);
    
    // reload the GPS tracking config file
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"TrackingData_GPSCompass" ofType:@"xml" inDirectory:@"Assets7"];
    bool result = m_metaioSDK->setTrackingConfiguration([filePath UTF8String]);
    NSLog(@"Tracking data GPS loaded: %d", (int)result);
    
    // modify the coordinate system for bettter view of the geometries
    metaio::TrackingValues pose;
    pose.translation = metaio::Vector3d(0, 0, -140);
    m_metaioSDK->setCosOffset(1, pose);
    
    [self setVisibleTV:false];
    [self setVisibleChair:false];
    [self setVisibleMan:false];
    
    // reset the button images to "unselected"
    for (UIView* subView in self.view.subviews)
    {
        if ([subView isKindOfClass:[UIButton class]])
        {
            UIButton* button = (UIButton*) subView;
            NSString* title = button.currentTitle;
            if ([title isEqual:@"TV"])
            {
                [button setSelected:false];
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"button_tv_unselected" ofType:@"png" inDirectory:@"Assets7"]] forState:UIControlStateNormal];
            }
            else if ([title isEqual:@"Chair"])
            {
                [button setSelected:false];
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"button_chair_unselected" ofType:@"png" inDirectory:@"Assets7"]] forState:UIControlStateNormal];
            }
            else if ([title isEqual: @"metaioMan"])
            {
                [button setSelected:false];
                [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"button_man_unselected" ofType:@"png" inDirectory:@"Assets7"]] forState:UIControlStateNormal];
            }
        }
    }
    
    
}

// hide/show the geometries
- (void)setVisibleTV:(bool)visible
{
    if (m_tv != NULL && m_screen != NULL)
    {
        m_tv->setVisible(visible);
        m_screen->setVisible(visible);
    }
    
    // remember to consider the movie
    if (visible)
    {
        m_screen->startMovieTexture();
    }
    else
    {
        m_screen->stopMovieTexture();
    }
}

- (void)setVisibleChair:(bool)visible
{
    if (m_chair != NULL)
    {
        m_chair->setVisible(visible);
    }
}

- (void)setVisibleMan:(bool)visible
{
    if (m_metaioMan != NULL)
    {
        m_metaioMan->setVisible(visible);
    }
}

// set the camera image as the tracking target
- (void) onCameraImageSaved: (NSString*) filepath
{
    if (filepath.length > 0)
    {
        m_metaioSDK->setImage([filepath UTF8String]);
    }
    m_imageTaken = true;
	
	//remember the current pose
	m_pose = m_metaioSDK->getTrackingValues(1);
}

-(void) onScreenshot:(NSString*) filepath
{
}

@end
