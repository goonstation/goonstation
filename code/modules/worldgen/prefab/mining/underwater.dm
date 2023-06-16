// Prefabs that can spawn on every water map including nadir
TYPEINFO(/datum/mapPrefab/mining/underwater/nadir_safe)
	stored_as_subtypes = TRUE

ABSTRACT_TYPE(/datum/mapPrefab/mining/underwater/nadir_safe)
/datum/mapPrefab/mining/underwater/nadir_safe

	init()
		..()
		tags |= PREFAB_NADIR_SAFE

	pathStart = "assets/maps/prefabs/underwater/nadir_safe/"

	pit
		required = 1
		maxNum = 1
		probability = 100
		prefabPath = "prefab_water_oshanpit.dmm"
		prefabSizeX = 8
		prefabSizeY = 8

	bee_sanctuary //Sov's Bee Sanctuary
		maxNum = 1
		probability = 30
		prefabPath = "prefab_water_beesanctuary.dmm"
		prefabSizeX = 34
		prefabSizeY = 19

	sandyruins
		maxNum = 1
		probability = 20
		prefabPath = "prefab_water_sandyruins.dmm"
		prefabSizeX = 11
		prefabSizeY = 13

	disposal
		maxNum = 1
		probability = 35
		prefabPath = "prefab_water_disposal.dmm"
		prefabSizeX = 16
		prefabSizeY = 13

	sketchy
		maxNum = 1
		probability = 35
		prefabPath = "prefab_water_sketchy.dmm"
		prefabSizeX = 21
		prefabSizeY = 15

	robotfactory
		maxNum = 1
		probability = 20
		prefabPath = "prefab_water_robotfactory.dmm"
		prefabSizeX = 20
		prefabSizeY = 28

	sea_crashed
		maxNum = 1
		probability = 25
		prefabPath = "prefab_water_crashed.dmm"
		prefabSizeX = 24
		prefabSizeY = 32

	torpedo_deposit // Torpedo deposit
		maxNum = 1
		probability = 30
		prefabPath = "prefab_water_torpedo_deposit.dmm"
		prefabSizeX = 21
		prefabSizeY = 21

	drone_battle
		maxNum = 1
		probability = 20
		prefabPath = "prefab_water_drone_battle.dmm"
		prefabSizeX = 24
		prefabSizeY = 21

	ydrone
		maxNum = 1
		probability = 10
		prefabPath = "prefab_water_ydrone.dmm"
		prefabSizeX = 15
		prefabSizeY = 15

	martian_glomp // Martian glomp (boarding pod? escape pod? you decide) that ended up very stranded
		maxNum = 1
		probability = 30
		prefabPath = "prefab_water_martian_glomp.dmm"
		prefabSizeX = 13
		prefabSizeY = 10

//water prefabs that wouldn't make overly much sense in nadir's acid should go in this subsection
TYPEINFO(/datum/mapPrefab/mining/underwater/nadir_unsafe)
	stored_as_subtypes = TRUE

ABSTRACT_TYPE(/datum/mapPrefab/mining/underwater/nadir_unsafe)
/datum/mapPrefab/mining/underwater/nadir_unsafe

	init()
		..()
		tags |= PREFAB_NADIR_UNSAFE

	pathStart = "assets/maps/prefabs/underwater/nadir_unsafe/"

	polaris
		required = 1
		maxNum = 1
		probability = 100
		prefabPath = "prefab_water_polaris.dmm"
		prefabSizeX = 10
		prefabSizeY = 10

	racetrack
		maxNum = 1
		probability = 10
		prefabPath = "prefab_water_racetrack.dmm"
		prefabSizeX = 24
		prefabSizeY = 25

	zoo
		maxNum = 1
		probability = 20
		prefabPath = "prefab_water_zoo.dmm"
		prefabSizeX = 20
		prefabSizeY = 17

	outpost
		maxNum = 1
		probability = 20
		prefabPath = "prefab_water_outpost.dmm"
		prefabSizeX = 21
		prefabSizeY = 21

	greenhouse
		maxNum = 1
		probability = 20
		prefabPath = "prefab_water_greenhouse.dmm"
		prefabSizeX = 21
		prefabSizeY = 15

	genelab
		maxNum = 1
		probability = 30
		prefabPath = "prefab_water_genelab.dmm"
		prefabSizeX = 12
		prefabSizeY = 11

	beetrader
		maxNum = 1
		probability = 30
		prefabPath = "prefab_water_beetrader.dmm"
		prefabSizeX = 13
		prefabSizeY = 18

	stripmall
		maxNum = 1
		probability = 20
		prefabPath = "prefab_water_stripmall.dmm"
		prefabSizeX = 20
		prefabSizeY = 22

	blindpig
		maxNum = 1
		probability = 30
		prefabPath = "prefab_water_blindpig.dmm"
		prefabSizeX = 23
		prefabSizeY = 20

	strangeprison
		maxNum = 1
		probability = 10
		prefabPath = "prefab_water_strangeprison.dmm"
		prefabSizeX = 35
		prefabSizeY = 21

	seamonkey
		maxNum = 1
		probability = 30
		prefabPath = "prefab_water_seamonkey.dmm"
		prefabSizeX = 33
		prefabSizeY = 25

	ghost_house
		maxNum = 1
		probability = 30
		prefabPath = "prefab_water_ghosthouse.dmm"
		prefabSizeX = 23
		prefabSizeY = 34

	honk
		maxNum = 1
		probability = 25
		prefabPath = "prefab_water_honk.dmm"
		prefabSizeX = 24
		prefabSizeY = 22

	water_treatment // Sov's water treatment facility
		maxNum = 1
		probability = 30
		prefabPath = "prefab_water_watertreatment.dmm"
		prefabSizeX = 33
		prefabSizeY = 14

	danktrench //the marijuana trench
		maxNum = 1
		probability = 35
		prefabPath = "prefab_water_danktrench.dmm"
		prefabSizeX = 16
		prefabSizeY = 9

// Map specific
// Nadir only prefabs
TYPEINFO(/datum/mapPrefab/mining/underwater/nadir)
	stored_as_subtypes = TRUE

ABSTRACT_TYPE(/datum/mapPrefab/mining/underwater/nadir)
/datum/mapPrefab/mining/underwater/nadir

	init()
		..()
		tags |= PREFAB_NADIR

	pathStart = "assets/maps/prefabs/underwater/nadir/"

	elevator
		required = 1
		maxNum = 1
		probability = 100
		prefabPath = "prefab_water_nadirelevator.dmm" //also sneakily contains diner and siphon shaft cover
		prefabSizeX = 47
		prefabSizeY = 47

	miracliumsurvey
		maxNum = 1
		probability = 100
		prefabPath = "prefab_water_miraclium_survey.dmm"
		prefabSizeX = 7
		prefabSizeY = 5

// Oshan only prefabs
TYPEINFO(/datum/mapPrefab/mining/underwater/oshan)
	stored_as_subtypes = TRUE

ABSTRACT_TYPE(/datum/mapPrefab/mining/underwater/oshan)
/datum/mapPrefab/mining/underwater/oshan

	init()
		..()
		tags |= PREFAB_OSHAN

	pathStart = "assets/maps/prefabs/underwater/oshan/"

	elevator
		required = 1
		maxNum = 1
		probability = 100
		prefabPath = "prefab_water_oshanelevator.dmm"
		prefabSizeX = 11
		prefabSizeY = 11

	sea_miner
		maxNum = 1
		probability = 35
		prefabPath = "prefab_water_miner.dmm"
		prefabSizeX = 21
		prefabSizeY = 15

// Manta only prefabs
TYPEINFO(/datum/mapPrefab/mining/underwater/manta)
	stored_as_subtypes = TRUE

ABSTRACT_TYPE(/datum/mapPrefab/mining/underwater/manta)
/datum/mapPrefab/mining/underwater/manta

	init()
		..()
		tags |= PREFAB_MANTA

	pathStart = "assets/maps/prefabs/underwater/manta/"

	sea_miner
		maxNum = 1
		required = 1
		prefabPath = "prefab_water_mantamining.dmm"
		prefabSizeX = 13
		prefabSizeY = 43

