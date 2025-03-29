/obj/storage/cart
	name = "supply cart"
	desc = "A big rolling supply cart."
	is_short = 1
	icon_state = "cart"
	icon_closed = "cart"
	icon_opened = "cartopen"
	icon_welded = "welded-crate"
	soundproofing = 5
	throwforce = 50
	flip_health = 4
	can_flip_bust = 1
	p_class = 1.5
	var/obj/storage/cart/next_cart = null

	recalcPClass()
		var/maxPClass = 0
		for (var/atom/movable/O in contents)
			if (ishuman(O)) // can't use p_class for human mobs as we need to use the heavier one regardless of whether they're standing/lying down
				maxPClass = max(maxPClass, 3) //horay magic number
			else
				maxPClass = max(maxPClass, O.p_class)
		p_class = initial(p_class) + maxPClass / 2

/obj/storage/cart/mechcart
	name = "mechanics cart"
	desc = "A big rolling supply cart for station mechanics."
	icon_state = "mechcart"
	icon_closed = "mechcart"
	icon_opened = "mechcartopen"

/obj/storage/cart/mechcart/breach
	name = "breach cart"
	desc = "A big rolling supply cart equipped for handling hull breaches."
	spawn_contents = list(
		/obj/item/sheet/steel/fullstack{pixel_x=4;pixel_y=-4} = 1,
		/obj/item/chem_grenade/metalfoam{pixel_x=-9; pixel_y=4} = 1,
		/obj/item/chem_grenade/metalfoam{pixel_x=-6; pixel_y=4} = 1,
		/obj/item/chem_grenade/metalfoam{pixel_x=-3; pixel_y=4} = 1,
		/obj/item/old_grenade/oxygen{pixel_x=-9; pixel_y=-2} = 1,
		/obj/item/old_grenade/oxygen{pixel_x=-6; pixel_y=-2} = 1,
		/obj/item/old_grenade/oxygen{pixel_x=-3; pixel_y=-2} = 1,
		/obj/item/reagent_containers/food/drinks/fueltank{pixel_x=6; pixel_y=4} = 1,
		/obj/item/storage/firstaid/oxygen{pixel_x=2; pixel_y=4} = 1,
		/obj/item/caution{pixel_x=4;pixel_y=-2} = 1,
		/obj/item/caution{pixel_x=6;pixel_y=-4} = 1,
	)

/obj/storage/cart/mechcart/breach/acid
	spawn_contents = list(
		/obj/item/sheet/steel/fullstack{pixel_x=4;pixel_y=-4} = 1,
		/obj/item/chem_grenade/metalfoam{pixel_x=-9; pixel_y=4} = 1,
		/obj/item/chem_grenade/metalfoam{pixel_x=-6; pixel_y=4} = 1,
		/obj/item/chem_grenade/metalfoam{pixel_x=-3; pixel_y=4} = 1,
		/obj/item/reagent_containers/food/drinks/fueltank{pixel_x=6; pixel_y=4} = 1,
		/obj/item/storage/firstaid/fire{pixel_x=2; pixel_y=4} = 1,
		/obj/item/caution{pixel_x=4;pixel_y=-2} = 1,
		/obj/item/caution{pixel_x=6;pixel_y=-4} = 1,
	)

/obj/storage/cart/mechcart/tools
	spawn_contents = list(
		/obj/item/electronics/scanner = 1,
		/obj/item/deconstructor = 1,
		/obj/item/storage/toolbox/electrical = 1,
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/electronics/soldering = 1,
		/obj/item/device/multitool = 1,
	)

/obj/storage/cart/medcart
	name = "medical cart"
	desc = "A big rolling supply cart for station medics."
	icon_state = "medcart"
	icon_closed = "medcart"
	icon_opened = "medcartopen"

/obj/storage/cart/medcart/crash
	name = "crash cart"
	desc = "A big rolling supply cart equipped for medical emergencies."
	spawn_contents = list(
		/obj/item/body_bag{pixel_x = -9; pixel_y = -10} = 1,
		/obj/item/body_bag{pixel_x = -1; pixel_y = -10} = 1,
		/obj/item/body_bag{pixel_x = 8; pixel_y = -10} = 1,
		/obj/item/storage/firstaid/brute{pixel_x = -11; pixel_y = 11} = 1,
		/obj/item/storage/firstaid/fire{pixel_x = -3; pixel_y = 11} = 1,
		/obj/item/storage/firstaid/toxin{pixel_x = 3; pixel_y = 11} = 1,
		/obj/item/storage/firstaid/oxygen{pixel_x = 10; pixel_y = 11} = 1,
		/obj/item/bandage{pixel_x = 11; pixel_y = -4} = 1,
		/obj/item/bandage{pixel_x = 5; pixel_y = -4} = 1,
		/obj/item/bandage{pixel_x = -1; pixel_y = -4} = 1,
		/obj/item/robodefibrillator{pixel_x=-4; pixel_y=8} = 1,
	)

/obj/storage/cart/forensic
	name = "forensics cart"
	desc = "A big rolling supply cart for crime-scene forensics work."
	icon_state = "forensiccart"
	icon_closed = "forensiccart"
	icon_opened = "forensiccartopen"

/obj/storage/cart/forensic/detective
	spawn_contents = list(
		/obj/item/storage/box/evidence{pixel_x=6;pixel_y=6} = 5,
		/obj/item/hand_labeler{pixel_x=-4; pixel_y=-6} = 1,
		/obj/item/device/audio_log{pixel_x=-4; pixel_y=4} = 1,
		/obj/item/body_bag{pixel_x=8; pixel_y=-6} = 1,
		/obj/item/body_bag{pixel_x=6; pixel_y=-4} = 1,
		/obj/item/body_bag{pixel_x=4; pixel_y=-2} = 1,
		/obj/item/clothing/gloves/latex/random{pixel_x=-6; pixel_y=2} = 1,
		/obj/item/clothing/mask/surgical{pixel_x=-6; pixel_y=8} = 1,
		/obj/item/device/detective_scanner{pixel_x=2;pixel_y=4} = 1,
		/obj/item/spraybottle/detective{pixel_x=2; pixel_y=-4} = 1,
	)

/obj/storage/cart/forensic/security
	spawn_contents = list(
		/obj/item/storage/box/evidence{pixel_x=6;pixel_y=6} = 5,
		/obj/item/hand_labeler{pixel_x=-4; pixel_y=-6} = 1,
		/obj/item/device/audio_log{pixel_x=-4; pixel_y=4} = 1,
		/obj/item/body_bag{pixel_x=8; pixel_y=-6} = 1,
		/obj/item/body_bag{pixel_x=6; pixel_y=-4} = 1,
		/obj/item/body_bag{pixel_x=4; pixel_y=-2} = 1,
		/obj/item/clothing/gloves/latex/random{pixel_x=-6; pixel_y=2} = 1,
		/obj/item/clothing/mask/surgical{pixel_x=-6; pixel_y=8} = 1,

	)

/obj/storage/cart/forensic/bomb_disposal
	name = "crisis cart"
	desc = "A big rolling supply cart equipped for \"safely\" disposing of bombs."
	spawn_contents = list(
		/obj/item/clothing/suit/armor/EOD{pixel_x=4; pixel_y=-4} = 1,
		/obj/item/clothing/suit/armor/EOD{pixel_x=-4; pixel_y=-4} = 1,
		/obj/item/clothing/head/helmet/EOD{pixel_x=4; pixel_y=8} = 1,
		/obj/item/clothing/head/helmet/EOD{pixel_x=-4; pixel_y=8} = 1,
		/obj/item/clothing/mask/gas{pixel_x=4; pixel_y=4} = 1,
		/obj/item/clothing/mask/gas{pixel_x=-4; pixel_y=4} = 1,
		/obj/item/device/multitool = 2,
		/obj/item/screwdriver = 2,
	)

/obj/storage/cart/trash
	name = "trash cart"
	desc = "Well at least you're in space, right?"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashcart"
	icon_closed = "trashcart"
	icon_opened = "trashcartopen"

/obj/storage/cart/trash/syndicate
	crunches_contents = 1

/obj/storage/cart/hotdog
	name = "hotdog stand"
	desc = "This will probably never be used to sell hotdogs."
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "hotdogstand"
	icon_closed = "hotdogstand"
	icon_opened = "hotdogstandopen"

/obj/storage/cart/hotdog/syndicate
	crunches_contents = 1
	crunches_deliciously = 1
