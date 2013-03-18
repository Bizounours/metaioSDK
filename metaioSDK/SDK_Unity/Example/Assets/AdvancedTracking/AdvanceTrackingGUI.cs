using UnityEngine;
using System.Collections;

public class AdvanceTrackingGUI : MonoBehaviour {
	
	
	public metaioSDK metaioSDKObject;
	public GUIStyle buttonTextStyle;
	float SizeFactor;
	
	// Use this for initialization
	void Start () {
		SizeFactor = GUIUtilities.SizeFactor;
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
		
		if(GUIUtilities.ButtonWithText(new Rect(
				0,
				Screen.height - 300*SizeFactor,
				300*SizeFactor,
				100*SizeFactor),"Picture",null,buttonTextStyle))
		{
			metaioSDKObject.setTrackingConfigurationFromResource("TrackingData_PictureMarker.xml");

		}
		
		if(GUIUtilities.ButtonWithText(new Rect(
				0,
				Screen.height - 200*SizeFactor,
				300*SizeFactor,
				100*SizeFactor),"Markerless",null,buttonTextStyle))
		{
			metaioSDKObject.setTrackingConfigurationFromResource("TrackingData_MarkerlessFast.xml");

		}
		
		if(GUIUtilities.ButtonWithText(new Rect(
				0,
				Screen.height - 100*SizeFactor,
				300*SizeFactor,
				100*SizeFactor),"ID Marker",null,buttonTextStyle))
		{
			metaioSDKObject.setTrackingConfigurationFromResource("TrackingData_IDMarker.xml");
		}
		
		
	}
}
