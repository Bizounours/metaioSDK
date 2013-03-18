using UnityEngine;
using System.Collections;

public class Slam3DGUI : MonoBehaviour {
	
	public metaioSDK metaioSDKObject;
	private float SizeFactor;
	public GUIStyle buttonTextStyle;
	private bool trackingStarted = false;
	
	// Use this for initialization
	void Start () {
		metaioSDK.registerCallback(gameObject.name);
	}
	
	// Update is called once per frame
	void Update () {
		SizeFactor = GUIUtilities.SizeFactor;
	}
	
	void OnGUI () {
		
		if(GUIUtilities.ButtonWithText(new Rect(
			Screen.width - 200*SizeFactor,
			Screen.height - 100*SizeFactor,
			200*SizeFactor,
			100*SizeFactor),"Back",null,buttonTextStyle) ||	Input.GetKeyDown(KeyCode.Escape)) {
			PlayerPrefs.SetInt("backFromARScene", 1);
			Application.LoadLevel("MainMenu");
		}
		
		GUI.enabled = !trackingStarted;
		
		if(GUIUtilities.ButtonWithText(new Rect(
				0,
				Screen.height - 300*SizeFactor,
				200*SizeFactor,
				100*SizeFactor),"2D",null,buttonTextStyle))
		{
			// start instant tracking, it will call the callback once done
			metaioSDK.startInstantTracking("INSTANT_2D", "");
			trackingStarted = true;
		}
		if(GUIUtilities.ButtonWithText(new Rect(
				0,
				Screen.height - 200*SizeFactor,
				300*SizeFactor,
				100*SizeFactor),"2D rectified",null,buttonTextStyle))
		{
				
			// start instant tracking, it will call the callback once done
			metaioSDK.startInstantTracking("INSTANT_2D_GRAVITY", "");
			trackingStarted = true;
		}
		
		if(GUIUtilities.ButtonWithText(new Rect(
				0,
				Screen.height - 100*SizeFactor,
				200*SizeFactor,
				100*SizeFactor),"3D",null,buttonTextStyle))
		{
				
			// start instant tracking, it will call the callback once done
			metaioSDK.startInstantTracking("INSTANT_3D", "");
			trackingStarted = true;
		}
		
		GUI.enabled = true;
	}
	
	
	
	public void onInstantTrackingEvent(string filepath)
	{
		Debug.Log("onInstantTrackingEvent: "+filepath);
		
			trackingStarted = false;
		// if succeeded, set new tracking configuration
		if (filepath.Length > 0)
		{
			int result = metaioSDK.setTrackingConfiguration(filepath);
			Debug.Log("onInstantTrackingEvent: instant tracking configuration loaded: "+result);
		}
		
	}
}
