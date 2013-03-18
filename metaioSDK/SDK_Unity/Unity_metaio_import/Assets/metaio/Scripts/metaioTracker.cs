using UnityEngine;
using System;

public class metaioTracker : MonoBehaviour 
{
	
	// COS ID
	public int cosID;
	
	// Holds temprary tracking values
	private float[] trackingValues;
	
	
	void Start () 
	{
		trackingValues = new float[7];
	}
	
	// Update is called once per frame
	void Update () 
	{
		
		float quality = metaioSDK.getTrackingValues(cosID, trackingValues);
		
		//Debug.Log("Tracking quality: "+quality);

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
			
			//Debug.Log("Rotation: "+q.ToString());
			
			// Apply translation
			Vector3 p;
			p.x = trackingValues[0];
			p.y = trackingValues[1];
			p.z = trackingValues[2];
			transform.position = p;
			
			//Debug.Log("Translation: "+p.ToString());
			
			// show childs
			enableRenderingChilds(true);
			
		}
		else
		{
			// hide because target not tracked
			enableRenderingChilds(false);
		}
		
	}
	
	// Enable/disable rendering
	private void enableRenderingChilds(bool enable)
    {
        Renderer[] rendererComponents = GetComponentsInChildren<Renderer>();

        foreach (Renderer component in rendererComponents) 
		{
            component.enabled = enable;
        }

    }

}
