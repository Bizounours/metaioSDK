using UnityEngine;
using System.Collections;

public class MovingCameraGUI : MonoBehaviour {
	
	private float SizeFactor;
	public positionCamera positionCamera;
	public GUIStyle buttonTextStyle;
	
	public GameObject[] spheres;
	
	// Use this for initialization
	void Start () {
		SizeFactor = GUIUtilities.SizeFactor;
	}
	

	// Update is called once per frame
	void Update () {
		SizeFactor = GUIUtilities.SizeFactor;
		
		foreach(GameObject sphere in spheres)
		{
			if(sphere.transform.position.y < -60)
			{
				sphere.transform.position = new Vector3(Random.Range(-50f,50f),50f, Random.Range(0f,30f));

			}
		}
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
		
	}
}
