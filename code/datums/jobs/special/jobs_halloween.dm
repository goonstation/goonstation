/*
 * Halloween jobs
 */
ABSTRACT_TYPE(/datum/job/special/halloween)
/datum/job/special/halloween
	ui_colour = TGUI_COLOUR_ORANGE
	job_category = JOB_HALLOWEEN
	wiki_link = "https://wiki.ss13.co/Jobs#Spooktober_Jobs"
#ifdef HALLOWEEN
	limit = 1
#else
	limit = 0
#endif

	New()
		. = ..()
		if(prob(80))
			src.limit = 0

/datum/job/special/halloween/blue_clown
	name = "Blue Clown"
	wages = PAY_DUMBCLOWN
	trait_list = list("training_clown")
	access_string = "Clown"
	change_name_on_spawn = TRUE
	slot_back = list()
	slot_mask = list(/obj/item/clothing/mask/clown_hat/blue)
	slot_ears = list(/obj/item/device/radio/headset/clown)
	slot_jump = list(/obj/item/clothing/under/misc/clown/blue)
	slot_card = /obj/item/card/id/clown
	slot_foot = list(/obj/item/clothing/shoes/clown_shoes/blue)
	slot_belt = list(/obj/item/storage/fanny/funny)
	slot_poc1 = list(/obj/item/bananapeel)
	slot_poc2 = list(/obj/item/device/pda2/clown)
	slot_lhan = list(/obj/item/instrument/bikehorn)

	faction = list(FACTION_CLOWN)

	special_setup(var/mob/living/carbon/human/M)
		..()
		M.bioHolder.AddEffect("regenerator", magical=1)

/datum/job/special/halloween/candy_salesman
	name = "Candy Salesman"
	wages = PAY_UNTRAINED
	access_string = "Salesman"
	slot_head = list(/obj/item/clothing/head/that/purple)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/suit/purple)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/storage/pill_bottle/cyberpunk)
	slot_poc2 = list(/obj/item/storage/pill_bottle/catdrugs)
	items_in_backpack = list(/obj/item/storage/goodybag, /obj/item/kitchen/everyflavor_box, /obj/item/item_box/heartcandy, /obj/item/kitchen/peach_rings)

/datum/job/special/halloween/pumpkin_head
	name = "Pumpkin Head"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/pumpkin)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/color/orange)
	slot_foot = list(/obj/item/clothing/shoes/orange)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/reagent_containers/food/snacks/candy/candy_corn)
	slot_poc2 = list(/obj/item/item_box/assorted/stickers/stickers_limited)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("quiet_voice", magical=1)

/datum/job/special/halloween/wanna_bee
	name = "WannaBEE"
	wages = PAY_UNTRAINED
	access_string = "Botanist"
	slot_head = list(/obj/item/clothing/head/headband/bee)
	slot_suit = list(/obj/item/clothing/suit/bee)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/rank/beekeeper)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/reagent_containers/food/snacks/ingredient/egg/bee)
	slot_poc2 = list(/obj/item/reagent_containers/food/snacks/ingredient/egg/bee/buddy)
	items_in_backpack = list(/obj/item/reagent_containers/food/snacks/b_cupcake, /obj/item/reagent_containers/food/snacks/ingredient/royal_jelly)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("drunk_bee", magical=1)

/datum/job/special/halloween/dracula
	name = "Discount Dracula"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/that)
	slot_suit = list(/obj/item/clothing/suit/gimmick/vampire)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/gimmick/vampire)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/reagent_containers/syringe)
	slot_poc2 = list(/obj/item/reagent_containers/glass/beaker/large)
	slot_back = list(/obj/item/storage/backpack/satchel)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("aura", magical=1)
		M.bioHolder.AddEffect("cloak_of_darkness", magical=1)

/datum/job/special/halloween/werewolf
	name = "Discount Werewolf"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/werewolf)
	slot_jump = list(/obj/item/clothing/under/shorts)
	slot_suit = list(/obj/item/clothing/suit/gimmick/werewolf)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_belt = list(/obj/item/device/pda2)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("jumpy", magical=1)

/datum/job/special/halloween/mummy
	name = "Discount Mummy"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	change_name_on_spawn = TRUE
	slot_mask = list(/obj/item/clothing/mask/mummy)
	slot_jump = list(/obj/item/clothing/under/gimmick/mummy)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_belt = list(/obj/item/device/pda2)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("aura", magical=1)
		M.bioHolder.AddEffect("midas", magical=1)

/datum/job/special/halloween/hotdog
	name = "Hot Dog"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	change_name_on_spawn = TRUE
	slot_jump = list(/obj/item/clothing/under/shorts)
	slot_suit = list(/obj/item/clothing/suit/gimmick/hotdog)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_belt = list(/obj/item/device/pda2)
	slot_back = list(/obj/item/storage/backpack/satchel/randoseru)
	slot_poc1 = list(/obj/item/shaker/ketchup)
	slot_poc2 = list(/obj/item/shaker/mustard)

/datum/job/special/halloween/godzilla
	name = "Discount Godzilla"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/biglizard)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/color/green)
	slot_suit = list(/obj/item/clothing/suit/gimmick/dinosaur)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/toy/figure)
	slot_poc2 = list(/obj/item/toy/figure)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("lizard", magical=1)
		M.bioHolder.AddEffect("loud_voice", magical=1)

/datum/job/special/halloween/macho
	name = "Discount Macho Man"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/helmet/macho)
	slot_eyes = list(/obj/item/clothing/glasses/macho)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/gimmick/macho)
	slot_foot = list(/obj/item/clothing/shoes/macho)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/reagent_containers/food/snacks/ingredient/sugar)
	slot_poc2 = list(/obj/item/sticker/ribbon/first_place)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("accent_chav", magical=1)

/datum/job/special/halloween/ghost
	name = "Ghost"
	wages = PAY_UNTRAINED
	change_name_on_spawn = TRUE
	slot_eyes = list(/obj/item/clothing/glasses/regular/ecto/goggles)
	slot_suit = list(/obj/item/clothing/suit/bedsheet)
	slot_ears = list(/obj/item/device/radio/headset)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("chameleon", magical=1)

/datum/job/special/halloween/ghost_buster
	name = "Ghost Buster"
	wages = PAY_UNTRAINED
	request_limit = 1
	request_cost = PAY_EXECUTIVE * 4
	access_string = "Staff Assistant"
	change_name_on_spawn = TRUE
	slot_ears = list(/obj/item/device/radio/headset/ghost_buster)
	slot_eyes = list(/obj/item/clothing/glasses/regular/ecto/goggles)
	slot_jump = list(/obj/item/clothing/under/shirt_pants)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/magnifying_glass)
	slot_poc2 = list(/obj/item/shaker/salt)
	items_in_backpack = list(/obj/item/device/camera_viewer/security, /obj/item/device/audio_log, /obj/item/gun/energy/ghost)
	alt_names = list("Paranormal Activities Investigator", "Spooks Specialist")
	change_name_on_spawn = TRUE

/datum/job/special/halloween/angel
	name = "Angel"
	wages = PAY_UNTRAINED
	trait_list = list("training_chaplain")
	access_string = "Chaplain"
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/laurels/gold)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/gimmick/birdman)
	slot_foot = list(/obj/item/clothing/shoes/sandal)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/coin)
	slot_poc2 = list(/obj/item/plant/herb/cannabis/white/spawnable)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("shiny", magical=1)
		M.bioHolder.AddEffect("healing_touch", magical=1)

/datum/job/special/halloween/vendor
	name = "Costume Vendor"
	wages = PAY_TRADESMAN
	change_name_on_spawn = TRUE
	slot_jump = list(/obj/item/clothing/under/gimmick/trashsinglet)
	slot_foot = list(/obj/item/clothing/shoes/sandal)
	slot_belt = list(/obj/item/device/pda2)
	slot_back = list(/obj/item/storage/backpack/satchel/anello)
	items_in_backpack = list(/obj/item/storage/box/costume/abomination,
	/obj/item/storage/box/costume/werewolf/odd,
	/obj/item/storage/box/costume/monkey,
	/obj/item/storage/box/costume/eighties,
	/obj/item/clothing/head/zombie)

/datum/job/special/halloween/devil
	name = "Devil"
	wages = PAY_UNTRAINED
	access_string = "Chaplain"
	limit = 0
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/headband/devil)
	slot_mask = list(/obj/item/clothing/mask/moustache/safe)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/misc/lawyer/red/demonic)
	slot_foot = list(/obj/item/clothing/shoes/sandal)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/pen/fancy/satan)
	slot_poc2 = list(/obj/item/contract/juggle)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("hell_fire", magical=1)

/datum/job/special/halloween/superhero
	name = "Discount Vigilante Superhero"
	wages = PAY_UNTRAINED
	trait_list = list("training_security")
	access_string = "Staff Assistant"
	limit = 0
	change_name_on_spawn = TRUE
	can_roll_antag = FALSE
	receives_miranda = TRUE
	slot_ears = list(/obj/item/device/radio/headset/security)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud/superhero)
	slot_glov = list(/obj/item/clothing/gloves/latex/blue)
	slot_jump = list(/obj/item/clothing/under/gimmick/superhero)
	slot_foot = list(/obj/item/clothing/shoes/tourist)
	slot_belt = list(/obj/item/storage/belt/utility/superhero)
	slot_back = list()
	slot_poc2 = list(/obj/item/device/pda2)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if(prob(60))
			var/aggressive = pick("eyebeams","cryokinesis")
			var/defensive = pick("fire_resist","cold_resist","rad_resist","breathless") // no thermal resist, gotta have some sort of comic book weakness
			var/datum/bioEffect/power/be = M.bioHolder.AddEffect(aggressive, do_stability=0)
			if(aggressive == "eyebeams")
				var/datum/bioEffect/power/eyebeams/eb = be
				eb.stun_mode = 1
				eb.altered = 1
			else
				be.power = 1
				be.altered = 1
			be = M.bioHolder.AddEffect(defensive, do_stability=0)
		else
			var/datum/bioEffect/power/shoot_limb/sl = M.bioHolder.AddEffect("shoot_limb", do_stability=0)
			sl.safety = 1
			sl.altered = 1
			sl.cooldown = 300
			sl.stun_mode = 1
			var/datum/bioEffect/regenerator/r = M.bioHolder.AddEffect("regenerator", do_stability=0)
			r.regrow_prob = 10
		var/datum/bioEffect/power/be = M.bioHolder.AddEffect("adrenaline", do_stability=0)
		be.safety = 1
		be.altered = 1

	get_default_miranda()
		return "Evildoer! You have been apprehended by a hero of space justice!"

/datum/job/special/halloween/pickle
	name = "Pickle"
	wages = PAY_DUMBCLOWN
	access_string = "Staff Assistant"
	change_name_on_spawn = TRUE
	slot_ears = list(/obj/item/device/radio/headset)
	slot_suit = list(/obj/item/clothing/suit/gimmick/pickle)
	slot_jump = list(/obj/item/clothing/under/color/green)
	slot_belt = list(/obj/item/device/pda2)
	slot_foot = list(/obj/item/clothing/shoes/black)

	New()
		. = ..()
		if (prob(0.1))
			src.limit = 1 //rare pickle

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/obj/item/trinket = M.trinket?.deref()
		trinket?.setMaterial(getMaterial("pickle"))
		for (var/i in 1 to 3)
			var/type = pick(trinket_safelist)
			var/obj/item/pickle = new type(M.loc)
			pickle.setMaterial(getMaterial("pickle"))
			M.equip_if_possible(pickle, SLOT_IN_BACKPACK)
		M.bioHolder.RemoveEffect("midas") //just in case mildly mutated has given us midas I guess?
		M.bioHolder.AddEffect("pickle", magical=TRUE)
		M.blood_id = "juice_pickle"

/datum/job/special/halloween/cowboy
	name = "Space Cowboy"
	ui_colour = TGUI_COLOUR_BLUE
	wages = PAY_UNTRAINED
	starting_mutantrace = /datum/mutantrace/cow
	badge = /obj/item/clothing/suit/security_badge
	change_name_on_spawn = TRUE
	access_string = "Rancher" // it didnt actually have a unique string
	slot_jump = list(/obj/item/clothing/under/rank/det)
	slot_suit = list(/obj/item/clothing/suit/poncho)
	slot_belt = list(/obj/item/storage/belt/rancher/cowboy)
	slot_head = list(/obj/item/clothing/head/cowboy)
	slot_mask = list(/obj/item/clothing/mask/cigarette/random)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_foot = list(/obj/item/clothing/shoes/cowboy)
	slot_card = /obj/item/card/id/civilian
	slot_poc1 = list(/obj/item/device/pda2/botanist)
	slot_poc2 = list(/obj/item/device/light/zippo/gold)
	slot_back = list(/obj/item/storage/backpack/satchel/brown)

/datum/job/special/halloween/wizard
	name = "Discount Wizard"
	wages = PAY_UNTRAINED
	change_name_on_spawn = TRUE
	access_string = "Staff Assistant"
	slot_jump = list(/obj/item/clothing/under/shorts/black)
	slot_suit = list(/obj/item/clothing/suit/bathrobe)
	slot_head = list(/obj/item/clothing/head/apprentice)
	slot_foot = list(/obj/item/clothing/shoes/fuzzy)
	items_in_backpack = list(/obj/item/mop)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("melt", magical=1)

/datum/job/special/halloween/spy
	name = "Super Spy"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	slot_jump = list(/obj/item/clothing/under/suit/black)
	slot_eyes = list(/obj/item/clothing/glasses/eyepatch)
	slot_suit = list(/obj/item/clothing/suit/armor/sneaking_suit/costume)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	items_in_backpack = list(/obj/item/clothing/suit/cardboard_box )

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("chameleon", magical=1)

ABSTRACT_TYPE(/datum/job/special/halloween/critter)
/datum/job/special/halloween/critter
	wages = PAY_DUMBCLOWN
	trusted_only = TRUE
	can_roll_antag = FALSE
	slot_ears = list()
	slot_card = null
	slot_back = list()

	special_setup(var/mob/living/carbon/human/M)
		if (!M)
			return

		..()
		// Deactivate any gene that was activated by Mildly mutated trait
		M.bioHolder.DeactivateAllPoolEffects()

/datum/job/special/halloween/critter/plush
	name = "Plush Toy"
	trusted_only = FALSE
#ifdef HALLOWEEN
	limit = 2
#endif
	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.critterize(/mob/living/critter/small_animal/plush/cryptid)

/datum/job/special/halloween/critter/remy
	name = "Remy"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/mob/living/critter/C = M.critterize(/mob/living/critter/small_animal/mouse/remy)
		C.flags = null

/datum/job/special/halloween/critter/bumblespider
	name = "Bumblespider"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/mob/living/critter/C = M.critterize(/mob/living/critter/spider/nice)
		C.flags = null

/datum/job/special/halloween/critter/crow
	name = "Crow"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/mob/living/critter/C = M.critterize(/mob/living/critter/small_animal/bird/crow)
		C.flags = null
