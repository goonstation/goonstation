#define MAKE_SLOT(slot, item) list("id" = slot, "item" = item?.name)
#define MAKE_SLOT_CUSTOM(slot, item, name) list("id" = slot, "item" = item ? name : null)

/datum/humanInventory
	var/mob/living/carbon/human/human = null

/datum/humanInventory/New(var/mob/living/carbon/human/H)
	..()
	human = H

/datum/humanInventory/ui_state(mob/user)
	return tgui_physical_state

/datum/humanInventory/ui_status(mob/user)
	return min(
		tgui_physical_state.can_use_topic(src.human, user),
		tgui_not_incapacitated_state.can_use_topic(src.human, user)
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
		"canSetInternal" = istype(src.human.wear_mask, /obj/item/clothing/mask) && istype(src.human.back, /obj/item/tank) && !src.human.internal
	)

/datum/humanInventory/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if ("access-slot")
			var/id
			var/obstructed = FALSE
			switch(params["id"])
				if ("slot_head")
					id = src.human.slot_head
				if ("slot_wear_mask")
					id = src.human.slot_wear_mask
				if ("slot_glasses")
					id = src.human.slot_glasses
				if ("slot_ears")
					id = src.human.slot_ears
				if ("slot_l_hand")
					id = src.human.slot_l_hand
				if ("slot_r_hand")
					id = src.human.slot_r_hand
				if ("slot_gloves")
					id = src.human.slot_gloves
				if ("slot_shoes")
					id = src.human.slot_shoes
				if ("slot_belt")
					id = src.human.slot_belt
				if ("slot_w_uniform")
					id = src.human.slot_w_uniform
				if ("slot_wear_suit")
					id = src.human.slot_wear_suit
				if ("slot_back")
					id = src.human.slot_back
				if ("slot_wear_id")
					id = src.human.slot_wear_id
				if ("slot_l_store")
					id = src.human.slot_l_store
				if ("slot_r_store")
					id = src.human.slot_r_store

			if (id)
				obstructed = src.human.CheckObstructed(id)
				actions.start(new/datum/action/bar/icon/otherItem(
					usr,
					src.human,
					usr.equipped(),
					id,
					0,
					id == src.human.slot_l_store || id == src.human.slot_r_store,
					obstructed
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
