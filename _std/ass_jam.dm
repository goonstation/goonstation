#if ASS_JAM

#define ADD_MORTY(X, Y, WIDTH, HEIGHT) \
	var/image/morty = image('icons/misc/critter.dmi', "possum"); \
	/*morty.appearance_flags = PIXEL_SCALE;*/ \
	var/matrix/mortrix = matrix(); \
	mortrix.Scale(WIDTH / 32, HEIGHT / 32); \
	mortrix.Translate(-(16 - WIDTH / 2) + X, -(16 - HEIGHT / 2) + Y); \
	morty.transform = mortrix; \
	src.UpdateOverlays(morty, "morty")

#endif
