using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
#if UNITY_EDITOR
public class SkinnedXmasLights : EditorWindow {

    [MenuItem ("Tools/XmasLights/Batch&Bake Active", false, 125)]
    public static void RunBakeActiveSkinnedWorldPos (MenuCommand command)
    {
        SkinnedMeshRenderer[] allSMR = UnityEngine.Object.FindObjectsOfType<SkinnedMeshRenderer>();
        List<SkinnedMeshRenderer> toBake = new List<SkinnedMeshRenderer>();
        foreach (SkinnedMeshRenderer smr in allSMR) {
            if (smr.sharedMaterials.Count() == 1 && smr.enabled) {
                var s = smr.sharedMaterials[0].shader;
                for (int i = 0; i < ShaderUtil.GetPropertyCount(s); i++) {
                    if (ShaderUtil.GetPropertyName(s, i).Equals("_TargetStrandLength")) {
                        toBake.Add(smr);
                        Debug.Log("Baking /" + string.Join("/", smr.gameObject.GetComponentsInParent<Transform>().Select(t => t.name).Reverse().ToArray()), smr);
                        break;
                    }
                }
            }
        }
        TrailRenderer[] allTR = UnityEngine.Object.FindObjectsOfType<TrailRenderer>();
        List<TrailRenderer> toBakeTrail = new List<TrailRenderer>();
        foreach (TrailRenderer tr in allTR) {
            if (tr.sharedMaterials.Count() == 1 && tr.enabled) {
                var s = tr.sharedMaterials[0].shader;
                for (int i = 0; i < ShaderUtil.GetPropertyCount(s); i++) {
                    if (ShaderUtil.GetPropertyName(s, i).Equals("_WireSmoothness")) {
                        toBakeTrail.Add(tr);
                        Debug.Log("Baking /" + string.Join("/", tr.gameObject.GetComponentsInParent<Transform>().Select(t => t.name).Reverse().ToArray()), tr);
                        break;
                    }
                }
            }
        }
        Mesh baked = new Mesh();
        List<Vector3> vertices = new List<Vector3>();
        List<Vector3> normals = new List<Vector3>();
        List<Vector4> tangents = new List<Vector4>();
        List<Vector3> uv = new List<Vector3>();
        List<Vector4> uv3 = new List<Vector4>();
        List<Vector3> uv4 = new List<Vector3>();
        int outVertCount = 0;
        var outSubMeshes = new Dictionary<Material, List<int>>();
        var baseVertices = new Dictionary<Material, int>();

        var outMeshGO = new GameObject();
        outMeshGO.name = "BakedXmasLights_" + DateTime.UtcNow.ToString ("s").Replace (':', '_');
        Undo.RegisterCreatedObjectUndo(outMeshGO, "Bake Xmas Lights");
        var outMeshFilter = outMeshGO.AddComponent<MeshFilter>();
        var outMeshRenderer = outMeshGO.AddComponent<MeshRenderer>();

        // TODO: Trail baking not supported until 2018.
        /*
        foreach (TrailRenderer tr in toBakeTrail) {
            if (!outSubMeshes.ContainsKey(smr.sharedMaterial)) {
                outSubMeshes[smr.sharedMaterial] = new List<int>();
                baseVertices[smr.sharedMaterial] = outVertCount;
            }
            Undo.RecordObject(smr, "Bake Xmas Lights / Disable SkinnedMeshRenderer");
            tr.BakeMesh(baked, false);
            tr.Clear();
        }
        */

        foreach (SkinnedMeshRenderer smr in toBake) {
            if (!outSubMeshes.ContainsKey(smr.sharedMaterial)) {
                outSubMeshes[smr.sharedMaterial] = new List<int>();
                baseVertices[smr.sharedMaterial] = outVertCount;
            }

            Undo.RecordObject(smr, "Bake Xmas Lights / Disable SkinnedMeshRenderer");
            smr.BakeMesh(baked);
            smr.enabled = false; // we leave the old components around.
            var localToWorld = smr.transform.localToWorldMatrix;
            float targetStrandLength = smr.sharedMaterial.GetFloat("_TargetStrandLength");
            var srcUV = new List<Vector3>();
            baked.GetUVs(0, srcUV); // zero-indexed
            var srcUV3 = new List<Vector4>();
            baked.GetUVs(2, srcUV3); // zero-indexed
            Vector3 originPoint = smr.rootBone.transform.position;
            Vector3 [] srcVertices = baked.vertices;
            Vector3 [] srcNormals = baked.normals;
            Vector4 [] srcTangents = baked.tangents;
            int[] vertMapping = new int[srcVertices.Count()];
            int dummyVert = -1;
            int baseVertex = baseVertices[smr.sharedMaterial];
            for (int i = 0; i < srcVertices.Count(); i++) {
                vertMapping[i] = -1;

                // Same logic as in shader.
                var vert = localToWorld.MultiplyPoint(srcVertices[i]);
                var normal = localToWorld.MultiplyVector(srcNormals[i]);
                var tangent = localToWorld.MultiplyVector(new Vector3(srcTangents[i].x, srcTangents[i].y, srcTangents[i].z));
                float strandLength = vert.magnitude;
                float weight = srcUV3[i].w;
                weight *= 1 > targetStrandLength / strandLength ? 1 : targetStrandLength / strandLength;
                if (weight < 1.03125 || dummyVert == -1) {
                    vertices.Add(vert); // originPoint + 
                    normals.Add(normal);
                    tangents.Add(new Vector4(tangent.x, tangent.y, tangent.z, srcTangents[i].w));
                    uv.Add(srcUV[i]);
                    uv3.Add(srcUV3[i]);
                    uv4.Add(originPoint);
                    vertMapping[i] = (outVertCount++) - baseVertex;
                    if (weight >= 1.03125) {
                        dummyVert = i;
                    }
                }
            }
            int[] indices = baked.GetIndices(0);
            List<int> outIndices = outSubMeshes[smr.sharedMaterial];
            for (int i = 0; i < indices.Count(); i+= 3) {
                int a = vertMapping[indices[i]], b = vertMapping[indices[i + 1]], c = vertMapping[indices[i + 2]];
                if ((a == -1 && b == -1) || (b == -1 && c == -1) || (a == -1 && c == -1)) {
                    continue; // degenerate triangle at end of strand.
                }
                outIndices.Add(a == -1 ? vertMapping[dummyVert] : a);
                outIndices.Add(b == -1 ? vertMapping[dummyVert] : b);
                outIndices.Add(c == -1 ? vertMapping[dummyVert] : c);
            }
        }
        baked = new Mesh();

        baked.vertices = vertices.ToArray();
        baked.normals = normals.ToArray();
        baked.tangents = tangents.ToArray();
        baked.SetUVs(0, uv);
        baked.SetUVs(2, uv3);
        baked.SetUVs(3, uv4);
        baked.subMeshCount = outSubMeshes.Count;
        Material[] newMaterialList = new Material[outSubMeshes.Count];
        int matIdx = 0;
        foreach (var val in outSubMeshes) {
            newMaterialList[matIdx] = val.Key;
            matIdx++;
            baked.SetIndices(val.Value.ToArray(), MeshTopology.Triangles, 0, true, baseVertices[val.Key]);
        }
        baked.name = "XmasLights";
        baked.RecalculateBounds();
        outMeshRenderer.sharedMaterials = newMaterialList;
        string pathToGenerated = "Assets" + "/Generated";
        if (!Directory.Exists (pathToGenerated)) {
            Directory.CreateDirectory (pathToGenerated);
        }
        string fileName = pathToGenerated + "/XmasLights_" + DateTime.UtcNow.ToString ("s").Replace (':', '_') + ".asset";
        AssetDatabase.CreateAsset (baked, fileName);
        AssetDatabase.SaveAssets ();
        outMeshFilter.sharedMesh = baked;
    }

    [MenuItem ("CONTEXT/Mesh/Import Xmas Strand", false, 125)]
    public static void ImportXmasStrandContext (MenuCommand command)
    {
        Mesh sourceMesh = command.context as Mesh;
        generateMesh(sourceMesh);
    }

    [MenuItem ("Tools/XmasLights/Import Xmas Strand [Select mesh in Assets]", true)]
    public static bool ImportXmasStrandCheck (MenuCommand command) {
        return (Selection.activeObject as Mesh) != null;
    }

    [MenuItem ("Tools/XmasLights/Import Xmas Strand [Select mesh in Assets]", false, 125)]
    public static void ImportXmasStrand (MenuCommand command)
    {
        Mesh sourceMesh = Selection.activeObject as Mesh;
        generateMesh(sourceMesh);
    }

    static void generateMesh(Mesh sourceMesh) {
        Vector3 leftPos = sourceMesh.bindposes[0].inverse.MultiplyPoint(new Vector3(0,0,0));
        Vector3 rightPos = sourceMesh.bindposes[1].inverse.MultiplyPoint(new Vector3(0,0,0));
        Mesh newMesh = new Mesh ();
        int size = sourceMesh.vertices.Length;
        Vector2[] srcUV = sourceMesh.uv;
        Vector3 [] srcVertices = sourceMesh.vertices;
        Color [] srcColors = sourceMesh.colors; // FIXME: Only uses colors.r -- should copy all colors?
        Vector3 [] srcNormals = sourceMesh.normals;
        Vector4 [] srcTangents = sourceMesh.tangents;
        Matrix4x4 [] srcBindposes = sourceMesh.bindposes;
        BoneWeight [] srcBoneWeights = sourceMesh.boneWeights;
        var newUV = new Vector4[size];
        var newUV3 = new Vector4[size];
        float droop = 1.0f;
        for (int i = 0; i < size; i++) {
            BoneWeight bw = srcBoneWeights[i];
            float weight = bw.boneIndex0 == 1 ? bw.weight0 : 1 - bw.weight0;
            Vector3 vertOffset = srcVertices[i] - Vector3.Lerp(leftPos, rightPos, weight < 0.00001f ? 0 : weight);
            newUV3 [i] = new Vector4 (vertOffset.x, vertOffset.y, vertOffset.z, weight);
            newUV[i] = new Vector4(srcUV[i].x, srcUV[i].y, srcColors[i].r, 0);
            BoneWeight newBw = new BoneWeight();
            if (weight < 0.00001f) {
                if (i % 2 == 0) {
                    srcVertices[i] = new Vector3(leftPos.x + 0.5f, leftPos.y - 0.1f, leftPos.z - droop);
                } else {
                    srcVertices[i] = new Vector3(srcVertices[i].x - 0.5f, srcVertices[i].y + 0.1f, srcVertices[i].z);
                }
                newBw.boneIndex0 = 0;
                newBw.weight0 = 1.0f;
                newBw.boneIndex1 = 1;
                newBw.weight1 = 0.0f;
            } else {
                srcVertices[i] = new Vector3(rightPos.x, rightPos.y, rightPos.z);
                newBw.boneIndex0 = 1;
                newBw.weight0 = 1.0f;
                newBw.boneIndex1 = 0;
                newBw.weight1 = 0.0f;
            }
            srcBoneWeights[i] = newBw;
        }
        newMesh.vertices = srcVertices;
        if (srcNormals != null && srcNormals.Length > 0) {
            newMesh.normals = srcNormals;
        }
        if (srcTangents != null && srcTangents.Length > 0) {
            newMesh.tangents = srcTangents;
        }
        newMesh.boneWeights = srcBoneWeights;
        newMesh.SetUVs (0, new List<Vector4>(newUV));
        newMesh.SetUVs (2, new List<Vector4>(newUV3));
        newMesh.subMeshCount = sourceMesh.subMeshCount;
        for (int i = 0; i < sourceMesh.subMeshCount; i++) {
            var curIndices = sourceMesh.GetIndices (i);
            newMesh.SetIndices (curIndices, sourceMesh.GetTopology(i), i);
        }
        newMesh.bounds = sourceMesh.bounds;
        if (srcBindposes != null && srcBindposes.Length > 0) {
            newMesh.bindposes = sourceMesh.bindposes;
        }
        newMesh.name = sourceMesh.name + "_xmasskin";
        newMesh.RecalculateBounds();
        Mesh meshAfterUpdate = newMesh;
		var dir = Path.GetDirectoryName(AssetDatabase.GetAssetPath(sourceMesh))+"/";
        string fileName = dir + "/" + newMesh.name + "_" + DateTime.UtcNow.ToString ("s").Replace (':', '_') + ".asset";
        AssetDatabase.CreateAsset (meshAfterUpdate, fileName);
        AssetDatabase.SaveAssets ();
    }
}
#endif