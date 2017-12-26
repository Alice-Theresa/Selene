precision mediump float;

uniform sampler2D image;

varying vec2 vTexcoord;

void main()
{
    vec4 outColor = texture2D(image, vTexcoord);
    
    gl_FragColor = outColor;
}

