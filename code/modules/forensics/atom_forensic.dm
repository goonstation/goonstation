/atom
	var/tmp/list/fingerprints = null
	var/tmp/list/fingerprints_full = null//new/list()
	var/tmp/fingerprintslast = null
	var/tmp/blood_DNA = null
	var/tmp/blood_type = null
	// only exists because human overlays are a headache, preserves color from add_blood
	var/tmp/forensics_blood_color = null
	//var/list/forensic_info = null
	var/list/forensic_trace = null // list(fprint, bDNA, btype) - can't get rid of this so easy!

/atom/movable
	var/tracked_blood = null // list(bDNA, btype, color, count)

/*
/atom/proc/add_forensic_info(var/key, var/value)
	if (!key || !value)
		return
	if (!islist(src.forensic_info))
		src.forensic_info = list("fprints" = null, "bDNA" = null, "btype" = null)
	src.forensic_info[key] = value

/atom/proc/get_forensic_info(var/key)
	if (!key || !islist(src.forensic_info))
		return 0
	return src.forensic_info[key]
*/
/atom/proc/add_forensic_trace(var/key, var/value)
	if (!key || !value)
		return
	if (!islist(src.forensic_trace))
		src.forensic_trace = list("fprints" = null, "bDNA" = null, "btype" = null)
	src.forensic_trace[key] = value

/atom/proc/get_forensic_trace(var/key)
	if (!key || !islist(src.forensic_trace))
		return 0
	return src.forensic_trace[key]

/// Add a mob's fingerprint to something. If `hidden_only` is TRUE, only add to admin-visible prints.
/atom/proc/add_fingerprint(mob/living/M, hidden_only = FALSE)
	if (!ismob(M) || isnull(M.key))
		return
	if (src.flags & NOFPRINT)
		return
	var/time = time2text(TIME, "hh:mm:ss")
	// The actual print that we save to the player-visible prints list
	var/seen_print
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		LAZYLISTINIT(src.fingerprints)

		if (H.gloves) // Fixed: now adds distorted prints even if 'fingerprintslast == ckey'. Important for the clean_forensic proc (Convair880).
			seen_print = H.gloves.distort_prints(H.bioHolder.fingerprints, TRUE)
		else
			seen_print = H.bioHolder.fingerprints

		if (seen_print && !hidden_only)
			add_fingerprint_direct(seen_print)

	LAZYLISTINIT(src.fingerprints_full)
	if (src.fingerprintslast != M.key) // don't really care about someone spam touching
		src.fingerprints_full[time] = list("key" = M.key, "real_name" = M.real_name, "time" = time, "timestamp" = TIME, "seen_print" = seen_print)
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			src.fingerprints_full[time]["color"] = H.mind.color
		src.fingerprintslast = M.key

/// Add a fingerprint to an atom directly. Doesn't interact with hidden prints at all
/atom/proc/add_fingerprint_direct(print)
	LAZYLISTINIT(src.fingerprints)
	src.fingerprints -= print
	if (length(src.fingerprints) >= 6) // limit fingerprints in the list to 6
		src.fingerprints -= src.fingerprints[1]
	src.fingerprints += print

// WHAT THE ACTUAL FUCK IS THIS SHIT
// WHO THE FUCK WROTE THIS
// maybe better now
/atom/proc/add_blood(atom/source, var/amount = 5)
	var/b_uid = "--unidentified substance--"
	var/b_type = "--unidentified substance--"
	var/blood_color = "#FFFFFF"
	// Null is white so using the default color of red causes issues in cases of white blood

	if (QDELETED(src) || QDELETED(source)) // Be safe
		return

	if (istype(source, /obj/fluid))
		var/obj/fluid/F = source
		blood_color = F.group.average_color.to_rgb()
		var/datum/reagent/blood/blood_reagent = F.group.reagents.reagent_list["blood"]
		if (!blood_reagent)
			blood_reagent = F.group.reagents.reagent_list["bloodc"]
		var/datum/bioHolder/bioholder = blood_reagent?.data
		if (istype(bioholder))
			b_uid = bioholder.Uid
			b_type = bioholder.bloodType
	else if (istype(source, /mob/living))
		var/mob/living/L = source
		if (!L.can_bleed)
			return
		b_uid = L.bioHolder?.Uid
		b_type = L.bioHolder?.bloodType
		if (L.bioHolder?.bloodColor)
			blood_color = L.bioHolder.bloodColor
		else if (L.blood_id)
			var/datum/reagent/R = reagents_cache[L.blood_id]
			blood_color = rgb(R.fluid_r, R.fluid_g, R.fluid_b)
		else
			blood_color = L.blood_color
	else
		if (source.blood_DNA)
			b_uid = source.blood_DNA
		if (source.blood_type)
			b_type = source.blood_type

	if (istype(source, /obj/decal/cleanable))
		var/obj/decal/cleanable/C = source
		if (C.color)
			blood_color = C.color
		else if (C.sample_reagent) // Gibs have no color but do have reagents
			var/datum/reagent/R = reagents_cache[C.sample_reagent]
			blood_color = rgb(R.fluid_r, R.fluid_g, R.fluid_b)

	if (src.blood_DNA)
		var/list/blood_list = params2list(src.blood_DNA)
		blood_list -= b_uid
		if (length(blood_list) >= 6)
			blood_list = blood_list.Copy(blood_list.len - 5, 0)
		blood_list += b_uid
		src.blood_DNA = list2params(blood_list)
		return

	if (isitem(src))
		var/obj/item/I = src
		var/image/blood_overlay = image('icons/obj/decals/blood/blood.dmi', "itemblood")
		blood_overlay.appearance_flags = PIXEL_SCALE | RESET_COLOR
		blood_overlay.color = blood_color
		blood_overlay.alpha = min(blood_overlay.alpha, 200)
		blood_overlay.blend_mode = BLEND_INSET_OVERLAY
		I.appearance_flags |= KEEP_TOGETHER
		I.UpdateOverlays(blood_overlay, "blood_splatter")
		I.blood_DNA = b_uid
		I.blood_type = b_type
		I.forensics_blood_color = blood_color
		if (istype(I, /obj/item/clothing))
			var/obj/item/clothing/C = src
			C.add_stain(/datum/stain/blood)
	else if (istype(src, /turf/simulated))
		if (istype(source, /mob/living))
			var/mob/living/L = source
			bleed(L, amount, 5, rand(1,3), src)
	else if (ishuman(src)) // this will add the blood to their hands or something?
		var/mob/living/carbon/human/H = src
		H.blood_DNA = b_uid
		H.blood_type = b_type
		H.forensics_blood_color = blood_color

// Was clean_blood. Reworked the proc to take care of other forensic evidence as well (Convair880).
/atom/proc/clean_forensic()
	if (!src)
		return
	if (src.flags & NOFPRINT)
		return
	// The first version accidently looped through everything for every atom. Consequently, cleaner grenades caused horrendous lag on my local server. Woops.
	if (!ismob(src)) // Mobs are a special case.
		if (isobj(src))
			var/obj/O = src
			if (O.tracked_blood)
				O.tracked_blood = null
		if (isitem(src) && (src.fingerprints || src.blood_DNA || src.blood_type || src.forensics_blood_color))
			src.add_forensic_trace("fprints", src.fingerprints)
			src.fingerprints = null
			src.add_forensic_trace("btype", src.blood_type)
			src.blood_type = null
			src.forensics_blood_color = null
			if (src.blood_DNA)
				src.add_forensic_trace("bDNA", src.blood_DNA)
				var/obj/item/CI = src
				CI.blood_DNA = null
				CI.UpdateOverlays(null, "blood_splatter")
		if (istype(src, /obj/item/clothing))
			var/obj/item/clothing/C = src
			C.clean_stains()

		else if (istype(src, /obj/decal/cleanable) || istype(src, /obj/reagent_dispensers/cleanable))
			qdel(src)

		else if (isturf(src))
			var/turf/T = get_turf(src)
			for (var/obj/decal/cleanable/mess in T)
				qdel(mess)
			T.messy = 0

		else // Don't think it should clean doors and the like. Give the detective at least something to work with.
			return

	else
		if (isobserver(src) || isintangible(src) || iswraith(src)) // Just in case.
			return

		src.remove_filter(list("paint_color", "paint_pattern")) //wash off any paint

		if (ishuman(src))
			var/mob/living/carbon/human/M = src
			var/list/gear_to_clean = list(M.r_hand, M.l_hand, M.head, M.wear_mask, M.w_uniform, M.wear_suit, M.belt, M.gloves, M.glasses, M.shoes, M.wear_id, M.back)
			for (var/obj/item/check in gear_to_clean)
				if (check.fingerprints || check.blood_DNA || check.blood_type || check.forensics_blood_color)
					check.add_forensic_trace("fprints", check.fingerprints)
					check.fingerprints = null
					check.add_forensic_trace("btype", check.blood_type)
					check.blood_type = null
					check.forensics_blood_color = null
					if (check.blood_DNA)
						check.add_forensic_trace("bDNA", check.blood_DNA)
						check.blood_DNA = null
						check.UpdateOverlays(null, "blood_splatter")
				if (istype(check, /obj/item/clothing))
					var/obj/item/clothing/C = check
					C.clean_stains()

			if (isnull(M.gloves)) // Can't clean your hands when wearing gloves.
				M.add_forensic_trace("bDNA", M.blood_DNA)
				M.blood_DNA = null
				M.add_forensic_trace("btype", M.blood_type)
				M.blood_type = null
				M.forensics_blood_color = null

			M.add_forensic_trace("fprints", M.fingerprints)
			M.fingerprints = null // Foreign fingerprints on the mob.
			M.gunshot_residue = 0 // Only humans can have residue at the moment.
			if (M.makeup || M.spiders || M.blush||M.eyeshadow)
				M.makeup = null
				M.makeup_color = null
				M.spiders = null
				M.blush = null
				M.blush_color = null
				M.eyeshadow = null
				M.eyeshadow_color = null
				M.set_body_icon_dirty()
			M.tracked_blood = null
			M.set_clothing_icon_dirty()

			// Noir effect alters M.color, so reapply
			if (M.bioHolder.HasEffect("noir"))
				animate_fade_grayscale(M, 0)

		else

			var/mob/living/L = src // Punching cyborgs does leave fingerprints for instance.
			L.add_forensic_trace("fprints", L.fingerprints)
			L.fingerprints = null
			L.add_forensic_trace("bDNA", L.blood_DNA)
			L.blood_DNA = null
			L.add_forensic_trace("btype", L.blood_type)
			L.blood_type = null
			L.forensics_blood_color = null
			L.tracked_blood = null
			L.set_clothing_icon_dirty()
	SEND_SIGNAL(src, COMSIG_ATOM_CLEANED)

/atom/movable/proc/track_blood()
	return
/* needs adjustment so let's stick with mobs for now
/obj/track_blood()
	if (!islist(src.tracked_blood))
		return
	var/obj/decal/cleanable/blood/dynamic/B = locate(/obj/decal/cleanable/blood/dynamic) in get_turf(src)
	var/blood_color_to_pass = src.tracked_blood["color"] ? src.tracked_blood["color"] : DEFAULT_BLOOD_COLOR

	if (!B)
		B = make_cleanable( /obj/decal/cleanable/blood/dynamic(get_turf(src))
	B.add_volume(blood_color_to_pass, 1, src.tracked_blood, "smear3", src.last_move)

	src.tracked_blood["count"] --
	if (src.tracked_blood["count"] <= 0)
		src.tracked_blood = null
	return

/obj/item/track_blood()
	if (!islist(src.tracked_blood))
		return
	var/obj/decal/cleanable/blood/dynamic/B = locate(/obj/decal/cleanable/blood/dynamic) in get_turf(src)
	var/blood_color_to_pass = src.tracked_blood["color"] ? src.tracked_blood["color"] : DEFAULT_BLOOD_COLOR

	if (!B)
		B = make_cleanable( /obj/decal/cleanable/blood/dynamic(get_turf(src))
	var/Istate = src.w_class > 4 ? "3" : src.w_class > 2 ? "2" : "1"
	B.add_volume(blood_color_to_pass, 1, src.tracked_blood, Istate, src.last_move)

	src.tracked_blood["count"] --
	if (src.tracked_blood["count"] <= 0)
		src.tracked_blood = null
	return
*/
/mob/living/track_blood()
	if (!islist(src.tracked_blood))
		return
	if (HAS_ATOM_PROPERTY(src, PROP_MOB_BLOOD_TRACKING_ALWAYS) && (tracked_blood["count"] > 0))
		return
	if (HAS_ATOM_PROPERTY(src, PROP_ATOM_FLOATING))
		return
	var/turf/T = get_turf(src)
	if(istype_exact(T, /turf/space)) //can't smear blood on space
		return
	var/obj/decal/cleanable/blood/dynamic/tracks/B = null
	if (T.messy > 0)
		B = locate(/obj/decal/cleanable/blood/dynamic) in T

	var/blood_color_to_pass = src.tracked_blood["color"] ? src.tracked_blood["color"] : DEFAULT_BLOOD_COLOR

	if (!B)
		if (T.active_liquid)
			return
		B = make_cleanable(/obj/decal/cleanable/blood/dynamic/tracks, get_turf(src))
		if(isnull(src.tracked_blood))
			return
		B.set_sample_reagent_custom(src.tracked_blood["sample_reagent"], 0)

	var/list/states = src.get_step_image_states()

	if (!src.lying && (states[1] || states[2]))
		if (states[1])
			B.add_volume(blood_color_to_pass, src.tracked_blood["sample_reagent"], 0.5, 0.5, src.tracked_blood, states[1], src.last_move, 0)
		if (states[2])
			B.add_volume(blood_color_to_pass, src.tracked_blood["sample_reagent"], 0.5, 0.5, src.tracked_blood, states[2], src.last_move, 0)
	else
		B.add_volume(blood_color_to_pass, src.tracked_blood["sample_reagent"], 1, 1, src.tracked_blood, "smear[min (3, round(src.tracked_blood["count"]/2, 1))]", src.last_move, 0)

	if (src.tracked_blood && isnum(src.tracked_blood["count"])) // mirror from below
		src.tracked_blood["count"] --
		if (src.tracked_blood["count"] <= 0)
			src.tracked_blood = null
			src.set_clothing_icon_dirty()
			return
	else
		src.tracked_blood = null
		src.set_clothing_icon_dirty()
		return

/mob/living/proc/get_step_image_states()
	return list("footprints[rand(1,2)]", null)

/mob/living/carbon/human/get_step_image_states()
	return src.limbs ? list(istype(src.limbs.l_leg) ? src.limbs.l_leg.step_image_state : null, istype(src.limbs.r_leg) ? src.limbs.r_leg.step_image_state : null) : list(null, null)

/mob/living/silicon/robot/get_step_image_states()
	return list(istype(src.part_leg_l) ? src.part_leg_l.step_image_state : null, istype(src.part_leg_r) ? src.part_leg_r.step_image_state : null)
