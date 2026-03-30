/obj/item/storage/backpack/chameleon
	name = "backpack"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's back."
	icon_state = "backpack"
	item_state = "backpack"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	var/list/clothing_choices = list()
	var/current_choice = new/datum/chameleon_backpack_pattern
	spawn_contents = list()
	check_wclass = STORAGE_CHECK_W_CLASS_INCLUDE
	can_hold = list(/obj/item/storage/belt/chameleon)
	satchel_variant = null //Set and then unset in convert_to_satchel, but should remain null as we don't know what we're disguised as.
	//Which chameleon items does this backpack come with?
	var/includes_remote = TRUE
	var/included_jumpsuit = /obj/item/clothing/under/chameleon
	var/included_hat = /obj/item/clothing/head/chameleon
	var/included_outer_suit = /obj/item/clothing/suit/chameleon
	var/included_glasses = /obj/item/clothing/glasses/chameleon
	var/included_shoes = /obj/item/clothing/shoes/chameleon
	var/included_belt = /obj/item/storage/belt/chameleon
	var/included_gloves = /obj/item/clothing/gloves/chameleon

	New()
		..()
		src.create_included_chameleon_set()
		for(var/U in (typesof(/datum/chameleon_backpack_pattern)))
			var/datum/chameleon_backpack_pattern/P = new U
			src.clothing_choices += P

	proc/create_included_chameleon_set()
		var/obj/item/remote/chameleon/remote
		if(src.includes_remote)
			remote = new /obj/item/remote/chameleon(src.loc)
			remote.connected_backpack = src
		if(src.included_jumpsuit)
			var/obj/item/clothing/under/chameleon/jumpsuit = new src.included_jumpsuit(src)
			src.storage.add_contents(jumpsuit)
			remote?.connected_jumpsuit = jumpsuit
		if(src.included_hat)
			var/obj/item/clothing/head/chameleon/hat = new src.included_hat(src)
			src.storage.add_contents(hat)
			remote?.connected_hat = hat
		if(src.included_outer_suit)
			var/obj/item/clothing/suit/chameleon/suit = new src.included_outer_suit(src)
			src.storage.add_contents(suit)
			remote?.connected_suit = suit
		if(src.included_glasses)
			var/obj/item/clothing/glasses/chameleon/glasses = new src.included_glasses(src)
			src.storage.add_contents(glasses)
			remote?.connected_glasses = glasses
		if(src.included_shoes)
			var/obj/item/clothing/shoes/chameleon/shoes = new src.included_shoes(src)
			src.storage.add_contents(shoes)
			remote?.connected_shoes = shoes
		if(src.included_belt)
			var/obj/item/storage/belt/chameleon/belt = new src.included_belt(src)
			src.storage.add_contents(belt)
			remote?.connected_belt = belt
		if(src.included_gloves)
			var/obj/item/clothing/gloves/chameleon/gloves = new src.included_gloves(src)
			src.storage.add_contents(gloves)
			remote?.connected_gloves = gloves


	attackby(obj/item/storage/backpack/U, mob/user)
		..()
		if(istype(U, /obj/item/storage/backpack/chameleon))
			boutput(user, SPAN_ALERT("No!!! That's a terrible idea! You'll cause a stinky backpack self-cloning freak accident!"))
			SPAWN(1 SECOND)
				boutput(user, SPAN_ALERT("Nah, just kidding. Doing that still doesn't work though!"))
			return

		if(istype(U, /obj/item/storage/backpack))
			for(var/datum/chameleon_backpack_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, SPAN_ALERT("That appearance is already saved in the chameleon pattern banks!"))
					return

			var/datum/chameleon_backpack_pattern/P = new /datum/chameleon_backpack_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			src.clothing_choices += P

			boutput(user, SPAN_NOTICE("[U.name]'s appearance has been copied!"))

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, SPAN_ALERT("<B>Your chameleon backpack malfunctions!</B>"))
			src.name = "backpack"
			src.desc = "A flashing backpack. Looks like you can still put things in it, though."
			src.icon_state = "psyche_backpack"
			src.item_state = "psyche_backpack"
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			M.set_clothing_icon_dirty()

	//Needs special casing to first figure out which bag we're disguised as, then call parent when we've figured out which satchel we need to be
	convert_to_satchel(name_base_item)
		var/list/bag_types = concrete_typesof(/obj/item/storage/backpack)
		for (var/obj/item/storage/backpack/bag as anything in bag_types)
			if((bag::icon_state == src.icon_state) && (bag::icon == src.icon))
				src.satchel_variant = bag::satchel_variant
		. = ..(name_base_item)
		//Make sure to add the new satchel disguise to our list if it isn't already there
		for(var/datum/chameleon_backpack_pattern/check_pattern in src.clothing_choices)
			if(check_pattern.name == src.name)
				return .
		var/datum/chameleon_backpack_pattern/P = new /datum/chameleon_backpack_pattern(src)
		P.name = src.name
		P.desc = src.desc
		P.icon_state = src.icon_state
		P.item_state = src.item_state
		P.sprite_item = src.icon
		P.sprite_worn = src.wear_image_icon
		P.sprite_hand = src.inhand_image_icon
		src.clothing_choices += P

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Backpack."
		set category = "Local"
		set src in usr

		var/datum/chameleon_backpack_pattern/which = tgui_input_list(usr, "Change the backpack to which pattern?", "Chameleon Backpack", clothing_choices)

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_backpack_pattern/T)
		if (T)
			src.current_choice = T
			src.name = T.name
			src.desc = T.desc
			src.icon_state = T.icon_state
			src.item_state = T.item_state
			src.icon = T.sprite_item
			src.wear_image_icon = T.sprite_worn
			src.inhand_image_icon = T.sprite_hand
			src.wear_image = image(wear_image_icon)
			src.inhand_image = image(inhand_image_icon)
			src.tooltip_rebuild = TRUE
			usr.set_clothing_icon_dirty()

/datum/chameleon_backpack_pattern
	var/name = "backpack"
	var/desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's back."
	var/icon_state = "backpack"
	var/item_state = "backpack"
	var/sprite_item = 'icons/obj/items/storage.dmi'
	var/sprite_worn =  'icons/mob/clothing/back.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_storage.dmi'

	satchel
		name = "satchel"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's shoulder."
		icon_state = "satchel"
		item_state = "satchel"

	engineer
		name = "engineering backpack"
		desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects effectively on the back of engineering personnel."
		icon_state = "bp_engineering"
		item_state = "bp_engineering"

	engineer_satchel
		name = "engineering satchel"
		desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects effectively on the shoulder of engineering personnel."
		icon_state = "satchel_engineering"
		item_state = "satchel_engineering"

	research
		name = "research backpack"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects efficiently on the back of research personnel."
		icon_state = "bp_research"
		item_state = "bp_research"

	research_satchel
		name = "research satchel"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects efficiently on the shoulder of research personnel."
		icon_state = "satchel_research"
		item_state = "satchel_research"

	security
		name = "security backpack"
		desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects adequately on the back of security personnel."
		icon_state = "bp_security"
		item_state = "bp_security"

	security_satchel
		name = "security satchel"
		desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects stylishly on the shoulder of security personnel."
		icon_state = "satchel_security"
		item_state = "satchel_security"

	robotics
		name = "robotics backpack"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects monochromaticly on the back of roboticists."
		icon_state = "bp_robotics"
		item_state = "bp_robotics"

	robotics_satchel
		name = "robotics satchel"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects monochromaticly on the shoulder of roboticists."
		icon_state = "satchel_robotics"
		item_state = "satchel_robotics"

	genetics
		name = "genetics backpack"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects safely on the back of geneticists."
		icon_state = "bp_genetics"
		item_state = "bp_genetics"

	genetics_satchel
		name = "genetics satchel"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects safely on the shoulder of geneticists."
		icon_state = "satchel_genetics"
		item_state = "satchel_genetics"

	pharmacist
		name = "pharmacy backpack"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects safely on the back of pharmacists."
		icon_state = "bp_pharma"
		item_state = "bp_pharma"

	pharmacist_satchel
		name = "pharmacy satchel"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects safely on the shoulder of pharmacists."
		icon_state = "satchel_pharma"
		item_state = "satchel_pharma"

	medic
		name = "medic's backpack"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a Medical Doctor's back."
		icon_state = "bp_medic"
		item_state = "bp-medic"

	medic_satchel
		name = "medic's satchel"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a Medical Doctor's shoulder."
		icon_state = "satchel_medic"
		item_state = "satchel_medic"

	captain
		name = "Captain's Backpack"
		desc = "A fancy designer bag made out of space snake leather and encrusted with plastic expertly made to look like gold."
		icon_state = "capbackpack"
		item_state = "capbackpack"

	captain_satchel
		name = "Captain's Satchel"
		desc = "A fancy designer bag made out of space snake leather and encrusted with plastic expertly made to look like gold."
		icon_state = "capsatchel"
		item_state = "capsatchel"
