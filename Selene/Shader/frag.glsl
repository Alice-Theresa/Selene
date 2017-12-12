precision mediump float;

uniform sampler2D image;

varying vec2 vTexcoord;

void main()
{
    vec4 outColor = texture2D(image, vTexcoord);
    float avg = 0.2126 * outColor.r + 0.7152 * outColor.g + 0.0722 * outColor.b;
    gl_FragColor = vec4(avg, avg, avg, 1.0);
}

