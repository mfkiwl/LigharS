void L_x() {

}



// approximates sin of x degree in the range from 0 to 180.
float BhaskaraSin(float x) {
    if(x >= 0)
        return 4 * x * (180 - x) / (40500 - x * (180 - x));
    else
        return -4 * x * (180 - x) / (40500 - x * (180 - x));
}


// using taylor series
float TaylorSin(float x) {
    float x2 = x * x;
    float x3 = x2 * x;
    float x5 = x3 * x2;
    return 1.0f * x - x3 / 6 + x5 / 120;
}
float TaylorCos(float x) {
    float x2 = x * x;
    float x4 = x2 * x2;
    float x6 = x4 * x2;
    float x8 = x4 * x4;
    return 1.0f - x2 / 4 + x4 / 24 - x6 / 720 + x8 / 40320;
}




float CarmackSqrt(float x) {
    float xhalf = 0.5f * x;
    int i = *(int*)&x;
    i = 0x5f3759df - (i >> 1);
    x = *(float*)&i;
    x = x * (1.5f - xhalf * x * x);
    return 1/x;
}
