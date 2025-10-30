
TYPEINFO(/datum/mapPrefab/mining)
	stored_as_subtypes = TRUE

ABSTRACT_TYPE(/datum/mapPrefab/mining)
/datum/mapPrefab/mining
	var/underwater = 0 //! prefab will only be used if this matches map_currently_underwater. I.e. if this is 1 and map_currently_underwater is 1 then the prefab may be used.

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
		for(var/x=0; x < prefabSizeX; x++)
			for(var/y=0; y<prefabSizeY; y++)
				var/turf/L = locate(target.x+x, target.y+y, target.z)
				if(L?.loc && ((L.loc.type != /area/space) && !istype(L.loc , /area/allowGenerate)))
					return FALSE
		return TRUE

// Prefabs that only spawn in space
TYPEINFO(/datum/mapPrefab/mining/space)
	stored_as_subtypes = TRUE

ABSTRACT_TYPE(/datum/mapPrefab/mining/space)
/datum/mapPrefab/mining/space // All prefabs that can only spawn in space
	tags = PREFAB_SPACE

	clown
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_clown.dmm"
		prefabSizeX = 5
		prefabSizeY = 5

	radshuttle //An ill-fated and ill-equipped "transport"
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_Radshuttle.dmm"
		prefabSizeX = 9
		prefabSizeY = 14

	shuttle
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_shuttle.dmm"
		prefabSizeX = 19
		prefabSizeY = 13

	cannibal
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_cannibal.dmm"
		prefabSizeX = 10
		prefabSizeY = 10

	sleepership
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_sleepership.dmm"
		prefabSizeX = 15
		prefabSizeY = 19

	rockworms
		maxNum = 4 // It was at 10 ... and there was a good chance that most of the prefabs on Z5 were this ugly mess. We need less of that. Way less. So here ya'go.
		probability = 100
		prefabPath = "assets/maps/prefabs/space/prefab_rockworms.dmm"
		prefabSizeX = 5
		prefabSizeY = 5

/* Disabling for now since the full mining outpost exists on z5
	outpost // rest stop/outpost for miners to eat/rest/heal at.
		required = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/space/prefab_outpost.dmm"
		prefabSizeX = 20
		prefabSizeY = 20
*/

	ksol // The wreck of the old radio buoy, rip
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/space/prefab_ksol.dmm"
		prefabSizeX = 35
		prefabSizeY = 27

	habitat // kube's habitat thing
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_habitat.dmm"
		prefabSizeX = 25
		prefabSizeY = 20

	smuggler // kube's smuggler thing
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_smuggler.dmm"
		prefabSizeX = 19
		prefabSizeY = 18

	janitor // adhara's janitorial hideout
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_janitor.dmm"
		prefabSizeX = 16
		prefabSizeY = 15

	customs_shuttle // Carsontheking's Crashed Customs shuttle
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_customs_shuttle.dmm"
		prefabSizeX = 27
		prefabSizeY = 16

	pie_ship // Urs's ship originally built for the pie eating contest event
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/space/prefab_pie_ship.dmm"
		prefabSizeX = 16
		prefabSizeY = 21

	bee_sanctuary_space // Sov's Bee Sanctuary (Space Variant)
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_beesanctuary.dmm"
		prefabSizeX = 41
		prefabSizeY = 24

	sequestered_cloner // MarkNstein's Sequestered Cloner
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_sequestered_cloner.dmm"
		prefabSizeX = 20
		prefabSizeY = 15

	clown_nest // Gores abandoned Clown-Federation Outpost
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/space/prefab_clown_nest.dmm"
		prefabSizeX = 30
		prefabSizeY = 30

	dans_asteroid // Discount Dans Delivery Asteroid featuring advanced cooling technology
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/space/prefab_dans_asteroid.dmm"
		prefabSizeX = 37
		prefabSizeY = 48

	drug_den // A highly cozy hideout in space; take out the stress - eat some mice sandwiches.
		maxNum = 1
		probability = 40
		prefabPath = "assets/maps/prefabs/space/prefab_drug_den.dmm"
		prefabSizeX = 32
		prefabSizeY = 27

	von_ricken // One way or another - an expensive space vavaction for a physical toll.
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/space/prefab_von_ricken.dmm"
		prefabSizeX = 42
		prefabSizeY = 40

	candy_shop // Ryn's store from out of time and out of place
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_candy_shop.dmm"
		prefabSizeX = 20
		prefabSizeY = 20

	space_casino // Lythine's casino with some dubious gambling machines
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_space_casino.dmm"
		prefabSizeX = 31
		prefabSizeY = 23

	ranch // A tiny little ranch in space
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_ranch.dmm"
		prefabSizeX = 12
		prefabSizeY = 12

	synd_lab // Zone's Syndicate laboratory for experimenting with telecrystals
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/space/prefab_synd_lab.dmm"
		prefabSizeX = 14
		prefabSizeY = 16

	shooting_range // Nef's shooting range with an experimental ray gun
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/space/prefab_gunrange.dmm"
		prefabSizeX = 19
		prefabSizeY = 22

	lesbeeans // BatElite's bee-shaped farm where the bees are also lesbians
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/space/prefab_lesbeeans.dmm"
		prefabSizeX = 24
		prefabSizeY = 24

	silverglass // Ill-fated entanglement research facility
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_silverglass.dmm"
		prefabSizeX = 35
		prefabSizeY = 26

	safehouse // A seemingly abandoned safehouse
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/space/prefab_safehouse.dmm"
		prefabSizeX = 35
		prefabSizeY = 23

	dreamplaza // Walp's abandoned space mall... Well, what remains of it.
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/space/prefab_dreamplaza.dmm"
		prefabSizeX = 30
		prefabSizeY = 30

	secbot_academy // Danger Noodle's elite securitron school
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/space/prefab_secbot_academy.dmm"
		prefabSizeX = 34
		prefabSizeY = 37

	art_workshop
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_artist_studio.dmm"
		prefabSizeX = 25
		prefabSizeY = 18

	adrift_cargorouter
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/space/prefab_adrift_cargo_router.dmm"
		prefabSizeX = 16
		prefabSizeY = 16

	larrys_laundry // Cheffie's Laundromat with port-a-laundry
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/space/prefab_larrys_laundromat.dmm"
		prefabSizeX = 17
		prefabSizeY = 20

	mauxite_hideout // Cheffie's Fermid infested hideout with grenade casings
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/space/prefab_mauxite_hideout.dmm"
		prefabSizeX = 22
		prefabSizeY = 20

	merc_outpost
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/space/prefab_merc_outpost.dmm"
		prefabSizeX = 25
		prefabSizeY = 25

// Drone Spawners
	drone_common
		maxNum = 8
		probability = 100
		prefabPath = "assets/maps/prefabs/space/prefab_drone_common.dmm"
		prefabSizeX = 1
		prefabSizeY = 1

	drone_uncommon
		maxNum = 4
		probability = 100
		prefabPath = "assets/maps/prefabs/space/prefab_drone_uncommon.dmm"
		prefabSizeX = 1
		prefabSizeY = 1

	drone_rare
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/space/prefab_drone_rare.dmm"
		prefabSizeX = 1
		prefabSizeY = 1
