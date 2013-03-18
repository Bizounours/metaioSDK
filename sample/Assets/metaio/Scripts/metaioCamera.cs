using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Camera))]
public class metaioCamera : MonoBehaviour 
{
	private bool mCameraProjectionSet;
	
	// Use this for initialization
	void Start () 
	{
		
		camera.transform.position = Vector3.zero;
		camera.transform.rotation = Quaternion.identity;
		
		mCameraProjectionSet = false;
	}
	
	
	// Update is called once per frame
	void Update () 
	{
		//Debug.Log( "calling Update" );
		
		// Only set once
		if (!mCameraProjectionSet)
		{
			float[] m = new float[16];
		
			// Retrieve camera projection matrix
			metaioMobile.getProjectionMatrix(m);
		
			// quick test to validate projection matrix
			if (m[0] > 0)
			{
		
				// Create matrix, note that array returned by SDK is row-ordered
				
				Matrix4x4 matrix;
				
				matrix.m00 = m[0];
				matrix.m10 = m[1];
				matrix.m20 = m[2];
				matrix.m30 = m[3];
				
				matrix.m01 = m[4];
				matrix.m11 = m[5];
				matrix.m21 = m[6];
				matrix.m31 = m[7];
				
				matrix.m02 = m[8];
				matrix.m12 = m[9];
				matrix.m22 = m[10];
				matrix.m32 = m[11];
				
				matrix.m03 = m[12];
				matrix.m13 = m[13];
				matrix.m23 = m[14];
				matrix.m33 = m[15];
				
				camera.projectionMatrix = matrix;

				Debug.Log("setting projection matrix is " + camera.projectionMatrix.ToString());
				
				mCameraProjectionSet = true;
			}
		
		}
		
	}
}

