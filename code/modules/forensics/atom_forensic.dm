/atom
	var/tmp/fingerprints = null
	var/tmp/list/fingerprintshidden = null//new/list()
	var/tmp/fingerprintslast = null
	var/tmp/blood_DNA = null
	var/tmp/blood_type = null
	//var/list/forensic_info = null
	var/list/forensic_trace = null // list(fprint, bDNA, btype) - can't get rid of this so easy!

/atom/movable
	var/tracked_blood = null // list(bDNA, btype, color, count)
	var/tracked_mud = null

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

/atom/proc/add_fingerprint(mob/living/M as mob)
	if (!ismob(M) || isnull(M.key))
		return
	if (!( src.flags ) & FPRINT)
		return
	if (!src.fingerprintshidden)
		src.fingerprintshidden = list()

	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		var/list/L = src.fingerprints
		if(isnull(L))
			L = list()

		if (H.gloves) // Fixed: now adds distorted prints even if 'fingerprintslast == ckey'. Important for the clean_forensic proc (Convair880).
			var/gloveprints = H.gloves.distort_prints(H.bioHolder.uid_hash, 1)
			if (!isnull(gloveprints))
				L -= gloveprints
				if (L.len >= 6) //Limit fingerprints in the list to 6
					L.Cut(1,2)
				L += gloveprints
				src.fingerprints = L

			if(src.fingerprintslast != H.key)
				src.fingerprintshidden += "(Wearing gloves). Real name: [H.real_name], Key: [H.key], Time: [time2text(world.timeofday, "hh:mm:ss")]"
				src.fingerprintslast = H.key

			return 0

		if (!( src.fingerprints ))
			src.fingerprints = list("[H.bioHolder.uid_hash]")
			if(src.fingerprintslast != H.key)
				src.fingerprintshidden += "Real name: [H.real_name], Key: [H.key], Time: [time2text(world.timeofday, "hh:mm:ss")]"
				src.fingerprintslast = H.key

			return 1

		else
			L -= H.bioHolder.uid_hash
			while(L.len >= 6) // limit the number of fingerprints to 6, previously 3
				L -= L[1]
			L += H.bioHolder.uid_hash
			src.fingerprints = L
			if(src.fingerprintslast != H.key)
				src.fingerprintshidden += "Real name: [H.real_name], Key: [H.key], Time: [time2text(world.timeofday, "hh:mm:ss")]"
				src.fingerprintslast = H.key

	else
		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += "Real name: [M.real_name], Key: [M.key], Time: [time2text(world.timeofday, "hh:mm:ss")]"
			src.fingerprintslast = M.key

	return

// WHAT THE ACTUAL FUCK IS THIS SHIT
// WHO THE FUCK WROTE THIS
/atom/proc/add_blood(mob/living/M as mob, var/amount = 5)
//	if (!( isliving(M) ) || !M.blood_id)
//		return 0
	if (!( src.flags ) & FPRINT)
		return
	var/b_uid = "--unidentified substance--"
	var/b_type = "--unidentified substance--"
	if (isliving(M) && M.bioHolder)
		b_uid = M.bioHolder.Uid
		b_type = M.bioHolder.bloodType
	else
		if (M.blood_DNA)
			b_uid = M.blood_DNA
		if (M.blood_type)
			b_type = M.blood_type
	if (!( src.blood_DNA ))
		if (isitem(src))
			var/obj/item/I = src
			var/datum/reagent/R
			if (isliving(M))
				R = reagents_cache[M.blood_id]
			var/icon/new_icon
			if (I.uses_multiple_icon_states)
				new_icon = new /icon(I.icon)
			else
				new_icon = new /icon(I.icon, I.icon_state)
			new_icon.Blend(new /icon('icons/effects/blood.dmi', "thisisfuckingstupid"), ICON_ADD)
			if (R)
				new_icon.Blend(rgb(R.fluid_r, R.fluid_g, R.fluid_b), ICON_MULTIPLY)
			else
				new_icon.Blend(DEFAULT_BLOOD_COLOR, ICON_MULTIPLY)
			new_icon.Blend(new /icon('icons/effects/blood.dmi', "itemblood"), ICON_MULTIPLY)
			if (I.uses_multiple_icon_states)
				new_icon.Blend(new /icon(I.icon), ICON_UNDERLAY)
			else
				new_icon.Blend(new /icon(I.icon, I.icon_state), ICON_UNDERLAY)
			I.icon = new_icon
			I.blood_DNA = b_uid
			I.blood_type = b_type
			if (istype(I, /obj/item/clothing))
				var/obj/item/clothing/C = src
				C.add_stain("blood-stained")
		else if (istype(src, /turf/simulated))
			bleed(M, amount, 5, rand(1,3), src)
		else if (ishuman(src)) // this will add the blood to their hands or something?
			src.blood_DNA = b_uid
			src.blood_type = b_type
		else
			return
	else
		var/list/L = params2list(src.blood_DNA)
		L -= b_uid
		while(L.len >= 6) // Increased from 3 (Convair880).
			L -= L[1]
		L += b_uid
		src.blood_DNA = list2params(L)
	return

// Was clean_blood. Reworked the proc to take care of other forensic evidence as well (Convair880).
/atom/proc/clean_forensic()
	if (!src)
		return

	if (!( src.flags ) & FPRINT)
		return

	// The first version accidently looped through everything for every atom. Consequently, cleaner grenades caused horrendous lag on my local server. Woops.
	if (!ismob(src)) // Mobs are a special case.
		if (isobj(src))
			var/obj/O = src
			if (O.tracked_blood)
				O.tracked_blood = null
		if (isitem(src) && (src.fingerprints || src.blood_DNA || src.blood_type))
			src.add_forensic_trace("fprints", src.fingerprints)
			src.fingerprints = null
			src.add_forensic_trace("btype", src.blood_type)
			src.blood_type = null
			if (src.blood_DNA)
				src.add_forensic_trace("bDNA", src.blood_DNA)
				var/obj/item/CI = src
				CI.blood_DNA = null
				CI.icon = initial(icon)

		else if (istype(src, /obj/decal/cleanable) || istype(src, /obj/reagent_dispensers/cleanable))
			pool(src)

		else if (isturf(src))
			//src.overlays = null
			var/turf/T = get_turf(src)
			for (var/obj/decal/cleanable/mess in T)
				pool(mess)
			T.messy = 0

		else // Don't think it should clean doors and the like. Give the detective at least something to work with.
			return

	else
		if (isobserver(src) || isintangible(src) || iswraith(src)) // Just in case.
			return

		if (src.color) //wash off paint! might be dangerous, so possibly move this check into humans only if it causes problems with critters
			src.color = initial(src.color)

		if (ishuman(src))
			var/mob/living/carbon/human/M = src
			var/list/gear_to_clean = list(M.r_hand, M.l_hand, M.head, M.wear_mask, M.w_uniform, M.wear_suit, M.belt, M.gloves, M.glasses, M.shoes, M.wear_id, M.back)
			for (var/obj/item/check in gear_to_clean)
				if (check.fingerprints || check.blood_DNA || check.blood_type)
					check.add_forensic_trace("fprints", check.fingerprints)
					check.fingerprints = null
					check.add_forensic_trace("btype", check.blood_type)
					check.blood_type = null
					if (check.blood_DNA)
						check.add_forensic_trace("bDNA", check.blood_DNA)
						check.blood_DNA = null
						check.icon = initial(check.icon)

			if (isnull(M.gloves)) // Can't clean your hands when wearing gloves.
				M.add_forensic_trace("bDNA", M.blood_DNA)
				M.blood_DNA = null
				M.add_forensic_trace("btype", M.blood_type)
				M.blood_type = null

			M.add_forensic_trace("fprints", M.fingerprints)
			M.fingerprints = null // Foreign fingerprints on the mob.
			M.gunshot_residue = 0 // Only humans can have residue at the moment.
			if (M.makeup || M.spiders)
				M.makeup = null
				M.makeup_color = null
				M.spiders = null
				M.set_body_icon_dirty()
			M.tracked_blood = null
			M.set_clothing_icon_dirty()

		else

			var/mob/living/L = src // Punching cyborgs does leave fingerprints for instance.
			L.add_forensic_trace("fprints", L.fingerprints)
			L.fingerprints = null
			L.add_forensic_trace("bDNA", L.blood_DNA)
			L.blood_DNA = null
			L.add_forensic_trace("btype", L.blood_type)
			L.blood_type = null
			L.tracked_blood = null
			L.set_clothing_icon_dirty()

	return

/atom/movable/proc/track_blood()
	return
/atom/movable/proc/track_mud()
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
	var/turf/T = get_turf(src)
	var/obj/decal/cleanable/blood/dynamic/tracks/B = null
	if (T.messy > 0)
		B = locate(/obj/decal/cleanable/blood/dynamic) in T

	var/blood_color_to_pass = src.tracked_blood["color"] ? src.tracked_blood["color"] : DEFAULT_BLOOD_COLOR

	if (!B)
		if (T.active_liquid)
			return
		B = make_cleanable( /obj/decal/cleanable/blood/dynamic/tracks,get_turf(src))
		B.set_sample_reagent_custom(src.tracked_blood["sample_reagent"],0)

	B.add_volume(blood_color_to_pass, src.tracked_blood["sample_reagent"], 1, 0, src.tracked_blood, "footprints[rand(1,2)]", src.last_move, 0)

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

/mob/living/carbon/human/track_blood()
	if (!islist(src.tracked_blood))
		return

	var/turf/T = get_turf(src)
	var/obj/decal/cleanable/blood/dynamic/tracks/B = null
	if (T.messy > 0)
		B = locate(/obj/decal/cleanable/blood/dynamic) in T

	var/blood_color_to_pass = src.tracked_blood["color"] ? src.tracked_blood["color"] : DEFAULT_BLOOD_COLOR

	if (!B)
		if (T.active_liquid)
			return
		B = make_cleanable( /obj/decal/cleanable/blood/dynamic/tracks,get_turf(src))
		if (B)
			B.set_sample_reagent_custom(src.tracked_blood["sample_reagent"],0)
		else
			return //must have been consumed by a fluid? this might be unnecessary...

	if (src.limbs)
		var/Lstate = istype(src.limbs.l_leg) ? src.limbs.l_leg.step_image_state : null
		var/Rstate = istype(src.limbs.r_leg) ? src.limbs.r_leg.step_image_state : null
		if (Lstate || Rstate)
			if (Lstate)
				B.add_volume(blood_color_to_pass, src.tracked_blood["sample_reagent"], 0.5, 0.5, src.tracked_blood, Lstate, src.last_move, 0)
			if (Rstate)
				B.add_volume(blood_color_to_pass, src.tracked_blood["sample_reagent"], 0.5, 0.5, src.tracked_blood, Rstate, src.last_move, 0)
		else
			B.add_volume(blood_color_to_pass, src.tracked_blood["sample_reagent"], 1, 1, src.tracked_blood, "smear2", src.last_move, 0)

	if (src.tracked_blood && isnum(src.tracked_blood["count"])) // maybe this will fix the bad index runtime PART
		src.tracked_blood["count"] --
		if (src.tracked_blood["count"] <= 0)
			src.tracked_blood = null
			src.set_clothing_icon_dirty()
			return
	else
		src.tracked_blood = null
		src.set_clothing_icon_dirty()
		return

/mob/living/silicon/robot/track_blood()
	if (!islist(src.tracked_blood))
		return

	var/turf/T = get_turf(src)
	var/obj/decal/cleanable/blood/dynamic/tracks/B = T.messy ? (locate(/obj/decal/cleanable/blood/dynamic/tracks) in T) : 0
	var/blood_color_to_pass = src.tracked_blood["color"] ? src.tracked_blood["color"] : DEFAULT_BLOOD_COLOR

	if (!B)
		if (T.active_liquid)
			return
		B = make_cleanable( /obj/decal/cleanable/blood/dynamic/tracks,get_turf(src))
		if (B)
			B.set_sample_reagent_custom(src.tracked_blood["sample_reagent"],0)
		else
			return

	var/Lstate = istype(src.part_leg_l) ? src.part_leg_l.step_image_state : null
	var/Rstate = istype(src.part_leg_r) ? src.part_leg_r.step_image_state : null

	if (Lstate || Rstate)
		if (Lstate)
			B.add_volume(blood_color_to_pass, src.tracked_blood["sample_reagent"], 0.5, 0.5, src.tracked_blood, Lstate, src.last_move, 0)
		if (Rstate)
			B.add_volume(blood_color_to_pass, src.tracked_blood["sample_reagent"], 0.5, 0.5, src.tracked_blood, Rstate, src.last_move, 0)
	else
		B.add_volume(blood_color_to_pass, src.tracked_blood["sample_reagent"], 1, 1, src.tracked_blood, "smear2", src.last_move, 0)

	if (src.tracked_blood && isnum(src.tracked_blood["count"])) //mirror from above
		src.tracked_blood["count"] --
		if (src.tracked_blood["count"] <= 0)
			src.tracked_blood = null
			src.set_clothing_icon_dirty()
			return
	else
		src.tracked_blood = null
		src.set_clothing_icon_dirty()
		return
