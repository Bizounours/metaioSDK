using UnityEngine;
using System;
using System.Collections;
using System.Runtime.InteropServices;
using System.IO;

/// <summary>
/// This class provides main interface to the UnifeyeMobile
/// </summary>
public class metaioMobile : MonoBehaviour
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
	public const String METAIO_DLL = "as_unifeyesdkmobile";
#endif
	
	[DllImport(METAIO_DLL)]
	public static extern void createUnifeyeMobile(System.String signature);
	
	[DllImport(METAIO_DLL)]
	public static extern void deleteUnifeyeMobile();
	
	[DllImport(METAIO_DLL)]
	public static extern void render(int textureID);
	
	[DllImport(METAIO_DLL)]
	public static extern int setTrackingData(String trackingDataFile);
	
	[DllImport(METAIO_DLL)]
	public static extern int loadStandardCameraCalibration(System.String calibrationFile);
	
	[DllImport(METAIO_DLL)]
	public static extern void getFrameSize(int[] size);

	[DllImport(METAIO_DLL)]
	public static extern void getSensorAccelerometer (float[] values);
	
	[DllImport(METAIO_DLL)]
	public static extern void getProjectionMatrix(float[] matrix);
	
	[DllImport(METAIO_DLL)]
	public static extern float getTrackingValues(int cosID, float[] values);
	
#if UNITY_IPHONE || UNITY_STANDALONE_WIN || UNITY_STANDALONE_OSX
	[DllImport(METAIO_DLL)]
	public static extern void startSensors (int sensors);
	
	[DllImport(METAIO_DLL)]
	public static extern void stopSensors ();
	
	[DllImport(METAIO_DLL)]
	public static extern void startCamera(int index, int width, int height);
	
	[DllImport(METAIO_DLL)]
	public static extern void stopCamera();
#endif
	
	[DllImport(METAIO_DLL)]
	public static extern void setCosOffset(int cosID, float[] pose);
	
	[UnmanagedFunctionPointer(CallingConvention.Cdecl)]
	public delegate void CameraCallback(String error);
	
	[DllImport(METAIO_DLL)]
	public static extern void requestCameraImage(CameraCallback callback, String filepath, int width, int height);
	
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
		
		AndroidJavaClass cls = new AndroidJavaClass("com.metaio.unifeye.UnityProxy");
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
		
		AndroidJavaClass cls = new AndroidJavaClass("com.metaio.unifeye.UnityProxy");
		object[] args = {jo};
		cls.CallStatic("StopCamera", args);
	}

	public static void startSensors(int sensors)
	{
		
			AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"); 
			AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
		
			AndroidJavaClass cls = new AndroidJavaClass("com.metaio.unifeye.UnityProxy");
			object[] args = {jo, sensors};
			cls.CallStatic("StartSensors", args);
	}
	
	public static void stopSensors()
	{
			AndroidJavaClass cls = new AndroidJavaClass("com.metaio.unifeye.UnityProxy");
			cls.CallStatic("StopSensors");
	}
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
	
	void Start () 
	{
		Debug.Log("Start.createUnifeyeMobileAndroid");
		metaioMobile.createUnifeyeMobile(applicationSignature);
		Debug.Log("Start.createUnifeyeMobileAndroid was successful");
		
		// Load tracking configuration
		if (mResources.ContainsKey(trackingData))
		{
			int r = metaioMobile.setTrackingData((String)mResources[trackingData]);
			Debug.Log("Start.setTrackingData: "+r);
		}
		else
			Debug.Log("Tracking data not found in the resources");
		
		// Start the camera
		metaioMobile.startCamera(cameraIndex, cameraWidth, cameraHeight);
		
		// Start accelerometer and orientation sensors
		metaioMobile.startSensors(6);
		
	}
	
	void OnDisable()
	{
		Debug.Log("OnDestroy: deleting unifeye mobile...");
		
		metaioMobile.stopCamera();
		metaioMobile.stopSensors();
		
		// delete the instance
		deleteUnifeyeMobile();
	}
	
	/*
	void OnApplicationPause() 
	{
		// if the applications pauses, force a restart
		Debug.Log("OnApplicationPauses: quitting application");
	    Application.Quit();
	}*/

}
