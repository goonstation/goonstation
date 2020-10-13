/**
Centcom / Earth Stuff
Contents:
	Areas:
		Main Area
		Outside
		Offices
		Lobby
		Lounge
		Garden
		Power Supply

	Turfs: Outside Concrete & Grass
**/

var/global/Z4_ACTIVE = 0 //Used for mob processing purposes

/area/centcom
	name = "Centcom"
	icon_state = "purple"
	requires_power = 0
	sound_environment = 4
	teleport_blocked = 1
	skip_sims = 1
	sims_score = 25
	sound_group = "centcom"
	filler_turf = "/turf/unsimulated/nicegrass/random"
	is_centcom = 1

/area/centcom/outside
	name = "Earth"
	icon_state = "nothing_earth"
	//force_fullbright = 1

// HIGHLY SCIENTIFIC NUMBERS PULLED OUT OF MY ASS
// Loosely based on color temperatures during daylight hours
// and random bullshit for night hours
// would love to have this at runtime but
// i do not think that is possible in a way that isnt shit. maybe. idk
#if BUILD_TIME_HOUR == 0
	ambient_light = rgb(255 * 0.01, 255 * 0.01, 255 * 0.01)	// night time
#elif BUILD_TIME_HOUR == 1
	ambient_light = rgb(255 * 0.005, 255 * 0.005, 255 * 0.01)	// night time
#elif BUILD_TIME_HOUR == 2
	ambient_light = rgb(255 * 0.00, 255 * 0.00, 255 * 0.005)	// night time
#elif BUILD_TIME_HOUR == 3
	ambient_light = rgb(255 * 0.00, 255 * 0.00, 255 * 0.00)	// night time
#elif BUILD_TIME_HOUR == 4
	ambient_light = rgb(255 * 0.02, 255 * 0.02, 255 * 0.02)	// night time
#elif BUILD_TIME_HOUR == 5
	ambient_light = rgb(255 * 0.05, 255 * 0.05, 255 * 0.05)	// night time
#elif BUILD_TIME_HOUR == 6
	ambient_light = rgb(181 * 0.25, 205 * 0.25, 255 * 0.25)	// 17000
#elif BUILD_TIME_HOUR == 7
	ambient_light = rgb(202 * 0.60, 218 * 0.60, 255 * 0.60)	// 10000
#elif BUILD_TIME_HOUR == 8
	ambient_light = rgb(221 * 0.95, 230 * 0.95, 255 * 0.95)	// 8000 (sunrise)
#elif BUILD_TIME_HOUR == 9
	ambient_light = rgb(210 * 1.00, 223 * 1.00, 255 * 1.00)	// 11000
#elif BUILD_TIME_HOUR == 10
	ambient_light = rgb(196 * 1.00, 214 * 1.00, 255 * 1.00)	// 10000
#elif BUILD_TIME_HOUR == 11
	ambient_light = rgb(221 * 1.00, 230 * 1.00, 255 * 1.00)	// 8000
#elif BUILD_TIME_HOUR == 12
	ambient_light = rgb(230 * 1.00, 235 * 1.00, 255 * 1.00)	// 7500-ish
#elif BUILD_TIME_HOUR == 13
	ambient_light = rgb(243 * 1.00, 242 * 1.00, 255 * 1.00)	// 7000
#elif BUILD_TIME_HOUR == 14
	ambient_light = rgb(255 * 1.00, 250 * 1.00, 244 * 1.00)	// 6250-ish
#elif BUILD_TIME_HOUR == 15
	ambient_light = rgb(255 * 1.00, 243 * 1.00, 231 * 1.00)	// 5800-ish
#elif BUILD_TIME_HOUR == 16
	ambient_light = rgb(255 * 1.00, 232 * 1.00, 213 * 1.00)	// 5200-ish
#elif BUILD_TIME_HOUR == 17
	ambient_light = rgb(255 * 0.95, 206 * 0.95, 166 * 0.95)	// 4000
#elif BUILD_TIME_HOUR == 18
	ambient_light = rgb(255 * 0.90, 146 * 0.90,  39 * 0.90)	// 2200 (sunset), "golden hour"
#elif BUILD_TIME_HOUR == 19
	ambient_light = rgb(196 * 0.50, 214 * 0.50, 255 * 0.50)	// 10000
#elif BUILD_TIME_HOUR == 20
	ambient_light = rgb(191 * 0.21, 211 * 0.20, 255 * 0.30)	// 12000 (moon / stars), "blue hour"
#elif BUILD_TIME_HOUR == 21
	ambient_light = rgb(218 * 0.10, 228 * 0.10, 255 * 0.13)	// 8250
#elif BUILD_TIME_HOUR == 22
	ambient_light = rgb(221 * 0.04, 230 * 0.04, 255 * 0.05)	// 8000
#elif BUILD_TIME_HOUR == 23
	ambient_light = rgb(243 * 0.01, 242 * 0.01, 255 * 0.02)	// 7000
#else
	ambient_light = rgb(255 * 1.00, 255 * 1.00, 255 * 1.00)	// uhhhhhh
#endif



/area/centcom/offices
	name = "NT Offices"
	icon_state = "red"
	var/ckey = ""


	a69
		ckey = ""
		name = "Office of Dixon Balls"
	aibm
		ckey = "angriestibm"
		name = "Office of AngriestIBM"
	aphtonites
		ckey = ""
		name = "Office of Aphtonites"
	atomicthumbs
		ckey = ""
		name = "Office of Atomicthumbs"
	bubs
		ckey = "insanoblan"
		name = "Office of bubs"
	burntcornmuffin
		ckey = ""
		name = "Office of BurntCornMuffin"
	cogwerks
		ckey = "drcogwerks"
		name = "Office of Cogwerks"
	crimes
		ckey = "warc"
		name = "Office of Warcrimes"
	darkchis
		ckey = "darkchis"
		name = "Office of Walter Poehl"
	dions
		ckey = "dionsu"
		name = "Office of Dions"
	drsingh
		ckey = "magicmountain"
		name = "Office of DrSingh"
	edad
		ckey = ""
		name = "Office of Edad"
	efrem
		ckey = "captainbravo"
		name = "Office of Vaughn Moon"
	enakai
		ckey = "enakai"
		name = "Office of Enakai"
	flaborized
		ckey = "flaborized"
		name = "Office of Flaborized"
	flourish
		ckey = "flourish"
		name = "Office of Flourish"
	freshlemon
		ckey = ""
		name = "Office of Belkis Tekeli"
	gannets
		ckey = "gannets"
		name = "Office of Hannah Strawberry"
	gerhazo
		ckey = "gerhazo"
		name = "Office of Casey Spark"
	gibbed
		ckey = "gibbed"
		name = "Office of Rick"
	grayshift
		ckey = "grayshift"
		name = "Office of Grayshift"
	hazoflabs
		// ckey = ""
		name = "Shared Office Space of Gerhazo and Flaborized"
	hufflaw
		ckey = "hufflaw"
		name = "Office of Hufflaw"
	hukhukhuk
		ckey = "hukhukhuk"
		name = "Office of HukHukHuk"
	hydro
		ckey = "hydrofloric"
		name = "Office of HydroFloric"
	ines
		ckey = "hokie"
		name = "Office of Ines"
	kyle
		ckey = "kyle2143"
		name = "Office of Kyle"
	lyra
		ckey = "lison"
		name = "Office of Lyra"
	maid
		ckey = "housekeep"
		name = "Office of Maid"
	marknstein
		ckey = "marknstein"
		name = "Office of MarkNstein"
	mbc
		ckey = "mybluecorners"
		name = "Office of Dotty Spud"
	mordent
		ckey = "mordent"
		name = "Office of Mordent"
	mrfishstick
		ckey = "mrfishstick"
		name = "Office of Mr Fishstick"
	nakar
		ckey = ""
		name = "Office of Nakar"
	pacra
		ckey = "pacra"
		name = "Office of Pacra"
	pali
		ckey = "pali6"
		name = "Office of Pali"
	patrickstar
		ckey = ""
		name = "Office of Patrick Star"
	pope
		ckey = "popecrunch"
		name = "Office of Popecrunch"
	questx
		ckey = "questx"
		name = "Office of Boris Bubbleton"
	reginaldhj
		ckey = "reginaldhj"
		name = "Office of ReginaldHJ"
	rodney
		ckey = "rodneydick"
		name = "Office of Lily"
	sageacrin
		ckey = "sageacrin"
		name = "Office of Escha Thermic"
	shotgunbill
		ckey = "shotgunbill"
		name = "Office of Shotgunbill"
	simianc
		ckey = "simianc"
		name = "Office of C.U.T.I.E."
	sord
		ckey="sord213"
		name = "Office of Sord"
	souricelle
		ckey = "souricelle"
		name = "Office of Souricelle"
	sovexe
		ckey = "sovexe"
		name = "Office of Sov Extant"
	studenterhue
		ckey = "studenterhue"
		name = "Office of Studenterhue"
	supernorn
		ckey = "supernorn"
		name = "Office of Supernorn"
	sydne66
		ckey = "sydne66"
		name = "Office of Throrvardr Finvardrardson"
	tarmunora
		ckey = "tarmunora"
		name = "Office of yass"
	urs
		ckey = "ursulamajor"
		name = "Office of UrsulaMajor"
	wire
		ckey = "wirewraith"
		name = "Office of Wire"
	zamujasa
		ckey = "zamujasa"
		name = "Office of Zamujasa"
	zewaka
		ckey = "zewaka"
		name = "Office of Shitty Bill Jr."

/area/centcom/lobby
	name = "NT Offices Lobby"
	icon_state = "blue"

/area/centcom/lounge
	name = "NT Recreational Lounge"
	icon_state = "yellow"

/area/centcom/garden
	name = "NT Business Park"
	icon_state = "orange"

/area/centcom/power
	name = "NT Power Supply"
	icon_state = "green"
	blocked = 1

////////////////////////////

/turf/unsimulated/outdoors
	icon = 'icons/turf/outdoors.dmi'

	snow
		name = "snow"
		New()
			..()
			dir = pick(cardinal)
		icon_state = "grass_snow"
	grass
		name = "grass"
		New()
			..()
			dir = pick(cardinal)
		icon_state = "grass"
		dense
			name = "dense grass"
			desc = "whoa, this is some dense grass. wow."
			density = 1
			opacity = 1
			color = "#AAAAAA"
	concrete
		name = "concrete"
		icon_state = "concrete"

/obj/machinery/door/unpowered/wood/sordBloodDoor
	open()
		. = ..()
		if(.)
			var/const/fluid_amount = 50
			var/datum/reagents/R = new /datum/reagents(fluid_amount)
			R.add_reagent("blood", fluid_amount)

			var/turf/T = get_turf(src)
			if (istype(T))
				T.fluid_react(R,fluid_amount)
				R.clear_reagents()
