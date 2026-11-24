/datum/element/lifeprocess/breath
	var/static/list/non_breathing_loc_types = list(
		/mob/living/object,
		/mob/living/critter,
		/obj/machinery/atmospherics/unary/cryo_cell,
	)

/datum/element/lifeprocess/breath/process(mob/living/target, mult, datum/gas_mixture/environment)
	if (isdead(target))
		return

	// Manual breathing handling.
	var/datum/component/manual_breathing/manual_breathing = target.GetComponent(/datum/component/manual_breathing)
	if (manual_breathing?.breath_timer > 15)
		return

	var/datum/organ_status/lung/status_updates = new()
	var/atom/underwater = null
	var/bubble_breathing = FALSE

	if (isturf(target.loc))
		var/turf/T = target.loc

		if (istype(T, /turf/space/fluid))
			var/obj/bubble/bubble = locate() in T
			if (bubble?.scale >= 0.4)
				bubble_breathing = TRUE
				environment = bubble.air_contents
			else
				underwater = T

		else if (T.active_liquid)
			var/obj/fluid/F = T.active_liquid

			var/depth = length(global.depth_levels)
			var/depth_to_breathe_from = depth
			if (target.lying)
				depth_to_breathe_from = depth - 1

			if (T.get_gforce_current() <= GFORCE_TRACTION_PARTIAL)
				// You can try to crawl under 0G liquids.
				if (target.lying)
					depth_to_breathe_from = depth
				else
					depth_to_breathe_from = depth - 1

			if (F.amt >= global.depth_levels[depth_to_breathe_from])
				underwater = F
				if (target.is_submerged != 4)
					target.show_submerged_image(4)

		else if (T.active_airborne_liquid)
			var/exception = ismiasmaimmune(target) ? "miasma" : null
			if (!issmokeimmune(target))
				var/obj/fluid/F = T.active_airborne_liquid
				F.force_mob_to_ingest(target, mult, exception)

			else if (!target.clothing_protects_from_chems())
				var/obj/fluid/airborne/F = T.active_airborne_liquid
				F.just_do_the_apply_thing(target, mult, hasmask = TRUE, exception = exception)

	// Mobs can drown in bathtubs.
	else if (istype(target.loc, /obj/machinery/bathtub) && target.lying)
		var/obj/machinery/bathtub/B = target.loc
		if (B.reagents.total_volume > B.suffocation_volume)
			var/obj/fluid/F = new()
			F.reagents = target.loc.reagents
			underwater = F

	// Mobs have no need to breathe in the locs.
	else if (istypes(target.loc, src.non_breathing_loc_types))
		src.update_breath_hud(target, status_updates)
		return

	// Handle mobs that shouldn't take oxygen damage.
	if (ischangeling(target) || HAS_ATOM_PROPERTY(target, PROP_MOB_NO_OXY_LOSS))
		if (target.losebreath)
			target.losebreath = 0
		if (target.get_oxygen_deprivation())
			target.take_oxygen_deprivation(-50 * mult)

		src.update_breath_hud(target, status_updates)
		return

	// Handle mobs that shouldn't take losebreath.
	if (HAS_ATOM_PROPERTY(target, PROP_MOB_NO_LOSEBREATH))
		if (target.losebreath)
			target.losebreath -= (1.3 * mult)

		src.update_breath_hud(target, status_updates)
		return

#ifdef UNDERWATER_MAP
	if (!underwater && isturf(target.loc) && ishuman(target))
		var/turf/T = target.loc
		var/mob/living/carbon/human/H = target
		if (H.mutantrace?.aquatic && (T.turf_flags & FLUID_MOVE)) // asteroid floors on underwater maps are submerged
			src.update_breath_hud(target, status_updates)
			return
#endif

	if (underwater)
		var/mob/living/carbon/human/H = astype(target)
		if (H)
			if (H.mutantrace?.aquatic)
				src.update_breath_hud(target, status_updates)
				return

			if (H.hasStatus("aquabreath"))
				src.update_breath_hud(target, status_updates)
				return

		if (prob(25) && (target.losebreath > 0))
			boutput(target, SPAN_ALERT("You are drowning!"))

	// Handle mask grabs.
	var/datum/gas_mixture/breath = null
	for (var/obj/item/grab/force_mask/mask in target.grabbed_by)
		breath = mask.get_breath(BREATH_VOLUME * mult)
		if (breath)
			break

	if (!breath)
		// Suffocating so do not take a breath.
		if (target.losebreath > 0)
			target.losebreath = max(target.losebreath - (1.3 * mult), 0)

			// High chance of gasping for air.
			if (prob(75))
				if (underwater)
					target.emote("gurgle")
				else
					target.emote("gasp")

			if (target.losebreath <= 0)
				boutput(target, SPAN_NOTICE("You catch your breath."))

		else
			// First, check for air from internal atmosphere (using an air tank and mask generally).
			breath = src.get_breath_from_internal(target, BREATH_VOLUME * mult)
			if (breath)
				underwater = null // Internals override underwater state.

			// Next check whether the target is inside an object.
			else if (isobj(target.loc))
				var/obj/O = target.loc
				breath = O.handle_internal_lifeform(target, BREATH_VOLUME, mult)

			// Otherwise take a breath from the environment.
			else if ((isturf(target.loc) || ismob(target.loc)) && environment)
				breath = environment.remove(TOTAL_MOLES(environment) * BREATH_PERCENTAGE * mult)

	breath?.volume = BREATH_VOLUME * mult

	var/success = src.handle_breath(target, breath, underwater, mult)
	if (breath && success)
		if (bubble_breathing)
			environment.merge(breath)
		else
			target.loc.assume_air(breath)

/// Returns a volume of air from a worn gas tank, if one exists.
/datum/element/lifeprocess/breath/proc/get_breath_from_internal(mob/living/carbon/human/target, volume_needed)
	if (!istype(target) || !target.internal)
		return

	var/obj/item/tank/internal = target.internal
	var/obj/item/clothing/mask/mask = target.wear_mask

	// Ensure that the internals are correctly configured.
	var/is_internals = mask && (mask.c_flags & MASKINTERNALS)
	var/tank_equipped = (internal in target.contents) || (internal in mask)
	if (!is_internals || !tank_equipped)
		internal = null

	// Special handling or medical masks.
	else if (istype(mask, /obj/item/clothing/mask/medical))
		var/datum/gas_mixture/atmosphere = target.loc.return_air()

		// Medical masks don't work in low-atmos environments.
		if (MIXTURE_PRESSURE(atmosphere) < ONE_ATMOSPHERE * 0.5)
			internal = null

		// Medical masks automatically shut off if there's not enough pressure remaining.
		else if (MIXTURE_PRESSURE(internal.air_contents) < internal.distribute_pressure)
			internal = null

	if (!internal)
		target.internals?.icon_state = "internal0"
		target.internal = null
		return

	target.internals?.icon_state = "internal1"

	for (var/obj/ability_button/tank_valve_toggle/toggle in internal.ability_buttons)
		toggle.icon_state = "airon"

	return internal.remove_air_volume(volume_needed)

/// Handle taking a single breath. Returns the number of lungs that took a breath.
/datum/element/lifeprocess/breath/proc/handle_breath(mob/living/target, datum/gas_mixture/breath, atom/underwater, mult)
	var/datum/organ_status/lung/status_updates = new
	var/area/A = get_area(target)

	if (target.nodamage || A.sanctuary)
		src.update_breath_hud(target, status_updates)
		if (target.losebreath)
			target.losebreath = 0
		if (target.get_oxygen_deprivation())
			target.take_oxygen_deprivation(-50 * mult)

		return 0

	if (underwater || !breath || (TOTAL_MOLES(breath) == 0))
		if (istype(target.loc, /turf/space))
			target.take_oxygen_deprivation(6 * mult)
		else
			target.take_oxygen_deprivation(3 * mult)

		status_updates.show_oxy_indicator = TRUE

		// If drowning, consume some reagents.
		if (underwater && ((target.get_oxygen_deprivation() > 40) || (underwater.type == /obj/fluid/airborne)))
			if (istype(underwater, /obj/fluid))
				var/obj/fluid/F = underwater
				F.force_mob_to_ingest(target, mult)

			else if (istype(underwater, /turf/space/fluid))
				var/turf/space/fluid/F = underwater
				F.force_mob_to_ingest(target, mult)

		src.update_breath_hud(target, status_updates)
		return 0

	// The target isn't breathing.
	var/mob/living/carbon/human/H = astype(target)
	if ((target.health < 0) || !H?.organHolder?.get_working_lung_amt())
		src.update_breath_hud(target, status_updates)
		return 0

	return src.take_breath(target, breath, underwater, status_updates, mult)

/datum/element/lifeprocess/breath/proc/take_breath(mob/living/target, datum/gas_mixture/breath, atom/underwater, datum/organ_status/lung/status_updates, mult)
	var/mob/living/carbon/human/H = astype(target)
	var/datum/gas_mixture/left_breath = breath.remove_ratio(0.5)
	var/datum/gas_mixture/right_breath = breath.remove_ratio(1) // 1, because the remaining air now takes up 100% of the breath.
	left_breath.volume = right_breath.volume = breath.volume / 2

	. = 0
	var/datum/organHolder/organ_holder = H?.organHolder
	if (organ_holder)
		if (organ_holder.left_lung && !organ_holder.left_lung.broken)
			. += organ_holder.left_lung.breathe(left_breath, underwater, mult, status_updates)

		if (organ_holder.right_lung && !organ_holder.right_lung.broken)
			. += organ_holder.right_lung.breathe(right_breath, underwater, mult, status_updates)

	breath.merge(left_breath)
	breath.merge(right_breath)

	src.update_breath_hud(target, status_updates)
	if (H)
		for (var/emote in status_updates.emotes)
			H.emote(emote)

/// Updates the HUD of the target.
/datum/element/lifeprocess/breath/proc/update_breath_hud(mob/living/target, datum/organ_status/lung/status_updates)
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		H.hud.update_breathing_indicators(status_updates)

	else if (iscritter(target))
		var/mob/living/critter/C = target
		C.hud.update_breathing_indicators(status_updates)
