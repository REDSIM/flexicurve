using System.Collections.Generic;
using UnityEngine;

public struct BezierCurve {

    public Vector3 P0;
    public Vector3 P1;
    public Vector3 P2;
    public Vector3 P3;

    public BezierCurve(Vector3 p0, Vector3 p1, Vector3 p2, Vector3 p3) {
        P0 = p0; P1 = p1; P2 = p2; P3 = p3;
    }

    public BezierCurve(Vector3[] points) {
        P0 = points[0]; P1 = points[1]; P2 = points[2]; P3 = points[3];
    }

    // Calculates an array of points for a bezier curve with specified resolution
    public Vector3[] GetPointArray(int resolution) {
        Vector3[] dots = new Vector3[resolution + 1];
        for (int i = 0; i <= resolution; i++) {
            float t = i / (float)resolution;
            dots[i] = GetPoint(t);
        }
        return dots;
    }

    // Calculates a point on a bezier curve
    public Vector3 GetPoint(float t) {
        float u = 1 - t;
        float tt = t * t;
        float uu = u * u;
        float uuu = uu * u;
        float ttt = tt * t;
        Vector3 p = uuu * P0; // (1-t)^3 * P0
        p += 3 * uu * t * P1; // 3(1-t)^2 * t * P1
        p += 3 * u * tt * P2; // 3(1-t) * t^2 * P2
        p += ttt * P3;        // t^3 * P3
        return p;
    }

    // Calculates garland wire array with the equal spacing between points
    public Vector3[] GetUniformPointArray(float spacing) {
        float accuracy = 10 / spacing;
        int resolution = (int)(Vector3.Distance(P0, P3) * accuracy); // Bezier curve resolution based on accuracy
        Vector3[] dots = GetPointArray(resolution); // Raw bezier curve
        List<Vector3> result = new List<Vector3>() { dots[0] }; // List of all dots placed on equal distance from each other (first dot included)
        float l = 0; // Length of the curve segment that already formed
        for (int i = 0; i < dots.Length - 1; i++) { // Iterating through all of the dots but the last one
            float dist = Vector3.Distance(dots[i], dots[i + 1]);
            if (l + dist < spacing) { // Not enough length, go to the next points pair
                l += dist;
            } else { // Too much length, we need to calculate the point on this line
                Vector3 currentPoint = dots[i]; // Current point we are working with
                do {
                    float required = spacing - l; // length required for the next point
                    float t = Mathf.InverseLerp(0, dist, required); // t lerp value required to get the nrxt point
                    currentPoint = Vector3.Lerp(currentPoint, dots[i + 1], t); // Updating point we are working with
                    result.Add(currentPoint); // Adding point to the list 
                    dist = Vector3.Distance(currentPoint, dots[i + 1]); // Updating distance left
                    l = 0; // Overshooted value
                } while (Vector3.Distance(currentPoint, dots[i + 1]) >= spacing); // Iterating in case if the current raw segment is too long
                l = Vector3.Distance(currentPoint, dots[i + 1]); // Overshooted value
            }
        }
        result.Add(dots[dots.Length - 1]); // Adding the last dot
        return result.ToArray();
    }

}