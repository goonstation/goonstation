#define CURRENT_SPACE_YEAR 2053

//DAY AND NIGHT CYCLES

// m = 127 + cos(BUILD_TIME_HOUR / 12 * (pi * 2) * 127
// Oshan light cycles every 12 hours by suggestion from cogwerks,
// to give people more chances to see different values
// Right now it's just a very simple dark-to-light-to-dark color shift
// in theory we could adjust it as Centcom does to have different colors
// during sunrise/sunset

// #define OCEAN_LIGHT  rgb(0.160 * 255, 0.60 * 255, 1.00 * 255, 0.65 * 255)
#if defined(MAP_OVERRIDE_NADIR)
	#define OCEAN_LIGHT  rgb(0,0,50)
#elif (BUILD_TIME_HOUR == 0) || (BUILD_TIME_HOUR - 12 == 0)
	#define OCEAN_LIGHT  rgb(0.160 *   0, 0.60 *   0, 1.00 *   0, 0.65 * 255)
#elif (BUILD_TIME_HOUR == 1) || (BUILD_TIME_HOUR - 12 == 1)
	#define OCEAN_LIGHT  rgb(0.160 *  18, 0.60 *  18, 1.00 *  18, 0.65 * 255)
#elif (BUILD_TIME_HOUR == 2) || (BUILD_TIME_HOUR - 12 == 2)
	#define OCEAN_LIGHT  rgb(0.160 *  63, 0.60 *  63, 1.00 *  63, 0.65 * 255)
#elif (BUILD_TIME_HOUR == 3) || (BUILD_TIME_HOUR - 12 == 3)
	#define OCEAN_LIGHT  rgb(0.160 * 125, 0.60 * 125, 1.00 * 125, 0.65 * 255)
#elif (BUILD_TIME_HOUR == 4) || (BUILD_TIME_HOUR - 12 == 4)
	#define OCEAN_LIGHT  rgb(0.160 * 187, 0.60 * 187, 1.00 * 187, 0.65 * 255)
#elif (BUILD_TIME_HOUR == 5) || (BUILD_TIME_HOUR - 12 == 5)
	#define OCEAN_LIGHT  rgb(0.160 * 236, 0.60 * 236, 1.00 * 236, 0.65 * 255)
#elif (BUILD_TIME_HOUR == 6) || (BUILD_TIME_HOUR - 12 == 6)
	#define OCEAN_LIGHT  rgb(0.160 * 255, 0.60 * 255, 1.00 * 255, 0.65 * 255)
#elif (BUILD_TIME_HOUR == 7) || (BUILD_TIME_HOUR - 12 == 7)
	#define OCEAN_LIGHT  rgb(0.160 * 236, 0.60 * 236, 1.00 * 236, 0.65 * 255)
#elif (BUILD_TIME_HOUR == 8) || (BUILD_TIME_HOUR - 12 == 8)
	#define OCEAN_LIGHT  rgb(0.160 * 187, 0.60 * 187, 1.00 * 187, 0.65 * 255)
#elif (BUILD_TIME_HOUR == 9) || (BUILD_TIME_HOUR - 12 == 9)
	#define OCEAN_LIGHT  rgb(0.160 * 125, 0.60 * 125, 1.00 * 125, 0.65 * 255)
#elif (BUILD_TIME_HOUR == 10) || (BUILD_TIME_HOUR - 12 == 10)
	#define OCEAN_LIGHT  rgb(0.160 *  63, 0.60 *  63, 1.00 *  63, 0.65 * 255)
#elif (BUILD_TIME_HOUR == 11) || (BUILD_TIME_HOUR - 12 == 11)
	#define OCEAN_LIGHT  rgb(0.160 *  18, 0.60 *  18, 1.00 *  18, 0.65 * 255)
#endif

/// trench has no light cycle! all dark, all the time
#define TRENCH_LIGHT rgb(0.025 * 255, 0.05 * 255, 0.15 * 255, 0.70 * 255)

//TODO: MOVE EARTH LIGHTCYCLE TO THIS SYSTEM
