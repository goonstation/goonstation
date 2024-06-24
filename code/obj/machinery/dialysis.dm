TYPEINFO(/obj/machinery/dialysis)
	mats = list("metal" = 20,
				"crystal" = 5,
				"conductive_high" = 5)
/obj/machinery/dialysis
	name = "dialysis machine"
	desc = "A machine which continuously draws blood from a patient, removes excess chemicals from it, and re-infuses it into the patient."
	icon = 'icons/obj/machines/dialysis.dmi'
#ifdef IN_MAP_EDITOR
	icon_state = "dialysis-map"
#else
	icon_state = "dialysis-base"
#endif
	density = 1
	var/mob/living/carbon/patient
	var/list/whitelist
	// In units per process tick.
	var/draw_amount = 16
	var/hacked = FALSE
	var/last_in = 0
	var/last_out = 0
	var/output_blood_colour
	/// Reagent ID of the current patient's blood.
	var/patient_blood_id

	New()
		..()
		src.create_reagents(100)
		if (!length(chem_whitelist))
			CRASH("[src] tried to fetch the global chem whitelist but it has a length of 0!")
		src.whitelist = chem_whitelist
		src.UpdateIcon()
		UnsubscribeProcess()

	disposing()
		if (src.patient)
			src.stop_dialysis()
		..()

	emag_act(mob/user, obj/item/card/emag/E)
		if (src.hacked) return FALSE
		src.hacked = TRUE
		src.audible_message(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"Dialysis protocols inversed.\""))
		logTheThing(LOG_ADMIN, user, "emagged [src] at [log_loc(user)].")
		logTheThing(LOG_DIARY, user, "emagged [src] at [log_loc(user)].", "admin")
		message_admins("[key_name(usr)] emagged [src] at [log_loc(user)].")

	attack_hand(mob/user)
		src.anchored = !src.anchored
		boutput(user, "You [src.anchored ? "apply" : "release"] \the [src.name]'s brake.")

	get_desc(dist, mob/user)
		..()
		if (src.hacked)
			. += " Something about it seems a little off."
		. += " Its internal blood reservoir is [get_fullness((src.reagents.total_volume / src.reagents.maximum_volume) * 100)]."

	mouse_drop(atom/over_object as mob|obj)
		var/mob/living/carbon/new_patient = over_object
		var/mob/living/user = usr
		if (isliving(user) && iscarbon(new_patient) && can_act(user) && in_interact_range(src, user) && in_interact_range(new_patient, user))
			if (src.patient)
				if (new_patient == src.patient)
					user.tri_message(new_patient,\
					SPAN_NOTICE("<b>[user]</b> removes [src]'s cannulae from [new_patient]'s arm."),\
					SPAN_NOTICE("You remove [src]'s cannulae from [new_patient]'s arm."),\
					SPAN_NOTICE("<b>[user]</b> removes [src]'s cannulae from your arm."))
					return src.stop_dialysis()
				else return boutput(user, SPAN_ALERT("[src] already has a patient attached!"))
			user.tri_message(new_patient,\
			SPAN_NOTICE("<b>[user]</b> begins inserting [src]'s cannulae into [new_patient]'s arm."),\
			SPAN_NOTICE("You begin inserting [src]'s cannulae into [new_patient]'s arm."),\
			SPAN_NOTICE("<b>[user]</b> begins inserting [src]'s cannulae into your arm."))
			logTheThing(LOG_COMBAT, user, "tries to hook up a dialysis machine [log_reagents(src)] to [constructTarget(new_patient,"combat")] at [log_loc(user)].")
			SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, PROC_REF(cannulate), list(new_patient, user), src.icon, "dialysis-map", null, null)
		..()

	process(mult)
		..()
		if (!src.patient || !ishuman(src.patient) || QDELETED(src.patient))
			src.audible_message(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"Patient lost.\""))
			src.stop_dialysis()
			return

		if (!src.patient.blood_volume)
			src.audible_message(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"No blood pressure detected.\""))
			src.stop_dialysis()
			return

		if (!in_interact_range(src, src.patient))
			var/fluff = pick("pulled", "yanked", "ripped")
			src.patient.visible_message(SPAN_ALERT("<b>[src]'s cannulae get [fluff] out of [src.patient]'s arm!</b>"),\
			SPAN_ALERT("<b>[src]'s cannulae get [fluff] out of your arm!</b>"))
			src.audible_message(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"No blood pressure detected.\""))
			src.stop_dialysis()
			return

		// If we're full of blood and can't take anymore on, destroy it all.
		if (src.reagents.is_full())
			src.reagents.clear_reagents()
			src.audible_message(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"Blood buffer has reached maximum capacity. Purging internal reservoir.\""))

		transfer_blood(src.patient, src, src.draw_amount)

		// Re-implemented here due to all the got dang boutputs.
		var/list/whitelist_buffer = src.whitelist + src.patient_blood_id
		for (var/reagent_id in src.reagents.reagent_list)
			if ((!src.hacked && !(reagent_id in whitelist_buffer)) || (src.hacked && (reagent_id in whitelist_buffer)))
				src.reagents.del_reagent(reagent_id)

		src.output_blood_colour = src.reagents.total_volume ? src.reagents.get_average_color().to_rgba() : null

		// Infuse blood back in if possible. Don't wanna stuff too much blood back in.
		// The blood that's not actually in the bloodstream yet, know what I mean?
		var/non_blood_volume_blood = src.patient.reagents.reagent_list["blood"]?.volume || 0
		if (!src.patient.reagents.is_full() && (src.patient.blood_volume + non_blood_volume_blood) <= 500)
			src.reagents.trans_to(src.patient, src.draw_amount)
			src.patient.reagents.reaction(src.patient, INGEST, src.draw_amount)

		src.UpdateIcon()

	update_icon(...)
		..()
		if (src.patient)
			src.UpdateOverlays(image(src.icon, "pump-on"), "pump")
			src.UpdateOverlays(image(src.icon, "screen-on"), "screen")
			src.UpdateOverlays(image(src.icon, "cannulae"), "tubing")

			var/image/blood_out = image(src.icon, "tubing-good[src.output_blood_colour ? "" : "-empty"]")
			if (src.output_blood_colour)
				blood_out.color = src.output_blood_colour
			src.UpdateOverlays(blood_out, "blood_out")

			var/image/blood_in = image(src.icon, "tubing-bad[(src.patient.blood_volume || src.patient.reagents.total_volume) ? "" : "-empty"]")
			if (src.patient.reagents.total_volume)
				blood_in.color = src.patient.reagents.get_average_color().to_rgba()
			else
				blood_in.color = src.patient.blood_color
			src.UpdateOverlays(blood_in, "blood_in")
		else
			src.UpdateOverlays(image(src.icon, "pump-off"), "pump")
			src.UpdateOverlays(image(src.icon, "screen-off"), "screen")
			src.UpdateOverlays(image(src.icon, "tubing"), "tubing")
			src.ClearSpecificOverlays("blood_out")
			src.ClearSpecificOverlays("blood_in")

	proc/cannulate(mob/living/carbon/new_patient, mob/user)
		user.tri_message(new_patient,\
		SPAN_NOTICE("<b>[user]</b> inserts [src]'s cannulae into [new_patient]'s arm."),\
		SPAN_NOTICE("You insert [src]'s cannulae into [new_patient]'s arm."),\
		SPAN_NOTICE("<b>[user]</b> inserts [src]'s cannulae into your arm."))
		logTheThing(LOG_COMBAT, user, "connects a dialysis machine [log_reagents(src)] to [constructTarget(new_patient,"combat")] at [log_loc(user)].")
		src.start_dialysis(new_patient, user)

	proc/start_dialysis(mob/living/carbon/new_patient, mob/user)
		if (!new_patient) return
		if (src.patient)
			return boutput(user, SPAN_ALERT("[src] already has a patient attached!"))
		src.patient = new_patient
		src.patient.setStatus("dialysis", INFINITE_STATUS, src)
		APPLY_ATOM_PROPERTY(patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src, 3)
		src.power_usage = 500
		src.patient_blood_id = src.patient.blood_id
		src.UpdateIcon()
		SubscribeToProcess()

	proc/stop_dialysis()
		UnsubscribeProcess()
		var/list/datum/statusEffect/statuses = src.patient?.getStatusList("dialysis", src) //get our particular status effect
		if (length(statuses))
			src.patient.delStatus(statuses[1])
		REMOVE_ATOM_PROPERTY(patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src)
		src.patient = null
		src.patient_blood_id = null
		src.output_blood_colour = null
		if (src.reagents.total_volume)
			src.reagents.clear_reagents()
			src.audible_message(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"Purging internal reservoir.\""))
		src.power_usage = 0
		src.UpdateIcon()
