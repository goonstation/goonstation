#define MAKE_SLOT(slot, item) list("id" = slot, "item" = item?.name)
#define MAKE_SLOT_CUSTOM(slot, item, name) list("id" = slot, "item" = item ? name : null)

/datum/humanInventory
	var/mob/living/carbon/human/human = null

/datum/humanInventory/New(var/mob/living/carbon/human/H)
	..()
	human = H

/datum/humanInventory/disposing()
	src.human = null
	..()

/datum/humanInventory/ui_state(mob/user)
	return tgui_physical_state

/datum/humanInventory/ui_status(mob/user)
	return min(
		tgui_physical_state.can_use_topic(src.human, user),
		tgui_not_incapacitated_state.can_use_topic(src.human, user),
		istype(src.human) ? UI_INTERACTIVE : UI_CLOSE
	)

/datum/humanInventory/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "HumanInventory")
		ui.open()

/datum/humanInventory/ui_data(mob/user)

	var/list/slots = list(
		MAKE_SLOT("slot_head", src.human.head),
		MAKE_SLOT("slot_wear_mask", src.human.wear_mask),
		MAKE_SLOT("slot_glasses", src.human.glasses),
		MAKE_SLOT("slot_ears", src.human.ears),
		MAKE_SLOT("slot_l_hand", src.human.l_hand),
		MAKE_SLOT("slot_r_hand", src.human.r_hand),
		MAKE_SLOT("slot_gloves", src.human.gloves),
		MAKE_SLOT("slot_shoes", src.human.shoes),
		MAKE_SLOT("slot_belt", src.human.belt),
		MAKE_SLOT("slot_w_uniform", src.human.w_uniform),
		MAKE_SLOT("slot_wear_suit", src.human.wear_suit),
		MAKE_SLOT("slot_back", src.human.back),
		MAKE_SLOT("slot_wear_id", src.human.wear_id),
		MAKE_SLOT_CUSTOM("slot_l_store", src.human.l_store, "Something"),
		MAKE_SLOT_CUSTOM("slot_r_store", src.human.r_store, "Something"),
	)

	. = list(
		"name" = src.human.name,
		"slots" = slots,
		"handcuffed" = src.human.hasStatus("handcuffed"),
		"internal" = src.human.internal != null,
		"canSetInternal" = src.can_set_internal()
	)

/datum/humanInventory/proc/can_set_internal()
	if(src.human.internal || !istype(src.human.wear_mask, /obj/item/clothing/mask))
		return FALSE
	if(!HAS_FLAG(src.human.wear_mask.c_flags, MASKINTERNALS))
		return FALSE
	var/list/eq_list = list(src.human.back, src.human.belt, src.human.l_store, src.human.r_store, src.human.r_hand, src.human.l_hand)
	for(var/I in eq_list)
		if(istype(I, /obj/item/tank))
			return TRUE
	return FALSE

/datum/humanInventory/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	switch(action)
		if ("access-slot")
			var/id
			switch(params["id"])
				if ("slot_head")
					id = SLOT_HEAD
				if ("slot_wear_mask")
					id = SLOT_WEAR_MASK
				if ("slot_glasses")
					id = SLOT_GLASSES
				if ("slot_ears")
					id = SLOT_EARS
				if ("slot_l_hand")
					id = SLOT_L_HAND
				if ("slot_r_hand")
					id = SLOT_R_HAND
				if ("slot_gloves")
					id = SLOT_GLOVES
				if ("slot_shoes")
					id = SLOT_SHOES
				if ("slot_belt")
					id = SLOT_BELT
				if ("slot_w_uniform")
					id = SLOT_W_UNIFORM
				if ("slot_wear_suit")
					id = SLOT_WEAR_SUIT
				if ("slot_back")
					id = SLOT_BACK
				if ("slot_wear_id")
					id = SLOT_WEAR_ID
				if ("slot_l_store")
					id = SLOT_L_STORE
				if ("slot_r_store")
					id = SLOT_R_STORE

			if (id)
				actions.start(new/datum/action/bar/icon/otherItem(
					usr,
					src.human,
					usr.equipped(),
					id,
					0,
					id == SLOT_L_STORE || id == SLOT_R_STORE
				), usr)
			return

		if ("remove-handcuffs")
			actions.start(new/datum/action/bar/icon/handcuffRemovalOther(src.human), usr)
			return

		if ("access-internals")
			actions.start(new/datum/action/bar/icon/internalsOther(src.human), usr)
			return

#undef MAKE_SLOT
#undef MAKE_SLOT_CUSTOM
