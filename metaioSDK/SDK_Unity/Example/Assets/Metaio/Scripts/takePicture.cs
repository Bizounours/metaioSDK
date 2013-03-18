using UnityEngine;
using System.Collections;
using System;

public class takePicture : MonoBehaviour 
{

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () 
	{
		if (Input.touchCount > 0)
		{
			
			Touch t = Input.GetTouch(0);
			
			if (t.phase == TouchPhase.Ended)
			{
				Debug.Log("requestCameraImage");
				
				// request a high resolution image, the callback onCameraImageSaved will be called once
				// image has been saved to the specified file
				metaioSDK.registerCallback(gameObject.name);
				metaioSDK.requestCameraImage(Application.persistentDataPath+"/unitycamera.jpg", 1600, 1200);
			}
		}
	}
	
	public void onCameraImageSaved(System.String filepath)
	{
		Debug.Log("onCameraImageSaved: "+filepath);
		metaioSDK.registerCallback("");
	}
}
