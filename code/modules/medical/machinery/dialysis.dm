#define DIALYSIS_PT_EMPTY "patient_empty"

// MUST BE IDENTICAL TO ICONSTATE NAMES IN 'icons/obj/machines/medical/dialysis.dmi'.
#define DIALYSIS_TUBING_BAD "tubing-bad"
#define DIALYSIS_TUBING_GOOD "tubing-good"

TYPEINFO(/obj/machinery/medical/dialysis)
	mats = list("metal" = 20,
				"crystal" = 5,
				"conductive_high" = 5)

/**
 * # Dialysis Machine
 */
/obj/machinery/medical/dialysis
	name = "dialysis machine"
	desc = "A machine which continuously draws blood from a patient, removes excess chemicals from it, and re-infuses it into the patient."
	icon = 'icons/obj/machines/medical/dialysis.dmi'
	density = 1
	icon_state = "dialysis"
	power_consumption = 1.5 KILO WATTS

	/*
		Bespoke overrides:
		* $FLF -> pick("pulled", "yanked", "ripped")
	*/
	attempt_msg_viewer = "<b>$USR</b> begins inserting $SRC's cannulae into $TRG's arm."
	attempt_msg_user = "You begin inserting $SRC's cannulae into $TRG's arm."
	attempt_msg_patient = "<b>$USR</b> begins inserting $SRC's cannulae into your arm."

	add_msg_viewer = "<b>$USR</b> inserts $SRC's cannulae into $TRG's arm."
	add_msg_user = "You inserts $SRC's cannulae into $TRG's arm."
	add_msg_patient = "<b>$USR</b> inserts $SRC's cannulae into your arm."

	remove_msg_viewer = "<b>$USR</b> removes $SRC's cannulae from $TRG's."
	remove_msg_user = "You removes $SRC's cannulae from $TRG's."
	remove_msg_patient = "<b>$USR</b> removes $SRC's cannulae from your arm."

	remove_force_msg_viewer = "<b>$SRC's cannulae get $FLF out of $TRG's arm!</b>"
	remove_force_msg_patient = "<b>$SRC's cannulae get $FLF out of your arm!</b>"

	/// In units per process tick.
	var/transfer_rate = 16
	/// Reagent ID of the current patient's blood.
	var/patient_blood_id = null

/obj/machinery/medical/dialysis/parse_message(text, mob/user, mob/living/carbon/target, self_referential = FALSE)
	text = ..()
	var/fluff = pick("pulled", "yanked", "ripped")
	text = replacetext(text, "$FLF", "[fluff]")
	. = text

/obj/machinery/medical/dialysis/New()
	..()
	src.create_reagents(src.transfer_rate)
	src.UpdateIcon()

/obj/machinery/medical/dialysis/emag_act(mob/user, obj/item/card/emag/E)
	..()
	src.say("Dialysis protocols inversed.")

/obj/machinery/medical/dialysis/can_affect()
	. = ..()
	if (!src.get_patient_fluid_volume())
		return FALSE

/obj/machinery/medical/dialysis/start_affect()
	..()
	APPLY_ATOM_PROPERTY(patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src, 3)

/obj/machinery/medical/dialysis/start_feedback()
	. = ..()
	src.say("Dialysing patient.")

/obj/machinery/medical/dialysis/affect_patient(mult)
	..()
	src.UpdateIcon()
	src.handle_draw(mult)
	src.screen_blood()
	src.handle_infusion(mult)

/obj/machinery/medical/dialysis/stop_affect(reason = MED_MACHINE_FAILURE)
	src.handle_infusion()
	..()
	REMOVE_ATOM_PROPERTY(src.patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src)
	src.UpdateIcon()
	if (src.is_broken())
		return
	if ((reason == MED_MACHINE_NO_POWER) && !src.low_power_alert_given)
		src.say("Unable to draw power, stopping dialysis.")
		src.low_power_alert_given = TRUE
		return
	if (src.has_no_power())
		return
	src.say("Stopped dialysing patient.")

/// Returns total patient blood volume in units.
/obj/machinery/medical/dialysis/proc/get_patient_blood_volume()
	. = 0
	if (!iscarbon(src.patient))
		return
	var/datum/reagent/patient_blood_reagent = src.patient.reagents.reagent_list["blood"]
	var/patient_blood_reagent_volume = patient_blood_reagent?.volume || 0
	. = src.patient.blood_volume + patient_blood_reagent_volume

/// Returns total patient fluid volume (blood + all reagents) in units.
/obj/machinery/medical/dialysis/proc/get_patient_fluid_volume()
	. = 0
	if (!iscarbon(src.patient))
		return
	. = src.patient.blood_volume + src.patient.reagents.total_volume

/obj/machinery/medical/dialysis/proc/handle_draw(mult)
	if (!src.patient)
		return
	if (!src.get_patient_fluid_volume())
		src.stop_affect()
		return
	transfer_blood(src.patient, src, src.calculate_transfer_volume(src.transfer_rate, mult))
	src.update_tubing(DIALYSIS_TUBING_BAD)

/// Re-implemented here due to all the got dang boutputs.
/obj/machinery/medical/dialysis/proc/screen_blood()
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

/obj/machinery/medical/dialysis/proc/handle_infusion(mult)
	if (!src.patient)
		return
	// Infuse blood back in if possible. Don't wanna stuff too much blood back in.
	var/patient_blood = src.get_patient_blood_volume()
	var/patient_blood_max = initial(src.patient.blood_volume)
	if (patient_blood > patient_blood_max)
		src.reagents.remove_reagent("blood", (patient_blood - patient_blood_max))
	src.update_tubing(DIALYSIS_TUBING_GOOD)
	var/infusion_volume = src.calculate_transfer_volume(src.reagents.total_volume, mult)
	src.reagents.trans_to(src.patient, infusion_volume)
	src.patient.reagents.reaction(src.patient, INGEST, infusion_volume)
	src.reagents.clear_reagents()

/obj/machinery/medical/dialysis/proc/calculate_transfer_volume(volume, mult)
	. = volume * max(mult / 10, 1)

/obj/machinery/medical/dialysis/update_icon(...)
	..()
	var/inoperative = FALSE
	if (!src.patient)
		inoperative = TRUE
		src.ClearSpecificOverlays(DIALYSIS_TUBING_GOOD, DIALYSIS_TUBING_BAD)
	if (!src.active)
		inoperative = TRUE
	if (inoperative)
		src.ClearSpecificOverlays("pump", "screen")
		return
	src.UpdateOverlays(image(src.icon, "pump"), "pump")
	src.UpdateOverlays(image(src.icon, "screen"), "screen")

/obj/machinery/medical/dialysis/proc/update_tubing(tube = DIALYSIS_TUBING_BAD)
	var/image/tubing_image = image(src.icon, tube)
	if (src.reagents.total_volume)
		tubing_image.color = src.reagents.get_average_color().to_rgba()
	src.UpdateOverlays(tubing_image, tube)

/obj/machinery/medical/dialysis/add_patient(mob/living/carbon/new_patient, mob/user)
	..()
	src.patient.setStatus("dialysis", INFINITE_STATUS, src)
	src.patient_blood_id = src.patient.blood_id
	src.UpdateIcon()

/obj/machinery/medical/dialysis/remove_patient(mob/user, force)
	var/list/datum/statusEffect/statuses = src.patient?.getStatusList("dialysis", src)
	if (length(statuses))
		src.patient.delStatus(statuses[1])
	src.patient_blood_id = null
	..()
	src.UpdateIcon()

#undef DIALYSIS_TUBING_BAD
#undef DIALYSIS_TUBING_GOOD

/datum/statusEffect/dialysis
	id = "dialysis"
	name = "Dialysis"
	desc = "Your blood is being filtered by a dialysis machine."
	icon_state = "dialysis"
	unique = FALSE
	effect_quality = STATUS_QUALITY_POSITIVE
	var/obj/machinery/medical/dialysis/dialysis_machine = null

/datum/statusEffect/dialysis/getTooltip()
	. = "A dialysis machine is filtering your blood, removing toxins and treating the symptoms of liver and kidney failure."

/datum/statusEffect/dialysis/onAdd(obj/machinery/medical/dialysis/optional)
	..()
	src.dialysis_machine = optional

/datum/statusEffect/dialysis/onCheck(optional)
	return src.dialysis_machine == optional
