/datum/component/aquatic_breathing
	/// The current requirement for water, with 0 being none.
	var/water_need = 0
	/// TRUE if the parent entered an area with sufficient water from an area with insufficient water.
	var/in_water_to_out_of_water = FALSE
	/// TRUE if the parent entered an area with insufficient water from an area with sufficient water.
	var/out_of_water_to_in_water = FALSE
	/// Buff amount for being in water.
	var/in_water_buff = 1
	/// Debuff amount for being out of water.
	var/out_of_water_debuff = 1
	/// A callback to be invoked when the parent moves.
	var/datum/callback/on_move = null

TYPEINFO(/datum/component/aquatic_breathing)
	initialization_args = list(
		ARG_INFO("in_water_buff", DATA_INPUT_NUM, "Buff amount for being in water", 1),
		ARG_INFO("out_of_water_debuff", DATA_INPUT_NUM, "Debuff amount for being out of water", 1),
	)

/datum/component/aquatic_breathing/Initialize(in_water_buff = 1, out_of_water_debuff = 1, datum/callback/on_move)
	. = ..()
	if (!ishuman(src.parent) && !ismobcritter(src.parent))
		return COMPONENT_INCOMPATIBLE

	src.in_water_buff = in_water_buff
	src.out_of_water_debuff = out_of_water_debuff
	src.on_move = on_move

	var/mob/M = src.parent
	M.event_handler_flags |= USE_FLUID_ENTER

	src.RegisterSignal(M, COMSIG_ATOM_FLUID_ENTERED, PROC_REF(update_water_status))
	src.RegisterSignal(M, COMSIG_AQUATIC_GET_WATER_NEED, PROC_REF(return_water_need))

	if (ishuman(M))
		src.RegisterSignal(M, COMSIG_LIVING_LIFE_TICK, PROC_REF(process_human))
	else if (ismobcritter(M))
		src.RegisterSignal(M, COMSIG_LIVING_LIFE_TICK, PROC_REF(process_critter))

	if (src.on_move)
		src.RegisterSignal(M, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/component/aquatic_breathing/UnregisterFromParent()
	var/mob/M = src.parent
	M.event_handler_flags &= ~USE_FLUID_ENTER

	src.UnregisterSignal(M, COMSIG_ATOM_FLUID_ENTERED)
	src.UnregisterSignal(M, COMSIG_AQUATIC_GET_WATER_NEED)
	src.UnregisterSignal(M, COMSIG_LIVING_LIFE_TICK)
	src.UnregisterSignal(M, COMSIG_MOVABLE_MOVED)
	. = ..()

/datum/component/aquatic_breathing/proc/return_water_need()
	return src.water_need

/datum/component/aquatic_breathing/proc/process_human(_, mult)
	src.update_water_status()
	var/mob/living/carbon/human/H = src.parent
	if (HAS_ATOM_PROPERTY(H, PROP_MOB_BREATHLESS))
		return

	if (src.water_need)
		if (prob(src.water_need * 50) && !H.nodamage)
			H.take_oxygen_deprivation(src.water_need * 10)
			global.hit_twitch(H)

	else if ((H.max_health > H.health) && prob(src.in_water_buff * 10))
		H.HealDamage("All", src.in_water_buff, src.in_water_buff, 0)
		H.take_oxygen_deprivation(-10)

/datum/component/aquatic_breathing/proc/process_critter(_, mult)
	src.update_water_status()
	var/mob/living/critter/C = src.parent
	if (HAS_ATOM_PROPERTY(C, PROP_MOB_BREATHLESS))
		return

	if (src.water_need)
		if (prob(src.water_need * 50) && !C.nodamage)
			var/datum/healthHolder/brute = C.get_health_holder("brute")
			brute?.TakeDamage(src.water_need * src.out_of_water_debuff)

			var/datum/healthHolder/burn = C.get_health_holder("burn")
			if (burn && !C.is_heat_resistant())
				burn.TakeDamage(src.water_need * src.out_of_water_debuff)

			global.hit_twitch(C)

	else if ((C.max_health > C.health) && prob(src.in_water_buff * 10))
		var/datum/healthHolder/brute = C.get_health_holder("brute")
		if (brute && (brute.maximum_value > brute.value))
			brute.TakeDamage(-src.in_water_buff)

		var/datum/healthHolder/burn = C.get_health_holder("burn")
		if (burn && (burn.maximum_value > burn.value) && !C.is_heat_resistant())
			burn.TakeDamage(-src.in_water_buff)

/datum/component/aquatic_breathing/proc/update_water_status()
	var/mob/M = src.parent
	var/atom/loc = M.loc

	if (istype(loc, /turf/space/fluid))
		if (src.water_need)
			src.water_need = 0
			src.out_of_water_to_in_water = TRUE

		return

	var/turf/T = loc
	if (istype(T) && T.active_liquid)
		if (T.active_liquid.last_depth_level > 3)
			if (src.water_need)
				src.water_need = 0
				src.out_of_water_to_in_water = TRUE

		else if (src.water_need != 1)
			if (!src.water_need)
				src.in_water_to_out_of_water = TRUE

			src.water_need = 1

		return

	if (src.water_need != 2)
		if (!src.water_need)
			src.in_water_to_out_of_water = TRUE

		src.water_need = 2
		return

/datum/component/aquatic_breathing/proc/on_move()
	src.on_move.Invoke(src)
