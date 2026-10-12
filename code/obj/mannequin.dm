/// A clothing display using human worn sprites without equipping items on a mob.
/obj/mannequin
	name = "mannequin"
	desc = "A blank display figure on a sturdy stand, ready to model the latest fashions."
	icon = 'icons/obj/furniture/mannequin.dmi'
	icon_state = "mannequin"
	density = TRUE
	layer = MOB_LAYER
	material_amt = MATERIAL::AMOUNT::SHEET
	mat_changeappearance = FALSE
	HELP_MESSAGE_OVERRIDE("Apply clothing to dress it; click empty-handed to remove clothing. Wrench: show/hide arms and legs or dismantle. Screwdriver: secure. Crowbar: rotate. Gloves show the arms; shoes show the legs.")
	/// Real items stored on the display, keyed by human equipment slot.
	var/list/displayed_items
	/// Visible pairs of limbs, using the ARMS and LEGS body-part flags.
	var/display_limbs = 0
	var/static/list/slot_names = list(
		SLOT_W_UNIFORM = "Uniform",
		SLOT_WEAR_SUIT = "Suit",
		SLOT_HEAD = "Headwear",
		SLOT_WEAR_MASK = "Mask",
		SLOT_GLASSES = "Glasses",
		SLOT_EARS = "Ears",
		SLOT_GLOVES = "Gloves",
		SLOT_SHOES = "Shoes",
		SLOT_BACK = "Back",
		SLOT_BELT = "Belt",
		SLOT_WEAR_ID = "Lanyard"
	)

	New()
		..()
		src.displayed_items = list()
		src.UpdateIcon()

	disposing()
		// qdel recursively deletes contents after disposing; save the clothes first.
		for (var/slot in src.displayed_items)
			src.remove_clothing(slot)
		src.displayed_items = null
		..()

	attackby(obj/item/W, mob/user)
		if (!in_interact_range(src, user) || !can_act(user))
			return
		if (iswrenchingtool(W))
			src.wrench_interact(W, user)
			return
		if (isscrewingtool(W))
			src.anchored = src.anchored ? UNANCHORED : ANCHORED
			playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
			user.visible_message(SPAN_NOTICE("[user] [src.anchored ? "secures" : "unsecures"] [src]."))
			return
		if (ispryingtool(W))
			if (src.anchored)
				boutput(user, SPAN_ALERT("Unsecure [src] before rotating it."))
				return
			src.set_dir(turn(src.dir, -90))
			return
		if (src.get_clothing_slot(W))
			src.add_clothing(W, user)
			return
		..()

	attack_hand(mob/user)
		if (!in_interact_range(src, user) || !can_act(user))
			return
		if (!length(src.displayed_items))
			boutput(user, SPAN_NOTICE("[src] isn't displaying any clothing."))
			return
		var/list/choices = list()
		for (var/slot in src.displayed_items)
			var/obj/item/I = src.displayed_items[slot]
			choices["[src.slot_names[slot]]: [I.name]"] = I
		var/selection = tgui_input_list(user, "Which item would you like to remove?", src.name, choices)
		// Recheck after input: another player may have taken the item or moved the display.
		if (!selection || QDELETED(src) || !in_interact_range(src, user) || !can_act(user))
			return
		var/obj/item/selected_item = choices[selection]
		for (var/slot in src.displayed_items)
			if (src.displayed_items[slot] != selected_item)
				continue
			src.remove_clothing(slot)
			user.put_in_hand_or_drop(selected_item)
			user.visible_message(SPAN_NOTICE("[user] removes [selected_item] from [src]."))
			return

	get_desc(dist, mob/user)
		. = ..()
		for (var/slot in src.displayed_items)
			var/obj/item/I = src.displayed_items[slot]
			. += "<br>[src.slot_names[slot]]: [I.name]."

	Exited(obj/item/gone, atom/newloc)
		..()
		src.forget_clothing(gone)

	proc/get_clothing_slot(obj/item/I)
		if (istype(I, /obj/item/clothing/under))
			return SLOT_W_UNIFORM
		if (istype(I, /obj/item/clothing/suit))
			return SLOT_WEAR_SUIT
		if (istype(I, /obj/item/clothing/head))
			return SLOT_HEAD
		if (istype(I, /obj/item/clothing/mask))
			return SLOT_WEAR_MASK
		if (istype(I, /obj/item/clothing/glasses))
			return SLOT_GLASSES
		if (istype(I, /obj/item/clothing/ears) || istype(I, /obj/item/device/radio/headset))
			return SLOT_EARS
		if (istype(I, /obj/item/clothing/gloves))
			return SLOT_GLOVES
		if (istype(I, /obj/item/clothing/shoes))
			return SLOT_SHOES
		if (istype(I, /obj/item/clothing/lanyard))
			return SLOT_WEAR_ID
		if (istype(I, /obj/item/clothing) || istype(I, /obj/item/storage))
			if (I.c_flags & ONBACK)
				return SLOT_BACK
			if (I.c_flags & ONBELT)
				return SLOT_BELT
		return null

	proc/add_clothing(obj/item/I, mob/user)
		if (QDELETED(src) || QDELETED(I) || !user || !in_interact_range(src, user) || !can_act(user))
			return FALSE
		var/slot = src.get_clothing_slot(I)
		if (!slot)
			return FALSE
		if (src.displayed_items[slot])
			boutput(user, SPAN_ALERT("Remove the [lowertext(src.slot_names[slot])] already on [src] first."))
			return FALSE
		if (!user.is_in_hands(I) || I.cant_drop || I.cant_self_remove)
			return FALSE
		if (!user.drop_item(I) || QDELETED(I))
			return FALSE
		I.set_loc(src)
		src.displayed_items[slot] = I
		src.RegisterSignal(I, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(forget_clothing))
		src.RegisterSignal(I, COMSIG_ATOM_POST_UPDATE_ICON, PROC_REF(refresh_clothing))
		if (slot == SLOT_GLOVES)
			src.display_limbs |= ARMS
		if (slot == SLOT_SHOES)
			src.display_limbs |= LEGS
		src.UpdateIcon()
		user.visible_message(SPAN_NOTICE("[user] puts [I] on [src]."))
		return TRUE

	proc/remove_clothing(slot)
		var/obj/item/I = src.displayed_items[slot]
		if (!I)
			return null
		src.forget_clothing(I)
		I.set_loc(get_turf(src))
		return I

	/// Clear both references and overlays if an item is taken or independently deleted.
	proc/forget_clothing(obj/item/I)
		for (var/slot in src.displayed_items)
			if (src.displayed_items[slot] != I)
				continue
			src.UnregisterSignal(I, list(COMSIG_PARENT_PRE_DISPOSING, COMSIG_ATOM_POST_UPDATE_ICON))
			src.displayed_items -= slot
			src.UpdateOverlays(null, slot)
			src.UpdateOverlays(null, "[slot]_material")
			return

	proc/refresh_clothing()
		src.UpdateIcon()

	proc/wrench_interact(obj/item/tool, mob/user)
		set waitfor = FALSE
		var/list/options = list(
			src.display_limbs & ARMS ? "Hide Arms" : "Show Arms",
			src.display_limbs & LEGS ? "Hide Legs" : "Show Legs",
			"Dismantle"
		)
		var/selection = tgui_input_list(user, "Adjust the mannequin's limbs or dismantle it.", src.name, options)
		if (!selection || QDELETED(src) || QDELETED(tool) || QDELETED(user) || !in_interact_range(src, user) || !can_act(user) || user.equipped() != tool)
			return
		var/limb_group
		var/visible
		switch (selection)
			if ("Show Arms", "Hide Arms")
				limb_group = ARMS
				visible = selection == "Show Arms"
			if ("Show Legs", "Hide Legs")
				limb_group = LEGS
				visible = selection == "Show Legs"
			if ("Dismantle")
				if (length(src.displayed_items))
					boutput(user, SPAN_ALERT("Remove the clothing before dismantling [src]."))
					return
				SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, PROC_REF(dismantle), list(user, tool), tool.icon, tool.icon_state, null, null)
				return
			else
				return
		var/limb_name = limb_group == ARMS ? "arms" : "legs"
		if (!src.set_limb_visible(limb_group, visible))
			boutput(user, SPAN_ALERT("Remove the [limb_group == ARMS ? "gloves" : "shoes"] before hiding the [limb_name]."))
			return
		user.visible_message(SPAN_NOTICE("[user] [visible ? "extends" : "retracts"] [src]'s [limb_name]."))

	/// Validate the wrench again when the dismantling action finishes.
	proc/dismantle(mob/user, obj/item/tool)
		if (QDELETED(user) || QDELETED(tool) || !in_interact_range(src, user) || !can_act(user) || user.equipped() != tool)
			return FALSE
		. = src.deconstruct()
		if (.)
			user.visible_message(SPAN_NOTICE("[user] dismantles [src]."))

	proc/set_limb_visible(limb_group, visible)
		if (limb_group != ARMS && limb_group != LEGS)
			return FALSE
		if (!visible && ((limb_group == ARMS && src.displayed_items[SLOT_GLOVES]) || (limb_group == LEGS && src.displayed_items[SLOT_SHOES])))
			return FALSE
		if (visible)
			src.display_limbs |= limb_group
		else
			src.display_limbs &= ~limb_group
		src.UpdateIcon()
		return TRUE

	update_icon()
		switch (src.display_limbs)
			if (ARMS | LEGS)
				src.icon_state = "mannequin-full"
			if (ARMS)
				src.icon_state = "mannequin-arms"
			if (LEGS)
				src.icon_state = "mannequin-legs"
			else
				src.icon_state = "mannequin"
		for (var/slot in src.displayed_items)
			var/obj/item/I = src.displayed_items[slot]
			var/wear_state = I.wear_state || I.icon_state
			if (slot == SLOT_BELT)
				wear_state = I.wear_state || I.item_state || I.icon_state
			I.wear_image.icon = I.wear_image_icon
			I.wear_image.icon_state = wear_state
			// Retain visual decorations without running equipped() effects.
			I.update_wear_image(null, FALSE)
			var/image/worn = image(null)
			worn.appearance = I.wear_image.appearance
			worn.icon = I.wear_image_icon
			worn.filters = I.filters.Copy()
			worn.layer = I.wear_layer
			worn.pixel_x = 0
			worn.pixel_y = 0
			worn.dir = SOUTH
			worn.appearance_flags |= RESET_COLOR | RESET_ALPHA
			I.copy_appearance_to_image(worn)
			if (slot == SLOT_BACK && worn.layer == MOB_CLOTHING_LAYER)
				worn.layer = MOB_BACK_LAYER
			if (slot == SLOT_BELT && worn.layer == MOB_CLOTHING_LAYER)
				worn.layer = MOB_BELT_LAYER
			if (slot == SLOT_GLOVES || slot == SLOT_SHOES)
				worn.icon = null
				worn.color = null
				worn.alpha = 255
				worn.filters = null
				worn.overlays = null
				if (slot == SLOT_GLOVES)
					wear_state = I.wear_state || I.item_state || I.icon_state
				for (var/side in list("left", "right"))
					if (slot == SLOT_GLOVES)
						var/obj/item/clothing/gloves/gloves = I
						if (!(gloves.which_hands & (side == "left" ? GLOVE_HAS_LEFT : GLOVE_HAS_RIGHT)))
							continue
					var/image/half = image(I.wear_image_icon, "[side]_[wear_state]")
					I.copy_appearance_to_image(half)
					half.appearance_flags |= RESET_COLOR | RESET_ALPHA
					worn.overlays += half
			src.UpdateOverlays(worn, slot)
			if (I.worn_material_texture_image)
				var/image/texture = image(null)
				texture.appearance = I.worn_material_texture_image.appearance
				texture.layer = worn.layer + 0.1
				texture.appearance_flags |= RESET_COLOR | RESET_ALPHA
				src.UpdateOverlays(texture, "[slot]_material")
			else
				src.UpdateOverlays(null, "[slot]_material")

	proc/deconstruct()
		// Somebody may have dressed it while the action bar was running.
		if (QDELETED(src) || length(src.displayed_items))
			return FALSE
		var/obj/item/sheet/sheet = new(get_turf(src))
		sheet.setMaterial(src.material || getMaterial("steel"))
		playsound(src, 'sound/items/Ratchet.ogg', 50, TRUE)
		qdel(src)
		return TRUE
