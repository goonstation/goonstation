#define LANDMARK_PIRATE "Pirate-Spawn"
#define LANDMARK_PIRATE_FIRST_MATE "Pirate-First-Mate-Spawn"
#define LANDMARK_PIRATE_CAPTAIN "Pirate-Captain-Spawn"

/area/pirate_ship
	name = "Peregrine"
	icon_state = "red"
	teleport_blocked = 1
	do_not_irradiate = TRUE

// These are needed because Load Area seems to have issues with ordinary var-edited landmarks.
/obj/landmark/pirate
	name = "Pirate-Spawn"

	first_mate
		name = "Pirate-First-Mate-Spawn"

	captain
		name = "Pirate-Captain-Spawn"

/obj/critter/parrot/macaw/pirate
	name = "Sharkbait"
	species = "smacaw"
	learn_phrase_chance = 0
	learn_words_chance = 0
	learned_phrases = list("YARR!")
	learned_words = list("YARR!")
	icon_state = "smacaw"
	dead_state = "smacaw"

/obj/item/clothing/suit/armor/pirate_captain_coat
	name = "pirate captain's coat"
	desc = "A dread inducing red and black greatcoat, worn by only the greatest of mass larcenists. Probably stolen."
	icon_state = "pirate_captain"
	item_state = "pirate_captain"
	hides_from_examine = 0
	setupProperties()
		..()
		setProperty("coldprot", 35)
		setProperty("heatprot", 35)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 0.9)

/obj/item/clothing/head/pirate_captain
	name = "pirate captain's hat"
	desc = "A traditional pirate tricorne, adorned with a crimson feather, just to tell everyone who's boss."
	icon_state = "pirate_captain"
	item_state = "pirate_captain"

/obj/item/clothing/glasses/eyepatch/pirate
	name = "pirate's eyepatch"
	pinhole = TRUE
	block_eye = null

	New()
		..()
		var/eye_covered
		if (prob(50))
			eye_covered = "L"
		else
			eye_covered = "R"
		src.icon_state = "eyepatch-[eye_covered]"

/datum/job/special/pirate
	linkcolor = "#880000"
	name = "Space Pirate"
	limit = 0
	wages = 0
	add_to_manifest = FALSE
	radio_announcement = FALSE
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	special_spawn_location = LANDMARK_PIRATE
	slot_card = /obj/item/card/id
	slot_belt = list()
	slot_back = list(/obj/item/storage/backpack)
	slot_jump = list(/obj/item/clothing/under/gimmick/guybrush)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_head = list(/obj/item/clothing/head/bandana/red)
	slot_eyes = list(/obj/item/clothing/glasses/eyepatch/pirate)
	slot_ears = list(/obj/item/device/radio/headset/syndicate)
	slot_poc1 = list()
	slot_poc2 = list()
	var/random_clothing = TRUE

	New()
		..()
		src.access = list(access_maint_tunnels, access_syndicate_shuttle)
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		if (random_clothing == TRUE)
			slot_jump = list(pick(/obj/item/clothing/under/gimmick/waldo,
							/obj/item/clothing/under/misc/serpico,
							/obj/item/clothing/under/gimmick/guybrush,
							/obj/item/clothing/under/misc/dirty_vest))
			slot_head = list(pick(/obj/item/clothing/head/red,
							/obj/item/clothing/head/bandana/red,
							/obj/item/clothing/head/pirate_brn))

		M.traitHolder.addTrait("training_drinker")


	first_mate
		name = "Space Pirate First Mate"
		slot_jump = list(/obj/item/clothing/under/gimmick/guybrush)
		slot_suit = list(/obj/item/clothing/suit/gimmick/guncoat/tan)
		slot_head = list(/obj/item/clothing/head/pirate_brn)
		random_clothing = FALSE
		special_spawn_location = LANDMARK_PIRATE_FIRST_MATE

	captain
		name = "Space Pirate Captain"
		slot_jump = list(/obj/item/clothing/under/shirt_pants_b)
		slot_suit = list(/obj/item/clothing/suit/armor/pirate_captain_coat)
		slot_head = list(/obj/item/clothing/head/pirate_captain)
		slot_foot = list(/obj/item/clothing/shoes/swat/heavy)
		random_clothing = FALSE
		special_spawn_location = LANDMARK_PIRATE_CAPTAIN
