TYPEINFO(/obj/machinery/medical/dialysis)
	mats = list("metal" = 20,
				"crystal" = 5,
				"conductive_high" = 5)

/obj/machinery/medical/dialysis
	name = "dialysis machine"
	desc = "A machine which continuously draws blood from a patient, removes excess chemicals from it, and re-infuses it into the patient."
	icon = 'icons/obj/machines/medical/dialysis.dmi'
	density = 1
#ifdef IN_MAP_EDITOR
	icon_state = "dialysis-map"
#else
	icon_state = "dialysis-base"
#endif
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

	remove_forceful_msg_viewer = "<b>$SRC's cannulae get $FLF out of $TRG's arm!</b>"
	remove_forceful_msg_patient = "<b>$SRC's cannulae get $FLF out of your arm!</b>"

	/// In units per process tick.
	var/draw_amount = 16
	/// Colour is used for fluid image overlay.
	var/output_blood_colour = null
	/// Reagent ID of the current patient's blood.
	var/patient_blood_id = null

/obj/machinery/medical/dialysis/parse_message(text, mob/user, mob/living/carbon/target, self_referential = FALSE)
	text = ..()
	var/fluff = pick("pulled", "yanked", "ripped")
	text = replacetext(text, "$FLF", "[fluff]")
	. = text

/obj/machinery/medical/dialysis/New()
	..()
	src.create_reagents(src.draw_amount)
	src.UpdateIcon()

/obj/machinery/medical/dialysis/disposing()
	if (src.patient)
		src.remove_patient()
	..()

/obj/machinery/medical/dialysis/emag_act(mob/user, obj/item/card/emag/E)
	..()
	src.say("Dialysis protocols inversed.")

/obj/machinery/medical/dialysis/affect_patient(mult)
	..()

	if (!src.patient.blood_volume)
		src.say("No blood pressure detected.")
		src.remove_patient()
		return

	transfer_blood(src.patient, src, (src.draw_amount * max(mult / 10, 1)))

	// Re-implemented here due to all the got dang boutputs.
	var/list/whitelist_buffer = chem_whitelist + src.patient_blood_id
	for (var/reagent_id in src.reagents.reagent_list)
		if ((!src.hacked && !(reagent_id in whitelist_buffer)) || (src.hacked && (reagent_id in whitelist_buffer)))
			src.reagents.del_reagent(reagent_id)

	src.output_blood_colour = src.reagents.total_volume ? src.reagents.get_average_color().to_rgba() : null

	// Infuse blood back in if possible. Don't wanna stuff too much blood back in.
	// The blood that's not actually in the bloodstream yet, know what I mean?
	var/datum/reagent/patient_blood_reagent = src.patient.reagents.reagent_list["blood"]
	var/patient_blood_reagent_volume = patient_blood_reagent?.volume || 0
	var/patient_blood = src.patient.blood_volume + patient_blood_reagent_volume
	var/patient_blood_max = initial(src.patient.blood_volume)
	if (patient_blood > patient_blood_max)
		src.reagents.remove_reagent("blood", (patient_blood - patient_blood_max))

	var/amount_to_draw = min(src.draw_amount, (src.patient.reagents.maximum_volume - src.patient.reagents.total_volume)) * max(mult / 10, 1)
	src.reagents.trans_to(src.patient, amount_to_draw)
	src.patient.reagents.reaction(src.patient, INGEST, amount_to_draw)
	src.reagents.clear_reagents()
	src.UpdateIcon()

/obj/machinery/medical/dialysis/update_icon(...)
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

/obj/machinery/medical/dialysis/add_patient(mob/living/carbon/new_patient, mob/user)
	..()
	src.patient.setStatus("dialysis", INFINITE_STATUS, src)
	src.patient_blood_id = src.patient.blood_id
	APPLY_ATOM_PROPERTY(patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src, 3)
	src.UpdateIcon()

/obj/machinery/medical/dialysis/remove_patient(mob/user, forceful)
	var/list/datum/statusEffect/statuses = src.patient?.getStatusList("dialysis", src) //get our particular status effect
	if (length(statuses))
		src.patient.delStatus(statuses[1])
	REMOVE_ATOM_PROPERTY(patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src)
	src.patient_blood_id = null
	src.output_blood_colour = null
	..()
	src.UpdateIcon()

/datum/statusEffect/dialysis
	id = "dialysis"
	name = "Dialysis"
	desc = "Your blood is being filtered by a dyalysis machine."
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
