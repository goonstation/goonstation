#define CURRENT_SPACE_YEAR 2053

//DAY AND NIGHT CYCLES

// m = 127 + cos(BUILD_TIME_HOUR / 12 * (pi * 2) * 127
// Oshan light cycles every 12 hours by suggestion from cogwerks,
// to give people more chances to see different values
// Right now it's just a very simple dark-to-light-to-dark color shift
// in theory we could adjust it as Centcom does to have different colors
// during sunrise/sunset

// #define OCEAN_LIGHT  rgb(0.160 * 255, 0.60 * 255, 1.00 * 255, 0.65 * 255)
#ifdef MAP_OVERRIDE_NADIR
	// nadir has an 8 hour rotation, but is somewhat evenly lit by both shidd and fugg, as it's quite far from typhone (royal rings district)
	// the redness increases as fugg (Fugere) rises, and the blueness (and greenness) increases as Shidd (Šid) rises. Still pretty dark most of the time though.
	// shidd and fugg are on opposite sides of the sky, so as one sets, the other rises.
	// #define OCEAN_LIGHT  rgb(0,0,50)
	#if (BUILD_TIME_HOUR == 0) || (BUILD_TIME_HOUR - 8 == 0) || (BUILD_TIME_HOUR - 16 == 0)
		#define OCEAN_LIGHT  rgb(0.10 * 128, 0.10 * 128, 1.00 *  75, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 1) || (BUILD_TIME_HOUR - 8 == 1) || (BUILD_TIME_HOUR - 16 == 1)
		#define OCEAN_LIGHT  rgb(0.10 *  64, 0.10 * 191, 1.00 *  88, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 2) || (BUILD_TIME_HOUR - 8 == 2) || (BUILD_TIME_HOUR - 16 == 2)
		#define OCEAN_LIGHT  rgb(0.10 *   0, 0.10 * 255, 1.00 * 100, 0.65 * 255) // noon (shidd) rgb(0,26,100), quite bluey
	#elif (BUILD_TIME_HOUR == 3) || (BUILD_TIME_HOUR - 8 == 3) || (BUILD_TIME_HOUR - 16 == 3)
		#define OCEAN_LIGHT  rgb(0.10 *  64, 0.10 * 191, 1.00 *  88, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 4) || (BUILD_TIME_HOUR - 8 == 4) || (BUILD_TIME_HOUR - 16 == 4)
		#define OCEAN_LIGHT  rgb(0.10 * 128, 0.10 * 128, 1.00 *  75, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 5) || (BUILD_TIME_HOUR - 8 == 5) || (BUILD_TIME_HOUR - 16 == 5)
		#define OCEAN_LIGHT  rgb(0.10 * 191, 0.10 *  64, 1.00 *  62, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 6) || (BUILD_TIME_HOUR - 8 == 6) || (BUILD_TIME_HOUR - 16 == 6)
		#define OCEAN_LIGHT  rgb(0.10 * 255, 0.10 *   0, 1.00 *  50, 0.65 * 255) // noon (fugg) rgb(26,0,50), some red tones, more purple
	#elif (BUILD_TIME_HOUR == 7) || (BUILD_TIME_HOUR - 8 == 7) || (BUILD_TIME_HOUR - 16 == 7)
		#define OCEAN_LIGHT  rgb(0.10 * 191, 0.10 *  64, 1.00 *  62, 0.65 * 255)
	#endif
#else // Abzu - oshan (and manta too technically), we're just going to say that fugg has noon exactly at shidd's midnight because we want a nice reddish glow during the night
	#if (BUILD_TIME_HOUR == 0) || (BUILD_TIME_HOUR - 12 == 0) // shidd noon, fugg midnight
		#define OCEAN_LIGHT  rgb(0.160 *   0, 0.60 * 255, 1.00 * 255, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 1) || (BUILD_TIME_HOUR - 12 == 1)
		#define OCEAN_LIGHT  rgb(0.160 *  18, 0.60 * 236, 1.00 * 255, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 2) || (BUILD_TIME_HOUR - 12 == 2)
		#define OCEAN_LIGHT  rgb(0.160 *  63, 0.60 * 187, 1.00 * 236, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 3) || (BUILD_TIME_HOUR - 12 == 3)
		#define OCEAN_LIGHT  rgb(0.160 * 125, 0.60 * 125, 1.00 * 125, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 4) || (BUILD_TIME_HOUR - 12 == 4)
		#define OCEAN_LIGHT  rgb(0.160 * 187, 0.60 *  63, 1.00 *  63, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 5) || (BUILD_TIME_HOUR - 12 == 5)
		#define OCEAN_LIGHT  rgb(0.2   * 236, 0.60 *  18, 1.00 *  18, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 6) || (BUILD_TIME_HOUR - 12 == 6) // shidd mignight, fugg noon
		#define OCEAN_LIGHT  rgb(0.25   * 255, 0.60 * 23, 1.00 *   0, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 7) || (BUILD_TIME_HOUR - 12 == 7)
		#define OCEAN_LIGHT  rgb(0.2   * 236, 0.60 *  18, 1.00 *  18, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 8) || (BUILD_TIME_HOUR - 12 == 8)
		#define OCEAN_LIGHT  rgb(0.160 * 187, 0.60 *  63, 1.00 *  63, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 9) || (BUILD_TIME_HOUR - 12 == 9)
		#define OCEAN_LIGHT  rgb(0.160 * 125, 0.60 * 125, 1.00 * 125, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 10) || (BUILD_TIME_HOUR - 12 == 10)
		#define OCEAN_LIGHT  rgb(0.160 *  63, 0.60 * 187, 1.00 * 236, 0.65 * 255)
	#elif (BUILD_TIME_HOUR == 11) || (BUILD_TIME_HOUR - 12 == 11)
		#define OCEAN_LIGHT  rgb(0.160 *  18, 0.60 * 236, 1.00 * 255, 0.65 * 255)
	#endif
#endif

/// trench has no light cycle! all dark, all the time
#define TRENCH_LIGHT rgb(0.025 * 255, 0.05 * 255, 0.15 * 255, 0.70 * 255)

// TODO: MOVE EARTH LIGHTCYCLE TO THIS SYSTEM
// more like, to-done

// HIGHLY SCIENTIFIC NUMBERS PULLED OUT OF MY ASS
// Loosely based on color temperatures during daylight hours
// and random bullshit for night hours
// would love to have this at runtime but
// i do not think that is possible in a way that isnt shit. maybe. idk

// hi zam here, 2024 edition
// fixed the timezone offset! orz
#if BUILD_TIME_HOUR == 7
	#define CENTCOM_LIGHT  rgb(255 * 0.01, 255 * 0.01, 255 * 0.01)	// night time
#elif BUILD_TIME_HOUR == 8
	#define CENTCOM_LIGHT  rgb(255 * 0.005, 255 * 0.005, 255 * 0.01)	// night time
#elif BUILD_TIME_HOUR == 9
	#define CENTCOM_LIGHT  rgb(255 * 0.00, 255 * 0.00, 255 * 0.005)	// night time
#elif BUILD_TIME_HOUR == 10
	#define CENTCOM_LIGHT  rgb(255 * 0.00, 255 * 0.00, 255 * 0.00)	// night time
#elif BUILD_TIME_HOUR == 11
	#define CENTCOM_LIGHT  rgb(255 * 0.02, 255 * 0.02, 255 * 0.02)	// night time
#elif BUILD_TIME_HOUR == 12
	#define CENTCOM_LIGHT  rgb(255 * 0.05, 255 * 0.05, 255 * 0.05)	// night time
#elif BUILD_TIME_HOUR == 13
	#define CENTCOM_LIGHT  rgb(181 * 0.25, 205 * 0.25, 255 * 0.25)	// 17000
#elif BUILD_TIME_HOUR == 14
	#define CENTCOM_LIGHT  rgb(202 * 0.60, 218 * 0.60, 255 * 0.60)	// 10000
#elif BUILD_TIME_HOUR == 15
	#define CENTCOM_LIGHT  rgb(221 * 0.95, 230 * 0.95, 255 * 0.95)	// 8000 (sunrise)
#elif BUILD_TIME_HOUR == 16
	#define CENTCOM_LIGHT  rgb(210 * 1.00, 223 * 1.00, 255 * 1.00)	// 11000
#elif BUILD_TIME_HOUR == 17
	#define CENTCOM_LIGHT  rgb(196 * 1.00, 214 * 1.00, 255 * 1.00)	// 10000
#elif BUILD_TIME_HOUR == 18
	#define CENTCOM_LIGHT  rgb(221 * 1.00, 230 * 1.00, 255 * 1.00)	// 8000
#elif BUILD_TIME_HOUR == 19
	#define CENTCOM_LIGHT  rgb(230 * 1.00, 235 * 1.00, 255 * 1.00)	// 7500-ish
#elif BUILD_TIME_HOUR == 20
	#define CENTCOM_LIGHT  rgb(243 * 1.00, 242 * 1.00, 255 * 1.00)	// 7000
#elif BUILD_TIME_HOUR == 21
	#define CENTCOM_LIGHT  rgb(255 * 1.00, 250 * 1.00, 244 * 1.00)	// 6250-ish
#elif BUILD_TIME_HOUR == 22
	#define CENTCOM_LIGHT  rgb(255 * 1.00, 243 * 1.00, 231 * 1.00)	// 5800-ish
#elif BUILD_TIME_HOUR == 23
	#define CENTCOM_LIGHT  rgb(255 * 1.00, 232 * 1.00, 213 * 1.00)	// 5200-ish
#elif BUILD_TIME_HOUR == 0
	#define CENTCOM_LIGHT  rgb(255 * 0.95, 206 * 0.95, 166 * 0.95)	// 4000
#elif BUILD_TIME_HOUR == 1
	#define CENTCOM_LIGHT  rgb(255 * 0.90, 146 * 0.90,  39 * 0.90)	// 2200 (sunset), "golden hour"
#elif BUILD_TIME_HOUR == 2
	#define CENTCOM_LIGHT  rgb(196 * 0.50, 214 * 0.50, 255 * 0.50)	// 10000
#elif BUILD_TIME_HOUR == 3
	#define CENTCOM_LIGHT  rgb(191 * 0.21, 211 * 0.20, 255 * 0.30)	// 12000 (moon / stars), "blue hour"
#elif BUILD_TIME_HOUR == 4
	#define CENTCOM_LIGHT  rgb(218 * 0.10, 228 * 0.10, 255 * 0.13)	// 8250
#elif BUILD_TIME_HOUR == 5
	#define CENTCOM_LIGHT  rgb(221 * 0.04, 230 * 0.04, 255 * 0.05)	// 8000
#elif BUILD_TIME_HOUR == 6
	#define CENTCOM_LIGHT  rgb(243 * 0.01, 242 * 0.01, 255 * 0.02)	// 7000
#else
	#define CENTCOM_LIGHT  rgb(255 * 1.00, 255 * 1.00, 255 * 1.00)	// uhhhhhh
#endif
