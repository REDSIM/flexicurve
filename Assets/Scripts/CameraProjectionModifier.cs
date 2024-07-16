using UnityEngine;

public class CameraProjectionModifier : MonoBehaviour {
    public Transform targetTransform; // The transform to align the near clip plane with
    private Camera cam;

    void Start() {
        cam = GetComponent<Camera>();
    }

    void LateUpdate() {
        if (targetTransform != null) {
            AlignCamera(targetTransform);
        }
    }

    void AlignCamera(Transform target) {
        Vector3 relativePos = cam.worldToCameraMatrix.MultiplyPoint(target.position);
        Vector3 normal = cam.worldToCameraMatrix.MultiplyVector(target.forward).normalized;

        float d = -Vector3.Dot(normal, relativePos);
        Vector4 clipPlaneWorldSpace = new Vector4(normal.x, normal.y, normal.z, d);

        Matrix4x4 projection = cam.projectionMatrix;
        Matrix4x4 obliqueProjection = CalculateObliqueMatrix(clipPlaneWorldSpace, projection);
        cam.projectionMatrix = obliqueProjection;
    }

    Matrix4x4 CalculateObliqueMatrix(Vector4 clipPlane, Matrix4x4 projection) {
        Vector4 q = projection.inverse * new Vector4(
            Mathf.Sign(clipPlane.x),
            Mathf.Sign(clipPlane.y),
            1.0f,
            1.0f
        );
        Vector4 c = clipPlane * (2.0F / (Vector4.Dot(clipPlane, q)));
        projection[2] = c.x - projection[3];
        projection[6] = c.y - projection[7];
        projection[10] = c.z - projection[11];
        projection[14] = c.w - projection[15];

        return projection;
    }
}