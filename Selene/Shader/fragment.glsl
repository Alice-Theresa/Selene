precision mediump float;

uniform sampler2D image;

varying vec2 vTexcoord;

void main()
{
    vec4 outColor = texture2D(image, vTexcoord);
    gl_FragColor = vec4(1. - outColor.r, 1. - outColor.g, 1. -outColor.b, 1.);
}
