/obj/storage/secure/closet
	name = "secure locker"
	desc = "A card-locked storage locker."
	soundproofing = 5
	can_flip_bust = 1
	p_class = 3

/obj/storage/secure/closet/personal
	name = "personal locker"
	desc = "The first card swiped gains control."
	personal = 1
	spawn_contents = list(/obj/item/storage/backpack,
	/obj/item/storage/backpack/satchel,
	/obj/item/device/radio/signaler,
	/obj/item/pen,
	/obj/item/device/radio/headset)

/obj/storage/secure/closet/personal/empty
	spawn_contents = list()

/* =================== */
/* ----- Command ----- */
/* =================== */

/obj/storage/secure/closet/command
	name = "command locker"
	req_access = list(access_heads)
	icon_state = "command"
	icon_closed = "command"
	icon_opened = "secure_blue-open"

/obj/storage/secure/closet/command/captain
	name = "\improper Captain's locker"
	spawn_contents = list(/obj/item/gun/energy/egun,
	/obj/item/storage/box/id_kit,
	/obj/item/storage/box/clothing/captain,
	/obj/item/clothing/shoes/brown,
	/obj/item/clothing/suit/armor/vest,
	/obj/item/clothing/head/helmet/swat,
	/obj/item/clothing/glasses/sunglasses,
	/obj/item/stamp/cap,
	/obj/item/device/radio/headset/command/captain)

/obj/storage/secure/closet/command/captain/fake
	req_access = null
	spawn_contents = list(/obj/item/clothing/shoes/brown,
	/obj/item/clothing/suit/armor/vest,
	/obj/item/clothing/head/helmet/swat,
	/obj/item/clothing/glasses/sunglasses,
	/obj/item/device/radio/headset/command/captain)


/obj/storage/secure/closet/command/hos
	name = "\improper Head of Security's locker"
	req_access_txt = "37"
	spawn_contents = list(/obj/item/storage/box/id_kit,
	/obj/item/handcuffs,
	/obj/item/device/flash,
	/obj/item/storage/box/clothing/hos,
	/obj/item/clothing/suit/det_suit/hos,
	/obj/item/clothing/shoes/brown,
	/obj/item/clothing/suit/armor/vest,
	/obj/item/clothing/head/helmet/hardhat/security,
	/obj/item/clothing/glasses/sunglasses/sechud,
	/obj/item/gun/energy/egun,
	/obj/item/device/radio/headset/security,
	/obj/item/clothing/glasses/thermal,
	/obj/item/stamp/hos,
	/obj/item/device/radio/headset/command/hos,
	/obj/item/clothing/shoes/swat/heavy,
#if ASS_JAM
	/obj/item/gun/kinetic/beepsky,
	/obj/item/turret_deployer/riot,
#endif
	/obj/item/barrier)

/obj/storage/secure/closet/command/hop
	name = "\improper Head of Personnel's locker"
	req_access_txt = "55"
	spawn_contents = list(/obj/item/device/flash,
	/obj/item/storage/box/id_kit,
	/obj/item/storage/box/clothing/hop,
	/obj/item/clothing/shoes/brown,
	/obj/item/clothing/suit/armor/vest,
	/obj/item/stamp/hop,
	/obj/item/device/radio/headset/command/hop,
	/obj/item/device/accessgun)

/obj/storage/secure/closet/command/research_director
	name = "\improper Research Director's locker"
	req_access_txt = "11"
	spawn_contents = list(/obj/item/plant/herb/cannabis/spawnable,
	/obj/item/device/light/zippo,
	/obj/item/storage/box/clothing/research_director,
	/obj/item/clothing/shoes/brown,
	/obj/item/circular_saw,
	/obj/item/scalpel,
	/obj/item/hand_tele,
	/obj/item/storage/box/zeta_boot_kit,
	/obj/item/device/radio/electropack,
	/obj/item/clothing/mask/gas,
	/obj/item/device/flash,
	/obj/item/stamp/rd,
	/obj/item/device/radio/headset/command/rd)

	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			if (prob(10))
				new /obj/item/photo/heisenbee(src)
			return 1

/obj/storage/secure/closet/command/medical_director
	name = "\improper Medical Director's locker"
	req_access_txt = "53"
	spawn_contents = list(/obj/item/storage/box/clothing/medical_director,
	/obj/item/clothing/shoes/brown,
	/obj/item/gun/implanter,
	/obj/item/gun/reagent/syringe/NT,
	/obj/item/gun/kinetic/dart_rifle,
	/obj/item/ammo/bullets/tranq_darts,
	/obj/item/ammo/bullets/tranq_darts/anti_mutant,
	/obj/item/robodefibrillator,
	/obj/item/clothing/gloves/latex,
	/obj/item/storage/belt/medical,
	/obj/item/storage/firstaid/docbag,
	/obj/item/reagent_containers/hypospray,
	/obj/item/device/flash,
	/obj/item/stamp/md,
	/obj/item/device/radio/headset/command/md)

	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			if (prob(10)) // heh
				new /obj/item/reagent_containers/glass/bottle/eyedrops(src)
				new /obj/item/reagent_containers/dropper(src)
			return 1

/obj/storage/secure/closet/command/chief_engineer
	name = "\improper Chief Engineer's locker"
	req_access_txt = "49"
	spawn_contents = list(/obj/item/storage/toolbox/mechanical,
	/obj/item/storage/box/clothing/chief_engineer,
	/obj/item/clothing/gloves/yellow,
	/obj/item/clothing/shoes/brown,
	/obj/item/clothing/shoes/magnetic,
	/obj/item/clothing/ears/earmuffs,
	/obj/item/clothing/glasses/meson,
	/obj/item/clothing/suit/fire,
	/obj/item/clothing/mask/gas,
	/obj/item/storage/belt/utility/prepared/ceshielded,
	/obj/item/clothing/head/helmet/welding,
	/obj/item/clothing/head/helmet/hardhat,
	/obj/item/device/multitool,
	/obj/item/device/flash,
	/obj/item/stamp/ce,
	/obj/item/device/radio/headset/command/ce)

/* ==================== */
/* ----- Security ----- */
/* ==================== */

/obj/storage/secure/closet/security
	name = "\improper Security locker"
	req_access_txt = "38"
	icon_state = "sec"
	icon_closed = "sec"
	icon_opened = "secure_red-open"

/obj/storage/secure/closet/security/equipment
	name = "\improper Security equipment locker"
	spawn_contents = list(/obj/item/storage/box/clothing/security,
	/obj/item/clothing/suit/wintercoat/security,
	/obj/item/clothing/suit/armor/vest,
	/obj/item/clothing/head/helmet/hardhat/security,
	/obj/item/clothing/glasses/sunglasses/sechud,
	/obj/item/handcuffs,
	/obj/item/device/flash,
	/obj/item/barrier)

/obj/storage/secure/closet/security/forensics
	name = "Forensics equipment locker"
	req_access_txt = "4"
	spawn_contents = list(/obj/item/storage/box/clothing/detective,
	/obj/item/clothing/suit/wintercoat/security,
	/obj/item/clothing/glasses/thermal,
	/obj/item/clothing/glasses/spectro,
	/obj/item/storage/box/spy_sticker_kit/radio_only/detective,
	/obj/item/storage/box/lglo_kit/random,
	/obj/item/clothing/head/det_hat/gadget,
	/obj/item/device/detective_scanner,
	/obj/item/bloodtracker,
	/obj/item/device/flash,
	/obj/item/camera_film,
	/obj/item/storage/box/luminol_grenade_kit)

/obj/storage/secure/closet/security/armory
	name = "\improper Special Equipment locker"
	req_access_txt = "37"
	spawn_contents = list(/obj/item/requisition_token/security = 2,
	/obj/item/turret_deployer/riot = 2,
	/obj/item/clothing/glasses/nightvision = 2,
	/obj/item/clothing/glasses/sunglasses,
	/obj/item/clothing/glasses/sunglasses,
	/obj/item/ammo/bullets/abg,
	/obj/item/ammo/bullets/abg,)

/obj/storage/secure/closet/brig
	name = "\improper Confiscated Items locker"
	req_access_txt = "2"

// Old Mushroom-era feature I fixed up (Convair880).
/obj/storage/secure/closet/brig/automatic
	name = "\improper Automatic Locker"
	desc = "Card-locked closet linked to a brig timer. Will unlock automatically when timer reaches zero."
	var/obj/machinery/door_timer/our_timer = null
	var/id = null

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/machinery/floorflusher (floorflusher.dm)
	// /obj/machinery/door_timer (door_timer.dm)
	// /obj/machinery/door/window/brigdoor (window.dm)
	// /obj/machinery/flasher (flasher.dm)
	solitary
		name = "\improper Automatic Locker (Cell #1)"
		id = "solitary"

	solitary2
		name = "\improper Automatic Locker (Cell #2)"
		id = "solitary2"

	solitary3
		name = "\improper Automatic Locker (Cell #3)"
		id = "solitary3"

	solitary4
		name = "\improper Automatic Locker (Cell #4)"
		id = "solitary4"

	minibrig
		name = "\improper Automatic Locker (Mini-Brig)"
		id = "minibrig"

	minibrig2
		name = "\improper Automatic Locker (Mini-Brig #2)"
		id = "minibrig2"

	minibrig3
		name = "\improper Automatic Locker (Mini-Brig #3)"
		id = "minibrig3"

	genpop
		name = "\improper Automatic Locker (Genpop)"
		id = "genpop"

	genpop_n
		name = "\improper Automatic Locker (Genpop North)"
		id = "genpop_n"

	genpop_s
		name = "\improper Automatic Locker (Genpop South)"
		id = "genpop_s"

	New()
		..()
		SPAWN_DBG (5)
			if (src)
				// Why range 30? COG2 places linked fixtures much further away from the timer than originally envisioned.
				for (var/obj/machinery/door_timer/DT in range(30, src))
					if (DT && DT.id == src.id)
						src.our_timer = DT
						if (src.name == "\improper Automatic Locker")
							src.name = "\improper Automatic Locker ([src.id])"
						break
				if (!src.our_timer)
					message_admins("Automatic locker: couldn't find brig timer with ID [isnull(src.id) ? "*null*" : "[src.id]"] in [get_area(src)].")
					logTheThing("debug", null, null, "<b>Convair880:</b> couldn't find brig timer with ID [isnull(src.id) ? "*null*" : "[src.id]"] for automatic locker at [log_loc(src)].")
		return

	MouseDrop(over_object, src_location, over_location)
		..()
		if (isobserver(usr) || isintangible(usr))
			return
		if (!isturf(usr.loc))
			return
		if (usr.stat || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened"))
			return
		if (get_dist(src, usr) > 1)
			usr.show_text("You are too far away to do this!", "red")
			return
		if (get_dist(over_object, src) > 5)
			usr.show_text("The [src.name] is too far away from the target!", "red")
			return
		if (!istype(over_object, /obj/machinery/door_timer))
			usr.show_text("Automatic lockers can only be linked to a brig timer.", "red")
			return

		if (alert("Link locker to this brig timer?",,"Yes","No") == "Yes")
			var/obj/machinery/door_timer/DT = over_object
			if (!DT.id)
				usr.show_text("This brig timer doesn't have an ID assigned to it.", "red")
				return
			src.id = DT.id
			src.our_timer = DT
			src.name = "\improper Automatic Locker ([src.id])"
			usr.visible_message("<span class='notice'><b>[usr.name]</b> links [src.name] to a brig timer.</span>", "<span class='notice'>Brig timer linked: [src.id].</span>")
		return

/* =================== */
/* ----- Medical ----- */
/* =================== */

/obj/storage/secure/closet/medical
	name = "medical locker"
	icon_state = "medical"
	icon_closed = "medical"
	icon_opened = "secure_white-open"
	req_access_txt = "10"

/obj/storage/secure/closet/medical/medicine
	name = "medicine storage locker"
	spawn_contents = list(/obj/item/clothing/glasses/visor,
	/obj/item/device/radio/headset/deaf,
	/obj/item/clothing/glasses/eyepatch,
	/obj/item/reagent_containers/glass/bottle/antitoxin = 3,
	/obj/item/reagent_containers/glass/bottle/epinephrine = 3,
	/obj/item/storage/box/syringes,
	/obj/item/storage/box/stma_kit,
	/obj/item/storage/box/lglo_kit/random,
	/obj/item/reagent_containers/dropper = 2,
	/obj/item/reagent_containers/glass/beaker = 2)

/obj/storage/secure/closet/medical/medkit
	name = "medkit storage locker"
	spawn_contents = list()
	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			var/obj/item/storage/firstaid/regular/B1 = new(src)
			B1.pixel_y = 6
			B1.pixel_x = -6

			var/obj/item/storage/firstaid/brute/B2 = new(src)
			B2.pixel_y = 6
			B2.pixel_x = 6

			var/obj/item/storage/firstaid/fire/B3 = new(src)
			B3.pixel_y = 0
			B3.pixel_x = -6

			var/obj/item/storage/firstaid/toxin/B4 = new(src)
			B4.pixel_y = 0
			B4.pixel_x = 6

			var/obj/item/storage/firstaid/oxygen/B5 = new(src)
			B5.pixel_y = -6
			B5.pixel_x = -6

			var/obj/item/storage/firstaid/brain/B6 = new(src)
			B6.pixel_y = -6
			B6.pixel_x = 6
			return 1

/obj/storage/secure/closet/medical/anesthetic
	name = "anesthetic storage locker"
	spawn_contents = list(/obj/item/reagent_containers/glass/bottle/morphine = 2,
	/obj/item/storage/box/syringes,
	/obj/item/tank/anesthetic = 5,
	/obj/item/clothing/mask/medical = 4)

/obj/storage/secure/closet/medical/uniforms
	name = "medical uniform locker"
	spawn_contents = list(/obj/item/storage/backpack/medic,
	/obj/item/storage/backpack/satchel/medic,
	/obj/item/storage/box/clothing/medical,
	/obj/item/storage/box/clothing/geneticist,
	/obj/item/storage/box/clothing/roboticist,
	/obj/item/clothing/suit/wintercoat/medical,
	/obj/item/storage/belt/medical,
	/obj/item/storage/box/stma_kit,
	/obj/item/storage/box/lglo_kit/random,
	/obj/item/clothing/glasses/healthgoggles)

/obj/storage/secure/closet/medical/chemical
	name = "restricted medical locker"
	spawn_contents = list()
	req_access_txt = "53"
	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			// let's organize the SHIT outta this closet too! hot damn
			var/obj/item/reagent_containers/glass/bottle/pfd/B1 = new(src)
			B1.pixel_y = 6
			B1.pixel_x = -4

			var/obj/item/reagent_containers/glass/bottle/pentetic/B2 = new(src)
			B2.pixel_y = 6
			B2.pixel_x = 4

			var/obj/item/reagent_containers/glass/bottle/omnizine/B3 = new(src)
			B3.pixel_y = 0
			B3.pixel_x = -4

			var/obj/item/reagent_containers/glass/bottle/pfd/B4 = new(src)
			B4.pixel_y = 0
			B4.pixel_x = 4

			var/obj/item/reagent_containers/glass/bottle/ether/B5 = new(src)
			B5.pixel_y = -5
			B5.pixel_x = -4

			var/obj/item/reagent_containers/glass/bottle/haloperidol/B6 = new(src)
			B6.pixel_y = -5
			B6.pixel_x = 4
			return 1

/obj/storage/secure/closet/animal
	name = "\improper Animal Control locker"
	req_access = list(access_medical)
	spawn_contents = list(/obj/item/device/radio/signaler,
	/obj/item/device/radio/electropack = 5,
	/obj/item/clothing/glasses/blindfold = 2)

/* ==================== */
/* ----- Research ----- */
/* ==================== */

/obj/storage/secure/closet/research
	name = "\improper Research locker"
	icon_state = "science"
	icon_closed = "science"
	icon_opened = "secure_white-open"
	req_access_txt = "8"

/obj/storage/secure/closet/research/uniform
	name = "science uniform locker"
	spawn_contents = list(/obj/item/tank/air,
	/obj/item/storage/box/clothing/research,
	/obj/item/clothing/suit/wintercoat/research,
	/obj/item/clothing/gloves/latex,
	/obj/item/clothing/mask/gas,
	/obj/item/device/reagentscanner,
	/obj/item/device/radio/headset/research)

/obj/storage/secure/closet/research/chemical
	name = "chemical storage locker"
	spawn_contents = list()
	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			// let's organize the SHIT outta this closet hot damn
			var/obj/item/reagent_containers/glass/bottle/oil/B1 = new(src)
			B1.pixel_y = 6
			B1.pixel_x = -4

			var/obj/item/reagent_containers/glass/bottle/phenol/B2 = new(src)
			B2.pixel_y = 6
			B2.pixel_x = 4

			var/obj/item/reagent_containers/glass/bottle/acetone/B3 = new(src)
			B3.pixel_y = 0
			B3.pixel_x = -4

			var/obj/item/reagent_containers/glass/bottle/ammonia/B4 = new(src)
			B4.pixel_y = 0
			B4.pixel_x = 4

			var/obj/item/reagent_containers/glass/bottle/diethylamine/B5 = new(src)
			B5.pixel_y = -5
			B5.pixel_x = -4

			var/obj/item/reagent_containers/glass/bottle/acid/B6 = new(src)
			B6.pixel_y = -5
			B6.pixel_x = 4
			return 1

/* ======================= */
/* ----- Engineering ----- */
/* ======================= */

/obj/storage/secure/closet/engineering
	name = "\improper Engineering locker"
	icon_state = "eng"
	icon_closed = "eng"
	icon_opened = "secure_yellow-open"
	req_access = list(access_engineering)

/obj/storage/secure/closet/engineering/electrical
	name = "electrical supplies locker"
	req_access_txt = "43"
	spawn_contents = list(/obj/item/clothing/gloves/yellow = 3,
	/obj/item/storage/toolbox/electrical = 3,
	/obj/item/device/multitool = 3)

/obj/storage/secure/closet/engineering/welding
	name = "welding supplies locker"
	spawn_contents = list(/obj/item/clothing/head/helmet/welding = 3,
	/obj/item/weldingtool = 3)

/obj/storage/secure/closet/engineering/mechanic
	name = "\improper Mechanic's locker"
	req_access_txt = "45"
	spawn_contents = list(/obj/item/storage/toolbox/electrical,
	/obj/item/clothing/suit/wintercoat/engineering,
	/obj/item/storage/box/clothing/mechanic,
	/obj/item/clothing/gloves/yellow,
	/obj/item/clothing/head/helmet/hardhat,
	/obj/item/electronics/scanner,
	/obj/item/clothing/glasses/meson,
	/obj/item/electronics/soldering,
	/obj/item/deconstructor,
	/obj/item/storage/mechanics/housing_large=2,
	/obj/item/storage/mechanics/housing_handheld=1)

/obj/storage/secure/closet/engineering/atmos
	name = "\improper Atmospheric Technician's locker"
	req_access = list(access_engineering_atmos)
	spawn_contents = list(/obj/item/clothing/shoes/orange,
	/obj/item/clothing/under/misc/atmospheric_technician,
	/obj/item/clothing/suit/fire,
	/obj/item/clothing/suit/wintercoat/engineering,
	/obj/item/clothing/head/helmet/hardhat,
	/obj/item/clothing/glasses/meson,
	/obj/item/device/radio/headset/engineer)

/obj/storage/secure/closet/engineering/engineer
	name = "\improper Engineer's locker"
	req_access_txt = "44"
	spawn_contents = list(/obj/item/storage/toolbox/mechanical,
	/obj/item/storage/box/clothing/engineer,
	/obj/item/clothing/suit/wintercoat/engineering,
	/obj/item/clothing/mask/gas,
	/obj/item/clothing/head/helmet/hardhat,
	/obj/item/clothing/glasses/meson,
	/obj/item/pen/infrared,
	/obj/item/clothing/head/helmet/welding)

/obj/storage/secure/closet/engineering/mining
	name = "\improper Miner's locker"
	req_access = list(access_mining)
	spawn_contents = list(/obj/item/clothing/shoes/orange,
	/obj/item/storage/box/clothing/miner,
	/obj/item/clothing/suit/wintercoat/engineering,
	/obj/item/breaching_charge/mining/light = 3,
	/obj/item/satchel/mining = 2,
	/obj/item/oreprospector,
	/obj/item/ore_scoop,
	/obj/item/mining_tool/power_pick,
	/obj/item/clothing/glasses/meson,
	/obj/item/storage/belt/mining)

/obj/storage/secure/closet/engineering/cargo
	name = "\improper Quartermaster's locker"
	req_access = list(access_cargo)
	spawn_contents = list(/obj/item/storage/box/clothing/qm,
	/obj/item/pen/fancy,
	/obj/item/paper_bin,
	/obj/item/clipboard,
	/obj/item/hand_labeler,
	/obj/item/cargotele)

/* ==================== */
/* ----- Civilian ----- */
/* ==================== */

/obj/storage/secure/closet/civilian
	name = "civilian locker"

/obj/storage/secure/closet/civilian/janitor
	name = "\improper Custodial supplies locker"
	req_access = list(access_janitor)
	spawn_contents = list(/obj/item/storage/box/clothing/janitor,\
	/obj/item/reagent_containers/glass/bottle/cleaner = 2,\
	/obj/item/reagent_containers/glass/bottle/acetone/janitors = 1,\
	/obj/item/reagent_containers/glass/bottle/ammonia/janitors = 1,\
	/obj/item/device/light/flashlight,\
	/obj/item/caution = 4)

/obj/storage/secure/closet/civilian/hydro
	name = "\improper Botanical supplies locker"
	req_access = list(access_hydro)
	icon_state = "secure_green"
	icon_closed = "secure_green"
	icon_opened = "secure_green-open"
	spawn_contents = list(/obj/item/storage/box/clothing/botanist,
	/obj/item/plantanalyzer,
	/obj/item/device/reagentscanner,
	/obj/item/reagent_containers/glass/wateringcan,
	/obj/item/paper/book/hydroponicsguide)

/obj/storage/secure/closet/civilian/kitchen
	name = "\improper Catering supplies locker"
	req_access = list(access_kitchen)
	spawn_contents = list(/obj/item/storage/box/clothing/chef,\
	/obj/item/storage/box/clothing/souschef,\
	/obj/item/storage/box/cutlery,\
	/obj/item/kitchen/rollingpin,\
	/obj/item/paper/book/cookbook,\
	/obj/item/reagent_containers/food/snacks/ingredient/spaghetti = 5)

/obj/storage/secure/closet/civilian/bartender
	name = "\improper Mixology supplies locker"
	req_access = list(access_bar)
	spawn_contents = list(/obj/item/storage/box/clothing/barman,\
	/obj/item/storage/box/clothing/waiter,\
	/obj/item/gun/russianrevolver,\
	/obj/item/reagent_containers/food/drinks/bottle/vintage,\
	/obj/item/reagent_containers/food/drinks/drinkingglass/shot = 4,\
	/obj/item/reagent_containers/food/drinks/drinkingglass/wine = 2,\
	/obj/item/storage/box/glassbox)

/obj/storage/secure/closet/civilian/chaplain
	name = "\improper Religious supplies locker"
	req_access = list(access_chapel_office)
	spawn_contents = list(/obj/item/storage/box/clothing/witchfinder,\
	/obj/item/storage/box/clothing/chaplain,\
	/obj/item/clothing/under/misc/chaplain/atheist,\
	/obj/item/clothing/under/misc/chaplain,\
	/obj/item/clothing/under/misc/chaplain/rabbi,\
	/obj/item/clothing/under/misc/chaplain/siropa_robe,\
	/obj/item/clothing/under/misc/chaplain/buddhist,\
	/obj/item/clothing/under/misc/chaplain/muslim,\
	/obj/item/clothing/suit/adeptus,\
	/obj/item/clothing/head/rabbihat,\
	/obj/item/clothing/head/formal_turban,\
	/obj/item/clothing/head/turban,\
	/obj/item/clothing/shoes/sandal,\
	/obj/item/clothing/suit/flockcultist,\
	/obj/item/reagent_containers/glass/bottle/holywater)

/* =================== */
/* ----- Fridges ----- */
/* =================== */

/obj/storage/secure/closet/fridge
	name = "refrigerator"
	icon_state = "fridge"
	icon_closed = "fridge"
	icon_opened = "fridge-open"
	icon_greenlight = "fridge-greenlight"
	icon_redlight = "fridge-redlight"
	icon_sparks = "fridge-sparks"

/obj/storage/secure/closet/fridge/kitchen
	spawn_contents = list(/obj/item/reagent_containers/food/drinks/milk = 5,/obj/item/storage/box/cookie_tin)
	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			var/obj/item/storage/box/donkpocket_kit/dp = new(src)
			var/obj/item/storage/box/bacon_kit/bc1 = new(src)
			var/obj/item/storage/box/bacon_kit/bc2 = new(src)
			var/obj/item/storage/box/popsicles/p = new(src)
			var/obj/item/storage/box/sushi_box/s = new(src)
			s.pixel_x = 3
			dp.pixel_x = 3
			bc1.pixel_x = 3
			bc2.pixel_x = 3
			p.pixel_x = 3

			var/obj/item/kitchen/food_box/egg_box/e1 = new(src)
			var/obj/item/kitchen/food_box/egg_box/e2 = new(src)
			e1.pixel_y = -4
			e2.pixel_y = -4

			var/obj/item/reagent_containers/food/drinks/cola/c1 = new(src)
			var/obj/item/reagent_containers/food/drinks/cola/c2 = new(src)
			c1.pixel_x = -8
			c2.pixel_x = -8

			var/obj/item/storage/box/cheese/cheese = new(src)
			cheese.pixel_x = 3

			var/obj/item/storage/box/butter/butter = new(src)
			butter.pixel_x = 2
			butter.pixel_y = 4

			if (prob(25))
				for (var/i = rand(2,10), i > 0, i--)
					new /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget(src)
			return 1

/obj/item/paper/blood_fridge_note
	name = "paper- 'angry note'"
	info = "This fridge is for BLOOD PACKS <u>ONLY</u>! If I ever catch the idiot who keeps leaving their lunch in here, you're taking a one-way trip to the goddamn solarium!<br><br><i>L. Alliman</i><br>"

/obj/storage/secure/closet/fridge/blood
	name = "blood supply refrigerator"
	req_access = list(access_medical_lockers)
	spawn_contents = list(/obj/item/storage/box/iv_box,
	/obj/item/reagent_containers/iv_drip/saline,
	/obj/item/reagent_containers/iv_drip/blood = 5,
	/obj/item/paper/blood_fridge_note)
	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			if (prob(11))
				new /obj/item/plate(src)
				var/obj/item/a_sandwich = pick(typesof(/obj/item/reagent_containers/food/snacks/sandwich))
				//a_sandwich.pixel_y = 0
				//a_sandwich.pixel_x = 0
				new a_sandwich(src)
			return 1

/obj/storage/secure/closet/fridge/pathology
	name = "pathology lab fridge"
	req_access = list(access_medical_lockers)
	//PATHOLOGY REMOVAL
	#ifdef CREATE_PATHOGENS
	spawn_contents = list(/obj/item/reagent_containers/glass/vial/prepared = 10,
	/obj/item/reagent_containers/syringe/antiviral = 3)
	#else
	spawn_contents = list(/obj/item/reagent_containers/syringe/antiviral = 3)
	#endif

/* ================ */
/* ----- Misc ----- */
/* ================ */

/obj/storage/secure/closet/courtroom
	name = "\improper Courtroom locker"
	req_access = list(access_heads)
	spawn_contents = list(/obj/item/clothing/shoes/brown,
	/obj/item/paper/Court = 3,
	/obj/item/pen,
	/obj/item/clothing/suit/judgerobe,
	/obj/item/clothing/head/powdered_wig,
	/obj/item/clothing/under/misc/lawyer/red,
	/obj/item/clothing/under/misc/lawyer,
	/obj/item/clothing/under/misc/lawyer/black,
	/obj/item/storage/briefcase)

/obj/storage/secure/closet/kitchen
	name = "kitchen cabinet"
	req_access = list(access_kitchen)
	spawn_contents = list(/obj/item/clothing/head/chefhat = 2,
	/obj/item/clothing/under/rank/chef = 2,
	/obj/item/kitchen/utensil/fork,
	/obj/item/kitchen/utensil/knife,
	/obj/item/kitchen/utensil/spoon,
	/obj/item/kitchen/rollingpin,
	/obj/item/reagent_containers/food/snacks/ingredient/spaghetti = 5)

/obj/storage/secure/closet/barber
	spawn_contents = list(/obj/item/clothing/under/misc/barber = 3,
	/obj/item/clothing/head/wig = 2,
	/obj/item/scissors,
	/obj/item/razor_blade)
