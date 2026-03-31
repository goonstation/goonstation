/obj/item/clothing/glasses/chameleon
	name = "prescription glasses"
	desc = "Corrective lenses, perfect for the near-sighted."
	icon_state = "glasses"
	item_state = "glasses"
	icon = 'icons/obj/clothing/item_glasses.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	wear_image_icon = 'icons/mob/clothing/eyes.dmi'
	var/list/clothing_choices = list()
	var/current_choice = new/datum/chameleon_glasses_pattern

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_glasses_pattern)))
			var/datum/chameleon_glasses_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/glasses/U, mob/user)
		if(istype(U, /obj/item/clothing/glasses/chameleon))
			boutput(user, SPAN_ALERT("No!!! That's a horrible idea! You'll cause a horrible eyewear cascade!"))
			SPAWN(1 SECOND)
				boutput(user, SPAN_ALERT("Nah, just pulling your leg. Doing that still doesn't work though!"))
			return

		if(istype(U, /obj/item/clothing/glasses/))
			for(var/datum/chameleon_glasses_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, SPAN_ALERT("That appearance is already saved in the chameleon pattern banks!"))
					return

			var/datum/chameleon_glasses_pattern/P = new /datum/chameleon_glasses_pattern(src)
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
			boutput(M, SPAN_ALERT("<B>Your chameleon glasses malfunction!</B>"))
			src.name = "glasses"
			src.desc = "A pair of glasses. They seem to be broken, though."
			src.icon_state = "psyche"
			src.item_state = "psyche"
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Glasses."
		set category = "Local"
		set src in usr

		var/datum/chameleon_glasses_pattern/which = tgui_input_list(usr, "Change the glasses to which pattern?", "Chameleon Glasses", clothing_choices)

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_glasses_pattern/T)
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

/datum/chameleon_glasses_pattern
	var/name = "prescription glasses"
	var/desc = "Corrective lenses, perfect for the near-sighted."
	var/icon_state = "glasses"
	var/item_state = "glasses"
	var/sprite_item = 'icons/obj/clothing/item_glasses.dmi'
	var/sprite_worn = 'icons/mob/clothing/eyes.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_headgear.dmi'

	meson
		name = "Meson Goggles"
		desc = "Goggles that allow you to see the structure of the station through walls."
		icon_state = "meson"
		item_state = "glasses"

	sunglasses
		name = "sunglasses"
		desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
		icon_state = "sun"
		item_state = "sunglasses"

	sechud
		name = "\improper Security HUD"
		desc = "Sunglasses with a high tech sheen."
		icon_state = "sec"

	thermal
		name = "optical thermal scanner"
		icon_state = "thermal"
		item_state = "glasses"

	visor
		name = "\improper VISOR goggles"
		icon_state = "visor"
		item_state = "glasses"

	prodoc
		name = "\improper ProDoc Healthgoggles"
		desc = "Fitted with an advanced miniature sensor array that allows the user to quickly determine the physical condition of others."
		icon_state = "prodocs-upgraded"

	spectro
		name = "spectroscopic scanner goggles"
		icon_state = "spectro"
		item_state = "glasses"

/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	desc = "These shoes somewhat protect you from fire."
	icon_state = "black"
	icon = 'icons/obj/clothing/item_shoes.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_feethand.dmi'
	wear_image_icon = 'icons/mob/clothing/feet.dmi'
	var/list/clothing_choices = list()
	var/current_choice = new/datum/chameleon_shoes_pattern
	step_sound = "step_default"

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_shoes_pattern)))
			var/datum/chameleon_shoes_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/shoes/U, mob/user)
		if(istype(U, /obj/item/clothing/shoes/chameleon))
			boutput(user, SPAN_ALERT("No!!! That's a terrible idea! You'll cause a bad shoe feedback cycle!"))
			SPAWN(1 SECOND)
				boutput(user, SPAN_ALERT("Nah, just joking. Doing that still doesn't work though!"))
			return

		if(istype(U, /obj/item/clothing/shoes/cowboy/boom)) //if they're gonna copy sounds they're not gonna work on boom boots
			boutput(user, SPAN_ALERT("It doesn't seem like your chameleon shoes can copy that. Hmm."))
			return

		if(istype(U, /obj/item/clothing/shoes))
			for(var/datum/chameleon_shoes_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, SPAN_ALERT("That appearance is already saved in the chameleon pattern banks!"))
					return

			var/datum/chameleon_shoes_pattern/P = new /datum/chameleon_shoes_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			P.step_sound = U.step_sound
			src.clothing_choices += P

			boutput(user, SPAN_NOTICE("[U.name]'s appearance has been copied!"))

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, SPAN_ALERT("<B>Your chameleon shoes malfunction!</B>"))
			src.name = "shoes"
			src.desc = "A pair of shoes. Maybe they're those light up kind you had as a kid?"
			src.icon_state = "psyche"
			src.item_state = "psyche"
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Shoes."
		set category = "Local"
		set src in usr

		var/datum/chameleon_shoes_pattern/which = tgui_input_list(usr, "Change the shoes to which pattern?", "Chameleon Shoes", clothing_choices)

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_shoes_pattern/T)
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
			src.step_sound = T.step_sound
			src.tooltip_rebuild = TRUE
			usr.set_clothing_icon_dirty()

/datum/chameleon_shoes_pattern
	var/name = "black shoes"
	var/desc = "These shoes somewhat protect you from fire."
	var/icon_state = "black"
	var/item_state = "black"
	var/sprite_item = 'icons/obj/clothing/item_shoes.dmi'
	var/sprite_worn = 'icons/mob/clothing/feet.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_feethand.dmi'
	var/step_sound = "step_default"

	brown
		name = "brown shoes"
		icon_state = "brown"
		item_state = "brown"
		desc = "Brown shoes, camouflage on this kind of station."
		step_sound = "step_default"

	red
		name = "red shoes"
		icon_state = "red"
		item_state = "red"
		step_sound = "step_default"

	orange
		name = "orange shoes"
		icon_state = "orange"
		item_state = "orange"
		desc = "Shoes, now in prisoner orange! Can be made into shackles."
		step_sound = "step_default"

	white
		name = "white shoes"
		icon_state = "white"
		item_state = "white"
		desc = "Protects you against biohazards that would enter your feet."
		step_sound = "step_default"

	magnetic
		name = "magnetic shoes"
		desc = "Keeps the wearer firmly anchored to the ground. Provided the ground is metal, of course."
		icon_state = "magboots"
		item_state = "magboots"
		step_sound = "step_plating"

	swat
		name = "military boots"
		desc = "Polished and very shiny military boots."
		icon_state = "swat"
		item_state = "swat"
		step_sound = "step_military"

	caps_boots
		name = "captain's boots"
		desc = "A set of formal shoes with a protective layer underneath."
		icon_state = "capboots"
		item_state = "capboots"
		step_sound = "step_military"

	galoshes
		name = "galoshes"
		desc = "Rubber boots that prevent slipping on wet surfaces."
		icon_state = "galoshes"
		item_state = "galoshes"
		step_sound = "step_rubberboot"

	detective
		name = "worn boots"
		desc = "This pair of leather boots has seen better days."
		icon_state = "detective"
		item_state = "detective"
		step_sound = "step_default"

	magic_sandals
		name = "magic sandals"
		desc = "They magically stop you from slipping on magical hazards. It's not the mesh on the underside that does that. It's MAGIC. Read a fucking book."
		icon_state = "wizard"
		item_state = "wizard"
		step_sound = "step_flipflop"

	chef
		name = "chef's clogs"
		desc = "Sturdy shoes that minimize injury from falling objects or knives."
		icon_state = "chef"
		step_sound = "step_wood"

	mechanised_diving_boots
		name = "mechanised diving boots"
		icon_state = "divindboots"
		item_state = "divindboots"
		desc = "Industrial-grade boots fitted with mechanised balancers and stabilisers to increase running speed under a heavy workload."
		step_sound = "step_default"

	mechanised_boots
		icon_state = "indboots"
		item_state = "indboots"
		name = "mechanised boots"
		desc = "Industrial-grade boots fitted with mechanised balancers and stabilisers to increase running speed under a heavy workload."
		step_sound = "step_default"
