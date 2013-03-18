using UnityEngine;
using System;
using System.Collections;
using System.Runtime.InteropServices;
using System.IO;

/// <summary>
/// This class provides main interface to the metaio SDK
/// </summary>
public class metaioSDK : MonoBehaviour
{
	
	
#region Public fields

	// Application signature for license verification
	public String applicationSignature;
	
	// Path to tracking data file
	public String trackingData;
	
	// Device camera index
	public static int cameraIndex = 0;
	
	// Device camera width
	public static int cameraWidth = 320;
	
	// Device camera height
	public static int cameraHeight = 240;
	
#endregion
	
#region DLL functions

	
#if UNITY_IPHONE
	public const String METAIO_DLL = "__Internal";
#else
	public const String METAIO_DLL = "metaiosdk";
#endif
	
	[DllImport(METAIO_DLL)]
	public static extern int createMetaioSDKUnity(System.String signature);
	
	[DllImport(METAIO_DLL)]
	public static extern void deleteMetaioSDKUnity();
	
	[DllImport(METAIO_DLL)]
	public static extern void registerCallback(String gameObjectName);
	
	[DllImport(METAIO_DLL)]
	public static extern void setScreenRotation(int rotation);
	
	[DllImport(METAIO_DLL)]
	public static extern void render(int textureID);
	
	[DllImport(METAIO_DLL)]
	public static extern int setTrackingConfiguration(String trackingDataFile);
	
	[DllImport(METAIO_DLL)]
	public static extern int setCameraParameters(System.String cameraFile);
	
	[DllImport(METAIO_DLL)]
	public static extern void setRendererClippingPlaneLimits(float nearCP, float farCP);
	
	[DllImport(METAIO_DLL)]
	public static extern void getFrameSize(int[] size);
	
	[DllImport(METAIO_DLL)]
	public static extern int getCameraTextureSize();
	
	[DllImport(METAIO_DLL)]
	public static extern float getCameraPlaneScale();

	[DllImport(METAIO_DLL)]
	public static extern void getSensorGravity(float[] values);
	
	[DllImport(METAIO_DLL)]
	public static extern void getLocation(double[] values);
	
	[DllImport(METAIO_DLL)]
	public static extern void getProjectionMatrix(float[] matrix);
	
	[DllImport(METAIO_DLL)]
	public static extern float getTrackingValues(int cosID, float[] values);

	[DllImport(METAIO_DLL)]
	public static extern void startSensors(int sensors);
	
	[DllImport(METAIO_DLL)]
	public static extern void stopSensors(int sensors);
	
	[DllImport(METAIO_DLL)]
	public static extern void pauseSensors();
	
	[DllImport(METAIO_DLL)]
	public static extern void resumeSensors();
	
	[DllImport(METAIO_DLL)]
	public static extern void setManualLocation(float latitude, float longitude, float altitude);
	
	[DllImport(METAIO_DLL)]
	public static extern void resetManualLocation();
	
	[DllImport(METAIO_DLL)]
	public static extern void setCosOffset(int cosID, float[] pose);
	
	[DllImport(METAIO_DLL)]
	public static extern void requestCameraImage(String filepath, int width, int height);
	
	[DllImport(METAIO_DLL)]
	public static extern int startInstantTracking(String trackingConfiguration, String outFile);
	
	[DllImport(METAIO_DLL)]
	public static extern void convertLLAToTranslation(double latitude, double longitude, float[] translation);
	
	// This table holds copied resources that will be used
	// by metaioSDK
	private Hashtable mResources;
	

#if UNITY_ANDROID
	/// <summary>
	///  Start device camera
	/// </summary>
	public static void startCamera(int index, int width, int height)
	{
		
		AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"); 
		AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
	
		Debug.Log("Application context: "+jo.ToString());
		
		AndroidJavaClass cls = new AndroidJavaClass("com.metaio.sdk.UnityProxy");
		object[] args = {jo, index, width, height};
		cls.CallStatic("StartCamera", args);
		
	}

	/// <summary>
	/// Stop device camera
	/// </summary>
	public static void stopCamera()
	{
		AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"); 
		AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
	
		Debug.Log("Application context: "+jo.ToString());
		
		AndroidJavaClass cls = new AndroidJavaClass("com.metaio.sdk.UnityProxy");
		object[] args = {jo};
		cls.CallStatic("StopCamera", args);
	}

#endif
	
#if UNITY_IPHONE || UNITY_STANDALONE_WIN || UNITY_STANDALONE_OSX

	[DllImport(METAIO_DLL)]
	public static extern void startCamera(int index, int width, int height);
	
	[DllImport(METAIO_DLL)]
	public static extern void stopCamera();
	
#endif
	
#endregion
	
	void Awake()
	{
		Debug.Log("Application.dataPath: "+Application.dataPath);
		Debug.Log("Application.persistentDataPath: "+Application.persistentDataPath);
		
		// Load all resources from Resources/metaio directory
		UnityEngine.Object[] resources = Resources.LoadAll("metaio");
		
		mResources = new Hashtable(resources.Length);
	
		foreach (UnityEngine.Object r in resources)
		{
			
			try
			{
				if (r.GetType() == typeof(TextAsset))
				{
					TextAsset a = (TextAsset)r;
					Debug.Log("Resources loaded: "+a.name);
						
					String filepath = Application.persistentDataPath+"/"+a.name;
					
					FileStream file = File.Create(filepath);
					file.Write(a.bytes, 0, a.bytes.Length);
					file.Close();
					
					mResources.Add(a.name, filepath);
					
				}
			}
			catch (Exception e)
			{
				Debug.Log("Error copying metaio assets: "+e);
			}
			
			
			
		}
		
	}
	
	/// <summary>
	/// Updates the screen orientation of metaio SDK
	/// </summary>
	/// <param name='orientation'>
	/// Screen orientation.
	/// </param>
	public static void updateScreenOrientation(ScreenOrientation orientation)
	{
		switch (orientation)
		{
		case ScreenOrientation.LandscapeLeft:
			setScreenRotation(0);
			break;
		case ScreenOrientation.LandscapeRight:
			setScreenRotation(2);
			break;
		case ScreenOrientation.Portrait:
			setScreenRotation(3);
			break;
		case ScreenOrientation.PortraitUpsideDown:
			setScreenRotation(1);
			break;
		}
		
	}
	
	/// <summary>
	/// Sets the tracking configuration from resource or a named string.
	/// </summary>
	/// <returns>
	/// non-zero in case of success, else 0
	/// </returns>
	/// <param name='trackingConfig'>
	/// XML file name in the resource, or a named string, e.g. "LLA" or "QRCODE"
	/// </param>
	public int setTrackingConfigurationFromResource(string trackingConfig)
    {
        int result = 0;
		if (mResources.ContainsKey(trackingConfig))
		{
			result = metaioSDK.setTrackingConfiguration((String)mResources[trackingConfig]);
		}
		else if (trackingConfig != null)
		{
			// its should only be used to loaded pre-defined tracking configurations, e.g. "GPS", "LLA" etc.
			Debug.Log("Tracking data not found in the resources, using tracking data string");
			result = metaioSDK.setTrackingConfiguration(trackingConfig);
		}
		
		return result;
    }
	
	void Start () 
	{
		int result = createMetaioSDKUnity(applicationSignature);
		if (result == 0)
			Debug.Log("metaio SDK created succesfully");
		else
			Debug.LogError("Failed to create metaio SDK!");
		
		updateScreenOrientation(Screen.orientation);
				
		// Start the camera
		startCamera(cameraIndex, cameraWidth, cameraHeight);
		
		// Load tracking configuration
		result = setTrackingConfigurationFromResource(trackingData);
		
		Debug.Log("Start.setTrackingData: "+result);
		
	}
	
	void OnDisable()
	{
		Debug.Log("OnDestroy: deleting metaio sdk...");
		
		// stop camera before deleting the instance
		stopCamera();
		
		// delete the instance
		deleteMetaioSDKUnity();
	}
	
	void OnApplicationPause(bool pause)
	{
		Debug.Log("OnApplicationPause: "+pause);
		
		if (pause)
		{
			pauseSensors();
			stopCamera();
			
		}
		else
		{
			resumeSensors();
			startCamera(cameraIndex, cameraWidth, cameraHeight);
		}
	}

}
