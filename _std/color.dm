//COLURSSSSSS AAAAA
/proc/hsv2rgb(var/hue, var/sat, var/val)
	var/hh
	var/p
	var/q
	var/t
	var/ff
	var/i
	if(sat <= 0)
		return rgb(val*255,val*255,val*255)
	hh = hue
	hh %= 360
	hh /= 60
	i = round(hh)
	ff = hh - i
	p = val * (1-sat)
	q = val * (1 - (sat * ff))
	t = val * (1 - (sat * (1 - ff)))
	switch(i)
		if(0)
			return rgb(val * 255, t * 255, p * 255)
		if(1)
			return rgb(q*255, val*255, p*255)
		if(2)
			return rgb(p*255, val*255, t*255)
		if(3)
			return rgb(p*255, q*255, val*255)
		if(4)
			return rgb(t*255, p*255, val*255)
		else
			return rgb(val*255, p*255, q*255)

/proc/hsv2rgblist(var/hue, var/sat, var/val)//gross but mah efficiency
	var/hh
	var/p
	var/q
	var/t
	var/ff
	var/i
	if(sat <= 0)
		return list(val*255,val*255,val*255)
	hh = hue
	hh %= 360
	hh /= 60
	i = round(hh)
	ff = hh - i
	p = val * (1-sat)
	q = val * (1 - (sat * ff))
	t = val * (1 - (sat * (1 - ff)))
	switch(i)
		if(0)
			return list(val * 255, t * 255, p * 255)
		if(1)
			return list(q*255, val*255, p*255)
		if(2)
			return list(p*255, val*255, t*255)
		if(3)
			return list(p*255, q*255, val*255)
		if(4)
			return list(t*255, p*255, val*255)
		else
			return list(val*255, p*255, q*255)

/proc/rgb2hsv(var/r, var/g, var/b)
	var/min
	var/max
	var/dt

	var/outh
	var/outs
	var/outv
	r/=255;g/=255;b/=255
	min = r < g ? r : g
	min = min < b ? min : b

	max = r > g ? r : g
	max = max > b ? max : b

	outv = max
	dt = max-min
	if(dt < 0.00001)
		return list(0, 0, outv)
	if(max > 0)
		outs = dt/max
	else
		return list(0, 0, outv)
	if(r >= max)
		outh = (g-b)/dt//y&mg
	else if(g >= max)
		outh = 2 + (b-r)/dt//cy/y
	else
		outh = 4 + (r-g)/dt//mg/cy

	outh *= 60
	if(outh < 0)
		outh += 360
	return list(outh, outs, outv)

/proc/hex_to_rgb_list(var/hex)
	var/regex/R = new("^#?(\[a-f\\d\]{2})(\[a-f\\d\]{2})(\[a-f\\d\]{2})$", "gi")
	var/list/L = list()
	if (R.Find(hex))
		L["r"] = hex2num(R.group[1])
		L["g"] = hex2num(R.group[2])
		L["b"] = hex2num(R.group[3])
		return L
	return null

/proc/random_color()
	return rgb(rand(0, 255), rand(0, 255), rand(0, 255))

/// Takes two 16-length lists, turns them into 4x4 matrices, multiplies them together, and returns a 16-length list
/proc/mult_color_matrix(var/list/Mat1, var/list/Mat2) // always 4x4 please
	if (!Mat1.len || !Mat2.len || Mat1.len != 16 || Mat2.len != 16)
		return 0

	var/list/M1[4][4] // turn the input matrix lists into more matrix-y lists
	var/list/M2[4][4] // both of em
	var/index = 1
	for(var/r in 1 to 4)
		for(var/c in 1 to 4)
			M1[c][r] = Mat1[index]
			M2[c][r] = Mat2[index]
			index ++
	var/list/out[4][4] // make a matrix to hold our result
	for(var/i in 1 to 4)
		for(var/ro in 1 to 4)
			for(var/co in 1 to 4)
				out[i][ro] += (M1[i][co]*M2[co][ro])
	var/list/outlist[16] // and convert that matrix back into a 1-dimensional list
	var/indexout = 1
	for(var/r in 1 to 4)
		for(var/c in 1 to 4)
			outlist[indexout] = out[c][r]
			indexout ++
	return outlist

//Color matrices		// vv Values modified from those obtained from https://gist.github.com/Lokno/df7c3bfdc9ad32558bb7
#define COLOR_MATRIX_PROTANOPIA list(0.55, 0.45, 0.00, 0.00,\
																		 0.55, 0.45, 0.00, 0.00,\
																		 0.00, 0.25, 1.00, 0.00,\
																		 0.00, 0.00, 0.00, 1.00)
#define COLOR_MATRIX_DEUTERANOPIA list(0.63, 0.38, 0.00, 0.00,\
																			 0.70, 0.30, 0.00, 0.00,\
																			 0.00, 0.30, 0.70, 0.00,\
																			 0.00, 0.00, 0.00, 1.00)
#define COLOR_MATRIX_TRITANOPIA list(0.95, 0.05, 0.00, 0.00,\
																		 0.00, 0.43, 0.57, 0.00,\
																		 0.00, 0.48, 0.53, 0.00,\
																		 0.00, 0.00, 0.00, 1.00)
#define COLOR_MATRIX_FLOCKMIND list(0.95, 0.05, 0.00, 0.00,\
																		0.00, 0.43, 0.57, 0.00,\
																		0.00, 0.48, 0.53, 0.00,\
																		0.00, 0.00, 0.00, 1.00)
#define COLOR_MATRIX_FLOCKMANGLED list(0.95, 0.05, 0.00, 0.00,\
																			 0.00, 0.43, 0.57, 0.00,\
																			 0.00, 0.48, 0.53, 0.00,\
																			 0.00, 0.00, 0.00, 1.00)
#define COLOR_MATRIX_IDENTITY list(1,0,0,0,\
																	 0,1,0,0,\
																	 0,0,1,0,\
																	 0,0,0,1)
#define COLOR_MATRIX_GRAYSCALE list(0.2126,0.2126,0.2126,0,\
																		0.7152,0.7152,0.7152,0,\
																		0.0722,0.0722,0.0722,0,\
																		0,0,0,1)
