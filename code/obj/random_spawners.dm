
/obj/random_item_spawner
	name = "random item spawner"
	icon = 'icons/obj/objects.dmi'
	icon_state = "itemspawn"
	density = 0
	anchored = ANCHORED
	invisibility = INVIS_ALWAYS
	layer = 99
	var/amt2spawn = 0
	var/min_amt2spawn = 0
	var/max_amt2spawn = 0
	var/rare_chance = 0 // chance (out of 100) that the rare item list will be spawned instead of the common one
	var/list/items2spawn = list()
	var/list/rare_items2spawn = list() // things that only rarely appear, independent of how big or small the main item list is
	var/list/guaranteed = list() // things that will always spawn from this - set to a number to spawn that many of the thing

	// TODO: initialize
	New()
		..()
		SPAWN(1 DECI SECOND)
			src.spawn_items()
			sleep(2 SECONDS) // ZEWAKA/INIT
			qdel(src)

	proc/spawn_items()
		SHOULD_NOT_SLEEP(TRUE)
		if (islist(src.guaranteed) && length(src.guaranteed))
			for (var/obj/new_item as anything in src.guaranteed)
				if (!ispath(new_item))
					logTheThing(LOG_DEBUG, src, "has a non-path item in its guaranteed list, [new_item]")
					DEBUG_MESSAGE("[src] has a non-path item in its guaranteed list, [new_item]")
					continue
				var/amt = 1
				if (isnum(guaranteed[new_item]))
					amt = abs(guaranteed[new_item])
				for (amt, amt>0, amt--)
					closet_check_spawn(new_item)

		if (!islist(src.items2spawn) || !length(src.items2spawn))
			var/area/area = get_area(src)
			CRASH("[identify_object(src)] at [src.x],[src.y],[src.z] ([area] [area.type]) has an invalid rare_items2spawn list")
		if (rare_chance)
			if (!islist(src.rare_items2spawn) || !length(src.rare_items2spawn))
				var/area/area = get_area(src)
				CRASH("[identify_object(src)] at [src.x],[src.y],[src.z] ([area] [area.type]) has an invalid rare_items2spawn list")
		if (amt2spawn == 0)
			amt2spawn = rand(min_amt2spawn, max_amt2spawn)
		if (amt2spawn == 0) // If for whatever reason we still end up with 0...
			return
		for (amt2spawn, amt2spawn>0, amt2spawn--)
			// first, decide whether or not we will spawn a rare item!
			var/list/item_list = list()
			if (prob(rare_chance))
				if (rare_items2spawn)
					item_list = rare_items2spawn
				else
					var/area/area = get_area(src)
					stack_trace("[identify_object(src)] at [src.x],[src.y],[src.z] ([area] [area.type]) has an invalid rare spawn list, [json_encode(rare_items2spawn)]")
					continue
			else
				item_list = items2spawn
			var/obj/new_item = pick(item_list)
			if (!ispath(new_item))
				var/area/area = get_area(src)
				stack_trace("[identify_object(src)] at [src.x],[src.y],[src.z] ([area] [area.type]) has a non-path item in its spawn list, [new_item]")
				continue

			closet_check_spawn(new_item)

	proc/closet_check_spawn(var/obj/item/new_item)
		var/obj/storage/S = locate(/obj/storage) in src.loc
		if (S)
			new new_item(S)
		else
			new new_item(src.loc)

/obj/random_item_spawner/snacks
	name = "random snack spawner"
	icon_state = "rand_snacks"
	min_amt2spawn = 1
	max_amt2spawn = 1
	items2spawn = list(/obj/item/reagent_containers/food/snacks/candy/chocolate,
	/obj/item/reagent_containers/food/snacks/candy/nougat,
	/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/butterscotch,
	/obj/item/reagent_containers/food/snacks/sandwich/meat_h,
	/obj/item/reagent_containers/food/snacks/sandwich/meat_m,
	/obj/item/reagent_containers/food/snacks/sandwich/meat_s,
	/obj/item/reagent_containers/food/snacks/sandwich/pb,
	/obj/item/reagent_containers/food/snacks/sandwich/pbh,
	/obj/item/reagent_containers/food/snacks/sandwich/cheese,
	/obj/item/reagent_containers/food/snacks/cookie,
	/obj/item/reagent_containers/food/snacks/cookie/oatmeal,
	)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/tools
	name = "random tool spawner"
	icon_state = "rand_tool"
	min_amt2spawn = 3
	max_amt2spawn = 7
	items2spawn = list(/obj/item/crowbar,
	/obj/item/wirecutters,
	/obj/item/wrench,
	/obj/item/screwdriver,
	/obj/item/weldingtool,
	/obj/item/device/multitool,
	/obj/item/cable_coil/cut/small,
	/obj/item/cable_coil,
	/obj/item/sheet/steel/fullstack,
	/obj/item/sheet/steel/reinforced/fullstack,
	/obj/item/sheet/glass/fullstack,
	/obj/item/sheet/glass/reinforced/fullstack,
	/obj/item/rods/steel/fullstack,
	/obj/item/tile/steel/fullstack,
	/obj/item/storage/toolbox/mechanical,
	/obj/item/storage/toolbox/electrical,
	/obj/item/storage/toolbox/emergency,
	/obj/item/storage/box/cablesbox,
	/obj/item/storage/box/lightbox,
	/obj/item/storage/box/lightbox/tubes,
	/obj/item/clothing/gloves/black,
	/obj/item/clothing/head/helmet/hardhat,
	/obj/item/clothing/head/helmet/welding,
	/obj/item/cell,
	/obj/item/cell/supercell,
	/obj/item/device/light/flashlight,
	/obj/item/device/light/glowstick,
	/obj/item/device/t_scanner,
	/obj/item/device/analyzer/atmospheric,
	/obj/item/device/analyzer/atmosanalyzer_upgrade,
	/obj/item/extinguisher,
	/obj/item/reagent_containers/glass/oilcan,
	/obj/item/storage/belt/utility)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/tools_w_igloves
	name = "random tool spawner (includes insulated gloves)"
	icon_state = "rand_tool_iglove"
	min_amt2spawn = 3
	max_amt2spawn = 7
	items2spawn = list(/obj/item/crowbar,
	/obj/item/wirecutters,
	/obj/item/wrench,
	/obj/item/screwdriver,
	/obj/item/weldingtool,
	/obj/item/device/multitool,
	/obj/item/cable_coil/cut/small,
	/obj/item/cable_coil,
	/obj/item/sheet/steel/fullstack,
	/obj/item/sheet/steel/reinforced/fullstack,
	/obj/item/sheet/glass/fullstack,
	/obj/item/sheet/glass/reinforced/fullstack,
	/obj/item/rods/steel/fullstack,
	/obj/item/tile/steel/fullstack,
	/obj/item/storage/toolbox/mechanical,
	/obj/item/storage/toolbox/electrical,
	/obj/item/storage/toolbox/emergency,
	/obj/item/storage/box/cablesbox,
	/obj/item/storage/box/lightbox,
	/obj/item/storage/box/lightbox/tubes,
	/obj/item/clothing/gloves/black,
	/obj/item/clothing/gloves/yellow,
	/obj/item/clothing/head/helmet/hardhat,
	/obj/item/clothing/head/helmet/welding,
	/obj/item/cell,
	/obj/item/cell/supercell,
	/obj/item/device/light/flashlight,
	/obj/item/device/light/glowstick,
	/obj/item/device/t_scanner,
	/obj/item/device/analyzer/atmospheric,
	/obj/item/device/analyzer/atmosanalyzer_upgrade,
	/obj/item/extinguisher,
	/obj/item/reagent_containers/glass/oilcan,
	/obj/item/storage/belt/utility)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/med_tool
	name = "random medical tool spawner"
	icon_state = "rand_med_tool"
	min_amt2spawn = 4
	max_amt2spawn = 8
	items2spawn = list(/obj/item/scalpel,
	/obj/item/circular_saw,
	/obj/item/staple_gun,
	/obj/item/robodefibrillator,
	/obj/item/hemostat,
	/obj/item/suture,
	/obj/item/bandage,
	/obj/item/body_bag,
	/obj/item/device/analyzer/healthanalyzer,
	/obj/item/device/analyzer/healthanalyzer_upgrade,
	/obj/item/reagent_containers/dropper,
	/obj/item/reagent_containers/dropper/mechanical,
	/obj/item/storage/box/syringes,
	/obj/item/storage/box/patchbox,
	/obj/item/storage/box/iv_box,
	/obj/item/reagent_containers/hypospray,
	/obj/item/clothing/glasses/healthgoggles,
	/obj/item/storage/box/lglo_kit/random,
	/obj/item/storage/box/stma_kit,
	/obj/item/clothing/mask/surgical_shield,
	/obj/item/storage/belt/medical)

	one
	amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/medicine
	name = "random medicine spawner"
	icon_state = "rand_medicine"
	min_amt2spawn = 4
	max_amt2spawn = 8
	items2spawn = list(/obj/item/storage/pill_bottle/antirad,
	/obj/item/storage/pill_bottle/mutadone,
	/obj/item/storage/pill_bottle/epinephrine,
	/obj/item/storage/pill_bottle/antitox,
	/obj/item/storage/pill_bottle/salbutamol,
	/obj/item/reagent_containers/syringe/epinephrine,
	/obj/item/reagent_containers/syringe/insulin,
	/obj/item/reagent_containers/syringe/haloperidol,
	/obj/item/reagent_containers/syringe/antitoxin,
	/obj/item/reagent_containers/syringe/antiviral,
	/obj/item/reagent_containers/syringe/atropine,
	/obj/item/reagent_containers/syringe/morphine,
	/obj/item/reagent_containers/syringe/calomel,
	/obj/item/reagent_containers/syringe/heparin,
	/obj/item/reagent_containers/syringe/proconvertin,
	/obj/item/reagent_containers/syringe/filgrastim,
	/obj/item/reagent_containers/iv_drip/blood,
	/obj/item/reagent_containers/iv_drip/saline,
	/obj/item/reagent_containers/glass/bottle/epinephrine,
	/obj/item/reagent_containers/glass/bottle/atropine,
	/obj/item/reagent_containers/glass/bottle/saline,
	/obj/item/reagent_containers/glass/bottle/aspirin,
	/obj/item/reagent_containers/glass/bottle/morphine,
	/obj/item/reagent_containers/glass/bottle/antitoxin,
	/obj/item/reagent_containers/glass/bottle/antihistamine,
	/obj/item/reagent_containers/glass/bottle/eyedrops,
	/obj/item/reagent_containers/glass/bottle/antirad,
	/obj/item/reagent_containers/glass/beaker/cryoxadone,
	/obj/item/reagent_containers/glass/beaker/large/epinephrine,
	/obj/item/reagent_containers/glass/beaker/large/antitox,
	/obj/item/reagent_containers/glass/beaker/large/brute,
	/obj/item/reagent_containers/glass/beaker/large/burn,
	/obj/item/reagent_containers/emergency_injector/epinephrine,
	/obj/item/reagent_containers/emergency_injector/atropine,
	/obj/item/reagent_containers/emergency_injector/charcoal,
	/obj/item/reagent_containers/emergency_injector/saline,
	/obj/item/reagent_containers/emergency_injector/anti_rad,
	/obj/item/reagent_containers/emergency_injector/insulin,
	/obj/item/reagent_containers/emergency_injector/calomel,
	/obj/item/reagent_containers/emergency_injector/salicylic_acid,
	/obj/item/reagent_containers/emergency_injector/spaceacillin,
	/obj/item/reagent_containers/emergency_injector/antihistamine,
	/obj/item/reagent_containers/emergency_injector/salbutamol,
	/obj/item/reagent_containers/emergency_injector/mannitol,
	/obj/item/reagent_containers/emergency_injector/mutadone,
	/obj/item/reagent_containers/emergency_injector/heparin,
	/obj/item/reagent_containers/emergency_injector/proconvertin,
	/obj/item/reagent_containers/emergency_injector/filgrastim,
	/obj/item/item_box/medical_patches/styptic,
	/obj/item/item_box/medical_patches/mini_styptic,
	/obj/item/item_box/medical_patches/silver_sulf,
	/obj/item/item_box/medical_patches/mini_silver_sulf,
	/obj/item/item_box/medical_patches/synthflesh,
	/obj/item/item_box/medical_patches/mini_synthflesh)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/med_kit
	name = "random medical kit spawner"
	icon_state = "rand_medkit"
	min_amt2spawn = 2
	max_amt2spawn = 4
	items2spawn = list(/obj/item/storage/firstaid/regular,
	/obj/item/storage/firstaid/brute,
	/obj/item/storage/firstaid/fire,
	/obj/item/storage/firstaid/toxin,
	/obj/item/storage/firstaid/oxygen,
	/obj/item/storage/firstaid/brain)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/desk_stuff
	name = "random desk item spawner"
	icon_state = "rand_desk"
	min_amt2spawn = 2
	max_amt2spawn = 5
	items2spawn = list(/obj/item/pen,
	/obj/item/pen/fancy,
	/obj/item/pen/red,
	/obj/item/pen/pencil,
	/obj/item/pen/marker,
	/obj/item/pen/marker/red,
	/obj/item/pen/marker/blue,
	/obj/item/storage/box/crayon,
	/obj/item/storage/box/crayon/basic,
	/obj/item/storage/box/marker,
	/obj/item/storage/box/marker/basic,
	/obj/item/hand_labeler,
	/obj/item/clipboard,
	/obj/item/stamp,
	/obj/item/paper,
	/obj/item/paper_bin,
	/obj/decal/cleanable/generic,
	/obj/item/reagent_containers/food/drinks/mug/random_color,
	/obj/item/item_box/postit,
	/obj/item/staple_gun/red)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/desk_stuff/g_clip_bin_pen
	name = "random desk item spawner (guaranteed basic)"
	icon_state = "rand_desk_g_basic"
	guaranteed = list(/obj/item/clipboard,
	/obj/item/paper_bin,
	/obj/item/pen)
	items2spawn = list(/obj/item/pen/fancy,
	/obj/item/pen/red,
	/obj/item/pen/pencil,
	/obj/item/pen/marker,
	/obj/item/pen/marker/red,
	/obj/item/pen/marker/blue,
	/obj/item/pen/marker/random,
	/obj/item/storage/box/crayon,
	/obj/item/storage/box/crayon/basic,
	/obj/item/storage/box/marker,
	/obj/item/storage/box/marker/basic,
	/obj/item/hand_labeler,
	/obj/item/stamp,
	/obj/item/paper,
	/obj/decal/cleanable/generic,
	/obj/item/reagent_containers/food/drinks/mug/random_color,
	/obj/item/item_box/postit,
	/obj/item/staple_gun/red)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/desk_stuff/g_clip_bin_fpen
	name = "random desk item spawner (guaranteed fancy)"
	icon_state = "rand_desk_g_fpen"
	guaranteed = list(/obj/item/clipboard,
	/obj/item/paper_bin,
	/obj/item/stamp,
	/obj/item/pen/fancy)
	items2spawn = list(/obj/item/pen,
	/obj/item/pen/red,
	/obj/item/pen/pencil,
	/obj/item/pen/marker,
	/obj/item/pen/marker/red,
	/obj/item/pen/marker/blue,
	/obj/item/pen/marker/random,
	/obj/item/storage/box/crayon,
	/obj/item/storage/box/crayon/basic,
	/obj/item/storage/box/marker,
	/obj/item/storage/box/marker/basic,
	/obj/item/hand_labeler,
	/obj/item/paper,
	/obj/decal/cleanable/generic,
	/obj/item/reagent_containers/food/drinks/mug/random_color,
	/obj/item/item_box/postit,
	/obj/item/staple_gun/red)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/tableware
	name = "random tableware spawner"
	icon_state = "rand_utensil"
	min_amt2spawn = 2
	max_amt2spawn = 7
	items2spawn = list(/obj/item/kitchen/utensil/fork,
	/obj/item/kitchen/utensil/knife,
	/obj/item/kitchen/utensil/spoon,
	/obj/item/plate,
	/obj/item/reagent_containers/food/drinks/bowl,
	/obj/item/reagent_containers/food/drinks/drinkingglass,
	/obj/item/reagent_containers/food/drinks/drinkingglass/shot,
	/obj/item/reagent_containers/food/drinks/drinkingglass/wine,
	/obj/item/reagent_containers/food/drinks/drinkingglass/cocktail,
	/obj/item/reagent_containers/food/drinks/drinkingglass/flute,
	/obj/item/reagent_containers/food/drinks/mug/random_color)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/junk
	name = "random junk spawner"
	icon_state = "rand_junk"
	min_amt2spawn = 2
	max_amt2spawn = 7
	rare_chance = 5
	items2spawn = list(/obj/item/brick,
	/obj/item/c_sheet,
	/obj/item/c_tube,
	/obj/item/cable_coil/cut,
	/obj/item/camera_film,
	/obj/item/casing,
	/obj/item/casing/rifle,
	/obj/item/casing/small,
	/obj/item/cigbutt,
	/obj/item/clothing/head/paper_hat,
	/obj/item/clothing/mask/gas,
	/obj/item/clothing/mask/medical,
	/obj/item/clothing/mask/surgical,
	/obj/item/clothing/shoes/black,
	/obj/item/coin,
	/obj/item/device/infra_sensor,
	/obj/item/device/radio,
	/obj/item/device/timer,
	/obj/item/folder,
	/obj/item/hand_labeler,
	/obj/item/light/bulb/neutral,
	/obj/item/light/tube/neutral,
	/obj/item/match,
	/obj/item/mining_tool,
	/obj/item/mousetrap,
	/obj/item/mousetrap/armed,
	/obj/item/paper,
	/obj/item/sheet/wood,
	/obj/item/plate,
	/obj/item/pen,
	/obj/item/pen/crayon/random,
	/obj/item/raw_material/shard/glass,
	/obj/item/reagent_containers/food/drinks/paper_cup,
	/obj/item/rods/steel,
	/obj/item/rubberduck,
	/obj/item/scissors,
	/obj/item/scrap,
	/obj/item/sheet/glass,
	/obj/item/sheet/steel,
	/obj/item/currency/spacecash/five,
	/obj/item/currency/spacecash/really_small,
	/obj/item/currency/spacecash/small,
	/obj/item/stamp,
	/obj/item/stick,
	/obj/item/tile/steel)

	rare_items2spawn = list(/obj/item/bluntwrap,
	/obj/item/cell,
	/obj/item/crowbar,
	/obj/item/electronics/scanner,
	/obj/item/electronics/soldering,
	/obj/item/light_parts,
	/obj/item/light_parts/bulb,
	/obj/item/light_parts/floor,
	/obj/item/screwdriver,
	/obj/item/spraybottle,
	/obj/item/spongecaps,
	/obj/item/storage/toolbox/mechanical,
	/obj/item/storage/toolbox/electrical,
	/obj/item/storage/toolbox/emergency,
	/obj/item/tank/air,
	/obj/item/tank/emergency_oxygen,
	/obj/item/tank/mini_oxygen,
	/obj/item/weldingtool,
	/obj/item/wrench)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/landmine
	name = "random land mine spawner"
	min_amt2spawn = 1
	max_amt2spawn = 1
	items2spawn = list(/obj/item/mine/radiation/armed,
	/obj/item/mine/incendiary/armed,
	/obj/item/mine/stun/armed,
	/obj/item/mine/blast/armed)

// Loot Crate picker.
/obj/random_item_spawner/loot_crate/surplus
	name = "Loot Crate Spawner"
	guaranteed = list(/obj/item/material_piece/mauxite=10,
	/obj/item/material_piece/molitz=10,
	/obj/item/material_piece/pharosium=10)
	min_amt2spawn = 24
	max_amt2spawn = 42
	items2spawn = list(/obj/item/material_piece/mauxite,
		/obj/item/material_piece/molitz,
		/obj/item/material_piece/pharosium,
		/obj/item/material_piece/cobryl,
		/obj/item/material_piece/claretine,
		/obj/item/material_piece/bohrum,
		/obj/item/material_piece/syreline,
		/obj/item/material_piece/plasmastone,
		/obj/item/material_piece/uqill,
		/obj/item/material_piece/koshmarite,
		/obj/item/stamped_bullion,
		/obj/item/raw_material/cotton,
		/obj/item/raw_material/miracle,
		/obj/item/raw_material/uqill,
		/obj/item/raw_material/cerenkite,
		/obj/item/raw_material/erebite,
		/obj/item/currency/buttcoin,
		/obj/item/currency/spacecash/tourist,
		/obj/item/a_gift/easter)

/obj/random_pod_spawner
	name = "random pod spawner"
	icon = 'icons/obj/objects.dmi'
	icon_state = "podspawn"
	density = 0
	anchored = ANCHORED
	invisibility = INVIS_ALWAYS
	layer = 99
	var/obj/machinery/vehicle/pod2spawn = null

	New()
		..()
		SPAWN(1 DECI SECOND)
			src.set_up()
			sleep(1 SECOND)
			qdel(src)

	proc/set_up()
		// choose pod to spawn and spawn it
		src.spawn_pod()
#ifdef RP_MODE
		// everyone gets a lock
		src.spawn_lock()
#endif

		// add the pod to the list of available random pods
		if (islist(random_pod_codes))
			random_pod_codes += pod2spawn

		// small chance for a paintjob
		if (prob(2))
			src.paint_pod()
		// weapons are common enough
		if (prob(33))
			src.spawn_weapon()
		// maybe a nicer engine
		if (prob(10))
			src.spawn_engine()
		// maybe a nicer sensor
		if (prob(8))
			src.spawn_sensor()
		// maybe let's have been treated a bit rough
		if (prob(5))
			pod2spawn.keyed = rand(1,66)

		// update our hud
		pod2spawn.myhud.update_systems()
		pod2spawn.myhud.update_states()

	proc/spawn_pod()
		var/turf/T = get_turf(src)
		if (prob(1))
			pod2spawn = new /obj/machinery/vehicle/pod_smooth/iridium(T)
		else if (prob(2))
			pod2spawn = new /obj/machinery/vehicle/pod_smooth/black(T)
		else if (prob(3))
			pod2spawn = new /obj/machinery/vehicle/pod_smooth/gold(T)
		else if (prob(5))
			pod2spawn = new /obj/machinery/vehicle/pod_smooth/heavy(T)
		else if (prob(15))
			pod2spawn = new /obj/machinery/vehicle/pod_smooth/industrial(T)
		else
			pod2spawn = new /obj/machinery/vehicle/pod_smooth/light(T)

	proc/spawn_lock()
		pod2spawn.lock = new /obj/item/shipcomponent/secondary_system/lock(pod2spawn)
		pod2spawn.lock.ship = pod2spawn
		pod2spawn.components += pod2spawn.lock
		pod2spawn.lock.code = random_hex(4)
		pod2spawn.locked = 1

	proc/paint_pod()
		var/paintjob
		if (prob(5))
			paintjob = pick(/obj/item/pod/paintjob/tronthing, /obj/item/pod/paintjob/rainbow)
		else
			paintjob = pick(/obj/item/pod/paintjob/flames, /obj/item/pod/paintjob/flames_p, /obj/item/pod/paintjob/flames_b, /obj/item/pod/paintjob/stripe_r, /obj/item/pod/paintjob/stripe_b, /obj/item/pod/paintjob/stripe_g)
		var/obj/item/pod/paintjob/P = new paintjob(pod2spawn)
		pod2spawn.paint_pod(P)

	proc/spawn_weapon()
		var/obj/item/shipcomponent/mainweapon/new_weapon
		if (prob(1))
			new_weapon = pick(/obj/item/shipcomponent/mainweapon/artillery, /obj/item/shipcomponent/mainweapon/precursor)
		else if (prob(3))
			new_weapon = pick(/obj/item/shipcomponent/mainweapon/disruptor, /obj/item/shipcomponent/mainweapon/laser_ass, /obj/item/shipcomponent/mainweapon/gun)
		else if (prob(5))
			new_weapon = pick(/obj/item/shipcomponent/mainweapon/rockdrills, /obj/item/shipcomponent/mainweapon/disruptor_light, /obj/item/shipcomponent/mainweapon/russian, /obj/item/shipcomponent/mainweapon/mining)
		else if (prob(10))
			new_weapon = pick(/obj/item/shipcomponent/mainweapon/phaser, /obj/item/shipcomponent/mainweapon/laser, /obj/item/shipcomponent/mainweapon/taser)
		else
			new_weapon = /obj/item/shipcomponent/mainweapon

		pod2spawn.m_w_system = new new_weapon(pod2spawn)
		pod2spawn.m_w_system.ship = pod2spawn
		pod2spawn.components += pod2spawn.m_w_system
		if (pod2spawn.uses_weapon_overlays)
			pod2spawn.overlays += image(pod2spawn.icon, "[pod2spawn.m_w_system.appearanceString]")

	proc/spawn_engine()
		if (prob(5))
			pod2spawn.engine.deactivate()
			pod2spawn.components -= pod2spawn.engine
			qdel(pod2spawn.engine)

			pod2spawn.engine = new /obj/item/shipcomponent/engine/hermes(pod2spawn)
			pod2spawn.engine.ship = pod2spawn
			pod2spawn.components += pod2spawn.engine
			pod2spawn.engine.activate()

		else
			pod2spawn.engine.deactivate()
			pod2spawn.components -= pod2spawn.engine
			qdel(pod2spawn.engine)

			pod2spawn.engine = new /obj/item/shipcomponent/engine/helios(pod2spawn)
			pod2spawn.engine.ship = pod2spawn
			pod2spawn.components += pod2spawn.engine
			pod2spawn.engine.activate()

	proc/spawn_sensor()
		pod2spawn.sensors.deactivate()
		pod2spawn.components -= pod2spawn.sensors
		qdel(pod2spawn.sensors)

		pod2spawn.sensors = new /obj/item/shipcomponent/sensor/mining(pod2spawn)
		pod2spawn.sensors.ship = pod2spawn
		pod2spawn.components += pod2spawn.sensors
		pod2spawn.sensors.activate()

/obj/random_pod_spawner/random_putt_spawner
	name = "random miniputt spawner"
	icon_state = "puttspawn"

	spawn_pod()
		var/turf/T = get_turf(src)
		if (prob(1))
			pod2spawn = new /obj/machinery/vehicle/miniputt/iridium(T)
		else if (prob(1))
			pod2spawn = new /obj/machinery/vehicle/miniputt/soviputt(T)
		else if (prob(2))
			pod2spawn = new /obj/machinery/vehicle/miniputt/black(T)
		else if (prob(3))
			pod2spawn = new /obj/machinery/vehicle/miniputt/gold(T)
		else if (prob(5))
			pod2spawn = new /obj/machinery/vehicle/miniputt/nanoputt(T)
		else if (prob(15))
			pod2spawn = new /obj/machinery/vehicle/miniputt/indyputt(T)
		else
			pod2spawn = new /obj/machinery/vehicle/miniputt(T)

// Random spawners for cargo crates. (Gannets)

/obj/random_item_spawner/prosthetics
	name = "random prosthesis spawner"
	min_amt2spawn = 6
	max_amt2spawn = 8
	items2spawn = list(/obj/item/parts/robot_parts/arm/left/sturdy,
	/obj/item/parts/robot_parts/arm/right/sturdy,
	/obj/item/parts/robot_parts/arm/left/heavy,
	/obj/item/parts/robot_parts/arm/right/heavy,
	/obj/item/parts/robot_parts/arm/left/light,
	/obj/item/parts/robot_parts/arm/right/light,
	/obj/item/parts/robot_parts/leg/right/treads,
	/obj/item/parts/robot_parts/leg/left/treads,
	/obj/item/organ/eye/cyber/prodoc,
	/obj/item/organ/eye/cyber/nightvision)

/obj/random_item_spawner/critter
	name = "random critter spawner"
	icon_state = "rand_critter"
	min_amt2spawn = 4
	max_amt2spawn = 6
	items2spawn = list(/obj/critter/domestic_bee,
	/obj/critter/bat,
	/mob/living/critter/small_animal/mouse,
	/mob/living/critter/small_animal/opossum,
	/mob/living/critter/small_animal/dog,
	/mob/living/critter/small_animal/dog/george,
	/mob/living/critter/small_animal/dog/blair,
	/mob/living/critter/small_animal/dog/shiba,
	/mob/living/critter/small_animal/pig,
	/obj/critter/seagull/gannet,
	/obj/critter/crow,
	/obj/critter/seagull,
	/mob/living/critter/spider/nice,
	/mob/living/critter/small_animal/bird/goose,
	/mob/living/critter/small_animal/bird/goose/swan)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/peripherals
	name = "random peripheral spawner"
	icon_state = "rand_peripheral"
	min_amt2spawn = 5
	max_amt2spawn = 8
	items2spawn = list(/obj/item/motherboard,
					/obj/item/peripheral/network/radio/locked,
					/obj/item/peripheral/network/powernet_card,
					/obj/item/peripheral/printer,
					/obj/item/peripheral/prize_vendor,
					/obj/item/peripheral/card_scanner,
					/obj/item/peripheral/sound_card,
					/obj/item/peripheral/drive/cart_reader,
					/obj/item/peripheral/drive/tape_reader,
					/obj/item/peripheral/cell_monitor,
					/obj/item/peripheral/videocard)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/circuitboards
	name = "random circuitboard spawner"
	icon_state = "rand_circuit"
	min_amt2spawn = 2
	max_amt2spawn = 4
	items2spawn = list(/obj/item/circuitboard/security,
					/obj/item/circuitboard/stockexchange,
					/obj/item/circuitboard/general_alert,
					/obj/item/circuitboard/atm,
					/obj/item/circuitboard/solar_control,
					/obj/item/circuitboard/arcade,
					/obj/item/circuitboard/powermonitor,
					/obj/item/circuitboard/barcode,
					/obj/item/circuitboard/operating)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/buddytool
	name = "random buddy tool spawner"
	icon_state = "rand_btool"
	min_amt2spawn = 1
	max_amt2spawn = 2
	items2spawn = list (/obj/item/device/guardbot_tool/medicator,
						/obj/item/device/guardbot_tool/smoker,
						/obj/item/device/guardbot_tool/taser,
						/obj/item/device/guardbot_tool/flash)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/dressup
	name = "random gimmick clothing spawner"
	icon_state = "rand_gimmick"
	min_amt2spawn = 5
	max_amt2spawn = 10
	items2spawn = list(
		/obj/item/clothing/under/gimmick/macho,
		/obj/item/clothing/under/gimmick/bowling,
		/obj/item/clothing/under/gimmick/hunter,
		/obj/item/clothing/under/gimmick/owl,
		/obj/item/clothing/under/gimmick/waldo,
		/obj/item/clothing/under/gimmick/odlaw,
		/obj/item/clothing/under/gimmick/fake_waldo,
		/obj/item/clothing/under/gimmick/johnny,
		/obj/item/clothing/under/gimmick/police,
		/obj/item/clothing/under/gimmick/donk,
		/obj/item/clothing/under/gimmick/duke,
		/obj/item/clothing/under/gimmick/mj_clothes,
		/obj/item/clothing/under/gimmick/viking,
		/obj/item/clothing/under/gimmick/merchant,
		/obj/item/clothing/under/gimmick/spiderman,
		/obj/item/clothing/under/gimmick/birdman,
		/obj/item/clothing/under/gimmick/chav,
		/obj/item/clothing/under/gimmick/safari,
		/obj/item/clothing/under/gimmick/utena,
		/obj/item/clothing/under/gimmick/anthy,
		/obj/item/clothing/under/gimmick/butler,
		/obj/item/clothing/under/gimmick/maid,
		/obj/item/clothing/under/gimmick/kilt,
		/obj/item/clothing/under/gimmick/wedding_dress,
		/obj/item/clothing/under/gimmick/psyche,
		/obj/item/clothing/under/gimmick/dolan,
		/obj/item/clothing/under/gimmick/jetson,
		/obj/item/clothing/under/gimmick/princess,
		/obj/item/clothing/under/gimmick/sweater,
		/obj/item/clothing/suit/chaps,
		/obj/item/clothing/under/gimmick/vault13,
		/obj/item/clothing/under/gimmick/murph,
		/obj/item/clothing/under/gimmick/sealab,
		/obj/item/clothing/under/gimmick/rainbow,
		/obj/item/clothing/under/gimmick/yay,
		/obj/item/clothing/under/gimmick/cloud,
		/obj/item/clothing/under/gimmick/mario/luigi,
		/obj/item/clothing/under/gimmick/mario/wario,
		/obj/item/clothing/under/gimmick/mario/waluigi,
		/obj/item/clothing/under/gimmick/mario,
		/obj/item/clothing/under/gimmick/shirtnjeans,
		/obj/item/clothing/under/gimmick/hakama/random,
		/obj/item/clothing/under/gimmick/eightiesmens,
		/obj/item/clothing/under/gimmick/eightieswomens,
		/obj/item/clothing/under/gimmick/ziggy,
		/obj/item/clothing/under/gimmick/jcdenton,
		/obj/item/clothing/under/misc/mobster,
		/obj/item/clothing/under/misc/mobster/alt,
		/obj/item/clothing/under/gimmick/guybrush)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/mask
	name = "random mask spawner"
	icon_state = "rand_mask"
	min_amt2spawn = 5
	max_amt2spawn = 10
	items2spawn = list(/obj/item/clothing/mask/owl_mask,
						/obj/item/clothing/mask/smile,
						/obj/item/clothing/mask/batman,
						/obj/item/clothing/mask/clown_hat,
						/obj/item/clothing/mask/clown_hat/blue,
						/obj/item/clothing/mask/balaclava,
						/obj/item/clothing/mask/spiderman,
						/obj/item/clothing/mask/horse_mask,
						/obj/item/clothing/mask/gas/plague,
						/obj/item/clothing/mask/skull,
						/obj/item/clothing/mask/niccage,
						/obj/item/clothing/mask/waltwhite,
						/obj/item/clothing/mask/mmyers,
						/obj/item/clothing/mask/mime,
						/obj/item/clothing/mask/moustache,
						/obj/item/clothing/mask/melons,
						/obj/item/clothing/mask/wrestling,
						/obj/item/clothing/mask/wrestling/black,
						/obj/item/clothing/mask/wrestling/green,
						/obj/item/clothing/mask/wrestling/blue,
						/obj/item/clothing/mask/anime,
						/obj/item/paper_mask,
						/obj/item/clothing/mask/kitsune,
						/obj/item/clothing/head/minotaurmask,
						/obj/item/clothing/mask/tengu)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/pizza
	name = "random pizza spawner"
	icon_state = "rand_pizza"
	min_amt2spawn = 2
	max_amt2spawn = 2
	rare_chance = 1
	items2spawn = list(/obj/item/reagent_containers/food/snacks/pizza/cargo/cheese,
						/obj/item/reagent_containers/food/snacks/pizza/cargo/pepperoni,
						/obj/item/reagent_containers/food/snacks/pizza/cargo/mushroom)
	rare_items2spawn = list(/obj/item/reagent_containers/food/drinks/bottle/soda/softsoft_pizza)

	one
		amt2spawn = 1

/obj/random_item_spawner/cola
	name = "random cola spawner"
	icon_state = "rand_pizza"
	min_amt2spawn = 2
	max_amt2spawn = 2
	rare_chance = 2
	items2spawn = list(/obj/item/reagent_containers/food/drinks/cola,
						/obj/item/reagent_containers/food/drinks/cola/random,
						/obj/item/reagent_containers/food/drinks/peach,
						/obj/item/reagent_containers/food/drinks/bottle/soda/orange,
						/obj/item/reagent_containers/food/drinks/bottle/soda/grones)
	rare_items2spawn = list(/obj/item/reagent_containers/food/drinks/bottle/soda/softsoft_pizza)

	one
		amt2spawn = 1

/obj/random_item_spawner/hat
	name = "random hat spawner"
	icon_state = "rand_hat"
	min_amt2spawn = 5
	max_amt2spawn = 10
	items2spawn = list(/obj/item/clothing/head/helmet/bobby,
						/obj/item/clothing/head/helmet/batman,
						/obj/item/clothing/head/helmet/viking,
						/obj/item/clothing/head/helmet/turd,
						/obj/item/clothing/head/helmet/thunderdome,
						/obj/item/clothing/head/helmet/hardhat,
						/obj/item/clothing/head/helmet/jetson,
						/obj/item/clothing/head/helmet/siren,
						/obj/item/clothing/head/helmet/bucket,
						/obj/item/clothing/head/helmet/bucket/red,
						/obj/item/clothing/head/tinfoil_hat,
						/obj/item/clothing/head/raccoon,
						/obj/item/clothing/head/fruithat,
						/obj/item/clothing/head/waldohat,
						/obj/item/clothing/head/odlawhat,
						/obj/item/clothing/head/fake_waldohat,
						/obj/item/clothing/head/flatcap,
						/obj/item/clothing/head/headband/devil,
						/obj/item/clothing/head/biker_cap,
						/obj/item/clothing/head/mj_hat,
						/obj/item/clothing/head/genki,
						/obj/item/clothing/head/birdman,
						/obj/item/clothing/head/chav,
						/obj/item/clothing/head/maid,
						/obj/item/clothing/head/veil,
						/obj/item/clothing/head/rando,
						/obj/item/clothing/head/psyche,
						/obj/item/clothing/head/serpico,
						/obj/item/clothing/head/cakehat,
						/obj/item/clothing/head/powdered_wig,
						/obj/item/clothing/head/that,
						/obj/item/clothing/head/that/purple,
						/obj/item/clothing/head/that/gold,
						/obj/item/clothing/head/mailcap,
						/obj/item/clothing/head/plunger,
						/obj/item/clothing/head/XComHair,
						/obj/item/clothing/head/apprentice,
						/obj/item/clothing/head/snake,
						/obj/item/clothing/head/rabbihat,
						/obj/item/clothing/head/formal_turban,
						/obj/item/clothing/head/turban,
						/obj/item/clothing/head/rastacap,
						/obj/item/clothing/head/fedora,
						/obj/item/clothing/head/cowboy,
						/obj/item/clothing/head/paper_hat,
						/obj/item/clothing/head/towel_hat,
						/obj/item/clothing/head/crown,
						/obj/item/clothing/head/oddjob,
						/obj/item/clothing/head/mario/luigi,
						/obj/item/clothing/head/mario/wario,
						/obj/item/clothing/head/mario/waluigi,
						/obj/item/clothing/head/mario,
						/obj/item/clothing/head/pumpkin,
						/obj/item/clothing/head/wig,
						/obj/item/clothing/head/zombie,
						/obj/item/clothing/head/werewolf/odd,
						/obj/item/clothing/head/elephanthat/random,
						/obj/item/clothing/head/giraffehat,
						/obj/item/clothing/head/mushroomcap/random)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/shoe
	name = "random shoe spawner"
	icon_state = "rand_shoes"
	min_amt2spawn = 5
	max_amt2spawn = 10
	items2spawn = list(/obj/item/clothing/shoes/bootsblk,
						/obj/item/clothing/shoes/bootsblu,
						/obj/item/clothing/shoes/cowboy,
						/obj/item/clothing/shoes/cyborg,
						/obj/item/clothing/shoes/dress_shoes,
						/obj/item/clothing/shoes/heels/dancin,
						/obj/item/clothing/shoes/flippers,
						/obj/item/clothing/shoes/fuzzy,
						/obj/item/clothing/shoes/gogo,
						/obj/item/clothing/shoes/heels,
						/obj/item/clothing/shoes/macho,
						/obj/item/clothing/shoes/mj_shoes,
						/obj/item/clothing/shoes/mjblack,
						/obj/item/clothing/shoes/mjwhite,
						/obj/item/clothing/shoes/moon,
						/obj/item/clothing/shoes/rocket,
						/obj/item/clothing/shoes/rollerskates,
						/obj/item/clothing/shoes/sailormoon,
						/obj/item/clothing/shoes/swat,
						/obj/item/clothing/shoes/thong,
						/obj/item/clothing/shoes/tourist,
						/obj/item/clothing/shoes/utenashoes,
						/obj/item/clothing/shoes/virtual,
						/obj/item/clothing/shoes/witchfinder,
						/obj/item/clothing/shoes/ziggy)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/formalclothes
	name = "formal clothing spawner"
	icon_state = "rand_gimmick"
	min_amt2spawn = 5
	max_amt2spawn = 10
	items2spawn = list(/obj/item/clothing/under/gimmick/red_wcoat,
						/obj/item/clothing/under/gimmick/black_wcoat,
						/obj/item/clothing/under/gimmick/blue_wcoat,
						/obj/item/clothing/under/rank/bartender/tuxedo,
						/obj/item/clothing/under/redtie,
						/obj/item/clothing/under/shirt_pants_w/blacktie,
						/obj/item/clothing/under/shirt_pants_w/bluetie,
						/obj/item/clothing/under/shirt_pants_w/redtie,
						/obj/item/clothing/under/shirt_pants_w,
						/obj/item/clothing/under/shirt_pants_br/blacktie,
						/obj/item/clothing/under/shirt_pants_br/bluetie,
						/obj/item/clothing/under/shirt_pants_br/redtie,
						/obj/item/clothing/under/shirt_pants_br,
						/obj/item/clothing/under/shirt_pants_b/blacktie,
						/obj/item/clothing/under/shirt_pants_b/redtie,
						/obj/item/clothing/under/shirt_pants_b/bluetie,
						/obj/item/clothing/under/shirt_pants_b,
						/obj/item/clothing/under/gimmick/butler,
						/obj/item/clothing/under/misc/dress,
						/obj/item/clothing/under/misc/dress/red,
						/obj/item/clothing/suit/dressb,
						/obj/item/clothing/under/misc/fancy_vest)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/furniture_parts
	name = "furniture parts spawner"
	icon_state = "rand_furniture"
	min_amt2spawn = 8
	max_amt2spawn = 10
	items2spawn = list(/obj/item/furniture_parts/IVstand,
						/obj/item/furniture_parts/surgery_tray,
						/obj/item/furniture_parts/table/desk,
						/obj/item/furniture_parts/table/wood/round,
						/obj/item/furniture_parts/table/wood/desk,
						/obj/item/furniture_parts/table/wood,
						/obj/item/furniture_parts/table/round,
						/obj/item/furniture_parts/table/glass/frame,
						/obj/item/furniture_parts/table/glass/reinforced,
						/obj/item/furniture_parts/table/glass,
						/obj/item/furniture_parts/table/reinforced/bar,
						/obj/item/furniture_parts/table/reinforced/chemistry,
						/obj/item/furniture_parts/table/reinforced,
						/obj/item/furniture_parts/table,
						/obj/item/furniture_parts/rack,
						/obj/item/furniture_parts/stool/bar,
						/obj/item/furniture_parts/stool,
						/obj/item/furniture_parts/bench/red,
						/obj/item/furniture_parts/bench/blue,
						/obj/item/furniture_parts/bench/green,
						/obj/item/furniture_parts/bench/yellow,
						/obj/item/furniture_parts/bench,
						/obj/item/furniture_parts/dining_chair/wood,
						/obj/item/furniture_parts/office_chair,
						/obj/item/furniture_parts/office_chair/red,
						/obj/item/furniture_parts/office_chair/green,
						/obj/item/furniture_parts/office_chair/blue,
						/obj/item/furniture_parts/office_chair/yellow,
						/obj/item/furniture_parts/office_chair/purple,
						/obj/item/furniture_parts/bed/roller,
						/obj/item/furniture_parts/bed)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/kineticgun //base type. split old behavior to fullrandom
	name = "firearm spawner"
	icon_state = "rand_gun"
	min_amt2spawn = 1 // doing it this way to preserve current use of spawner while allowing random amounts
	max_amt2spawn = 1
	items2spawn = null

/obj/random_item_spawner/kineticgun/fullrandom // used in the 4th of july admin button.
	New()
		items2spawn = concrete_typesof(/obj/item/gun/kinetic) - /obj/item/gun/kinetic/meowitzer //No, just no
		. = ..()

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

/obj/random_item_spawner/kineticgun/safer // safe...ish list for reasonable random gun spawns. less admin guns
	name = "firearm spawner"
	icon_state = "rand_gun"
	min_amt2spawn = 1
	max_amt2spawn = 4
	items2spawn = list(/obj/item/gun/kinetic/clock_188,
	/obj/item/gun/kinetic/clock_188/boomerang,
	/obj/item/gun/kinetic/derringer,
	/obj/item/gun/kinetic/derringer/empty,
	/obj/item/gun/kinetic/detectiverevolver,
	/obj/item/gun/kinetic/flaregun,
	/obj/item/gun/kinetic/foamdartgun,
	/obj/item/gun/kinetic/pistol,
	/obj/item/gun/kinetic/pistol/empty,
	/obj/item/gun/kinetic/riot40mm,
	/obj/item/gun/kinetic/pumpweapon/riotgun,
	/obj/item/gun/kinetic/pumpweapon/riotgun,
	/obj/item/gun/kinetic/pumpweapon/riotgun,
	/obj/item/gun/kinetic/sawnoff,
	/obj/item/gun/kinetic/sawnoff,
	/obj/item/gun/kinetic/single_action/colt_saa,
	/obj/item/gun/kinetic/single_action/flintlock,
	/obj/item/gun/kinetic/zipgun,
	/obj/item/gun/kinetic/makarov,
	/obj/item/gun/kinetic/single_action/mts_255,
	/obj/item/gun/kinetic/survival_rifle,
	/obj/item/gun/kinetic/survival_rifle,
	/obj/item/gun/kinetic/m16,
	/obj/item/gun/kinetic/m16,
	/obj/item/gun/kinetic/pumpweapon/ks23,
	/obj/item/gun/kinetic/striker,
	/obj/item/gun/kinetic/striker,
	/obj/item/gun/kinetic/webley,
	/obj/item/gun/kinetic/lopoint,
	/obj/item/gun/kinetic/uzi,
	/obj/item/gun/kinetic/uzi,
	/obj/item/gun/kinetic/greasegun,
	/obj/item/gun/kinetic/greasegun
	)

	one
		amt2spawn = 1

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	one_or_two
		min_amt2spawn = 1
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/armoryweapon
	name = "armory special weapon spawner"
	icon_state = "rand_gun"
	amt2spawn = 1

	items2spawn = list(/obj/item/gun/energy/stasis,
	/obj/item/gun/energy/egun,
	/obj/item/gun/energy/egun_jr,
	/obj/item/gun/energy/phaser_huge)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	bunch
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/ai_experimental //used to spawn 'experimental' AI law modules
//intended to add random chance to what pre-fab 'gimmicky' law modules are available at round-start, such as Equality

	name = "experimental law module spawner"
	icon_state = "rand_circuit"
	amt2spawn = 1
	//only 1 can spawn for now since the pool size is small. Might want to increase it if the pool size increases by a fair amount

	items2spawn = list(/obj/item/aiModule/experimental/equality/a,
						/obj/item/aiModule/experimental/equality/b,
						/obj/item/aiModule/experimental/corrupted,
						/obj/item/aiModule/experimental/historic)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

/obj/random_item_spawner/chompskey //fringe case
	name = "chompskey spawner"
	desc = "Modify where_to_spawn by adding lists with elements that coorespond to coordinate pairs: i.e. add list(120,31)"
	var/list/where_to_spawn = list()

	spawn_items() //since this is a fringe case spawner, this is an override to the standard spawn rules
		if(where_to_spawn.len)
			var/reference = rand(1,where_to_spawn.len)
			var/new_x = where_to_spawn[reference][1]
			var/new_y = where_to_spawn[reference][2]
			closet_check_spawn(new_x,new_y)
		else
			closet_check_spawn()

	closet_check_spawn(var/new_x,var/new_y)
		var/obj/item/K = new /obj/item/device/key/generic/chompskey

		if(new_x && new_y)
			K.set_loc(locate(new_x,new_y,src.z))
		else
			K.set_loc(src.loc)

		var/obj/storage/S = locate(/obj/storage) in K.loc
		if (S)
			K.set_loc(S)

/obj/random_item_spawner/organs
	name = "random organ spawner"
	icon_state = "rand_organ"
	min_amt2spawn = 1
	max_amt2spawn = 1
	items2spawn = list(/obj/item/organ/eye/left,
	/obj/item/organ/eye/right,
	/obj/item/organ/heart,
	/obj/item/organ/lung/left,
	/obj/item/organ/lung/right,
	/obj/item/organ/kidney/left,
	/obj/item/organ/kidney/right,
	/obj/item/organ/liver,
	/obj/item/organ/stomach,
	/obj/item/organ/intestines,
	/obj/item/organ/spleen,
	/obj/item/organ/pancreas,
	/obj/item/organ/appendix,
	)

	one_to_three
		min_amt2spawn = 1
		max_amt2spawn = 3

/obj/random_item_spawner/organs/bloody
	New()
		. = ..()
		SPAWN(1 DECI SECOND) //sync with the organs spawn
			make_cleanable(/obj/decal/cleanable/blood/gibs, src.loc)

	one_to_three
		min_amt2spawn = 1
		max_amt2spawn = 3


/obj/random_item_spawner/armory_breaching_supplies //"random"
	name = "armory breaching supplies"
	icon_state = "breachspawn"
	spawn_items()
		new /obj/rack(src.loc)
		new /obj/item/breaching_charge{
			pixel_x = 10;
			pixel_y = 1
		}(src.loc)
		new /obj/item/breaching_charge{
			pixel_x = 4;
			pixel_y = -2
		}(src.loc)
		new /obj/item/breaching_charge{
			pixel_x = -2;
			pixel_y = -5
		}(src.loc)
		new /obj/item/breaching_hammer{
			pixel_x = -3;
			pixel_y = 7
		}(src.loc)
		new /obj/item/breaching_hammer{
			pixel_x = -1;
			pixel_y = 1
		}(src.loc)
		new /obj/item/gun/kinetic/riot40mm/breach{
			pixel_x = -5;
			pixel_y = 8
		}(src.loc)
		new /obj/item/ammo/bullets/breach_flashbang{
			pixel_x = -4;
			pixel_y = 3
		}(src.loc)

/obj/random_item_spawner/armory_armor_supplies //"random"
	name = "armory armor supplies"
	icon_state = "armorspawn"
	spawn_items()
		new /obj/rack(src.loc)
		new /obj/item/clothing/head/helmet/EOD{
			pixel_x = 4;
			pixel_y = 8
		}(src.loc)
		new /obj/item/clothing/head/helmet/EOD{
			pixel_x = 12;
			pixel_y = 8
		}(src.loc)
		new /obj/item/clothing/suit/armor/EOD{
			pixel_x = 1
		}(src.loc)
		new /obj/item/clothing/suit/armor/EOD{
			pixel_x = 9
		}(src.loc)
		new /obj/item/clothing/head/helmet/riot{
			pixel_x = -13;
			pixel_y = 12
		}(src.loc)
		new /obj/item/clothing/head/helmet/riot{
			pixel_x = -4;
			pixel_y = 12
		}(src.loc)
		new /obj/item/clothing/suit/armor/heavy{
			pixel_x = -5
		}(src.loc)
		new /obj/item/clothing/suit/armor/heavy{
			pixel_x = -13
		}(src.loc)

/obj/random_item_spawner/armory_goggle_supplies //"random"
	name = "armory goggle supplies"
	icon_state = "gogglespawn"
	spawn_items()
		new /obj/rack(src.loc)
		new /obj/item/clothing/mask/gas/emergency{
			pixel_x = -9;
			pixel_y = 11
		}(src.loc)
		new /obj/item/clothing/mask/gas/emergency{
			pixel_x = -3;
			pixel_y = 11
		}(src.loc)
		new /obj/item/clothing/mask/gas/emergency{
			pixel_x = 3;
			pixel_y = 11
		}(src.loc)
		new /obj/item/clothing/mask/gas/emergency{
			pixel_x = 9;
			pixel_y = 11
		}(src.loc)
		new /obj/item/clothing/glasses/nightvision{
			pixel_x = -8;
			pixel_y = -8
		}(src.loc)
		new /obj/item/clothing/glasses/nightvision{
			pixel_x = -7;
			pixel_y = -3
		}(src.loc)
		new /obj/item/clothing/glasses/nightvision{
			pixel_x = -6;
			pixel_y = 2
		}(src.loc)
		new /obj/item/clothing/glasses/nightvision{
			pixel_x = -5;
			pixel_y = 7
		}(src.loc)
		new /obj/item/clothing/glasses/thermal{
			pixel_x = 6;
			pixel_y = -10
		}(src.loc)
		new /obj/item/clothing/glasses/thermal{
			pixel_x = 7;
			pixel_y = -5
		}(src.loc)
		new /obj/item/clothing/glasses/thermal{
			pixel_x = 8;
			pixel_y = 0
		}(src.loc)
		new /obj/item/clothing/glasses/thermal{
			pixel_x = 9;
			pixel_y = 5
		}(src.loc)

/obj/random_item_spawner/armory_phasers
	name = "armory phaser rack spawner"
	icon_state = "armory_phaser"
	min_amt2spawn = 1
	max_amt2spawn = 1
	items2spawn = list(/obj/machinery/weapon_stand/phaser_rack,
	/obj/machinery/weapon_stand/phaser_smg_rack
	)

/obj/random_item_spawner/fruits
	name = "random fruit spawner"
	icon_state = "rand_fruits"
	min_amt2spawn = 1
	max_amt2spawn = 1

	// List of veggies
	var/list/veggie_list = list(/obj/item/reagent_containers/food/snacks/plant/tomato,
		/obj/item/reagent_containers/food/snacks/plant/chili,
		/obj/item/reagent_containers/food/snacks/plant/cucumber,
		/obj/item/reagent_containers/food/snacks/plant/corn,
		/obj/item/reagent_containers/food/snacks/plant/onion,
		/obj/item/reagent_containers/food/snacks/plant/lettuce,
		/obj/item/reagent_containers/food/snacks/plant/bean,
		/obj/item/reagent_containers/food/snacks/plant/peas,
		/obj/item/reagent_containers/food/snacks/plant/peas/ammonia,
		/obj/item/reagent_containers/food/snacks/plant/potato,
		/obj/item/reagent_containers/food/snacks/plant/pumpkin,
		/obj/item/reagent_containers/food/snacks/plant/pumpkin/pumpkinlatte,
		/obj/item/reagent_containers/food/snacks/plant/garlic,
		/obj/item/reagent_containers/food/snacks/plant/eggplant,
		/obj/item/reagent_containers/food/snacks/plant/turmeric,
		/obj/item/reagent_containers/food/snacks/plant/mustard,
		/obj/item/reagent_containers/food/snacks/plant/bamboo,
		/obj/item/reagent_containers/food/snacks/plant/soy/soylent
	)

	New()
		setup_spawns()
		..()

	proc/setup_spawns()
		// Get a list of all fruits
		// This includes all the /wedge sub-types
		items2spawn = concrete_typesof(/obj/item/reagent_containers/food/snacks/plant)

		// Exclude veggies
		items2spawn -= veggie_list

		// Exclude toxic / dangerous / fruits or subtypes
		items2spawn -= list(/obj/item/reagent_containers/food/snacks/plant/pear/sickly,
			/obj/item/reagent_containers/food/snacks/plant/pumpkin/summon,
			/obj/item/reagent_containers/food/snacks/plant/pumpkin/pumpkinlatte,
			/obj/item/reagent_containers/food/snacks/plant/slurryfruit,
			/obj/item/reagent_containers/food/snacks/plant/slurryfruit/omega,
			/obj/item/reagent_containers/food/snacks/plant/purplegoop,
			/obj/item/reagent_containers/food/snacks/plant/purplegoop/orangegoop,
			/obj/item/reagent_containers/food/snacks/plant/chili/ghost_chili,
			/obj/item/reagent_containers/food/snacks/plant/melon/bowling,
			/obj/item/reagent_containers/food/snacks/plant/apple/stick
		)

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/fruits/veggies
	name = "random vegetable spawner"
	icon_state = "rand_veggies"

	setup_spawns()
		// Get a list of all veggies
		items2spawn = veggie_list

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7

/obj/random_item_spawner/flowers
	name = "random flower spawner"
	icon_state = "rand_flowers"
	min_amt2spawn = 1
	max_amt2spawn = 1

	New()
		// Get a list of all flowers
		items2spawn = concrete_typesof(/obj/item/clothing/head/flower)
		items2spawn += concrete_typesof(/obj/item/plant/flower)

		// Add some herbs that are basically flowers
		items2spawn += list(/obj/item/plant/herb/poppy, /obj/item/plant/herb/catnip, /obj/item/plant/herb/hcordata)

		// Exclude the non-natural ones
		items2spawn -= list(/obj/item/clothing/head/flower/rose/holorose)
		..()

	one
		amt2spawn = 1

	two
		amt2spawn = 2

	three
		amt2spawn = 3

	four
		amt2spawn = 4

	five
		amt2spawn = 5

	six
		amt2spawn = 6

	seven
		amt2spawn = 7

	one_or_zero
		min_amt2spawn = 0
		max_amt2spawn = 1

	maybe_few
		min_amt2spawn = 0
		max_amt2spawn = 2

	few
		min_amt2spawn = 1
		max_amt2spawn = 3

	some
		min_amt2spawn = 3
		max_amt2spawn = 5

	lots
		min_amt2spawn = 5
		max_amt2spawn = 7
