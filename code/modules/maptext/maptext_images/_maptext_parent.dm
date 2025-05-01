/**
 *	Maptext images are special subtypes of images without an icon with the sole purpose of displaying maptext to a single client.
 *	As a result of being an image, each subtype requires a special constructor proc in lieu of `New()`; this is a result of BYOND
 *	treating an argument passed to an image's `New()` as an argument for `image()`. This has been clarified by Lummox as intended
 *	behaviour.
 */
/image/maptext
	icon = null
	appearance_flags = PIXEL_SCALE
	plane = PLANE_HUD
	layer = HUD_LAYER_UNDER_1
	alpha = 255
	maptext_x = -64
	maptext_y = 34
	maptext_width = 160
	maptext_height = 48
	/// Whether this maptext image should respect the client's flying chat preferences.
	var/respect_maptext_preferences = TRUE

/**
 *	The parameters to `/image/New()` are defined internally by BYOND, which means that image subtypes cannot define their own
 *	`New()` parameters. This necessitates an `init()` proc if arguments are to be passed during instantiation.
 */
/image/maptext/proc/init()
	RETURN_TYPE(/image/maptext)
	SHOULD_CALL_PARENT(TRUE)
	return src
