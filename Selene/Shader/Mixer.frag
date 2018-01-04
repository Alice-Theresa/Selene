precision mediump float;

uniform sampler2D image1;
uniform sampler2D image2;

varying vec2 vTexcoord;

void main()
{
    vec4 t1 = texture2D(image1, vTexcoord);
    vec4 t2 = texture2D(image2, vTexcoord);
    gl_FragColor = mix(t1, t2, 0.5);
}

