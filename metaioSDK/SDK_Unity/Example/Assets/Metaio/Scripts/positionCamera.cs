using UnityEngine;
using System;


//Instead of transforming the objects in space and using a static camera, we actually transform the camera, otherwise
//the Unity physics will not work correctly. This should work as long as we only use one target.

public class positionCamera : MonoBehaviour 
{	
	
	public Camera cameraToPosition;
	

	public float quality;
	
	// COS ID
	public int cosID;	

	// Holds temprary tracking values
	private float[] trackingValues;	

	
	void Start () 
	{
		trackingValues = new float[7];	

	}

	// Update is called once per frame
	void Update  () 
	{
		quality = metaioSDK.getTrackingValues(cosID, trackingValues);
		
		
		if (quality > 0f)
		{
			//Debug.LogError("quality: " + quality);
			//rotation
			Quaternion q;

			q.x = trackingValues[3];
			q.y = trackingValues[4];
			q.z = trackingValues[5];
			q.w = trackingValues[6];

			
			//translation
			Vector3 p;
			p.x = trackingValues[0];
			p.y = trackingValues[1];
			p.z = trackingValues[2];
			
			

			Matrix4x4 rotationMatrix = new Matrix4x4();
			NormalizeQuaternion(ref q);

			rotationMatrix.SetTRS(Vector3.zero, 
			                       q,
			                       new Vector3(1.0f, 1.0f, 1.0f));

			Matrix4x4 translationMatrix = new Matrix4x4();
			translationMatrix.SetTRS(p, 
			                       new Quaternion(0.0f, 0.0f, 0.0f, 1.0f),
			                       new Vector3(1.0f, 1.0f, 1.0f));
			
			//split up rotation and translation
			Matrix4x4 composed = translationMatrix * rotationMatrix;
			//from world to camera so we have to invert the matrix
			Matrix4x4 invertedMatrix = composed.inverse;


            Quaternion rotation = QuaternionFromMatrix(invertedMatrix);
			
			Vector3 eulerRot = rotation.eulerAngles;
	
//	        //center the camera in front of goal - z-axis			
			cameraToPosition.transform.position = invertedMatrix.GetColumn(3);
			cameraToPosition.transform.rotation = QuaternionFromMatrix(invertedMatrix);
			
			
            Quaternion quat = cameraToPosition.transform.rotation;
            Vector3 euler = quat.eulerAngles;
			
			// show childs
			enableRenderingChilds(true);
			
		}
		else
		{
			// hide because target not tracked
			enableRenderingChilds(false);
		}
	
	}

	

	private void TransformFromMatrix(Matrix4x4 matrix, Transform trans) {
	    trans.rotation = QuaternionFromMatrix(matrix);
	    trans.position = matrix.GetColumn(3); // uses implicit conversion from Vector4 to Vector3
	}



	private Quaternion QuaternionFromMatrix(Matrix4x4 m) {
	    // Adapted from: http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm

	    Quaternion q = new Quaternion();
	    q.w = Mathf.Sqrt( Mathf.Max( 0, 1 + m[0,0] + m[1,1] + m[2,2] ) ) / 2; 
	    q.x = Mathf.Sqrt( Mathf.Max( 0, 1 + m[0,0] - m[1,1] - m[2,2] ) ) / 2; 
	    q.y = Mathf.Sqrt( Mathf.Max( 0, 1 - m[0,0] + m[1,1] - m[2,2] ) ) / 2; 
	    q.z = Mathf.Sqrt( Mathf.Max( 0, 1 - m[0,0] - m[1,1] + m[2,2] ) ) / 2; 

	    q.x *= Mathf.Sign( q.x * ( m[2,1] - m[1,2] ) );
	    q.y *= Mathf.Sign( q.y * ( m[0,2] - m[2,0] ) );
	    q.z *= Mathf.Sign( q.z * ( m[1,0] - m[0,1] ) );

	    return q;

	}

	
	private Matrix4x4 multMatrix(Matrix4x4 m1, Matrix4x4 m2) {
	    
		Matrix4x4 result = new Matrix4x4();
		for(int i = 0; i < 4; i++)
		{
			for(int n = 0; n < 4; n++)
			{
				double sum = 0;
				for(int o = 0; o < 4; o++)
				{
					sum = sum + m1[i,o] * m2[o,n];
				}				

				result[i,n] = (float)sum;
			}
		}
		return result;
	}


	private void NormalizeQuaternion (ref Quaternion q)
	{
	    float sum = 0;
	    for (int i = 0; i < 4; ++i)
	        sum += q[i] * q[i];
	    float magnitudeInverse = 1 / Mathf.Sqrt(sum);
	    for (int i = 0; i < 4; ++i)
	        q[i] *= magnitudeInverse;
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

