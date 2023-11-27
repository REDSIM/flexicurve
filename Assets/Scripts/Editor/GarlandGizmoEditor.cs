using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(Garland))]
public class GarlandGizmoEditor : Editor {

    const float _interactableRadius = 72;

    private int _gizmoID = 0;
    private bool _isGrab = false;

    private void OnSceneGUI() {

        // Getting editor UI scale
        System.Type utilityType = typeof(GUIUtility);
        PropertyInfo[] allProps = utilityType.GetProperties(BindingFlags.Static | BindingFlags.NonPublic);
        PropertyInfo property = allProps.First(m => m.Name == "pixelsPerPoint");
        float pixelsPerPoint = (float)property.GetValue(null);
        Garland garland = (Garland)target;
        var pointerPos = Event.current.mousePosition;
        float circleGizmoSize = Mathf.Max(garland.Radius, 0.04f) * garland.transform.lossyScale.x;
        bool isInRange = false;

        if (garland == null) return;

        // If grabbing already, then search the closest gizmo to the pointer
        if (!_isGrab) {
            float closestDistance = _interactableRadius * pixelsPerPoint;
            for (int i = 0; i < garland.Points.Length; i++) {
                Vector2 gizmoPos = HandleUtility.WorldToGUIPoint(garland.transform.TransformPoint(garland.Points[i]));
                float dist = Vector2.Distance(gizmoPos, pointerPos);
                if (dist < closestDistance) {
                    closestDistance = dist;
                    _gizmoID = i; // Saving gizmo id to grab it in future
                    isInRange = true;
                }
            }
        }

        // Start grabbing gizmo or stop grabbing
        if (isInRange && Event.current.type == EventType.MouseDown && Event.current.button == 0){
            _isGrab = true;
        } else if (Event.current.type == EventType.MouseUp && Event.current.button == 0) {
            _isGrab = false;
        }

        // Sag handles
        for (int i = 0; i < garland.Sags.Length; i++) {
            EditorGUI.BeginChangeCheck();

            Vector3 oldSagGizmoPos = garland.transform.TransformPoint((garland.WireSegments[i].Curve.P1 + garland.WireSegments[i].Curve.P2)/2);
            Vector3 newSagGizmoPos = Handles.FreeMoveHandle(oldSagGizmoPos, Quaternion.identity, circleGizmoSize, Vector3.up * 1.1f, Handles.CircleHandleCap);

            if (EditorGUI.EndChangeCheck()) {
                Undo.RecordObject(garland, "Change Garland Sag");
                garland.Sags[i] += (newSagGizmoPos.y - oldSagGizmoPos.y) * 1f;
                garland.OnValidate();
            }
        }

        // Actual gizmo movement
        if (isInRange || _isGrab) {
            EditorGUI.BeginChangeCheck();
            Vector3 newPos = Handles.DoPositionHandle(garland.transform.TransformPoint(garland.Points[_gizmoID]), Quaternion.identity);
            if (EditorGUI.EndChangeCheck()) {
                Undo.RecordObject(garland, "Move Garland Point");
                garland.Points[_gizmoID] = garland.transform.InverseTransformPoint(newPos);
                garland.OnValidate();
            }
        }
        Vector3 camPos = SceneView.currentDrawingSceneView.camera.transform.position;
        for (int i = 0; i < garland.Points.Length; i++) {
            if (!isInRange || i != _gizmoID) {
                Quaternion rot = Quaternion.FromToRotation(Vector3.forward, camPos - garland.transform.TransformPoint(garland.Points[i]));
                Handles.CircleHandleCap(0, garland.transform.TransformPoint(garland.Points[i]), rot, circleGizmoSize, EventType.Repaint);
            }
        }
    }
}