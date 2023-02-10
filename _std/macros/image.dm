#define ENSURE_IMAGE(x, y, z) if(!x) x = image(icon = y, icon_state = z); else x.icon_state = z

/image
	appearance_flags = PIXEL_SCALE

/image/disposing()
	src.loc = null
	..()
