/// returns the length of a hud zone, and returns 1 instead of 0 if its only 1 wide
#define HUD_ZONE_LENGTH(coords) ((coords["x_high"] - coords["x_low"]) != 0 ? (coords["x_high"] - coords["x_low"]) : 1)

/// returns the height of a hud zone, and returns 1 instead of 0 if its only 1 wide
#define HUD_ZONE_HEIGHT(coords) ((coords["y_high"] - coords["y_low"]) != 0 ? (coords["y_high"] - coords["y_low"]) : 1)

/// returns the area of a hud zone (total amount of 32x32 tiles in the hud zone)
#define HUD_ZONE_AREA(coords) ((HUD_ZONE_LENGTH(coords)) * (HUD_ZONE_HEIGHT(coords)))
