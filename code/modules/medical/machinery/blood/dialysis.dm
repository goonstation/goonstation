// MUST BE IDENTICAL TO ICONSTATE NAMES IN 'icons/obj/machines/medical/dialysis.dmi'.
#define DIALYSIS_TUBING_BAD "tubing-bad"
#define DIALYSIS_TUBING_GOOD "tubing-good"

TYPEINFO(/obj/machinery/medical/blood/dialysis)
	mats = list("metal" = 20,
				"crystal" = 5,
				"conductive_high" = 5)

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

	connection_status_effect = "dialysis"

	attempt_msg_viewer = "<b>$USR</b> begins inserting $SRC's cannulae into $TRG."
	attempt_msg_user = "You begin inserting $SRC's cannulae into $TRG."
	attempt_msg_patient = "<b>$USR</b> begins inserting $SRC's cannulae into you."
	add_msg_viewer = "<b>$USR</b> inserts $SRC's cannulae into $TRG."
	add_msg_user = "You insert $SRC's cannulae into $TRG."
	add_msg_patient = "<b>$USR</b> inserts $SRC's cannulae into you."
	remove_msg_viewer = "<b>$USR</b> removes $SRC's cannulae from $TRG."
	remove_msg_user = "You remove $SRC's cannulae from $TRG."
	remove_msg_patient = "<b>$USR</b> removes $SRC's cannulae from your."
	remove_force_msg_viewer = "<b>$SRC's cannulae get $FLUFF out of $TRG!</b>"
	remove_force_msg_patient = "<b>$SRC's cannulae get $FLUFF out of you!</b>"

	hack_msg = "Dialysis protocols inversed."
	low_power_msg = "Unable to draw power, stopping dialysis."
	start_msg = "Dialysing patient."
	stop_msg = "Stopping dialysis."

	/// Reagent ID of the current patient's blood.
	var/patient_blood_id = null

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

/obj/machinery/medical/blood/dialysis/stop_affect(reason = MED_MACHINE_FAILURE)
	if (!src.patient.reagents.is_full())
		src.handle_infusion()
	REMOVE_ATOM_PROPERTY(src.patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src)
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
	id = "dialysis"
	name = "Dialysis"
	desc = "Your blood is being filtered by a dialysis machine."
	icon_state = "dialysis"
	effect_quality = STATUS_QUALITY_POSITIVE

/datum/statusEffect/medical_machine/getTooltip()
	. = "A dialysis machine is filtering your blood, removing toxins and treating the symptoms of liver and kidney failure."
