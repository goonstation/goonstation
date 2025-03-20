
// TODO readd counters for debugging
#define RL_UPDATE_LIGHT(src) do { \
	if (src.fullbright || src.loc?:force_fullbright) { break } \
	var/turf/_N = get_step(src, NORTH) || src; \
	var/turf/_E = get_step(src, EAST) || src; \
	var/turf/_NE = get_step(src, NORTHEAST) || src; \
	src.RL_MulOverlay?.color = list( \
		src.RL_LumR, src.RL_LumG, src.RL_LumB, 0, \
		_E.RL_LumR, _E.RL_LumG, _E.RL_LumB, 0, \
		_N.RL_LumR, _N.RL_LumG, _N.RL_LumB, 0, \
		_NE.RL_LumR, _NE.RL_LumG, _NE.RL_LumB, 0, \
		DLL, DLL, DLL, 1 \
		) ; \
	if (src.RL_NeedsAdditive || _E.RL_NeedsAdditive || _N.RL_NeedsAdditive || _NE.RL_NeedsAdditive) { \
		if(!src.RL_AddOverlay) { \
			src.RL_AddOverlay = new /atom/movable/light/robust_light/add(src) ; \
			src.RL_AddOverlay.icon = src.RL_OverlayIcon ; \
			src.RL_AddOverlay.icon_state = src.RL_OverlayState ; \
		} \
		src.RL_AddOverlay.color = list( \
			src.RL_AddLumR, src.RL_AddLumG, src.RL_AddLumB, 0, \
			_E.RL_AddLumR, _E.RL_AddLumG, _E.RL_AddLumB, 0, \
			_N.RL_AddLumR, _N.RL_AddLumG, _N.RL_AddLumB, 0, \
			_NE.RL_AddLumR, _NE.RL_AddLumG, _NE.RL_AddLumB, 0, \
			0, 0, 0, 1) ; \
	} else { if(src.RL_AddOverlay) { qdel(src.RL_AddOverlay); src.RL_AddOverlay = null; } } \
	} while(FALSE)


// requires atten to be defined outside
// consider: caching atten below, precomputed
#define RL_APPLY_LIGHT_EXPOSED_ATTEN(src, lx, ly, brightness, height2, r, g, b) do { \
	if (src.loc?:force_fullbright) { break } \
	atten = (brightness*RL_Atten_Quadratic) / ((src.x - lx)**2 + (src.y - ly)**2 + height2) + RL_Atten_Constant ; \
	if (atten < RL_Atten_Threshold) { break } \
	src.RL_LumR += r*atten ; \
	src.RL_LumG += g*atten ; \
	src.RL_LumB += b*atten ; \
	src.RL_AddLumR = clamp((src.RL_LumR - 1) * 0.5, 0, 0.3) ; \
	src.RL_AddLumG = clamp((src.RL_LumG - 1) * 0.5, 0, 0.3) ; \
	src.RL_AddLumB = clamp((src.RL_LumB - 1) * 0.5, 0, 0.3) ; \
	src.RL_NeedsAdditive = src.RL_AddLumR + src.RL_AddLumG + src.RL_AddLumB ; \
	} while(FALSE)

#define RL_APPLY_LIGHT(src, lx, ly, brightness, height2, r, g, b) do { \
	var/atten ; \
	 RL_APPLY_LIGHT_EXPOSED_ATTEN(src, lx, ly, brightness, height2, r, g, b) ; \
	} while(FALSE)

#define RL_APPLY_LIGHT_LINE(src, lx, ly, dir, radius, brightness, height2, r, g, b) do { \
	if (src.loc?:force_fullbright) { break } \
	var/atten = (brightness*RL_Atten_Quadratic) / ((src.x - lx)**2 + (src.y - ly)**2 + height2) + RL_Atten_Constant ; \
	var/exponent = 3.5 ;\
	atten *= (max( abs(ly-src.y),abs(lx-src.x),0.85 )/radius)**exponent ;\
	if (radius <= 1) { atten *= 0.1 }\
	else if (radius <= 2) { atten *= 0.5 }\
	else if (radius == 3) { atten *= 0.8 }\
	else{\
		var/mult_atten = 1;\
		var/line_len = (abs(src.x - lx)+abs(src.y - ly));\
		if (line_len <= 1.1) { mult_atten = 4.6 } \
		else if (line_len<=1.5) { mult_atten = 3 } \
		else if (line_len<=2.5) { mult_atten = 2 } \
		switch(dir){ \
			if (NORTH){ if (round(ly) - src.y < 0){ atten *= mult_atten } }\
			if (WEST){ if (ceil(lx) - src.x > 0){ atten *= mult_atten } }\
			if (EAST){ if (round(lx) - src.x < 0){ atten *= mult_atten } }\
			if (SOUTH){ if (ceil(ly) - src.y > 0){ atten *= mult_atten } }\
		}\
		if (round(line_len) >= radius) { atten *= 0.4 } \
	}\
	if (atten < RL_Atten_Threshold) { break } \
	src.RL_LumR += r*atten ; \
	src.RL_LumG += g*atten ; \
	src.RL_LumB += b*atten ; \
	src.RL_AddLumR = clamp((src.RL_LumR - 1) * 0.5, 0, 0.3) ; \
	src.RL_AddLumG = clamp((src.RL_LumG - 1) * 0.5, 0, 0.3) ; \
	src.RL_AddLumB = clamp((src.RL_LumB - 1) * 0.5, 0, 0.3) ; \
	src.RL_NeedsAdditive = src.RL_AddLumR + src.RL_AddLumG + src.RL_AddLumB ; \
	} while(FALSE)

#define APPLY_AND_UPDATE if (RL_Started) { for (var/turf/T as anything in src.apply()) { RL_UPDATE_LIGHT(T) } }

#define RL_Atten_Quadratic 2.2 // basically just brightness scaling atm
#define RL_Atten_Constant -0.11 // constant subtracted at every point to make sure it goes <0 after some distance
#define RL_Atten_Threshold 2/256 // imperceptible change
#define RL_Rad_QuadConstant 0.9 //Subtracted from the quadratic constant for light.radius
#define RL_Rad_ConstConstant 0.03 //Added to the -linear constant for light.radius
#define RL_MaxRadius 6 // maximum allowed light.radius value. if any light ends up needing more than this it'll cap and look screwy
#define DLL 0 //Darkness Lower Limit, at 0 things can get absolutely pitch black.

#ifdef UPSCALED_MAP
#undef DLL
#define DLL 0.2
#endif
