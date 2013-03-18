using UnityEngine;
using System;
using System.Threading;

[RequireComponent(typeof(GUITexture))]
public class metaioDeviceCamera : MonoBehaviour 
{

	// Texture
    private Texture2D m_Texture;
	
	
	// Texture ID to which captured image is uploaded
	private int textureID;
	

	// false until camera image is really fixed
	private bool mCameraImageFixed;
	
	void Awake()
	{
	}
		
	void Start () 
	{
		// Reset
		transform.position = Vector3.zero;
		transform.rotation = Quaternion.identity;
		
		textureID = 0;
		
		// Stretch and crop camera image to fit full screen
		int[] frameSize = new int[2];
		metaioMobile.getFrameSize(frameSize);
		mCameraImageFixed = fixCameraImage();
		
		
	}
	
	void OnDisable() 
	{
		
	}

	
	void OnGUI ()
	{
		
		// If camera image not yet fixed, continue until it is fixed
		if (!mCameraImageFixed)
			mCameraImageFixed = fixCameraImage();
		
		
	}
	
	
	void Update ()
	{
		// Render the camera image to given texture
		metaioMobile.render (textureID);
		
		// just for debugging
		//float[] values = new float[3];
		//metaioMobile.getSensorAccelerometer (values);
		//Debug.Log ("accelerometer: " + values[0] + "," + values[1] + "," +values[2] );
	}
	
	
	private void createTexture(int frameWidth, int frameHeight)
	{
		
		// Determine texture size required to render camera image
		int textureSize = Math.Max(frameWidth, frameHeight);
		textureSize--;
		textureSize |= textureSize >> 1;
		textureSize |= textureSize >> 2;
		textureSize |= textureSize >> 4;
		textureSize |= textureSize >> 8;
		textureSize |= textureSize >> 16;
		textureSize++;
		
		Debug.Log("Creating texture with size: "+textureSize);
		
		// Create texture that will hold camera frames
        m_Texture = new Texture2D (textureSize, textureSize, TextureFormat.RGBA32, false);
		
		// Check component type again
		if (GetComponent(typeof(GUITexture)))
        {
            GUITexture gui = GetComponent(typeof(GUITexture)) as GUITexture;
			gui.transform.position = Vector3.zero;
			gui.transform.rotation = Quaternion.identity;
			
			// Set texture and retrieve texture ID for texture uploading
            gui.texture = m_Texture;
			textureID = m_Texture.GetNativeTextureID();
        }
        else
        {
            Debug.Log("Game object has no renderer or gui texture to assign the generated texture to!");
        }
		
		
		Debug.Log("Texture ID: "+textureID);
	}
	
	private bool fixCameraImage()
	{
		
		
		int[] frameSize = new int[2];
		metaioMobile.getFrameSize(frameSize);
		
		if (frameSize[0] > 0 && frameSize[1] > 0)
		{
		
			Debug.Log("Frame size: "+frameSize[0]+", "+frameSize[1]);
			Debug.Log("Screen: "+Screen.width+", "+Screen.height);
			
			createTexture(frameSize[0], frameSize[1]);
			
			// Screen.width * texture.width / camera.width
			int size = Screen.width*m_Texture.width / frameSize[0];
			
			// Offset to crop top and bottom
			int offsetY = (Screen.height - (Screen.width*frameSize[1]/frameSize[0]))/2;
			
			
			Rect newInset = new Rect(0, offsetY, size, size);
			
			guiTexture.pixelInset = newInset;
			
			return true;
		}
		else
			return false;
	}
	
	
}