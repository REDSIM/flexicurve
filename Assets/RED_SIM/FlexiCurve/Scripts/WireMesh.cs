using UnityEngine;

public class WireMesh : BezierMesh {

    private Vector3 _a = Vector3.zero;
    public Vector3 A {
        get {
            return _a;
        }
        set {
            Curve = Utils.BezierWire(value, B, Sag);
            _a = value;
        }
    }

    private Vector3 _b = Vector3.right;
    public Vector3 B {
        get {
            return _b;
        }
        set {
            Curve = Utils.BezierWire(A, value, Sag);
            _b = value;
        }
    }

    private float _sag = -1f;
    public float Sag {
        get {
            return _sag;
        }
        set {
            Curve = Utils.BezierWire(A, B, value);
            _sag = value;
        }
    }

    public WireMesh() {
    }

    public WireMesh(Vector3 a, Vector3 b, float sag, float radius, float spacing, int edges, float decimation, bool closedSides) {
        Curve = Utils.BezierWire(a, b, sag); Radius = radius; Edges = edges; Spacing = spacing; ClosedSides = closedSides; Decimation = decimation;
    }

    public void SetWireShape(Vector3 a, Vector3 b, float sag) {
        _a = a;
        _b = b;
        _sag = sag;
        Curve = Utils.BezierWire(a, b, sag);
    }

}