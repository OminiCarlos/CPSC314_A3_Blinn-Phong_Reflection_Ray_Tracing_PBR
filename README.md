I made this project for my CPSC 314 (Computer Graphics) course at UBC. It demonstrates my understanding of fundamental and advanced shading techniques using **Three.js** and **WebGL ES 3.0**. The project is divided into several scenes, each highlighting a core graphics technique or algorithm.

Environment:

* Three.js (JavaScript library for 3D rendering)
* WebGL ES 3.0
* Shaders written in GLSL

Scenes & Features:

1. **Scene 1: Blinn-Phong Reflection**

   * Implemented a fragment shader based on the Blinn-Phong reflection model.
   * Lighting is computed per-fragment using interpolated normals and positions from the vertex shader.
   * Demonstrates diffuse and specular shading, applied to a 3D snowman.

2. **Scene 2: Ray Marching with SDFs**

   * Used ray marching to render a procedurally defined snowman using Signed Distance Functions (SDFs).
   * Employed smooth union and hard union operations to blend primitive shapes (spheres, cylinders, cones).
   * Simulates global lighting effects with ambient occlusion and soft shadows.
   * Fully implemented in the fragment shader, demonstrating how to compute ray-surface intersections without explicit geometry.

3. **Scene 3: Physically Based Rendering (PBR)**

   * Used Three.js's `MeshStandardMaterial` for PBR rendering.
   * Applied multiple texture maps (albedo, roughness, metalness, normal) to a sci-fi helmet model.
   * Simulates realistic material properties like metallic shine and surface roughness.

4. **Scene 4: Feature Extension**

   * The helmet model in the PBR scene is animated to move forward along the z-axis, creating a looping motion through space.
   * Additionally, I created a **neon flicker effect** on the helmet’s emissive material by dynamically adjusting `emissiveIntensity` with a sine-based flicker and random dropouts, simulating faulty neon lighting.
   * These features demonstrate use of **procedural animation**, **time-based effects**, and dynamic **material property manipulation** in real-time using **clipping space concepts** and Three.js shaders.
    

Instructions:

* Open `A3.html` in a browser via a local server (e.g., VSCode Live Server).
* Use number keys `1`, `2`, `3` to switch between the main scenes.
* Additional extension in `part2/`; follow the same launch steps.

Controls:

* Use mouse to orbit the scene (Three.js OrbitControls).
* Use keys `1`, `2`, `3` to toggle scenes.


You can see a video demo here:
[![Watch the video](https://github.com/OminiCarlos/CPSC314_A3_Blinn-Phong_Reflection_Ray_Tracing_PBR/blob/master/A3_Demo-Cover.jpg)](https://www.youtube.com/watch?v=RdYNH5DE-g4)

