using System;
using UnityEngine;

public class Utils {

    // Calculates bezier curve for a wire hanging down based on point a, point b and a vertical sag
    public static BezierCurve BezierWire(Vector3 a, Vector3 b, float sag) {
        BezierCurve result = new BezierCurve();
        result.P0 = a; // First point
        result.P3 = b; // Last point
        Vector3 centerPoint = (a + b) / 2;
        centerPoint = new Vector3(centerPoint.x, centerPoint.y + sag, centerPoint.z); // Vertical offset
        result.P1 = (a + centerPoint) / 2;
        result.P2 = (b + centerPoint) / 2;
        return result;
    }

    // Get point on a circle in 3D space
    public static Vector3 PointOnCircle(Vector3 center, float radius, Vector3 normal, Vector3 tangent, float angle) {
        return center + radius * (Mathf.Cos(angle) * tangent + Mathf.Sin(angle) * Vector3.Cross(normal, tangent));
    }

    // Super simple pseudo-random
    public static float Random01(float seed) {
        return Mathf.Repeat(Mathf.Sin(seed * 12.9898f) * 43758.5453f, 1f);
    }
    // Super simple pseudo-random range
    public static float RandomRange(float min, float max, float seed) {
        return Mathf.Lerp(min, max, Random01(seed));
    }
    // Super simple pseudo-random angle in degrees
    public static float RandomAngle(float seed) {
        return Mathf.Lerp(-180, 180, Random01(seed));
    }

}