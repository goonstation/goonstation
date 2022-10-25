//COLURSSSSSS AAAAA
// num2hex, hex2num
#define num2hex(X, len) num2text(X, len, 16)

#define hex2num(X) text2num(X, 16)

#define hsl2rgb(hue, sat, lum) rgb(h=hue,s=sat,l=lum)

#define hsv2rgb(hue, sat, val) rgb(h=hue,s=sat,v=val)

#define hsv2rgblist(hue, sat, val) rgb2num(hsv2rgb(hue, sat, val))

#define rgb2hsl(r, g, b) rgb2num(rgb(r, g, b), COLORSPACE_HSL)

#define rgb2hsv(r, g, b) rgb2num(rgb(r, g, b), COLORSPACE_HSV)

#define hex_to_rgb_list(hex) rgb2num(hex)

/proc/random_color()
	return rgb(rand(0, 255), rand(0, 255), rand(0, 255))

// This proc converts a hex color value ("#420CAB") to an RGB list
// Clamps each of the RGB values between 50 and 190
/proc/fix_colors(var/hex)
	if(length(hex) != 7)
		hex = fix_hex(hex)
	var/list/L = hex_to_rgb_list(hex)
	if(isnull(L))
		return rgb(22, 210, 22)
	for (var/i in 1 to 3)
		L[i] = min(L[i], 190)
		L[i] = max(L[i], 50)
	if (length(L) == 3)
		return rgb(L[1], L[2], L[3])
	return rgb(22, 210, 22)

/proc/fix_hex(hex)
	return copytext((startswith(hex, "#") ? hex : "#") + "000000", 1, 8)

#define COLOR_MATRIX_PROTANOPIA_LABEL "protanopia"
#define COLOR_MATRIX_PROTANOPIA list(0.55, 0.45, 0.00, 0.00,\
																		 0.55, 0.45, 0.00, 0.00,\
																		 0.00, 0.25, 1.00, 0.00,\
																		 0.00, 0.00, 0.00, 1.00,\
																		 0.00, 0.00, 0.00, 0.00)
#define COLOR_MATRIX_DEUTERANOPIA_LABEL "deuteranopia"
#define COLOR_MATRIX_DEUTERANOPIA list(0.63, 0.38, 0.00, 0.00,\
																			 0.70, 0.30, 0.00, 0.00,\
																			 0.00, 0.30, 0.70, 0.00,\
																			 0.00, 0.00, 0.00, 1.00,\
																			 0.00, 0.00, 0.00, 0.00)
#define COLOR_MATRIX_TRITANOPIA_LABEL "tritanopia"
#define COLOR_MATRIX_TRITANOPIA list(0.95, 0.05, 0.00, 0.00,\
																		 0.00, 0.43, 0.57, 0.00,\
																		 0.00, 0.48, 0.53, 0.00,\
																		 0.00, 0.00, 0.00, 1.00,\
																		 0.00, 0.00, 0.00, 0.00)
#define COLOR_MATRIX_FLOCKMIND_LABEL "flockmind"
#define COLOR_MATRIX_FLOCKMIND list(1.00, 0.00, 0.00, 0.00,\
																		0.00, 1.00, 0.00, 0.00,\
																		0.00, 0.00, 1.00, 0.00,\
																		0.00, 0.00, 0.00, 1.00,\
																		0.00, 0.10, 0.20, 0.00)
#define COLOR_MATRIX_FLOCKMANGLED_LABEL "flockmind-fucked"
#define COLOR_MATRIX_FLOCKMANGLED list(-0.3, -0.3, -0.3, 0.00,\
																			 -0.3, -0.3, -0.3, 0.00,\
																			 -0.3, -0.3, -0.3, 0.00,\
																			 0.00, 0.00, 0.00, 1.00,\
																			 0.20, 0.80, 0.70, 0.00)
#define COLOR_MATRIX_IDENTITY_LABEL "identity"
#define COLOR_MATRIX_IDENTITY list(1.00, 0.00, 0.00, 0.00,\
																	 0.00, 1.00, 0.00, 0.00,\
																	 0.00, 0.00, 1.00, 0.00,\
																	 0.00, 0.00, 0.00, 1.00,\
																	 0.00, 0.00, 0.00, 0.00)
#define COLOR_MATRIX_GRAYSCALE_LABEL "grayscale"
#define COLOR_MATRIX_GRAYSCALE list(0.2126,0.2126,0.2126,0.00,\
																		0.7152,0.7152,0.7152,0.00,\
																		0.0722,0.0722,0.0722,0.00,\
																		0.00,  0.00,  0.00,  1.00,\
																		0.00,  0.00,  0.00,  0.00)

/// Takes two 20-length lists, turns them into 5x4 matrices, multiplies them together, and returns a 20-length list
/proc/mult_color_matrix(var/list/Mat1, var/list/Mat2) // always 5x4 please
	if (!Mat1.len || !Mat2.len || Mat1.len != 20 || Mat2.len != 20)
		return COLOR_MATRIX_IDENTITY

	var/list/M1[5][5] // turn the input matrix lists into more matrix-y lists
	var/list/M2[5][5] // wait thats 5x5
	var/index = 1
	for(var/r in 1 to 5)
		for(var/c in 1 to 4)
			M1[r][c] = Mat1[index]
			M2[r][c] = Mat2[index]
			index ++

	for(var/f in 1 to 5)
		M1[f][5] = (f == 5)
		M2[f][5] = (f == 5)

	var/list/out[5][5] // make a matrix to hold our result

	for(var/r1 in 1 to 5)
		for(var/c2 in 1 to 5)
			for(var/r2 in 1 to 5)
				out[r1][c2] += (M1[r1][r2]*M2[r2][c2])

	for(var/u in 1 to 5)
		out[u].len = 4

	var/list/outlist[20] // and convert that matrix back into a 1-dimensional list
	var/indexout = 1
	for(var/r in 1 to 5)
		for(var/c in 1 to 4)
			outlist[indexout] = out[r][c]
			indexout ++
	return outlist

/**
 * Takes a possible value of the `color` var and returns a length 20 color matrix doing the same thing.
 * Available inputs:
 *  null, "#rgb", "#rrggbb", "#rgba", "#rrggbbaa", all forms of color matrices
 */
/proc/normalize_color_to_matrix(color)
	if(isnull(color))
		return list(
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1,
			0, 0, 0, 0)
	if(istext(color))
		var/list/color_list = hex_to_rgb_list(color)
		if(length(color_list) == 3)
			color_list += 255
		return list(
			color_list[1] / 255, 0, 0, 0,
			0, color_list[2] / 255, 0, 0,
			0, 0, color_list[3] / 255, 0,
			0, 0, 0, color_list[4] / 255,
			0, 0, 0, 0,
		)
	if(islist(color))
		if(length(color) == 0)
			return null
		if(islist(color[1])) // list of rows
			while(length(color) < 5)
				color += null
			var/list/result = list()
			var/row_number = 1
			for(var/list/row in color)
				if(isnull(row))
					result += list(
						list(1, 0, 0, 0),
						list(0, 1, 0, 0),
						list(0, 0, 1, 0),
						list(0, 0, 0, 1),
						list(0, 0, 0, 0)
					)[row_number]
				else
					result += row // appending
				row_number += 1
			return result
		if(length(color) >= 9 && length(color) <= 12)
			var/list/long_col = color
			long_col = long_col.Copy()
			while(length(long_col) < 12)
				long_col += 0
			return list(
				long_col[1], long_col[2], long_col[3], 0,
				long_col[4], long_col[5], long_col[6], 0,
				long_col[7], long_col[8], long_col[9], 0,
				0, 0, 0, 1,
				long_col[10], long_col[11], long_col[12], 0)
		if(length(color) >= 16 && length(color) <= 20)
			var/list/long_col = color
			long_col = long_col.Copy()
			while(length(long_col) < 20)
				long_col += 0
			return long_col
	CRASH("invalid color format")

/**
	Takes two lists, inp=list(i1, i2, i3), out=(o1, o2, o3).
	Creates a color matrix which maps color i1 to o2, i2 to o2, i3 to o3. (Ignores alpha values.)
	Keep the i1, i2, i3 vectors linearly independent.
	The colors can be either be color hex strings or lists as returned from hex_to_rgb_list.
	You need to supply all arguments. If you don't care about the third just set i3 = o3 to something linearly independent of i1 and i2.
*/
proc/color_mapping_matrix(list/list/inp, list/list/out)
	if(length(inp) != 3 || length(out) != 3)
		CRASH("Incorrect number of colors in the mapping.")
	inp = inp.Copy() // we don't want to modify the input lists
	out = out.Copy()
	for(var/i in 1 to 3)
		if(istext(inp[i])) inp[i] = hex_to_rgb_list(inp[i])
		if(istext(out[i])) out[i] = hex_to_rgb_list(out[i])
		for(var/c in 1 to 3) // color matrices work in the 0-1 range
			inp[i][c] /= 255
			out[i][c] /= 255
	// don't panic, this is essentially just condensed way of writing: inversion of the (i1, i2, i3) matrix multiplied by the (o1, o2, o3) matrix
	// which essentially means: translate i1 to red, i2 to green, i3 to blue; then translate red to o1, green to o2, blue to o3
	// see this link (but beware bad variable names): https://www.wolframalpha.com/input/?i=%28invert+%28%28a%2Cb%2Cc%29%2C%28d%2Ce%2Cf%29%2C%28g%2Ch%2Ci%29%29%29%28%28j%2Ck%2Cl%29%2C%28m%2Cn%2Co%29%2C%28p%2Cq%2Cr%29%29
	var/D = inp[1][1]*inp[2][2]*inp[3][3] - inp[1][1]*inp[2][3]*inp[3][2] - inp[1][2]*inp[2][1]*inp[3][3] + inp[1][2]*inp[2][3]*inp[3][1] + inp[1][3]*inp[2][1]*inp[3][2] - inp[1][3]*inp[2][2]*inp[3][1]
	return list(
		( inp[1][2]*inp[2][3]*out[3][1] - inp[1][2]*inp[3][3]*out[2][1] - inp[1][3]*inp[2][2]*out[3][1] + inp[1][3]*inp[3][2]*out[2][1] + inp[2][2]*inp[3][3]*out[1][1] - inp[2][3]*inp[3][2]*out[1][1]) / D,
		( inp[1][2]*inp[2][3]*out[3][2] - inp[1][2]*inp[3][3]*out[2][2] - inp[1][3]*inp[2][2]*out[3][2] + inp[1][3]*inp[3][2]*out[2][2] + inp[2][2]*inp[3][3]*out[1][2] - inp[2][3]*inp[3][2]*out[1][2]) / D,
		( inp[1][2]*inp[2][3]*out[3][3] - inp[1][2]*inp[3][3]*out[2][3] - inp[1][3]*inp[2][2]*out[3][3] + inp[1][3]*inp[3][2]*out[2][3] + inp[2][2]*inp[3][3]*out[1][3] - inp[2][3]*inp[3][2]*out[1][3]) / D,
		(-inp[1][1]*inp[2][3]*out[3][1] + inp[1][1]*inp[3][3]*out[2][1] + inp[1][3]*inp[2][1]*out[3][1] - inp[1][3]*inp[3][1]*out[2][1] - inp[2][1]*inp[3][3]*out[1][1] + inp[2][3]*inp[3][1]*out[1][1]) / D,
		(-inp[1][1]*inp[2][3]*out[3][2] + inp[1][1]*inp[3][3]*out[2][2] + inp[1][3]*inp[2][1]*out[3][2] - inp[1][3]*inp[3][1]*out[2][2] - inp[2][1]*inp[3][3]*out[1][2] + inp[2][3]*inp[3][1]*out[1][2]) / D,
		(-inp[1][1]*inp[2][3]*out[3][3] + inp[1][1]*inp[3][3]*out[2][3] + inp[1][3]*inp[2][1]*out[3][3] - inp[1][3]*inp[3][1]*out[2][3] - inp[2][1]*inp[3][3]*out[1][3] + inp[2][3]*inp[3][1]*out[1][3]) / D,
		( inp[1][1]*inp[2][2]*out[3][1] - inp[1][1]*inp[3][2]*out[2][1] - inp[1][2]*inp[2][1]*out[3][1] + inp[1][2]*inp[3][1]*out[2][1] + inp[2][1]*inp[3][2]*out[1][1] - inp[2][2]*inp[3][1]*out[1][1]) / D,
		( inp[1][1]*inp[2][2]*out[3][2] - inp[1][1]*inp[3][2]*out[2][2] - inp[1][2]*inp[2][1]*out[3][2] + inp[1][2]*inp[3][1]*out[2][2] + inp[2][1]*inp[3][2]*out[1][2] - inp[2][2]*inp[3][1]*out[1][2]) / D,
		( inp[1][1]*inp[2][2]*out[3][3] - inp[1][1]*inp[3][2]*out[2][3] - inp[1][2]*inp[2][1]*out[3][3] + inp[1][2]*inp[3][1]*out[2][3] + inp[2][1]*inp[3][2]*out[1][3] - inp[2][2]*inp[3][1]*out[1][3]) / D
	)

/**
	The same thing as [proc/color_mapping_matrix] but with 4 mapped colors.
	The first color is used as the origin in the affine transform.
*/
proc/affine_color_mapping_matrix(list/list/inp, list/list/out)
	if(length(inp) != 4 || length(out) != 4)
		CRASH("Incorrect number of colors in the mapping.")
	inp = inp.Copy()
	out = out.Copy()
	var/list/list/inp_inner = list()
	var/list/list/out_inner = list()
	for(var/i in 1 to 4)
		if(istext(inp[i]))
			inp[i] = hex_to_rgb_list(inp[i])
		if(istext(out[i]))
			out[i] = hex_to_rgb_list(out[i])
		if(i > 1) // first color is used at the origin so subtract it from all inputs and outputs
			inp_inner += list(inp[i])
			out_inner += list(out[i])
			for(var/c in 1 to 3)
				inp_inner[length(inp_inner)][c] -= inp[1][c]
				out_inner[length(out_inner)][c] -= out[1][c]
	var/list/result_inner = color_mapping_matrix(inp_inner, out_inner)
	for(var/c in 1 to 3)
		inp[1][c] /= 255
		out[1][c] /= 255
	// the additive term is out[1] - in[1] * M (where M is the linear transform matrix)
	var/list/additive_row = out[1].Copy()
	for(var/row in 1 to 3)
		for(var/c in 1 to 3)
			additive_row[c] -= inp[1][c] * result_inner[(row - 1) * 3 + c]
	return result_inner + additive_row

/**
	Generates a color matrix which performs an approximation of the HSV-space transform.
	Hue is in degrees and is applied additively.
	Saturation is in a 0-1 range and is applied multiplicatively.
	Value is in a 0-1 range and is applied multiplicatively.
*/
proc/hsv_transform_color_matrix(h=0.0, s=1.0, v=1.0)
	// Source: http://beesbuzz.biz/code/16-hsv-color-transforms
	var/vsu = v * s * cos(h)
	var/vsw = v * s * sin(h)
	return list(
		0.299*v + 0.701*vsu + 0.168*vsw,
		0.299*v - 0.299*vsu - 0.328*vsw,
		0.299*v - 0.300*vsu + 1.25*vsw,
		0,
		0.587*v - 0.587*vsu + 0.330*vsw,
		0.587*v + 0.413*vsu + 0.035*vsw,
		0.587*v - 0.588*vsu - 1.05*vsw,
		0,
		0.114*v - 0.114*vsu - 0.497*vsw,
		0.114*v - 0.114*vsu + 0.292*vsw,
		0.114*v + 0.886*vsu - 0.203*vsw,
		0,
		0, 0, 0, 1,
		0, 0, 0, 0
	)

/client/proc/set_saturation(s=1)
	src.saturation_matrix = hsv_transform_color_matrix(1, s, 1)
	src.color = mult_color_matrix(src.color_matrix, src.saturation_matrix)

/client/proc/set_color(matrix=COLOR_MATRIX_IDENTITY)
	src.color_matrix = matrix
	src.color = mult_color_matrix(src.color_matrix, src.saturation_matrix)

/client/proc/animate_color(matrix=COLOR_MATRIX_IDENTITY, time=5, easing=SINE_EASING)
	src.color_matrix = matrix
	matrix = mult_color_matrix(src.color_matrix, src.saturation_matrix)
	animate(src, color=matrix, time=time, easing=easing)
