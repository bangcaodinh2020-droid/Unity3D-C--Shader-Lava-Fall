using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class Extruder : MonoBehaviour
{
    public float height = 0.5f;
    // Start is called before the first frame update
    void Start()
    {
         Mesh mesh = GetComponent<MeshFilter>().mesh;

        Vector3[] vertices = mesh.vertices;
        Vector3[] normals = mesh.normals;

        for (int i = 0; i < vertices.Length; i++)
        {
            vertices[i] += normals[i] * height;
        }

        mesh.vertices = vertices;
        mesh.RecalculateBounds();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}

//using UnityEngine;

// [RequireComponent(typeof(MeshFilter))]
// public class ExtrudeMesh : MonoBehaviour
// {
//     public float height = 0.5f;

//     void Start()
//     {
       
//     }
// }
