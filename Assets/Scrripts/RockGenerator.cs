using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// public class RockGenerator : MonoBehaviour
// {
//     // Start is called before the first frame update
//     void Start()
//     {
        
//     }

//     // Update is called once per frame
//     void Update()
//     {
        
//     }
// }

// using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class RockGenerator : MonoBehaviour
{
    [Header("Shape")]
    public float size = 1f;
    public float noiseStrength = 0.3f;
    public float flattenY = 0.2f;

    [Header("Detail")]
    public int seed = 0;
    public float frequency = 2f;

    void Start()
    {
        GenerateRock();
    }

    void GenerateRock()
    {
        Mesh mesh = CreateBaseMesh();
        Vector3[] vertices = mesh.vertices;

        System.Random prng = new System.Random(seed);
        float offsetX = prng.Next(-1000, 1000);
        float offsetY = prng.Next(-1000, 1000);
        float offsetZ = prng.Next(-1000, 1000);

        for (int i = 0; i < vertices.Length; i++)
        {
            Vector3 v = vertices[i];

            // noise 3D
            float nx = Mathf.PerlinNoise(v.x * frequency + offsetX, v.y * frequency);
            float ny = Mathf.PerlinNoise(v.y * frequency + offsetY, v.z * frequency);
            float nz = Mathf.PerlinNoise(v.z * frequency + offsetZ, v.x * frequency);

            Vector3 noise = new Vector3(nx, ny, nz) - Vector3.one * 0.5f;

            // extrude outward
            v += noise * noiseStrength;

            // flatten đá một chút
            v.y *= 1f - flattenY;

            // scale
            v *= size;

            vertices[i] = v;
        }

        mesh.vertices = vertices;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();

        GetComponent<MeshFilter>().mesh = mesh;
    }

    Mesh CreateBaseMesh()
    {
        // dùng sphere làm base
        GameObject temp = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        Mesh mesh = temp.GetComponent<MeshFilter>().mesh;

        Destroy(temp);

        return Instantiate(mesh);
    }
}