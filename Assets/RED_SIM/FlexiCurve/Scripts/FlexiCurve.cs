using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class FlexiCurve : MonoBehaviour {

    [Header("Preset Template")]
    [Tooltip("Preset is used to auto setup parameters of FlexiCurve. Changing parameters will not change them in the preset itself.")]
    public FlexiCurvePreset CurvePreset;

    [Header("Curve Mesh")]
    public bool GenerateWires = true;
    [Min(0.05f)] public float Spacing = 0.1f;
    [Range(0, 1)] public float Decimatation = 0.15f;
    [Min(0.001f)] public float Radius = 0.01f;
    [Min(3)] public int Edges = 3;

    [Header("Elements Scattering")]
    public Mesh Element;
    public float ElementsScale = 1f;
    [Min(0.05f)] public float ElementsSpacing = 0.2f;
    [Range(0, 1f)] public float DirectionRandomization = 0.3f;
    public bool RandomizeRotation = true;
    public bool GeneratePerElementWires = true;
    public float ElementOffset = 0.1f;

    [Header("Other Settings")]
    [Range(0, 0.9f)] public float LightmapPadding = 0.1f;
    public int RandomSeed;

    [Header("Curve Points")]
    public Vector3[] Points;
    public float[] Sags;

    [HideInInspector]public int LastInstanceID;

    public WireMesh[] WireSegments {
        get {
#if UNITY_EDITOR
            if (_wireSegments == null) OnValidate();
#endif
            return _wireSegments;
        }
    }
    private WireMesh[] _wireSegments;

    [HideInInspector] public MeshFilter Filter;
    [HideInInspector] public MeshRenderer Renderer;

    private List<Vector3> _vertices = new List<Vector3>();
    private List<Vector3> _normals = new List<Vector3>();
    private List<int> _triangles = new List<int>();
    private List<Vector4> _uv0 = new List<Vector4>();
    private List<Vector2> _uv1 = new List<Vector2>();

    private int _seed;

    public double LastTimeValidated => _lastTimeValidated;
    private double _lastTimeValidated = 0;

    [HideInInspector] public bool IsValidated = false;

    private float _decimate => Mathf.LerpUnclamped(0f, 0.01f, Decimatation); // Actual decimation level

    [HideInInspector] public FlexiCurvePreset _curvePresetPrev = null; // Previous curve presed used, for comparison

#if UNITY_EDITOR
    public void Setup(FlexiCurvePreset preset) {

        if (preset == null) return;

        // Curve Mesh
        GenerateWires = preset.GenerateWires;
        Spacing = preset.Spacing;
        Decimatation = preset.Decimatation;
        Radius = preset.Radius;
        Edges = preset.Edges;

        // Elements Scattering
        Element = preset.Element;
        ElementsScale = preset.ElementsScale;
        ElementsSpacing = preset.ElementsSpacing;
        DirectionRandomization = preset.DirectionRandomization;
        RandomizeRotation = preset.RandomizeRotation;
        GeneratePerElementWires = preset.GeneratePerElementWires;
        ElementOffset = preset.ElementOffset;

        // Preset Template
        if (Renderer == null || preset.Material == null) return;
        Renderer.sharedMaterial = preset.Material;

    }

    public void OnValidate() {

        // Initialize
        if(!ReferenceEquals(CurvePreset, _curvePresetPrev)) {
            // Undo
            Undo.RecordObject(this, "Changing FlexiCurve Preset");
            if(CurvePreset != null && Renderer != null && CurvePreset.Material != null) Undo.RecordObject(Renderer, "Changing FlexiCurve Material");
            // Setup
            _curvePresetPrev = CurvePreset;
            Setup(CurvePreset);
        }

        if (Filter == null) return;

        _lastTimeValidated = EditorApplication.timeSinceStartup;
        IsValidated = true;

        if (Points == null || Points.Length < 2) {
            Points = new Vector3[] {
                new Vector3(0, 0, 1),
                new Vector3 (1, 0, 0)
            };
            Sags = new float[] {
                -0.25f
            };
        }

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
        float elementAngle = 0; // Random agle of the lamp
        float elementAngleNew = 0; // Random agle of the lamp, but a value to compare with
        Quaternion elementWireRot; // Rotation to rotate a lamp around wire
        Vector3 wireDir; // Direction the wire facing to
        Quaternion lampAxisRot; // Rotation to rotate a lamp around it's vertical axis
        Vector3 wireTangent; // Points right
        Vector3 wireNormal; // Points down

        List<Vector3>[] elementPoints = new List<Vector3>[_wireSegments.Length]; // Array of lists of lamp points. Each list for each wire segment
        int elementCount = 0; // Actual elements count

        // Adding lamp points
        for (int i = 0; i < _wireSegments.Length; i++) {
            _wireSegments[i] = new WireMesh(Points[i], Points[i + 1], Sags[i], Radius, Spacing, Edges, _decimate, true);
            elementPoints[i] = new List<Vector3>();
            elementPoints[i].AddRange(_wireSegments[i].Curve.GetUniformPointArray(ElementsSpacing));
            if (elementPoints[i].Count > 2) elementCount += elementPoints[i].Count - 2;
        }

        // Calculated data required for generating lightmap UVs
        int uvIslandsCount = elementCount + (GenerateWires ? _wireSegments.Length : 0); // Lightmap UV will consist of this square tiles count
        int uvSideSize = (int)Mathf.Ceil(Mathf.Sqrt(uvIslandsCount)); // Lightmap UV is always consists of squars. This is the squares count of a one side of uv

        if (GenerateWires) {

            // Creating wires
            for (int i = 0; i < _wireSegments.Length; i++) {

                // Recreating wire segment
                
                _wireSegments[i].Recalculate(offset);

                // Creating wires
                _vertices.AddRange(_wireSegments[i].Vertices);
                _normals.AddRange(_wireSegments[i].Normals);
                _triangles.AddRange(_wireSegments[i].Triangles);
                _uv0.AddRange(_wireSegments[i].UV0);

                

                offset = _vertices.Count;

            }

            // Generating lightmap uv for wire segments
            for (int i = 0; i < _wireSegments.Length; i++) {
                for(int u = 0; u < _wireSegments[i].UV1.Length; u++) {
                    Vector2 shift = new Vector2(((float) i % uvSideSize + LightmapPadding / 2) / uvSideSize, (Mathf.Floor((float) i / uvSideSize) + LightmapPadding / 2) / uvSideSize);
                    _uv1.Add(shift + _wireSegments[i].UV1[u] * (1 - LightmapPadding) / uvSideSize);
                }
            }

        }

        if (Element != null) {

            // Buffering mesh data
            var elementVertices = Element.vertices;
            var elementNormals = Element.normals;
            var elementTriangles = Element.triangles;
            var elementUV = Element.uv;
            var elementUV2 = Element.uv2;

            // Current element id we are working with
            int elementId = 0;

            // Calculating X-UV
            float holdingWireXUV = ElementOffset / (Mathf.PI * 2 * Radius);

            // Scattering elements
            for (int i = 0; i < elementPoints.Length; i++) {

                elementAngle = 0; // Reset old element angle for every wire segment
                int count = elementPoints[i].Count - 1;

                // Individual elements
                for (int l = 1; l < count; l++) {

                    _seed = RandomSeed + i * 5000 + l * 50; // Shift seed for every wire segment and element
                    wireDir = Vector3.Normalize(elementPoints[i][l + 1] - elementPoints[i][l - 1]); // Direction, the wire is going to

                    // Calculated wire directions
                    wireTangent = Vector3.Cross(Vector3.up, wireDir).normalized;
                    wireNormal = Vector3.Cross(wireTangent, wireDir).normalized;
                    elementWireRot = Quaternion.AngleAxis(Vector3.SignedAngle(Vector3.down, wireNormal, wireTangent), wireTangent);

                    // Element axis rotation 
                    lampAxisRot = RandomizeRotation ? Quaternion.AngleAxis(Utils.RandomAngle(_seed), Vector3.up) : Quaternion.FromToRotation(Vector3.right, new Vector3(wireDir.x, 0, wireDir.z).normalized);

                    // Element wire rotation based on selective pseudo random
                    if (DirectionRandomization > 0) {
                        do { elementAngleNew = Utils.RandomAngle(_seed + 1); _seed++; }
                        while (Mathf.DeltaAngle(elementAngle, elementAngleNew) < 90f); // If alsost the same angle as before, rerandom
                        elementAngle = elementAngleNew;
                        elementWireRot = Quaternion.Slerp(elementWireRot, Quaternion.AngleAxis(elementAngleNew, wireDir) * elementWireRot, DirectionRandomization);
                    }

                    // Lightmap UV shift
                    Vector2 shift = new Vector2((float)((float)(elementId + (GenerateWires ? _wireSegments.Length : 0)) % uvSideSize + LightmapPadding / 2) / uvSideSize, (float)(Mathf.Floor((float)(elementId + (GenerateWires ? _wireSegments.Length : 0)) / uvSideSize) + LightmapPadding / 2) / uvSideSize);

                    // Generating Per Element Wires and UV
                    if (GeneratePerElementWires) {

                        Vector3 from = elementPoints[i][l]; // Position wire holder goes from
                        Vector3 to = from + (elementWireRot * Vector3.down) * ElementOffset; // Position wire holder goes to
                        int edgesExtra = Edges + 1;
                        // Upper part
                        for (int v = 0; v < edgesExtra; v++) {

                            int vId = v == Edges ? 0 : v;
                            float holdingWireYUV = v == Edges ? 1 : (float)vId / Edges;
                            
                            float angle = 2 * Mathf.PI * vId / Edges;
                            Vector3 vert = Utils.PointOnCircle(from, Radius, elementWireRot * Vector3.down, elementWireRot * Vector3.right, angle);
                            _vertices.Add(vert); // Filling vertices array
                            _normals.Add((vert - from).normalized);
                            _uv0.Add(new Vector4(0, holdingWireYUV, 0, 0));
                            _uv1.Add(shift);

                            int vv = v + 1;

                            if (v < Edges) {
                                // First triangle
                                _triangles.Add(offset + v);
                                _triangles.Add(offset + vv);
                                _triangles.Add(offset + edgesExtra + v);
                                // Second triangle
                                _triangles.Add(offset + vv);
                                _triangles.Add(offset + edgesExtra + vv);
                                _triangles.Add(offset + edgesExtra + v);
                            }

                        }
                        offset = _vertices.Count;

                        // Lower part
                        for (int v = 0; v < edgesExtra; v++) {

                            int vId = v == Edges ? 0 : v;
                            float holdingWireYUV = v == Edges ? 1 : (float)vId / Edges;
                            
                            float angle = 2 * Mathf.PI * vId / Edges;
                            Vector3 vert = Utils.PointOnCircle(to, Radius, elementWireRot * Vector3.down, elementWireRot * Vector3.right, angle);
                            _vertices.Add(vert); // Filling vertices array
                            _normals.Add((vert - to).normalized);
                            _uv0.Add(new Vector4(holdingWireXUV, holdingWireYUV, 0, 0));
                            _uv1.Add(shift);
                        }
                        
                    }

                    offset = _vertices.Count;

                    // Generating Vertices and UV
                    for (int v = 0; v < Element.vertexCount; v++) {

                        // Vertices
                        _vertices.Add((elementWireRot * (lampAxisRot * elementVertices[v] * ElementsScale + new Vector3(0, -ElementOffset, 0))) + elementPoints[i][l]);

                        // Normals
                        _normals.Add(elementWireRot * (lampAxisRot * elementNormals[v]));

                        // Regular UV
                        if (elementUV.Length > 0) {
                            float glowShift = elementCount == 0 ? 0 : (elementId + 0.5f) / elementCount; // Offsetting uv to make lamps glow one after another
                            _uv0.Add(new Vector4(elementUV[v].x, elementUV[v].y, glowShift, glowShift));
                        } else {
                            _uv0.Add(Vector4.zero);
                        }

                        // Lightmap UV
                        if (elementUV2.Length > 0) _uv1.Add(shift + elementUV2[v] * (1 - LightmapPadding) / uvSideSize);
                        else _uv1.Add(shift);

                    }

                    // Triangles
                    for (int t = 0; t < elementTriangles.Length; t++) {
                        _triangles.Add(elementTriangles[t] + offset);
                    }

                    elementId++; // Now incrementing the current element id

                    offset = _vertices.Count;

                }

            }
        }

        Filter.sharedMesh.Clear();

        // Will mesh use UInt16 format, or UInt32?
        if (_vertices.Count > 65535) {
            Filter.sharedMesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
        } else {
            Filter.sharedMesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt16;
        }
        Filter.sharedMesh.vertices = _vertices.ToArray();
        Filter.sharedMesh.triangles = _triangles.ToArray();
        Filter.sharedMesh.normals = _normals.ToArray();
        Filter.sharedMesh.SetUVs(0, _uv0.ToArray());
        Filter.sharedMesh.SetUVs(1, _uv1.ToArray());
        Filter.sharedMesh.RecalculateBounds();

    }

    public void SaveMesh() {
        if (Filter == null || Filter.sharedMesh == null) return;

        Mesh mesh = Filter.sharedMesh;

        string path = $"Assets/FlexiCurveMeshes/{mesh.name}.asset";

        // Check if the folder exists, if not, create it
        if (!Directory.Exists(Path.GetDirectoryName(path))) {
            Directory.CreateDirectory(Path.GetDirectoryName(path));
        }

        // Check if the asset already exists
        if (!File.Exists(path)) AssetDatabase.CreateAsset(mesh, path);

        // Save the mesh asset
        AssetDatabase.SaveAssets();

    }
#endif

}
