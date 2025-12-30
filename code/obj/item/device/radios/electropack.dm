#define WIRE_SIGNAL 1
#define WIRE_RECEIVE 2
#define WIRE_TRANSMIT 4

TYPEINFO(/obj/item/device/radio/electropack)
	start_listen_effects = null

/obj/item/device/radio/electropack
	name = "\improper Electropack"
	desc = "A device that, when signaled on the correct frequency, causes a disabling electric shock to be sent to the animal (or human) wearing it."
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "electropack0"
	has_microphone = FALSE
	frequency = FREQ_TRACKING_IMPLANT
	throw_speed = 1
	throw_range = 3
	w_class = W_CLASS_HUGE
	flags = TABLEPASS | CONDUCT
	tool_flags = TOOL_ASSEMBLY_APPLIER
	c_flags = ONBACK
	item_state = "electropack"
	cant_self_remove = TRUE

	var/baseline_arc_power = 2500 //! the amount of Wattage the electropack does provide baseline
	var/required_arc_power = 5000 //! The total of power needed to cause an electric arc with the assembly
	var/code = 2
	var/on = FALSE

/obj/item/device/radio/electropack/New()
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY, PROC_REF(assembly_application))
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, PROC_REF(assembly_setup))
	// Electropack + sec helmet  -> shock kit
	src.AddComponent(/datum/component/assembly, /obj/item/clothing/head/helmet, PROC_REF(shock_kit_assembly), TRUE)

/obj/item/device/radio/electropack/disposing()
	. = ..()
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY)
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP)

/// ----------- Trigger/Applier/Target-Assembly-Related Procs -----------

/obj/item/device/radio/electropack/proc/assembly_setup(var/manipulated_electropack, var/obj/item/assembly/parent_assembly, var/mob/user, var/is_build_in)
	//dangerous assemblies should likely all fall under contraband level 4
	var/electropack_assembly_contraband_level = 4
	// we update the contraband now to reflect the newly added tank
	APPLY_ATOM_PROPERTY(parent_assembly, PROP_MOVABLE_VISIBLE_GUNS, parent_assembly, max(GET_ATOM_PROPERTY(parent_assembly,PROP_MOVABLE_VISIBLE_CONTRABAND), electropack_assembly_contraband_level))
	SEND_SIGNAL(parent_assembly, COMSIG_MOVABLE_CONTRABAND_CHANGED, TRUE)
	// trigger/electropack-Assembly + cell -> trigger/electropack/cell assembly
	parent_assembly.AddComponent(/datum/component/assembly, list(/obj/item/cell), TYPE_PROC_REF(/obj/item/assembly, add_target_item), TRUE)

/obj/item/device/radio/electropack/proc/assembly_application(var/manipulated_electropack, var/obj/item/assembly/parent_assembly, var/obj/assembly_target)
	//give it a bigger cooldown because the effect can be quite severe
	if(!ON_COOLDOWN(src, "electropack_applier", 4 SECONDS))
		//The electropack supplies a baseline power, we then add the cell's power to it
		var/electropack_power = src.baseline_arc_power
		var/obj/item/cell/manipulated_cell = assembly_target
		if(istype(manipulated_cell, /obj/item/cell/erebite))
			parent_assembly.visible_message(SPAN_ALERT("[parent_assembly] violently explodes!"))
			logTheThing(LOG_COMBAT, parent_assembly.last_armer, "'s [parent_assembly] (erebite power cell) went off at [log_loc(src)].")
			var/turf/T = get_turf(src)
			explosion(src, T, 0, 1, 2, 2)
			SPAWN(0.1 SECONDS)
				qdel(parent_assembly)
			return
		if(manipulated_cell)
			electropack_power += manipulated_cell.charge
		// Now we check if we have enough power for an arc flash
		if(electropack_power >= src.required_arc_power)
			var/turf/current_turf = get_turf(src)
			var/atom/target = null
			var/list/target_group = list()
			for(var/mob/iterated_mob in viewers(6, current_turf))
				//We discard any intangible mob
				if(!isintangible(iterated_mob))
					target_group += iterated_mob
			if(!length(target_group))
				//if we don't find any mob in range, we pick a random turf instead
				for(var/turf/iterated_turf in range(6, current_turf))
					target_group += iterated_turf
			// once we have a target group, we pick a target and arcflash them
			target = pick(target_group)
			if(manipulated_cell)
				manipulated_cell.use(electropack_power)
			arcFlash(parent_assembly, target, electropack_power)
		else
			elecflash(get_turf(src),0, power=4, exclude_center = 0)

/// ----------------------------------------------

/obj/item/device/radio/electropack/receive_signal(datum/signal/signal)
	if(istype(src.master, /obj/item/assembly))
		return

	if (!signal || !signal.data || ("[signal.data["code"]]" != "[code]"))
		return

	if (ismob(src.loc) && src.on)
		var/mob/M = src.loc
		if (src == M.back)
			M.show_message(SPAN_ALERT("<B>You feel a sharp shock!</B>"))
			logTheThing(LOG_SIGNALERS, usr, "signalled an electropack worn by [constructTarget(M,"signalers")] at [log_loc(M)].")
			if((M.mind?.get_antagonist(ROLE_REVOLUTIONARY)) && !(M.mind.get_antagonist(ROLE_HEAD_REVOLUTIONARY)) && prob(20))
				M.mind.remove_antagonist(ROLE_REVOLUTIONARY)

#ifdef USE_STAMINA_DISORIENT
			M.do_disorient(200, knockdown = 100, disorient = 60, remove_stamina_below_zero = 0)
#else
			M.changeStatus("knockdown", 10 SECONDS)
#endif

	if (src.master && (src.wires & WIRE_SIGNAL))
		src.master.receive_signal()

/obj/item/device/radio/electropack/update_icon()
	src.icon_state = "electropack[src.on]"

/obj/item/device/radio/electropack/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if (.)
		return

	switch (action)
		if ("set-code")
			var/newcode = text2num_safe(params["value"])
			newcode = round(newcode)
			newcode = clamp(newcode, 1, 100)
			src.code = newcode
			. = TRUE

		if ("toggle-power")
			src.on = !(src.on)
			. = TRUE
			UpdateIcon()

/obj/item/device/radio/electropack/ui_data(mob/user)
	. = ..()
	. += list(
		"code" = src.code,
		"hasToggleButton" = TRUE,
		"power" = src.on
	)

/// Shock kit construction.
/obj/item/device/radio/electropack/proc/shock_kit_assembly(atom/to_combine_atom, mob/user)
	user.u_equip(src)
	user.u_equip(to_combine_atom)
	var/obj/item/shock_kit/new_shock_kit = new /obj/item/shock_kit(get_turf(user), to_combine_atom, src)
	user.put_in_hand_or_drop(new_shock_kit)

	// Since the assembly was done, return TRUE
	return TRUE


#undef WIRE_SIGNAL
#undef WIRE_RECEIVE
#undef WIRE_TRANSMIT
