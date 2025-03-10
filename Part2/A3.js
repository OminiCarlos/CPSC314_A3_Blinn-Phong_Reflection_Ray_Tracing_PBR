/*
 * UBC CPSC 314
 * Assignment 3 Template
 */
import {
  setup,
  createScene,
  createRayMarchingScene,
  loadAndPlaceGLB,
  loadAndPlaceOBJ
} from "./js/setup.js";
import * as THREE from "./js/three.module.js";
import { SourceLoader } from "./js/SourceLoader.js";
import { THREEx } from "./js/KeyboardState.js";

// Setup the renderer
// You should look into js/setup.js to see what exactly is done here.
const { renderer, canvas } = setup();

/////////////////////////////////
//   YOUR WORK STARTS BELOW    //
/////////////////////////////////

// Uniforms - Pass these into the appropriate vertex and fragment shader files
const spherePosition = { type: "v3", value: new THREE.Vector3(0.0, 0.0, 0.0) };

const ambientColor = { type: "c", value: new THREE.Color(0.0, 0.0, 1.0) };
const diffuseColor = { type: "c", value: new THREE.Color(0.0, 1.0, 1.0) };
const specularColor = { type: "c", value: new THREE.Color(1.0, 1.0, 1.0) };

const kAmbient = { type: "f", value: 0.3 };
const kDiffuse = { type: "f", value: 0.6 };
const kSpecular = { type: "f", value: 1.0 };
const shininess = { type: "f", value: 50.0 };
const ticks = { type: "f", value: 0.0 };
const resolution = { type: "v3", value: new THREE.Vector3() };

const yzClippingPlane = new THREE.Plane(new THREE.Vector3(1, 0, 0), 0);
const planeGeometry = new THREE.PlaneGeometry(20, 30); // Adjust size as needed
const planeMaterial = new THREE.MeshBasicMaterial({
  color: 0xff0000,
  side: THREE.DoubleSide,
  transparent: true,
  opacity: 0.5 // semi-transparent so you can see through it
});
const clippingPlaneHelper = new THREE.Mesh(planeGeometry, planeMaterial);

const sphereLight = new THREE.PointLight(0xffffff, 200);

// Shader materials
const sphereMaterial = new THREE.ShaderMaterial({
  uniforms: {
    spherePosition: spherePosition
  }
});

const blinnPhongMaterial = new THREE.ShaderMaterial({
  uniforms: {
    spherePosition: spherePosition,
    ambientColor: ambientColor,
    diffuseColor: diffuseColor,
    specularColor: specularColor,
    kAmbient: kAmbient,
    kDiffuse: kDiffuse,
    kSpecular: kSpecular,
    shininess: shininess
  }
});

const rayMarchingMaterial = new THREE.ShaderMaterial({
  uniforms: {
    time: ticks,
    resolution: resolution
  }
});

const helmetAlbedoMap = new THREE.TextureLoader().load(
  "gltf/Default_albedo.jpg"
);
helmetAlbedoMap.colorSpace = THREE.SRGBColorSpace;
helmetAlbedoMap.flipY = false;
helmetAlbedoMap.wrapS = 1000;
helmetAlbedoMap.wrapT = 1000;

const helmetMetalRoughnessMap = new THREE.TextureLoader().load(
  "gltf/Default_metalRoughness.jpg"
);
helmetMetalRoughnessMap.colorSpace = THREE.LinearSRGBColorSpace; // Typically, these maps are linear
helmetMetalRoughnessMap.flipY = false;
helmetMetalRoughnessMap.wrapS = THREE.RepeatWrapping;
helmetMetalRoughnessMap.wrapT = THREE.RepeatWrapping;

const helmetEmissiveMap = new THREE.TextureLoader().load(
  "gltf/Default_emissive.jpg"
);
helmetEmissiveMap.colorSpace = THREE.SRGBColorSpace;
helmetEmissiveMap.flipY = false;
helmetEmissiveMap.wrapS = THREE.RepeatWrapping;
helmetEmissiveMap.wrapT = THREE.RepeatWrapping;

const helmetNormalMap = new THREE.TextureLoader().load(
  "gltf/Default_normal.jpg"
);
helmetNormalMap.flipY = false; // Normal maps usually require flipY = false with glTF
helmetNormalMap.wrapS = THREE.RepeatWrapping;
helmetNormalMap.wrapT = THREE.RepeatWrapping;

const helmetAOMap = new THREE.TextureLoader().load("gltf/Default_AO.jpg");
helmetAOMap.flipY = false;
helmetAOMap.wrapS = THREE.RepeatWrapping;
helmetAOMap.wrapT = THREE.RepeatWrapping;

// TODO: implement helmetMetalRoughnessMap, helmetEmissiveMap, helmetNormalMap, helmetAOMap
// similarly to how helmetAlbedoMap is implemented

const helmetPBRMaterial = new THREE.MeshStandardMaterial({
  // TODO: pass texture maps to the material. Note that
  // both metalnessMap and roughnessMap should be set to the same
  // texture map
  map: helmetAlbedoMap,
  metalnessMap: helmetMetalRoughnessMap, // Both metalness and roughness come from the same texture
  roughnessMap: helmetMetalRoughnessMap,
  normalMap: helmetNormalMap,
  emissiveMap: helmetEmissiveMap,
  aoMap: helmetAOMap,

  // TODO: set the material's emissive color and metalness
  // Set default values for metalness and roughness:
  metalness: 1.0, // High metalness for a damaged sci-fi helmet (adjust as needed)
  roughness: 0.5, // Adjust roughness to control how shiny the helmet is
  emissive: new THREE.Color(0xffffff), // Start with no emissive color, adjust if needed

  clippingPlanes: [yzClippingPlane],
  clipShadows: true,
  alphaToCoverage: true
});


// Load shaders
const shaderFiles = [
  "glsl/sphere.vs.glsl",
  "glsl/sphere.fs.glsl",
  "glsl/blinn_phong.vs.glsl",
  "glsl/blinn_phong.fs.glsl",
  "glsl/raymarching.vs.glsl",
  "glsl/raymarching.fs.glsl"
];

new SourceLoader().load(shaderFiles, function (shaders) {
  sphereMaterial.vertexShader = shaders["glsl/sphere.vs.glsl"];
  sphereMaterial.fragmentShader = shaders["glsl/sphere.fs.glsl"];

  blinnPhongMaterial.vertexShader = shaders["glsl/blinn_phong.vs.glsl"];
  blinnPhongMaterial.fragmentShader = shaders["glsl/blinn_phong.fs.glsl"];

  rayMarchingMaterial.vertexShader = shaders["glsl/raymarching.vs.glsl"];
  rayMarchingMaterial.fragmentShader = shaders["glsl/raymarching.fs.glsl"];
});

// Define the shader modes
const shaders = {
  BLINNPHONG: { key: 0, material: blinnPhongMaterial },
  RAYMARCHING: { key: 1, material: rayMarchingMaterial },
  PBR: { key: 2, material: helmetPBRMaterial }
};

let mode = shaders.BLINNPHONG.key; // Default

renderer.localClippingEnabled = true;
let damagedHelmet;
// Set up scenes
let scenes = [];
for (let shader of Object.values(shaders)) {
  // Create the scene
  let scene, camera, worldFrame;
  if (shader.material == rayMarchingMaterial) {
    ({ scene, camera } = createRayMarchingScene(canvas, renderer));
    const plane = new THREE.PlaneGeometry(2, 2);
    scene.add(new THREE.Mesh(plane, shaders.RAYMARCHING.material));
  } else {
    ({ scene, camera, worldFrame } = createScene(canvas, renderer));

    // Create the main sphere geometry (light source)
    // https://threejs.org/docs/#api/en/geometries/SphereGeometry
    const sphereGeometry = new THREE.SphereGeometry(1.0, 32.0, 32.0);
    const sphere = new THREE.Mesh(sphereGeometry, sphereMaterial);
    sphere.position.set(0.0, 1.5, 0.0);
    sphere.parent = worldFrame;
    scene.add(sphere);
  }

  // Load the helmet, for scene key 3.
  if (shader.material == helmetPBRMaterial) {
     loadAndPlaceGLB(
      "gltf/DamagedHelmet.glb",
      shaders.PBR.material,
      function (helmet) {
        helmet.position.set(0, 0, -10.0);
        helmet.scale.set(7, 7, 7);
        helmet.parent = worldFrame;
        scene.add(helmet);
        damagedHelmet = helmet;
        scene.add(clippingPlaneHelper);
        // Rotate helper plane so that its normal points in the x direction.
        clippingPlaneHelper.rotation.y = -Math.PI / 2; // rotates plane so that (0,0,1) becomes (1,0,0)

        // Update its position along x based on the clipping plane constant.
        clippingPlaneHelper.position.x = -yzClippingPlane.constant;
        const helmetWorldPosition = new THREE.Vector3();
        damagedHelmet.getWorldPosition(helmetWorldPosition);
        clippingPlaneHelper.position.y = helmetWorldPosition.y;
        clippingPlaneHelper.position.z = helmetWorldPosition.z;
      }
    );

    const ambientLight = new THREE.AmbientLight(0xffffff, 3.0);
    scene.add(ambientLight);

    sphereLight.parent = worldFrame;
  } 
  else {
    // If there's no helmet, then only place the snowman. i.e. key 1, 2
    loadAndPlaceOBJ("obj/snowman.obj", shader.material, function (snowman) {
      snowman.position.set(0.0, 0.0, -10.0);
      snowman.rotation.y = 0.0;
      snowman.scale.set(1.0e-3, 1.0e-3, 1.0e-3);
      snowman.parent = worldFrame;
      scene.add(snowman);
    });
  }

  scenes.push({ scene, camera });
}


function rotateHelmet(){
  damagedHelmet.rotation.y += 0.01;
}

function getNeonFlickerIntensity(time) {
  // A sine wave for a baseline periodic fluctuation.
  const periodic = Math.sin(time * 20);

  // Occasionally, we want to simulate a sudden drop in intensity.
  // For instance, with a 10% chance each frame, drop the intensity.
  const dropChance = 0.1;
  const drop = Math.random() < dropChance ? 0.3 : 1.0;

  // Combine the periodic fluctuation with the random drop.
  // Adjust the multipliers to achieve your desired neon effect.
  const baseIntensity = 1.0;
  const flicker = baseIntensity + 0.3 * periodic;

  // Apply the drop factor.
  return flicker * drop;
}

// Listen to keyboard events.
const keyboard = new THREEx.KeyboardState();
function checkKeyboard() {
  if (keyboard.pressed("1")) mode = shaders.BLINNPHONG.key;
  else if (keyboard.pressed("2")) mode = shaders.RAYMARCHING.key;
  else if (keyboard.pressed("3")) mode = shaders.PBR.key;

  if (mode != shaders.RAYMARCHING.key) {
    if (keyboard.pressed("W")) spherePosition.value.z -= 0.3;
    else if (keyboard.pressed("S")) spherePosition.value.z += 0.3;

    if (keyboard.pressed("A")) spherePosition.value.x -= 0.3;
    else if (keyboard.pressed("D")) spherePosition.value.x += 0.3;

    if (keyboard.pressed("E")) spherePosition.value.y -= 0.3;
    else if (keyboard.pressed("Q")) spherePosition.value.y += 0.3;

    if (keyboard.pressed("Z")) {
      yzClippingPlane.constant -= 0.3;
      clippingPlaneHelper.position.x = -yzClippingPlane.constant;
    } else if (keyboard.pressed("C")) {
      yzClippingPlane.constant += 0.3;
      clippingPlaneHelper.position.x = -yzClippingPlane.constant;
    }

    sphereLight.position.set(
      spherePosition.value.x,
      spherePosition.value.y,
      spherePosition.value.z
    );
  } else {
    const canvas = renderer.domElement;
    resolution.value.set(canvas.width, canvas.height, 1);
  }

  // The following tells three.js that some uniforms might have changed
  sphereMaterial.needsUpdate = true;
  blinnPhongMaterial.needsUpdate = true;
  helmetPBRMaterial.needsUpdate = true;
  rayMarchingMaterial.needsUpdate = true;
}

let clock = new THREE.Clock();
let startTime = Date.now();
// Setup update callback
function update() {
  checkKeyboard();
  ticks.value += clock.getDelta();
  const currentTime = Date.now();
  const time = (currentTime - startTime) / 1000;
  if (damagedHelmet) {
    rotateHelmet();
  }
  
  helmetPBRMaterial.emissiveIntensity = getNeonFlickerIntensity(time);

  // Requests the next update call, this creates a loop
  requestAnimationFrame(update);
  const { scene, camera } = scenes[mode];
  renderer.render(scene, camera);
}

// Start the animation loop.
update();
