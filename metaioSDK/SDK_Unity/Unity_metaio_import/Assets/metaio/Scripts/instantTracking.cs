using UnityEngine;
using System.Collections;
using System;

public class instantTracking : MonoBehaviour 
{

	void Update () 
	{
		if (Input.touchCount > 0)
		{
			
			Touch t = Input.GetTouch(0);
			
			if (t.phase == TouchPhase.Ended)
			{
				Debug.Log("Starting instant tracking");
				
				String trackingConfiguration = "INSTANT_2D";
				
				// start instant tracking, the callback onInstantTrackingEvent will be
				// called once instant tracking is done.
				metaioSDK.registerCallback(gameObject.name);
				metaioSDK.startInstantTracking(trackingConfiguration, "");
			}
		}
	}
	
	/// <summary>
	/// This is called when instant tracking has succeeded or failed.
	/// </summary>
	/// <param name='filepath'>
	/// Tracking configuration file path in case of success, else empty when failed.
	/// </param>
	public void onInstantTrackingEvent(String filepath)
	{
		Debug.Log("onInstantTrackingEvent: "+filepath);
		
		// if succeeded, set new tracking configuration
		if (filepath.Length > 0)
		{
			int result = metaioSDK.setTrackingConfiguration(filepath);
			Debug.Log("onInstantTrackingEvent: instant tracking configuration loaded: "+result);
		}
		
	}
}

