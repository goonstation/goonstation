/atom/movable/var/tmp/throw_count = 0	  //Counts up for tiles traveled in throw mode. Stacks on diagonals, stacks on stacked throws.
/atom/movable/var/tmp/throw_traveled = 0	//same as above, however if throw_at is provided a source param it will refer to the ACTUAL distance of the throw (dist proc)
/atom/var/tmp/throw_unlimited = 0 //Setting this to 1 before throwing will make the object behave as if in space. //If set on turf, the turf will allow infinite throwing over itself.
/atom/movable/var/tmp/throw_return = 0    //When 1 item will return like a boomerang.
/atom/movable/var/tmp/throw_spin = 1      //If the icon spins while thrown
/atom/movable/var/tmp/throw_pixel = 1		//1 if the pixel vars will be adjusted depending on aiming/mouse params, on impact.
/atom/movable/var/tmp/last_throw_x = 0
/atom/movable/var/tmp/last_throw_y = 0

// returns true if hit
/atom/movable/proc/hit_check()
	if(src.throwing)
		for(var/thing in get_turf(src))
			var/atom/A = thing
			if (!src.throwing)
				break
			if(A == src) continue
			if(isliving(A))
				var/mob/living/L = A
				if (!L.throws_can_hit_me) continue
				if (L.lying) continue
				src.throw_impact(A)
				. = TRUE
			// **TODO: Better behaviour for windows
			// which are dense, but shouldn't always stop movement
			if(isobj(A))
				if(!A.CanPass(src, src.loc, 1.5))
					src.throw_impact(A)
					. = TRUE

/atom/movable/proc/throw_begin(atom/target)

// when an atom gets hit by a thrown object, returns the sound to play
/atom/proc/hitby(atom/movable/AM)
	SHOULD_CALL_PARENT(TRUE)

/atom/movable/proc/throw_end(list/params, turf/thrown_from) //throw ends (callback regardless of whether we impacted something)
	if (throw_pixel && islist(params) && params["icon-y"] && params["icon-x"])
		src.pixel_x = text2num(params["icon-x"]) - 16
		src.pixel_y = text2num(params["icon-y"]) - 16

/atom/movable/proc/throw_impact(atom/hit_atom, list/params)
	var/area/AR = get_area(hit_atom)
	if(AR?.sanctuary)
		return

	src.material?.triggerOnAttack(src, src, hit_atom)
	for(var/atom/A in hit_atom)
		A.material?.triggerOnAttacked(A, src, hit_atom, src)

	if(!hit_atom)
		return

	reagents?.physical_shock(20)
	var/impact_sfx = hit_atom.hitby(src)
	if(src && impact_sfx)
		playsound(src, impact_sfx, 40, 1)

/atom/movable/Bump(atom/O)
	if(src.throwing)
		src.throw_impact(O)
		src.throwing = 0
	..()

/atom/movable/proc/throw_at(atom/target, range, speed, list/params, turf/thrown_from, throw_type = 1, allow_anchored = 0, bonus_throwforce = 0)
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target
	if(!throwing_controller) return
	if(!target) return
	if(src.anchored && !allow_anchored) return
	reagents?.physical_shock(14)
	src.throwing = throw_type

	if (src.throwing & (THROW_CHAIRFLIP | THROW_GUNIMPACT | THROW_SLIP))
		if (ismob(src))
			var/mob/M = src
			M.force_laydown_standup()

	src.throw_traveled = 0
	src.last_throw_x = src.x
	src.last_throw_y = src.y
	src.throw_begin(target)

	src.throwforce += bonus_throwforce

	var/matrix/transform_original = src.transform
	if (src.throw_spin == 1 && !(throwing & THROW_SLIP))
		animate(src, transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = -1)
		animate(transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = -1)
		animate(transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = -1)

	var/turf/targets_turf = get_turf(target)
	var/target_true_x = targets_turf.x
	var/target_true_y = targets_turf.y

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
		return_target = usr, // gross
		bonus_throwforce = bonus_throwforce
	)

	LAZYLISTADD(throwing_controller.thrown, thr)
	throwing_controller.start()
