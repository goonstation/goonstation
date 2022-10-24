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
	fish.set_loc(get_turf(user))
	playsound(user, 'sound/items/fishing_rod_reel.ogg', 50, 1)
	fishing_rod.last_fished = TIME //set the last fished time
	return 1

/datum/fishing_spot/sea
	fishing_atom_type = /turf/space/fluid
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5)

/datum/fishing_spot/swamp
	fishing_atom_type = /turf/unsimulated/floor/auto/swamp
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/critter/slug = 10,\
	/mob/living/critter/small_animal/snake = 10,\
	/obj/critter/frog = 10,\
	/obj/item/clothing/head/rafflesia = 5)

/datum/fishing_spot/test
	fishing_atom_type = /turf/simulated/floor/ancient
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5)
	do_not_generate = 1

/datum/fishing_spot/toilet
	fishing_atom_type = /obj/item/storage/toilet
	fish_available = list( /obj/item/reagent_containers/food/snacks/yuck = 20, \
	/obj/item/reagent_containers/food/snacks/yuckburn = 20, \
	/obj/item/reagent_containers/food/snacks/shell = 20, \
	/obj/item/reagent_containers/food/snacks/burger/moldy = 5, \
	/obj/item/raw_material/scrap_metal = 5, \
	/obj/item/reagent_containers/food/snacks/fish_fingers = 10)

/datum/fishing_spot/toilet/random
	fishing_atom_type = /obj/item/storage/toilet/random

/datum/fishing_spot/spatial_tear
	fishing_atom_type = /obj/forcefield/event
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
	/obj/critter/aberration = 1,\
	/obj/critter/cat = 2,\
	/obj/item/clothing/head/void_crown = 1,\
	/obj/item/record/spacebux = 4,\
	/obj/critter/domestic_bee/trauma = 20)

/datum/fishing_spot/fryer
	fishing_atom_type = /obj/machinery/deep_fryer
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5,\
	/obj/item/reagent_containers/food/snacks/yuckburn = 20,
	/obj/item/reagent_containers/food/snacks/fish_fingers = 10)

	generate_fish(var/mob/user, var/obj/item/fishing_rod/fishing_rod, atom/target)
		. = ..()
		if(!istype(., /obj/item/reagent_containers/food/snacks))
			var/obj/machinery/deep_fryer/fryer = target
			. = fryer.fryify(.)

/datum/fishing_spot/fish_portal
	fishing_atom_type = /obj/machinery/active_fish_portal
	fish_available = list(/obj/item/fish/salmon = 40,\
	/obj/item/fish/herring = 30,\
	/obj/item/fish/carp = 20,\
	/obj/item/fish/bass = 15,\
	/obj/item/fish/red_herring = 5)
