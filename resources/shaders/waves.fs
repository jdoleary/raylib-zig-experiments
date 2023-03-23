#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;
uniform float seconds;
uniform vec2 size;

// Output fragment color
out vec4 finalColor;

// NOTE: Add here your custom variables

void main()
{
    float thresholdY = sin(seconds);
    float thresholdX = cos(seconds)+1.5;

    vec2 coord = fragTexCoord;
    float waveHeight = 0.02;
    float wavePeriod = 0.1;
    float waveSpeed = 0.2;
    float wholeWaveBodyUpAndDownAmount = 0.02;
    float verticalOffset = 0.09;

    if(coord.y + thresholdY*wholeWaveBodyUpAndDownAmount > size.y/2.0 + cos((coord.x+seconds*waveSpeed)/wavePeriod)*waveHeight + verticalOffset){
        finalColor = vec4(0.0);
    }else{
        vec2 xy = coord.xy / size;//Condensing this into one line
        vec4 texColor = texture(texture0,xy);//Get the pixel at xy from iChannel0

        finalColor = texColor;//Set the screen pixel to that color
    }
}
float mod_float(float base, float div){
    return div - (base * floor(div/base));
}