using System.Linq;
using System.Reflection;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(FlexiCurve))]
public class FlexiCurveGizmoEditor : Editor {

    const float _pointInteractableRadius = 72;
    const float _sagInteractableRadius = 24;

    private int _pointGizmoID = 0;
    private int _sagGizmoID = 0;
    private bool _isGrab = false;
    private bool _isCtrlPressed = false;

    public override void OnInspectorGUI() {
        base.OnInspectorGUI();

        FlexiCurve garland = (FlexiCurve)target;

        if (garland.GetInstanceID() != garland.LastInstanceID) {
            // The instance ID changed, duplication or other change
            garland.LastInstanceID = garland.GetInstanceID();
            garland.Filter.sharedMesh = null;
        }

        // Initializing
        if (garland.Filter == null) garland.TryGetComponent(out garland.Filter);
        if (garland.Renderer == null) garland.TryGetComponent(out garland.Renderer);

        if (garland.Filter != null && garland.Filter.sharedMesh == null) {
            garland.Filter.sharedMesh = new Mesh();
            garland.Filter.sharedMesh.name = $"FlexiCurve_{Random.Range(int.MinValue, int.MaxValue)}";
            garland.OnValidate();
        }
        
    }

    private void OnSceneGUI() {

        FlexiCurve garland = (FlexiCurve)target;

        if (garland.LastInstanceID == 0) garland.LastInstanceID = target.GetInstanceID();

        if (garland.IsValidated && EditorApplication.timeSinceStartup - garland.LastTimeValidated > 1f) {
            garland.IsValidated = false;
            garland.SaveMesh();
        }

        HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));

        // Limiting _gizmoID just in case 
        if (_pointGizmoID >= garland.Points.Length) {
            _pointGizmoID = garland.Points.Length - 1;
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
        Vector3 camPos = SceneView.currentDrawingSceneView.camera.transform.position;
        bool isHoverPointGizmo = false;
        bool isHoverSagGizmo = false;

        if (garland == null) return;

        // If grabbing already, then search the closest gizmo to the pointer
        if (!_isGrab) {
            float closestDistance = _pointInteractableRadius * pixelsPerPoint;

            // Iterating points
            for (int i = 0; i < garland.Points.Length; i++) {
                Vector2 gizmoPos = HandleUtility.WorldToGUIPoint(garland.transform.TransformPoint(garland.Points[i]));
                float dist = Vector2.Distance(gizmoPos, pointerPos);
                if (dist < closestDistance) {
                    closestDistance = dist;
                    _pointGizmoID = i; // Saving gizmo id to grab it in future
                    isHoverPointGizmo = true;
                }
            }

            // Limiting closest distance for sag gizmos
            closestDistance = Mathf.Min(closestDistance, _sagInteractableRadius * pixelsPerPoint);

            // Iterating sags
            for (int i = 0; i < garland.Sags.Length; i++) {
                Vector2 gizmoPos = HandleUtility.WorldToGUIPoint(garland.transform.TransformPoint((garland.WireSegments[i].Curve.P1 + garland.WireSegments[i].Curve.P2) / 2));
                float dist = Vector2.Distance(gizmoPos, pointerPos);
                if (dist < closestDistance) {
                    closestDistance = dist;
                    _sagGizmoID = i; // Saving gizmo id to grab it in future
                    isHoverSagGizmo = true;
                }
            }
        }

        // Start grabbing gizmo or stop grabbing
        if (isHoverPointGizmo && Event.current.type == EventType.MouseDown && Event.current.button == 0){
            _isGrab = true;
        } else if (Event.current.type == EventType.MouseUp && Event.current.button == 0) {
            _isGrab = false;
        }

        // Drawing cursor
        if (_isCtrlPressed) {
            if (!isHoverSagGizmo && isHoverPointGizmo) {
                EditorGUIUtility.AddCursorRect(SceneView.lastActiveSceneView.camera.pixelRect, MouseCursor.ArrowMinus);
            } else {
                EditorGUIUtility.AddCursorRect(SceneView.lastActiveSceneView.camera.pixelRect, MouseCursor.ArrowPlus);
            }
        }

        // Sag handles
        for (int i = 0; i < garland.Sags.Length; i++) {
            EditorGUI.BeginChangeCheck();

            Vector3 oldSagGizmoPos = garland.transform.TransformPoint((garland.WireSegments[i].Curve.P1 + garland.WireSegments[i].Curve.P2) / 2);

            if (!_isCtrlPressed || !isHoverSagGizmo || _sagGizmoID != i) {

                // If we not hovering a sag gizmo with ctrl button pressed
#pragma warning disable CS0618 // Type or member is obsolete
                Vector3 newSagGizmoPos = Handles.FreeMoveHandle(oldSagGizmoPos, Quaternion.identity, circleGizmoSize, Vector3.up * 0.25f, Handles.CircleHandleCap);
#pragma warning restore CS0618 // Type or member is obsolete
                if (EditorGUI.EndChangeCheck()) {
                    Undo.RecordObject(garland, "Changing FlexiCurve Sag");
                    garland.Sags[i] += (newSagGizmoPos.y - oldSagGizmoPos.y) * 1f;
                    garland.OnValidate();
                }

            } else {

                // If we hovering a sag gizmo with ctrl button pressed
                Quaternion rot = Quaternion.FromToRotation(Vector3.forward, camPos - oldSagGizmoPos);
                Handles.color = Color.yellow;
                Handles.CircleHandleCap(0, oldSagGizmoPos, rot, circleGizmoSize, EventType.Repaint);
                Handles.color = Color.white;

                if (Event.current.type == EventType.MouseDown && Event.current.button == 0) {
                    // If we clicked on sag gizmo with ctrl button pressed
                    if (isHoverSagGizmo) {
                        // Recording Undo
                        Undo.RecordObject(garland, "Adding FlexiCurve Point");

                        // Initializing arrays
                        List<Vector3> points = new List<Vector3>(garland.Points);
                        List<float> sags = new List<float>(garland.Sags);

                        // Editing arrays
                        points.Insert(i + 1, (points[i] + points[i + 1]) / 2);
                        sags.Insert(i, sags[i]);

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

        // Actual gizmo movement
        if ((isHoverPointGizmo || _isGrab) && !_isCtrlPressed) {
            EditorGUI.BeginChangeCheck();
            Vector3 newPos = Handles.DoPositionHandle(garland.transform.TransformPoint(garland.Points[_pointGizmoID]), Quaternion.identity);
            if (EditorGUI.EndChangeCheck()) {
                Undo.RecordObject(garland, "Moving FlexiCurve Point");
                garland.Points[_pointGizmoID] = garland.transform.InverseTransformPoint(newPos);
                garland.OnValidate();
            }
        }
        
        for (int i = 0; i < garland.Points.Length; i++) {
            if (isHoverSagGizmo || !isHoverPointGizmo || i != _pointGizmoID) {

                // Draw regular handles
                Quaternion rot = Quaternion.FromToRotation(Vector3.forward, camPos - garland.transform.TransformPoint(garland.Points[i]));
                Handles.color = Color.white;
                Handles.CircleHandleCap(0, garland.transform.TransformPoint(garland.Points[i]), rot, circleGizmoSize, EventType.Repaint);

            } else if(isHoverPointGizmo && !isHoverSagGizmo && _isCtrlPressed && i == _pointGizmoID) {

                // Should draw red delete circle
                Quaternion rot = Quaternion.FromToRotation(Vector3.forward, camPos - garland.transform.TransformPoint(garland.Points[i]));
                Handles.color = Color.red;
                Handles.CircleHandleCap(0, garland.transform.TransformPoint(garland.Points[i]), rot, circleGizmoSize, EventType.Repaint);

                // Delete
                if (Event.current.type == EventType.MouseDown && Event.current.button == 0 && garland.Points.Length > 2) {

                    // Recording Undo
                    Undo.RecordObject(garland, "Removing FlexiCurve Point");

                    // Initializing arrays
                    List<Vector3> points = new List<Vector3>(garland.Points);
                    List<float> sags = new List<float>(garland.Sags);
                    
                    // Editing arrays
                    points.RemoveAt(_pointGizmoID);
                    if(_pointGizmoID > 0) sags.RemoveAt(_pointGizmoID - 1);
                    
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
        if (!isHoverPointGizmo && !isHoverSagGizmo && _isCtrlPressed) {
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