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
	return 1.0f * x - x * x * x / 6 + x * x * x * x * x / 120;
}
float TaylorCos(float x) {
	return 1.0f - x * x / 4 + x * x * x * x / 24 - x * x * x * x * x * x / 720 + x * x * x * x * x * x * x * x / 40320;
}




float CarmackSqrt(float x) { 
	float xhalf = 0.5f * x;   
	int i = *(int*)&x;    
	i = 0x5f3759df - (i >> 1);   
	x = *(float*)&i;    
	x = x * (1.5f - xhalf * x * x);    
	return 1/x; 
}
