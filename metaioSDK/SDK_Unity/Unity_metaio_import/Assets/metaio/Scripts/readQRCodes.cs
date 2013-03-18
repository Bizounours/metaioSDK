using UnityEngine;
using System.Collections;
using System;

public class readQRCodes : MonoBehaviour 
{

	// Use this for initialization
	void Start () 
	{
		// register game object to receive the callback onTrackingEvent
		metaioSDK.registerCallback(gameObject.name);
	}
	
	/// <summary>
	/// This is called when a QR code is detected or lost
	/// </summary>
	/// <param name='trackingEvent'>
	/// QR code data, or empty when lost
	/// </param>
	public void onTrackingEvent(String trackingEvent)
	{
		Debug.Log("onTrackingEvent: "+trackingEvent);
		
		guiText.text = trackingEvent;
		
	}
}
