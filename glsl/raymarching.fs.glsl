uniform vec3 resolution;
uniform float time;   

// NOTE: You may temporarily adjust these values to improve render performance.
#define MAX_STEPS 50 // max number of steps to take along ray
#define MAX_DIST 50. // max distance to travel along ray
#define HIT_DIST .01 // distance to consider as "hit" to surface

/*
 * Helper: determines the material ID based on the closest distance.
 */
float getMaterial (vec2 d1, vec2 d2) {
    return (d1.x < d2.x) ? d1.y : d2.y;
}

/*
 * Hard union of two SDFs.
 */
float unionSDF (float d1, float d2) {

	/*
     * TODO: Implement the union of two SDFs.
     */
    return min (d1, d2);
}

/*
 * Smooth union of two SDFs.
 * Resource: `https://iquilezles.org/articles/smin/`
 */
float smoothUnionSDF (float d1, float d2, float k) {
	/*
     * TODO: Implement the smooth union of two SDFs.
     */
    k *= 4.0;
    float h = max (k - abs (d1 - d2), 0.0) / k;
    return min (d1, d2) - h * h * k * (1.0 / 4.0);
}

/*
 * Helper: Computes the signed distance function (SDF) of a plane.
 */
vec2 Plane (vec3 p) {
    vec3 n = vec3 (0, 1, 0); // Normal
    float h = 0.0; // Height
    return vec2 (dot (p, n) + h, 1.0);
}

/*
 * Sphere SDF.
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *  - center: The center of the sphere.
 *  - r: The radius of the sphere.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the sphere.
 *    - An identifier for material type.
 */
vec2 Sphere (vec3 p, vec3 center, float r) {

    /*
     * TODO: Implement the signed distance function for a sphere.
     */

    float dist = length (p - center) - r;
    float sphere_id = 2.0;

    return vec2 (dist, sphere_id);
}

/*
 * Cylinder SDF.
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *  - center: The center of the cylinder.
 *  - r: The radius of the cylinder.
 *  - h: The height of the cylinder.
 *  - rotate: A flag to apply rotation.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the cylinder.
 *    - An identifier for material type.
 */
vec2 Cylinder (vec3 p, vec3 center, float r, float h, bool rotate) {
    float hat_id = 3.0;
    float button_id = 5.0;

    /*
     * TODO: Implement the signed distance function for a cylinder.
     *       use to rotate flag for surfaces that require rotation.
     */

    // Step 1. Translate the point so that the cylinder's base center is at the origin.
    vec3 pos = p - center;

    if (rotate) {
        pos = vec3 (pos.x, pos.z, pos.y);
    }

    // Step 3. Compute the radial distance from the cylinder's central (vertical) axis.
    // This is the distance in the xz-plane.
    float radialDistance = length (vec2(pos.x,pos.z));

    // Step 4. Compute the vertical distance relative to the cylinder.
    // For a cylinder aligned along y, the vertical component is pos.y.
    // Here, we assume h is the half-height (i.e. cylinder extends from -h to +h).
    float verticalDistance = abs (pos.y) - h;

    // Step 5. Form a vec2 'd' with two components:
    //   d.x: the excess radial distance beyond the radius.
    //   d.y: the excess vertical distance beyond the half-height.
    vec2 d = vec2 (radialDistance - r, verticalDistance);

    // Step 6. Combine these distances to compute the SDF.
    // If the point is inside both the radial and vertical extents, max(d.x, d.y) is negative.
    // Outside, we add the positive parts. This is a common formulation for a finite cylinder.
    float distance = min (max (d.x, d.y), 0.0) + length (max (d, vec2 (0.0)));

    // Step 7. Choose the material ID based on the 'rotate' flag.
    float finalMaterialID = rotate ?  button_id :hat_id ;

    // Return the signed distance and the material ID.
    return vec2 (distance, finalMaterialID);
}

/*
 * Cone SDF. 
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *  - center: The center of the cone base.
 *  - t: The angle of the cone.
 *  - h: The height of the cone.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the cone.
 *    - An identifier for material type.
 */
vec2 Cone (vec3 p, vec3 c, float t, float h) {
    float dist = MAX_DIST;
    float cone_id = 4.0; 

    // Shift the input point `p` so that `c` is the origin
    p -= c;

    // Rotate the cone around the y-axis
    p = vec3 (p.x, -p.z, p.y);

    vec2 cxy = vec2 (sin (t), cos (t));
    vec2 q = h * vec2 (cxy.x / cxy.y, -1.0);
    vec2 w = vec2 (length (p.xz), p.y);
    vec2 a = w - q * clamp (dot (w, q) / dot (q, q), 0.0, 1.0);
    vec2 b = w - q * vec2 (clamp (w.x / q.x, 0.0, 1.0), 1.0);
    float k = sign (q.y);
    float d = min (dot (a, a), dot (b, b));
    float s = max (k * (w.x * q.y - w.y * q.x), k * (w.y - q.y));
    dist = sqrt (d) * sign (s);

    return vec2 (dist, cone_id);
}

/*
 * Snowman SDF.
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the snowman.
 *    - An identifier for material type.
 */
vec2 Snowman (vec3 p) {

    vec3 basePoint = vec3 (0, 0, 5);
    /*
     * TODO - Implement the signed distance function for a snowman.
     *        Make use of the helper SDF and blending functions
     *        to compute the final distance and material ID.
     */
     // --- Body Parts ---
    // Bottom sphere (body)
    vec2 body = Sphere (p, basePoint + vec3 (0.0, 0.5, 2.0), 0.5);
    // Middle sphere (torso)
    vec2 torso = Sphere (p, basePoint + vec3 (0.0, 1, 2.0), 0.35);
    // Top sphere (head)
    vec2 head = Sphere (p, basePoint + vec3 (0.0, 1.4, 2.0), 0.2);

    // Combine the body parts using hard union:
    float dBodyTorso = unionSDF (body.x, torso.x);
    float idBodyTorso = (body.x < torso.x) ? body.y : torso.y;
    vec2 bodyUnion = vec2 (dBodyTorso, idBodyTorso);

    float dAllBody = unionSDF (bodyUnion.x, head.x);
    float idAllBody = (bodyUnion.x < head.x) ? bodyUnion.y : head.y;
    vec2 snowmanBody = vec2 (dAllBody, idAllBody);

    // // --- Buttons on the Torso ---
    // // Three small spheres representing buttons on the front of the torso.
    // vec2 Cylinder (vec3 p, vec3 center, float r, float h, bool rotate) {
    vec2 button1 = Cylinder(p, basePoint +vec3(0.0, 1.0, 1.65), 0.03, 0.001, true);
    vec2 button2 = Cylinder(p, basePoint +vec3(0.0, 1.1, 1.657), 0.03, 0.001, true);
    vec2 button3 = Cylinder(p, basePoint +vec3(0.0, 1.2, 1.70), 0.03, 0.002, true);
    

    float dButtonsTemp = unionSDF(button1.x, button2.x);
    float idButtonsTemp = (button1.x < button2.x) ? button1.y : button2.y;
    vec2 buttonsUnion = vec2(unionSDF(dButtonsTemp, button3.x),
                             (dButtonsTemp < button3.x) ? idButtonsTemp : button3.y);

    // // --- Eyes on the Head ---
    vec2 eye1 = Cylinder(p, basePoint + vec3(0.07, 1.5, 1.82), 0.01, 0.001, true);
    vec2 eye2 = Cylinder(p, basePoint + vec3(- 0.07, 1.5, 1.82), 0.01, 0.001, true);
    float dEyes = unionSDF(eye1.x, eye2.x);
    float idEyes = (eye1.x < eye2.x) ? eye1.y : eye2.y;
    vec2 eyesUnion = vec2(dEyes, idEyes);

    // --- Nose: A Cone for the Carrot ---
    // Here we use a cone SDF with a given angle (in radians) and height.
    vec2 nose = Cone (p, basePoint +vec3 (0.0, 1.45, 1.6), radians (10.0), 0.3);

    // --- Hat: A Cylinder for the Hat ---
    // The hat is modeled as a small cylinder placed on top of the head.
    vec2 hat1 = Cylinder (p, basePoint +vec3 (0.0, 1.68, 2.0), 0.15, 0.08, false);
    vec2 hat2 = Cylinder (p, basePoint +vec3 (0.0, 1.60, 2.0), 0.25, 0.0005, false);
    // vec2 hat2 = Cylinder (p, vec3 (0.2, 1.60, 2.0), 0.25, 0.0005, true);

    // --- Combine All Features ---
    // Start with the body union and then union with the other features.
    float dFinal = snowmanBody.x;
    float finalID = snowmanBody.y;

    // Union with buttons:
    dFinal = unionSDF(dFinal, buttonsUnion.x);
    finalID = (dFinal == buttonsUnion.x) ? buttonsUnion.y : finalID;

    // // Union with eyes:
    dFinal = unionSDF(dFinal, eyesUnion.x);
    finalID = (dFinal == eyesUnion.x) ? eyesUnion.y : finalID;

    // Union with nose:
    dFinal = unionSDF (dFinal, nose.x);
    finalID = (dFinal == nose.x) ? nose.y : finalID;

    // Union with hat:
    dFinal = unionSDF (dFinal, hat1.x);
    finalID = (dFinal == hat1.x) ? hat1.y : finalID;
    // Union with hat:
    dFinal = unionSDF (dFinal, hat2.x);
    finalID = (dFinal == hat2.x) ? hat2.y : finalID;

    return vec2 (dFinal, finalID);
}

/*
 * Helper: gets the distance and material ID to the closest surface in the scene.
 */
vec2 getSceneDist (vec3 p) {

    vec2 snowman = Snowman (p);
    vec2 plane = Plane (p);

    float dist = smoothUnionSDF (snowman.x, plane.x, .02);
    float id = getMaterial (snowman, plane);

    return vec2 (dist, id);
}

/*
 * Performs ray marching to determine the closest surface intersection.
 *
 * Parameters:
 *  - ro: Ray origin.
 *  - rd: Ray direction.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Distance to the closest surface intersection.
 *    - material ID of the closest intersected surface.
 */
vec2 rayMarch (vec3 ro, vec3 rd) {
    float d = 0.0;
    float id = 0.0;

    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * d;       // Current point along the ray
        vec2 scene = getSceneDist (p); // Get distance and material ID for this point
        float distStep = scene.x;
        id = scene.y;               // Update material ID based on the closest surface

        // If we're close enough to a surface, break out
        if (distStep < HIT_DIST) {
            break;
        }

        // Increment the ray distance
        d += distStep;

        // If we exceed the maximum allowed distance, return background (id = 0.0)
        if (d > MAX_DIST) {
            id = 0.0;
            break;
        }
    }

    return vec2 (d, id);
}

/* 
 * Helper: computes surface normal
 */
vec3 getNormal (vec3 p) {
    float d = getSceneDist (p).x;
    vec2 e = vec2 (.01, 0);

    vec3 n = d - vec3 (getSceneDist (p - e.xyy).x, getSceneDist (p - e.yxy).x, getSceneDist (p - e.yyx).x);

    return normalize (n);
}

/*
 * Helper: gets surface color.
 */
vec3 getColor (vec3 p, float id) {

    vec3 lightPos = vec3 (3, 5, 2);
    vec3 l = normalize (lightPos - p);
    vec3 n = getNormal (p);

    float diffuse = clamp (dot (n, l), 0.2, 1.);

    // Perform shadow check using ray marching 
    { 
        // NOTE: Comment out to improve render performance
        float d = rayMarch (p + n * HIT_DIST * 2., l).x;
        if (d < length (lightPos - p))
            diffuse *= 0.1;
    }

    vec3 diffuseColor;

    switch (int (id)) {
        case 0: // background sky color (ray missed all surfaces) 
            diffuseColor = vec3 (.3, .6, 1.);
            diffuse = .97;
            // diffuseColor = vec3 (0.76, 1.0, 0.3);
            // diffuse = 0.7;
            break;
        case 1: // plane (snow)
            diffuseColor = vec3 (1, .98, .98);
            // diffuseColor = vec3 (0.98, 1.0, 0.0);
            break;
        case 2: // snowman (slightly darker snow)
            diffuseColor = vec3 (0.9, 1.0, 0.93);
            // diffuseColor = vec3 (0.9, 0.96, 0.0);
            break;
        case 3: // hat
            diffuseColor = vec3 (.8, .05, 0);
            break;
        case 4: // nose
            diffuseColor = vec3 (.8, .2, .0);
            break;
        case 5: // eye/buttons
            diffuseColor = vec3 (.1, .1, .1);
            break;
    }

    // vec3 ambientColor = vec3 (.9, .9, .9);
    // float ambient = .1;
    vec3 ambientColor = vec3 (0.54, 0.0, 0.9);
    float ambient = 0.0;
    return ambient * ambientColor + diffuse * diffuseColor;
}

/*
 * Helper: camera matrix.
 */
mat3 setCamera (in vec3 ro, in vec3 ta, float cr) {
    vec3 cw = normalize (ta - ro);
    vec3 cp = vec3 (sin (cr), cos (cr), 0.0);
    vec3 cu = normalize (cross (cw, cp));
    vec3 cv = (cross (cu, cw));
    return mat3 (cu, cv, cw);
}

void main () {

    // Get the fragment coordinate in screen space
    vec2 fragCoord = gl_FragCoord.xy;

    // normalize to UV coordinates
    vec2 uv = (fragCoord - 0.5 * resolution.xy) / resolution.y;

    // Look-at target (the point the camera is focusing on)
    vec3 ta = vec3 (0, 1, 5); 

    // Camera position 
    // NOTE: modify camera for development
    vec3 ro = vec3 (0, 2, 0); // static 
    // vec3 ro = vec3 (0, 5, 5); // static 
    // vec3 ro = ta + vec3(4.0 * cos(0.7 * time), 2.0, 4.0 * sin(0.7 * time)); // dynamic camera

    // Compute the camera's coordinate frame
    mat3 ca = setCamera (ro, ta, 0.0); 

    // Compute the ray direction for this pixel with respect to camera frame
    vec3 rd = ca * normalize (vec3 (uv.x, uv.y, 1));

    // Perform ray marching to find intersection distance and surface material ID
    vec2 dist = rayMarch (ro, rd);
    float d = dist.x;
    float id = dist.y; 

    // Surface intersection point
    vec3 p = ro + rd * d;

    // Compute surface color
    vec3 color = getColor (p, id); 

    // Apply gamma correction to adjust brightness
    color = pow (color, vec3 (0.4545)); 

    // Output the final color to the fragment shader
    gl_FragColor = vec4 (color, 1.0);
}
