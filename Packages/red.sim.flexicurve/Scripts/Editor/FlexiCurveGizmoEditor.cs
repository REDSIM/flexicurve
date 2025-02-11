using System;
using System.Linq;
using System.Reflection;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using Random = UnityEngine.Random;

namespace Flexicurve {

    [CustomEditor(typeof(FlexiCurve))]
    public class FlexiCurveGizmoEditor : Editor {

        const float _pointInteractableRadius = 72;
        const float _sagInteractableRadius = 24;

        private int _pointGizmoID = 0;
        private int _sagGizmoID = 0;
        private bool _isGrab = false;
        private bool _isCtrlPressed = false;

# region Used for AutoGenerate

        private string[] _tags;

        private void DrawAutoGenerate(FlexiCurve garland) {

            EditorGUILayout.Space(5f);

            EditorGUILayout.BeginHorizontal();

            _tags = UnityEditorInternal.InternalEditorUtility.tags;

            string[] tags2 = new string[_tags.Length + 1];
            tags2[0] = "Everything";
            for (int i = 1; i < tags2.Length; i++) {
                tags2[i] = $"Use Tag: {_tags[i - 1]}";
            }

            EditorGUILayout.LabelField("Parent: ", GUILayout.Width(45));
            garland._editorSelectedParentTransform = (Transform)EditorGUILayout.ObjectField(garland._editorSelectedParentTransform, typeof(Transform), true);
            garland._editorCurtag = Mathf.Clamp(garland._editorCurtag, 0, tags2.Length);
            garland._editorCurtag = EditorGUILayout.Popup(garland._editorCurtag, tags2);

            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Space(0.1f);

            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Sag Min: ", GUILayout.Width(55));
            garland._editorSagMin = EditorGUILayout.FloatField(garland._editorSagMin, GUILayout.Width(50));
            EditorGUILayout.Space(0.01f);
            EditorGUILayout.LabelField("Max: ", GUILayout.Width(30));
            garland._editorSagMax = EditorGUILayout.FloatField(garland._editorSagMax, GUILayout.Width(50));
            EditorGUILayout.Space(0.01f);
            if (GUILayout.Button("Generate")) AutoGenerate(garland);

            GUILayout.EndHorizontal();

        }

        private void AutoGenerate(FlexiCurve garland) {

            Undo.RecordObject(garland, $"Auto Generate Points");
            Transform[] tempPointArray = garland._editorSelectedParentTransform.GetComponentsInChildren<Transform>();
            if (garland._editorCurtag == 0) {
                garland.Points = new Vector3[tempPointArray.Length];
                for (int i = 0; i < garland.Points.Length; i++) {
                    garland.Points[i] = garland.transform.InverseTransformPoint(tempPointArray[i].position);
                }
            } else {
                garland.Points = new Vector3[0];
                for (int i = 0; i < tempPointArray.Length; i++) {
                    if (tempPointArray[i].CompareTag(_tags[garland._editorCurtag - 1])) {
                        Array.Resize(ref garland.Points, garland.Points.Length + 1);
                        garland.Points[garland.Points.Length - 1] = garland.transform.InverseTransformPoint(tempPointArray[i].position);
                    }
                }
            }

            garland.Sags = new float[garland.Points.Length];
            for (int i = 0; i < garland.Sags.Length; i++) {
                garland.Sags[i] = Random.Range(garland._editorSagMin, garland._editorSagMax);
            }

            garland.Filter.sharedMesh = new Mesh();
            garland.Filter.sharedMesh.name = $"FlexiCurve_{Random.Range(int.MinValue, int.MaxValue)}";
            garland.OnValidate();
            PrefabUtility.RecordPrefabInstancePropertyModifications(garland);
        }

#endregion

        public override void OnInspectorGUI() {

            serializedObject.Update();

            FlexiCurve garland = (FlexiCurve)target;

            DrawAutoGenerate(garland);

            string polyCount = "none";

            if (garland.Filter != null && garland.Filter.sharedMesh != null) {
                polyCount = "" + (garland.Filter.sharedMesh.triangles.Length / 3);
            }
            
            EditorGUILayout.Space(10f);

            EditorGUILayout.HelpBox($" Generated mesh poly-count: {polyCount}", MessageType.Info);

            // Works just like base.OnInspectorGUI(); but excluding m_Script field
            DrawPropertiesExcluding(serializedObject, "m_Script");

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

            serializedObject.ApplyModifiedProperties();

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
            if (_pointGizmoID >= garland.Points.Length) _pointGizmoID = garland.Points.Length - 1;

            // Checking is Ctrl button is pressed
            if (Event.current.type == EventType.KeyDown && Event.current.keyCode == KeyCode.LeftControl && !_isGrab) {
                _isCtrlPressed = true;
            } else if (Event.current.type == EventType.KeyUp && Event.current.keyCode == KeyCode.LeftControl) {
                _isCtrlPressed = false;
            }

            // Getting editor UI scale
            Type utilityType = typeof(GUIUtility);
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
                    Vector2 gizmoPos = HandleUtility.WorldToGUIPoint( garland.transform.TransformPoint((garland.WireSegments[i].Curve.P1 + garland.WireSegments[i].Curve.P2) / 2));
                    float dist = Vector2.Distance(gizmoPos, pointerPos);
                    if (dist < closestDistance) {
                        closestDistance = dist;
                        _sagGizmoID = i; // Saving gizmo id to grab it in future
                        isHoverSagGizmo = true;
                    }
                }
            }

            // Start grabbing gizmo or stop grabbing
            if (isHoverPointGizmo && Event.current.type == EventType.MouseDown && Event.current.button == 0) {
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
                    Vector3 newSagGizmoPos = Handles.FreeMoveHandle(oldSagGizmoPos, circleGizmoSize, Vector3.up * 0.25f, Handles.CircleHandleCap);

                    if (EditorGUI.EndChangeCheck()) {
                        Undo.RecordObject(garland, "Changing FlexiCurve Sag");
                        garland.Sags[i] += newSagGizmoPos.y - oldSagGizmoPos.y;
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

                } else if (isHoverPointGizmo && !isHoverSagGizmo && _isCtrlPressed && i == _pointGizmoID) {

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
                        if (_pointGizmoID > 0) sags.RemoveAt(_pointGizmoID - 1);

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
                if (hitobj != null) {
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
}