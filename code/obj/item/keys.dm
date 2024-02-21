// why were most of these in gimmick.dm??????  that's a file for clothing.  what??????????????????????????
ABSTRACT_TYPE(/obj/item/device/key)
/obj/item/device/key
	name = "abstract key"
	desc = "This shouldn't be spawned!"
	icon = 'icons/obj/artifacts/keys.dmi'
	icon_state = "key"
	item_state = "pen"
	force = null
	w_class = W_CLASS_TINY
	burn_possible = FALSE // too important to burn!
	var/id = null
	var/dodgy = 0 //Woe be upon the poor fool who tries to give a dodgy key to the automaton

/obj/item/device/key/generic
	name = "key"
	desc = "It unlocks or locks doors."

/obj/item/device/key/generic/radio
	name = "studio door key"
	desc = "It unlocks or locks doors. This one specifically is made for a studio door."
	icon_state = "key_radio"

/obj/item/device/key/generic/larrys
	name = "backroom key"
	desc = "Do you really want to go back there?"
	icon_state = "key_larry"

/obj/item/device/key/cheget
	name = "old fancy key"
	desc = "It unlocks or locks slightly newer doors."
	icon_state = "ckey1"

/obj/item/device/key/skull
	name = "collar key"
	desc = "Unlocks places you'd otherwise need a bone to pick. Proof that you are an awful human being."
	icon_state = "bloodyskull"

/obj/item/device/key/literal_skeleton
	name = "literal skeleton key"
	desc = "It's a key made of bone.  Grody."
	icon_state = "key_bone"

// The key that unlocks walls.  (please refer to turf.dm)
/obj/item/device/key/haunted
	name = "iron key"
	desc = "An old key of iron."
	icon_state = "key_iron"
	var/last_use = 0

/obj/item/device/key/generic/chompskey
	name = "chomps key"
	desc = "It's gnot what you were expecting..."
	icon_state = "chompskey"

/obj/item/device/key/random
	name = ""
	desc = "You are not sure what this key is for."

	icon = 'icons/obj/items/randomkeys.dmi'
	icon_state = "null"

	New(var/loca)
		randomize()
		return ..(loca)

	proc/randomize()
		var/part1 = ""
		var/part2 = ""
		var/part3 = ""
		var/part4 = ""

		switch (pick(prob(100);1, prob(40);2, prob(15);3))
			if (1) //adjective only
				part1 = pick_string("random_key.txt", "adjectives")
			if (2) //noun only
				part1 = pick_string("random_key.txt", "nouns")
			if (3) //adjective and noun
				part1 = "[pick_string("random_key.txt", "adjectives")] [pick_string("random_key.txt", "nouns")]"

		if (prob(50)) //add material?
			part2 = "[pick_string("random_key.txt", "materials")] "

		part3 = pick_string("random_key.txt", "keynames") //pick name for key

		if (prob(5)) //add more fluff?
			part4 = " [pick_string("random_key.txt", "ofwhat")]"

		name = "[part1] [part2][part3][part4]"

		desc = "\A [part1] key. [length(part2) ? "It is made of [part2]. ":""][prob(5) ? pick_string("random_key.txt", "descfluff"):""]"

		color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))

		if (findtext(name, "crystal") || findtext(name, "prismatic") || findtext(name, "glowing") || findtext(name, "shining")) blend_mode = 2
		else if (findtext(name, "void") || findtext(name, "evil") || findtext(name, "doom") || findtext(name, "ancient")) blend_mode = 3

		if (findtext(name, "ghost") || findtext(name, "crystal") || findtext(name, "void") || findtext(name, "ethereal")) alpha = 150

		if (findtext(name, "float"))
			animate_float(src, -1, rand(10, 40))
		else if (findtext(name, "eldritch") || findtext(name, "wizard") || findtext(name, "magic"))
			animate_flash_color_fill(src,rgb(rand(0, 255), rand(0, 255), rand(0, 255)),-1, rand(10, 100))
		else if (prob(50))
			src.Turn(rand(0, 359))

		if (findtext(name, "burning") || findtext(name, "searing") || findtext(name, "fire") || findtext(name, "sun"))
			particleMaster.SpawnSystem(new /datum/particleSystem/fireTest(src))

		overlays += image('icons/obj/items/randomkeys.dmi',src,"ring[rand(0,10)]")
		overlays += image('icons/obj/items/randomkeys.dmi',src,"shaft[rand(0,9)]")
		overlays += image('icons/obj/items/randomkeys.dmi',src,"teeth[rand(0,10)]")
		return

/obj/item/device/key/iridium
	name = "iridium key"
	desc = "An artifact made of a fancy, silvery material. Arcs of energy repeatedly crawl up the twin shanks of the device."
	icon_state = "key_iridium"


	virtual
		desc = "A key made of a fancy, silvery set of pixels."
		Move()
			. = ..()
			var/area/A = get_area(src)
			if (A && !A.virtual)
				qdel(src)

		set_loc()
			..()
			var/area/A = get_area(src)
			if (A && !A.virtual)
				qdel(src)


/obj/item/device/key/virtual
	name = "virtual key"
	desc = "A key crafted of polygons and VRML."
	icon_state = "key_vr"

	New()
		..()
		. = rand(5, 20)
		SPAWN(rand(1,10))
			animate(src, pixel_y = 32, transform = matrix(., MATRIX_ROTATE), time = 20, loop = -1, easing = SINE_EASING)
			animate(pixel_y = 0, transform = matrix(. * (-1), MATRIX_ROTATE), time = 20, loop = -1, easing = SINE_EASING)

/obj/item/device/key/lead
	name = "lead key"
	desc = "A shockingly heavy key for such a small size."
	icon_state = "key_lead"

/obj/item/device/key/onyx
	name = "onyx key"
	desc = "A menacing onyx-like scepter with angular hand guards. Shaped a bit like the teeth of a big key, weird."
	icon_state = "key_onyx"

/obj/item/device/key/silver
	desc = "A little key with a green jewel socketed into the bow. How fancy."
	name = "silver key"
	icon_state = "key_silver"

/obj/item/device/key/hotiron
	name = "hot iron key"
	desc = "An intricate key made of iron. It occasionally flashes with a brilliant heat."
	icon_state = "key_hot"

/obj/item/device/key/generic/coldsteel
	name = "cold steel key"
	desc = "A partially frozen key made of steel. It might still work despite all the ice."
	icon_state = "key_cold"

/obj/item/device/key/hospital
	name = "niobium key"
	desc = "A dazzling key made of some multicolored metal."
	icon_state = "key_niobium"

//Something for the solarium nerds to obsess over for a month
/obj/item/device/key/filing_cabinet
	name = "tubular key"
	desc = "One of those cylinder keys that you see on vending machines and stuff."
	icon_state = "key_round"

/obj/item/device/key/filing_cabinet/locked_table_random_room
	desc = "A key for locking desk drawers. Cool."
	id = "locked_table_random_room"
