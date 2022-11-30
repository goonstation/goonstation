/**
 * Personal energy shield component
 *
 * Wearer-targeting?
 * Add ability button to item to toggle component
 * Uses power cell in the item - automatically create a cell_holder component if one does not exist?
 *
 * How it blocks damage:
 *  attack code Sends a COMSIG_MOB_SHIELD_ACTIVATE(imcoming_damage, return_list) to the mob, energy shield component responds with a CELL_SUFFICIENT/CELL_INSUFFICIENT return
 *  Addnl: Or send a RETURNED_LIST, in the case of a partial block? Perhaps preceed with a COMSIG_CHECK_SHIELD? unsure
 *  Proc sending the signal decides how to handle the damage - Some way of having shield strength determined by the component?
 *   Bleedthrough? On all hits, or only on shield-break? Or never?
 *
 * Addnl support for granting mob properties? Consider subtype for CE shield - low power but strong environmental resists
 * Req hooking into a process scheduler for passive power drain
 *
 * 
 * TODO: better sfx
 * TODO: text feedback
 * TODO: vfx??
 * TODO: impl in item/attack, bullet_act, ex_act
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

	signals = list(COMSIG_MOB_SHIELD_ACTIVATE)
	proctype = .proc/activate

/datum/component/wearertargeting/energy_shield/Initialize(_valid_slots, _shield_strength = 1, _shield_efficiency = 1, _bleedthrough = TRUE, _power_drain = 0)
	. = ..()
	src.shield_strength = _shield_strength
	src.shield_efficiency = _shield_efficiency
	src.bleedthrough = _bleedthrough
	src.power_drain = _power_drain
	RegisterSignal(parent, COMSIG_SHIELD_TOGGLE, .proc/toggle)

/datum/component/wearertargeting/energy_shield/on_equip(datum/source, mob/equipper, slot)
	//Add item ability?????????????????????
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
		return //what the fuck

	var/cost = incoming_damage * shield_strength * shield_efficiency
	var/blocked = shield_strength
	if(cost > charge && bleedthrough)
		blocked *= charge/cost
		playsound(current_user, 'sound/impact_sounds/Crystal_Shatter_1.ogg', 30, 0.1, 0, 0.5)
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
	//check for cell?
	if(SEND_SIGNAL(parent, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE)
		processing_items |= src
		src.active = TRUE
	else //fail message here?
		src.active = FALSE
	playsound(current_user, 'sound/items/miningtool_on.ogg', 30, 1)

/datum/component/wearertargeting/energy_shield/proc/turn_off()
	processing_items -= src
	src.active = FALSE
	playsound(current_user, 'sound/items/miningtool_off.ogg', 30, 1)

/datum/component/wearertargeting/energy_shield/proc/toggle()
	if(active)
		src.turn_off()
	else
		src.turn_on()

/obj/ability_button/toggle_shield //TODO: percentage inventory-counter for remaining power?
	name = "Toggle Energy Shield"
	icon_state = "shieldceon"
	desc = "Toggle personal energy shield."

	execute_ability()
		. = ..()
		SEND_SIGNAL(the_item, COMSIG_SHIELD_TOGGLE)

/obj/item/clothing/gloves/yellow
	New()
		. = ..()
		AddComponent(/datum/component/wearertargeting/energy_shield, list(SLOT_GLOVES), 1, 1, 1, 0)
		AddComponent(/datum/component/power_cell, 50, 50, 0, 0, 1)

//TODO: Add tooltip/desc info to item