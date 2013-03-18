using UnityEngine;
using System.Collections;

public class takePicture : MonoBehaviour {

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
				// request a high resolution image
				metaioMobile.requestCameraImage( new metaioMobile.CameraCallback(onCameraImageSaved), Application.persistentDataPath+"/unitycamera.jpg", 1600, 1200);
			}
		}
	}
	
	public static void onCameraImageSaved(System.String filepath)
	{
		Debug.Log("onCameraImageSaved: "+filepath);
	}
}
