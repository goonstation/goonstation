ABSTRACT_TYPE(/obj/machinery/medical/blood)
/**
 * # `machinery/medical/blood`
 *
 * Any piece of medical machinery which primarily deals in transfusing blood/reagents in a patient. Contains some relevant helper procs.
 */
/obj/machinery/medical/blood
	/// Units of fluid transferred each tick. Currently for both in and out.
	var/transfer_volume = 16
	/// Assuming there's a single internal reagent container.
	var/maximum_container_volume = 16

/obj/machinery/medical/blood/New()
	. = ..()
	if (!src.connect_directly)
		return
	if (!src.maximum_container_volume)
		return
	src.create_reagents(src.maximum_container_volume)

/// Draws patient blood into internal reagent container.
/obj/machinery/medical/blood/proc/handle_draw(volume, mult)
	if (!src.patient)
		return
	if (!src.get_patient_fluid_volume())
		src.stop_affect()
		return
	if (!isnum(volume))
		return
	transfer_blood(src.patient, src, src.calculate_transfer_volume(src.transfer_volume, mult))

/// Infuses internal reagent container contents to patient.
/obj/machinery/medical/blood/proc/handle_infusion(volume, mult)
	if (!src.patient)
		return
	if (!src.reagents.total_volume)
		return
	if (!isnum(volume))
		return
	if (src.patient.reagents.is_full())
		src.stop_affect()
		return
	var/infusion_volume = src.calculate_transfer_volume(volume, mult)
	src.reagents.trans_to(src.patient, infusion_volume)
	src.patient.reagents.reaction(src.patient, INGEST, infusion_volume)

/// Returns total patient blood volume in units.
/obj/machinery/medical/blood/proc/get_patient_blood_volume()
	. = 0
	if (!iscarbon(src.patient))
		return
	var/datum/reagent/patient_blood_reagent = src.patient.reagents.reagent_list["blood"]
	var/patient_blood_reagent_volume = patient_blood_reagent?.volume || 0
	. = src.patient.blood_volume + patient_blood_reagent_volume

/// Returns total patient fluid volume (blood + all reagents) in units.
/obj/machinery/medical/blood/proc/get_patient_fluid_volume()
	. = 0
	if (!iscarbon(src.patient))
		return
	. = src.patient.blood_volume + src.patient.reagents.total_volume

/// As `mult` is given in deciseconds, it needs to be converted to seconds for transfer volume calculations.
/obj/machinery/medical/blood/proc/calculate_transfer_volume(volume, mult)
	. = volume * max(mult / 10, 1)
