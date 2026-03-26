/obj/item/clothing/head/chameleon
	name = "hat"
	desc = "A knit cap in red."
	icon_state = "red"
	item_state = "rgloves"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	icon = 'icons/obj/clothing/item_hats.dmi'
	var/list/clothing_choices = list()
	var/current_choice = new/datum/chameleon_hat_pattern
	blocked_from_petasusaphilic = TRUE
	item_function_flags = IMMUNE_TO_ACID

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_hat_pattern)))
			var/datum/chameleon_hat_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/head/U, mob/user)
		if(istype(U, /obj/item/clothing/head/chameleon))
			boutput(user, SPAN_ALERT("No!!! That's a terrible idea! You'll cause a cataclysmic hat infinite loop!"))
			SPAWN(1 SECOND)
				boutput(user, SPAN_ALERT("Nah, just yankin' your chain. Doing that still doesn't work though!"))
			return

		if(istype(U, /obj/item/clothing/head/))
			for(var/datum/chameleon_hat_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, SPAN_ALERT("That appearance is already saved in the chameleon pattern banks!"))
					return

			var/datum/chameleon_hat_pattern/P = new /datum/chameleon_hat_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			P.seal_hair = U.c_flags & COVERSHAIR
			src.clothing_choices += P

			boutput(user, SPAN_NOTICE("[U.name]'s appearance has been copied!"))

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, SPAN_ALERT("<B>Your chameleon hat malfunctions!</B>"))
			src.name = "hat"
			src.desc = "A knit cap in...what the hell?"
			src.icon_state = "psyche"
			src.item_state = "bgloves"
			src.hides_from_examine = null
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			src.c_flags &= ~COVERSHAIR
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Hat."
		set category = "Local"
		set src in usr

		var/datum/chameleon_hat_pattern/which = tgui_input_list(usr, "Change the hat to which pattern?", "Chameleon Hat", clothing_choices)

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_hat_pattern/T)
		if (T)
			src.current_choice = T
			src.hides_from_examine = T.hides_from_examine
			src.name = T.name
			src.desc = T.desc
			src.icon_state = T.icon_state
			src.item_state = T.item_state
			src.icon = T.sprite_item
			src.wear_image_icon = T.sprite_worn
			src.inhand_image_icon = T.sprite_hand
			src.wear_image = image(wear_image_icon)
			src.inhand_image = image(inhand_image_icon)
			if (T.seal_hair)
				c_flags |= COVERSHAIR
			else
				c_flags &= ~COVERSHAIR
			src.tooltip_rebuild = TRUE
			usr.set_clothing_icon_dirty()

/datum/chameleon_hat_pattern
	var/name = "hat"
	var/desc = "A knit cap in red."
	var/icon_state = "red"
	var/item_state = "rgloves"
	var/sprite_item = 'icons/obj/clothing/item_hats.dmi'
	var/sprite_worn = 'icons/mob/clothing/head.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_headgear.dmi'
	var/seal_hair = FALSE
	var/hides_from_examine = null

	NTberet
		name = "Nanotrasen beret"
		desc = "For the inner space dictator in you."
		icon_state = "ntberet"
		item_state = "ntberet"
		seal_hair = FALSE

	HoS_beret
		name = "HoS Beret"
		icon_state = "hosberet"
		item_state = "hosberet"
		desc = "Actually, this hat is from a fast-food restaurant, that's why it folds like it was made of paper."
		seal_hair = FALSE

	HoS_hat
		name = "HoS Hat"
		icon_state = "hoscap"
		item_state = "hoscap"
		desc = "Actually, this hat is from a fast-food restaurant, that's why it folds like it was made of paper."
		seal_hair = FALSE

	caphat
		name = "Captain's hat"
		icon_state = "captain"
		item_state = "caphat"
		desc = "A symbol of the captain's rank, and the source of all their power."
		seal_hair = FALSE

	janiberet
		name = "Head of Sanitation beret"
		desc = "The Chief of Cleaning, the Superintendent of Scrubbing, whatever you call yourself, you know how to make those tiles shine. Good job."
		icon_state = "janitorberet"
		item_state = "janitorberet"
		seal_hair = FALSE

	janihat
		name = "Head of Sanitation hat"
		desc = "The Chief of Cleaning, the Superintendent of Scrubbing, whatever you call yourself, you know how to make those tiles shine. Good job."
		icon_state = "janitorhat"
		item_state = "janitorhat"
		seal_hair = FALSE

	hardhat
		name = "hard hat"
		icon_state = "hardhat0"
		item_state = "hardhat0"
		desc = "Protects your head from falling objects, and comes with a flashlight. Safety first!"
		seal_hair = FALSE

	hardhat_CE
		name = "chief engineer's hard hat"
		icon_state = "hardhat_chief_engineer0"
		item_state = "hardhat_chief_engineer0"
		desc = "A dented old helmet with a bright green stripe. An engraving on the inside reads 'CE'."
		seal_hair = FALSE

	security
		name = "helmet"
		icon_state = "helmet-sec"
		item_state = "helmet"
		desc = "Somewhat protects your head from being bashed in."
		seal_hair = FALSE
		hides_from_examine = C_EARS

	fancy
		name = "fancy hat"
		icon_state = "rank-fancy"
		item_state = "that"
		desc = "What do you mean this hat isn't fancy?"
		seal_hair = FALSE

	detective
		name = "Detective's hat"
		desc = "Someone who wears this will look very smart."
		icon_state = "detective"
		item_state = "det_hat"
		seal_hair = FALSE

	space_helmet
		name = "space helmet"
		icon_state = "space"
		item_state = "s_helmet"
		desc = "Helps protect against vacuum."
		seal_hair = TRUE
		hides_from_examine = C_EARS|C_MASK|C_GLASSES

	space_helmet_emergency
		name = "emergency hood"
		icon_state = "emerg"
		item_state = "emerg"
		desc = "Helps protect from vacuum for a short period of time."
		seal_hair = TRUE
		hides_from_examine = C_EARS|C_MASK|C_GLASSES

	space_helmet_engineer
		name = "engineering space helmet"
		desc = "Comes equipped with a builtin flashlight."
		icon_state = "espace0"
		item_state = "s_helmet"
		seal_hair = TRUE
		hides_from_examine = C_EARS|C_MASK|C_GLASSES

	industrial_helmet
		icon_state = "indus"
		item_state = "indus"
		name = "industrial space helmet"
		desc = "Goes with Industrial Space Armor. Now with zesty citrus-scented visor!"
		seal_hair = TRUE
		hides_from_examine = C_EARS|C_MASK|C_GLASSES

	industrial_diving_helmet
		icon_state = "diving_suit-industrial"
		item_state = "diving_suit-industrial"
		name = "industrial diving helmet"
		desc = "Goes with Industrial Diving Suit. Now with a fresh mint-scented visor!"
		seal_hair = TRUE
		hides_from_examine = C_EARS|C_MASK|C_GLASSES

	cowboy_hat
		name = "cowboy hat"
		desc = "Yeehaw!"
		icon_state = "cowboy"
		item_state = "cowboy"
		seal_hair = FALSE

	turban
		name = "turban"
		desc = "A very comfortable cotton turban."
		icon_state = "turban"
		item_state = "that"
		seal_hair = FALSE

	top_hat
		name = "top hat"
		desc = "An stylish looking hat"
		icon_state = "tophat"
		item_state = "that"
		seal_hair = FALSE

	chef_hat
		name = "Chef's hat"
		desc = "Your toque blanche, coloured as such so that your poor sanitation is obvious, and the blood shows up nice and crazy."
		icon_state = "chef"
		item_state = "chefhat"
		seal_hair = FALSE

	bio_hood
		name = "bio hood"
		icon_state = "bio"
		item_state = "bio_hood"
		desc = "This hood protects you from harmful biological contaminants."
		seal_hair = TRUE
		hides_from_examine = C_EARS

	postal_cap
		name = "postmaster's hat"
		desc = "The hat of a postmaster."
		icon_state = "mailcap"
		item_state = "mailcap"
		seal_hair = FALSE
