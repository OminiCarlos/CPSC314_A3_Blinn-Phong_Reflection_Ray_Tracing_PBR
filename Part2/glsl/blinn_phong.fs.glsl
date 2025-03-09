uniform vec3 ambientColor;
uniform float kAmbient;

uniform vec3 diffuseColor;
uniform float kDiffuse;

uniform vec3 specularColor;
uniform float kSpecular;
uniform float shininess;

uniform mat4 modelMatrix;

uniform vec3 spherePosition;

// These are interpolated from the vertex shader:
in vec3 interpolatedNormal;
in vec3 viewPosition;
in vec3 worldPosition;

void main () {
    // Normalize the interpolated normal (assumed to be in world space)
    vec3 N = normalize (interpolatedNormal);

    // Compute the light direction (from the fragment to the light source)
    vec3 L = normalize (spherePosition - worldPosition);
    // Ambient component:
    vec3 ambient = kAmbient * ambientColor;

    // Diffuse component: based on Lambert's cosine law
    float diffusionIntensity = max (dot (N, L), 0.0);
    vec3 diffuse = kDiffuse * diffusionIntensity * diffuseColor;

    // Specular component: using Blinn–Phong
    vec3 viewDir = normalize (cameraPosition - worldPosition);
    vec3 halfDir = normalize (L + viewDir);
    float phongFactor = pow (max (dot (N, halfDir), 0.0), shininess);
    vec3 specular = kSpecular * phongFactor * specularColor;

    // Combine all components
    // vec3 finalColor = ambient + diffuse + specular;
    vec3 finalColor = ambient + diffuse + specular;
    gl_FragColor = vec4 (finalColor, 1.0);
}
