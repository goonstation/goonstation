//file for where da fish appear
//TODO: add fishing exp? spot difficulty? dynamic probabilities?

/// initialised on world/New(), associative list with the format (fishing_atom_type = /datum/fishing_spot)
var/global/list/fishing_spots = null

/// run on world/New(), clears global.fishing_spots (if it exists) and fills it with the format (fishing_atom_type = /datum/fishing_spot)
proc/initialise_fishing_spots()
	global.fishing_spots = list()
	var/list/fishing_spot_types = concrete_typesof(/datum/fishing_spot)
	for (var/spot in fishing_spot_types)
		var/datum/fishing_spot/fishing_spot = new spot()
		if (fishing_spot.do_not_generate)
			qdel(fishing_spot)
			continue
		var/fishing_atom_type = fishing_spot.fishing_atom_type
		if(!isnull(global.fishing_spots[fishing_atom_type]))
			stack_trace("Duplicte fishing spot for [fishing_atom_type]")
		global.fishing_spots[fishing_atom_type] = fishing_spot

// dont auto-instantiate the parent please :3
ABSTRACT_TYPE(/datum/fishing_spot)

/// a datum that holds all the information about a "fishing spot"
/datum/fishing_spot
	/// the type of the atom that is the "fishing spot"
	var/fishing_atom_type = null
	/// associative list with the format (fish_type = probability), doesnt need to be ordered in descending probability
	var/list/fish_available = null
	/// for wip fishing spots that shouldnt be automatically added to the global list of fishing spots
	var/do_not_generate = 0
	/// what tier of rod do you need to fish here? current rods are tier 1,2 & 3
	var/rod_tier_required = 0

/datum/fishing_spot/proc/generate_fish(var/mob/user, var/obj/item/fishing_rod/fishing_rod, atom/target)
	if (length(src.fish_available))
		var/fish_path = weighted_pick(src.fish_available)
		return new fish_path()
	return null

/// called every time a fishing rod's action loop finishes. returns 0 if catching a fish failed, returns 1 if it succeeds
/datum/fishing_spot/proc/try_fish(var/mob/user, var/obj/item/fishing_rod/fishing_rod, atom/target)
	var/atom/movable/fish = src.generate_fish(user, fishing_rod, target)
	if (!fish)
		return 0
	// ever put this much effort into the dumbest thing ever haha
	user.visible_message("[user] [pick("reels in", "catches", "pulls in", "fishes up")] a \
	[pick("big", "wriggly", "fat", "slimy", "fishy", "large", "high-quality", "nasty", "chompy", "real", "wily")] \
	[prob(80) ? "[fish.name]" : pick("one", "catch", "chomper", "wriggler", "sunovagun", "sucker")]!")
	user.put_in_hand_or_drop(fish)
	playsound(user, 'sound/items/fishing_rod_reel.ogg', 50, 1)
	playsound(user, 'sound/effects/fish_catch.ogg', 50, 1)
	fishing_rod.last_fished = TIME //set the last fished time
	return 1

/datum/fishing_spot/sea
	fishing_atom_type = /turf/space/fluid
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5,\
	/obj/item/fish/tuna = 10,\
	/obj/item/fish/cod = 15,\
	/obj/item/fish/flounder = 10,\
	/obj/item/fish/coelacanth = 5,\
	/obj/item/fish/mahimahi = 10,\
	/obj/item/fish/shrimp = 15,\
	/mob/living/carbon/human/npc/monkey/sea = 5,\
	/obj/item/fish/sardine = 20)

/datum/fishing_spot/swamp
	fishing_atom_type = /turf/unsimulated/floor/auto/swamp
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/critter/slug = 10,\
	/mob/living/critter/small_animal/snake = 10,\
	/obj/critter/frog = 10,\
	/obj/item/clothing/head/rafflesia = 5)
/*
/datum/fishing_spot/test
	fishing_atom_type = /turf/simulated/floor/ancient
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5)
	do_not_generate = 1
*/
/datum/fishing_spot/toilet
	fishing_atom_type = /obj/item/storage/toilet
	rod_tier_required = 1
	fish_available = list( /obj/item/reagent_containers/food/snacks/yuck = 20, \
	/obj/item/reagent_containers/food/snacks/yuckburn = 20, \
	/obj/item/reagent_containers/food/snacks/shell = 20, \
	/obj/item/reagent_containers/food/snacks/burger/moldy = 5, \
	/obj/item/raw_material/scrap_metal = 5, \
	/obj/item/reagent_containers/food/snacks/fish_fingers = 10)

/datum/fishing_spot/drain
	fishing_atom_type = /obj/machinery/drainage
	fish_available = list(/obj/item/reagent_containers/food/snacks/yuck = 20, \
	/obj/item/reagent_containers/food/snacks/shell = 20, \
	/obj/item/reagent_containers/food/snacks/burger/moldy = 5, \
	/obj/item/raw_material/scrap_metal = 5, \
	/obj/item/fish/bass = 9,\
	/obj/item/fish/salmon = 7,\
	/obj/item/fish/herring = 6,\
	/obj/item/fish/red_herring = 1)

/datum/fishing_spot/toilet/random
	fishing_atom_type = /obj/item/storage/toilet/random

/datum/fishing_spot/spatial_tear
	fishing_atom_type = /obj/forcefield/event
	rod_tier_required = 3
	fish_available = list(/obj/item/fish/carp = 1,\
	/obj/item/fish/bass = 1,\
	/obj/item/fish/salmon = 1,\
	/obj/item/fish/herring = 1,\
	/obj/item/fish/red_herring = 1,\
	/obj/item/space_thing = 5,\
	/obj/item/gnomechompski = 5,\
	/obj/item/material_piece/cerenkite = 10,\
	/obj/item/material_piece/erebite = 10,\
	/obj/item/clothing/shoes/clown_shoes = 5,\
	/obj/item/coin = 5,\
	/mob/living/carbon/human/future = 1,\
#ifdef SECRETS_ENABLED
	/mob/living/carbon/human/npc/monkey/extremely_fast = 1,\
#endif
	/mob/living/critter/aberration = 1,\
	/mob/living/critter/small_animal/cat = 2,\
	/obj/item/clothing/head/void_crown = 1,\
	/obj/item/record/spacebux = 4,\
	/obj/critter/domestic_bee/trauma = 20)

/datum/fishing_spot/fryer
	fishing_atom_type = /obj/machinery/deep_fryer
	rod_tier_required = 2
	fish_available = list(/obj/item/fish/tuna = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/cod = 15,\
	/obj/item/fish/flounder = 5,\
	/obj/item/fish/carp = 15,\
	/obj/item/reagent_containers/food/snacks/yuckburn = 20,\
	/obj/item/reagent_containers/food/snacks/fish_fingers = 10)

	generate_fish(var/mob/user, var/obj/item/fishing_rod/fishing_rod, atom/target)
		. = ..()
		if(!istype(., /obj/item/reagent_containers/food/snacks))
			var/obj/machinery/deep_fryer/fryer = target
			. = fryer.fryify(.)

/datum/fishing_spot/fish_portal
	fishing_atom_type = /obj/machinery/active_fish_portal
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5,\
	/obj/item/fish/tuna = 10,\
	/obj/item/fish/cod = 15,\
	/obj/item/fish/flounder = 10,\
	/obj/item/fish/coelacanth = 5,\
	/obj/item/fish/mahimahi = 10,\
	/obj/item/fish/shrimp = 15,\
	/obj/item/fish/sardine = 20)

/datum/fishing_spot/nuclear_reactor
	fishing_atom_type = /obj/machinery/atmospherics/binary/nuclear_reactor
	rod_tier_required = 2
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5,\
	/obj/item/fish/coelacanth = 5,\
	/obj/item/reagent_containers/food/snacks/yellow_cake_uranium_cake = 1)

	generate_fish(var/mob/user, var/obj/item/fishing_rod/fishing_rod, atom/target)
		var/atom/result = ..()
		result.AddComponent(/datum/component/radioactive, 20, TRUE, FALSE, 0)
		return result

/datum/fishing_spot/nuclear_reactor/prefilled
	fishing_atom_type = /obj/machinery/atmospherics/binary/nuclear_reactor/prefilled/normal

// Gannets new fishing spots
// todo adjust availible fish lists & balance probabilities.

// Normal fishing spots
/datum/fishing_spot/fishing_pool
	fishing_atom_type = /obj/fishing_pool
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/goldfish = 30,\
	/obj/item/fish/bass = 20,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/carp = 15,\
	/obj/item/fish/rainbow_trout = 10,\
	/obj/item/fish/chub = 10,\
	/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/sardine = 20)

	// test pools
	basic
		fishing_atom_type = /obj/fishing_pool/basic
		rod_tier_required = 1

	upgraded
		fishing_atom_type = /obj/fishing_pool/upgraded
		rod_tier_required = 2

	master
		fishing_atom_type = /obj/fishing_pool/master
		rod_tier_required = 3

/datum/fishing_spot/fishing_pool_portable
	fishing_atom_type = /obj/fishing_pool/portable
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/goldfish = 30,\
	/obj/item/fish/bass = 20,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/carp = 15,\
	/obj/item/fish/rainbow_trout = 10,\
	/obj/item/fish/chub = 10,\
	/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/sardine = 20)

/datum/fishing_spot/fluid // covers pool, aquariums and uh all other standing pools of fluid.
	fishing_atom_type = /obj/fluid
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/clownfish = 15,\
	/obj/item/fish/damselfish = 10,\
	/obj/item/fish/green_chromis = 10,\
	/obj/item/fish/cardinalfish = 5,\
	/obj/item/fish/royal_gramma = 10,\
	/obj/item/fish/bc_angelfish = 5,\
	/obj/item/fish/blue_tang = 15,\
	/obj/item/fish/firefish = 5,\
	/obj/item/fish/yellow_tang = 10,\
	/obj/item/fish/mandarin_fish = 5)

/datum/fishing_spot/water_cooler
	fishing_atom_type = /obj/reagent_dispensers/watertank/fountain
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/clownfish = 40,\
	/obj/item/fish/damselfish = 30,\
	/obj/item/fish/green_chromis = 20,\
	/obj/item/fish/cardinalfish = 15,\
	/obj/item/fish/royal_gramma = 10,\
	/obj/item/fish/bc_angelfish = 10,\
	/obj/item/fish/blue_tang = 15,\
	/obj/item/fish/firefish = 5,\
	/obj/item/fish/yellow_tang = 15,\
	/obj/item/fish/mandarin_fish = 5)

/datum/fishing_spot/kitchen_sink
	fishing_atom_type = /obj/submachine/chef_sink
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/goldfish = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5,\
	/obj/item/fish/tuna = 10,\
	/obj/item/fish/cod = 15,\
	/obj/item/fish/flounder = 10,\
	/obj/item/fish/mahimahi = 10,\
	/obj/item/fish/shrimp = 15,\
	/obj/item/fish/sardine = 20,\
	/obj/item/clothing/head/chefhat = 10,\
	/obj/item/reagent_containers/food/snacks/swedish_fish = 10)

/datum/fishing_spot/bathroom_sink
	fishing_atom_type = /obj/submachine/chef_sink/chem_sink
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/goldfish = 30,\
	/obj/item/fish/bass = 20,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/carp = 15,\
	/obj/item/fish/chub = 10,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5,\
	/obj/item/fish/flounder = 10,\
	/obj/item/fish/mahimahi = 10,\
	/obj/item/fish/shrimp = 15,\
	/obj/item/fish/sardine = 20)

/datum/fishing_spot/bathtub
	fishing_atom_type = /obj/machinery/bathtub
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/goldfish = 30,\
	/obj/item/fish/bass = 20,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/carp = 15,\
	/obj/item/fish/rainbow_trout = 10,\
	/obj/item/fish/chub = 10,\
	/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5,\
	/obj/item/fish/tuna = 10,\
	/obj/item/fish/cod = 15,\
	/obj/item/fish/flounder = 10,\
	/obj/item/fish/mahimahi = 10,\
	/obj/item/fish/sardine = 20)

/datum/fishing_spot/watertank
	fishing_atom_type = /obj/reagent_dispensers/watertank
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/clownfish = 40,\
	/obj/item/fish/damselfish = 30,\
	/obj/item/fish/green_chromis = 20,\
	/obj/item/fish/cardinalfish = 15,\
	/obj/item/fish/royal_gramma = 10,\
	/obj/item/fish/bc_angelfish = 10,\
	/obj/item/fish/blue_tang = 15,\
	/obj/item/fish/firefish = 5,\
	/obj/item/fish/yellow_tang = 15,\
	/obj/item/fish/mandarin_fish = 5,\
	/obj/item/fish/tuna = 10,\
	/obj/item/fish/cod = 15,\
	/obj/item/fish/flounder = 10,\
	/obj/item/fish/mahimahi = 10,\
	/obj/item/fish/shrimp = 15,\
	/obj/item/fish/sardine = 20)

/datum/fishing_spot/river
	fishing_atom_type = /obj/river
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/herring = 40,\
	/obj/item/fish/tuna = 30,\
	/obj/item/fish/cod = 20,\
	/obj/item/fish/flounder = 15,\
	/obj/critter/slug = 10,\
	/mob/living/critter/small_animal/snake = 10,\
	/obj/critter/frog = 10)

/datum/fishing_spot/plantpot
	fishing_atom_type = /obj/machinery/plantpot
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/goldfish = 20,\
	/obj/item/plant/herb/grass = 20,\
	/obj/critter/slug = 10,\
	/mob/living/critter/small_animal/snake = 10,\
	/obj/critter/frog = 10)
/*
/datum/fishing_spot/blob
	fishing_atom_type = /obj/blob
	rod_tier_required = 2
	fish_available = list(/obj/item/fish/blobfish = 25)
*/
// Trash fishing spots
/datum/fishing_spot/disposal_chute // doesn't work yet
	fishing_atom_type = /obj/machinery/disposal
	rod_tier_required = 1
	fish_available = list(/obj/item/clothing/under/trash_bag = 10,\
	/mob/living/critter/small_animal/cockroach = 10,\
	/obj/item/c_tube = 10,\
	/obj/item/raw_material/shard/glass = 10,\
	/obj/item/cigbutt = 20,\
	/obj/item/reagent_containers/food/drinks/bottle/empty = 20,\
	/obj/machinery/light/small/broken = 20)

/datum/fishing_spot/janitor_bucket
	fishing_atom_type = /obj/mopbucket
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/clownfish = 40,\
	/obj/item/fish/damselfish = 30,\
	/obj/item/fish/green_chromis = 20,\
	/obj/item/fish/cardinalfish = 15,\
	/obj/item/fish/royal_gramma = 10,\
	/obj/item/fish/bc_angelfish = 10,\
	/obj/item/fish/blue_tang = 15,\
	/obj/item/fish/firefish = 5,\
	/obj/item/fish/yellow_tang = 15,\
	/obj/item/fish/mandarin_fish = 5)

/datum/fishing_spot/bucket
	fishing_atom_type = /obj/item/reagent_containers/glass/bucket
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/clownfish = 40,\
	/obj/item/fish/damselfish = 30,\
	/obj/item/fish/green_chromis = 20,\
	/obj/item/fish/cardinalfish = 15,\
	/obj/item/fish/royal_gramma = 10,\
	/obj/item/fish/bc_angelfish = 10,\
	/obj/item/fish/blue_tang = 15,\
	/obj/item/fish/firefish = 5,\
	/obj/item/fish/yellow_tang = 15,\
	/obj/item/fish/mandarin_fish = 5)

/datum/fishing_spot/drain
	fishing_atom_type = /obj/machinery/drainage
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/goldfish = 30,\
	/obj/item/fish/bass = 20,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/carp = 15,\
	/obj/item/fish/rainbow_trout = 10,\
	/obj/item/fish/chub = 10,\
	/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20)

// Alien/mutant fishing spots
/datum/fishing_spot/meatzone_acid
	fishing_atom_type = /turf/unsimulated/floor/setpieces/bloodfloor/stomach
	rod_tier_required = 2
	fish_available = list(/obj/item/fish/meat_mutant = 25,\
	/mob/living/critter/blobman = 5,\
	/mob/living/critter/blobman/meat = 5,\
	/obj/item/fish/eye_mutant = 15,\
	/obj/decal/cleanable/blood/gibs = 25,\
	/obj/decal/cleanable/blood/gibs/core = 25)

/datum/fishing_spot/lava_moon
	fishing_atom_type = /turf/unsimulated/floor/lava
	rod_tier_required = 3
	fish_available = list(/obj/item/fish/firefish = 20,\
	/obj/item/material_piece/slag = 20,\
	/obj/decal/cleanable/ash = 20,\
	/obj/item/reagent_containers/food/snacks/yuckburn = 20,\
	/obj/item/raw_material/char =20)

/datum/fishing_spot/cryo
	fishing_atom_type = /obj/machinery/atmospherics/unary/cryo_cell
	rod_tier_required = 2
	fish_available = list(/obj/item/fish/meat_mutant = 10,\
	/obj/item/parts/human_parts/arm/left = 10,\
	/obj/item/parts/human_parts/arm/right = 10,\
	/obj/item/parts/human_parts/leg/left = 10,\
	/obj/item/parts/human_parts/leg/right =10,\
	/obj/item/organ/brain = 10)

/datum/fishing_spot/clonepod
	fishing_atom_type = /obj/machinery/clonepod
	rod_tier_required = 2
	fish_available = list(/obj/item/fish/meat_mutant = 10,\
	/mob/living/critter/blobman = 5,\
	/mob/living/critter/blobman/meat = 5,\
	/obj/item/parts/human_parts/arm/left = 10,\
	/obj/item/parts/human_parts/arm/right = 10,\
	/obj/item/parts/human_parts/leg/left = 10,\
	/obj/item/parts/human_parts/leg/right =10,\
	/obj/item/organ/brain = 10)

/datum/fishing_spot/time_ship
	fishing_atom_type = /turf/unsimulated/floor/void/timewarp
	rod_tier_required = 3
	fish_available = list(/obj/item/space_thing = 5,\
	/obj/item/gnomechompski = 5,\
	/obj/item/clothing/shoes/clown_shoes = 5,\
	/mob/living/carbon/human/future = 1,\
	/mob/living/critter/aberration = 1,\
	/mob/living/critter/small_animal/cat = 2,\
	/obj/critter/domestic_bee/trauma = 20,\
	/obj/item/fish/void_fish = 20)

/datum/fishing_spot/singularity
	fishing_atom_type = /obj/machinery/the_singularity
	rod_tier_required = 3
	fish_available = list(/obj/item/fish/void_fish = 75)

//void
/datum/fishing_spot/void
	fishing_atom_type = /turf/unsimulated/floor/void
	rod_tier_required = 3
	fish_available = list(/obj/item/space_thing = 5,\
	/obj/item/gnomechompski = 5,\
	/obj/item/clothing/shoes/clown_shoes = 5,\
	/mob/living/carbon/human/future = 1,\
	/mob/living/critter/aberration = 1,\
	/mob/living/critter/small_animal/cat = 2,\
	/obj/critter/domestic_bee/trauma = 20,\
	/obj/item/fish/void_fish = 20)

//random event wormholes
/datum/fishing_spot/wormhole
	fishing_atom_type = /obj/portal/wormhole
	rod_tier_required = 3
	fish_available = list(/obj/item/space_thing = 5,\
	/obj/item/gnomechompski = 5,\
	/obj/item/material_piece/cerenkite = 10,\
	/obj/item/material_piece/erebite = 10,\
	/obj/item/clothing/shoes/clown_shoes = 5,\
	/mob/living/carbon/human/future = 1,\
	/mob/living/critter/aberration = 1,\
	/mob/living/critter/small_animal/cat = 2,\
	/obj/item/clothing/head/void_crown = 1,\
	/obj/critter/domestic_bee/trauma = 20,\
	/obj/item/fish/void_fish = 20)

/datum/fishing_spot/black_hole
	fishing_atom_type = /obj/bhole
	rod_tier_required = 3
	fish_available = list(/obj/item/space_thing = 5,\
	/obj/item/gnomechompski = 5,\
	/obj/item/material_piece/cerenkite = 10,\
	/obj/item/material_piece/erebite = 10,\
	/obj/item/clothing/shoes/clown_shoes = 5,\
	/mob/living/carbon/human/future = 1,\
	/mob/living/critter/aberration = 1,\
	/mob/living/critter/small_animal/cat = 2,\
	/obj/item/clothing/head/void_crown = 1,\
	/obj/critter/domestic_bee/trauma = 20,\
	/obj/item/fish/void_fish = 20)

//biodome flooded area
/datum/fishing_spot/biodome_lake
	fishing_atom_type = /turf/space/fluid/cenote
	rod_tier_required = 2
	fish_available = list(/obj/item/fish/goldfish = 30,\
	/obj/item/fish/bass = 20,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/carp = 15,\
	/obj/item/fish/rainbow_trout = 10,\
	/obj/item/fish/chub = 10,\
	/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5,\
	/obj/item/fish/tuna = 10,\
	/obj/item/fish/cod = 15,\
	/obj/item/fish/flounder = 10,\
	/obj/item/fish/mahimahi = 10,\
	/obj/item/fish/shrimp = 15,\
	/obj/item/fish/sardine = 20)

//ainsley
/datum/fishing_spot/nuclear_core_decal
	fishing_atom_type = /obj/decal/fakeobjects/core
	rod_tier_required = 3
	fish_available = list(/obj/item/fish/goldfish = 30,\
	/obj/item/fish/bass = 20,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/carp = 15,\
	/obj/item/fish/rainbow_trout = 10,\
	/obj/item/fish/chub = 10,\
	/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5,\
	/obj/item/fish/tuna = 10,\
	/obj/item/fish/cod = 15,\
	/obj/item/fish/flounder = 10,\
	/obj/item/fish/mahimahi = 10,\
	/obj/item/fish/shrimp = 15,\
	/obj/item/fish/sardine = 20,\
	/obj/item/reagent_containers/food/snacks/yellow_cake_uranium_cake = 1)

	generate_fish(var/mob/user, var/obj/item/fishing_rod/fishing_rod, atom/target)
		var/atom/result = ..()
		result.AddComponent(/datum/component/radioactive, 20, TRUE, FALSE, 0)
		return result

//solarium
/datum/fishing_spot/the_sun
	fishing_atom_type = /obj/the_sun
	rod_tier_required = 3
	fish_available = list(/obj/item/fish/sun_fish = 50)

//dojo
/datum/fishing_spot/dojo_water
	fishing_atom_type = /turf/unsimulated/wall/water
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/clownfish = 40,\
	/obj/item/fish/damselfish = 30,\
	/obj/item/fish/green_chromis = 20,\
	/obj/item/fish/cardinalfish = 15,\
	/obj/item/fish/royal_gramma = 10,\
	/obj/item/fish/bc_angelfish = 10,\
	/obj/item/fish/blue_tang = 15,\
	/obj/item/fish/firefish = 5,\
	/obj/item/fish/yellow_tang = 15,\
	/obj/item/fish/mandarin_fish = 5)

//martian wallholes
/datum/fishing_spot/martian_wallhole
	rod_tier_required = 2
	fishing_atom_type = /obj/crevice
	fish_available = list(/obj/item/fish/meat_mutant = 10,\
	/obj/item/parts/human_parts/arm/left = 10,\
	/obj/item/parts/human_parts/arm/right = 10,\
	/obj/item/parts/human_parts/leg/left = 10,\
	/obj/item/parts/human_parts/leg/right =10,\
	/obj/item/organ/brain = 10,\
	/mob/living/critter/martian = 15)

//telesci void rift
/datum/fishing_spot/void_rift
	fishing_atom_type = /obj/dfissure_to
	rod_tier_required = 3
	fish_available = list(/obj/item/fish/void_fish = 50)

//engine furnace
/datum/fishing_spot/furnace
	fishing_atom_type = /obj/machinery/power/furnace/thermo
	rod_tier_required = 2
	fish_available = list(/obj/item/fish/firefish = 50)

//#1 HOS mug
/datum/fishing_spot/hosmug
	fishing_atom_type = /obj/item/reagent_containers/food/drinks/mug/HoS
	rod_tier_required = 1
	fish_available = list(/obj/item/paper/book/from_file/space_law = 50)

//vending machines
/datum/fishing_spot/vending
	fishing_atom_type = /obj/machinery/vending
	rod_tier_required = 1
	fish_available = list(/obj/item/coin = 25,\
	/obj/item/spacecash/random/really_small = 20)

//Arc electroplater
/datum/fishing_spot/arc_electroplater
	fishing_atom_type = /obj/machinery/arc_electroplater
	rod_tier_required = 3
	fish_available = list(/obj/item/fish/firefish = 50)

//golden toilet
datum/fishing_spot/golden_toilet
	fishing_atom_type = /obj/item/storage/toilet/goldentoilet
	rod_tier_required = 2
	fish_available = list( /obj/item/reagent_containers/food/snacks/yuck = 20, \
	/obj/item/reagent_containers/food/snacks/yuckburn = 20, \
	/obj/item/reagent_containers/food/snacks/shell = 20, \
	/obj/item/reagent_containers/food/snacks/burger/moldy = 5, \
	/obj/item/raw_material/scrap_metal = 5, \
	/obj/item/reagent_containers/food/snacks/fish_fingers = 10)

	generate_fish(var/mob/user, var/obj/item/fishing_rod/fishing_rod, atom/target)
		var/atom/result = ..()
		result.setMaterial(getMaterial("gold"))
		return result

//crusher
/datum/fishing_spot/crusher
	fishing_atom_type = /obj/machinery/crusher
	rod_tier_required = 2
	fish_available = list(/obj/item/clothing/under/trash_bag = 10,\
	/mob/living/critter/small_animal/cockroach = 10,\
	/obj/item/c_tube = 10,\
	/obj/item/raw_material/shard/glass = 10,\
	/obj/item/cigbutt = 20,\
	/obj/item/reagent_containers/food/drinks/bottle/empty = 20,\
	/obj/machinery/light/small/broken = 20)

//nadir ocean
/datum/fishing_spot/nadir_ocean
	fishing_atom_type = /turf/space/fluid/acid
	rod_tier_required = 2
	fish_available = list(/obj/item/fish/clownfish = 15,\
	/obj/item/fish/damselfish = 10,\
	/obj/item/fish/green_chromis = 10,\
	/obj/item/fish/cardinalfish = 5,\
	/obj/item/fish/royal_gramma = 10,\
	/obj/item/fish/bc_angelfish = 5,\
	/obj/item/fish/blue_tang = 15,\
	/obj/item/fish/firefish = 5,\
	/obj/item/fish/yellow_tang = 10,\
	/obj/item/fish/mandarin_fish = 5)

//elevator shafts
/datum/fishing_spot/elevator_shaft
	fishing_atom_type = /turf/simulated/floor/specialroom/sea_elevator_shaft
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/herring = 40,\
	/obj/item/fish/tuna = 30,\
	/obj/item/fish/cod = 20,\
	/obj/item/fish/flounder = 15,\
	/obj/critter/slug = 10,\
	/mob/living/critter/small_animal/snake = 10,\
	/obj/critter/frog = 10)

//chemical barrel
/datum/fishing_spot/chemical_barrel
	fishing_atom_type = /obj/reagent_dispensers/chemicalbarrel
	rod_tier_required = 1
	fish_available = list(/obj/item/fish/clownfish = 40,\
	/obj/item/fish/damselfish = 30,\
	/obj/item/fish/green_chromis = 20,\
	/obj/item/fish/cardinalfish = 15,\
	/obj/item/fish/royal_gramma = 10,\
	/obj/item/fish/bc_angelfish = 10,\
	/obj/item/fish/blue_tang = 15,\
	/obj/item/fish/firefish = 5,\
	/obj/item/fish/yellow_tang = 15,\
	/obj/item/fish/mandarin_fish = 5)

//ice cream machine
/datum/fishing_spot/ice_cream_machine
	fishing_atom_type = /obj/submachine/ice_cream_dispenser
	rod_tier_required = 2
	fish_available = list(/obj/item/reagent_containers/food/snacks/condiment/chocchips = 40,\
	/obj/item/reagent_containers/food/snacks/condiment/custard = 30,\
	/obj/item/reagent_containers/food/snacks/condiment/cream = 20,\
	/obj/item/reagent_containers/food/snacks/condiment/syrup = 15,\
	/obj/item/raw_material/ice = 35,\
	/obj/item/fish/yellow_tang = 10,\
	/obj/item/reagent_containers/food/snacks/ice_cream/goodrandom = 30)

//mainframe
/datum/fishing_spot/mainframe
	fishing_atom_type = /obj/machinery/networked/mainframe/zeta
	rod_tier_required = 3
	fish_available = list(/obj/item/fish/code_worm = 50,\
	/obj/item/disk/data/tape/boot2 = 30,\
	/obj/item/disk/data/floppy/demo = 25,\
	/obj/item/disk/data/cartridge/clown = 15,\
	/obj/item/disk/data/cartridge/ringtone_beepy = 5)
