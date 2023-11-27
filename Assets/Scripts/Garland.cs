using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class Garland : MonoBehaviour {

    
    [Min(0.01f)] public float Spacing = 1.0f;
    [Min(0.001f)] public float Radius = 0.01f;
    [Min(3)] public int Edges = 5;
    [Range(0, 1)] public float Decimatation = 1;
    [Range(0, 0.9f)] public float LightmapPadding = 0.1f;
    public Vector3[] Points;
    public float[] Sags;
    public Mesh Lamp;
    public float LampScale = 0.1f;
    [Min(0.01f)] public float LampSpacing = 0.1f;
    public int Seed;
    public bool RandomizeRotation = true;
    [Range(0,1f)]public float DirectionRandomization = 0;

    public WireMesh[] WireSegments {
        get {
            if (_wireSegments == null) OnValidate();
            return _wireSegments;
        }
    }
    private WireMesh[] _wireSegments;

    public bool ShowVerticesIds;
    public bool ShowTrianglesIds;

    private MeshFilter _filter;

    private List<Vector3> _vertices = new List<Vector3>();
    private List<Vector3> _normals = new List<Vector3>();
    private List<int> _triangles = new List<int>();
    private List<Vector4> _uv0 = new List<Vector4>();
    private List<Vector2> _uv1 = new List<Vector2>();

    private int _seed;

    private double _lastTimeValidated = 0;
    private bool _validated = false;

    private float _decimate => Mathf.LerpUnclamped(0f, 0.01f, Decimatation); // Actual decimation level

    public void OnValidate() {

        if (_filter == null) return;
        _lastTimeValidated = EditorApplication.timeSinceStartup;
        _validated = true;

        if (Spacing < 0.01f) Spacing = 0.01f;
        if (LampSpacing < 0.01f) LampSpacing = 0.01f;
        if (Edges < 3) Edges = 3;
        if (Radius < 0.001f) Radius = 0.001f;

        if (Points.Length < 2) return;

        _vertices.Clear();
        _normals.Clear();
        _uv0.Clear();
        _uv1.Clear();
        _triangles.Clear();

        int offset = 0;

        // Sags array must be Points.length - 1 size
        if (Sags.Length != Points.Length - 1) { // If Points array changed size
            var newSags = new float[Points.Length - 1]; // Creating new sags array
            for (int i = 0; i < Points.Length - 1; i++) { 
                if (i < Sags.Length) newSags[i] = Sags[i]; // Iterating through old sags array and copuing it to new one
                else if(Sags.Length != 0) newSags[i] = Sags[Sags.Length - 1]; // Filling new values with the last old value
                else newSags[i] = -1; // Filling array with default value
            }
            Sags = newSags;
        }

        // Segments to draw
        _wireSegments = new WireMesh[Sags.Length];

        // Defining variables before multiple loops
        float lampAngle = 0; // Random agle of the lamp
        float lampAngleNew = 0; // Random agle of the lamp, but a value to compare with
        Quaternion lampWireRot; // Rotation to rotate a lamp around wire
        Vector3 wireDir; // Direction the wire facing to
        Quaternion lampAxisRot; // Rotation to rotate a lamp around it's vertical axis
        Vector3 wireTangent; // Points right
        Vector3 wireNormal; // Points down

        List<Vector3>[] lampPoints = new List<Vector3>[_wireSegments.Length]; // Array of lists of lamp points. Each list for each wire segment
        int lampsCount = 0; // Actual lamps count

        // Creating wires
        for (int i = 0; i < _wireSegments.Length; i++) {

            // Recreating wire segment
            _wireSegments[i] = new WireMesh(Points[i], Points[i + 1], Sags[i], Radius, Spacing, Edges, _decimate, true);
            _wireSegments[i].Recalculate(offset);

            // Creating wires
            _vertices.AddRange(_wireSegments[i].Vertices);
            _normals.AddRange(_wireSegments[i].Normals);
            _triangles.AddRange(_wireSegments[i].Triangles);
            _uv0.AddRange(_wireSegments[i].UV0);

            // Adding lamp points
            if (Lamp != null) {
                lampPoints[i] = new List<Vector3>();
                lampPoints[i].AddRange(_wireSegments[i].Curve.GetUniformPointArray(LampSpacing));
                if(lampPoints[i].Count > 2) lampsCount += lampPoints[i].Count - 2;
            }

            offset = _vertices.Count;

        }

        // Calculated data required for generating lightmap UVs
        int uvIslandsCount = lampsCount + _wireSegments.Length; // Lightmap UV will consist of this square tiles count
        int uvSideSize = (int)Mathf.Ceil(Mathf.Sqrt(uvIslandsCount)); // Lightmap UV is always consists of squars. This is the squares count of a one side of uv

        // Generating lightmap uv for wire segments
        for (int i = 0; i < _wireSegments.Length; i++) {
            for(int u = 0; u < _wireSegments[i].UV1.Length; u++) {
                Vector2 shift = new Vector2(((float) i % uvSideSize + LightmapPadding / 2) / uvSideSize, (Mathf.Floor((float) i / uvSideSize) + LightmapPadding / 2) / uvSideSize);
                _uv1.Add(shift + _wireSegments[i].UV1[u] * (1 - LightmapPadding) / uvSideSize);
            }
        }

        // Current lamp id we are working with
        int lampId = 0;

        // Scattering lamps
        for (int i = 0; i < lampPoints.Length; i++) {

            lampAngle = 0; // Reset old lamp angle for every wire segment
            int count = lampPoints[i].Count - 1;

            // Individual lamps
            for (int l = 1; l < count; l++) {

                _seed = Seed + i * 5000 + l * 50; // Shift seed for every wire segment and lamp
                wireDir = Vector3.Normalize(lampPoints[i][l + 1] - lampPoints[i][l - 1]); // Direction, the wire is going to

                // Calculated wire directions
                wireTangent = Vector3.Cross(Vector3.up, wireDir).normalized;
                wireNormal = Vector3.Cross(wireTangent, wireDir).normalized;
                lampWireRot = Quaternion.AngleAxis(Vector3.SignedAngle(Vector3.down, wireNormal, wireTangent), wireTangent);

                // Lamp axis rotation 
                lampAxisRot = RandomizeRotation ? Quaternion.AngleAxis(Utils.RandomAngle(_seed), Vector3.up) : Quaternion.FromToRotation(Vector3.right, new Vector3(wireDir.x, 0, wireDir.z).normalized);

                // Lamp wire rotation based on selective pseudo random
                if (DirectionRandomization > 0) {
                    do { lampAngleNew = Utils.RandomAngle(_seed + 1); _seed++; }
                    while (Mathf.DeltaAngle(lampAngle, lampAngleNew) < 90f); // If alsost the same angle as before, rerandom
                    lampAngle = lampAngleNew;
                    lampWireRot = Quaternion.Slerp(lampWireRot, Quaternion.AngleAxis(lampAngleNew, wireDir) * lampWireRot, DirectionRandomization);
                }

                // Lightmap UV shift
                Vector2 shift = new Vector2((float)((float)(lampId + _wireSegments.Length) % uvSideSize + LightmapPadding / 2) / uvSideSize, (float)(Mathf.Floor((float)(lampId + _wireSegments.Length) / uvSideSize) + LightmapPadding / 2) / uvSideSize);

                // Generating Vertices and UV
                for (int v = 0; v < Lamp.vertexCount; v++) {

                    // Vertices
                    _vertices.Add((lampWireRot * (lampAxisRot * Lamp.vertices[v])) * LampScale + lampPoints[i][l]);

                    // Normals
                    _normals.Add(lampWireRot * (lampAxisRot * Lamp.normals[v]));

                    // Regular UV
                    if (Lamp.uv.Length > 0) {
                        float glowShift = lampsCount == 0 ? 0 : (lampId + 0.5f) / lampsCount; // Offsetting uv to make lamps glow one after another
                        _uv0.Add(new Vector4(Lamp.uv[v].x, Lamp.uv[v].y, glowShift, glowShift));
                    } else {
                        _uv0.Add(Vector4.zero);
                    }

                    // Lightmap UV
                    if (Lamp.uv2.Length > 0) _uv1.Add(shift + Lamp.uv2[v] * (1 - LightmapPadding) / uvSideSize);
                    else _uv1.Add(shift);

                }

                // Triangles
                for (int t = 0; t < Lamp.triangles.Length; t++) {
                    _triangles.Add(Lamp.triangles[t] + offset);
                }

                lampId++; // Now incrementing the current lamp id

                offset = _vertices.Count;

            }

        }

        _filter.sharedMesh.Clear();
        _filter.sharedMesh.vertices = _vertices.ToArray();
        _filter.sharedMesh.triangles = _triangles.ToArray();
        _filter.sharedMesh.normals = _normals.ToArray();
        _filter.sharedMesh.SetUVs(0, _uv0.ToArray());
        _filter.sharedMesh.SetUVs(1, _uv1.ToArray());
        _filter.sharedMesh.RecalculateBounds();

    }

    private void OnDrawGizmos() {

        if (_filter == null) TryGetComponent(out _filter);

        if (_filter != null && _filter.sharedMesh == null) {
            _filter.sharedMesh = new Mesh();
            _filter.sharedMesh.name = $"Garland_{Random.Range(int.MinValue, int.MaxValue)}";
            OnValidate();
        }

        if (_validated && EditorApplication.timeSinceStartup - _lastTimeValidated > 1f) {
            _validated = false;
            SaveMesh();
        }

        if (ShowVerticesIds) {
            GUI.color = Color.white;
            for (int i = 0; i < _vertices.Count; i++) {
                UnityEditor.Handles.Label(_vertices[i], "" + i);
            }
        }

        if (ShowTrianglesIds) {
            GUI.color = Color.black;
            for (int i = 0; i < _triangles.Count; i += 3) {
                UnityEditor.Handles.Label((_vertices[_triangles[i]] + _vertices[_triangles[i + 1]] + _vertices[_triangles[i + 2]]) / 3, "" + i / 3);
            }
        }

    }

    public void SaveMesh() {
        if (_filter == null || _filter.sharedMesh == null) return;

        Mesh mesh = _filter.sharedMesh;

        string path = $"Assets/Garlands/{mesh.name}.asset";

        // Check if the folder exists, if not, create it
        if (!Directory.Exists(Path.GetDirectoryName(path))) {
            Directory.CreateDirectory(Path.GetDirectoryName(path));
        }

        // Check if the asset already exists
        if (!File.Exists(path)) AssetDatabase.CreateAsset(mesh, path);

        // Save the mesh asset
        AssetDatabase.SaveAssets();

    }

}
