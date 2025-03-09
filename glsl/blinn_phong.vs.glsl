uniform vec3 spherePosition;

out vec3 viewPosition;       // Vertex position in view (camera) space
out vec3 worldPosition;      // Vertex position in world space
out vec3 interpolatedNormal; // Transformed normal in world space

void main () {
    // Compute the world space position by transforming the vertex position
    worldPosition = (modelMatrix * vec4 (position, 1.0)).xyz;

    // Compute the view (camera) space position by using the model-view matrix
    viewPosition = (modelViewMatrix * vec4 (position, 1.0)).xyz;

    // Compute the transformed normal vector in world space.
    // Using the normalMatrix (inverse-transpose of modelViewMatrix) ensures proper handling
    // of non-uniform scaling. The result is then normalized.
    interpolatedNormal = normalize ((mat3 (modelMatrix)) * normal);

    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4 (position, 1.0);
}
