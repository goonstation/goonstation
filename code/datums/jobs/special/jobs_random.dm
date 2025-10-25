ABSTRACT_TYPE(/datum/job/special/random)
/datum/job/special/random
	limit = 0
	name = "Random"
	request_limit = 2
	request_cost = PAY_IMPORTANT*4

	New()
		..()
		if (src.alt_names.len)
			name = pick(src.alt_names)

/datum/job/special/random/radioshowhost
	name = "Radio Show Host"
	wages = PAY_TRADESMAN
	request_cost = PAY_DOCTORATE * 4
	access_string = "Radio Show Host"
#ifdef MAP_OVERRIDE_OSHAN
	special_spawn_location = null
	ui_colour = TGUI_COLOUR_BLUE
	limit = 1
#elif defined(MAP_OVERRIDE_NADIR)
	special_spawn_location = null
	ui_colour = TGUI_COLOUR_BLUE
	limit = 1
#else
	special_spawn_location = LANDMARK_RADIO_SHOW_HOST_SPAWN
#endif
	request_limit = 1 // limited workspace
	slot_ears = list(/obj/item/device/radio/headset/command/radio_show_host)
	slot_eyes = list(/obj/item/clothing/glasses/regular)
	slot_jump = list(/obj/item/clothing/under/shirt_pants)
	slot_card = /obj/item/card/id/civilian
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_belt = list(/obj/item/device/pda2)
	slot_poc1 = list(/obj/item/reagent_containers/food/drinks/coffee)
	items_in_backpack = list(/obj/item/device/camera_viewer/security, /obj/item/device/audio_log, /obj/item/storage/box/record/radio/host)
	alt_names = list("Radio Show Host", "Talk Show Host")
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Radio_Host"

/datum/job/special/random/souschef
	name = "Sous-Chef"
	request_cost = PAY_DOCTORATE * 4
	wages = PAY_UNTRAINED
	trait_list = list("training_chef")
	access_string = "Sous-Chef"
	requires_supervisor_job = "Chef"
	slot_belt = list(/obj/item/device/pda2/chef)
	slot_jump = list(/obj/item/clothing/under/misc/souschef)
	slot_foot = list(/obj/item/clothing/shoes/chef)
	slot_head = list(/obj/item/clothing/head/souschefhat)
	slot_suit = list(/obj/item/clothing/suit/apron)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	wiki_link = "https://wiki.ss13.co/Chef"

/datum/job/special/random/hall_monitor
	name = "Hall Monitor"
	wages = PAY_UNTRAINED
	access_string = "Hall Monitor"
	invalid_antagonist_roles = list(ROLE_HEAD_REVOLUTIONARY)
	badge = /obj/item/clothing/suit/security_badge/paper
	slot_belt = list(/obj/item/device/pda2)
	slot_jump = list(/obj/item/clothing/under/color/red)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_head = list(/obj/item/clothing/head/basecap/red)
	slot_poc1 = list(/obj/item/pen/pencil)
	slot_poc2 = list(/obj/item/device/radio/hall_monitor)
	items_in_backpack = list(/obj/item/instrument/whistle,/obj/item/device/ticket_writer/crust)

/datum/job/special/random/hollywood
	name = "Hollywood Actor"
	wages = PAY_UNTRAINED
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/suit/purple)
	special_spawn_location = LANDMARK_ACTOR_SPAWN

/datum/job/special/random/medical_specialist
	name = "Medical Specialist"
	ui_colour = TGUI_COLOUR_PINK
	wages = PAY_IMPORTANT
	trait_list = list("training_medical", "training_partysurgeon")
	access_string = "Medical Specialist"
	slot_card = /obj/item/card/id/medical
	slot_belt = list(/obj/item/storage/belt/medical/prepared)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/medic)
	slot_jump = list(/obj/item/clothing/under/scrub/maroon)
	slot_suit = list(/obj/item/clothing/suit/apron/surgeon)
	slot_head = list(/obj/item/clothing/head/bouffant)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_rhan = list(/obj/item/storage/firstaid/docbag)
	slot_poc1 = list(/obj/item/device/pda2/medical_director)
	alt_names = list(
		"Acupuncturist",
	  	"Anesthesiologist",
		"Cardiologist",
		"Dental Specialist",
		"Dermatologist",
		"Emergency Medicine Specialist",
		"Hematology Specialist",
		"Hepatology Specialist",
		"Immunology Specialist",
		"Internal Medicine Specialist",
		"Maxillofacial Specialist",
		"Medical Director's Assistant",
		"Neurological Specialist",
		"Ophthalmic Specialist",
		"Orthopaedic Specialist",
		"Otorhinolaryngology Specialist",
		"Plastic Surgeon",
		"Thoracic Specialist",
		"Vascular Specialist",
	)

/datum/job/special/random/vip
	name = "VIP"
	wages = PAY_EXECUTIVE
	access_string = "VIP"
	ui_colour = TGUI_COLOUR_RED
	request_cost = PAY_EMBEZZLED * 4 // they're on the take
	slot_jump = list(/obj/item/clothing/under/suit/black)
	slot_head = list(/obj/item/clothing/head/that)
	slot_eyes = list(/obj/item/clothing/glasses/monocle)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_lhan = list(/obj/item/storage/secure/sbriefcase)
	items_in_backpack = list(/obj/item/baton/cane)
	alt_names = list("Senator", "President", "Board Member", "Mayor", "Vice-President", "Governor")
	wiki_link = "https://wiki.ss13.co/VIP"

	special_setup(var/mob/living/carbon/human/M)
		..()

		var/obj/item/storage/secure/sbriefcase/B = M.find_type_in_hand(/obj/item/storage/secure/sbriefcase)
		if (B && istype(B))
			for (var/i = 1 to 2)
				B.storage.add_contents(new /obj/item/stamped_bullion(B))

		return

/datum/job/special/random/inspector
	name = "Inspector"
	wages = PAY_IMPORTANT
	ui_colour = TGUI_COLOUR_NAVY
	request_cost = PAY_EXECUTIVE * 4
	access_string = "Inspector"
	receives_miranda = TRUE
	invalid_antagonist_roles = list(ROLE_HEAD_REVOLUTIONARY)
	badge = /obj/item/clothing/suit/security_badge/nanotrasen
	slot_card = /obj/item/card/id/nanotrasen
	slot_back = list(/obj/item/storage/backpack)
	slot_belt = list(/obj/item/device/pda2/ntofficial)
	slot_jump = list(/obj/item/clothing/under/misc/lawyer/black) // so they can slam tables
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/command/inspector)
	slot_head = list(/obj/item/clothing/head/NTberet)
	slot_suit = list(/obj/item/clothing/suit/armor/NT)
	slot_eyes = list(/obj/item/clothing/glasses/regular)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_rhan = list(/obj/item/device/ticket_writer)
	items_in_backpack = list(/obj/item/device/flash)
	wiki_link = "https://wiki.ss13.co/Inspector"

	get_default_miranda()
		return "You have been found to be in breach of Nanotrasen corporate regulation [rand(1,100)][pick(uppercase_letters)]. You are allowed a grace period of 5 minutes to correct this infringement before you may be subjected to disciplinary action including but not limited to: strongly worded tickets, reduction in pay, and being buried in paperwork for the next [rand(10,20)] standard shifts."

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			B.storage.add_contents(new /obj/item/instrument/whistle(B))
			var/obj/item/clipboard/with_pen/inspector/clipboard = new /obj/item/clipboard/with_pen/inspector(B)
			B.storage.add_contents(clipboard)
			clipboard.set_owner(M)
		return

/datum/job/special/random/diplomat
	name = "Diplomat"
	wages = PAY_DUMBCLOWN
	access_string = "Diplomat"
	request_limit = 0 // you don't request them, they come to you
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_jump = list(/obj/item/clothing/under/misc/lawyer)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	alt_names = list("Diplomat", "Ambassador")
	invalid_antagonist_roles = list(ROLE_HEAD_REVOLUTIONARY)
	change_name_on_spawn = TRUE

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/morph = pick(/datum/mutantrace/lizard,/datum/mutantrace/skeleton,/datum/mutantrace/ithillid,/datum/mutantrace/martian,/datum/mutantrace/amphibian,/datum/mutantrace/blob,/datum/mutantrace/cow)
		M.set_mutantrace(morph)
		if (istype(M.mutantrace, /datum/mutantrace/martian) || istype(M.mutantrace, /datum/mutantrace/blob))
			M.equip_if_possible(new /obj/item/device/speech_pro(src), SLOT_IN_BACKPACK)
		else
			if (M.l_store)
				M.stow_in_available(M.l_store)
			M.equip_if_possible(new /obj/item/device/speech_pro(src), SLOT_L_STORE)

/datum/job/special/random/testsubject
	name = "Test Subject"
	wages = PAY_DUMBCLOWN
	slot_jump = list(/obj/item/clothing/under/shorts)
	slot_mask = list(/obj/item/clothing/mask/monkey_translator)
	change_name_on_spawn = TRUE
	starting_mutantrace = /datum/mutantrace/monkey
	wiki_link = "https://wiki.ss13.co/Monkey"

/datum/job/special/random/union
	name = "Union Rep"
	wages = PAY_TRADESMAN
	slot_jump = list(/obj/item/clothing/under/misc/lawyer)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	alt_names = list("Assistants Union Rep", "Cargo Union Rep", "Catering Union Rep", "Union Rep", "Security Union Rep", "Doctors Union Rep", "Engineers Union Rep", "Miners Union Rep")
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			B.storage.add_contents(new /obj/item/clipboard/with_pen(B))

		return

/datum/job/special/random/salesman
	name = "Salesman"
	wages = PAY_TRADESMAN
	slot_suit = list(/obj/item/clothing/suit/merchant)
	slot_jump = list(/obj/item/clothing/under/gimmick/merchant)
	slot_head = list(/obj/item/clothing/head/merchant_hat)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	alt_names = list("Salesman", "Merchant")
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Salesman"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		if(prob(33))
			var/morph = pick(/datum/mutantrace/lizard,/datum/mutantrace/skeleton,/datum/mutantrace/ithillid,/datum/mutantrace/martian,/datum/mutantrace/amphibian)
			M.set_mutantrace(morph)

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			for (var/i = 1 to 2)
				B.storage.add_contents(new /obj/item/stamped_bullion(B))

		return

/datum/job/special/random/coach
	name = "Coach"
	wages = PAY_UNTRAINED
	slot_jump = list(/obj/item/clothing/under/jersey)
	slot_suit = list(/obj/item/clothing/suit/armor/vest/macho)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_poc1 = list(/obj/item/instrument/whistle)
	slot_glov = list(/obj/item/clothing/gloves/boxing)
	items_in_backpack = list(/obj/item/football,/obj/item/football,/obj/item/basketball,/obj/item/basketball)
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

/datum/job/special/random/journalist
	name = "Journalist"
	wages = PAY_UNTRAINED
	slot_jump = list(/obj/item/clothing/under/suit/red)
	slot_head = list(/obj/item/clothing/head/fedora)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_poc1 = list(/obj/item/camera)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	items_in_backpack = list(/obj/item/camera_film/large)
	special_spawn_location = LANDMARK_JOURNALIST_SPAWN
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			B.storage.add_contents(new /obj/item/device/camera_viewer/public(B))
			B.storage.add_contents(new /obj/item/clothing/head/helmet/camera(B))
			B.storage.add_contents(new /obj/item/device/audio_log(B))
			B.storage.add_contents(new /obj/item/clipboard/with_pen(B))

		return

/datum/job/special/random/beekeeper
	name = "Apiculturist"
	wages = PAY_TRADESMAN
	access_string = "Apiculturist"
	slot_jump = list(/obj/item/clothing/under/rank/beekeeper)
	slot_suit = list(/obj/item/clothing/suit/hazard/beekeeper)
	slot_head = list(/obj/item/clothing/head/bio_hood/beekeeper)
	slot_poc1 = list(/obj/item/reagent_containers/food/snacks/beefood)
	slot_poc2 = list(/obj/item/paper/book/from_file/bee_book)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_belt = list(/obj/item/device/pda2/botanist)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	items_in_backpack = list(/obj/item/bee_egg_carton, /obj/item/bee_egg_carton, /obj/item/bee_egg_carton, /obj/item/reagent_containers/food/snacks/beefood, /obj/item/reagent_containers/food/snacks/beefood)
	alt_names = list("Apiculturist", "Apiarist")
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

	faction = list(FACTION_BOTANY)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		if (prob(15))
			var/obj/critter/domestic_bee/bee = new(get_turf(M))
			bee.beeMom = M
			bee.beeMomCkey = M.ckey
			bee.name = pick_string("bee_names.txt", "beename")
			bee.name = replacetext(bee.name, "larva", "bee")

		M.bioHolder.AddEffect("bee", magical=1) //They're one with the bees!


/datum/job/special/random/angler
	name = "Angler"
	wages = PAY_TRADESMAN
	access_string = "Rancher"
	slot_jump = list(/obj/item/clothing/under/rank/angler)
	slot_head = list(/obj/item/clothing/head/black)
	slot_foot = list(/obj/item/clothing/shoes/galoshes/waders)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	items_in_backpack = list(/obj/item/fishing_rod/basic)


/datum/job/special/random/pharmacist
	name = "Pharmacist"
	wages = PAY_DOCTORATE
	ui_colour = TGUI_COLOUR_PINK
	request_limit = 1 // limited workspace
	trait_list = list("training_medical")
	access_string = "Pharmacist"
	slot_card = /obj/item/card/id/medical
	slot_belt = list(/obj/item/device/pda2/medical)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/shirt_pants)
	slot_suit = list(/obj/item/clothing/suit/labcoat)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	items_in_backpack = list(/obj/item/storage/box/beakerbox, /obj/item/storage/pill_bottle/cyberpunk)

/datum/job/special/random/psychiatrist
	name = "Psychiatrist"
	ui_colour = TGUI_COLOUR_PINK
	wages = PAY_DOCTORATE
	request_limit = 1 // limited workspace
	trait_list = list("training_therapy")
	access_string = "Psychiatrist"
	slot_eyes = list(/obj/item/clothing/glasses/regular)
	slot_card = /obj/item/card/id/medical
	slot_belt = list(/obj/item/device/pda2/medical)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/shirt_pants)
	slot_suit = list(/obj/item/clothing/suit/labcoat)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_poc1 = list(/obj/item/reagent_containers/food/drinks/tea)
	slot_poc2 = list(/obj/item/reagent_containers/food/drinks/bottle/gin)
	items_in_backpack = list(/obj/item/luggable_computer/personal, /obj/item/clipboard/with_pen, /obj/item/paper_bin, /obj/item/stamp, /obj/item/storage/firstaid/mental)
	alt_names = list("Psychiatrist", "Psychologist", "Psychotherapist", "Therapist", "Counselor", "Life Coach") // All with slightly different connotations

/datum/job/special/random/artist
	name = "Artist"
	wages = PAY_UNTRAINED
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/misc/casualjeansblue)
	slot_head = list(/obj/item/clothing/head/mime_beret)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_poc1 = list(/obj/item/currency/spacecash/twenty)
	slot_poc2 = list(/obj/item/pen/pencil)
	slot_lhan = list(/obj/item/storage/toolbox/artistic)
	items_in_backpack = list(/obj/item/canvas, /obj/item/canvas, /obj/item/storage/box/crayon/basic ,/obj/item/paint_can/random)
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

/datum/job/special/random/foodcritic
	name = "Food Critic"
	wages = PAY_UNTRAINED
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/shirt_pants_br)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_poc2 = list(/obj/item/paper)
	slot_lhan = list(/obj/item/clipboard/with_pen)
	items_in_backpack = list(/obj/item/item_box/postit)
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

/datum/job/special/random/pestcontrol
	name = "Pest Control Specialist"
	wages = PAY_UNTRAINED
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/gimmick/safari)
	slot_head = list(/obj/item/clothing/head/safari)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_lhan = list(/obj/item/pet_carrier)
	items_in_backpack = list(/obj/item/storage/box/mousetraps)
	access_string = "Staff Assistant"
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

/datum/job/special/random/vehiclemechanic
	name = "Vehicle Mechanic" // fallback name, gets changed later
	#ifdef UNDERWATER_MAP
	name = "Submarine Mechanic"
	#else
	name = "Pod Mechanic"
	#endif
	wages = PAY_TRADESMAN
	trait_list = list("training_engineer")
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/rank/mechanic)
	slot_head = list(/obj/item/clothing/head/helmet/hardhat)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_lhan = list(/obj/item/storage/toolbox/mechanical)
	#ifdef UNDERWATER_MAP
	items_in_backpack = list(/obj/item/preassembled_frame_box/sub, /obj/item/podarmor/armor_light, /obj/item/clothing/head/helmet/welding)
	#else
	items_in_backpack = list(/obj/item/preassembled_frame_box/putt, /obj/item/podarmor/armor_light, /obj/item/clothing/head/helmet/welding)
	#endif
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

/datum/job/special/random/phonemerchant
	name = "Phone Merchant"
	wages = PAY_TRADESMAN
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/gimmick/merchant)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_poc1 = list(/obj/item/electronics/soldering)
	items_in_backpack = list(/obj/item/electronics/frame/phone, /obj/item/electronics/frame/phone, /obj/item/electronics/frame/phone, /obj/item/electronics/frame/phone)
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

// god help us
// hello it's me god, adding an RP define here
#ifndef RP_MODE
/datum/job/special/random/influencer
	name = "Influencer"
	wages = PAY_UNTRAINED
	change_name_on_spawn = TRUE
	slot_foot = list(/obj/item/clothing/shoes/dress_shoes)
	slot_jump = list(/obj/item/clothing/under/misc/casualjeanspurp)
	slot_head = list(/obj/item/clothing/head/basecap/purple)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_poc1 = list(/obj/item/device/audio_log)
	slot_poc2 = list(/obj/item/camera)
	items_in_backpack = list(/obj/item/storage/box/random_colas, /obj/item/clothing/head/helmet/camera, /obj/item/device/camera_viewer/public)
	special_spawn_location = LANDMARK_INFLUENCER_SPAWN
	// missing wiki link, parent fallback to https://wiki.ss13.co/Jobs#Gimmick_Jobs

#endif
