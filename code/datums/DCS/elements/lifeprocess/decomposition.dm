/datum/element/lifeprocess/decomposition
	target_type = /mob/living/carbon/human
	var/static/list/non_decomp_loc_types = list(
		/obj/machinery/atmospherics/unary/cryo_cell,
		/obj/item/reagent_containers/food/snacks/shell,
		/obj/icecube,
	)

/datum/element/lifeprocess/decomposition/process(mob/living/carbon/human/target, datum/gas_mixture/environment)
	if (!isdead(target))
		return

	var/turf/T = get_turf(target)
	if (!T)
		return

	// Handle kudzu infections.
	if ( \
		(T.temp_flags & HAS_KUDZU) && (target.loc == T) && \
		(target.decomp_stage < DECOMP_STAGE_SKELETONIZED) && \
		(!isrestrictedz(T.z) || istype(get_area(T), /area/syndicate_station/hideout)) \
	)
		target.infect_kudzu()

	if (!src.should_decompose(target))
		return

	var/atom/A = target.loc
	if ( \
		!HAS_ATOM_PROPERTY(target, PROP_MOB_NO_MIASMA) && \
		!astype(A, /obj/storage)?.welded && \
		!istype(A, /obj/item/body_bag) && \
		!istype(A, /obj/statue) \
	)
		src.create_miasma(target, T)

	if (environment)
		var/mult = src.get_multiplier(target)
		var/temperature_modifier = (environment.temperature - T20C) / 10
		target.time_until_decomposition -= clamp(2 SECONDS + temperature_modifier, 0, 6 SECONDS) * mult

	if (target.time_until_decomposition < 0)
		target.time_until_decomposition = rand(4 MINUTES, 10 MINUTES)

		target.decomp_stage = min(target.decomp_stage + 1, DECOMP_STAGE_SKELETONIZED)
		target.update_body()
		target.update_face()

/// Whether the target should decompose, based on its properties and environment.
/datum/element/lifeprocess/decomposition/proc/should_decompose(mob/living/carbon/human/target)
	if (!target.mutantrace.decomposes || (target.decomp_stage >= DECOMP_STAGE_SKELETONIZED))
		return FALSE

	if (HAS_ATOM_PROPERTY(target, PROP_MOB_NO_DECOMPOSITION))
		return FALSE

	var/atom/A = target.loc
	if (istypes(A, src.non_decomp_loc_types))
		return FALSE

	if (istype(A, /obj/machinery/traymachine/morgue))
		var/obj/machinery/traymachine/morgue/morgue = A
		if (!(morgue.status & NOPOWER))
			return FALSE

	var/datum/reagents/reagents = target.reagents
	if (reagents && (reagents.has_reagent("formaldehyde") || reagents.has_reagent("miasmosa")))
		return FALSE

	return TRUE

/// Attempt to create a plume of miasma on a turf.
/datum/element/lifeprocess/decomposition/proc/create_miasma(mob/living/carbon/human/target, turf/T)
	var/datum/reagents/reagents = T.active_airborne_liquid?.group?.reagents
	if (reagents && prob(90))
		reagents.get_reagent("miasma")?.flush(reagents, 2)
		if (reagents.total_volume > target.decomp_stage * 20)
			return

	for_by_tcl(IX, /obj/machinery/interdictor)
		if (IX.expend_interdict(15, src, TRUE, ITDR_DEVERA, TRUE))
			return

	T.fluid_react_single("miasma", 3, airborne = TRUE)
