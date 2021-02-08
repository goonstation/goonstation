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
		var/list/fishing_spot_children = concrete_typesof(fishing_spot.fishing_atom_type)
		for (var/spotchild in fishing_spot_children)
			global.fishing_spots[spotchild] = fishing_spot
		//var/fishing_atom_type = fishing_spot.fishing_atom_type
		//global.fishing_spots[fishing_atom_type] = fishing_spot

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
	[prob(80) ? "[fish.name]" : pick("one", "catch", "chomper", "wriggler", "sunovabitch", "sucker")]!")
	fish.set_loc(get_turf(user))
	playsound(get_turf(user), "sound/items/fishing_rod_reel.ogg", 50, 1)
	fishing_rod.last_fished = TIME //set the last fished time
	return 1

/datum/fishing_spot/sea
	fishing_atom_type = /turf/space/fluid
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5)

/datum/fishing_spot/sea/dojo
	fishing_atom_type = /turf/unsimulated/wall/water

/datum/fishing_spot/sea/river
	fishing_atom_type = /obj/river

/datum/fishing_spot/sea/watertanks
	fishing_atom_type = /obj/reagent_dispensers/watertank

/datum/fishing_spot/sea/deeptrench
	fishing_atom_type = /turf/unsimulated/floor/polarispit

/datum/fishing_spot/beer
	fishing_atom_type = /obj/reagent_dispensers/beerkeg
	fish_available = list(/obj/item/fish/carp = 400,\
	/obj/item/fish/bass = 300,\
	/obj/item/fish/salmon = 200,\
	/obj/item/fish/herring = 150,\
	/obj/item/fish/red_herring = 50,\
	/mob/living/carbon/human/biker = 5)

/datum/fishing_spot/clonepod
	fishing_atom_type = /obj/machinery/clonepod
	fish_available = list(/obj/item/fish/carp = 400,\
	/obj/item/fish/bass = 300,\
	/obj/item/fish/salmon = 200,\
	/obj/item/fish/herring = 150,\
	/obj/item/fish/red_herring = 50,\
	/mob/living/carbon/human/biker = 1,\
	/mob/living/carbon/human/fatherted = 1,\
	/mob/living/carbon/human/fatherjack = 1,\
	/mob/living/carbon/human/don_glab = 1,\
	/mob/living/carbon/human/spacer = 1,\
	/mob/living/carbon/human/tommy = 1,\
	/mob/living/carbon/human/npc/assistant = 1,\
	/mob/living/carbon/human/npc/syndicate_weak = 1,\
	/mob/living/carbon/human/npc/monkey/angry = 1,\
	/mob/living/carbon/human/future = 1)

/datum/fishing_spot/test
	fishing_atom_type = /turf/simulated/floor/ancient
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5)
	do_not_generate = 1

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
	/obj/item/record/random = 4,\
	/obj/critter/domestic_bee/trauma = 20)

/datum/fishing_spot/spatial_tear/wormhole
	fishing_atom_type = /obj/portal/wormhole

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

/datum/fishing_spot/toilet
	fishing_atom_type = /obj/item/storage/toilet
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5,\
	/obj/item/reagent_containers/food/snacks/burrito = 10,\
	/obj/item/clothing/head/plunger = 3,\
	/obj/item/reagent_containers/pill/cyberpunk = 3,\
	/obj/item/reagent_containers/syringe/jenkem = 3,\
	/obj/item/hairball/inert = 2,\
	/obj/item/electronics/scanner = 2,\
	/obj/item/skull = 2,\
	/obj/item/clothing/gloves/ring/gold = 1,\
	/obj/item/clothing/mask/niccage = 1,\
	/obj/item/clothing/head/DONOTSTEAL = 1)

/datum/fishing_spot/sink
	fishing_atom_type = /obj/submachine/chef_sink
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5,\
	/obj/item/coin = 5,\
	/obj/item/reagent_containers/food/snacks/goldfish_cracker = 4,\
	/obj/item/hairball/inert = 2,\
	/obj/item/clothing/gloves/ring/gold = 1,\
	/obj/critter/snake = 1,\
	/obj/item/reagent_containers/food/snacks/condiment/custard = 1,\
	/obj/item/reagent_containers/food/snacks/haggis = 1) //snake, custard, and haggis are nethack references, haggis is a meat "pudding"

/datum/fishing_spot/pool
	fishing_atom_type = /turf/simulated/pool
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5,\
	/obj/item/beach_ball = 3,\
	/obj/item/clothing/shoes/flippers = 3,\
	/obj/item/clothing/gloves/water_wings = 3,\
	/obj/item/inner_tube/random = 3,\
	/obj/item/reagent_containers/food/drinks/curacao = 3,\
	/obj/item/rubberduck = 2,\
	/obj/item/organ/chest = 1,\
	/obj/item/reagent_containers/food/drinks/rum_spaced = 1) //get it, a chest, like a treasure chest, pffft ha

/datum/fishing_spot/pool/unsimulated
	fishing_atom_type = /turf/unsimulated/floor/pool

/datum/fishing_spot/bathtub
	fishing_atom_type = /obj/machinery/bathtub
	fish_available = list(/obj/item/fish/carp = 40,\
	/obj/item/fish/bass = 30,\
	/obj/item/fish/salmon = 20,\
	/obj/item/fish/herring = 15,\
	/obj/item/fish/red_herring = 5,\
	/obj/item/sponge = 3,\
	/obj/item/rubberduck = 2,\
	/obj/item/reagent_containers/bath_bomb = 2,\
	/obj/item/hairball/inert = 2,\
	/obj/item/reagent_containers/glass/bottle/bubblebath = 2,\
	/obj/critter/spider/baby = 1,\
	/obj/critter/mouse = 1,\
	/obj/critter/turtle = 1,\
	/obj/item/kitchen/utensil/knife = 1,\
	/obj/item/reagent_containers/food/snacks/condiment/syrup = 1) //hitchcock references

/datum/fishing_spot/bathtub/drain
	fishing_atom_type = /obj/machinery/drainage

/datum/fishing_spot/acid
	fishing_atom_type = /turf/unsimulated/floor/setpieces/bloodfloor/stomach
	fish_available = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat = 40,\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 30,\
	/obj/item/reagent_containers/food/snacks/bite = 30,\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/spicy = 5,\
	/obj/item/parts/human_parts/arm/mutant/skeleton/left = 5,\
	/obj/item/parts/human_parts/arm/mutant/skeleton/right = 5,\
	/obj/item/parts/human_parts/leg/mutant/skeleton/left = 5,\
	/obj/item/parts/human_parts/leg/mutant/skeleton/right = 5,\
	/obj/item/material_piece/bone = 5,\
	/obj/item/reagent_containers/food/snacks/spaghetti/sauce/skeletal = 1,\
	/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/skeleton = 1,\
	/obj/item/power_stones/Gall = 1)

/datum/fishing_spot/acid/actualacid
	fishing_atom_type = /obj/stomachacid

/datum/fishing_spot/lava
	fishing_atom_type = /turf/unsimulated/floor/lava
	fish_available = list(/obj/item/reagent_containers/food/snacks/yuckburn = 900,\
	/obj/item/reagent_containers/food/snacks/shell = 100,\
	/obj/item/reagent_containers/food/snacks/strudel = 100,\
	/obj/critter/lavacrab = 50,\
	/obj/item/decoration/ashtray = 50,\
	/obj/item/clothing/head/devil = 50,\
	/obj/item/property_setter/thermal = 10,\
	/obj/item/wizard_crystal/ruby = 10,\
	/obj/item/property_setter/fire_jewel = 1,\
	/obj/item/mutation_orb/fire_orb = 1,\
	/obj/item/potion = 1)
