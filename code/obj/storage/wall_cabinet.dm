
TYPEINFO(/obj/item/storage/wall)
	mats = 8

/obj/item/storage/wall
	name = "cabinet"
	desc = "It's basically a big box attached to the wall."
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "wall"
	flags = FPRINT | TABLEPASS
	plane = PLANE_NOSHADOW_ABOVE
	force = 8
	w_class = W_CLASS_BULKY
	anchored = ANCHORED
	density = 0
	deconstruct_flags = DECON_SIMPLE
	burn_possible = FALSE
	max_wclass = W_CLASS_BULKY
	slots = 13 // these can't move so I guess we may as well let them store more stuff?
	mechanics_type_override = /obj/item/storage/wall

	attack_hand(mob/user)
		if (istype(user, /mob/living/critter/small_animal))
			return
		return mouse_drop(user)

	mouse_drop(atom/over_object, src_location, over_location)
		if (istype(usr, /mob/living/critter/small_animal))
			return
		..()

/obj/item/storage/wall/emergency
	name = "emergency supplies"
	desc = "A wall-mounted storage container that has a few emergency supplies in it."
	icon_state = "miniO2"

	make_my_stuff()
		..()
		if (prob(40))
			new /obj/item/storage/toolbox/emergency(src)
		if (prob(33))
			new /obj/item/clothing/suit/space/emerg(src)
			new /obj/item/clothing/head/emerg(src)
		if (prob(10))
			new /obj/item/storage/firstaid/oxygen(src)
		if (prob(10))
			new /obj/item/tank/air(src)
		if (prob(2))
			new /obj/item/tank/oxygen(src)
		if (prob(2))
			new /obj/item/clothing/mask/gas/emergency(src)
		for (var/i=rand(2,3), i>0, i--)
			if (prob(40))
				new /obj/item/tank/mini_oxygen(src)
			if (prob(40))
				new /obj/item/clothing/mask/breath(src)

/obj/item/storage/wall/fire
	name = "firefighting supplies"
	desc = "A wall-mounted storage container that has a few firefighting supplies in it."
	icon_state = "minifire"

	make_my_stuff()
		..()
		if (prob(80))
			new /obj/item/extinguisher(src)
		if (prob(50))
			new /obj/item/clothing/head/helmet/firefighter(src)
		if (prob(30))
			new /obj/item/clothing/suit/fire(src)
			new /obj/item/clothing/mask/gas/emergency(src)
		if (prob(10))
			new /obj/item/storage/firstaid/fire(src)
		if (prob(5))
			new /obj/item/storage/toolbox/emergency(src)

/obj/item/storage/wall/random
	pixel_y = 32
	make_my_stuff()
		..()
		var/thing1 = pick(10;/obj/item/screwdriver, 10;/obj/item/wrench, 5;/obj/item/crowbar, 3;/obj/item/wirecutters)
		if (ispath(thing1))
			new thing1(src)
		var/thing2 = pick(10;/obj/item/device/radio, 4;/obj/item/device/radio/signaler, 30;/obj/item/device/light/glowstick, 15;/obj/item/device/light/flashlight, 1;/obj/item/device/multitool)
		if (ispath(thing2))
			new thing2(src)
		var/thing3 = pick(10;/obj/item/cigpacket/propuffs, 15;/obj/item/reagent_containers/food/snacks/chips, 5;/obj/item/reagent_containers/food/drinks/bottle/hobo_wine, 2;/obj/item/reagent_containers/pill/cyberpunk)
		if (ispath(thing3))
			new thing3(src)
		return

/obj/item/storage/wall/office // basically the same as the office supply closet but in wall cabinet form!!
	name = "office supplies"
	pixel_y = 32
	spawn_contents = list(/obj/item/paper_bin = 2,
	/obj/item/hand_labeler,
	/obj/item/item_box/postit,
	/obj/item/pen,
	/obj/item/staple_gun/red,
	/obj/item/scissors,
	/obj/item/stamp,
	/obj/item/canvas)

	make_my_stuff()
		..()
		var/markers = pick(66;/obj/item/storage/box/marker/basic, 34;/obj/item/storage/box/marker)
		if (ispath(markers))
			new markers(src)
		var/crayons = pick(66;/obj/item/storage/box/crayon/basic, 34;/obj/item/storage/box/crayon)
		if (ispath(crayons))
			new crayons(src)
		return

/obj/item/storage/wall/medical_wear
	name = "medical supplies"
	pixel_y = 32
	spawn_contents = list(/obj/item/storage/box/stma_kit = 2,
	/obj/item/storage/box/lglo_kit/random = 2,
	/obj/item/storage/box/clothing/patient_gowns = 2)



/obj/item/storage/wall/research_supplies
	name = "research supplies"
	pixel_y = 32
	spawn_contents = list(/obj/item/storage/box/stma_kit,
	/obj/item/storage/box/lglo_kit/random,
	/obj/item/storage/box/clothing/patient_gowns,
	/obj/item/storage/box/syringes,
	/obj/item/storage/box/patchbox,
	/obj/item/storage/box/vialbox,
	/obj/item/clothing/glasses/spectro = 2,
	/obj/item/reagent_containers/dropper/mechanical = 2,
	/obj/item/storage/box/biohazard_bags)

/obj/item/storage/wall/orange
	name = "orange wardrobe"
	icon_state = "miniorange"
	pixel_y = 32
	spawn_contents = list(/obj/item/clothing/under/color/orange = 2,
	/obj/item/clothing/under/misc = 2,
	/obj/item/clothing/shoes/orange = 3)

/obj/item/storage/wall/blue
	name = "blue wardrobe"
	icon_state = "miniblue"
	pixel_y = 32
	spawn_contents = list(/obj/item/clothing/under/color/blue = 4,
	/obj/item/clothing/shoes/brown = 4,
	/obj/item/clothing/head/blue = 2)

/obj/item/storage/wall/red
	name = "red wardrobe"
	icon_state = "minired"
	pixel_y = 32
	spawn_contents = list(/obj/item/clothing/under/color/red = 4,
	/obj/item/clothing/shoes/brown = 4,
	/obj/item/clothing/head/red = 2)

/obj/item/storage/wall/purple
	name = "purple wardrobe"
	icon_state = "minipurple"
	pixel_y = 32
	spawn_contents = list(/obj/item/clothing/under/color/pink = 4,
	/obj/item/clothing/shoes/brown = 4)

/obj/item/storage/wall/green
	name = "green wardrobe"
	icon_state = "minigreen"
	pixel_y = 32
	spawn_contents = list(/obj/item/clothing/under/color/green = 4,
	/obj/item/clothing/shoes/black = 4,
	/obj/item/clothing/head/green = 2)

/obj/item/storage/wall/mining
	name = "mining equipment"
	icon_state = "minimining"
	pixel_y = 32
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

/obj/item/storage/wall/cargo
	name = "cargo equipment"
	icon_state = "minimining"
	pixel_x = -32
	spawn_contents = list(/obj/item/storage/box/clothing/qm,
	/obj/item/pen/fancy,
	/obj/item/paper_bin,
	/obj/item/clipboard,
	/obj/item/hand_labeler,
	/obj/item/cargotele)

/obj/item/storage/wall/clothingrack
	name = "clothing rack"
	icon = 'icons/obj/large_storage.dmi'
	density = 1
	slots = 7
	anchored = ANCHORED
	icon_state = "clothingrack" //They start full so might as well
	can_hold = list(/obj/item/clothing/under,/obj/item/clothing/suit)

	New()
		hud = new(src)
		..()
		SPAWN(1 DECI SECOND)
			UpdateIcon()

	update_icon()

		var/list/my_contents = src.get_contents()
		if (my_contents.len <= 0)
			src.icon_state = "clothingrack-empty"
		else
			src.icon_state = "clothingrack"

/obj/item/storage/wall/clothingrack/dresses
	spawn_contents = list(/obj/item/clothing/under/suit/red/dress = 1,
	/obj/item/clothing/under/suit/purple/dress = 1,
	/obj/item/clothing/under/gimmick/wedding_dress = 1,
	/obj/item/clothing/under/gimmick/sailormoon = 1,
	/obj/item/clothing/under/gimmick/princess = 1,
	/obj/item/clothing/under/gimmick/maid = 1,
	/obj/item/clothing/under/gimmick/kilt = 1)

/obj/item/storage/wall/clothingrack/clothes1
	spawn_contents = list(/obj/item/clothing/under/gimmick/hakama/random = 1,
	/obj/item/clothing/under/gimmick/sweater = 1,
	/obj/item/clothing/under/gimmick/mario = 1,
	/obj/item/clothing/under/gimmick/odlaw = 1,
	/obj/item/clothing/under/gimmick/sealab = 1,
	/obj/item/clothing/under/misc/hitman = 1,
	/obj/item/clothing/under/misc/america = 1)

/obj/item/storage/wall/clothingrack/dresses2
	spawn_contents = list(/obj/item/clothing/under/misc/dress/hawaiian = 1,
	/obj/item/clothing/under/misc/dress/red = 1,
	/obj/item/clothing/suit/dressb = 1,
	/obj/item/clothing/suit/dressb/dressr = 1,
	/obj/item/clothing/suit/dressb/dressg = 1,
	/obj/item/clothing/suit/dressb/dressbl = 1,
	/obj/item/clothing/under/gimmick/anthy = 1)

/obj/item/storage/wall/clothingrack/clothes2
	spawn_contents = list(/obj/item/clothing/under/gimmick/hakama/random = 1,
	/obj/item/clothing/under/gimmick/toga = 1,
	/obj/item/clothing/suit/mj_suit = 1,
	/obj/item/clothing/under/gimmick/mj_clothes = 1,
	/obj/item/clothing/under/gimmick/sealab = 1,
	/obj/item/clothing/suit/scarf = 1,
	/obj/item/clothing/suit/greek = 1)

/obj/item/storage/wall/clothingrack/clothes3
	spawn_contents = list(/obj/item/clothing/suit/suspenders = 1,
	/obj/item/clothing/suit/hoodie = 1,
	/obj/item/clothing/under/misc/barber = 1,
	/obj/item/clothing/under/misc/serpico = 1,
	/obj/item/clothing/under/misc/tourist/max_payne = 1,
	/obj/item/clothing/under/referee = 1,
	/obj/item/clothing/under/misc/mail = 1)

/obj/item/storage/wall/clothingrack/clothes4
	spawn_contents = list(/obj/item/clothing/under/gimmick/utena = 1,
	/obj/item/clothing/suit/hoodie = 1,
	/obj/item/clothing/under/gimmick/dolan = 1,
	/obj/item/clothing/under/gimmick/butler = 1,
	/obj/item/clothing/under/misc/mobster = 1,
	/obj/item/clothing/under/gimmick/chaps= 1,
	/obj/item/clothing/under/gimmick/shirtnjeans = 1)

/obj/item/storage/wall/clothingrack/clothes_shooting_range //for the shooting range prefab; Consumerism.
	spawn_contents = list(/obj/item/clothing/under/gimmick/utena = 1,
	/obj/item/clothing/suit/hoodie = 1,
	/obj/item/clothing/suit/wintercoat = 1,
	/obj/item/clothing/suit/labcoat/hitman = 1,
	/obj/item/clothing/suit/johnny_coat = 1,
	/obj/item/clothing/under/gimmick/chaps= 1,
	/obj/item/clothing/under/gimmick/shirtnjeans = 1)

obj/item/storage/wall/clothingrack/hatrack
	name = "hat shelf"
	desc = "It's a shelf designed for many hats."
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "hatrack"
	density = 0
	can_hold = list(/obj/item/clothing/head)


	New()
		hud = new(src)
		..()
		SPAWN(1 DECI SECOND)
			UpdateIcon()


	update_icon()

		var/list/my_contents = src.get_contents()
		if (my_contents.len <= 0)
			src.icon_state = "hatrack-empty"
		else
			src.icon_state = "hatrack"

	hatrack_1
		spawn_contents = list(/obj/item/clothing/head/pinkwizard = 1,
		/obj/item/clothing/head/snake = 1,
		/obj/item/clothing/head/helmet/greek = 1,
		/obj/item/clothing/head/laurels = 1,
		/obj/item/clothing/head/laurels/gold = 1,
		/obj/item/clothing/head/formal_turban = 1)

	hatrack_2
		spawn_contents = list(/obj/item/clothing/head/beret/random_color = 1,
		/obj/item/clothing/head/beret/random_color = 1,
		/obj/item/clothing/head/beret/random_color = 1,
		/obj/item/clothing/head/beret/random_color = 1,
		/obj/item/clothing/head/sunhat/sunhatg = 1,
		/obj/item/clothing/head/serpico = 1,
		/obj/item/clothing/head/cowboy = 1)

	hatrack_3
		spawn_contents = list(/obj/item/clothing/head/raccoon = 1,
		/obj/item/clothing/head/mj_hat = 1,
		/obj/item/clothing/head/veil = 1,
		/obj/item/clothing/head/sunhat = 1,
		/obj/item/clothing/head/sunhat/sunhatr = 1,
		/obj/item/clothing/head/aviator = 1,
		/obj/item/clothing/head/sailormoon = 1)

/obj/item/storage/wall/toolshelf
	name = "tool shelf"
	icon = 'icons/obj/large/64x64.dmi'
	density = 0
	slots = 7
	anchored = ANCHORED
	plane = PLANE_DEFAULT
	icon_state = "toolshelf"
	can_hold = list(/obj/item/clothing/under,/obj/item/clothing/suit)

	New()
		hud = new(src)
		..()
		SPAWN(1 DECI SECOND)
			UpdateIcon()

	update_icon()
		var/list/my_contents = src.get_contents()
		if (my_contents.len <= 0)
			src.icon_state = "shelf"
		else
			src.icon_state = "toolshelf"

/obj/item/storage/wall/mineralshelf
	name = "mineral shelf"
	icon = 'icons/obj/large/64x64.dmi'
	density = 0
	slots = 7
	anchored = ANCHORED
	icon_state = "mineralshelf"
	plane = PLANE_DEFAULT
	can_hold = list(/obj/item/raw_material,/obj/item/material_piece)
	spawn_contents = list(/obj/item/raw_material/mauxite = 4)

	New()
		hud = new(src)
		..()
		SPAWN(1 DECI SECOND)
			UpdateIcon()

	update_icon()
		var/list/my_contents = src.get_contents()
		if (my_contents.len <= 0)
			src.icon_state = "shelf"
		else
			src.icon_state = "mineralshelf"

/obj/item/storage/wall/surgery
	name = "surgical cabinet"
	desc = "A wall-mounted cabinet containing surgical tools."
	icon_state = "minimed"
	slots = 13
	spawn_contents = list(
		/obj/item/scalpel = 1,
		/obj/item/circular_saw = 1,
		/obj/item/scissors/surgical_scissors = 1,
		/obj/item/surgical_spoon = 1,
		/obj/item/staple_gun = 1,
		/obj/item/hemostat = 1,
		/obj/item/suture = 1,
		/obj/item/device/analyzer/healthanalyzer = 1,
	)
