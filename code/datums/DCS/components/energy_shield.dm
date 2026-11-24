/**
 * Personal energy shield component
 *
 * Wearer-targeting?
 * Add ability button to item to toggle component
 * Uses power cell in the item - automatically create a cell_holder component if one does not exist?
 *
 * How it blocks damage:
 *  attack code Sends a COMSIG_MOB_SHIELD_ACTIVATE(imcoming_damage, return_list) to the mob, energy shield component drains power cell of parent item if possible
 *  Addnl: Send a RETURNED_LIST, in the case of a partial block
 *  Proc sending the signal decides how to handle the damage
 *   Bleedthrough? On all hits, or only on shield-break? Determined by initialization var
 *
 * Req hooking into a process scheduler for passive power drain
 *
 *
 * TODO: better sfx
 * TODO: better text feedback?
 * TODO: not copy-pasted vfx
 * TODO: Have efficiency coefficients for different damage types defined on the component?
 * TODO: support for granting mob properties? Consider subtype for CE shield - low efficiency but strong environmental resists
 */

TYPEINFO(/datum/component/wearertargeting/energy_shield)
	initialization_args = list(
		ARG_INFO("valid_slots", DATA_INPUT_LIST_BUILD, "List of wear slots that the component should function in \[1-19\]"),
		ARG_INFO("shield_strength", DATA_INPUT_NUM, "Fraction of damage blocked by shield \[0-1\]", 1),
		ARG_INFO("shield_efficiency", DATA_INPUT_NUM, "Power cost per point of damage blocked", 1),
		ARG_INFO("bleedthrough", DATA_INPUT_BOOL, "If the shield should only block damage proportional to power left in the cell if it would run out to block the hit", TRUE),
		ARG_INFO("power_drain", DATA_INPUT_NUM, "Cell power use per process cycle when active", 0)
	)

/datum/component/wearertargeting/energy_shield
	//no transfer, highlander dupe

	///what percent of damage should be blocked by the shield
	var/shield_strength
	///efficiency of the shield, as a coefficient to damage blocked - i.e.: shield strength of 0.5, efficiency of 1.5, blocking a 100 damage attack, would cost 75 power (100 * 0.5 * 1.5).
	var/shield_efficiency
	///do we bleed through on break?
	var/bleedthrough
	///how much power do we draw every process cycle
	var/power_drain
	///are we turned on 😳
	var/active

	var/obj/decal/ceshield/overlay

	signals = list(COMSIG_MOB_SHIELD_ACTIVATE)
	proctype = PROC_REF(activate)

/datum/component/wearertargeting/energy_shield/Initialize(_valid_slots, _shield_strength = 1, _shield_efficiency = 1, _bleedthrough = TRUE, _power_drain = 0)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.shield_strength = _shield_strength
	src.shield_efficiency = _shield_efficiency
	src.bleedthrough = _bleedthrough
	src.power_drain = _power_drain
	overlay = new
	RegisterSignal(parent, COMSIG_SHIELD_TOGGLE, PROC_REF(toggle))
	if((SLOT_L_HAND in valid_slots) || (SLOT_R_HAND in valid_slots))
		parent:c_flags |= EQUIPPED_WHILE_HELD

/datum/component/wearertargeting/energy_shield/on_equip(datum/source, mob/equipper, slot)
	var/obj/item/I = parent
	I.add_item_ability(equipper, /obj/ability_button/toggle_shield)
	. = ..()

/datum/component/wearertargeting/energy_shield/on_unequip(datum/source, mob/user)
	var/obj/item/I = parent
	I.remove_item_ability(user, /obj/ability_button/toggle_shield)
	if(active)
		src.turn_off()
	. = ..()

/datum/component/wearertargeting/energy_shield/proc/activate(datum/source, incoming_damage, list/return_list)
	if(!src.active)
		return
	var/list/charge_list = list()
	var/charge = null

	if(SEND_SIGNAL(parent, COMSIG_CELL_CHECK_CHARGE, charge_list) & CELL_RETURNED_LIST)
		charge = charge_list["charge"]
	else
		return

	var/cost = incoming_damage * shield_strength * shield_efficiency
	var/blocked = shield_strength
	if(cost > charge)
		if(bleedthrough)
			blocked *= charge/cost
		turn_off(TRUE)
	else
		playsound(current_user, 'sound/impact_sounds/Energy_Hit_1.ogg', 30, 0.1, 0, 2)

	return_list["shield_strength"] += blocked
	SEND_SIGNAL(parent, COMSIG_CELL_USE, cost)

	return //return code?

/datum/component/wearertargeting/energy_shield/proc/process(datum/source)
	if(SEND_SIGNAL(parent, COMSIG_CELL_USE, power_drain) & CELL_INSUFFICIENT_CHARGE)
		src.turn_off()
	return

/datum/component/wearertargeting/energy_shield/disposing()
	processing_items -= src
	. = ..()

/datum/component/wearertargeting/energy_shield/proc/turn_on()
	processing_items |= src
	src.active = TRUE
	playsound(current_user, 'sound/items/miningtool_on.ogg', 25, FALSE, -5, 1.5)
	boutput(current_user, SPAN_NOTICE("You power up your energy shield."))
	current_user.vis_contents += overlay

/datum/component/wearertargeting/energy_shield/proc/turn_off(shatter = FALSE)
	processing_items -= src
	src.active = FALSE
	current_user.vis_contents -= overlay
	if(shatter)
		playsound(current_user, 'sound/impact_sounds/Crystal_Shatter_1.ogg', 30, 0.1, 0, 0.5)
		current_user.visible_message(SPAN_ALERT("[current_user]'s energy shield violently pops!"))
		elecflash(current_user, 1, 1, 0)
	else
		playsound(current_user, 'sound/items/miningtool_off.ogg', 25, FALSE, -5, 1.5)
		boutput(current_user, SPAN_NOTICE("Your energy shield powers down."))
	SEND_SIGNAL(parent, COMSIG_UPDATE_ICON)

/datum/component/wearertargeting/energy_shield/proc/toggle()
	if(active)
		src.turn_off()
	else
		if(SEND_SIGNAL(parent, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE)
			src.turn_on()
			return TRUE
		else
			playsound(current_user, "sparks", 75, 1, -1)
			boutput(current_user, SPAN_ALERT("Your energy shield is depleted!"))

/obj/ability_button/toggle_shield //TODO: percentage inventory-counter for remaining power?
	name = "Toggle Energy Shield"
	icon_state = "shieldceoff"
	desc = "Toggle personal energy shield."

	execute_ability()
		. = ..()
		if(SEND_SIGNAL(the_item, COMSIG_SHIELD_TOGGLE))
			src.icon_state = "shieldceon"
		else
			src.icon_state = "shieldceoff"

	post_attach()
		RegisterSignal(src.the_item, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		UpdateIcon()

	disposing()
		UnregisterSignal(src.the_item, COMSIG_UPDATE_ICON)
		. = ..()

	update_icon(...)
		. = ..()
		var/ret = list()
		var/percent
		if(SEND_SIGNAL(the_item, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			percent = 100 * ret["charge"] / ret["max_charge"]
		else
			percent = 0 //no cell, no charge meter
		if(percent == 0)
			src.icon_state = "shieldceoff"
		var/h_color
		switch(percent)
			if (50 to INFINITY)
				h_color	= "rgb([(100 - percent) / 50 * 255], 255, [(100 - percent) * 0.3])"
			if (0 to 50)
				h_color	= "rgb(255, [percent / 50 * 255], 0)"
			if (-INFINITY to 0)
				h_color	= "#ffffff"
		src.maptext = "<span style='color: [h_color];' class='pixel c sh'>[round(percent)]%</span>"

//TODO: Add tooltip/desc info to item


/datum/component/wearertargeting/energy_shield/ceshield/turn_on()
	. = ..()
	APPLY_ATOM_PROPERTY(current_user, PROP_MOB_COLDPROT, src, 100)
	APPLY_ATOM_PROPERTY(current_user, PROP_MOB_HEATPROT, src, 100)
	APPLY_ATOM_PROPERTY(current_user, PROP_MOB_RADPROT_EXT, src, 100)

/datum/component/wearertargeting/energy_shield/ceshield/turn_off(shatter = FALSE)
	. = ..()
	REMOVE_ATOM_PROPERTY(current_user, PROP_MOB_COLDPROT, src)
	REMOVE_ATOM_PROPERTY(current_user, PROP_MOB_HEATPROT, src)
	REMOVE_ATOM_PROPERTY(current_user, PROP_MOB_RADPROT_EXT, src)
