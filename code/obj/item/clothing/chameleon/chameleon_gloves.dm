/obj/item/clothing/gloves/chameleon
	name = "black gloves"
	desc = "These thick leather gloves are fire-resistant."
	icon_state = "black"
	item_state = "bgloves"
	icon = 'icons/obj/clothing/item_gloves.dmi'
	wear_image_icon = 'icons/mob/clothing/hands.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_feethand.dmi'
	var/list/clothing_choices = list()
	var/current_choice = new/datum/chameleon_gloves_pattern
	material_prints = "black leather fibers"
	fingertip_color = "#535353"

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_gloves_pattern)))
			var/datum/chameleon_gloves_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/gloves/U, mob/user)
		if(istype(U, /obj/item/clothing/gloves/chameleon))
			boutput(user, SPAN_ALERT("No!!! That's a terrible idea! You'll cause an awful glove fractal!"))
			SPAWN(1 SECOND)
				boutput(user, SPAN_ALERT("Nah, just having a laugh. Doing that still doesn't work though!"))
			return

		if(istype(U, /obj/item/clothing/gloves))
			for(var/datum/chameleon_gloves_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, SPAN_ALERT("That appearance is already saved in the chameleon pattern banks!"))
					return

			var/datum/chameleon_gloves_pattern/P = new /datum/chameleon_gloves_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			src.clothing_choices += P
			P.print_type = U.material_prints

			boutput(user, SPAN_NOTICE("[U.name]'s appearance has been copied!"))

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, SPAN_ALERT("<B>Your chameleon gloves malfunction!</B>"))
			src.name = "gloves"
			src.desc = "A pair of gloves. Something seems off about them..."
			src.icon_state = "psyche"
			src.item_state = "psyche"
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			src.material_prints = "high-tech rainbow flashing nanofibers"
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Gloves."
		set category = "Local"
		set src in usr

		var/datum/chameleon_shoes_pattern/which = tgui_input_list(usr, "Change the shoes to which pattern?", "Chameleon Gloves", clothing_choices)

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_gloves_pattern/T)
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
			src.material_prints = T.print_type
			var/glove_fp_mask = T.get_fiber_mask(src)
			if(glove_fp_mask)
				src.print_mask = register_id(glove_fp_mask)
				var/list/fiber_chars = list("c","f","g","h","i","j","k","r","s","t","v","w","x","y","z")
				fibers = register_id("[src.material_prints]: [build_id(fiber_chars, 7)]")
			src.tooltip_rebuild = TRUE
			usr.set_clothing_icon_dirty()

/datum/chameleon_gloves_pattern
	var/name = "black gloves"
	var/desc = "These thick leather gloves are fire-resistant."
	var/icon_state = "black"
	var/item_state = "bgloves"
	var/sprite_item = 'icons/obj/clothing/item_gloves.dmi'
	var/sprite_worn = 'icons/mob/clothing/hands.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_feethand.dmi'
	var/print_type = "black leather fibers"
	var/fingertip_color = null

	proc/get_fiber_mask(var/obj/item/clothing/gloves/gloves)
		return FORENSIC_GLOVE_MASK_NONE

	insulated
		desc = "Tough rubber work gloves styled in a high-visibility yellow color. They are electrically insulated, and provide full protection against most shocks."
		name = "insulated gloves"
		icon_state = "yellow"
		item_state = "ygloves"
		print_type = "insulative fibers"
		fingertip_color = "#ffff33"

		get_fiber_mask(var/obj/item/clothing/gloves/gloves)
			return gloves.create_glovemask_order(3) // 1/8 chance of match

	fingerless
		desc = "These gloves lack fingers. Good for a space biker look, but not so good for concealing your fingerprints."
		name = "fingerless gloves"
		icon_state = "fgloves"
		item_state = "finger-"
		fingertip_color = null

		get_fiber_mask(var/obj/item/clothing/gloves/gloves)
			return FORENSIC_GLOVE_MASK_FINGERLESS

	latex
		name = "latex gloves"
		icon_state = "latex"
		item_state = "lgloves"
		desc = "Thin, disposal medical gloves used to help prevent the spread of germs."
		fingertip_color = "#f3f3f3"

		get_fiber_mask(var/obj/item/clothing/gloves/gloves)
			return gloves.create_glovemask_bunch(2) // 1/16 chance of match

	boxing
		name = "boxing gloves"
		desc = "Big soft gloves used in competitive boxing. Gives your punches a bit more weight, at the cost of precision."
		icon_state = "boxinggloves"
		item_state = "bogloves"
		print_type = "red leather fibers"
		fingertip_color = "#f80000"

		get_fiber_mask(var/obj/item/clothing/gloves/gloves)
			return gloves.create_glovemask_bunch(1) // 1/4 chance of match

	long
		desc = "These long gloves protect your sleeves and skin from whatever dirty job you may be doing."
		name = "cleaning gloves"
		icon_state = "long_gloves"
		item_state = "long_gloves"
		print_type = "synthetic silicone rubber fibers"
		fingertip_color = "#ffff33"

		get_fiber_mask(var/obj/item/clothing/gloves/gloves)
			return gloves.create_glovemask_order(2) // 1/2 chance of match

	gauntlets
		name = "concussion gauntlets"
		desc = "These gloves enable miners to punch through solid rock with their hands instead of using tools."
		icon_state = "cgaunts"
		item_state = "bgloves"
		print_type = "industrial-grade mineral fibers"
		fingertip_color = "#535353"

		get_fiber_mask(var/obj/item/clothing/gloves/gloves)
			return gloves.create_glovemask_order(2) // 1/2 chance of match

	caps_gloves
		name = "captain's gloves"
		desc = "A pair of formal gloves that are electrically insulated and quite heat-resistant. The high-quality materials help you in blocking attacks."
		icon_state = "capgloves"
		item_state = "capgloves"
		print_type = "high-quality synthetic fibers"
		fingertip_color = "#3fb54f"

		get_fiber_mask(var/obj/item/clothing/gloves/gloves)
			return gloves.create_glovemask_order(2) // 1/2 chance of match
