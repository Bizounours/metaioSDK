using UnityEngine;
using System.Collections;
using System;

public class readLLAMarker : MonoBehaviour 
{
	// Use this for initialization
	void Start () 
	{
		// register game object to receive the callback onTrackingEvent
		metaioSDK.registerCallback(gameObject.name);
	}
		
	public void onTrackingEvent(String trackingEvent)
	{
		Debug.Log("onTrackingEvent: "+trackingEvent);
		
		string[] values = trackingEvent.Split(',');
		
		if (values.Length == 4)
		{
			float latitude = float.Parse(values[0]);
			float longitude = float.Parse(values[1]);
			float altitude = float.Parse(values[2]);
			float accuracy = float.Parse(values[3]);
			
			// optionaly set manual location
			if (accuracy >= 0)
				metaioSDK.setManualLocation(latitude, longitude, altitude);

			
		}
		
	}
}
