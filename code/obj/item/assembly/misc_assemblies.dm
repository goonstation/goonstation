/*
Contains:

- Assembly parent
- Timer/igniter
- Proximity/igniter
- Remote signaller/igniter
- Health analyzer/igniter
- Remote signaller/bike horn
- Remote signaller/timer
- Remote signaller/proximity
- Beaker Assembly
- Pipebomb Assembly
- Craftable shotgun shells

*/

//////////////////////////////////////// Assembly parent /////////////////////////////////

/obj/item/assembly
	name = "assembly"
	icon = 'icons/obj/items/assemblies.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "assembly"
	var/status = 0
	throwforce = 10
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 10
	force = 2
	stamina_damage = 10
	stamina_cost = 10
	var/force_dud = 0

/obj/item/assembly/proc/c_state(n, O as obj)
	return

/////////////////////////////////////// Component-Assembly /////////////////////////


/obj/item/assembly/complete
	desc = "An assembly of multiple components."
	var/obj/item/trigger = null //! This is anything that causes the Applier to fire, e.g. a signaler, mouse trap or a timer
	var/trigger_icon_prefix = null
	var/obj/item/applier = null //!  This is anything that is activated by the trigger, e.g. an igniter or a bikehorn
	var/applier_icon_prefix = null
	var/obj/item/target = null //! This is anything that the applier will be used upon, e.g. a plasma tank or a beaker
	var/target_item_prefix = null
	var/target_overlay_invisible = FALSE ///! use this if you dont want either the target or the target_item_prefix to create an overlay
	var/secured = FALSE //! If false, this does not activate and can be modified on self-use
	var/list/additional_components = null //! This is a list of components that don't make up the main 3 components of the assembly, but can be attached after the target was added.
	var/icon_base_offset = 0 //! offset for the base-icon of the assembly, if the target gets overriden
	var/override_upstream = FALSE //!Set this to true if the assembly should send the signal received to its master (e.g. in case of canbombs)
	var/special_construction_identifier = null //! a string which should be used to identify special constructions, so e.g. cables in additional_components know they should show their overlay for a canbomb
	var/override_name = null //! use this when an assembly should override the name of the assembly, e.g. canbomb assembly
	var/override_description = null //! same for the descripion
	var/override_help_message = null //! see override_name, just for help message
	var/mob/last_armer = null //! for tracking/logging of who armed the assembly
	flags = TABLEPASS | CONDUCT | NOSPLASH
	item_function_flags = OBVIOUS_INTERACTION_BAR

/obj/item/assembly/complete/New(var/new_location)
	src.additional_components = list()
	RegisterSignal(src, COMSIG_MOVABLE_FLOOR_REVEALED, PROC_REF(on_floor_reveal))
	RegisterSignal(src, COMSIG_ITEM_STORAGE_INTERACTION, PROC_REF(on_storage_interaction))
	RegisterSignal(src, COMSIG_ITEM_ON_OWNER_DEATH, PROC_REF(on_wearer_death))
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_GET_TRIGGER_STATE, PROC_REF(get_trigger_state))
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_GET_TRIGGER_TIME_LEFT, PROC_REF(get_trigger_time_left))
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ON_PART_DISPOSAL, PROC_REF(on_part_disposing))
	..()

/obj/item/assembly/complete/proc/set_up_new(var/mob/user, var/obj/item/new_trigger, var/obj/item/new_applier, var/obj/item/new_target)
	if(!new_trigger || !new_applier)
		CRASH("tried to set up an assembly without a trigger or applier")
	var/list/to_set_up_items = list(new_trigger, new_applier)
	src.applier = new_applier
	src.applier_icon_prefix = initial(new_applier.icon_state)
	src.trigger = new_trigger
	src.trigger_icon_prefix = initial(new_trigger.icon_state)
	if(new_target)
		to_set_up_items += new_target
		src.target = new_target
	for(var/obj/item/checked_item in to_set_up_items)
		checked_item.set_loc(src)
		checked_item.master = src
		checked_item.layer = initial(checked_item.layer)
		src.w_class = max(src.w_class, checked_item.w_class)
		if(user)
			checked_item.add_fingerprint(user)
	//now, to set up the assembly, we have to send the signals in the correct order like a normal assembly would be created
	SEND_SIGNAL(src.trigger, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, src, user, TRUE)
	SEND_SIGNAL(src.applier, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, src, user, TRUE)
	if(new_target)
		//Since we set up the target addition, we undo the added assembly components
		src.RemoveComponentsOfType(/datum/component/assembly)
		SEND_SIGNAL(src.target, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, src, user, TRUE)
		SEND_SIGNAL(src.trigger, COMSIG_ITEM_ASSEMBLY_ITEM_ON_TARGET_ADDITION, src, user, new_target)
		SEND_SIGNAL(src.applier, COMSIG_ITEM_ASSEMBLY_ITEM_ON_TARGET_ADDITION, src, user, new_target)
	src.UpdateIcon()
	src.UpdateName()

/obj/item/assembly/complete/proc/get_trigger_state(var/affected_assembly)
	if(src.secured)
		//we relay the signal to the trigger, if the assembly is secured
		return SEND_SIGNAL(src.trigger, COMSIG_ITEM_ASSEMBLY_GET_TRIGGER_STATE, src)
	else
		return ASSEMBLY_TRIGGER_NOT_SECURED

/// returns TRUE if the assembly has anything that condemns it worth to be logged
/obj/item/assembly/complete/proc/requires_admin_messaging()
	var/value_to_return = FALSE
	if(src.target)
		value_to_return = (value_to_return | HAS_FLAG(src.target.flags, ASSEMBLY_NEEDS_MESSAGING))
	return (value_to_return | HAS_FLAG(src.trigger.flags, ASSEMBLY_NEEDS_MESSAGING) | HAS_FLAG(src.applier.flags, ASSEMBLY_NEEDS_MESSAGING))

///this goes over every component of the assembly and checks if admins need additional informations about these.
/obj/item/assembly/complete/proc/get_additional_logging_information(var/mob/user)
	var/information_to_return = ""
	for(var/obj/item/affected_item in list(src.trigger, src.applier, src.target))
		var/information_to_add = affected_item.assembly_get_admin_log_message(user, src)
		if(information_to_add)
			information_to_return += " [affected_item]:[information_to_add];"
	return information_to_return

/obj/item/assembly/complete/proc/get_trigger_time_left(var/affected_assembly)
	//we relay the signal to the trigger, in case of mousetraps
	return SEND_SIGNAL(src.trigger, COMSIG_ITEM_ASSEMBLY_GET_TRIGGER_TIME_LEFT, src)

/obj/item/assembly/complete/proc/set_trigger_time(var/time_to_set)
	//we send a signal on the trigger to set the time
	return SEND_SIGNAL(src.trigger, COMSIG_ITEM_ASSEMBLY_SET_TRIGGER_TIME, src, time_to_set)

/obj/item/assembly/complete/proc/on_floor_reveal(var/affected_assembly, var/turf/revealed_turf)
	//we relay the signal to the trigger, in case of mousetraps
	SEND_SIGNAL(src.trigger, COMSIG_MOVABLE_FLOOR_REVEALED, revealed_turf)

/obj/item/assembly/complete/proc/on_storage_interaction(var/affected_assembly, var/mob/user)
	//we relay the signal to the trigger, in case of mousetraps
	return SEND_SIGNAL(src.trigger, COMSIG_ITEM_STORAGE_INTERACTION, user)

/obj/item/assembly/complete/proc/on_wearer_death(var/affected_assembly, var/mob/dying_mob)
	//we relay the signal to the trigger, in case of health-analyser
	return SEND_SIGNAL(src.trigger, COMSIG_ITEM_ON_OWNER_DEATH, dying_mob)

/obj/item/assembly/complete/receive_signal(datum/signal/signal)
	if(src.force_dud == TRUE)
		message_admins("A [src.name] would have activated at [log_loc(src)] but was forced to dud! Armed by: [key_name(src.last_armer)]; Last touched by: [key_name(src.fingerprintslast)]")
		logTheThing(LOG_BOMBING, null, "A [src.name] would have activated at [log_loc(src)] but was forced to dud! Armed by: [key_name(src.last_armer)]; Last touched by: [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"]")
		return
	if(src.override_upstream && src.master)
		//if we should just relay signals, we do so, no matter where they come from
		src.master.receive_signal(signal)
		return
	//only secured assemblies should fire and only if the signal is not from the applier.
	if (src.secured && (signal && signal.source != src.applier))
		for(var/mob/O in hearers(1, src.loc))
			O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)
		//Some Admin logging/messaging
		logTheThing(LOG_BOMBING, src.last_armer, "A [src.name] was activated at [log_loc(src)]. Armed by: [key_name(src.last_armer)]; Last touched by: [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"];[src.get_additional_logging_information(src.last_armer)]")
		if(src.requires_admin_messaging())
			message_admins("A [src.name] was activated at [log_loc(src)]. Armed by: [key_name(src.last_armer)]; Last touched by: [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"]")
		//now lets blow some shit up
		SEND_SIGNAL(src.applier, COMSIG_ITEM_ASSEMBLY_APPLY, src, src.target)


/obj/item/assembly/complete/proc/on_part_disposing(var/affected_assembly, var/datum/removed_datum)
	if(src.disposed || src.qdeled)
		return
	spawn(1)
		src.tear_apart()

/obj/item/assembly/complete/dropped(mob/user)
	. = ..()
	// we relay the dropping of the assembly to the trigger in case of a proximity sensor
	SEND_SIGNAL(src.trigger, COMSIG_ITEM_DROPPED, user)

/obj/item/assembly/complete/Crossed(atom/movable/crossing_atom)
	. = ..()
	// we relay the dropping of the assembly to the trigger in case of a mouse trap
	src.trigger.Crossed(crossing_atom)

///------ Proc to transfer impulses/events onto the main components ---------
/obj/item/assembly/complete/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume, cannot_be_cooled)
	. = ..()
	for(var/obj/item/affected_item in list(src.trigger, src.applier, src.target))
		affected_item.temperature_expose(air, exposed_temperature, exposed_volume, cannot_be_cooled)

/obj/item/assembly/complete/ex_act(severity)
	..()
	if(!src.qdeled && !src.disposed)
		for(var/obj/item/affected_item in list(src.trigger, src.applier, src.target))
			affected_item.ex_act(severity)

/obj/item/assembly/complete/material_trigger_on_mob_attacked(mob/attacker, mob/attacked, atom/weapon, situation_modifier)
	. = ..()
	for(var/obj/item/affected_item in list(src.trigger, src.applier, src.target))
		affected_item.material_trigger_on_mob_attacked(attacker, attacked, weapon, situation_modifier)

/obj/item/assembly/complete/material_trigger_on_bullet(atom/attacked, obj/projectile/projectile, situation_modifier)
	. = ..()
	for(var/obj/item/affected_item in list(src.trigger, src.applier, src.target))
		affected_item.material_trigger_on_bullet(attacked, projectile, situation_modifier)

/obj/item/assembly/complete/material_trigger_on_chems(chem, amount)
	. = ..()
	for(var/obj/item/affected_item in list(src.trigger, src.applier, src.target))
		affected_item.material_trigger_on_chems(chem, amount)

/obj/item/assembly/complete/material_trigger_on_blob_attacked(blobPower, situation_modifier)
	. = ..()
	for(var/obj/item/affected_item in list(src.trigger, src.applier, src.target))
		affected_item.material_trigger_on_blob_attacked(blobPower, situation_modifier)

/obj/item/assembly/complete/material_on_attack_use(mob/attacker, atom/attacked)
	. = ..()
	for(var/obj/item/affected_item in list(src.trigger, src.applier, src.target))
		affected_item.material_on_attack_use(attacker, attacked)

/obj/item/assembly/complete/material_trigger_when_attacked(atom/attackatom, mob/attacker, meleeorthrow, situation_modifier)
	. = ..()
	for(var/obj/item/affected_item in list(src.trigger, src.applier, src.target))
		affected_item.material_trigger_when_attacked(attackatom, attacker, meleeorthrow, situation_modifier)

/obj/item/assembly/complete/material_on_pickup(mob/user)
	//we pick one item here the person is touching
	. = ..()
	var/list/item_selection = list(src.trigger, src.applier)
	if(src.target)
		item_selection += src.target
	var/obj/item/picked_item = pick(item_selection)
	picked_item.material_on_pickup(user)

/obj/item/assembly/complete/material_on_drop(mob/user)
	//we pick one item here the person is touching
	. = ..()
	var/list/item_selection = list(src.trigger, src.applier)
	if(src.target)
		item_selection += src.target
	var/obj/item/picked_item = pick(item_selection)
	picked_item.material_on_drop(user)
///------ ------------------------------------------ ---------

/obj/item/assembly/complete/disposing()
	UnregisterSignal(src, COMSIG_MOVABLE_FLOOR_REVEALED)
	UnregisterSignal(src, COMSIG_ITEM_STORAGE_INTERACTION)
	UnregisterSignal(src, COMSIG_ITEM_ON_OWNER_DEATH)
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_GET_TRIGGER_STATE)
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_GET_TRIGGER_TIME_LEFT)
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ON_PART_DISPOSAL)
	var/list/items_to_remove = list(src.trigger, src.applier, src.target) | src.additional_components
	for(var/obj/item/item_to_delete in items_to_remove)
		qdel(item_to_delete)
	src.trigger = null
	src.applier = null
	src.target = null
	src.additional_components = null
	src.last_armer = null
	..()

/obj/item/assembly/complete/attack_self(mob/user)
	if (isghostcritter(user))
		boutput(user, SPAN_NOTICE("Some unseen force stops you from tampering with [src.name]."))
		return
	if(src.secured)
		//if the assembly is secured, we activate that thing
		if (SEND_SIGNAL(src.trigger, COMSIG_ITEM_ASSEMBLY_ACTIVATION, src, user))
			boutput(user, SPAN_NOTICE("You activate the [src.trigger.name] on the [src.name]."))
			//Some Admin logging/messaging
			logTheThing(LOG_BOMBING, user, "A [src.name] was armed at [log_loc(src)]. Armed by: [key_name(user)];[src.get_additional_logging_information(user)]")
			if(src.requires_admin_messaging())
				message_admins("A [src.name] was armed at [log_loc(src)]. Armed by: [key_name(user)]")
	else
		//if the assembly is unsecured, we enable modification on that thing
		SEND_SIGNAL(src.trigger, COMSIG_ITEM_ASSEMBLY_MANIPULATION, src, user)
		SEND_SIGNAL(src.applier, COMSIG_ITEM_ASSEMBLY_MANIPULATION, src, user)
	src.add_fingerprint(user)
	return

/obj/item/assembly/complete/update_icon()
	var/overlay_offset = 0 //how many pixels we want to move the overlays
	src.overlays = null
	src.underlays = null
	if(src.target && !src.target_item_prefix && !src.target_overlay_invisible)
		//If the target doesn't add it's own special icon state
		src.icon = src.target.icon
		src.icon_state = src.target.icon_state
		overlay_offset += 5
	else
		src.icon = initial(src.icon)
		src.icon_state = "trigger_[src.trigger_icon_prefix]"
		if(src.target_item_prefix && !src.target_overlay_invisible)
			var/image/temp_image_target = image('icons/obj/items/assemblies.dmi', src, "target_[src.target_item_prefix]")
			temp_image_target.pixel_y += overlay_offset + src.icon_base_offset
			src.overlays += temp_image_target
	if(src.applier_icon_prefix)
		var/image/temp_image_applier = image('icons/obj/items/assemblies.dmi', src, "applier_[src.applier_icon_prefix]")
		temp_image_applier.pixel_y += overlay_offset + src.icon_base_offset
		src.overlays += temp_image_applier
	if (src.additional_components)
		for(var/obj/item/iterated_component in src.additional_components)
			//if we have any additional components, we send them a signal to see if they add overlays to the assembly.
			SEND_SIGNAL(iterated_component,COMSIG_ITEM_ASSEMBLY_OVERLAY_ADDITIONS , src, overlay_offset)
	//So the applier gets rendered over every other component, we add it here as an overlay
	var/image/temp_image_trigger = image('icons/obj/items/assemblies.dmi', src, "trigger_[src.trigger_icon_prefix]")
	temp_image_trigger.pixel_y += overlay_offset + src.icon_base_offset
	src.overlays += temp_image_trigger
	if(!src.secured)
		var/image/temp_image_cables = image('icons/obj/items/assemblies.dmi', src, "assembly_unsecured")
		temp_image_cables.pixel_y += overlay_offset + src.icon_base_offset
		src.underlays += temp_image_cables


/obj/item/assembly/complete/get_help_message(dist, mob/user)
	if(src.secured)
		return "You can use <b>screwdriver</b> to unsecure the assembly in order to further modify it."

	var/text_to_be_returned = "You can use <b>screwdriver</b> to secure the assembly. You can use a <b>wrench</b> to disassemble the assembly."
	for(var/obj/item/checked_item in (list(src.trigger, src.applier, src.target) | src.additional_components))
		text_to_be_returned += checked_item.assembly_get_part_help_message(dist, user, src)
	return text_to_be_returned

/obj/item/assembly/complete/UpdateName()
	var/component_names = ""
	if(src.trigger) //lets not crash when we initially create the assembly
		component_names = "[initial(src.trigger.name)]/[initial(src.applier.name)]"
	if(src.target)
		component_names = "[component_names]/[initial(src.target.name)]"
	src.name = "[name_prefix(null, 1)][component_names]-[initial(src.name)][name_suffix(null, 1)]"


/obj/item/assembly/complete/attackby(obj/item/used_object, mob/user)
	if (iswrenchingtool(used_object) && !src.secured)
		if (src.target)
			boutput(user, SPAN_NOTICE("You remove the [src.target.name] from the assembly."))
			src.remove_until_minimum_components()
		else
			boutput(user, SPAN_NOTICE("You disassemble the [src.name]."))
			src.tear_apart()
		return
	if (isscrewingtool(used_object))
		src.secured = !(src.secured)
		boutput(user, SPAN_NOTICE("[src.name] is now [src.secured ? "secured" : "unsecured"]."))
		src.add_fingerprint(user)
		src.UpdateIcon()
		src.last_armer = user
		return
	..()

///an assembly does need at least a trigger and an applier, so this proc strips down the assembly to these parts
/obj/item/assembly/complete/proc/remove_until_minimum_components()
	// We remove all assembly-components from the assembly
	// and send the different parts of the assembly their corresponding signals to set up the assembly to the state it was
	var/turf/target_turf = get_turf(src)
	var/list/items_to_remove = list(src.target)
	if(src.additional_components)
		items_to_remove = items_to_remove | src.additional_components
	for(var/obj/item/removed_item in items_to_remove)
		SEND_SIGNAL(removed_item, COMSIG_ITEM_ASSEMBLY_ITEM_REMOVAL, src, null)
		removed_item.master = null
		if(!removed_item.qdeled && !removed_item.disposed)
			removed_item.set_loc(target_turf)
		if(removed_item in src.additional_components)
			src.additional_components -= removed_item
	//now, we need to set the assembly to a fresh state
	src.RemoveComponentsOfType(/datum/component/assembly)
	src.special_construction_identifier = null
	src.target = null
	src.target_item_prefix = null
	src.w_class = max(src.trigger.w_class, src.applier.w_class)
	SEND_SIGNAL(src.trigger, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, src, null, FALSE)
	SEND_SIGNAL(src.applier, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, src, null, FALSE)
	src.UpdateIcon()
	src.UpdateName()


///This proc removes all items attached to the assembly and removes it
/obj/item/assembly/complete/proc/tear_apart()
	var/list/items_to_remove = list(src.trigger, src.applier, src.target)
	var/turf/target_turf = get_turf(src)
	if(src.additional_components)
		items_to_remove = items_to_remove | src.additional_components
	if(ismob(src.loc))
		var/mob/handling_user = src.loc
		handling_user.u_equip(src)
	for(var/obj/item/removed_item in items_to_remove)
		SEND_SIGNAL(removed_item, COMSIG_ITEM_ASSEMBLY_ITEM_REMOVAL, src, null)
		removed_item.master = null
		if(!removed_item.qdeled && !removed_item.disposed)
			removed_item.set_loc(target_turf)
		if(removed_item in src.additional_components)
			src.additional_components -= removed_item
	src.trigger = null
	src.applier = null
	src.target = null
	qdel(src)


/// misc. Assembly-procs --------------------------------

/obj/item/assembly/complete/proc/add_target_item(var/atom/to_combine_atom, var/mob/user)
	if(src.target)
		return
	if(src.secured)
		boutput(user, "You need to unsecure the assembly first.")
		return
	if(SEND_SIGNAL(to_combine_atom, COMSIG_ITEM_ASSEMBLY_COMBINATION_CHECK, src, user))
		//let's check if we can combine the item in the first place, e.g. in case of cabled pipebombs
		return
	var/obj/item/manipulated_item = to_combine_atom
	src.target = manipulated_item
	manipulated_item.master = src
	manipulated_item.layer = initial(manipulated_item.layer)
	user.u_equip(manipulated_item)
	manipulated_item.set_loc(src)
	manipulated_item.add_fingerprint(user)
	src.w_class = max(src.w_class, manipulated_item.w_class)
	boutput(user, "You attach the [src.name] to the [manipulated_item.name].")
	//Since we completed the assembly, remove all assembly components
	src.RemoveComponentsOfType(/datum/component/assembly)
	//Now we set up the attached target for overlays/other assembly steps
	SEND_SIGNAL(manipulated_item, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, src, user, TRUE)
	//Now we send a signal to the other two components in case we enable certain combinations, e.g. for mousetraps
	SEND_SIGNAL(src.trigger, COMSIG_ITEM_ASSEMBLY_ITEM_ON_TARGET_ADDITION, src, user, to_combine_atom)
	SEND_SIGNAL(src.applier, COMSIG_ITEM_ASSEMBLY_ITEM_ON_TARGET_ADDITION, src, user, to_combine_atom)
	//Last but not least, we update our icon, w_class and name
	src.UpdateIcon()
	src.UpdateName()
	//Some Admin logging/messaging
	logTheThing(LOG_BOMBING, user, "A [src.name] was created at [log_loc(src)]. Created by: [key_name(user)];[src.get_additional_logging_information(user)]")
	if(src.requires_admin_messaging())
		message_admins("A [src.name] was created at [log_loc(src)]. Created by: [key_name(user)]")
	// Since the assembly was done, return TRUE
	return TRUE

/obj/item/assembly/complete/proc/add_additional_component(var/atom/to_combine_atom, var/mob/user)
	if(src.secured)
		boutput(user, "You need to unsecure the assembly first.")
		return
	if(SEND_SIGNAL(to_combine_atom, COMSIG_ITEM_ASSEMBLY_COMBINATION_CHECK, src, user))
		//let's check if we can combine the item in the first place, e.g. in case of cabled pipebombs
		return
	var/obj/item/manipulated_item = to_combine_atom
	src.additional_components += manipulated_item
	manipulated_item.master = src
	manipulated_item.layer = initial(manipulated_item.layer)
	user.u_equip(manipulated_item)
	manipulated_item.set_loc(src)
	manipulated_item.add_fingerprint(user)
	boutput(user, "You attach the [manipulated_item.name] to the [src.name].")
	//Since we completed the assembly, remove all assembly components
	src.RemoveComponentsOfType(/datum/component/assembly)
	//Now we set up the attached target for overlays/other assembly steps
	SEND_SIGNAL(manipulated_item, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, src, user, TRUE)
	//Now we send a signal to the other components in case we enable certain combinations, e.g. for mousetraps
	for(var/obj/item/checked_item in list(src.trigger, src.applier, src.target))
		SEND_SIGNAL(checked_item, COMSIG_ITEM_ASSEMBLY_ITEM_ON_MISC_ADDITION, src, user, to_combine_atom)
	for(var/obj/item/checked_item in src.additional_components)
		if(checked_item != manipulated_item)
			SEND_SIGNAL(checked_item, COMSIG_ITEM_ASSEMBLY_ITEM_ON_MISC_ADDITION, src, user, to_combine_atom)
	//Last but not least, we update our icon, w_class and name
	src.w_class = max(src.w_class, manipulated_item.w_class)
	src.UpdateIcon()
	src.UpdateName()
	// Since the assembly was done, return TRUE
	return TRUE


///mousetrap roller crafting proc
/obj/item/assembly/complete/proc/create_mousetrap_roller(var/atom/to_combine_atom, var/mob/user)
	if(src.w_class > W_CLASS_NORMAL)
		boutput(user, "[src.name] is too large for a mousetrap roller assembly.")
		return FALSE
	var/obj/item/pipebomb/frame/manipulated_frame = to_combine_atom
	if(src.secured || manipulated_frame.state > 1)
		//we can only use non-welded frames and unsecured assemblies
		return FALSE
	user.u_equip(to_combine_atom)
	user.u_equip(src)
	src.secured = TRUE
	src.UpdateIcon()
	src.add_fingerprint(user)
	manipulated_frame.add_fingerprint(user)
	var/obj/item/mousetrap_roller/new_roller = new /obj/item/mousetrap_roller(get_turf(user), src, to_combine_atom)
	new_roller.name = "roller/[src.name]" // Roller/mousetrap/igniter/plutonium 239-pipebomb-assembly, gotta love those names
	user.put_in_hand_or_drop(new_roller)
	//Some Admin logging/messaging
	logTheThing(LOG_BOMBING, user, "A [new_roller.name] was created at [log_loc(src)]. Created by: [key_name(user)];[src.get_additional_logging_information(user)]")
	if(src.requires_admin_messaging())
		message_admins("A [new_roller.name] was created at [log_loc(src)]. Created by: [key_name(user)]")
	// we don't remove the components here since the frame and assembly can be retreived by disassembling the roller
	// Since the assembly was done, return TRUE
	return TRUE

/obj/item/assembly/complete/proc/create_suicide_vest(var/atom/to_combine_atom, var/mob/user)
	if(src.secured)
		boutput(user, "You need to unsecure [src.name] first.")
		return FALSE
	user.u_equip(to_combine_atom)
	user.u_equip(src)
	src.secured = TRUE
	src.UpdateIcon()
	src.add_fingerprint(user)
	to_combine_atom.add_fingerprint(user)
	var/obj/item/clothing/suit/armor/suicide_bomb/new_suicide_vest = new /obj/item/clothing/suit/armor/suicide_bomb(get_turf(user), src, to_combine_atom)
	user.put_in_hand_or_drop(new_suicide_vest)
	//Some Admin logging/messaging
	logTheThing(LOG_BOMBING, user, "A [new_suicide_vest.name] was created at [log_loc(src)]. Created by: [key_name(user)];[src.get_additional_logging_information(user)]")
	if(src.requires_admin_messaging())
		message_admins("A [new_suicide_vest.name] was created at [log_loc(src)]. Created by: [key_name(user)]")
	// we don't remove the components here since the frame and assembly can be retreived by disassembling the roller
	// Since the assembly was done, return TRUE
	return TRUE

/obj/item/assembly/complete/proc/create_canbomb(var/atom/to_combine_atom, var/mob/user)
	var/obj/machinery/portable_atmospherics/canister/payload = to_combine_atom
	if(src.secured)
		boutput(user, "You need to unsecure [src.name] first.")
		return FALSE
	if(payload.holding)
		boutput(user, "You must remove the currently inserted tank from the slot first.")
		return FALSE
	user.u_equip(src)
	src.secured = TRUE
	src.UpdateIcon()
	src.add_fingerprint(user)
	to_combine_atom.add_fingerprint(user)
	var/obj/item/canbomb_detonator/new_detonator = new /obj/item/canbomb_detonator(get_turf(user), src, to_combine_atom)
	new_detonator.master = payload // i swear, i want to kill that master-variable sooooo bad
	new_detonator.attachedTo = payload
	new_detonator.builtBy = user
	payload.overlay_state = "overlay_safety_on"
	payload.det = new_detonator
	logTheThing(LOG_BOMBING, user, "builds a canister bomb [log_atmos(payload)] at [log_loc(payload)].")
	if(payload.air_contents.check_if_dangerous())
		message_admins("[key_name(user)] builds a canister bomb [alert_atmos(payload)] at [log_loc(payload)].")
	tgui_process.update_uis(payload)
	payload.UpdateIcon()
	// we don't remove the components here since the frame and assembly can be retreived by disassembling the canbomb
	// Since the assembly was done, return TRUE
	return TRUE



/// -----------------------------------------------------

/////////////////////////////////////// Timer/igniter /////////////////////////

/obj/item/assembly/time_ignite
	name = "Timer/Igniter Assembly"
	desc = "A timer-activated igniter assembly."
	icon_state = "timer-igniter0"
	var/obj/item/device/timer/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/reagent_containers/glass/beaker/part3 = null
	var/obj/item/pipebomb/frame/part4 = null
	var/obj/item/pipebomb/bomb/part5 = null
	var/sound_pipebomb = 'sound/weapons/armbomb.ogg'
	status = null
	flags = TABLEPASS | CONDUCT | NOSPLASH

/obj/item/assembly/time_ignite/New()
	..()
	// Timer-Igniter Assembly + wired pipebomb -> timer-igniter pipebomb
	src.AddComponent(/datum/component/assembly, /obj/item/pipebomb/frame, PROC_REF(pipebomb_frame_assembly), TRUE)
	// Timer-Igniter Assembly + pipebomb -> timer-igniter pipebomb
	src.AddComponent(/datum/component/assembly, /obj/item/pipebomb/bomb, PROC_REF(pipebomb_assembly), TRUE)
	// Timer-Igniter Assembly + beaker -> timer-igniter beakerbomb
	src.AddComponent(/datum/component/assembly, /obj/item/reagent_containers/glass/beaker, PROC_REF(beakerbomb_assembly), TRUE)
	SPAWN(0)
		if(!part1)
			part1 = new(src)
			part1.master = src
		if(!part2)
			part2 = new(src)
			part2.master = src
	return

/obj/item/assembly/time_ignite/disposing()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	qdel(part3)
	part3 = null
	qdel(part4)
	part4 = null
	qdel(part5)
	part5 = null
	..()

/obj/item/assembly/time_ignite/attack_self(mob/user as mob)
	src.part1.AttackSelf(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/time_ignite/receive_signal()
	if(!src.status)
		return
	for(var/mob/O in hearers(1, src.loc))
		O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)
	src.part2.ignite()
	if(src.part3)
		src.part3.reagents.temperature_reagents(4000, 400)
		src.part3.reagents.temperature_reagents(4000, 400)
	if(src.part5)
		playsound(src.loc, sound_pipebomb, 50, 0)
		SPAWN(3 SECONDS)
			src.part5.do_explode()
			qdel(src)
	return

/obj/item/assembly/time_ignite/attackby(obj/item/W, mob/user)
	if (!W)
		return
	if (iswrenchingtool(W) && !(src.status))
		var/turf/T = get_turf(src)
		if (src.part1)
			src.part1.set_loc(T)
			src.part1.master = null
			src.part1 = null
		if (src.part2)
			src.part2.set_loc(T)
			src.part2.master = null
			src.part2 = null
		if (src.part3)
			src.part3.set_loc(T)
			src.part3.master = null
			src.part3 = null
		if (src.part4)
			src.part4.set_loc(T)
			src.part4.master = null
			src.part4 = null
			src.part5.master = null
			src.part5 = null
		if (src.part5 && !src.part4)
			src.part5.set_loc(T)
			src.part5.master = null
			src.part5 = null
		user.u_equip(src)
		qdel(src)
		return

	if (isscrewingtool(W))
		src.status = !(src.status)
		if (src.status)
			user.show_message(SPAN_NOTICE("The timer is now secured!"), 1)
		else
			user.show_message(SPAN_NOTICE("The timer is now unsecured!"), 1)
		src.add_fingerprint(user)
		return

/obj/item/assembly/time_ignite/c_state(n)
	if(!src.part3 && !src.part5)
		src.icon = 'icons/obj/items/assemblies.dmi'
		src.icon_state = text("timer-igniter[n]")
		src.overlays = null
		src.underlays = null
		src.name = "Timer/Igniter Assembly"
	else if(!src.part3 && src.part5)
		src.icon = part5.icon
		src.icon_state = part5.icon_state
		src.overlays = null
		src.underlays = null
		src.overlays += image('icons/obj/items/assemblies.dmi', "timeignite_overlay[n]", layer = FLOAT_LAYER)
		src.name = "Timer/Igniter/Pipebomb Assembly"
	else
		src.icon = part3.icon
		src.icon_state = part3.icon_state
		src.overlays = null
		src.underlays = null
		src.overlays += image('icons/obj/items/assemblies.dmi', "timeignite_overlay[n]", layer = FLOAT_LAYER)
		src.underlays += part3.underlays
		src.name = "Timer/Igniter/Beaker Assembly"
	return

/obj/item/assembly/time_ignite/verb/removebeaker()
	set src in oview(1)
	set name = "remove beaker"
	set category = "Local"

	if (usr.stat || !isliving(usr) || isintangible(usr))
		return

	if(src.part3)
		src.part3.master = null
		src.part3.Attackhand(usr)
		src.part3 = null
		src.c_state(src.part1.timing)
		boutput(usr, SPAN_NOTICE("You remove the timer/igniter assembly from the beaker."))
		//since the assembly is free of beakers, let's add the assembly components again
		// Timer-Igniter Assembly + wired pipebomb -> timer-igniter pipebomb
		src.AddComponent(/datum/component/assembly, /obj/item/pipebomb/frame, PROC_REF(pipebomb_frame_assembly), TRUE)
		// Timer-Igniter Assembly + pipebomb -> timer-igniter pipebomb
		src.AddComponent(/datum/component/assembly, /obj/item/pipebomb/bomb, PROC_REF(pipebomb_assembly), TRUE)
		// Timer-Igniter Assembly + beaker -> timer-igniter beakerbomb
		src.AddComponent(/datum/component/assembly, /obj/item/reagent_containers/glass/beaker, PROC_REF(beakerbomb_assembly), TRUE)
	else boutput(usr, SPAN_ALERT("That doesn't have a beaker attached to it!"))

// Timer-igniter-assemblies

///Beakerbomb-assembly
/obj/item/assembly/time_ignite/proc/beakerbomb_assembly(var/atom/to_combine_atom, var/mob/user)
	if(src.status)
		boutput(user, "You need to unsecure the timer first.")
		return
	var/obj/item/reagent_containers/glass/beaker/manipulated_beaker = to_combine_atom
	src.part3 = manipulated_beaker
	manipulated_beaker.master = src
	manipulated_beaker.layer = initial(manipulated_beaker.layer)
	user.u_equip(manipulated_beaker)
	manipulated_beaker.set_loc(src)
	src.c_state(0)
	boutput(user, "You attach the timer/igniter assembly to the beaker.")

	//Since we completed the assembly, remove all assembly components
	src.RemoveComponentsOfType(/datum/component/assembly)
	// Since the assembly was done, return TRUE
	return TRUE

///Pipebomb-assembly out of standard pipebomb
/obj/item/assembly/time_ignite/proc/pipebomb_assembly(var/atom/to_combine_atom, var/mob/user)
	if(src.status)
		boutput(user, "You need to unsecure the timer first.")
		return
	var/obj/item/pipebomb/bomb/manipulated_pipebomb = to_combine_atom
	src.part5 = manipulated_pipebomb
	manipulated_pipebomb.master = src
	manipulated_pipebomb.layer = initial(manipulated_pipebomb.layer)
	user.u_equip(manipulated_pipebomb)
	manipulated_pipebomb.set_loc(src)
	src.c_state(0)
	boutput(user, "You attach the pipebomb to the timer/igniter assembly.")
	logTheThing(LOG_BOMBING, user, "made Timer/Igniter/Pipebomb Assembly at [log_loc(src)].")
	message_admins("[key_name(user)] made a Timer/Igniter/Pipebomb Assembly at [log_loc(src)].")

	//Since we completed the assembly, remove all assembly components
	src.RemoveComponentsOfType(/datum/component/assembly)
	// Since the assembly was done, return TRUE
	return TRUE


///Pipebomb-assembly out of cabled pipebomb
/obj/item/assembly/time_ignite/proc/pipebomb_frame_assembly(var/atom/to_combine_atom, var/mob/user)
	if(src.status)
		boutput(user, "You need to unsecure the timer first.")
		return
	var/obj/item/pipebomb/frame/manipulated_pipebomb = to_combine_atom
	if(manipulated_pipebomb.state < 4)
		boutput(user, "You have to add reagents and wires to the pipebomb before you can add an igniter.")
		return

	src.part4 = manipulated_pipebomb
	manipulated_pipebomb.master = src
	manipulated_pipebomb.layer = initial(manipulated_pipebomb.layer)
	user.u_equip(manipulated_pipebomb)
	manipulated_pipebomb.set_loc(src)

	src.part5 = new /obj/item/pipebomb/bomb
	src.part5.strength = manipulated_pipebomb.strength
	if (manipulated_pipebomb.material)
		src.part5.setMaterial(manipulated_pipebomb.material)
	//add properties from item mods to the finished pipe bomb
	src.part5.set_up_special_ingredients(manipulated_pipebomb.item_mods)
	user.u_equip(manipulated_pipebomb)
	src.part5 = src.part5
	src.part5.master = src
	src.part5.layer = initial(src.part5.layer)
	src.part5.set_loc(src)
	src.c_state(0)
	boutput(user, "You attach the pipebomb to the timer/igniter assembly.")
	logTheThing(LOG_BOMBING, user, "made Timer/Igniter/Pipebomb Assembly at [log_loc(src)].")
	message_admins("[key_name(user)] made a Timer/Igniter/Pipebomb Assembly at [log_loc(src)].")

	//Since we completed the assembly, remove all assembly components
	src.RemoveComponentsOfType(/datum/component/assembly)
	// Since the assembly was done, return TRUE
	return TRUE



/////////////////////////////// Proximity/igniter /////////////////////////////////////

/obj/item/assembly/prox_ignite
	name = "Proximity/Igniter Assembly"
	desc = "A proximity-activated igniter assembly."
	icon_state = "prox-igniter0"
	var/obj/item/device/prox_sensor/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/reagent_containers/glass/beaker/part3 = null
	var/obj/item/pipebomb/frame/part4 = null
	var/obj/item/pipebomb/bomb/part5 = null
	var/sound_pipebomb = 'sound/weapons/armbomb.ogg'
	status = null
	flags = TABLEPASS | CONDUCT | NOSPLASH

/obj/item/assembly/prox_ignite/dropped()
	. = ..()
	SPAWN( 0 )
		if (src.part1)
			src.part1.sense()
		return
	return

/obj/item/assembly/prox_ignite/New()
	..()
	// Proximity-Igniter Assembly + wired pipebomb -> Proximity-igniter pipebomb
	src.AddComponent(/datum/component/assembly, /obj/item/pipebomb/frame, PROC_REF(pipebomb_frame_assembly), TRUE)
	// Proximity-Igniter Assembly + pipebomb -> Proximity-igniter pipebomb
	src.AddComponent(/datum/component/assembly, /obj/item/pipebomb/bomb, PROC_REF(pipebomb_assembly), TRUE)
	// Proximity-Igniter Assembly + beaker -> Proximity-igniter beakerbomb
	src.AddComponent(/datum/component/assembly, /obj/item/reagent_containers/glass/beaker, PROC_REF(beakerbomb_assembly), TRUE)
	SPAWN(0)
		if(!part1)
			part1 = new(src)
			part1.master = src
		if(!part2)
			part2 = new(src)
			part2.master = src
	return

/obj/item/assembly/prox_ignite/disposing()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	qdel(part3)
	part3 = null
	qdel(part4)
	part4 = null
	qdel(part5)
	part5 = null
	..()

/obj/item/assembly/prox_ignite/c_state(n)
	if(!src.part3 && !src.part5)
		src.icon = 'icons/obj/items/assemblies.dmi'
		src.icon_state = text("prox-igniter[n]")
		src.overlays = null
		src.underlays = null
		src.name = "Proximity/Igniter Assembly"
	else if(!src.part3 && src.part5)
		src.icon = part5.icon
		src.icon_state = part5.icon_state
		src.overlays = null
		src.underlays = null
		src.overlays += image('icons/obj/items/assemblies.dmi', "proxignite_overlay[n]", layer = FLOAT_LAYER)
		src.name = "Proximity/Igniter/Pipebomb Assembly"
	else
		src.icon = part3.icon
		src.icon_state = part3.icon_state
		src.overlays = null
		src.underlays = null
		src.overlays += image('icons/obj/items/assemblies.dmi', "proxignite_overlay[n]", layer = FLOAT_LAYER)
		src.underlays += part3.underlays
		src.name = "Proximity/Igniter/Beaker Assembly"
	return

/obj/item/assembly/prox_ignite/attackby(obj/item/W, mob/user)
	if (!W)
		return
	if (iswrenchingtool(W) && !(src.status))
		var/turf/T = get_turf(src)
		if (part1)
			src.part1.set_loc(T)
			src.part1.master = null
			src.part1 = null

		if (part2)
			src.part2.set_loc(T)
			src.part2.master = null
			src.part2 = null

		if (part3)
			src.part3.set_loc(T)
			src.part3.master = null
			src.part3 = null

		if (part4)
			src.part4.set_loc(T)
			src.part4.master = null
			src.part4 = null
			src.part5.master = null
			src.part5 = null

		if (part5 && !part4)
			src.part5.set_loc(T)
			src.part5.master = null
			src.part5 = null
		user.u_equip(src)
		qdel(src)
		return
	if (!isscrewingtool(W))
		return
	src.status = !(src.status)
	if (src.status)
		user.show_message(SPAN_NOTICE("The proximity sensor is now secured! The igniter now works!"), 1)
	else
		user.show_message(SPAN_NOTICE("The proximity sensor is now unsecured! The igniter will not work."), 1)
	src.add_fingerprint(user)

	return

/obj/item/assembly/prox_ignite/attack_self(mob/user as mob)

	src.part1.AttackSelf(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/prox_ignite/receive_signal()
	if(!src.status)
		return
	for(var/mob/O in hearers(1, src.loc))
		O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)
	src.part2.ignite()
	if(src.part3)
		src.part3.reagents.temperature_reagents(4000, 400)
		src.part3.reagents.temperature_reagents(4000, 400)
	if(src.part5)
		playsound(src.loc, sound_pipebomb, 50, 0)
		SPAWN(3 SECONDS)
			src.part5?.do_explode()
			qdel(src)
	return

/obj/item/assembly/prox_ignite/verb/removebeaker()
	set src in oview(1)
	set name = "remove beaker"
	set category = "Local"

	if (usr.stat || !isliving(usr) || isintangible(usr))
		return

	if(src.part3)
		src.part3.master = null
		src.part3.Attackhand(usr)
		src.part3 = null
		src.c_state(src.part1.timing)
		boutput(usr, SPAN_NOTICE("You remove the Proximity/Igniter assembly from the beaker."))
		//since the assembly is free of beakers, let's add the assembly components again
		// proximity-Igniter Assembly + wired pipebomb -> proximity-igniter pipebomb
		src.AddComponent(/datum/component/assembly, /obj/item/pipebomb/frame, PROC_REF(pipebomb_frame_assembly), TRUE)
		// proximity-Igniter Assembly + pipebomb -> proximity-igniter pipebomb
		src.AddComponent(/datum/component/assembly, /obj/item/pipebomb/bomb, PROC_REF(pipebomb_assembly), TRUE)
		// proximity-Igniter Assembly + beaker -> proximity-igniter beakerbomb
		src.AddComponent(/datum/component/assembly, /obj/item/reagent_containers/glass/beaker, PROC_REF(beakerbomb_assembly), TRUE)
	else boutput(usr, SPAN_ALERT("That doesn't have a beaker attached to it!"))



// proximity-ignite-assemblies

///Beakerbomb-assembly
/obj/item/assembly/prox_ignite/proc/beakerbomb_assembly(var/atom/to_combine_atom, var/mob/user)
	if(src.status)
		boutput(user, "You need to unsecure the timer first.")
		return
	var/obj/item/reagent_containers/glass/beaker/manipulated_beaker = to_combine_atom
	src.part3 = manipulated_beaker
	manipulated_beaker.master = src
	manipulated_beaker.layer = initial(manipulated_beaker.layer)
	user.u_equip(manipulated_beaker)
	manipulated_beaker.set_loc(src)
	src.c_state(0)
	boutput(user, "You attach the proximity/igniter assembly to the beaker.")

	//Since we completed the assembly, remove all assembly components
	src.RemoveComponentsOfType(/datum/component/assembly)
	// Since the assembly was done, return TRUE
	return TRUE

///Pipebomb-assembly out of standard pipebomb
/obj/item/assembly/prox_ignite/proc/pipebomb_assembly(var/atom/to_combine_atom, var/mob/user)
	if(src.status)
		boutput(user, "You need to unsecure the timer first.")
		return
	var/obj/item/pipebomb/bomb/manipulated_pipebomb = to_combine_atom
	src.part5 = manipulated_pipebomb
	manipulated_pipebomb.master = src
	manipulated_pipebomb.layer = initial(manipulated_pipebomb.layer)
	user.u_equip(manipulated_pipebomb)
	manipulated_pipebomb.set_loc(src)
	src.c_state(0)
	boutput(user, "You attach the sensor/igniter assembly to the pipebomb.")
	logTheThing(LOG_BOMBING, user, "made Proximity/Igniter/Beaker Assembly at [log_loc(src)].")
	message_admins("[key_name(user)] made a Proximity/Igniter/Beaker Assembly at [log_loc(src)].")

	//Since we completed the assembly, remove all assembly components
	src.RemoveComponentsOfType(/datum/component/assembly)
	// Since the assembly was done, return TRUE
	return TRUE


///Pipebomb-assembly out of cabled pipebomb
/obj/item/assembly/prox_ignite/proc/pipebomb_frame_assembly(var/atom/to_combine_atom, var/mob/user)
	if(src.status)
		boutput(user, "You need to unsecure the timer first.")
		return
	var/obj/item/pipebomb/frame/manipulated_pipebomb = to_combine_atom
	if(manipulated_pipebomb.state < 4)
		boutput(user, "You have to add reagents and wires to the pipebomb before you can add an igniter.")
		return
	src.part4 = manipulated_pipebomb
	manipulated_pipebomb.master = src
	manipulated_pipebomb.layer = initial(manipulated_pipebomb.layer)
	user.u_equip(manipulated_pipebomb)
	manipulated_pipebomb.set_loc(src)

	src.part5 = new /obj/item/pipebomb/bomb
	src.part5.strength = manipulated_pipebomb.strength
	if (manipulated_pipebomb.material)
		src.part5.setMaterial(manipulated_pipebomb.material)
	//add properties from item mods to the finished pipe bomb
	src.part5.set_up_special_ingredients(manipulated_pipebomb.item_mods)
	user.u_equip(manipulated_pipebomb)
	src.part5 = src.part5
	src.part5.master = src
	src.part5.layer = initial(src.part5.layer)
	src.part5.set_loc(src)
	src.c_state(0)
	boutput(user, "You attach the sensor/igniter assembly to the pipebomb.")
	logTheThing(LOG_BOMBING, user, "made Proximity/Igniter/Pipebomb Assembly at [log_loc(src)].")
	message_admins("[key_name(user)] made a Proximity/Igniter/Pipebomb Assembly at [log_loc(src)].")

	//Since we completed the assembly, remove all assembly components
	src.RemoveComponentsOfType(/datum/component/assembly)
	// Since the assembly was done, return TRUE
	return TRUE

/////////////////////////////////////// Remote signaller/igniter //////////////////////////////////////

/obj/item/assembly/rad_ignite
	name = "Radio/Igniter Assembly"
	desc = "A radio-activated igniter assembly."
	icon_state = "radio-igniter"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/reagent_containers/glass/beaker/part3 = null
	var/obj/item/pipebomb/frame/part4 = null
	var/obj/item/pipebomb/bomb/part5 = null
	var/sound_pipebomb = 'sound/weapons/armbomb.ogg'
	status = null
	flags = TABLEPASS | CONDUCT | NOSPLASH

/obj/item/assembly/rad_ignite/New()
	..()
	// radio-Igniter Assembly + wired pipebomb -> radio-igniter pipebomb
	src.AddComponent(/datum/component/assembly, /obj/item/pipebomb/frame, PROC_REF(pipebomb_frame_assembly), TRUE)
	// radio-Igniter Assembly + pipebomb -> radio-igniter pipebomb
	src.AddComponent(/datum/component/assembly, /obj/item/pipebomb/bomb, PROC_REF(pipebomb_assembly), TRUE)
	// radio-Igniter Assembly + beaker -> radio-igniter beakerbomb
	src.AddComponent(/datum/component/assembly, /obj/item/reagent_containers/glass/beaker, PROC_REF(beakerbomb_assembly), TRUE)
	SPAWN(0)
		if(!part1)
			part1 = new(src)
			part1.master = src
		if(!part2)
			part2 = new(src)
			part2.master = src

/obj/item/assembly/rad_ignite/disposing()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	qdel(part3)
	part3 = null
	qdel(part4)
	part4 = null
	qdel(part5)
	part5 = null
	..()

/obj/item/assembly/rad_ignite/attackby(obj/item/W, mob/user)
	if (!W)
		return
	if (iswrenchingtool(W) && !(src.status))
		var/turf/T = get_turf(src)
		if (part1)
			src.part1.set_loc(T)
			src.part1.master = null
			src.part1 = null

		if (part2)
			src.part2.set_loc(T)
			src.part2.master = null
			src.part2 = null

		if (part3)
			src.part3.set_loc(T)
			src.part3.master = null
			src.part3 = null

		if (part4)
			src.part4.set_loc(T)
			src.part4.master = null
			src.part4 = null
			src.part5.master = null
			src.part5 = null

		if (part5 && !part4)
			src.part5.set_loc(T)
			src.part5.master = null
			src.part5 = null

		user.u_equip(src)
		qdel(src)
		return

	if (!isscrewingtool(W))
		return
	src.status = !(src.status)
	if (src.status)
		user.show_message(SPAN_NOTICE("The radio is now secured! The igniter now works!"), 1)
	else
		user.show_message(SPAN_NOTICE("The radio is now unsecured! The igniter will not work."), 1)
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_ignite/attack_self(mob/user as mob)

	src.part1.AttackSelf(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_ignite/receive_signal()
	if(!src.status)
		return
	for(var/mob/O in hearers(1, src.loc))
		O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)
	if (src.part2)
		src.part2.ignite()
	if(src.part3)
		src.part3.reagents.temperature_reagents(4000, 400)
		src.part3.reagents.temperature_reagents(4000, 400)
	if(src.part5)
		playsound(src.loc, sound_pipebomb, 50, 0)
		SPAWN(3 SECONDS)
			src.part5?.do_explode()
			qdel(src)
	return

/obj/item/assembly/rad_ignite/verb/removebeaker()
	set src in oview(1)
	set name = "remove beaker"
	set category = "Local"

	if (usr.stat || !isliving(usr) || isintangible(usr))
		return

	if(src.part3)
		src.part3.master = null
		src.part3.Attackhand(usr)
		src.part3 = null
		src.c_state()
		boutput(usr, SPAN_NOTICE("You remove the radio/igniter assembly from the beaker."))
		//since the assembly is free of beakers, let's add the assembly components again
		// radio-Igniter Assembly + wired pipebomb -> radio-igniter pipebomb
		src.AddComponent(/datum/component/assembly, /obj/item/pipebomb/frame, PROC_REF(pipebomb_frame_assembly), TRUE)
		// radio-Igniter Assembly + pipebomb -> radio-igniter pipebomb
		src.AddComponent(/datum/component/assembly, /obj/item/pipebomb/bomb, PROC_REF(pipebomb_assembly), TRUE)
		// radio-Igniter Assembly + beaker -> radio-igniter beakerbomb
		src.AddComponent(/datum/component/assembly, /obj/item/reagent_containers/glass/beaker, PROC_REF(beakerbomb_assembly), TRUE)
	else boutput(usr, SPAN_ALERT("That doesn't have a beaker attached to it!"))

/obj/item/assembly/rad_ignite/c_state()
	if(!src.part3 && !src.part5)
		src.icon = 'icons/obj/items/assemblies.dmi'
		src.icon_state = text("radio-igniter")
		src.overlays = null
		src.underlays = null
		src.name = "Radio/Igniter Assembly"
	if(!src.part3 && src.part5)
		src.icon = part5.icon
		src.icon_state = part5.icon_state
		src.overlays = null
		src.underlays = null
		src.overlays += image('icons/obj/items/assemblies.dmi', "radignite_overlay", layer = FLOAT_LAYER)
		src.name = "Radio/Igniter/Pipebomb Assembly"
	else
		src.icon = part3.icon
		src.icon_state = part3.icon_state
		src.overlays = null
		src.underlays = null
		src.overlays += image('icons/obj/items/assemblies.dmi', "radignite_overlay", layer = FLOAT_LAYER)
		src.underlays += part3.underlays
		src.name = "Radio/Igniter/Beaker Assembly"
	return

// proximity-ignite-assemblies
//Oh for fucks sake, why the fuck aren't these under a single parent? I have added these assembly procs three times already.


///Beakerbomb-assembly
/obj/item/assembly/rad_ignite/proc/beakerbomb_assembly(var/atom/to_combine_atom, var/mob/user)
	if(src.status)
		boutput(user, "You need to unsecure the timer first.")
		return
	var/obj/item/reagent_containers/glass/beaker/manipulated_beaker = to_combine_atom
	src.part3 = manipulated_beaker
	manipulated_beaker.master = src
	manipulated_beaker.layer = initial(manipulated_beaker.layer)
	user.u_equip(manipulated_beaker)
	manipulated_beaker.set_loc(src)
	src.c_state()
	boutput(user, "You attach the radio/igniter assembly to the beaker.")

	//Since we completed the assembly, remove all assembly components
	src.RemoveComponentsOfType(/datum/component/assembly)
	// Since the assembly was done, return TRUE
	return TRUE

///Pipebomb-assembly out of standard pipebomb
/obj/item/assembly/rad_ignite/proc/pipebomb_assembly(var/atom/to_combine_atom, var/mob/user)
	if(src.status)
		boutput(user, "You need to unsecure the timer first.")
		return
	var/obj/item/pipebomb/bomb/manipulated_pipebomb = to_combine_atom
	src.part5 = manipulated_pipebomb
	manipulated_pipebomb.master = src
	manipulated_pipebomb.layer = initial(manipulated_pipebomb.layer)
	user.u_equip(manipulated_pipebomb)
	manipulated_pipebomb.set_loc(src)
	src.c_state()
	boutput(user, "You attach the radio/igniter assembly to the pipebomb.")
	logTheThing(LOG_BOMBING, user, "made Radio/Igniter/Pipebomb Assembly at [log_loc(user)].")
	message_admins("[key_name(user)] made a Radio/Igniter/Pipebomb Assembly at [log_loc(user)].")

	//Since we completed the assembly, remove all assembly components
	src.RemoveComponentsOfType(/datum/component/assembly)
	// Since the assembly was done, return TRUE
	return TRUE

///Pipebomb-assembly out of cabled pipebomb
/obj/item/assembly/rad_ignite/proc/pipebomb_frame_assembly(var/atom/to_combine_atom, var/mob/user)
	if(src.status)
		boutput(user, "You need to unsecure the timer first.")
		return
	var/obj/item/pipebomb/frame/manipulated_pipebomb = to_combine_atom
	if(manipulated_pipebomb.state < 4)
		boutput(user, "You have to add reagents and wires to the pipebomb before you can add an igniter.")
		return

	src.part4 = manipulated_pipebomb
	manipulated_pipebomb.master = src
	manipulated_pipebomb.layer = initial(manipulated_pipebomb.layer)
	user.u_equip(manipulated_pipebomb)
	manipulated_pipebomb.set_loc(src)
	src.part5 = new /obj/item/pipebomb/bomb
	src.part5.strength = manipulated_pipebomb.strength
	if (manipulated_pipebomb.material)
		src.part5.setMaterial(manipulated_pipebomb.material)
	//add properties from item mods to the finished pipe bomb
	src.part5.set_up_special_ingredients(manipulated_pipebomb.item_mods)
	user.u_equip(manipulated_pipebomb)
	src.part5 = src.part5
	src.part5.master = src
	src.part5.layer = initial(src.part5.layer)
	src.part5.set_loc(src)
	src.c_state()
	boutput(user, "You attach the radio/igniter assembly to the pipebomb.")
	logTheThing(LOG_BOMBING, user, "made Radio/Igniter/Pipebomb Assembly at [log_loc(user)].")
	message_admins("[key_name(user)] made a Radio/Igniter/Pipebomb Assembly at [log_loc(user)].")


	//Since we completed the assembly, remove all assembly components
	src.RemoveComponentsOfType(/datum/component/assembly)
	// Since the assembly was done, return TRUE
	return TRUE


///////////////////////////////// Health analyzer/igniter /////////////////////////////////////////////

/obj/item/assembly/anal_ignite //lol
	name = "Health-Analyzer/Igniter Assembly"
	desc = "A health-analyzer igniter assembly."
	icon_state = "health-igniter"
	var/obj/item/device/analyzer/healthanalyzer/part1 = null
	var/obj/item/device/igniter/part2 = null
	status = null
	flags = TABLEPASS | CONDUCT
	item_state = "electronic"

/obj/item/assembly/anal_ignite/New()
	..()
	SPAWN(0.5 SECONDS)
		if (src && !src.part1)
			src.part1 = new /obj/item/device/analyzer/healthanalyzer(src)
			src.part1.master = src
		if (src && !src.part2)
			src.part2 = new /obj/item/device/igniter(src)
			src.part2.master = src
	return

/obj/item/assembly/anal_ignite/attackby(obj/item/W, mob/user)
	if (!W)
		return
	if (iswrenchingtool(W) && !(src.status))
		var/turf/T = get_turf(src)
		src.part1.set_loc(T)
		src.part2.set_loc(T)
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null

		user.u_equip(src)
		qdel(src)
		return
	if (isscrewingtool(W))
		src.status = !(src.status)
		if (src.status)
			user.show_message(SPAN_NOTICE("The analyzer is now secured!"), 1)
		else
			user.show_message(SPAN_NOTICE("The analyzer is now unsecured!"), 1)
		src.add_fingerprint(user)
	return

///////////////////////////////////////////////////// Remote signaller/bike horn /////////////////////

/obj/item/assembly/radio_horn
	desc = "A bike horn hastily jammed into a signaller."
	name = "Radio/Horn Assembly"
	icon_state = "radio-horn"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/instrument/bikehorn/part2 = null
	status = 0
	flags = TABLEPASS | CONDUCT

/obj/item/assembly/radio_horn/New()
	..()
	SPAWN(0)
		if(!part1)
			part1 = new(src)
			part1.master = src
		if(!part2)
			part2 = new(src)
			part2.master = src
	return

/obj/item/assembly/radio_horn/disposing()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	..()
	return

/obj/item/assembly/radio_horn/attack_self(mob/user as mob)
	src.part1.AttackSelf(user)
	src.add_fingerprint(user)
	return

/obj/item/assembly/radio_horn/receive_signal()
	var/num_notes = part2.sounds_instrument.len
	part2.play_note(rand(1, num_notes), user = null)
	return

/obj/item/assembly/radio_horn/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		var/turf/T = get_turf(src)
		src.part1.set_loc(T)
		src.part2.set_loc(T)
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null

		user.u_equip(src)
		qdel(src)
		return
	. = ..()

/////////////////////////////////////////////////////// Remote signaller/timer /////////////////////////////////////

/obj/item/assembly/rad_time
	name = "Signaller/Timer Assembly"
	desc = "A radio signaller activated by a count-down timer."
	icon_state = "timer-radio0"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/timer/part2 = null
	status = null
	flags = TABLEPASS | CONDUCT

/obj/item/assembly/rad_time/disposing()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	..()
	return

/obj/item/assembly/rad_time/attackby(obj/item/W, mob/user)
	if (!W)
		return
	if (iswrenchingtool(W) && !(src.status))
		var/turf/T = get_turf(src)
		src.part1.set_loc(T)
		src.part2.set_loc(T)
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		user.u_equip(src)
		qdel(src)
		return
	if (!isscrewingtool(W))
		return
	src.status = !(src.status)
	if (src.status)
		user.show_message(SPAN_NOTICE("The signaler is now secured!"), 1)
	else
		user.show_message(SPAN_NOTICE("The signaler is now unsecured!"), 1)
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_time/attack_self(mob/user as mob)

	src.part1.AttackSelf(user, src.status)
	src.part2.AttackSelf(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_time/receive_signal(datum/signal/signal)
	// drsingh for cannot read null.source
	if (signal && signal.source == src.part2)
		src.part1.send_signal("ACTIVATE")
	return

////////////////////////////////////////////// Remote signaller/proximity //////////////////////////////////

/obj/item/assembly/rad_prox
	name = "Signaller/Prox Sensor Assembly"
	desc = "A proximity-activated radio signaller."
	icon_state = "prox-radio0"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/prox_sensor/part2 = null
	status = null
	flags = TABLEPASS | CONDUCT
	event_handler_flags = USE_FLUID_ENTER

/obj/item/assembly/rad_prox/c_state(n)
	src.icon_state = "prox-radio[n]"
	return

/obj/item/assembly/rad_prox/disposing()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	..()
	return

/obj/item/assembly/rad_prox/EnteredProximity(atom/movable/AM)
	if (istype(AM, /obj/projectile))
		return
	if (AM.move_speed < 12 && src && src.part2)
		src.part2.sense()
	return

/obj/item/assembly/rad_prox/attackby(obj/item/W, mob/user)
	if (!W)
		return
	if (iswrenchingtool(W) && !(src.status))
		var/turf/T = get_turf(src)
		src.part1.set_loc(T)
		src.part2.set_loc(T)
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		user.u_equip(src)
		qdel(src)
		return
	if (!isscrewingtool(W))
		return
	src.status = !(src.status)
	if (src.status)
		user.show_message(SPAN_NOTICE("The proximity sensor is now secured!"), 1)
	else
		user.show_message(SPAN_NOTICE("The proximity sensor is now unsecured!"), 1)
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_prox/attack_self(mob/user as mob)
	src.part1.AttackSelf(user, src.status)
	src.part2.AttackSelf(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_prox/receive_signal(datum/signal/signal)
	// drsingh for Cannot read null.source
	if (signal && signal.source == src.part2)
		src.part1.send_signal("ACTIVATE")
	return

/obj/item/assembly/rad_prox/Move()
	. = ..()
	src.part2.sense()
	return

/obj/item/assembly/rad_prox/dropped()
	. = ..()
	SPAWN( 0 )
		src.part2.sense()
		return
	return


//////////////////////////////////handmade shotgun shells//////////////////////////////////

ABSTRACT_TYPE(/datum/pipeshotrecipe)
/datum/pipeshotrecipe
	var/thingsneeded = null
	var/obj/item/ammo/bullets/result = null
	var/obj/item/accepteditem = null
	var/craftname = null
	var/success = FALSE
	var/allow_subtypes = TRUE

	proc/check_match(obj/item/craftingitem)
		if(allow_subtypes)
			. = istype(craftingitem, accepteditem)
		else
			. = craftingitem.type == accepteditem

	proc/craftwith(obj/item/craftingitem, obj/item/frame, mob/user)

		if (istype(craftingitem, accepteditem))
			//the checks for if an item is actually allowed are local to the recipie, since they can vary
			var/consumed = min(src.thingsneeded, craftingitem.amount)
			thingsneeded -= consumed //ideally we'd do this later but for sake of working with zeros it's up here

			//consume material- proc handles deleting
			var/obj/item/crafting_piece = craftingitem.split_stack(consumed)
			if(crafting_piece)
				crafting_piece.set_loc(frame)
			else
				user.u_equip(craftingitem)
				craftingitem.set_loc(frame)

			if (thingsneeded > 0)//craft successful, but they'll need more
				boutput(user, SPAN_NOTICE("You add [consumed] items to the [frame]. You feel like you'll need [thingsneeded] more [craftname]s to fill all the shells. "))

			if (thingsneeded <= 0) //check completion and produce shells as needed
				var/obj/item/ammo/bullets/shot = new src.result(get_turf(frame))
				user.put_in_hand_or_drop(shot)
				qdel(frame)

			. = TRUE

/datum/pipeshotrecipe/plasglass
	thingsneeded = 2
	result = /obj/item/ammo/bullets/pipeshot/plasglass
	accepteditem = /obj/item/raw_material/shard
	craftname = "shard"
	var/matid = "plasmaglass"

	check_match(obj/item/craftingitem)
		. = ..()
		if(. && matid != craftingitem.material.getID())
			. = FALSE

	craftwith(obj/item/craftingitem, obj/item/frame, mob/user)
		if(matid == craftingitem.material.getID())
			. = ..() //call parent, have them run the typecheck

/datum/pipeshotrecipe/scrap
	thingsneeded = 1
	result = /obj/item/ammo/bullets/pipeshot/scrap
	accepteditem = /obj/item/raw_material/scrap_metal
	craftname = "scrap chunk"

/datum/pipeshotrecipe/glass
	thingsneeded = 2
	result = /obj/item/ammo/bullets/pipeshot/glass
	accepteditem = /obj/item/raw_material/shard
	craftname = "shard"

/datum/pipeshotrecipe/bone
	thingsneeded = 2
	result = /obj/item/ammo/bullets/pipeshot/bone
	accepteditem = /obj/item/material_piece/bone
	craftname = "bone chunk"


/obj/item/assembly/pipehulls
	name = "filled pipe hulls"
	desc = "Four open pipe shells, with propellant in them. You wonder what you could stuff into them."
	icon_state = "Pipeshotrow"
	flags = NOSPLASH
	var/static/list/datum/pipeshotrecipe/recipes_list = list()
	var/datum/pipeshotrecipe/recipe = null

	New()
		..()
		create_reagents(80)
		if(!length(recipes_list))
			for(var/recipe_type in concrete_typesof(/datum/pipeshotrecipe))
				recipes_list += new recipe_type

	attack_self(mob/user as mob)
		if (length(contents) || src.reagents.total_volume)
			if(tgui_alert(user, "Pour out the [src]?", "Empty hulls", list("Yes", "No")) != "Yes")
				return
			boutput(user, SPAN_NOTICE("The contents inside spill out!"))
			for(var/obj/item in contents)
				item.set_loc(get_turf(user))
			if(src.reagents.total_volume)
				src.reagents.reaction(get_turf(user), TOUCH, src.reagents.total_volume)
			recipe = null

	attackby(obj/item/W, mob/user)
		if (!recipe) //no recipie? assign one
			for(var/datum/pipeshotrecipe/R in recipes_list)
				if(R.check_match(W))
					recipe = new R.type()
					break
		if(recipe?.craftwith(W, src, user))
			return //don't bang objects together unless they are wrong...
		..()

