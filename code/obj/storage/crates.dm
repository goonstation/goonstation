/obj/storage/crate
	name = "crate"
	desc = "A small, cuboid object with a hinged top and empty interior."
	is_short = 1
	icon_state = "crate"
	icon_closed = "crate"
	icon_opened = "crateopen"
	icon_welded = "welded-crate"
	soundproofing = 3
	throwforce = 50 //ouch
	can_flip_bust = 1
	event_handler_flags = USE_FLUID_ENTER | USE_CHECKEXIT | USE_CANPASS | NO_MOUSEDROP_QOL

	get_desc()
		. = ..()
		if(src.delivery_destination)
			. += "\nThere's a barcode with the code for [src.delivery_destination] on it."

	update_icon()
		..()
		if(src.delivery_destination)
			src.UpdateOverlays(image(src.icon, "crate-barcode"), "barcode")
		else
			src.UpdateOverlays(null, "barcode")


	CanPass(atom/movable/mover, turf/target)
		if(istype(mover, /obj/projectile))
			return 1
		return ..()

	CheckExit(atom/movable/O as mob|obj, target as turf)
		if(istype(O, /obj/projectile))
			return 1
		return ..()

// Gore delivers new crates - woo!
/obj/storage/secure/crate/dan
	name = "Discount Dans cargo crate"
	desc = "Because space is not available!"
	icon_state = "dd_freezer"
	icon_opened = "dd_freezeropen"
	icon_closed = "dd_freezer"
	weld_image_offset_Y = -1

	beverages
		name = "Discount Dans beverages crate"
		desc = "Contents vary from sugar-shockers to pure poison."
		spawn_contents = list(/obj/item/reagent_containers/food/drinks/noodlecup = 2,
		/obj/item/reagent_containers/food/drinks/peach = 2,
		/obj/item/reagent_containers/food/drinks/covfefe = 2,
		/obj/item/reagent_containers/food/drinks/bottle/soda/spooky = 2,
		/obj/item/reagent_containers/food/drinks/bottle/soda/spooky2 = 2,
		/obj/item/reagent_containers/food/drinks/bottle/soda/gingerale = 2,
		/obj/item/reagent_containers/food/drinks/bottle/soda/drowsy = 2)

	snacks
		name = "Discount Dans 'edibles' crate"
		desc = "Contents may hold many surprises or...just a quick way out."
		spawn_contents = list(/obj/item/tvdinner = 2,
		/obj/item/reagent_containers/food/snacks/strudel = 2,
		/obj/item/reagent_containers/food/snacks/snack_cake/golden = 2,
		/obj/item/reagent_containers/food/snacks/burrito = 2,
		/obj/item/reagent_containers/food/snacks/snack_cake = 2)

/obj/storage/crate/internals
	name = "internals crate"
	desc = "An internals crate."
	icon_state = "o2crate"
	icon_opened = "o2crateopen"
	icon_closed = "o2crate"

/obj/storage/crate/medical
	name = "medical crate"
	desc = "A medical crate."
	icon_state = "medicalcrate"
	icon_opened = "medicalcrateopen"
	icon_closed = "medicalcrate"
	weld_image_offset_Y = -2


/obj/storage/crate/medical/morgue
	name = "morgue supplies crate"
	desc = "A medical crate containing supplies for use in morgues."
	spawn_contents = list(/obj/item/storage/box/biohazard_bags = 2,
	/obj/item/storage/box/body_bag = 2,
	/obj/item/clothing/gloves/latex/random,
	/obj/item/clothing/mask/surgical,
	/obj/item/clothing/mask/surgical_shield,
	/obj/item/device/analyzer/healthanalyzer,
	/obj/item/device/reagentscanner,
	/obj/item/device/detective_scanner,
	/obj/item/spraybottle/cleaner/,
	/obj/item/reagent_containers/glass/bottle/formaldehyde,
	/obj/item/reagent_containers/syringe)

/obj/storage/crate/rcd
	name = "\improper RCD crate"
	desc = "A crate for the storage of the RCD."
	spawn_contents = list(/obj/item/rcd_ammo = 5,
	/obj/item/rcd)

/obj/storage/crate/rcd/CE
	name = "\improper RCD crate"
	desc = "A crate for the Chief Engineer's personal RCD."
	spawn_contents = list(/obj/item/rcd_ammo = 5,
	/obj/item/rcd/construction/chiefEngineer)

/obj/storage/crate/abcumarker
	name = "\improper ABCU-Marker crate"
	desc = "A crate for ABCU marker devices."
	spawn_contents = list(/obj/item/blueprint_marker = 5)

/obj/storage/crate/freezer
	name = "freezer"
	desc = "A freezer."
	icon_state = "freezer"
	icon_opened = "freezeropen"
	icon_closed = "freezer"
	weld_image_offset_Y = -1

/obj/storage/crate/bartending
	name = "bartending crate"
	spawn_contents = list(/obj/item/reagent_containers/food/drinks/bottle/soda/ = 5,
	/obj/item/reagent_containers/glass/beaker/large = 2,
	/obj/item/device/reagentscanner,
	/obj/item/clothing/glasses/spectro,
	/obj/item/reagent_containers/dropper/mechanical,
	/obj/item/reagent_containers/dropper,
	/obj/item/reagent_containers/food/drinks/drinkingglass/pitcher,
	/obj/item/storage/firstaid/toxin,
	/obj/item/reagent_containers/emergency_injector/calomel)

/obj/storage/crate/biohazard
	name = "biohazard crate"
	desc = "A crate for biohazardous materials."
	icon_state = "biohazardcrate"
	icon_opened = "biohazardcrateopen"
	icon_closed = "biohazardcrate"
	weld_image_offset_Y = -2

	cdc
		name = "CDC pathogen sample crate"
		desc = "A crate for sending pathogen or blood samples to the CDC for analysis."
		spawn_contents = list(/obj/item/reagent_containers/syringe,
		/obj/item/paper/cdc_pamphlet)

/obj/storage/crate/freezer/milk
	spawn_contents = list(/obj/item/reagent_containers/food/drinks/milk = 10, \
	/obj/item/gun/russianrevolver)

/obj/storage/crate/bin
	name = "large bin"
	desc = "A large bin."
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "largebin"
	icon_opened = "largebinopen"
	icon_closed = "largebin"

/obj/storage/crate/bin/lostandfound
	name = "\improper Lost and Found bin"
	desc = "Theoretically, items that are lost by a person are placed here so that the person may come and find them. This never happens."
	spawn_contents = list(/obj/item/gnomechompski)

/obj/storage/crate/adventure
	name = "adventure crate"
	desc = "Only distantly related to the adventure closet."
	spawn_contents = list(/obj/item/device/radio/headset/multifreq = 4,
	/obj/item/device/audio_log = 2,
	/obj/item/audio_tape = 4,
	/obj/item/camera = 2,
	/obj/item/device/light/flashlight = 2,
	/obj/item/paper/book/from_file/critter_compendium,
	/obj/item/reagent_containers/food/drinks/milk,
	/obj/item/reagent_containers/food/snacks/sandwich/pb,
	/obj/item/paper/note_from_mom)

/obj/storage/crate/materials
	name = "building materials crate"
	spawn_contents = list(/obj/item/sheet/steel/fullstack,
	/obj/item/sheet/glass/fullstack)

/obj/storage/crate/furnacefuel
	name = "furnace fuel crate"
	desc = "A crate with fuel for a furnace."
	spawn_contents = list(/obj/item/raw_material/char = 30)

/obj/storage/crate/robotics_supplies
	name = "robotics supplies crate"
	desc = "A crate containing supplies for Robotics."
	spawn_contents = list(/obj/item/sheet/steel/fullstack = 3,
	/obj/item/sheet/glass/fullstack,
	/obj/item/cell/supercell = 4,
	/obj/item/cable_coil = 2)

/obj/storage/crate/robotics_supplies_borg
	name = "robotics supplies crate"
	desc = "A crate containing supplies for Robotics and an extra set of cyborg parts."
	spawn_contents = list(/obj/item/sheet/steel/fullstack = 3,
	/obj/item/sheet/glass/fullstack,
	/obj/item/ai_interface,
	/obj/item/parts/robot_parts/robot_frame,
	/obj/item/parts/robot_parts/leg/left,
	/obj/item/parts/robot_parts/leg/right,
	/obj/item/parts/robot_parts/arm/left,
	/obj/item/parts/robot_parts/arm/right,
	/obj/item/parts/robot_parts/chest,
	/obj/item/parts/robot_parts/head,
	/obj/item/cell/supercell = 4,
	/obj/item/cable_coil = 2)

/obj/storage/crate/clown
	desc = "A small, cuboid object with a hinged top and empty interior. It looks a little funny."
	spawn_contents = list(/obj/item/clothing/under/misc/clown/fancy,
	/obj/item/clothing/under/misc/clown/dress,
	/obj/item/clothing/under/misc/clown,
	/obj/item/clothing/shoes/clown_shoes,
	/obj/item/clothing/mask/clown_hat,
	/obj/item/storage/box/crayon,
	/obj/item/storage/box/crayon/basic,
	/obj/item/storage/box/balloonbox)

	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			if (prob(5))
				new /obj/item/pen/crayon/rainbow(src)
			return 1

/obj/storage/crate/materials
	name = "building materials crate"
	spawn_contents = list(/obj/item/sheet/steel/fullstack,
	/obj/item/sheet/glass/fullstack)

/*
 *	SPOOKY haunted crate!
 */

/obj/storage/crate/haunted
	icon = 'icons/misc/halloween.dmi'
	icon_state = "crate"
	var/triggered = 0

	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			if(prob(60))
				new /obj/critter/spirit( src )
			return 1

	open()
		..()
		if(!triggered)
			triggered = 1
			gibs(src.loc)
			return

/obj/storage/crate/syndicate_surplus
	var/ready = 0
	grab_stuff_on_spawn = FALSE
	New()
		..()
		SPAWN_DBG(2 SECONDS)
			if (!ready)
				spawn_items()

	proc/spawn_items(var/mob/owner)
		ready = 1
		var/telecrystals = 0
		var/list/possible_items = list()

		if (islist(syndi_buylist_cache))
			for (var/datum/syndicate_buylist/S in syndi_buylist_cache)
				var/blocked = 0
				if (ticker?.mode && S.blockedmode && islist(S.blockedmode) && length(S.blockedmode))
					for (var/V in S.blockedmode)
						if (ispath(V) && istype(ticker.mode, V))
							blocked = 1
							break

				if (blocked == 0 && !S.not_in_crates)
					possible_items += S

		if (islist(possible_items) && length(possible_items))
			while(telecrystals < 18)
				var/datum/syndicate_buylist/item_datum = pick(possible_items)
				if(telecrystals + item_datum.cost > 24) continue
				var/obj/item/I = new item_datum.item(src)
				if (owner)
					item_datum.run_on_spawn(I, owner, TRUE)
					if (owner.mind)
						owner.mind.traitor_crate_items += item_datum
				telecrystals += item_datum.cost

/obj/storage/crate/pizza
	name = "pizza box"
	desc = "A pizza box."
	icon_state = "pizzabox"
	icon_opened = "pizzabox_open"
	icon_closed = "pizzabox"
	icon_welded = "welded-short-horizontal"
	weld_image_offset_Y = -10

	New()
		..()
		src.setMaterial(getMaterial("cardboard"), appearance = 0, setname = 0)

/obj/storage/crate/bee
	name = "Bee crate"
	desc = "A crate with a picture of a bee on it. Buzz."
	icon_state = "beecrate"
	density = 1
	icon_opened = "beecrateopen"
	icon_closed = "beecrate"

	loaded
		spawn_contents = list(/obj/item/bee_egg_carton = 5)

		var/blog = ""

		make_my_stuff()
			.=..()
			if (.)
				for(var/obj/item/bee_egg_carton/carton in src)
					carton.ourEgg.blog += blog
				return 1

// New crates woo. (Gannets)

/obj/storage/crate/packing
	name = "packing crate"
	desc = "A packing crate."
	icon_state = "packingcrate1"

	New()
		var/n = rand(1,12)
		switch(n)
			if(1 to 3)
				weld_image_offset_Y = 7
			if(4 to 6)
				icon_welded = "welded-short-horizontal"
			if(7 to 9)
				weld_image_offset_Y = 4
			if(10 to 12)
				icon_welded = "welded-short-vertical"
		icon_state = "packingcrate[n]"
		icon_opened = "packingcrate[n]_open"
		icon_closed = "packingcrate[n]"
		src.setMaterial(getMaterial("cardboard"), appearance = 0, setname = 0)
		..()

/obj/storage/crate/wooden
	name = "wooden crate"
	desc = "A wooden crate."
	icon_state = "woodencrate1"
	New()
		var/n = rand(1,9)
		switch(n)
			if(1 to 3)
				icon_welded = "welded-short-horizontal"
			if(4 to 6)
				weld_image_offset_Y = 5
			if(7 to 9)
				weld_image_offset_Y = 3

		icon_state = "woodencrate[n]"
		icon_opened = "woodencrate[n]_open"
		icon_closed = "woodencrate[n]"
		src.setMaterial(getMaterial("wood"), appearance = 0, setname = 0)
		..()


/obj/storage/crate/loot_crate
	name = "Loot Crate"
	desc = "A small, cuboid object with a hinged top and loot filled interior."
	spawn_contents = list(/obj/random_item_spawner/loot_crate/surplus)

/obj/storage/crate/chest
	name = "treasure chest"
	desc = "Glittering gold, trinkets and baubles, paid for in blood."
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "chest"
	icon_opened = "chest-open"
	icon_closed = "chest"

	New()
		..()
		src.setMaterial(getMaterial("wood"), appearance = 0, setname = 0)

/obj/storage/crate/chest/coins
	var/coins_count_min = 5
	var/coins_count_max = 50
	New()
		..()
		var/coins_count = rand(coins_count_min, coins_count_max)
		for(var/i in 1 to coins_count)
			var/obj/item/coin/coin = new(src)
			coin.pixel_x = rand(-9, 9)
			coin.pixel_y = rand(0, 6)

/obj/storage/crate/chest/spacebux
	New()
		..()
		var/bux_count = rand(3, 10)
		for(var/i in 1 to bux_count)
			var/obj/item/spacebux/bux = new(src, pick(10, 20, 50, 100, 200, 500))
			bux.pixel_x = rand(-9, 9)
			bux.pixel_y = rand(0, 6)

// Gannets' Nuke Ops Specialist Class Crates

/obj/storage/crate/classcrate
	name = "class crate"
	desc = "A class crate"
	//spawn_contents = list(null)
	icon_state = "attachecase"
	icon_opened = "attachecase_open"
	icon_closed = "attachecase"
	weld_image_offset_Y = -5

	demo
		name = "Class Crate - Grenadier"
		desc = "A crate containing a Specialist Operative loadout. This one features a hand-held grenade launcher and a pile of ordnance."
		spawn_contents = list(/obj/item/gun/kinetic/grenade_launcher,
		/obj/item/storage/pouch/grenade_round,
		/obj/item/storage/grenade_pouch/mixed_explosive,
		/obj/item/clothing/suit/space/syndicate/specialist/grenadier,
		/obj/item/clothing/head/helmet/space/syndicate/specialist)

	heavy
		name = "Class Crate - Heavy Weapons Specialist"
		desc = "A crate containing a Specialist Operative loadout. This one features a light machine gun, several belts of ammunition and a pouch of grenades."
		spawn_contents = list(/obj/item/gun/kinetic/light_machine_gun,
		/obj/item/storage/pouch/lmg,
		/obj/item/storage/grenade_pouch/high_explosive,
		/obj/item/storage/fanny/syndie,
		/obj/item/clothing/suit/space/industrial/syndicate/specialist,
		/obj/item/clothing/head/helmet/space/syndicate/specialist)

	assault
		name = "Class Crate - Assault Trooper"
		desc = "A crate containing a Specialist Operative loadout. This one includes a customized assault rifle, several additional magazines as well as an assortment of breach and clear grenades."
		spawn_contents = list(/obj/item/gun/kinetic/assault_rifle,
		/obj/item/storage/pouch/assault_rifle/mixed,
		/obj/item/storage/grenade_pouch/mixed_standard,
		/obj/item/breaching_charge = 2,
		/obj/item/clothing/suit/space/syndicate/specialist,
		/obj/item/clothing/head/helmet/space/syndicate/specialist)

	agent // not avaliable for purchase
		name = "Class Crate - Infiltrator"
		desc = "A crate containing a Specialist Operative loadout. This one includes a pair of semi-automatic pistols, a combat knife, an electromagnetic card (EMAG) and a cloaking device."
		spawn_contents = list(/obj/item/gun/kinetic/pistol = 2,
		/obj/item/storage/pouch/bullet_9mm,
		/obj/item/clothing/glasses/nightvision,
		/obj/item/cloaking_device,
		/obj/item/old_grenade/smoke = 2,
		/obj/item/dagger/syndicate/specialist,
		/obj/item/card/emag,
		/obj/item/clothing/suit/space/syndicate/specialist/infiltrator,
		/obj/item/clothing/head/helmet/space/syndicate/specialist/infiltrator)

	infiltrator
		name = "Class Crate - Infiltrator" // for actually fitting in among the crew.
		desc = "A crate containing a Specialist Operative loadout."
		spawn_contents = list(/obj/item/gun/kinetic/tranq_pistol,
		/obj/item/storage/pouch/tranq_pistol_dart,
		/obj/item/pinpointer/disk,
		/obj/item/genetics_injector/dna_scrambler,
		/obj/item/voice_changer,
		/obj/item/card/emag,
		/obj/item/clothing/under/chameleon,
		/obj/item/device/chameleon,
		/obj/item/clothing/suit/space/syndicate/specialist,
		/obj/item/clothing/head/helmet/space/syndicate/specialist/infiltrator)

	scout
		name = "Class Crate - Scout" // sneaky invisible flanker
		desc = "A crate containing a Specialist Operative loadout. Includes a submachine gun, a cloaking device and an electromagnetic card (EMAG)."
		spawn_contents = list(/obj/item/gun/kinetic/smg,
		/obj/item/storage/pouch/bullet_9mm/smg,
		/obj/item/clothing/glasses/nightvision,
		/obj/item/pinpointer/disk,
		/obj/item/cloaking_device,
		/obj/item/card/emag,
		/obj/item/lightbreaker,
		/obj/item/clothing/suit/space/syndicate/specialist/infiltrator,
		/obj/item/clothing/head/helmet/space/syndicate/specialist/infiltrator)

	medic
		name = "Class Crate - Combat Medic"
		desc = "A crate containing a Specialist Operative loadout. This one is packed with medical supplies, some poison and a syringe gun delivery system."
		spawn_contents = list(/obj/item/gun/reagent/syringe,
		/obj/item/reagent_containers/glass/bottle/syringe_canister/neurotoxin = 2,
		/obj/item/reagent_containers/emergency_injector/high_capacity/juggernaut,
		/obj/item/reagent_containers/emergency_injector/high_capacity/donk_injector,
		/obj/item/clothing/glasses/healthgoggles/upgraded,
		/obj/item/device/analyzer/healthanalyzer/borg,
		/obj/item/storage/medical_pouch,
		/obj/item/storage/belt/syndicate_medic_belt,
		/obj/item/storage/backpack/satchel/syndie/syndicate_medic_satchel,
		/obj/item/clothing/suit/space/syndicate/specialist/medic,
		/obj/item/clothing/head/helmet/space/syndicate/specialist/medic)

	medic_rework
		name = "Class Crate - Field Medic"
		desc = "A crate containing a Specialist Operative loadout. This one is packed with medical supplies."
		spawn_contents = list(/obj/item/clothing/glasses/healthgoggles/upgraded,
		/obj/item/device/analyzer/healthanalyzer/borg,
		/obj/item/storage/medical_pouch,
		/obj/item/storage/belt/syndicate_medic_belt,
		/obj/item/storage/backpack/satchel/syndie/syndicate_medic_satchel,
		/obj/item/clothing/suit/space/syndicate/specialist/medic,
		/obj/item/clothing/head/helmet/space/syndicate/specialist/medic)

	engineer
		name = "Class Crate - Combat Engineer"
		desc = "A crate containing a Specialist Operative loadout."
		spawn_contents = list(/obj/item/paper/nast_manual,
		/obj/item/turret_deployer,
		/obj/item/wrench/battle,
		/obj/item/gun/kinetic/spes/engineer,
		/obj/item/storage/pouch/shotgun/weak,
		/obj/item/weldingtool/high_cap,
		/obj/item/storage/belt/utility/prepared,
		/obj/item/clothing/glasses/meson,
		/obj/item/clothing/suit/space/syndicate/specialist/engineer,
		/obj/item/clothing/head/helmet/space/syndicate/specialist/engineer)

	pyro
		name = "Class Crate - Firebrand"
		desc = "A crate containing a Specialist Operative loadout."
		spawn_contents = list(/obj/item/gun/flamethrower/backtank/napalm,
		/obj/item/fireaxe,
		/obj/item/storage/grenade_pouch/napalm,
		/obj/item/storage/grenade_pouch/incendiary,
		/obj/item/storage/fanny/syndie,
		/obj/item/clothing/suit/space/syndicate/specialist/firebrand,
		/obj/item/clothing/head/helmet/space/syndicate/specialist/firebrand)

	sniper
		name = "Class Crate - Marksman"
		desc = "A crate containing a Specialist Operative loadout."
		spawn_contents = list(/obj/item/gun/kinetic/sniper,
		/obj/item/storage/pouch/sniper,
		/obj/item/storage/grenade_pouch/smoke,
		/obj/item/storage/fanny/syndie,
		/obj/item/clothing/glasses/thermal/traitor,
		/obj/item/clothing/suit/space/syndicate/specialist/sniper,
		/obj/item/clothing/head/helmet/space/syndicate/specialist/sniper)

	melee //wip, not ready for use
		name = "Class Crate - Knight"
		desc = "A crate containing a Specialist Operative loadout."
		spawn_contents = list(/obj/item/heavy_power_sword,
		/obj/item/clothing/shoes/swat/knight,
		/obj/item/clothing/gloves/swat/knight,
		/obj/item/clothing/suit/space/syndicate/knight,
		/obj/item/clothing/head/helmet/space/syndicate/specialist/knight)

	bard
		name = "Class Crate - Rocker"
		desc = "A crate containing a Specialist Operative loadout."
		spawn_contents = list(/obj/item/breaching_hammer/rock_sledge,
		/obj/item/device/radio/headset/syndicate/bard,
		/obj/item/storage/fanny/syndie,
		/obj/item/clothing/suit/space/syndicate/specialist/firebrand, // Gannets should make a cool suit
		/obj/item/clothing/head/helmet/space/syndicate/specialist/infiltrator) // Gannet should make cool helm

	qm //Hi Gannets, I like your crate and wanted to use it for some QM stuff. Come yell at Azungar if this is not ok.
		name = "Weapons crate"
		desc = "Just a fancy crate that may or may not contain weapons."


//trench loots : gps, clothing/armor, meds, shipcomponents, foods, etc

/obj/storage/crate/trench_loot
	name = "rusted crate"
	desc = "This crate looks old. The lock has rusted off."
	//spawn_contents = list(null)
	icon_state = "rustedcrate"
	icon_opened = "rustedcrate_open"
	icon_closed = "rustedcrate"

	var/datum/light/point/light = 0
	var/init = 0

	New()
		..()
		if (current_state == GAME_STATE_PLAYING)
			initialize()

	disposing()
		light = 0
		..()

	initialize()
		..()
		if (!init)
			init = 1
			if (!light)
				light = new
				light.attach(src)
			light.set_brightness(1)
			light.set_color(0.4, 1, 0.4)
			light.set_height(3)
			light.enable()

	meds
		spawn_contents = list(/obj/item/storage/firstaid/old = 2,
		/obj/item/reagent_containers/vape/medical/o2,
		/obj/item/storage/pill_bottle/epinephrine,
		/obj/item/storage/pill_bottle/salicylic_acid)

	meds2
		spawn_contents = list(/obj/item/reagent_containers/glass/beaker/large/epinephrine,
		/obj/item/reagent_containers/glass/beaker/large/antitox,
		/obj/item/reagent_containers/glass/beaker/large/brute,
		/obj/item/reagent_containers/glass/beaker/large/burn,
		/obj/item/reagent_containers/syringe)

	ore
		spawn_contents = list(/obj/item/raw_material/erebite = 5,
		/obj/item/raw_material/miracle = 2,
		/obj/item/raw_material/telecrystal = 5,
		/obj/item/raw_material/cerenkite = 5,
		/obj/item/mining_tool/powerhammer)

	ore2
		spawn_contents = list(/obj/item/raw_material/plasmastone = 5,
		/obj/item/raw_material/uqill = 5,
		/obj/item/clothing/head/helmet/space/industrial,
		/obj/item/clothing/suit/space/industrial,
		/obj/item/mining_tool/power_pick)

	ore3
		spawn_contents = list(/obj/item/raw_material/cobryl = 5,
		/obj/item/raw_material/gold = 5,
		/obj/item/raw_material/claretine = 5,
		/obj/item/raw_material/bohrum = 5,
		/obj/item/mining_tool)

	ore4
		spawn_contents = list(/obj/item/raw_material/fibrilith = 5,
		/obj/item/raw_material/miracle = 3,
		/obj/item/raw_material/starstone,
		/obj/item/mining_tool)

	rad
		spawn_contents = list(/obj/item/clothing/suit/rad,
		/obj/item/mine/radiation = 5,
		/obj/item/clothing/head/rad_hood,
		/obj/item/storage/pill_bottle/antirad,
		/obj/item/storage/pill_bottle/antitox,
		/obj/item/storage/pill_bottle/mutadone,
		/obj/item/reagent_containers/glass/beaker/cryoxadone)

	drug
		spawn_contents = list(/obj/item/reagent_containers/patch/synthflesh = 3,
		/obj/item/storage/pill_bottle/methamphetamine,
		/obj/item/reagent_containers/syringe/krokodil,
		/obj/item/reagent_containers/glass/beaker/stablemut,
		/obj/item/reagent_containers/food/drinks/rum_spaced)

	ship
		spawn_contents = list(/obj/item/shipcomponent/mainweapon/mining,
		/obj/item/shipcomponent/secondary_system/repair,
		/obj/item/shipcomponent/sensor/mining,
		/obj/item/shipcomponent/secondary_system/gps)

	ship2
		spawn_contents = list(/obj/item/shipcomponent/mainweapon/foamer,
		/obj/item/shipcomponent/sensor/mining,
		/obj/item/shipcomponent/secondary_system/tractor_beam)

	ship3
		spawn_contents = list(/obj/item/shipcomponent/mainweapon/rockdrills,
		/obj/item/shipcomponent/sensor/mining)

	clothes
		spawn_contents = list(/obj/item/clothing/under/gimmick/blackstronaut,
		/obj/item/clothing/shoes/cleats,
		/obj/item/clothing/mask/balaclava,
		/obj/item/reagent_containers/glass/beaker/burn)

	clothes2
		spawn_contents = list(/obj/item/clothing/under/gimmick/mario/luigi,
		/obj/item/clothing/suit/wizrobe/green,
		/obj/item/clothing/shoes/galoshes,
		/obj/item/reagent_containers/glass/beaker/burn)

	tools
		spawn_contents = list(/obj/item/hand_tele,
		/obj/item/device/flash,
		/obj/item/device/pda2/captain)

	tools2
		spawn_contents = list(/obj/item/storage/toolbox/mechanical,
		/obj/machinery/bot/medbot,
		/obj/item/device/light/flashlight,
		/obj/item/device/radio,
		/obj/item/cell/erebite/charged)

	weapons
		spawn_contents = list(/obj/item/gun/energy/phaser_gun,
		/obj/item/old_grenade/stinger = 2,
		/obj/item/ammo/power_cell/med_power)

	weapons2
		spawn_contents = list(/obj/item/gun/energy/laser_gun,
		/obj/item/chem_grenade/cryo = 4)

	weapons3
		spawn_contents = list(/obj/item/barrier,
		/obj/item/chem_grenade/shock = 2)

	weapons4
		spawn_contents = list(/obj/item/gun/kinetic/zipgun,
		/obj/item/ammo/bullets/a38 = 2)

	cargonia
		spawn_contents = list(/obj/item/radio_tape/advertisement/cargonia,
		/obj/item/clothing/under/rank/cargo,/obj/decal/skeleton)

	escape
		spawn_contents = list(/obj/item/sea_ladder,
		/obj/item/pipebomb/bomb/engineering = 2)
