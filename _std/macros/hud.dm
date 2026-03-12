/*
	Careful with the lower two defines, because
	screen_loc is zero-indexed, unlike the rest of DM.
	It's G R E A T.
*/

/// Returns a stringified number with its associated +/- sign.
#define SIGNED_NUM_STRING(NUM) (NUM >= 0 ? "+[NUM]" : "[NUM]")

/// returns the length of a hud zone, adds 1 because these are coordinates of a cell in a grid, and not a corner of a cell in a grid
#define HUD_ZONE_LENGTH(coords) (abs(coords["x_high"] - coords["x_low"]) + 1)

/// returns the height of a hud zone, adds 1 because these are coordinates of a cell in a grid, and not a corner of a cell in a grid
#define HUD_ZONE_HEIGHT(coords) (abs(coords["y_high"] - coords["y_low"]) + 1)

/// returns the area of a hud zone (total amount of 32px x 32px tiles in the hud zone)
#define HUD_ZONE_AREA(coords) ((HUD_ZONE_LENGTH(coords)) * (HUD_ZONE_HEIGHT(coords)))

// hudzone return status codes

/// The hudzone still has horizontal space available
#define HUD_ZONE_EMPTY 1
/// The hudzone wrapped around to a new vertical layer
#define HUD_ZONE_WRAPAROUND 2
/// The hudzone is completely full of elements
#define HUD_ZONE_FULL -1
