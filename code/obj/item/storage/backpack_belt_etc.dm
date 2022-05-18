
/* -------------------- Backpacks  -------------------- */

/obj/item/storage/backpack
	name = "backpack"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's back."
	icon_state = "backpack"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "backpack"
	flags = ONBACK | FPRINT | TABLEPASS | NOSPLASH
	w_class = W_CLASS_BULKY
	max_wclass = 3
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	does_not_open_in_pocket = 0
	spawn_contents = list(/obj/item/storage/box/starter)
	duration_remove = 3 SECONDS
	duration_put = 3 SECONDS

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

/obj/item/storage/backpack/withO2
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/NT
	name = "\improper NT backpack"
	desc = "A stylish blue, thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's back."
	icon_state = "NTbackpack"
	item_state = "NTbackpack"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/syndie
	name = "\improper Syndicate backpack"
	desc = "A stylish red, evil, thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on an operative's back."
	icon_state = "Syndiebackpack"
	item_state = "Syndiebackpack"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/captain
	name = "Captain's Backpack"
	desc = "A fancy designer bag made out of space snake leather and encrusted with plastic expertly made to look like gold."
	icon_state = "capbackpack"
	item_state = "capbackpack"

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
	spawn_contents = list(/obj/item/storage/box/starter/withO2)
	slots = 10

/obj/item/storage/backpack/medic
	name = "medic's backpack"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a Medical Doctor's back."
	icon_state = "bp_medic" //im doing inhands, im not getting baited into refactoring every icon state to use hyphens instead of underscores right now
	item_state = "bp-medic"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/security
	name = "security backpack"
	desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects adequately on the back of security personnel."
	icon_state = "bp_security"
	item_state = "bp_security"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/robotics
	name = "robotics backpack"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects monochromaticly on the back of roboticists."
	icon_state = "bp_robotics"
	item_state = "bp_robotics"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/genetics
	name = "genetics backpack"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects safely on the back of geneticists."
	icon_state = "bp_genetics"
	item_state = "bp_genetics"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/engineering
	name = "engineering backpack"
	desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects effectively on the back of engineering personnel."
	icon_state = "bp_engineering"
	item_state = "bp_engineering"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

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

/obj/item/storage/backpack/satchel/syndie
	name = "\improper Syndicate Satchel"
	desc = "A stylish red, evil, thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on an operative's shoulder."
	icon_state = "Syndiesatchel"
	item_state = "Syndiesatchel"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

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
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

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
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/satchel/robotics
	name = "robotics satchel"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects monochromaticly on the shoulder of roboticists."
	icon_state = "satchel_robotics"
	item_state = "satchel_robotics"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/satchel/genetics
	name = "genetics satchel"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects safely on the shoulder of geneticists."
	icon_state = "satchel_genetics"
	item_state = "satchel_genetics"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

/obj/item/storage/backpack/satchel/engineering
	name = "engineering satchel"
	desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects effectively on the shoulder of engineering personnel."
	icon_state = "satchel_engineering"
	item_state = "satchel_engineering"
	spawn_contents = list(/obj/item/storage/box/starter/withO2)

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

/* -------------------- Fanny Packs -------------------- */

/obj/item/storage/fanny
	name = "fanny pack"
	desc = "No, 'fanny' as in 'butt.' Not the other thing."
	icon = 'icons/obj/items/belts.dmi'
	icon_state = "fanny"
	item_state = "fanny"
	flags = FPRINT | TABLEPASS | ONBELT | NOSPLASH
	w_class = W_CLASS_BULKY
	slots = 5
	max_wclass = 3
	does_not_open_in_pocket = 0
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

/* -------------------- Belts -------------------- */

/obj/item/storage/belt
	name = "belt"
	icon = 'icons/obj/items/belts.dmi'
	icon_state = "belt"
	item_state = "belt"
	flags = FPRINT | TABLEPASS | ONBELT | NOSPLASH
	max_wclass = 2
	does_not_open_in_pocket = 0
	stamina_damage = 10
	stamina_cost = 5
	stamina_crit_chance = 5
	w_class = W_CLASS_BULKY

	New()
		..()
		BLOCK_SETUP(BLOCK_ROPE)

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


	attack_hand(mob/user as mob)
		if (src.loc == user && !can_use())
			boutput(user, "<span class='alert'>You need to wear [src] for that.</span>")
			return
		return ..()

	attackby(obj/item/W as obj, mob/user as mob, obj/item/storage/T)
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
	in_list_or_max = 1

/obj/item/storage/belt/utility/prepared/ceshielded
	name = "aurora MKII utility belt"
	desc = "An utility belt for usage in high-risk salvage operations. Contains a personal shield generator. Can be activated to overcharge the shields temporarily."
	icon_state = "cebelt"
	item_state = "cebelt"
	rarity = 4
	abilities = list(/obj/ability_button/cebelt_toggle)
	var/active = 0
	var/charge = 8
	var/maxCharge = 8
	var/obj/decal/ceshield/overlay
	var/lastTick = 0
	var/chargeTime = 50 //world.time Ticks per charge increase. 50 works out to be roughly 45 seconds from 0 -> 10 under normal conditions.
	can_hold = list(/obj/item/rcd,
	/obj/item/rcd_ammo,
	/obj/item/deconstructor)
	in_list_or_max = 1

	New()
		..()
		processing_items.Add(src)

	proc/toggle()
		if(active)
			deactivate()
		else
			activate()
		return

	proc/activate()
		processing_items |= src

		if(charge > 0)
			charge -= 1

			active = 1
			setProperty("block", 80)
			setProperty("rangedprot", 1.5)
			setProperty("coldprot", 100)
			setProperty("heatprot", 100)

			if(ishuman(src.loc))
				var/mob/living/carbon/human/H = src.loc
				overlay = new(get_turf(src))

				if(H.attached_objs == null)
					H.attached_objs = list()

				H.attached_objs.Add(overlay)


			playsound(src.loc, "sound/machines/shieldup.ogg", 60, 1)
		return

	dropped(mob/user as mob)
		if(active)
			deactivate()
		..()

	proc/deactivate()
		lastTick = (world.time + 20) //Tacking on a little delay before charging starts. Discourage toggling it too often.
		active = 0
		setProperty("block", 25)
		delProperty("rangedprot")
		delProperty("coldprot")
		delProperty("heatprot")

		if(overlay)
			if(ishuman(src.loc))
				var/mob/living/carbon/human/H = src.loc
				H.attached_objs.Remove(overlay)
			qdel(overlay)
			overlay = null

		playsound(src.loc, "sound/machines/shielddown.ogg", 60, 1)
		return

	process()
		if(active)
			if(--charge <= 0)
				deactivate()
		else
			var/multiplier = 0
			var/remainder = 0

			if(world.time >= (lastTick + chargeTime))
				var/diff = round(world.time - lastTick)
				remainder = (diff % chargeTime)
				multiplier = round((diff - remainder) / chargeTime) //Round shouldnt be needed but eh.

			if(multiplier)
				charge = min(charge+(1*multiplier), maxCharge)
				lastTick = (world.time - remainder) //Plop in the remainder so we don't just swallow ticks.
		return

	setupProperties()
		..()
		setProperty("block", 25)

	equipped(var/mob/user, var/slot)
		return ..()

	unequipped(var/mob/user)
		if(active)
			deactivate()
		return ..()

	examine()
		. = ..()
		. += "There are [src.charge]/[src.maxCharge] PU left."

	buildTooltipContent()
		. = ..()
		. += "<br>There are [src.charge]/[src.maxCharge] PU left."
		lastTooltipContent = .

/obj/item/storage/belt/utility/prepared
	spawn_contents = list(/obj/item/crowbar/yellow,
	/obj/item/weldingtool,
	/obj/item/wirecutters/yellow,
	/obj/item/screwdriver/yellow,
	/obj/item/wrench/yellow,
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
	can_hold = list(
		/obj/item/robodefibrillator
	)
	in_list_or_max = 1

/obj/item/storage/belt/roboticist
	icon_state = "utilrobotics"
	name = "Roboticist's belt"
	item_state = "robotics"
	desc = "A utility belt, in the departmental colors of someone who loves robots and surgery."

/obj/item/storage/belt/roboticist/prepared
	spawn_contents = list(
	/obj/item/crowbar,
	/obj/item/weldingtool,
	/obj/item/wirecutters,
	/obj/item/screwdriver,
	/obj/item/wrench,
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
		/obj/item/mining_tools
	)
	in_list_or_max = 1

/obj/item/storage/belt/mining/prepared
	spawn_contents = list(/obj/item/mining_tool/power_pick,
		/obj/item/ore_scoop/prepared,
		/obj/item/satchel/mining,
		/obj/item/device/geiger,
		/obj/item/device/gps,
		/obj/item/oreprospector,
		/obj/item/device/appraisal)

/obj/item/storage/belt/hunter
	name = "trophy belt"
	desc = "Holds normal-sized items, such as skulls."
	icon_state = "hunterbelt"
	item_state = "hunter"
	max_wclass = 3
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
	/obj/item/gun/energy/lawbringer/old,
	/obj/item/gun/energy/wavegun,
	/obj/item/gun/kinetic/revolver,
	/obj/item/gun/kinetic/zipgun,
	/obj/item/clothing/mask/gas/NTSO,
	/obj/item/gun/energy/tasersmg,
	/obj/item/gun/energy/signifer2, //added so the NTSO mask can be clipped to the belt, maybe good to do with all gas masks?
	/obj/item/device/prisoner_scanner)
	in_list_or_max = 1

// kiki's detective shoulder (holster)
// get it? like kiki's delivery service? ah, i'll show myself out.

	shoulder_holster
		name = "shoulder holster"
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

	ntso
		spawn_contents = list(/obj/item/gun/energy/signifer2, /obj/item/gun/kinetic/clock_188, /obj/item/baton/ntso, /obj/item/instrument/whistle, /obj/item/clothing/mask/gas/NTSO, /obj/item/storage/ntso_pouch, /obj/item/barrier) //secbelt subtype that only spawns on NTSO, not in vendor

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
	in_list_or_max = 0

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
	in_list_or_max = 0
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
	in_list_or_max = 0
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
	in_list_or_max = 0
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
	in_list_or_max = 0

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
	/obj/item/extinguisher)


/* -------------------- Wrestling Belt -------------------- */

/obj/item/storage/belt/wrestling
	name = "championship wrestling belt"
	desc = "A haunted antique wrestling belt, imbued with the spirits of wrestlers past."
	icon_state = "machobelt"
	item_state = "machobelt"
	contraband = 8
	is_syndicate = 1
	item_function_flags = IMMUNE_TO_ACID
	mats = 18 //SPACE IS THE PLACE FOR WRESTLESTATION 13
	var/fake = 0		//So the moves are all fake.

	equipped(var/mob/user)
		..()
		user.make_wrestler(0, 1, 0, fake)

	unequipped(var/mob/user)
		..()
		user.make_wrestler(0, 1, 1, fake)

/obj/item/storage/belt/wrestling/fake
	name = "fake wrestling belt"
	desc = "A haunted antique wrestling belt, imbued with the spirits of wrestlers past."
	contraband = 0
	is_syndicate = 0
	fake = 1

// I dunno where else to put these vOv
/obj/item/inner_tube
	name = "inner tube"
	desc = "An inflatable torus for your waist!"
	icon = 'icons/obj/items/belts.dmi'
	icon_state = "pool_ring"
	item_state = "pool_ring"
	flags = FPRINT | TABLEPASS | ONBELT
	w_class = W_CLASS_NORMAL
	mats = 5 // I dunno???

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
