// MUST BE IDENTICAL TO ICONSTATE NAMES IN 'icons/obj/machines/medical/dialysis.dmi'.
#define DIALYSIS_TUBING_BAD "tubing-bad"
#define DIALYSIS_TUBING_GOOD "tubing-good"

TYPEINFO(/obj/machinery/medical/blood/dialysis)
	mats = list(
		"metal" = 20,
		"crystal" = 5,
		"conductive_high" = 5
	)

/**
 * # Dialysis Machine
 */
/obj/machinery/medical/blood/dialysis
	name = "dialysis machine"
	desc = "A machine which continuously draws blood from a patient, removes excess chemicals from it, and re-infuses it into the patient."
	icon = 'icons/obj/machines/medical/dialysis.dmi'
	density = 1
	icon_state = "dialysis"
	power_consumption = 1.5 KILO WATTS
	transfer_volume = 16
	hackable = TRUE

	connection_status_effect = "dialysis-machine"

	/// Reagent ID of the current patient's blood.
	var/patient_blood_id = null

/obj/machinery/medical/blood/dialysis/handle_emag(mob/user, obj/item/card/emag/E)
	. = ..()
	src.say("Dialysis protocols inversed.")

/obj/machinery/medical/blood/dialysis/start_failure_feedback()
	. = ..()
	src.say("Failure to start dialysis. Check patient.")

/obj/machinery/medical/blood/dialysis/start_feedback()
	. = ..()
	src.say("Dialysing patient.")

/obj/machinery/medical/blood/dialysis/stop_feedback(reason)
	. = ..()
	src.say("Stopping dialysis.")

/obj/machinery/medical/blood/dialysis/low_power_alert()
	. = ..()
	src.say("Unable to draw power, stopping dialysis.")

/obj/machinery/medical/blood/dialysis/attempt_message(mob/user, mob/living/carbon/new_patient)
	user.tri_message(new_patient,\
		SPAN_NOTICE("<b>[user]</b> begins inserting [src]'s cannulae into [new_patient]."),\
		SPAN_NOTICE("You begin inserting [src]'s cannulae into [new_patient]."),\
		SPAN_NOTICE("<b>[user]</b> begins inserting [src]'s cannulae into you.")\
	)

/obj/machinery/medical/blood/dialysis/add_message(mob/user, mob/living/carbon/new_patient)
	user.tri_message(new_patient,\
		SPAN_NOTICE("<b>[user]</b> inserts [src]'s cannulae into [new_patient]."),\
		SPAN_NOTICE("You insert [src]'s cannulae into [new_patient]."),\
		SPAN_NOTICE("<b>[user]</b> inserts [src]'s cannulae into you.")\
	)

/obj/machinery/medical/blood/dialysis/remove_message(mob/user)
	user.tri_message(src.patient,\
		SPAN_NOTICE("<b>[user]</b> removes [src]'s cannulae from [src.patient]."),\
		SPAN_NOTICE("You remove [src]'s cannulae from [src.patient]."),\
		SPAN_NOTICE("<b>[user]</b> removes [src]'s cannulae from your.")\
	)

/obj/machinery/medical/blood/dialysis/force_remove_feedback()
	var/fluff = pick("pulled", "yanked", "ripped")
	src.patient.visible_message(\
		SPAN_ALERT("<b>[src]'s cannulae get [fluff] out of [src.patient]!</b>"),\
		SPAN_ALERT("<b>[src]'s cannulae get [fluff] out of you!</b>")\
	)

/obj/machinery/medical/blood/dialysis/New()
	..()
	src.UpdateIcon()

/obj/machinery/medical/blood/dialysis/can_affect()
	. = ..()
	if (!src.get_patient_fluid_volume())
		return FALSE

/obj/machinery/medical/blood/dialysis/start_affect()
	..()
	APPLY_ATOM_PROPERTY(patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src, 3)

/obj/machinery/medical/blood/dialysis/affect_patient(mult)
	..()
	src.handle_draw(src.transfer_volume, mult)
	src.screen_blood()
	src.handle_infusion(src.transfer_volume, mult)
	if (src.active && !src.patient.hasStatus("dialysis"))
		src.patient.setStatus("dialysis", INFINITE_STATUS)

/obj/machinery/medical/blood/dialysis/stop_affect(reason = MED_MACHINE_FAILURE)
	if (src.patient)
		if (!src.patient.reagents.is_full())
			src.handle_infusion()
		REMOVE_ATOM_PROPERTY(src.patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src)
		src.patient.delStatus("dialysis")
	..()
	src.UpdateIcon()

/obj/machinery/medical/blood/dialysis/handle_draw(volume, mult)
	..()
	src.update_tubing(DIALYSIS_TUBING_BAD)

/// Re-implemented here due to all the got dang boutputs.
/obj/machinery/medical/blood/dialysis/proc/screen_blood()
	var/list/whitelist_buffer = chem_whitelist + src.patient_blood_id
	for (var/reagent_id in src.reagents.reagent_list)
		var/purge_reagent = FALSE
		if (src.hacked)
			purge_reagent = !purge_reagent
		if (!(reagent_id in whitelist_buffer))
			purge_reagent = !purge_reagent
		if (!purge_reagent)
			continue
		src.reagents.del_reagent(reagent_id)

/obj/machinery/medical/blood/dialysis/handle_infusion(volume, mult)
	// Don't wanna stuff too much blood back in.
	var/patient_blood = src.get_patient_blood_volume()
	var/patient_blood_max = initial(src.patient.blood_volume)
	if (patient_blood > patient_blood_max)
		src.reagents.remove_reagent("blood", (patient_blood - patient_blood_max))
		volume = src.transfer_volume
	src.update_tubing(DIALYSIS_TUBING_GOOD)
	. = ..()
	src.reagents.clear_reagents()

/obj/machinery/medical/blood/dialysis/update_icon(...)
	..()
	if (!src.active || !src.patient)
		src.ClearSpecificOverlays("pump", "screen", DIALYSIS_TUBING_GOOD, DIALYSIS_TUBING_BAD)
		return
	src.UpdateOverlays(image(src.icon, "pump"), "pump")
	src.UpdateOverlays(image(src.icon, "screen"), "screen")

/obj/machinery/medical/blood/dialysis/proc/update_tubing(tube = DIALYSIS_TUBING_BAD)
	var/image/tubing_image = image(src.icon, tube)
	if (src.reagents.total_volume)
		tubing_image.color = src.reagents.get_average_color().to_rgba()
	src.UpdateOverlays(tubing_image, tube)

/obj/machinery/medical/blood/dialysis/add_patient(mob/living/carbon/new_patient, mob/user)
	..()
	src.patient_blood_id = src.patient.blood_id
	src.UpdateIcon()

/obj/machinery/medical/blood/dialysis/remove_patient(mob/user, force = FALSE)
	..()
	src.patient_blood_id = null
	src.UpdateIcon()

#undef DIALYSIS_TUBING_BAD
#undef DIALYSIS_TUBING_GOOD

/datum/statusEffect/medical_machine/dialysis
	id = "dialysis-machine"
	name = "Dialysis Machine"
	desc = "You are connected to a dialysis machine."

/datum/statusEffect/dialysis
	id = "dialysis"
	name = "Dialysis"
	desc = "Your blood is being filtered by a dialysis machine."
	icon_state = "dialysis"
	effect_quality = STATUS_QUALITY_POSITIVE
	unique = TRUE

/datum/statusEffect/dialysed/getTooltip()
	. = "A dialysis machine is filtering your blood, removing toxins and treating the symptoms of liver and kidney failure."
