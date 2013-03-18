attribute vec4 position;
attribute vec3 color;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;

void main()
{
    colorVarying = vec4(color, 1);
    
    gl_Position = modelViewProjectionMatrix * position;
}
