using System.Linq;
using System.Reflection;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(FlexiCurve))]
public class FlexiCurveGizmoEditor : Editor {

    const float _interactableRadius = 72;

    private int _gizmoID = 0;
    private bool _isGrab = false;
    private bool _isCtrlPressed = false;

    private void OnSceneGUI() {

        FlexiCurve garland = (FlexiCurve)target;

        HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));

        // Limiting _gizmoID just in case 
        if (_gizmoID >= garland.Points.Length) {
            _gizmoID = garland.Points.Length - 1;
        }

        // Checking is Ctrl button is pressed
        if (Event.current.type == EventType.KeyDown && Event.current.keyCode == KeyCode.LeftControl && !_isGrab) {
            _isCtrlPressed = true;
        } else if (Event.current.type == EventType.KeyUp && Event.current.keyCode == KeyCode.LeftControl) {
            _isCtrlPressed = false;
        }

        // Getting editor UI scale
        System.Type utilityType = typeof(GUIUtility);
        PropertyInfo[] allProps = utilityType.GetProperties(BindingFlags.Static | BindingFlags.NonPublic);
        PropertyInfo property = allProps.First(m => m.Name == "pixelsPerPoint");
        float pixelsPerPoint = (float)property.GetValue(null);
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

        // Drawing cursor
        if (_isCtrlPressed) {
            if (isInRange) {
                EditorGUIUtility.AddCursorRect(SceneView.lastActiveSceneView.camera.pixelRect, MouseCursor.ArrowMinus);
            } else {
                EditorGUIUtility.AddCursorRect(SceneView.lastActiveSceneView.camera.pixelRect, MouseCursor.ArrowPlus);
            }
        }

        // Sag handles
        if (!_isCtrlPressed) {
            for (int i = 0; i < garland.Sags.Length; i++) {
                EditorGUI.BeginChangeCheck();

                Vector3 oldSagGizmoPos = garland.transform.TransformPoint((garland.WireSegments[i].Curve.P1 + garland.WireSegments[i].Curve.P2) / 2);
#pragma warning disable CS0618 // Type or member is obsolete
                Vector3 newSagGizmoPos = Handles.FreeMoveHandle(oldSagGizmoPos, Quaternion.identity, circleGizmoSize, Vector3.up * 0.25f, Handles.CircleHandleCap);
#pragma warning restore CS0618 // Type or member is obsolete

                if (EditorGUI.EndChangeCheck()) {
                    Undo.RecordObject(garland, "Changing FlexiCurve Sag");
                    garland.Sags[i] += (newSagGizmoPos.y - oldSagGizmoPos.y) * 1f;
                    garland.OnValidate();
                }
            }
        }

        // Actual gizmo movement
        if ((isInRange || _isGrab) && !_isCtrlPressed) {
            EditorGUI.BeginChangeCheck();
            Vector3 newPos = Handles.DoPositionHandle(garland.transform.TransformPoint(garland.Points[_gizmoID]), Quaternion.identity);
            if (EditorGUI.EndChangeCheck()) {
                Undo.RecordObject(garland, "Moving FlexiCurve Point");
                garland.Points[_gizmoID] = garland.transform.InverseTransformPoint(newPos);
                garland.OnValidate();
            }
        }
        Vector3 camPos = SceneView.currentDrawingSceneView.camera.transform.position;
        for (int i = 0; i < garland.Points.Length; i++) {
            if (!isInRange || i != _gizmoID) {

                // Draw regular handles
                Quaternion rot = Quaternion.FromToRotation(Vector3.forward, camPos - garland.transform.TransformPoint(garland.Points[i]));
                Handles.color = Color.white;
                Handles.CircleHandleCap(0, garland.transform.TransformPoint(garland.Points[i]), rot, circleGizmoSize, EventType.Repaint);

            } else if(isInRange && _isCtrlPressed && i == _gizmoID && garland.Points.Length > 2) {

                // Should draw red delete circle
                Quaternion rot = Quaternion.FromToRotation(Vector3.forward, camPos - garland.transform.TransformPoint(garland.Points[i]));
                Handles.color = Color.red;
                Handles.CircleHandleCap(0, garland.transform.TransformPoint(garland.Points[i]), rot, circleGizmoSize, EventType.Repaint);

                // Delete
                if (Event.current.type == EventType.MouseDown && Event.current.button == 0) {

                    // Recording Undo
                    Undo.RecordObject(garland, "Removing FlexiCurve Point");

                    // Initializing arrays
                    List<Vector3> points = new List<Vector3>(garland.Points);
                    List<float> sags = new List<float>(garland.Sags);
                    
                    // Editing arrays
                    points.RemoveAt(_gizmoID);
                    if(_gizmoID > 0) sags.RemoveAt(_gizmoID - 1);
                    
                    // Apply points array
                    garland.Points = points.ToArray();
                    garland.Sags = sags.ToArray();
                    garland.OnValidate();
                    
                    // Supress click
                    Event.current.Use();
                }

            }
        }

        // Adding new point
        if (!isInRange && _isCtrlPressed) {
            object hitobj = HandleUtility.RaySnap(HandleUtility.GUIPointToWorldRay(Event.current.mousePosition));
            if(hitobj != null) {
                RaycastHit hit = (RaycastHit)hitobj;

                // Drawing disc
                Handles.color = Color.yellow;
                Handles.DrawWireDisc(hit.point, hit.normal, circleGizmoSize);

                if (Event.current.type == EventType.MouseDown && Event.current.button == 0) {

                    // Recording Undo
                    Undo.RecordObject(garland, "Adding FlexiCurve Point");

                    // Initializing arrays
                    List<Vector3> points = new List<Vector3>(garland.Points);
                    List<float> sags = new List<float>(garland.Sags);

                    // Editing arrays
                    points.Add(garland.transform.InverseTransformPoint(hit.point));
                    if (sags.Count > 0) sags.Add(sags[sags.Count - 1]);
                    else sags.Add(-0.1f);

                    // Apply points array
                    garland.Points = points.ToArray();
                    garland.Sags = sags.ToArray();
                    garland.OnValidate();

                    // Supress click
                    Event.current.Use();
                }

            }
            
        }

    }
}