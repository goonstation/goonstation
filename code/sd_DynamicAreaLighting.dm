
var/sd_light_layer = TILE_EFFECT_OVERLAY_LAYER_LIGHTING		// graphics layer for light effect
var/sd_defer_updates = 1

var/list/sd_ToUpdate = list(list())
var/list/sd_Updating

#define LIGHT_LOWER 0.1
#define CONSTANT_FALLOFF 2
#define MAX_LUMINOSITY 8
#define UPDATE_BIN_SIZE 50

// This is a shitty fudge factor that determines how the brightness of the light is translated to gaussian amplitude.
#define BRIGHTNESS_GAUSSIAN_AMPLITUDE_FACTOR 0.05

proc/sd_Update()
	if (sd_defer_updates)
		return
	sd_ProcessUpdateQueue()

proc/sd_ProcessUpdateQueue()
	set background = 1

	var/list/l
	sd_Updating = sd_ToUpdate
	sd_ToUpdate = list(list())
	while (sd_Updating.len > 0)
		// fuck you, imma cut you
		l = sd_Updating[sd_Updating.len]
		sd_Updating.len--
		if(!l)
			break
		for(var/i = 1,i <= l.len,i++)
			var/turf/Affected = l[i]
			if (!istype(Affected))
				continue
			Affected.sd_LumUpdate()
		// Shh, take a nap, lil shithead
		if(sd_Updating.len > 0)
			sleep(-1)

proc/sd_toUpdate(var/T)
	// Get last bin
	if(sd_ToUpdate.len == 0)
		// If the shit is empty
		sd_ToUpdate.len++
		sd_ToUpdate[sd_ToUpdate.len] = list()
	var/list/l = sd_ToUpdate[sd_ToUpdate.len]
	if(l.len >= UPDATE_BIN_SIZE)
		// If last bin is full, make a new one, yeah mmf take it
		l = new
		sd_ToUpdate.len++
		sd_ToUpdate[sd_ToUpdate.len] = l

	// add that bad motherfuckin bitch
	if(istype(T, /turf))
		l.Add(T)
	else if(islist(T))
		// If its a list, just toss it in, fuck it
		sd_ToUpdate.len++
		sd_ToUpdate[sd_ToUpdate.len] = T

atom
	disposing()
		// if this is luminous (Areas will just return without doing anything)
		if(luminosity > 0)
			sd_StripLum(1)
			luminosity = 0
		..()

	var/sd_ColorRed = 1
	var/sd_ColorGreen = 1
	var/sd_ColorBlue = 1
	var/sd_Brightness = 0
	var/sd_Height = 1 // How high is the light above the floor?
	// Higher spread means the light goes farther before tapering off
	// A spread of less than 1 makes a really focused light.
	var/list/turf/sd_AppliedTiles = null
	var/atom/sd_Center

	proc/sd_Intensity(var/turf/T, var/turf/measureLoc, whine)
		//1 / sqrt((get_dist(T, measureLoc) ** 2 / sd_Height ** 2) + 1) == cos(arctan(dist/sd_Height))
		// This is basically the Oren-Nayar reflectance model, with a hack to say lights are sd_Height meters above the floor and the reflectance of the object is actually the brightness value of the light. don't ask. It's cheaper than the old thing.
		var/heightTerm = 1 / sqrt((squaredDistance(T, measureLoc) / sd_Height ** 2) + 1)
		if(whine)
			boutput(world, heightTerm)
		//intensity = max(0, (rho / pi) * C * Irradiance(1))
		return max(0, (( sd_Brightness * 1.8 ) / 3.14159) * heightTerm * (1 - (sd_Brightness / (10 + sd_Brightness))))

	/**
	 * Strips luminosity data
	 * param updateMode: 0 = defer update, > 0 = update immediately
	 */
	proc/sd_ApplyLum(updateMode = 0)
		if (isarea(src) || luminosity <= 0)
			return
		if (sd_AppliedTiles)
			CRASH("sd_ApplyLum called without stripping first")
		sd_Center = src.loc
		if (!isturf(sd_Center))
			return

		sd_AppliedTiles = list()
		for(var/turf/T in view(min(20, luminosity), sd_Center))
			var/intensity = sd_Intensity(T, src.loc)
			T.sd_TotalRed   += sd_ColorRed * intensity
			T.sd_TotalGreen += sd_ColorGreen * intensity
			T.sd_TotalBlue  += sd_ColorBlue * intensity
			sd_AppliedTiles += T

		if(sd_defer_updates || updateMode == 0)
			sd_toUpdate(sd_AppliedTiles)
		else
			for(var/turf/T in sd_AppliedTiles)
				T.sd_LumUpdate()

		//boutput(world, "[src] applying luminosity - applied [appliedCount], ignored [ignoredCount]")
	/**
	 * Strips luminosity data
	 * param updateMode: 0 = defer update, > 0 = update immediately
	 */
	proc/sd_StripLum(updateMode = 0)
		if (isarea(src) || !luminosity)
			return
		for(var/turf/T in sd_AppliedTiles)
			var/intensity = sd_Intensity(T, sd_Center)
			T.sd_TotalRed   = max(T.sd_TotalRed - sd_ColorRed * intensity, 0) // due to the magic of floating point, these tend to go ever so slightly below zero
			T.sd_TotalGreen = max(T.sd_TotalGreen - sd_ColorGreen * intensity, 0)
			T.sd_TotalBlue  = max(T.sd_TotalBlue - sd_ColorBlue * intensity, 0)

		if(sd_defer_updates || updateMode == 0)
			sd_toUpdate(sd_AppliedTiles)
		else
			for(var/turf/T in sd_AppliedTiles)
				T.sd_LumUpdate()
		sd_AppliedTiles = null

		//boutput(world, "[src] stripping luminosity - stripped [strippedCount], ignored [ignoredCount]")

	proc/sd_ApplyLocalLum(list/affected = view(MAX_LUMINOSITY, src))
		// Reapplies the lighting effect of all atoms in affected.
		for(var/atom/A in affected)
			if(A.luminosity) A.sd_ApplyLum()

	proc/sd_StripLocalLum()
		/*	strips all local luminosity

			RETURNS: list of all the luminous atoms stripped

			IMPORTANT! Each sd_StripLocalLum() call should have a matching
				sd_ApplyLocalLum() to restore the local effect. */
		. = list()
		for(var/atom/A in view(MAX_LUMINOSITY, src))
			if(A.luminosity)
				A.sd_StripLum()
				. += A

	proc/sd_SetLuminosity(new_luminosity)
		sd_SetBrightness(new_luminosity / 2.5)

	proc/sd_ReduceLuminosity(change)
		change = min(ceil(sqrt((change / 2.5) - CONSTANT_FALLOFF*LIGHT_LOWER) / sqrt(LIGHT_LOWER)) + 1, MAX_LUMINOSITY)
		sd_SetBrightness(luminosity - change)

	proc/sd_SetBrightness(new_brightness)
		if (sd_Brightness == new_brightness)
			return

		if(luminosity)
			sd_StripLum(1)
		sd_Brightness = new_brightness
		// dont ask
		if (new_brightness < CONSTANT_FALLOFF*LIGHT_LOWER)
			luminosity = 0
		else
			luminosity = min(ceil(sqrt(new_brightness - CONSTANT_FALLOFF*LIGHT_LOWER) / sqrt(LIGHT_LOWER)) + 1, MAX_LUMINOSITY)
		if(luminosity)
			sd_ApplyLum(1)

	proc/sd_SetColor(r as num, g as num, b as num)
		if(luminosity)
			sd_StripLum(1)
		sd_ColorRed = r
		sd_ColorGreen = g
		sd_ColorBlue = b
		if(luminosity)
			sd_ApplyLum(1)

turf
	var/tmp/sd_TotalRed = 0
	var/tmp/sd_TotalGreen = 0
	var/tmp/sd_TotalBlue = 0
	var/tmp/sd_LastRedAdditiveApplied = 0
	var/tmp/sd_LastGreenAdditiveApplied = 0
	var/tmp/sd_LastBlueAdditiveApplied = 0

//	disposing()
//		sd_StripEffectOverlayLighting()
//		sd_StripAdditiveEffectOverlay()
//		..()

	proc/sd_LumReset()
		var/list/affected = sd_StripLocalLum()

		sd_ApplyLocalLum(affected)

	proc/sd_LumUpdate()
		var/area/Loc = loc
		return

		if(fullbright)
			sd_StripEffectOverlayLighting()
			sd_StripAdditiveEffectOverlay()
			return

		var r, g, b
		if(max(sd_TotalRed, sd_TotalGreen, sd_TotalBlue) < 0.149)
			r = sd_TotalRed + 0.141 // AMBIENT COLOR = a nice cool extremely dark gray
			g = sd_TotalGreen + 0.141
			b = sd_TotalBlue + 0.149
		else
			r = sd_TotalRed
			g = sd_TotalGreen
			b = sd_TotalBlue

		// get magnitude of RGB
		// Normalize RGB values to preserve color, get coefficient of normalization to determine if we need to use additive.
		var/nRGB = normalizeRGB(r,g,b)
		r = nRGB[1]
		g = nRGB[2]
		b = nRGB[3]

		if (src.density > 0) // If it is a wall... set its color to the average of the three color components - maybe we should add just a teensy weensy bit of color?
			var/a = (r + g + b) / 3
			r = a
			g = a
			b = a

		//If the RGB color was normalized down by a factor of 2 or more, we will calculate an additive effect... because fudge factor and math.
		if(nRGB[4] > 2)
			var/additiveDelta = abs(r - sd_LastRedAdditiveApplied) + abs(g - sd_LastGreenAdditiveApplied) + abs(b - sd_LastBlueAdditiveApplied)

			if(additiveDelta > 0.05)
				//recalculate additive effect
				sd_LastRedAdditiveApplied = r
				sd_LastGreenAdditiveApplied = g
				sd_LastBlueAdditiveApplied = b

				var/hsv = rgb2hsv(nRGB)
				//hsv[2] = 0.75 // Set saturation to 75%
				hsv[3] = min(0.5, hsv[3]) // Set value to 50% or less
				var/_rgb = hsv2rgb(hsv)
				if (!src.effect_overlay_additive)
					src.effect_overlay_additive = new /obj/overlay/tile_effect
					src.effect_overlay_additive.set_loc(src)
					src.effect_overlay_additive.blend_mode = BLEND_ADD
					// Maybe scale this based on nRGB[4] (coefficient)
					src.effect_overlay_additive.alpha = 60
				src.effect_overlay_additive.color = rgb(_rgb[1], _rgb[2], _rgb[3])
		else if(src.effect_overlay_additive) //If there's no additive remainder, pool the effect
			sd_LastRedAdditiveApplied = 0
			sd_LastGreenAdditiveApplied = 0
			sd_LastBlueAdditiveApplied = 0
			qdel(src.effect_overlay_additive)
			src.effect_overlay_additive.set_loc(null)
			src.effect_overlay_additive.alpha = 255
			src.effect_overlay_additive = null

		sd_lumcount = (sd_TotalRed + sd_TotalGreen + sd_TotalBlue) * 2.5 // Hack for old code that accessed sd_lumcount directly to work
		//Apply color on the Multiplicative blend overlay I WISH BYOND HAD 2X MULTIPLICATIVE BLENDING WTF LUMMUX_BITCHFACE
		if (!src.effect_overlay)
			src.effect_overlay = new /obj/overlay/tile_effect
			src.effect_overlay.set_loc(src)
			src.effect_overlay.blend_mode = BLEND_MULTIPLY
		src.effect_overlay.color = rgb(min(255, r * 255), min(255, g * 255), min(255, b * 255))

		for (var/obj/overlay/tile_effect/secondary/S in src)
			S.color = src.effect_overlay.color

	proc/sd_StripEffectOverlayLighting()
		if(effect_overlay)
			qdel(src.effect_overlay)
			src.effect_overlay.set_loc(null)
			src.effect_overlay = null

	proc/sd_StripAdditiveEffectOverlay()
		if(effect_overlay_additive)
			qdel(src.effect_overlay_additive)
			src.effect_overlay_additive.set_loc(null)
			src.effect_overlay_additive = null

turf/space
	luminosity = 1

atom/movable/Move() // when something moves
	var/turf/oldloc = loc	// remember for range calculations
	. = ..()

	if(loc != oldloc && isturf(loc) && luminosity)	// if the atom actually moved
		sd_StripLum(1)
		sd_ApplyLum(1)

proc/hsv2rgb(var/list/HSV)
	if (HSV[2] == 0)
		var c = HSV[3] * 255
		return list(c,c,c)

	var/h = HSV[1] * 6

	if (h == 6)
		h = 0

	var/i = round(h)

	var/v1 = HSV[3] * (1 - HSV[2])
	var/v2 = HSV[3] * (1 - HSV[2] * (h - i))
	var/v3 = HSV[3] * (1 - HSV[2] * (1 - (h - i)))

	var/r
	var/g
	var/b

	if (i == 0)
		r = HSV[3]
		g = v3
		b = v1
	else if (i == 1)
		r = v2
		g = HSV[3]
		b = v1
	else if (i == 2)
		r = v1
		g = HSV[3]
		b = v3
	else if (i == 3)
		r = v1
		g = v2
		b = HSV[3]
	else if (i == 4)
		r = v3
		g = v1
		b = HSV[3]
	else // i = 5
		r = HSV[3]
		g = v1
		b = v2

	return list(r * 255, g * 255, b * 255)

proc/rgb2hsv(var/list/RGB)
	var/r = RGB[1]/255
	var/g = RGB[2]/255
	var/b = RGB[3]/255
	var/mx = max(r,g,b)
	var/mn = min(r,g,b)
	var/dmxmn = mx - mn

	var/V = mx
	var/H
	var/S
	if(dmxmn == 0 || V == 0)
		H = 0
		S = 0
	else
		S = dmxmn / mx

		var/dr = ( ( ( mx - r ) / 6 ) + ( dmxmn / 2 ) ) / dmxmn
		var/dg = ( ( ( mx - g ) / 6 ) + ( dmxmn / 2 ) ) / dmxmn
		var/db = ( ( ( mx - b ) / 6 ) + ( dmxmn / 2 ) ) / dmxmn

		if       ( r == mx ) H = db - dg
		else if  ( g == mx ) H = ( 1 / 3 ) + dr - db
		else if  ( b == mx ) H = ( 2 / 3 ) + dg - dr

		if ( H < 0 ) H += 1
		if ( H > 1 ) H -= 1

	return list(H,S,V)

proc/normalizeRGB(var/r, var/g, var/b)
	var/coefficient = max(r / 255, g / 255, b / 255)
	if(coefficient > 1)
		return list(round(r / coefficient), round(g / coefficient), round(b / coefficient), coefficient)
	return list(r, g, b, coefficient)

proc/distance(var/turf/A, var/turf/B)
	return sqrt((A.x - B.x)**2 + (A.y - B.y)**2)

proc/squaredDistance(var/turf/A, var/turf/B)
	return (A.x - B.x)**2 + (A.y - B.y)**2
