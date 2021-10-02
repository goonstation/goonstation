
#define MAKE_SLOT(slot, item) list("slot" = slot, "item" = item ? item.name : null)

/mob/living/carbon/human/proc/show_inv(mob/user as mob)
	src.ui_interact(user)
	return


/mob/living/carbon/human/ui_state(mob/user)
	return tgui_physical_state

/mob/living/carbon/human/ui_status(mob/user)
  return min(
		tgui_physical_state.can_use_topic(src, user),
		tgui_not_incapacitated_state.can_use_topic(src, user)
	)

/mob/living/carbon/human/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "HumanInventory")
		ui.open()

/mob/living/carbon/human/ui_data(mob/user)

	var/list/slots = list(
		MAKE_SLOT(src.slot_head, src.head),
		MAKE_SLOT(src.slot_wear_mask, src.wear_mask),
		MAKE_SLOT(src.slot_glasses, src.glasses),
		MAKE_SLOT(src.slot_ears, src.ears),
		MAKE_SLOT(src.slot_l_hand, src.l_hand),
		MAKE_SLOT(src.slot_r_hand, src.r_hand),
		MAKE_SLOT(src.slot_gloves, src.gloves),
		MAKE_SLOT(src.slot_shoes, src.shoes),
		MAKE_SLOT(src.slot_belt, src.belt),
		MAKE_SLOT(src.slot_w_uniform, src.w_uniform),
		MAKE_SLOT(src.slot_wear_suit, src.wear_suit),
		MAKE_SLOT(src.slot_back, src.back),
		MAKE_SLOT(src.slot_wear_id, src.wear_id),
		MAKE_SLOT(src.slot_l_store, src.l_store),
		MAKE_SLOT(src.slot_r_store, src.r_store),
	)

	. = list(
		"name" = src.name,
		"slots" = slots,
		"handcuffed" = src.hasStatus("handcuffed"),
		"internal" = src.internal != null,
		"canSetInternal" = istype(src.wear_mask, /obj/item/clothing/mask) && istype(src.back, /obj/item/tank) && !src.internal
	)

/mob/living/carbon/human/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	switch(action)
		if ("slot")
			actions.start(new/datum/action/bar/icon/otherItem(
				usr,
				src,
				usr.equipped(),
				params["slot"],
				0,
				params["slot"] == src.slot_l_store || params["slot"] == src.slot_r_store
			), usr)
			return

		if ("handcuff")
			actions.start(new/datum/action/bar/icon/handcuffRemovalOther(src), usr)
			return

		if ("internal")
			actions.start(new/datum/action/bar/icon/internalsOther(src), usr)
			return

#undef MAKE_SLOT
