/atom/var/tmp/throw_unlimited = 0 //Setting this to 1 before throwing will make the object behave as if in space. //If set on turf, the turf will allow infinite throwing over itself.
/atom/movable/var/tmp/throw_return = 0    //When 1 item will return like a boomerang.
/atom/movable/var/tmp/throw_spin = 1      //If the icon spins while thrown
/atom/movable/var/tmp/throw_pixel = 1		//1 if the pixel vars will be adjusted depending on aiming/mouse params, on impact.
/atom/movable/var/tmp/last_throw_x = 0
/atom/movable/var/tmp/last_throw_y = 0

// returns true if hit
/atom/movable/proc/hit_check(datum/thrown_thing/thr)
	for (var/atom/A as anything in get_turf(src))
		if (!src.throwing)
			break
		if(A == src) continue
		if(A.GetComponent(/datum/component/glued)) continue
		if(isliving(A))
			var/mob/living/L = A
			if (!L.throws_can_hit_me) continue
			if (L.lying) continue
			if (L.buckled == src) continue
			src.throw_impact(A, thr)
			if (thr.stops_on_mob_hit)
				. = TRUE
		// **TODO: Better behaviour for windows
		// which are dense, but shouldn't always stop movement
		if(isobj(A))
			if(!A.Cross(src))
				src.throw_impact(A, thr)
				. = TRUE
		//Would be an idea to move all these checks into its own proc so non-humans don't need to check for this
		if(ishuman(src) && istype(A, /obj/item/plant/tumbling_creeper))
			var/obj/item/plant/tumbling_creeper/M = A
			if(M.armed)
				src.throw_impact(M, thr)
				. = TRUE

/atom/movable/proc/throw_begin(atom/target, turf/thrown_from, mob/thrown_by)

// when an atom gets hit by a thrown object, returns the sound to play
/atom/proc/hitby(atom/movable/AM, datum/thrown_thing/thr=null)
	SHOULD_CALL_PARENT(TRUE)

/atom/movable/proc/throw_end(list/params, turf/thrown_from) //throw ends (callback regardless of whether we impacted something)
	if (throw_pixel && islist(params) && params["icon-y"] && params["icon-x"])
		src.pixel_x = text2num(params["icon-x"]) - 16
		src.pixel_y = text2num(params["icon-y"]) - 16

/atom/movable/proc/overwrite_impact_sfx(original_sound, hit_atom, thr)
	. = original_sound

/atom/movable/proc/throw_impact(atom/hit_atom, datum/thrown_thing/thr=null)
	if(src.disposed)
		return TRUE
	var/area/AR = get_area(hit_atom)
	if(AR?.sanctuary)
		return TRUE
	src.material_on_attack_use(thr?.user, hit_atom)
	hit_atom.material_trigger_when_attacked(src, thr?.user, 2)
	if(ismob(hit_atom))
		var/mob/hit_mob = hit_atom
		for(var/atom/A in hit_mob)
			A.material_trigger_on_mob_attacked(thr?.user, hit_atom, src, "chest")
		for(var/atom/A in hit_mob.equipped())
			A.material_trigger_on_mob_attacked(thr?.user, hit_atom, src, "chest")

	if(!hit_atom)
		return TRUE

	src.reagents?.physical_shock(20)
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_HIT_THROWN, hit_atom, thr))
		return
	if(SEND_SIGNAL(hit_atom, COMSIG_ATOM_HITBY_THROWN, src, thr))
		return
	var/impact_sfx = hit_atom.hitby(src, thr)
	impact_sfx = src.overwrite_impact_sfx(impact_sfx,hit_atom, thr)
	if(src && impact_sfx)
		playsound(src, impact_sfx, 40, TRUE)

/atom/movable/bump(atom/O)
	if(src.throwing)
		var/found_any = FALSE
		for(var/datum/thrown_thing/thr as anything in global.throwing_controller.throws_of_atom(src))
			src.throw_impact(O, thr)
			found_any = TRUE
			break // I'd like this to process all relevant datums but something is duplicating throws so it actually sometimes causes a ton of lag
		if(!found_any)
			src.throw_impact(O)
		src.throwing = 0
	..()

/atom/movable/proc/throw_at(atom/target, range, speed, list/params, turf/thrown_from, mob/thrown_by, throw_type = 1,
			allow_anchored = UNANCHORED, bonus_throwforce = 0, datum/callback/end_throw_callback = null)
	SHOULD_CALL_PARENT(TRUE)
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target
	if(!throwing_controller) return
	if(!target) return
	if(src.anchored && !allow_anchored) return
	var/turf/targets_turf = get_turf(target)
	if(!targets_turf)
		return

	reagents?.physical_shock(14)
	src.throwing = throw_type

	if (src.throwing & (THROW_CHAIRFLIP | THROW_GUNIMPACT | THROW_SLIP))
		if (ismob(src))
			var/mob/M = src
			M.force_laydown_standup()

	if (istype(src.loc, /obj/vehicle))
		var/obj/vehicle/V = src.loc
		if (V.can_eject_items)
			src.set_loc(get_turf(V))

	src.last_throw_x = src.x
	src.last_throw_y = src.y
	src.throw_begin(target, thrown_from, thrown_by)

	src.throwforce += bonus_throwforce

	var/matrix/transform_original = src.transform
	if (src.throw_spin && !(throwing & THROW_SLIP) && !(throwing & THROW_PEEL_SLIP))
		animate(src, transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = -1)
		animate(transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = -1)
		animate(transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = -1)

	var/target_true_x = targets_turf.x
	var/target_true_y = targets_turf.y
	if(islist(params))
		params["icon-x"] = text2num(params["icon-x"])
		if(params["icon-x"] > 32)
			target_true_x += round(params["icon-x"] / 32)
			params["icon-x"] = params["icon-x"] % 32
		params["icon-y"] = text2num(params["icon-y"])
		if(params["icon-y"] > 32)
			target_true_y += round(params["icon-y"] / 32)
			params["icon-y"] = params["icon-y"] % 32

	var/dist_x = abs(target_true_x - src.x)
	var/dist_y = abs(target_true_y - src.y)

	var/datum/thrown_thing/thr = new(
		thing = src,
		target = target,
		error = dist_x > dist_y ? dist_x/2 - dist_y : dist_y/2 - dist_x,
		speed = speed,
		dx = target_true_x  > src.x ? EAST : WEST,
		dy = target_true_y  > src.y ? NORTH : SOUTH,
		dist_x = dist_x,
		dist_y = dist_y,
		range = range,
		target_x = target_true_x,
		target_y = target_true_y,
		transform_original = transform_original,
		params = params,
		thrown_from = thrown_from,
		thrown_by = thrown_by,
		return_target = usr, // gross
		bonus_throwforce = bonus_throwforce,
		end_throw_callback = end_throw_callback,
		throw_type = throw_type
	)

	if(isliving(src) && (throwing & THROW_PEEL_SLIP))
		var/mob/living/L = src
		APPLY_ATOM_PROPERTY(L, PROP_MOB_CANTMOVE, "peel_slip_\ref[thr]")

	LAZYLISTADD(throwing_controller.thrown, thr)
	throwing_controller.start()

	return thr
