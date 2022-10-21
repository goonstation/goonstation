
TYPEINFO(/datum/mapPrefab/mining)
	stored_as_subtypes = TRUE

ABSTRACT_TYPE(/datum/mapPrefab/mining)
/datum/mapPrefab/mining
	var/underwater = 0 //! prefab will only be used if this matches map_currently_underwater. I.e. if this is 1 and map_currently_underwater is 1 then the prefab may be used.

	New()
		..()
		if(underwater)
			LAZYLISTADD(src.tags, "underwater")

	adjust_position(turf/target)
		RETURN_TYPE(/turf)
		var/adjustX = target.x
		var/adjustY = target.y

		//Move prefabs backwards if they would end up outside the map.
		if(!isnull(prefabSizeX) && (adjustX + prefabSizeX) > (world.maxx - AST_MAPBORDER))
			adjustX -= ((adjustX + prefabSizeX) - (world.maxx - AST_MAPBORDER))

		if(!isnull(prefabSizeY) && (adjustY + prefabSizeY) > (world.maxy - AST_MAPBORDER))
			adjustY -= ((adjustY + prefabSizeY) - (world.maxy - AST_MAPBORDER))

		return locate(adjustX, adjustY, target.z)

	verify_position(turf/target)
		for(var/x=0, x<prefabSizeX; x++)
			for(var/y=0, y<prefabSizeY; y++)
				var/turf/L = locate(target.x+x, target.y+y, target.z)
				if(L?.loc && ((L.loc.type != /area/space) && !istype(L.loc , /area/allowGenerate)))
					return FALSE
		return TRUE

	clown
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_clown.dmm"
		prefabSizeX = 5
		prefabSizeY = 5

	vault
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_vault.dmm"
		prefabSizeX = 7
		prefabSizeY = 7

	shuttle
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_shuttle.dmm"
		prefabSizeX = 19
		prefabSizeY = 13

	cannibal
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_cannibal.dmm"
		prefabSizeX = 10
		prefabSizeY = 10

	sleepership
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_sleepership.dmm"
		prefabSizeX = 15
		prefabSizeY = 19

	rockworms
		maxNum = 4 // It was at 10 ... and there was a good chance that most of the prefabs on Z5 were this ugly mess. We need less of that. Way less. So here ya'go.
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_rockworms.dmm"
		prefabSizeX = 5
		prefabSizeY = 5

	outpost // rest stop/outpost for miners to eat/rest/heal at.
		required = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_outpost.dmm"
		prefabSizeX = 20
		prefabSizeY = 20

	ksol // The wreck of the old radio buoy, rip
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_ksol.dmm"
		prefabSizeX = 35
		prefabSizeY = 27

	habitat // kube's habitat thing
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_habitat.dmm"
		prefabSizeX = 25
		prefabSizeY = 20

	smuggler // kube's smuggler thing
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_smuggler.dmm"
		prefabSizeX = 19
		prefabSizeY = 18

	tomb // small little tomb
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_tomb.dmm"
		prefabSizeX = 13
		prefabSizeY = 10

	janitor // adhara's janitorial hideout
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_janitor.dmm"
		prefabSizeX = 16
		prefabSizeY = 15

	customs_shuttle // Carsontheking's Crashed Customs shuttle
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_customs_shuttle.dmm"
		prefabSizeX = 27
		prefabSizeY = 16

	pie_ship // Urs's ship originally built for the pie eating contest event
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_pie_ship.dmm"
		prefabSizeX = 16
		prefabSizeY = 21

	bee_sanctuary_space // Sov's Bee Sanctuary (Space Variant)
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_beesanctuary.dmm"
		prefabSizeX = 41
		prefabSizeY = 24

	sequestered_cloner // MarkNstein's Sequestered Cloner
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_sequestered_cloner.dmm"
		prefabSizeX = 20
		prefabSizeY = 15

	clown_nest // Gores abandoned Clown-Federation Outpost
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_clown_nest.dmm"
		prefabSizeX = 30
		prefabSizeY = 30

	dans_asteroid // Discount Dans Delivery Asteroid featuring advanced cooling technology
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_dans_asteroid.dmm"
		prefabSizeX = 37
		prefabSizeY = 48

	drug_den // A highly cozy hideout in space; take out the stress - eat some mice sandwiches.
		maxNum = 1
		probability = 40
		prefabPath = "assets/maps/prefabs/prefab_drug_den.dmm"
		prefabSizeX = 32
		prefabSizeY = 27

	von_ricken // One way or another - an expensive space vavaction for a physical toll.
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_von_ricken.dmm"
		prefabSizeX = 42
		prefabSizeY = 40

	candy_shop // Ryn's store from out of time and out of place
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_candy_shop.dmm"
		prefabSizeX = 20
		prefabSizeY = 20

	space_casino // Lythine's casino with some dubious gambling machines
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_space_casino.dmm"
		prefabSizeX = 31
		prefabSizeY = 23

	ranch // A tiny little ranch in space
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_ranch.dmm"
		prefabSizeX = 12
		prefabSizeY = 12

	synd_lab // Zone's Syndicate laboratory for experimenting with telecrystals
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/prefab_synd_lab.dmm"
		prefabSizeX = 14
		prefabSizeY = 16

	shooting_range // Nef's shooting range with an experimental ray gun
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/prefab_gunrange.dmm"
		prefabSizeX = 19
		prefabSizeY = 22

	lesbeeans // BatElite's bee-shaped farm where the bees are also lesbians
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_lesbeeans.dmm"
		prefabSizeX = 24
		prefabSizeY = 24

	silverglass // Ill-fated entanglement research facility
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_silverglass.dmm"
		prefabSizeX = 35
		prefabSizeY = 26

	safehouse // A seemingly abandoned safehouse
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/prefab_safehouse.dmm"
		prefabSizeX = 35
		prefabSizeY = 23

	dreamplaza // Walp's abandoned space mall... Well, what remains of it.
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_dreamplaza.dmm"
		prefabSizeX = 30
		prefabSizeY = 30

	secbot_academy // Danger Noodle's elite securitron school
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/prefab_secbot_academy.dmm"
		prefabSizeX = 34
		prefabSizeY = 37

	art_workshop
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_artist_studio.dmm"
		prefabSizeX = 25
		prefabSizeY = 18

	adrift_cargorouter
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_adrift_cargo_router.dmm"
		prefabSizeX = 16
		prefabSizeY = 16

	//UNDERWATER AREAS FOR OSHAN

	pit
		required = 1
		underwater = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_water_oshanpit.dmm"
		prefabSizeX = 8
		prefabSizeY = 8

#if defined(MAP_OVERRIDE_OSHAN)
	mantahole
		required = 1
		underwater = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_water_mantahole.dmm"
		prefabSizeX = 10
		prefabSizeY = 10
#endif

#if defined(MAP_OVERRIDE_OSHAN)
	elevator
		required = 1
		underwater = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_water_oshanelevator.dmm"
		prefabSizeX = 11
		prefabSizeY = 11
#endif

#if defined(MAP_OVERRIDE_NADIR)
	elevator
		required = 1
		underwater = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_water_nadirelevator.dmm" //also sneakily contains diner and siphon shaft cover
		prefabSizeX = 46
		prefabSizeY = 41
#endif

//nadir shouldn't have most general prefabs due to circumstances of trench
#ifndef MAP_OVERRIDE_NADIR
	robotfactory
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_robotfactory.dmm"
		prefabSizeX = 20
		prefabSizeY = 28

	racetrack
		underwater = 1
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/prefab_water_racetrack.dmm"
		prefabSizeX = 24
		prefabSizeY = 25

	zoo
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_zoo.dmm"
		prefabSizeX = 20
		prefabSizeY = 17

	outpost
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_outpost.dmm"
		prefabSizeX = 21
		prefabSizeY = 21

	sandyruins
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_sandyruins.dmm"
		prefabSizeX = 11
		prefabSizeY = 13

	greenhouse
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_greenhouse.dmm"
		prefabSizeX = 21
		prefabSizeY = 15

	genelab
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_genelab.dmm"
		prefabSizeX = 12
		prefabSizeY = 11

	beetrader
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_beetrader.dmm"
		prefabSizeX = 13
		prefabSizeY = 18

	stripmall
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_stripmall.dmm"
		prefabSizeX = 20
		prefabSizeY = 22

	blindpig
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_blindpig.dmm"
		prefabSizeX = 23
		prefabSizeY = 20

	strangeprison
		underwater = 1
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/prefab_water_strangeprison.dmm"
		prefabSizeX = 35
		prefabSizeY = 21

	seamonkey
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_seamonkey.dmm"
		prefabSizeX = 33
		prefabSizeY = 25

	ghost_house
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_ghosthouse.dmm"
		prefabSizeX = 23
		prefabSizeY = 34

	honk
		underwater = 1
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_water_honk.dmm"
		prefabSizeX = 24
		prefabSizeY = 22

	disposal
		underwater = 1
		maxNum = 1
		probability = 35
		prefabPath = "assets/maps/prefabs/prefab_water_disposal.dmm"
		prefabSizeX = 16
		prefabSizeY = 13

	sketchy
		underwater = 1
		maxNum = 1
		probability = 35
		prefabPath = "assets/maps/prefabs/prefab_water_sketchy.dmm"
		prefabSizeX = 21
		prefabSizeY = 15

	water_treatment // Sov's water treatment facility
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_watertreatment.dmm"
		prefabSizeX = 33
		prefabSizeY = 14

	bee_sanctuary //Sov's Bee Sanctuary
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_beesanctuary.dmm"
		prefabSizeX = 34
		prefabSizeY = 19

	danktrench //the marijuana trench
		underwater = 1
		maxNum = 1
		probability = 35
		prefabPath = "assets/maps/prefabs/prefab_water_danktrench.dmm"
		prefabSizeX = 16
		prefabSizeY = 9

	grill //test post do not bonk
		maxNum = 1
		prefabPath = "assets/maps/prefabs/prefab_grill.dmm"
		probability = 30
		prefabSizeX = 10
		prefabSizeY = 10

	torpedo_deposit // Torpedo deposit
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_torpedo_deposit.dmm"
		prefabSizeX = 21
		prefabSizeY = 21

	cache_small_loot
		underwater = 1
		maxNum = -1
		probability = 1
		prefabPath = "assets/maps/prefabs/prefab_water_cache_smallloot.dmm"
		prefabSizeX = 4
		prefabSizeY = 4

	cache_small_oxygen
		underwater = 1
		maxNum = -1
		probability = 1
		prefabPath = "assets/maps/prefabs/prefab_water_cache_smalloxygen.dmm"
		prefabSizeX = 4
		prefabSizeY = 4

	cache_small_skull
		underwater = 1
		maxNum = -1
		probability = 1
		prefabPath = "assets/maps/prefabs/prefab_water_cache_smallskull.dmm"
		prefabSizeX = 3
		prefabSizeY = 3

	sea_crashed
		underwater = 1
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_water_crashed.dmm"
		prefabSizeX = 24
		prefabSizeY = 32
#endif

	drone_battle
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_drone_battle.dmm"
		prefabSizeX = 24
		prefabSizeY = 21

	ydrone
		underwater = 1
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/prefab_water_ydrone.dmm"
		prefabSizeX = 15
		prefabSizeY = 15

#if defined(MAP_OVERRIDE_OSHAN)
	sea_miner
		underwater = 1
		maxNum = 1
		probability = 35
		prefabPath = "assets/maps/prefabs/prefab_water_miner.dmm"
		prefabSizeX = 21
		prefabSizeY = 15
#endif

#if defined(MAP_OVERRIDE_MANTA)
	sea_miner
		underwater = 1
		maxNum = 1
		required = 1
		prefabPath = "assets/maps/prefabs/prefab_water_mantamining.dmm"
		prefabSizeX = 13
		prefabSizeY = 43
#endif
