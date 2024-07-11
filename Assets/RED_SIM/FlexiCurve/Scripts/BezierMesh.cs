using System.Collections.Generic;
using UnityEngine;

public class BezierMesh {

    public BezierCurve Curve;
    public float Spacing = 0.1f;
    public float Radius = 0.05f;
    public int Edges = 5;
    public float Decimation = 1;
    public bool ClosedSides = true;

    public Vector3[] Vertices { get; private set; }
    public Vector3[] Normals { get; private set; }
    public int[] Triangles { get; private set; }
    public Vector4[] UV0 { get; private set; }
    public Vector2[] UV1 { get; private set; }

    public float Length => _length;
    private float _length = 0; // Physical length

    public BezierMesh() {
    }

    public BezierMesh(BezierCurve curve, float radius, float spacing, int edges, float decimation, bool closedSides) {
        Curve = curve; Radius = radius; Edges = edges; Spacing = spacing; ClosedSides = closedSides; Decimation = decimation;
    }

    public BezierMesh(Vector3 a, Vector3 b, float sag, float radius, float spacing, int edges, float decimation, bool closedSides) {
        Curve = Utils.BezierWire(a, b, sag); Radius = radius; Edges = edges; Spacing = spacing; ClosedSides = closedSides; Decimation = decimation;
    }

    // Recalculates points, vertices, triangles. Offset of vertex indexes for triangles array. Usefull when manually batching meshes.
    public void Recalculate(int offset) {

        _length = 0; // Resetting physical length

        Vector3 tangent; // Calculating tangent for circle formation
        Vector3 dir = Curve.P0 - Curve.P3;
        // Id this segment is vertical, there is another way to calculate tangent
        if (Mathf.Abs(dir.x) < 0.00001f && Mathf.Abs(dir.z) < 0.00001f) tangent = Vector3.Cross(Vector3.forward, dir).normalized;
        else tangent = Vector3.Cross(Vector3.up, dir).normalized;

        Vector3[] pointsRaw = Curve.GetUniformPointArray(Spacing); // Raw not decimated points array
        List<Vector3> points = new List<Vector3>(); // Decimated points array

        // Mesh attributes
        List<Vector3> vertices = new List<Vector3>();
        List<Vector3> normals = new List<Vector3>();
        List<int> triangles = new List<int>();
        List<Vector4> uv0 = new List<Vector4>();
        List<Vector2> uv1 = new List<Vector2>();

        Vector3 dirCurr; // Current direction to compare
        Vector3 dirPrev; // Prev direction to compare
        Vector3 pointLast = pointsRaw[0]; // Last point added to points array

        // Decimating curve by filtering points we dont need and calculating overall physical length
        for (int i = 0; i < pointsRaw.Length; i++) {
            if (i > 0 && i < pointsRaw.Length - 1 && Decimation > 0) { // Skip point if there's no big difference in angle between current and previous directions
                dirCurr = pointsRaw[i + 1] - pointsRaw[i];
                dirPrev = pointsRaw[i] - pointLast;
                float dot = Vector3.Dot(dirCurr.normalized, dirPrev.normalized);
                if (dot * dot > 1 - Decimation) continue;
            }
            if(i != 0) _length += (pointsRaw[i] - pointLast).magnitude; // Incrementing length
            pointLast = pointsRaw[i];
            points.Add(pointLast);
        }

        // Iterating through points
        float currentLength = 0;
        int pointsCount = points.Count;
        for (int i = 0; i < pointsCount; i++) {
            
            // Calculating normal for circle generation
            if (i == 0) dirCurr = Vector3.Normalize(points[i + 1] - points[i]); // First point
            else if (i == pointsCount - 1) dirCurr = Vector3.Normalize(points[i] - points[i - 1]); // Last point
            else dirCurr = Vector3.Normalize(Vector3.Normalize(points[i + 1] - points[i]) + Vector3.Normalize(points[i] - points[i - 1])); // Other points

            int vtc = vertices.Count; // Current vertex count in previous loops

            // Calculating X-UV
            float x0 = 0, x1 = 0; // x0 is X for main uv map, x1 is X for lightmap uv
            if (i != 0) {
                currentLength += (points[i] - points[i - 1]).magnitude;
                x0 = currentLength / (Mathf.PI * 2 * Radius);
                x1 = Mathf.Clamp01(currentLength / _length);
            }
            

            int edgesExtra = Edges + 1; // We need extra edge for UV mapping seam
            for (int n = 0; n < edgesExtra; n++) { // Iterating through vertex loop

                // Actual vertex id, one extra for a seam
                int v = n == Edges ? 0 : n;

                // Generating vertices
                float angle = 2 * Mathf.PI * v / Edges;
                Vector3 vert = Utils.PointOnCircle(points[i], Radius, dirCurr, tangent, angle);
                vertices.Add(vert); // Filling vertices array
                normals.Add((vert - points[i]).normalized);

                // Calculating Y-UV
                float y = n == Edges ? 1 : (float) v / Edges;
                uv0.Add(new Vector4(x0, y, 0, 0));
                uv1.Add(new Vector2(x1, y));

                // Generating quads
                if (i == pointsCount - 1 || n == Edges) continue; // Skip last loop or the last vertex for seam

                int nn = n + 1;

                // First triangle
                triangles.Add(offset + vtc + n);
                triangles.Add(offset + vtc + nn);
                triangles.Add(offset + vtc + edgesExtra + n);
                // Second triangle
                triangles.Add(offset + vtc + nn);
                triangles.Add(offset + vtc + edgesExtra + nn);
                triangles.Add(offset + vtc + edgesExtra + n);

            }

        }

        if (ClosedSides) {
            // Adding extra vertices copying existing
            int vCount = vertices.Count;

            // First side
            for (int i = 0; i < Edges; i++) {
                vertices.Add(vertices[i]);
                normals.Add(Vector3.up);
                uv0.Add(new Vector4(0, 0, 0, 0));
                uv1.Add(new Vector2(0, 0));
            }

            // Second side
            for (int i = 0; i < Edges; i++) {
                vertices.Add(vertices[vCount - Edges + i]);
                normals.Add(Vector3.up);
                uv0.Add(new Vector4(0, 0, 0, 0));
                uv1.Add(new Vector2(0, 0));
            }

            // Adding extra tris
            CoverHole(triangles, Edges, offset + vertices.Count - Edges * 2, false);
            CoverHole(triangles, Edges, offset + vertices.Count - Edges, true);
        }

        Vertices = vertices.ToArray();
        Normals = normals.ToArray();
        Triangles = triangles.ToArray();
        UV0 = uv0.ToArray();
        UV1 = uv1.ToArray();

    }

    // Covers convex hole in geometry with triangles
    private void CoverHole(List<int> trisList, int verticesCount, int verticesOffset, bool reverse) {
        if (verticesCount < 3) return;
        for (int i = 0; i < verticesCount - 2; i++) {
            trisList.Add(verticesOffset);
            trisList.Add(verticesOffset + i + (reverse ? 1 : 2));
            trisList.Add(verticesOffset + i + (reverse ? 2 : 1));
        }
    }

    public void Recalculate() {
        Recalculate(0);
    }

}