/// This code handles different lootpools for fishing
/// A fishing_lootpool is a datum that stores unified loottables for certain conditions on fishing
/// These loottables created in new()of a fishing spot and are added to a fishing spot.
/// These, in contrast to fishing spots, are NOT singletons, since they can be added and removed dynamically (for cases such as a fishing component)
/// Once someone tries to fish somewhere, proc/generate_fish iterate through all fishing_lootpools and generates a list to pick its fish from
/// Since fishing_lootpools have their own conditionals, this enables different loottables for e.g. different tier rods or other things such as baits
/// When adding loottables, is should be paid attention to that a loottable is avaible there.

/datum/fishing_lootpool
	/// associative list with the format (fish_type = probability), doesnt need to be ordered in descending probability
	var/list/fish_available = null
	/// what tier of rod do you need at least to fish here? current rods are tier 1,2 & 3
	var/minimum_rod_tier = 0
	/// what tier of rod is the highest to have access to the lootable?
	var/maximum_rod_tier = INFINITY
	/// what kind of food item is needed as a lure
	var/obj/item/reagent_containers/food/required_lure = null

/// This proc checks for all the conditionals that could apply to a fishing spot. Modify that for special conditions.
/datum/fishing_lootpool/proc/check_conditionals(var/mob/user, var/obj/item/fishing_rod/fishing_rod)
	. = TRUE
	if(fishing_rod?.tier < src.minimum_rod_tier || fishing_rod?.tier > src.maximum_rod_tier)
		return FALSE
	if (required_lure != null)
		var/obj/item/lure = fishing_rod?.get_lure()
		if (!istype(lure, required_lure)) return FALSE

/// This proc generates a new loottable out of a given current one
/datum/fishing_lootpool/proc/generate_loot(var/list/current_loottable, var/mob/user, var/obj/item/fishing_rod/fishing_rod)
	var/list/result = list()
	result += current_loottable
	if (length(src.fish_available))
		for (var/fish in src.fish_available)
			// we add the weightings of our list onto the other.
			result[fish] += src.fish_available[fish]
	//then we return the list again
	return result

/// Here can the lootpools be found

///Standard lootpool for the standard fishing tank
/datum/fishing_lootpool/standard
	fish_available = list(/obj/item/reagent_containers/food/fish/goldfish = 30,\
	/obj/item/reagent_containers/food/fish/bass = 20,\
	/obj/item/reagent_containers/food/fish/salmon = 20,\
	/obj/item/reagent_containers/food/fish/carp = 15,\
	/obj/item/reagent_containers/food/fish/rainbow_trout = 10,\
	/obj/item/reagent_containers/food/fish/chub = 10,\
	/obj/item/reagent_containers/food/fish/pike = 10,\
	/obj/item/reagent_containers/food/fish/eel = 15,\
	/obj/item/reagent_containers/food/fish/catfish = 20,\
	/obj/item/reagent_containers/food/fish/bass = 30,\
	/obj/item/reagent_containers/food/fish/salmon = 20,\
	/obj/item/reagent_containers/food/fish/herring = 15,\
	/obj/item/reagent_containers/food/fish/sardine = 20)

///lava fish as T3 fish for fire-sources
/datum/fishing_lootpool/lava_fish
	minimum_rod_tier = 3
	fish_available = list(/obj/item/reagent_containers/food/fish/lava_fish = 25)

///extra loot from their shoes for clowns only
/datum/fishing_lootpool/clown_shoes_loot
	fish_available = list(/obj/item/bananapeel = 40, \
	/obj/item/instrument/bikehorn = 20, \
	/obj/item/instrument/bikehorn/dramatic = 5)

/datum/fishing_lootpool/clown_shoes_loot/check_conditionals(mob/user, obj/item/fishing_rod/fishing_rod)
	. = ..()
	//clown-only-zone
	if(!(user.bioHolder.HasEffect("clumsy")))
		return FALSE

///requires meat to get pufferfish from exotic sources
/datum/fishing_lootpool/pufferfish
	required_lure = /obj/item/reagent_containers/food/snacks/ingredient/meat
	fish_available = list(/obj/item/reagent_containers/food/fish/pufferfish = 25)

///REAL goldfish will eat the FAKE goldfish
/datum/fishing_lootpool/real_goldfish
	required_lure = /obj/item/reagent_containers/food/fish/goldfish
	fish_available = list(/obj/item/reagent_containers/food/fish/real_goldfish = 10)

///tiny junk items you can find in vending machines and others.
/datum/fishing_lootpool/tiny_junk
	fish_available = list(/obj/item/reagent_containers/food/snacks/burger/moldy = 5, \
	/obj/item/coin = 15, \
	/mob/living/critter/small_animal/cockroach = 1, \
	/obj/item/currency/buttcoin = 10, \
	/obj/item/currency/spacecash/really_small = 20, \
	/obj/item/cigbutt = 5)

///charred items you potentionally can find in lava or the oven in the kitchen
/datum/fishing_lootpool/charred_remains
	fish_available = list(/obj/item/material_piece/slag = 20,\
	/obj/decal/cleanable/ash = 20,\
	/obj/item/reagent_containers/food/snacks/yuck/burn = 20,\
	/obj/item/raw_material/char =20)

///A mid-tier fish you can find in hot places.
/datum/fishing_lootpool/igneous_fish
	minimum_rod_tier = 2
	fish_available = list(/obj/item/reagent_containers/food/fish/igneous_fish = 10)
