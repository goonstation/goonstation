/obj/item/storage/belt/chameleon
	name = "utility belt"
	desc = "Can hold various small objects."
	icon_state = "utilitybelt"
	item_state = "utility"
	icon = 'icons/obj/items/belts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	wear_image_icon = 'icons/mob/clothing/belt.dmi'
	var/list/clothing_choices = list()
	var/current_choice = new/datum/chameleon_belt_pattern

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_belt_pattern)))
			var/datum/chameleon_belt_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/storage/belt/U, mob/user)
		..()
		if(istype(U, /obj/item/storage/belt/chameleon))
			boutput(user, SPAN_ALERT("No!!! That's a terrible idea! You'll cause a putrid belt spiral!"))
			SPAWN(1 SECOND)
				boutput(user, SPAN_ALERT("Nah, just jesting. Doing that still doesn't work though!"))
			return

		if(istype(U, /obj/item/storage/belt))
			for(var/datum/chameleon_belt_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, SPAN_ALERT("That appearance is already saved in the chameleon pattern banks!"))
					return

			var/datum/chameleon_belt_pattern/P = new /datum/chameleon_belt_pattern(src)
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
			boutput(M, SPAN_ALERT("<B>Your chameleon belt malfunctions!</B>"))
			src.name = "belt"
			src.desc = "A flashing belt. Looks like you can still put things in it, though."
			src.icon_state = "psyche"
			src.item_state = "psyche"
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Belt."
		set category = "Local"
		set src in usr

		var/datum/chameleon_belt_pattern/which = tgui_input_list(usr, "Change the belt to which pattern?", "Chameleon Belt", clothing_choices)

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_belt_pattern/T)
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

/datum/chameleon_belt_pattern
	var/name = "utility belt"
	var/desc = "Can hold various small objects."
	var/icon_state = "utilitybelt"
	var/item_state = "utility"
	var/sprite_item = 'icons/obj/items/belts.dmi'
	var/sprite_worn = 'icons/mob/clothing/belt.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_storage.dmi'

	ceshielded
		name = "aurora MKII utility belt"
		desc = "An utility belt for usage in high-risk salvage operations. Contains a personal shield generator. Can be activated to overcharge the shields temporarily."
		icon_state = "cebelt"
		item_state = "cebelt"

	security
		name = "security toolbelt"
		desc = "For the trend-setting officer on the go. Has a place on it to clip a baton and a holster for a small gun."
		icon_state = "secbelt"
		item_state = "secbelt"

	medical
		name = "medical belt"
		desc = "A specialized belt for treating patients outside medbay in the field. A unique attachment point lets you carry defibrillators."
		icon_state = "injectorbelt"
		item_state = "medical"

	shoulder_holster
		name = "shoulder holster"
		icon_state = "shoulder_holster"
		item_state = "shoulder_holster"

	miner
		name = "miner's belt"
		desc = "Can hold various mining tools."
		icon_state = "minerbelt"
		item_state = "mining"

	robotics
		name = "Roboticist's belt"
		desc = "A utility belt, in the departmental colors of someone who loves robots and surgery."
		icon_state = "utilrobotics"
		item_state = "robotics"

	rancher
		name = "rancher's belt"
		desc = "A sturdy belt with hooks for chicken carriers."
		icon_state = "rancherbelt"
		item_state = "rancher"
