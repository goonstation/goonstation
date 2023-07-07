
/* -------------------- Backpacks  -------------------- */

/obj/item/storage/backpack
	name = "backpack"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's back."
	icon_state = "backpack"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "backpack"
	flags = FPRINT | TABLEPASS | NOSPLASH
	c_flags = ONBACK
	w_class = W_CLASS_BULKY
	max_wclass = W_CLASS_NORMAL
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	opens_if_worn = TRUE
	spawn_contents = list(/obj/item/storage/box/starter)
	duration_remove = 3 SECONDS
	duration_put = 3 SECONDS
	var/satchel_compatible = TRUE

	blue
		icon_state = "backpackb"
		item_state = "backpackb"
		desc = "A thick, wearable container made of synthetic fibers. The blue variation is similar in shade to Abzu's ocean."

	red
		icon_state = "backpackr"
		item_state = "backpackr"
		desc = "A thick, wearable container made of synthetic fibers. The red variation is striking and slightly suspicious."

	brown
		icon_state = "backpackbr"
		item_state = "backpackbr"
		desc = "A thick, wearable container made of synthetic fibers. The brown variation is both rustic and adventurous!"

	green
		icon_state = "backpackg"
		item_state = "backpackg"
		desc = "A thick, wearable container made of synthetic fibers. The green variation reminds you of a botanist's garden..."

	New()
		..()
		BLOCK_SETUP(BLOCK_LARGE)
		AddComponent(/datum/component/itemblock/backpackblock)

/obj/item/storage/backpack/empty
	spawn_contents = list()

	blue
		icon_state = "backpackb"
		item_state = "backpackb"
		desc = "A thick, wearable container made of synthetic fibers. The blue variation is similar in shade to Abzu's ocean."

	red
		icon_state = "backpackr"
		item_state = "backpackr"
		desc = "A thick, wearable container made of synthetic fibers. The red variation is striking and slightly suspicious."

	brown
		icon_state = "backpackbr"
		item_state = "backpackbr"
		desc = "A thick, wearable container made of synthetic fibers. The brown variation is both rustic and adventurous!"

	green
		icon_state = "backpackg"
		item_state = "backpackg"
		desc = "A thick, wearable container made of synthetic fibers. The green variation reminds you of a botanist's garden..."

/obj/item/storage/backpack/withO2
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

	blue
		icon_state = "backpackb"
		item_state = "backpackb"
		desc = "A thick, wearable container made of synthetic fibers. The blue variation is similar in shade to Abzu's ocean."

	red
		icon_state = "backpackr"
		item_state = "backpackr"
		desc = "A thick, wearable container made of synthetic fibers. The red variation is striking and slightly suspicious."

	brown
		icon_state = "backpackbr"
		item_state = "backpackbr"
		desc = "A thick, wearable container made of synthetic fibers. The brown variation is both rustic and adventurous!"

	green
		icon_state = "backpackg"
		item_state = "backpackg"
		desc = "A thick, wearable container made of synthetic fibers. The green variation reminds you of a botanist's garden..."

/obj/item/storage/backpack/NT
	name = "\improper NT backpack"
	desc = "A stylish blue, thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's back."
	icon_state = "NTbackpack"
	item_state = "NTbackpack"
	spawn_contents = list(/obj/item/storage/box/starter)

/obj/item/storage/backpack/syndie
	name = "\improper Syndicate backpack"
	desc = "A stylish red, evil, thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on an operative's back."
	icon_state = "Syndiebackpack"
	item_state = "Syndiebackpack"
	spawn_contents = list(/obj/item/storage/box/starter)

/obj/item/storage/backpack/captain
	name = "Captain's Backpack"
	desc = "A fancy designer bag made out of space snake leather and encrusted with plastic expertly made to look like gold."
	icon_state = "capbackpack"
	item_state = "capbackpack"
	spawn_contents = list(/obj/item/storage/box/starter)

	blue
		desc = "A fancy designer bag made out of rare blue space snake leather and encrusted with plastic expertly made to look like gold."
		icon_state = "capbackpack_blue"
		item_state = "capbackpack_blue"

	red
		desc = "A fancy designer bag made out of rare red space snake leather and encrusted with plastic expertly made to look like gold."
		icon_state = "capbackpack_red"
		item_state = "capbackpack_red"

/obj/item/storage/backpack/syndie/tactical
	name = "tactical assault rucksack"
	desc = "A military backpack made of high density fabric, designed to fit a wide array of tools for comprehensive storage support."
	icon_state = "tactical_backpack"
	spawn_contents = list(/obj/item/storage/box/starter)
	slots = 10

/obj/item/storage/backpack/medic
	name = "medic's backpack"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a Medical Doctor's back."
	icon_state = "bp_medic" //im doing inhands, im not getting baited into refactoring every icon state to use hyphens instead of underscores right now
	item_state = "bp-medic"
	spawn_contents = list(/obj/item/storage/box/starter)

/obj/item/storage/backpack/security
	name = "security backpack"
	desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects adequately on the back of security personnel."
	icon_state = "bp_security"
	item_state = "bp_security"
	spawn_contents = list(/obj/item/storage/box/starter)

/obj/item/storage/backpack/robotics
	name = "robotics backpack"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects monochromaticly on the back of roboticists."
	icon_state = "bp_robotics"
	item_state = "bp_robotics"
	spawn_contents = list(/obj/item/storage/box/starter)

/obj/item/storage/backpack/genetics
	name = "genetics backpack"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects safely on the back of geneticists."
	icon_state = "bp_genetics"
	item_state = "bp_genetics"
	spawn_contents = list(/obj/item/storage/box/starter)

/obj/item/storage/backpack/engineering
	name = "engineering backpack"
	desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects effectively on the back of engineering personnel."
	icon_state = "bp_engineering"
	item_state = "bp_engineering"
	spawn_contents = list(/obj/item/storage/box/starter)

/obj/item/storage/backpack/research
	name = "research backpack"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects efficiently on the back of research personnel."
	icon_state = "bp_research"
	item_state = "bp_research"

/obj/item/storage/backpack/randoseru
	name = "randoseru"
	desc = "Inconspicuous, nostalgic and quintessentially Space Japanese."
	icon_state = "bp_randoseru"
	item_state = "bp_randoseru"

/obj/item/storage/backpack/fjallravenred
	name = "rucksack"
	desc = "A thick, wearable container made of synthetic fibers, perfectly suited for outdoorsy, adventure-loving staff."
	icon_state = "bp_fjallraven_red"
	item_state = "bp_fjallraven_red"

/obj/item/storage/backpack/fjallravenyel
	name = "rucksack"
	desc = "A thick, wearable container made of synthetic fibers, perfectly suited for outdoorsy, adventure-loving staff."
	icon_state = "bp_fjallraven_yellow"
	item_state = "bp_fjallraven_yellow"

/obj/item/storage/backpack/anello
	name = "travel pack"
	desc = "A thick, wearable container made of synthetic fibers, often seen carried by tourists and travelers."
	icon_state = "bp_anello"
	item_state = "bp_anello"

/obj/item/storage/backpack/studdedblack
	name = "studded backpack"
	desc = "Made of sturdy synthleather and covered in metal studs. Much edgier than the standard issue bag."
	icon_state = "bp_studded"
	item_state = "bp_studded"

/obj/item/storage/backpack/itabag
	name = "pink itabag"
	desc = "Comes in cute pastel shades. Within the heart-shaped window, you can see buttons and stickers of Heisenbee!"
	icon_state = "bp_itabag_pink"
	item_state = "bp_itabag_pink"

	blue
		desc = "Comes in cute pastel shades. Within the heart-shaped window, you can see buttons and stickers of Dr. Acula!"
		icon_state = "bp_itabag_blue"
		item_state = "bp_itabag_blue"

	purple
		desc = "Comes in cute pastel shades. Within the heart-shaped window, you can see buttons and stickers of a Bombini!"
		icon_state = "bp_itabag_purple"
		item_state = "bp_itabag_purple"

	mint
		desc = "Comes in cute pastel shades. Within the heart-shaped window, you can see buttons and stickers of Sylvester!"
		icon_state = "bp_itabag_mint"
		item_state = "bp_itabag_mint"

	black
		desc = "Comes in cute pastel shades. Within the heart-shaped window, you can see buttons and stickers of Morty!"
		icon_state = "bp_itabag_black"
		item_state = "bp_itabag_black"

/obj/item/storage/backpack/studdedwhite
	name = "white studded backpack"
	desc = "Made of sturdy white synthleather and covered in metal studs. Much edgier than the standard issue bag."
	icon_state = "bp_studdedw"
	item_state = "bp_studdedw"

/obj/item/storage/backpack/breadpack
	name = "bag-uette"
	desc = "It kind of smells like bread too! Unfortunately inedible."
	icon_state = "bp_breadpack"
	item_state = "bp_breadpack"

/obj/item/storage/backpack/bearpack
	name = "bearpack"
	desc = "An adorable friend that is perfect for hugs AND carries your gear for you, how helpful!"
	icon_state = "bp_bear"
	item_state = "bp_bear"

/obj/item/storage/backpack/turtlebrown
	name = "brown turtle shell backpack"
	desc = "A backpack that looks like a brown turtleshell. How childish!"
	icon_state = "bp_turtle_brown"

/obj/item/storage/backpack/turtlegreen
	name = "green turtle shell backpack"
	desc = "A backpack that looks like a green turtleshell. Cowabunga!"
	icon_state = "bp_turtle_green"

/obj/item/storage/backpack/bpangel
	name = "angel backpack"
	desc = "This backpack gives you wings (that are entirely non-functional)!"
	icon_state = "bp_angel"
	item_state = "bp_angel"

/obj/item/storage/backpack/satchel
	name = "satchel"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's shoulder."
	icon_state = "satchel"
	wear_layer = MOB_BACK_LAYER_SATCHEL // satchels show over the tail of lizards normally, they should be BEHIND the tail

	blue
		icon_state = "satchelb"
		item_state = "satchelb"

	red
		icon_state = "satchelr"
		item_state = "satchelr"

	brown
		icon_state = "satchelbr"
		item_state = "satchelbr"

	green
		icon_state = "satchelg"
		item_state = "satchelg"

/obj/item/storage/backpack/satchel/empty
	spawn_contents = list()

	blue
		icon_state = "satchelb"
		item_state = "satchelb"

	red
		icon_state = "satchelr"
		item_state = "satchelr"

	brown
		icon_state = "satchelbr"
		item_state = "satchelbr"

	green
		icon_state = "satchelg"
		item_state = "satchelg"

/obj/item/storage/backpack/satchel/withO2
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

	blue
		icon_state = "satchelb"
		item_state = "satchelb"

	red
		icon_state = "satchelr"
		item_state = "satchelr"

	brown
		icon_state = "satchelbr"
		item_state = "satchelbr"

	green
		icon_state = "satchelg"
		item_state = "satchelg"

/obj/item/storage/backpack/satchel/syndie
	name = "\improper Syndicate Satchel"
	desc = "A stylish red, evil, thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on an operative's shoulder."
	icon_state = "Syndiesatchel"
	item_state = "Syndiesatchel"
	spawn_contents = list(/obj/item/storage/box/starter)

	New()
		..()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

/obj/item/storage/backpack/satchel/NT
	name = "\improper NT Satchel"
	desc = "A stylish blue, thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's shoulder."
	icon_state = "NTsatchel"
	item_state = "NTsatchel"
	spawn_contents = list(/obj/item/storage/box/starter)

/obj/item/storage/backpack/satchel/captain
	name = "Captain's Satchel"
	desc = "A fancy designer bag made out of space snake leather and encrusted with plastic expertly made to look like gold."
	icon_state = "capsatchel"

	blue
		desc = "A fancy designer bag made out of rare blue space snake leather and encrusted with plastic expertly made to look like gold."
		icon_state = "capsatchel_blue"

	red
		desc = "A fancy designer bag made out of rare red space snake leather and encrusted with plastic expertly made to look like gold."
		icon_state = "capsatchel_red"

/obj/item/storage/backpack/satchel/medic
	name = "medic's satchel"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a Medical Doctor's shoulder."
	icon_state = "satchel_medic"

/obj/item/storage/backpack/satchel/security
	name = "security satchel"
	desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects stylishly on the shoulder of security personnel."
	icon_state = "satchel_security"
	item_state = "satchel_security"
	spawn_contents = list(/obj/item/storage/box/starter)

/obj/item/storage/backpack/satchel/robotics
	name = "robotics satchel"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects monochromaticly on the shoulder of roboticists."
	icon_state = "satchel_robotics"
	item_state = "satchel_robotics"
	spawn_contents = list(/obj/item/storage/box/starter)

/obj/item/storage/backpack/satchel/genetics
	name = "genetics satchel"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects safely on the shoulder of geneticists."
	icon_state = "satchel_genetics"
	item_state = "satchel_genetics"
	spawn_contents = list(/obj/item/storage/box/starter)

/obj/item/storage/backpack/satchel/engineering
	name = "engineering satchel"
	desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects effectively on the shoulder of engineering personnel."
	icon_state = "satchel_engineering"
	item_state = "satchel_engineering"
	spawn_contents = list(/obj/item/storage/box/starter)

/obj/item/storage/backpack/satchel/research
	name = "research satchel"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects efficiently on the shoulder of research personnel."
	icon_state = "satchel_research"
	item_state = "satchel_research"

/obj/item/storage/backpack/satchel/randoseru
	name = "randoseru satchel"
	desc = "Inconspicuous, nostalgic and quintessentially Space Japanese"
	icon_state = "sat_randoseru"
	item_state = "sat_randoseru"

/obj/item/storage/backpack/satchel/fjallraven
	name = "rucksack satchel"
	desc = "A thick, wearable container made of synthetic fibers, perfectly suited for outdoorsy, adventure-loving staff."
	icon_state = "sat_fjallraven_red"
	item_state = "sat_fjallraven_red"

/obj/item/storage/backpack/satchel/anello
	name = "travel satchel"
	desc = "A thick, wearable container made of synthetic fibers, often seen carried by tourists and travelers."
	icon_state = "sat_anello"
	item_state = "sat_anello"

/obj/item/storage/backpack/satchel/itabag
	name = "pink itabag satchel"
	desc = "Comes in cute pastel shades. Within the heart-shaped window, you can see buttons and stickers of Heisenbee!"
	icon_state = "sat_itabag_pink"
	item_state = "sat_itabag_pink"

	blue
		desc = "Comes in cute pastel shades. Within the heart-shaped window, you can see buttons and stickers of Dr. Acula!"
		icon_state = "sat_itabag_blue"
		item_state = "sat_itabag_blue"

	purple
		desc = "Comes in cute pastel shades. Within the heart-shaped window, you can see buttons and stickers of a bumblespider!"
		icon_state = "sat_itabag_purple"
		item_state = "sat_itabag_purple"

	mint
		desc = "Comes in cute pastel shades. Within the heart-shaped window, you can see buttons and stickers of Bombini!"
		icon_state = "sat_itabag_mint"
		item_state = "sat_itabag_mint"

	black
		desc = "Comes in cute pastel shades. Within the heart-shaped window, you can see buttons and stickers of Morty!"
		icon_state = "sat_itabag_black"
		item_state = "sat_itabag_black"

/obj/item/storage/backpack/satchel/studdedblack
	name = "studded satchel"
	desc = "Made of sturdy synthleather and covered in metal studs. Much edgier than the standard issue bag."
	icon_state = "sat_studded"
	item_state = "sat_studded"

/obj/item/storage/backpack/satchel/studdedwhite
	name = "white studded satchel"
	desc = "Made of sturdy white synthleather and covered in metal studs. Much edgier than the standard issue bag."
	icon_state = "sat_studdedw"
	item_state = "sat_studdedw"

/obj/item/storage/backpack/satchel/breadpack
	name = "bag-uette satchel"
	desc = "It kind of smells like bread too! Unfortunately inedible."
	icon_state = "sat_breadpack"
	item_state = "sat_breadpack"

/obj/item/storage/backpack/satchel/bearpack
	name = "bear-satchel"
	desc = "An adorable friend that is perfect for hugs AND carries your gear for you, how helpful!"
	icon_state = "sat_bear"
	item_state = "sat_bear"

/obj/item/storage/backpack/satchel/turtlebrown
	name = "brown turtle shell satchel"
	desc = "A satchel that looks like a brown turtleshell. How childish!"
	icon_state = "sat_turtle_brown"
	item_state = "sat_turtle_brown"

/obj/item/storage/backpack/satchel/turtlegreen
	name = "green turtle shell satchel"
	desc = "A satchel that looks like a green turtleshell. Cowabunga!"
	icon_state = "sat_turtle_green"
	item_state = "sat_turtle_green"

/obj/item/storage/backpack/satchel/flintlock_pistol_satchel
	name = "leather satchel"
	desc = "A thick, wearable container made of leather, suitable for storing ammunition and other essential equipment for the operation of flintlock weaponry."
	icon_state = "satchelbr"
	item_state = "satchelbr"
	spawn_contents = list(/obj/item/gun/kinetic/single_action/flintlock,
						/obj/item/gun/kinetic/single_action/flintlock,
						/obj/item/ammo/bullets/flintlock)

/obj/item/storage/backpack/satchel/flintlock_rifle_satchel
	name = "flintlock rifle ammunition pouch"
	desc = "A small leather pouch, suitable for storing ammunition and other essential equipment for the operation of flintlock weaponry. It has room on it's strap to sling a flintlock rifle over."
	icon_state = "flintlock_satchel"
	item_state = "flintlock_satchel"
	check_wclass = TRUE
	can_hold = list(/obj/item/gun/kinetic/single_action/flintlock/rifle)
	spawn_contents = list(/obj/item/gun/kinetic/single_action/flintlock/rifle, /obj/item/ammo/bullets/flintlock/rifle)
	slots = 4

	New()
		. = ..()
		icon_state = initial(icon_state) + "-1"
		item_state = initial(item_state) + "-1"

	Entered(Obj, OldLoc)
		..()
		if (istype(Obj, /obj/item/gun/kinetic/single_action/flintlock/rifle))
			icon_state = initial(icon_state) + "-1"
			item_state = initial(item_state) + "-1"

			if (istype(src.loc, /mob))
				var/mob/parent = src.loc
				parent.update_clothing()

			return

	Exited(Obj, newloc)
		..()
		if (istype(Obj, /obj/item/gun/kinetic/single_action/flintlock/rifle))
			icon_state = initial(icon_state)
			item_state = initial(item_state)

			if (istype(src.loc, /mob))
				var/mob/parent = src.loc
				parent.update_clothing()

/* -------------------- Fanny Packs -------------------- */

/obj/item/storage/fanny
	name = "fanny pack"
	desc = "Be the butt of jokes with this simple storage device."
	icon = 'icons/obj/items/belts.dmi'
	icon_state = "fanny"
	item_state = "fanny"
	flags = FPRINT | TABLEPASS | NOSPLASH
	c_flags = ONBELT
	w_class = W_CLASS_BULKY
	slots = 5
	max_wclass = W_CLASS_NORMAL
	opens_if_worn = TRUE
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 5
	spawn_contents = list(/obj/item/storage/box/starter)

	New()
		..()
		BLOCK_SETUP(BLOCK_ROPE)

/obj/item/storage/fanny/funny
	name = "funny pack"
	desc = "Haha, get it? Get it? 'Funny'!"
	icon_state = "funny"
	item_state = "funny"
	spawn_contents = list(/obj/item/storage/box/starter,\
	/obj/item/storage/box/balloonbox)
	slots = 7

/obj/item/storage/fanny/funny/mini
	name = "mini funny pack"
	desc = "Haha, get it? Get it? 'Funny'! This one seems a little smaller, and made of even cheaper material."
	slots = 3

/obj/item/storage/fanny/syndie
	name = "syndicate tactical espionage belt pack"
	desc = "It's different than a fanny pack. It's tactical and action-packed!"
	icon_state = "syndie"
	item_state = "syndie"
	slots = 7

	New()
		..()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

/obj/item/storage/fanny/janny
	name = "janny pack"
	desc = "It's a janny fanny, a fanny for a janny."
	icon_state = "janny"
	item_state = "janny"
	spawn_contents = list(
		/obj/item/cloth/towel/janitor,
		/obj/item/handheld_vacuum,
		/obj/item/sponge,
		/obj/item/spraybottle/cleaner
	)
	slots = 5

/* -------------------- Belts -------------------- */

/obj/item/storage/belt
	name = "belt"
	icon = 'icons/obj/items/belts.dmi'
	icon_state = "belt"
	item_state = "belt"
	flags = FPRINT | TABLEPASS | NOSPLASH
	c_flags = ONBELT
	max_wclass = W_CLASS_SMALL
	opens_if_worn = TRUE
	stamina_damage = 10
	stamina_cost = 5
	stamina_crit_chance = 5
	w_class = W_CLASS_BULKY

	New()
		..()
		BLOCK_SETUP(BLOCK_ROPE)
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

	proc/can_use()
		.= 1
		if (!ismob(loc))
			return 0

	mouse_drop(obj/over_object as obj, src_location, over_location)
		var/mob/M = usr
		if (istype(over_object,/obj/item) || istype(over_object,/mob/)) // covers pretty much all the situations we're trying to prevent; namely transferring storage and opening while on ground
			if(!can_use())
				boutput(M, "<span class='alert'>You need to wear [src] for that.</span>")
				return
		return ..()


	attack_hand(mob/user)
		if (src.loc == user && !can_use())
			boutput(user, "<span class='alert'>You need to wear [src] for that.</span>")
			return
		return ..()

	attackby(obj/item/W, mob/user)
		if(!can_use())
			boutput(user, "<span class='alert'>You need to wear [src] for that.</span>")
			return
		return ..()

/obj/item/storage/belt/utility
	name = "utility belt"
	desc = "Can hold various small objects."
	icon_state = "utilitybelt"
	item_state = "utility"
	can_hold = list(/obj/item/deconstructor)
	check_wclass = 1

/obj/item/storage/belt/utility/nt_engineer
	name = "specialist engineering belt"
	desc = "A high capacity engineering belt."
	can_hold = list(
		/obj/item/rcd,
		/obj/item/rcd_ammo,
		/obj/item/deconstructor,
		/obj/item/sheet,
		/obj/item/tile
	)
	spawn_contents = list(
		/obj/item/rcd/construction,
		/obj/item/rcd_ammo/medium,
		/obj/item/tool/omnitool,
		/obj/item/device/analyzer/atmospheric/upgraded
	)

/obj/item/storage/belt/utility/prepared/ceshielded
	name = "aurora MKII utility belt"
	desc = "An utility belt for usage in high-risk salvage operations. Contains a personal shield generator. Can be activated to overcharge the shields temporarily."
	icon_state = "cebelt"
	item_state = "cebelt"
	rarity = 4
	can_hold = list(/obj/item/rcd,
	/obj/item/rcd_ammo,
	/obj/item/deconstructor)
	check_wclass = 1
	inventory_counter_enabled = 1

	New()
		..()
		AddComponent(/datum/component/wearertargeting/energy_shield/ceshield, list(SLOT_BELT), 0.75, 0.2, FALSE, 5) //blocks 3/4 of incoming damage, up to 200 points, on a full charge, but loses charge quickly while active
		var/obj/item/ammo/power_cell/self_charging/cell = new/obj/item/ammo/power_cell/self_charging{recharge_rate = 3; recharge_delay = 10 SECONDS}
		AddComponent(/datum/component/cell_holder, cell, FALSE, 100, FALSE)
		cell.set_loc(null) //otherwise it takes a slot in the belt. aaaaa
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		UpdateIcon()

	examine()
		. = ..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			. += "There are [ret["charge"]]/[ret["max_charge"]] PUs left!"

	equipped(mob/user, slot)
		..()
		inventory_counter?.show_count()

	update_icon()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			inventory_counter?.update_percent(ret["charge"], ret["max_charge"])
		else
			inventory_counter?.update_text("-")
		return 0

/obj/item/storage/belt/utility/prepared
	spawn_contents = list(/obj/item/crowbar/yellow,
	/obj/item/weldingtool/yellow,
	/obj/item/wirecutters/yellow,
	/obj/item/screwdriver/yellow,
	/obj/item/wrench/yellow,
	/obj/item/device/multitool,
	/obj/item/deconstructor)

/obj/item/storage/belt/utility/virtual
	name = "virtual utility belt"
	desc = "Are these tools DLC?"
	spawn_contents = list(/obj/item/crowbar/vr,
	/obj/item/weldingtool/vr,
	/obj/item/wirecutters/vr,
	/obj/item/screwdriver/vr,
	/obj/item/wrench/vr,
	/obj/item/device/multitool,
	/obj/item/deconstructor)

/obj/item/storage/belt/utility/superhero
	name = "superhero utility belt"
	spawn_contents = list(/obj/item/clothing/mask/breath,/obj/item/tank/emergency_oxygen)

/obj/item/storage/belt/medical
	name = "medical belt"
	desc = "A specialized belt for treating patients outside medbay in the field. A unique attachment point lets you carry defibrillators."
	icon_state = "injectorbelt"
	item_state = "medical"
	can_hold = list(/obj/item/robodefibrillator)
	check_wclass = 1

/obj/item/storage/belt/medical/prepared
	spawn_contents = list(/obj/item/reagent_containers/mender/brute,
	/obj/item/reagent_containers/mender/burn,
	/obj/item/reagent_containers/hypospray,
	/obj/item/device/analyzer/healthanalyzer/upgraded,
	/obj/item/robodefibrillator)

/obj/item/storage/belt/roboticist
	icon_state = "utilrobotics"
	name = "Roboticist's belt"
	item_state = "robotics"
	desc = "A utility belt, in the departmental colors of someone who loves robots and surgery."

/obj/item/storage/belt/roboticist/prepared
	spawn_contents = list(
	/obj/item/crowbar/grey,
	/obj/item/weldingtool/grey,
	/obj/item/wirecutters/grey,
	/obj/item/screwdriver/grey,
	/obj/item/wrench/grey,
	/obj/item/circular_saw,
	/obj/item/scalpel
	)
/obj/item/storage/belt/mining
	name = "miner's belt"
	desc = "Can hold various mining tools."
	icon_state = "minerbelt"
	item_state = "mining"
	can_hold = list(
		/obj/item/mining_tool,
		/obj/item/mining_tools)
	check_wclass = 1

/obj/item/storage/belt/mining/prepared
	spawn_contents = list(/obj/item/mining_tool/power_pick,
		/obj/item/ore_scoop/prepared,
		/obj/item/satchel/mining,
		/obj/item/device/geiger,
		/obj/item/device/gps,
		/obj/item/oreprospector,
		/obj/item/device/appraisal)

/obj/item/storage/belt/rancher
	name = "rancher's belt"
	desc = "A sturdy belt with hooks for chicken carriers."
	icon_state = "rancherbelt"
	item_state = "rancher"
	can_hold = list(
		/obj/item/chicken_carrier,
		/obj/item/fishing_rod/basic)
	check_wclass = 1

	prepared
		spawn_contents = list(/obj/item/chicken_carrier,
		/obj/item/chicken_carrier,
		/obj/item/chicken_carrier,
		/obj/item/fishing_rod/basic)

/obj/item/storage/belt/hunter
	name = "trophy belt"
	desc = "Holds normal-sized items, such as skulls."
	icon_state = "hunterbelt"
	item_state = "hunter"
	max_wclass = W_CLASS_NORMAL
	item_function_flags = IMMUNE_TO_ACID

/obj/item/storage/belt/security
	name = "security toolbelt"
	desc = "For the trend-setting officer on the go. Has a place on it to clip a baton and a holster for a small gun."
	icon_state = "secbelt"
	item_state = "secbelt"
	can_hold = list(/obj/item/baton, // not included in this list are guns that are already small enough to fit (like the detective's gun)
	/obj/item/gun/energy/taser_gun,
	/obj/item/gun/energy/phaser_gun,
	/obj/item/gun/energy/laser_gun,
	/obj/item/gun/energy/egun,
	/obj/item/gun/energy/lawbringer,
	/obj/item/gun/energy/wavegun,
	/obj/item/gun/kinetic/revolver,
	/obj/item/gun/kinetic/zipgun,
	/obj/item/clothing/mask/gas/NTSO, //added so the NTSO mask can be clipped to the belt, maybe good to do with all gas masks?
	/obj/item/gun/energy/tasersmg,
	/obj/item/gun/energy/signifer2,
	/obj/item/device/prisoner_scanner,
	/obj/item/gun/energy/ntgun,
	/obj/item/gun/energy/cornicen3)
	check_wclass = 1

// kiki's detective shoulder (holster)
// get it? like kiki's delivery service? ah, i'll show myself out.

	shoulder_holster
		name = "shoulder holster"
		desc = "A holster to hold a gun, and whatever is just a bit too big to put under a hat."
		icon_state = "shoulder_holster"
		item_state = "shoulder_holster"

		inspector
			icon_state = "inspector_holster"
			item_state = "inspector_holster"


	standard
		spawn_contents = list(/obj/item/gun/energy/taser_gun, /obj/item/baton, /obj/item/barrier)

	offense
		spawn_contents = list(/obj/item/gun/energy/wavegun, /obj/item/baton, /obj/item/barrier)

	support
		spawn_contents = list(/obj/item/baton, /obj/item/reagent_containers/food/snacks/donut/custom/robust = 2,  /obj/item/reagent_containers/emergency_injector/morphine = 4)

	control
		spawn_contents = list(/obj/item/gun/energy/tasershotgun, /obj/item/baton, /obj/item/barrier)
		New()
			..()
			can_hold += /obj/item/gun/energy/tasershotgun

	assistant
		spawn_contents = list(/obj/item/barrier, /obj/item/device/detective_scanner, /obj/item/device/ticket_writer)

	ntsc
		spawn_contents = list(/obj/item/gun/energy/signifer2, /obj/item/baton/ntso, /obj/item/instrument/whistle, /obj/item/clothing/mask/gas/NTSO, /obj/item/storage/ntsc_pouch, /obj/item/barrier) //secbelt subtype that only spawns on NTSC, not in vendor

	ntso
		spawn_contents = list(/obj/item/gun/energy/cornicen3, /obj/item/old_grenade/energy_frag = 2, /obj/item/old_grenade/energy_concussion = 2, /obj/item/tank/emergency_oxygen/extended, /obj/item/reagent_containers/food/snacks/donkpocket/warm)

	baton
		spawn_contents = list(/obj/item/baton, /obj/item/barrier, /obj/item/requisition_token/security/utility)

	tasersmg
		spawn_contents = list(/obj/item/gun/energy/tasersmg, /obj/item/baton, /obj/item/barrier)

//////////////////////////////
// ~Nuke Ops Class Storage~ //
//////////////////////////////

// belt for storing clips + magazines only

/obj/item/storage/belt/ammo
	name = "ammunition belt"
	desc = "A rugged belt fitted with ammo pouches."
	icon_state = "minerbelt"
	item_state = "utility"
	can_hold = list(/obj/item/ammo/bullets)
	check_wclass = 0

ABSTRACT_TYPE(/obj/item/storage/belt/gun)
/obj/item/storage/belt/gun
	var/gun_type

	New()
		..()
		icon_state = initial(icon_state) + "-1"

	Entered(Obj, OldLoc)
		..()
		for (var/obj/item/O in contents)
			if (istype(O, gun_type))
				icon_state = initial(icon_state) + "-1"
				return

	Exited(Obj, newloc)
		..()
		for (var/obj/item/O in contents)
			if (istype(O, gun_type))
				return
		icon_state = initial(icon_state) + "-0"

/obj/item/storage/belt/gun/revolver
	name = "revolver belt"
	desc = "A stylish leather belt for holstering a revolver and it's ammo."
	icon_state = "revolver_belt"
	item_state = "revolver_belt"
	slots = 4
	check_wclass = 0
	gun_type = /obj/item/gun/kinetic/revolver
	can_hold = list(/obj/item/ammo/bullets/a357)
	can_hold_exact = list(/obj/item/gun/kinetic/revolver)
	spawn_contents = list(/obj/item/gun/kinetic/revolver, /obj/item/ammo/bullets/a357 = 2, /obj/item/ammo/bullets/a357/AP)

/obj/item/storage/belt/gun/pistol
	name = "pistol belt"
	desc = "A rugged belt fitted with a pistol holster and some magazine pouches."
	icon_state = "pistol_belt"
	item_state = "pistol_belt"
	slots = 5
	check_wclass = 0
	gun_type = /obj/item/gun/kinetic/pistol
	can_hold = list(/obj/item/ammo/bullets/bullet_9mm)
	can_hold_exact = list(/obj/item/gun/kinetic/pistol)
	spawn_contents = list(/obj/item/gun/kinetic/pistol, /obj/item/ammo/bullets/bullet_9mm = 4)

/obj/item/storage/belt/gun/smartgun
	name = "smartpistol belt"
	desc = "A rugged belt fitted with a smart pistol holster and some magazine pouches."
	icon_state = "smartgun_belt"
	item_state = "smartgun_belt"
	slots = 5
	check_wclass = 0
	gun_type = /obj/item/gun/kinetic/pistol/smart/mkII
	can_hold = list(/obj/item/ammo/bullets/bullet_22/smartgun)
	can_hold_exact = list(/obj/item/gun/kinetic/pistol/smart/mkII)
	spawn_contents = list(/obj/item/gun/kinetic/pistol/smart/mkII, /obj/item/ammo/bullets/bullet_22/smartgun = 4)


// fancy shoulder sling for grenades

/obj/item/storage/backpack/grenade_bandolier
	name = "grenade bandolier"
	desc = "A sturdy shoulder-sling for storing various grenades."
	icon_state = "grenade_bandolier"
	item_state = "grenade_bandolier"
	can_hold = list(/obj/item/old_grenade,
	/obj/item/chem_grenade,
	/obj/item/storage/grenade_pouch,
	/obj/item/ammo/bullets/grenade_round)
	check_wclass = 0

// combat medic storage 7 slot

/obj/item/storage/belt/syndicate_medic_belt
	name = "injector bag"
	icon = 'icons/obj/items/belts.dmi'
	desc = "A canvas duffel bag full of medical autoinjectors."
	icon_state = "medic_belt"
	item_state = "medic_belt"
	spawn_contents = list(/obj/item/reagent_containers/emergency_injector/high_capacity/cardiac,
	/obj/item/reagent_containers/emergency_injector/high_capacity/bloodloss,
	/obj/item/reagent_containers/emergency_injector/high_capacity/lifesupport,
	/obj/item/reagent_containers/emergency_injector/high_capacity/juggernaut,
	/obj/item/reagent_containers/emergency_injector/high_capacity/donk_injector)

/obj/item/storage/backpack/satchel/syndie/syndicate_medic_satchel
	name = "medical shoulder pack"
	desc = "A satchel containing larger medical supplies and instruments."
	icon_state = "Syndiesatchel"
	item_state = "backpack"
	spawn_contents = list(/obj/item/robodefibrillator,
	/obj/item/extinguisher/large)


/* -------------------- Wrestling Belt -------------------- */

TYPEINFO(/obj/item/storage/belt/wrestling)
	mats = list("MET-2"=5, "DEN-2"=10, "FAB-1"=5)

/obj/item/storage/belt/wrestling
	name = "championship wrestling belt"
	desc = "A haunted antique wrestling belt, imbued with the spirits of wrestlers past."
	icon_state = "machobelt"
	item_state = "machobelt"
	contraband = 8
	is_syndicate = 1
	item_function_flags = IMMUNE_TO_ACID
	var/fake = 0		//So the moves are all fake.

	equipped(var/mob/user)
		..()
		if (!user.mind.get_antagonist(ROLE_WRESTLER))
			user.add_wrestle_powers(src.fake)

	unequipped(var/mob/user)
		..()
		if (!user.mind.get_antagonist(ROLE_WRESTLER))
			user.remove_wrestle_powers(src.fake)

/obj/item/storage/belt/wrestling/fake
	name = "fake wrestling belt"
	desc = "A haunted antique wrestling belt, imbued with the spirits of wrestlers past."
	contraband = 0
	is_syndicate = 0
	fake = 1

// I dunno where else to put these vOv
TYPEINFO(/obj/item/inner_tube)
	mats = 5 // I dunno???

/obj/item/inner_tube
	name = "inner tube"
	desc = "An inflatable torus for your waist!"
	icon = 'icons/obj/items/belts.dmi'
	icon_state = "pool_ring"
	item_state = "pool_ring"
	flags = FPRINT | TABLEPASS
	c_flags = ONBELT
	w_class = W_CLASS_NORMAL

	New()
		..()
		setProperty("negate_fluid_speed_penalty", 0.2)

/obj/item/inner_tube/duck
	icon_state = "pool_ring-duck"
	item_state = "pool_ring-duck"

/obj/item/inner_tube/giraffe
	icon_state = "pool_ring-giraffe"
	item_state = "pool_ring-giraffe"

/obj/item/inner_tube/flamingo
	icon_state = "pool_ring-flamingo"
	item_state = "pool_ring-flamingo"

/obj/item/inner_tube/random
	New()
		..()
		if (prob(40))
			src.icon_state = "pool_ring-[pick("duck","giraffe","flamingo")]"
			src.item_state = src.icon_state
