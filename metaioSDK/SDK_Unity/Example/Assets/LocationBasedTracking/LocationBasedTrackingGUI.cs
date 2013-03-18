using UnityEngine;
using System.Collections;

public class LocationBasedTrackingGUI : MonoBehaviour {
	
	public GameObject berlin;
	public GameObject london;
	public GameObject paris;
	public GameObject newyork;
	public GameObject rome;
	
	private Vector3 berlinScreen;
	private Vector3 londonScreen;
	private Vector3 parisScreen;
	private Vector3 newyorkScreen;
	private Vector3 romeScreen;
	
	public Camera myCamera;
	
	public GUIStyle buttonTextStyle;
	private float SizeFactor;
	
	public GUIStyle textStyle;
	public GUIStyle textShadowStyle;
	
	// Use this for initialization
	void Start () {
		SizeFactor = GUIUtilities.SizeFactor;
	}
	
	// Update is called once per frame
	void Update () {
		SizeFactor = GUIUtilities.SizeFactor;
		
		berlinScreen = myCamera.WorldToScreenPoint(berlin.transform.position);
		londonScreen = myCamera.WorldToScreenPoint(london.transform.position);
		parisScreen = myCamera.WorldToScreenPoint(paris.transform.position);
		newyorkScreen = myCamera.WorldToScreenPoint(newyork.transform.position);
		romeScreen = myCamera.WorldToScreenPoint(rome.transform.position);
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
		
		if(berlinScreen.z > 0)
		{
			GUIUtilities.Text(new Rect( berlinScreen.x + 3 * SizeFactor, Screen.height - berlinScreen.y + 3 * SizeFactor, 0, 0), "Berlin", textShadowStyle);
			GUIUtilities.Text(new Rect( berlinScreen.x, Screen.height - berlinScreen.y,	0, 0), "Berlin", textStyle);
		}
		if(londonScreen.z > 0)
		{
			GUIUtilities.Text(new Rect( londonScreen.x + 3 * SizeFactor, Screen.height - londonScreen.y + 3 * SizeFactor, 0, 0), "London", textShadowStyle);
			GUIUtilities.Text(new Rect( londonScreen.x, Screen.height - londonScreen.y,	0, 0), "London", textStyle);
		}
		if(parisScreen.z > 0)
		{
			GUIUtilities.Text(new Rect( parisScreen.x + 3 * SizeFactor, Screen.height - parisScreen.y + 3 * SizeFactor, 0, 0), "Paris", textShadowStyle);
			GUIUtilities.Text(new Rect( parisScreen.x, Screen.height - parisScreen.y, 0, 0), "Paris", textStyle);
		}
		if(newyorkScreen.z > 0)
		{
			GUIUtilities.Text(new Rect( newyorkScreen.x + 3 * SizeFactor, Screen.height - newyorkScreen.y + 3 * SizeFactor, 0, 0), "New York", textShadowStyle);
			GUIUtilities.Text(new Rect( newyorkScreen.x, Screen.height - newyorkScreen.y, 0, 0), "New York", textStyle);
		}
		if(romeScreen.z > 0)
		{
			GUIUtilities.Text(new Rect( romeScreen.x + 3 * SizeFactor, Screen.height - romeScreen.y + 3 * SizeFactor, 0, 0), "Rome", textShadowStyle);
			GUIUtilities.Text(new Rect( romeScreen.x, Screen.height - romeScreen.y, 0, 0), "Rome", textStyle);
			
		}

	}
}
