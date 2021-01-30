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

/// called every time a fishing rod's action loop finishes. returns 0 if catching a fish failed, returns 1 if it succeeds
/datum/fishing_spot/proc/try_fish(var/mob/user, var/obj/item/fishing_rod/fishing_rod)
	if (length(src.fish_available))
		var/fish_path = weighted_pick(src.fish_available)
		var/atom/movable/fish = new fish_path()
		if (!fish)
			return 0
		// ever put this much effort into the dumbest thing ever haha
		user.visible_message("[user] [pick("reels in", "catches", "pulls in", "fishes up")] a \
		[pick("big", "wriggly", "fat", "slimy", "fishy", "large", "high-quality", "nasty", "chompy", "real", "wily")] \
		[prob(80) ? "[fish.name]" : pick("one", "catch", "chomper", "wriggler", "sunovabitch", "sucker")]!")
		fish.set_loc(get_turf(user))
		playsound(get_turf(user), "sound/items/fishing_rod_reel.ogg", 50, 1)
		fishing_rod.last_fished = TIME //set the last fished time
		return 1
	else
		return 0

/datum/fishing_spot/sea
	fishing_atom_type = /turf/space/fluid
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5)

/datum/fishing_spot/test
	fishing_atom_type = /turf/simulated/floor/ancient
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5)
	do_not_generate = 1
