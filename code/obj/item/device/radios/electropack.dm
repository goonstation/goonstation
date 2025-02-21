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
	c_flags = ONBACK
	item_state = "electropack"
	cant_self_remove = TRUE

	var/code = 2
	var/on = FALSE

/obj/item/device/radio/electropack/New()
	. = ..()

	// Electropack + sec helmet  -> shock kit
	src.AddComponent(/datum/component/assembly, /obj/item/clothing/head/helmet, PROC_REF(shock_kit_assembly), TRUE)

/obj/item/device/radio/electropack/receive_signal(datum/signal/signal)
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
