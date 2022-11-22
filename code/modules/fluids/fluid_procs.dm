///////////////////
//Turf Procs/Vars//
///////////////////

/turf/var/tmp/obj/fluid/active_liquid

//this is messy!
//this is for turf/space/fluid oceans. Using this in place of turf/canpass() because this one can account for shitt like windows and tables.
/turf/proc/ocean_canpass()
	if( density )
		return 0
	for( var/A in contents )
		var/atom/thing = A
		if (!A)
			continue
		if(IS_SOLID_TO_FLUID(thing) && (thing.density || thing.flags & FLUID_DENSE))
			return 0 // && !istype(thing,/obj/grille) && !istype(thing,/obj/table) && !istype(thing,/obj/structure/girder)) return 0
	return 1

turf/simulated/floor/plating/airless/ocean_canpass()
	.= 0

/turf/selftilenotify()
	if (src.active_liquid && src.active_liquid.group && !src.can_crossed_by(src.active_liquid))
		src.active_liquid.group.displace(src.active_liquid)
	else
		///HEY HEY LOOK AT ME TODO : This is kind of a band-aid. I'm not sure why, but tilenotify() doesn't trigger when it should sometimes. do this to be absolutely sure!
		for (var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			if (!T) continue
			if(T.active_liquid)
				T.active_liquid.blocked_dirs = 0
				if (T.active_liquid.group && !T.active_liquid.group.updating)
					T.active_liquid.group.update_loop()
					break
			if(T.active_airborne_liquid)
				T.active_airborne_liquid.blocked_dirs = 0
				if (T.active_airborne_liquid.group && !T.active_airborne_liquid.group.updating)
					T.active_airborne_liquid.group.update_loop()
					break

	return ..()

/turf/tilenotify()
	if(src.active_liquid)
		src.active_liquid.blocked_dirs = 0
		if (src.active_liquid.group && !src.active_liquid.group.updating)
			src.active_liquid.group.update_loop()
	if(src.active_airborne_liquid)
		src.active_airborne_liquid.blocked_dirs = 0
		if (src.active_airborne_liquid.group && !src.active_airborne_liquid.group.updating)
			src.active_airborne_liquid.group.update_loop()
	return ..()


/// this should happen whenever a liquid reagent hits a simulated tile
/turf/proc/fluid_react(var/datum/reagents/R, var/react_volume, var/airborne = 0, var/index = 0, processing_cleanables=FALSE)
	if (react_volume <= 0) return
	if (!IS_VALID_FLUIDREACT_TURF(src)) return
	if (!index)
		if (airborne)
			for(var/reagent_id in R.reagent_list)
				if (reagent_id in ban_from_airborne_fluid) return
			purge_smoke_blacklist(R)
		else
			for(var/reagent_id in R.reagent_list)
				if (reagent_id in ban_from_fluid) return
	else // We only care about one chem
		var/CI = 1
		if (airborne)
			for(var/reagent_id in R.reagent_list)
				if ( CI++ == index )
					if (reagent_id in ban_from_airborne_fluid) return
			purge_smoke_blacklist(R)
		else
			for(var/reagent_id in R.reagent_list)
				if ( CI++ == index )
					if (reagent_id in ban_from_fluid) return


	var/datum/fluid_group/FG
	var/obj/fluid/F
	var/fluid_and_group_already_exist = 0

	if (airborne)
		if (!src.active_airborne_liquid || QDELETED(src.active_airborne_liquid) || QDELETED(src.active_airborne_liquid.group))
			FG = new /datum/fluid_group/airborne
			F = new /obj/fluid/airborne
			src.active_airborne_liquid = F
			F.set_up(src)
			if (react_volume == 0)
				react_volume = 1
		else
			F = src.active_airborne_liquid
			if (F.group)
				FG = F.group
				fluid_and_group_already_exist = 1
			else
				FG = new /datum/fluid_group/airborne
				if (react_volume == 0)
					react_volume = 1
	else
		if (!src.active_liquid || QDELETED(src.active_liquid) || QDELETED(src.active_liquid.group))
			FG = new
			F = new /obj/fluid
			src.active_liquid = F
			F.set_up(src)
			if (react_volume == 0)
				react_volume = 1
		else
			F = src.active_liquid
			if (F.group)
				FG = F.group
				fluid_and_group_already_exist = 1
			else
				FG = new
				if (react_volume == 0)
					react_volume = 1

	FG.add(F, react_volume, guarantee_is_member = fluid_and_group_already_exist)
	R.trans_to_direct(FG.reagents, react_volume, index=index)
	/*Normally `amt` isn't set until the fluid group process procs, but we sometimes need it right away for mob reactions etc.
	  We know the puddle starts as a single tile, so until then just set `amt` as the total reacted reagent volume. */
	F.amt = FG.reagents.total_volume
	F.UpdateIcon()

	if (!airborne && !processing_cleanables)
		var/turf/simulated/floor/T = src
		if (istype(T) && T.messy > 0)
			var/found_cleanable = 0
			for (var/obj/decal/cleanable/C in T)
				if (istype(T) && !T.cleanable_fluid_react(C, 1)) // Some cleanables need special treatment
					found_cleanable = 1 //there exists a cleanable without a special case
					break
			if (found_cleanable)
				T.cleanable_fluid_react(0,1)

	F.trigger_fluid_enter()

//s/ ame as the above, but using a reagent_id instead of a datum
/turf/proc/fluid_react_single(reagent_name, react_volume, airborne = 0, processing_cleanables=FALSE)
	if (react_volume <= 0) return
	if (!IS_VALID_FLUIDREACT_TURF(src)) return

	if (airborne)
		if (reagent_name in ban_from_airborne_fluid) return
	else
		if (reagent_name in ban_from_fluid) return

	var/datum/fluid_group/FG
	var/obj/fluid/F
	var/fluid_and_group_already_exist = 0


	if (airborne)
		if (!src.active_airborne_liquid)
			FG = new /datum/fluid_group/airborne
			F = new /obj/fluid/airborne
			src.active_airborne_liquid = F
			F.set_up(src)
			if (react_volume == 0)
				react_volume = 1
		else
			F = src.active_airborne_liquid
			if (F.group)
				FG = F.group
				fluid_and_group_already_exist = 1
			else
				FG = new /datum/fluid_group/airborne
				if (react_volume == 0)
					react_volume = 1
	else
		if (!src.active_liquid)
			FG = new
			F = new /obj/fluid
			src.active_liquid = F
			F.set_up(src)
			if (react_volume == 0)
				react_volume = 1
		else
			F = src.active_liquid
			if (F.group)
				FG = F.group
				fluid_and_group_already_exist = 1
			else
				FG = new
				if (react_volume == 0)
					react_volume = 1


	FG.reagents.add_reagent(reagent_name,react_volume)
	FG.add(F, react_volume, guarantee_is_member = fluid_and_group_already_exist)
	F.done_init()
	.= F

	if (!airborne && !processing_cleanables)
		var/turf/simulated/floor/T = src
		if (istype(T) && T.messy > 0)
			var/found_cleanable = 0
			for (var/obj/decal/cleanable/C in T)
				if (istype(T) && !T.cleanable_fluid_react(C, 1))
					found_cleanable = 1
					break
			if (found_cleanable)
				T.cleanable_fluid_react(0,1)

	F.trigger_fluid_enter()


/turf/proc/react_all_cleanables() //Same procedure called in fluid_react and fluid_react_single. copypasted cause i dont wanna proc call overhead up in hea

/turf/simulated/floor/react_all_cleanables() //Same procedure called in fluid_react and fluid_react_single. copypasted cause i dont wanna proc call overhead up in hea
	if (src.messy <= 0) return //hey this is CLEAN so don't even bother looping through contents, thanks!!
	var/found_cleanable = 0
	for (var/obj/decal/cleanable/C in src)
		if (!src.cleanable_fluid_react(C, 1)) // Some cleanables need special treatment
			found_cleanable = 1 //there exists a cleanable without a special case
	if (found_cleanable)
		src.cleanable_fluid_react(0,1)

//called whenever a cleanable is spawned. Returns 1 on success
//grab_any_amount will be True when a fluid spreads onto a tile that may have cleanables on it
/turf/simulated/proc/cleanable_fluid_react(var/obj/decal/cleanable/possible_cleanable = 0, var/grab_any_amount = 0)
	if (!IS_VALID_FLUIDREACT_TURF(src)) return
	//if possible_cleanable has a value, handle exclusively this decal. don't search thru the turf.
	if (possible_cleanable)
		if (possible_cleanable.qdeled || possible_cleanable.disposed) return
		if (istype(possible_cleanable, /obj/decal/cleanable/blood/dynamic))
			var/obj/decal/cleanable/blood/dynamic/blood = possible_cleanable
			var/blood_dna = blood.blood_DNA
			var/blood_type = blood.blood_type
			var/is_tracks = istype(possible_cleanable,/obj/decal/cleanable/blood/dynamic/tracks)
			if(is_tracks)
				return 0
			if (blood.reagents && blood.reagents.total_volume >= 13 || src.active_liquid || grab_any_amount)
				if (blood.reagents)
					var/datum/reagents/R = new(blood.reagents.maximum_volume) //Store reagents, delete cleanable, and then fluid react. prevents recursion
					blood.reagents.copy_to(R)
					var/blood_volume = blood.reagents.total_volume
					blood.clean_forensic()
					src.fluid_react(R,is_tracks ? 0 : blood_volume)
				else
					var/reagent = blood.sample_reagent
					var/amt = blood.reagents.total_volume
					blood.clean_forensic()
					src.fluid_react_single(reagent,is_tracks ? 0 : amt)

				if (src.active_liquid)
					src.active_liquid.blood_DNA = blood_dna
					src.active_liquid.blood_type = blood_type
				return 1
		return 0

	//all right, tally up the cleanables and attempt to call fluid_reacts on them
	var/list/cleanables = list()
	for (var/obj/decal/cleanable/C in src)
		if (C.qdeled || C.disposed) continue
		//if (C.dry) continue
		if (istype(C,/obj/decal/cleanable/blood/dynamic)) continue // handled above
		if (!C.can_fluid_absorb) continue
		cleanables += C

	if (!src.active_liquid && (cleanables.len < 3 && !grab_any_amount))
		return 0	//If the tile has an active liquid already, there is no requirement

	for (var/obj/decal/cleanable/C in cleanables)
		if (C?.reagents)
			for(var/reagent_id in C.reagents.reagent_list)
				if (reagent_id in ban_stacking_into_fluid) return
			var/datum/reagents/R = new(C.reagents.maximum_volume) //Store reagents, delete cleanable, and then fluid react. prevents recursion
			C.reagents.copy_to(R)
			C.clean_forensic()
			src.fluid_react(R, R.total_volume, processing_cleanables=TRUE)
		else if (C?.can_sample && C.sample_reagent)
			if ((!grab_any_amount && (C.sample_reagent in ban_stacking_into_fluid)) || (C.sample_reagent in ban_from_fluid)) return
			var/sample = C.sample_reagent
			var/amt = C.sample_amt
			C.clean_forensic()
			src.fluid_react_single(sample, amt, processing_cleanables=TRUE)
	return 1
