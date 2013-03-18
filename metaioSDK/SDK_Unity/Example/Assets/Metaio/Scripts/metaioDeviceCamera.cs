using UnityEngine;
using System.Collections;
using System;

[RequireComponent(typeof(Camera))]
public class metaioDeviceCamera : MonoBehaviour 
{
	
	// camera plane on which camera image is rendered
	GameObject cameraPlane;
	
	// true when camera texture has been created
	bool textureCreated;
	
	// camera texture id
	int textureID;
	
	// currently used screen orientation
	ScreenOrientation screenOrientation;
	
	// Use this for initialization
	void Start () 
	{
	
		Camera cam = GetComponent(typeof(Camera)) as Camera;
		cam.orthographic = true;
		
		// initialize camera plane object
		cameraPlane = transform.FindChild("CameraPlane").gameObject;
		cameraPlane.renderer.material.shader = Shader.Find("metaio/UnlitTexture");
		cameraPlane.transform.localPosition = new Vector3(0.0f, 0.0f, 1.0f);
		
		screenOrientation = ScreenOrientation.Unknown;
		
	}
	
	// Update is called once per frame
	void Update () 
	{
		if (updateScreenOrientation())
		{
			// also update orientation of metaio SDK and camera projection
			// matrix
			metaioSDK.updateScreenOrientation(screenOrientation);
			metaioCamera.updateCameraProjectionMatrix();	
		}
		
		if (textureCreated)
		{
			// Render the camera image to the given texture
			metaioSDK.render (textureID);
		}
		else
		{
			// try to create the texture
			textureCreated = createTexture();
		}
		
	}
	
	/// <summary>
	/// Applys screen orientation to camera preview plane
	/// </summary>
	/// <returns>
	/// true when screen orientation is changed and applied to the camera plane.
	/// </returns>
	private bool updateScreenOrientation()
	{
		// if screen orientation has not changed, return false
		if (screenOrientation == Screen.orientation)
			return false;
		
		// update orthographic size
		Camera cam = GetComponent(typeof(Camera)) as Camera;
		cam.orthographicSize = getOrthographicSize(Screen.orientation);
		Debug.Log("Camera orthographic size: "+cam.orthographicSize);
		
		// update camera plane rotation
		cameraPlane.transform.localRotation = Quaternion.AngleAxis(270.0f, Vector3.right);
		
		switch (Screen.orientation)
		{
		case ScreenOrientation.Portrait:
			cameraPlane.transform.localRotation *= Quaternion.AngleAxis(90.0f, Vector3.up);
			break;
		case ScreenOrientation.LandscapeRight:
            cameraPlane.transform.localRotation *= Quaternion.AngleAxis(180.0f, Vector3.up);
        	break;
		case ScreenOrientation.PortraitUpsideDown:
            cameraPlane.transform.localRotation *= Quaternion.AngleAxis(270.0f, Vector3.up);
			break;
        }
		
		screenOrientation = Screen.orientation;
		
		return true;
	}
	
	/// <summary>
	/// Determine size of the orthographic camera based on screen orientation.
	/// </summary>
	/// <returns>
	/// The orthographic camera size.
	/// </returns>
	/// <param name='orientation'>
	/// Screen orientation
	/// </param>
	private static float getOrthographicSize(ScreenOrientation orientation)
	{
		if (orientation == ScreenOrientation.Portrait || orientation == ScreenOrientation.PortraitUpsideDown)
			return 1.0f;
		
		if (Screen.width < Screen.height)
			return ((float)Screen.width)/((float)Screen.height);
		else
			return ((float)Screen.height)/((float)Screen.width);
	}
	
	/// <summary>
	/// Create camera texture and set it to the camera plane
	/// </summary>
	/// <returns>
	/// true when texture is created, else false
	/// </returns>
	private bool createTexture()
	{
		// get required texture size
		int textureSize = metaioSDK.getCameraTextureSize();
		
		if (textureSize <= 0)
			return false;
		
		// Create the texture that will hold camera frames
		Debug.Log("Creating texture with size: "+textureSize);
        Texture2D texture = new Texture2D (textureSize, textureSize, TextureFormat.RGBA32, false);
		
		cameraPlane.renderer.material.mainTexture = texture;
		textureID = texture.GetNativeTextureID();
		
		Debug.Log("Texture ID: "+textureID);
		
		// determine scale of the camera plane
		float scale = metaioSDK.getCameraPlaneScale();
	
		Debug.Log("Camera plane scale: "+scale);
		
		cameraPlane.transform.localScale = new Vector3(-scale, scale, scale);
		
		return true;
	}
	
}
