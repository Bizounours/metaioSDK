//
//  Tutorial7ViewController.h
//  Example
//
//  Created by  on 10/24/12.
//  Copyright 2007-2012 metaio GmbH. All rights reserved.
//

#import "MetaioSDKViewController.h"
#import <metaioSDK/GestureHandlerIOS.h>

@interface Tutorial7ViewController : MetaioSDKViewController
{
    // pointers to geometries
    metaio::IGeometry* m_metaioMan; 
    metaio::IGeometry* m_chair; 
    metaio::IGeometry* m_tv;
    metaio::IGeometry* m_screen;
    // GestureHandler handles the dragging/pinch/rotation touches
    GestureHandlerIOS* m_gestureHandler;
    //gesture mask to specify the gestures that are enabled
    int m_gestures;
    //indicate if a camera image has been requested from the user
    bool m_imageTaken;
	// remember the TrackingValues
	metaio::TrackingValues m_pose;
}
//geometry button callback to show/hide the geometry and reset the location and scale of the geometry
- (IBAction)onTVButtonClick:(id)sender;
- (IBAction)onChairButtonClick:(id)sender;
- (IBAction)onManButtonClick:(id)sender;

/* Handle segment control */
- (IBAction)onSegmentControlChanged:(UISegmentedControl*)sender;
- (void)onSaveScreen:(id)sender;
- (void)onTakePicture:(id)sender;
- (void)onClearScreen:(id)sender;

//show/hide the geometries
- (void)setVisibleTV:(bool)visible;
- (void)setVisibleChair:(bool)visible;
- (void)setVisibleMan:(bool)visible;
@end


