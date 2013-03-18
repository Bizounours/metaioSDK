using UnityEngine;
using System.Collections;

public class metaioTrackerLLA : MonoBehaviour 
{

	// Latitude of the game object
	public double latitude;
	
	// Longitude of the game object
	public double longitude;
	
	// buffer to hold temporary cartesian translations
	private float[] translation;
	
	// buffer to hold temporary tracking values
	private float[] trackingValues;
	
	
	void Start () 
	{
		trackingValues = new float[7];
		translation = new float[3];
		translation[0] = 0;
		translation[1] = 0;
		translation[2] = 0;
		
	}
	
	// Update is called once per frame
	void Update () 
	{
		
		float quality = metaioSDK.getTrackingValues(1, trackingValues);
		
//		Debug.Log("Tracking quality: "+quality);
		
		
		// If quality is greater than 0, the target is detected in the current frame
		if (quality > 0)
		{
		
			// Apply rotation
			Quaternion q;
			q.x = trackingValues[3];
			q.y = trackingValues[4];
			q.z = trackingValues[5];
			q.w = trackingValues[6];
			transform.rotation = q;
			
//			Debug.Log("Rotation: "+q.ToString());
			
			// Apply cartesian translation
			Vector3 p;
			p.x = trackingValues[0];
			p.y = trackingValues[1];
			p.z = trackingValues[2];
			transform.position = p;
			
//			Debug.Log("Cartesian translation: "+transform.position.ToString());
			
			// convert LLA to cartesian translation
			metaioSDK.convertLLAToTranslation(latitude, longitude, translation);
//			Debug.Log("LLA translation: "+translation[0]+", "+translation[1]+", "+translation[2]);
			
			// Augment LLA cartesian translation
			Vector3 tLLA;
			tLLA.x = translation[0];
			tLLA.y = translation[1];
			tLLA.z = translation[2];
			transform.Translate(tLLA);
			
//			Debug.Log("Final translation: "+transform.position.ToString());
			
		}
		
	}
	
}
