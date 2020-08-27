/datum/thrown_thing
	var/atom/movable/thing
	var/atom/target
	var/error
	var/speed
	var/dx
	var/dy
	var/dist_x
	var/dist_y
	var/range
	var/target_x
	var/target_y
	var/matrix/transform_original
	var/list/params
	var/turf/thrown_from
	var/atom/return_target
	var/bonus_throwforce = 0
	var/hitAThing = FALSE
	var/dist_travelled = 0

	New(atom/movable/thing, atom/target, error, speed, dx, dy, dist_x, dist_y, range,
			target_x, target_y, matrix/transform_original, list/params, turf/thrown_from, atom/return_target,
			bonus_throwforce=0)
		src.thing = thing
		src.target = target
		src.error = error
		src.speed = speed
		src.dx = dx
		src.dy = dy
		src.dist_x = dist_x
		src.dist_y = dist_y
		src.range = range
		src.target_x = target_x
		src.target_y = target_y
		src.transform_original = transform_original
		src.params = params
		src.thrown_from = thrown_from
		src.return_target = return_target
		src.bonus_throwforce = bonus_throwforce
		..()

var/global/datum/controller/throwing/throwing_controller = new

/datum/controller/throwing
	var/global/list/datum/thrown_thing/thrown
	var/running = FALSE

/datum/controller/throwing/proc/start()
	if(src.running)
		return
	src.running = TRUE
	SPAWN_DBG(0)
		while(src.tick())
			sleep(0.1 SECONDS)
		src.running = FALSE

/datum/controller/throwing/proc/tick()
	if(!length(thrown))
		return FALSE
	for(var/_thr in thrown)
		var/datum/thrown_thing/thr = _thr
		var/atom/movable/thing = thr.thing
#if ASS_JAM
		if(thing.throwing_paused)//timestop effect
			continue
#endif
		var/end_throwing = FALSE
		for(var/i in 1 to thr.speed)
			var/turf/T = thing.loc
			if( !(
					thr.target && thing.throwing && isturf(T) && \
						(
							(
								(thr.target_x != thing.x || thr.target_y != thing.y ) && \
								thr.dist_travelled < thr.range
							) || \
							T?.throw_unlimited || \
							thing.throw_unlimited
						)
					))
				end_throwing = TRUE
				break
			var/choose_x = thr.error > 0
			if(thr.dist_y > thr.dist_x) choose_x = !choose_x
			var/turf/next = get_step(thing, choose_x ? thr.dx : thr.dy)
			if(!next || next == T) // going off the edge of the map makes get_step return null, don't let things go off the edge
				end_throwing = TRUE
				break
			thing.glide_size = (32 / (1/thr.speed)) * world.tick_lag
			if (!thing.Move(next))  // Grayshift: Race condition fix. Bump proc calls are delayed past the end of the loop and won't trigger end condition
				thr.hitAThing = TRUE // of !throwing on their own, so manually checking if Move failed as end condition
				end_throwing = TRUE
				break
			thing.glide_size = (32 / (1/thr.speed)) * world.tick_lag
			var/hit_thing = thing.hit_check()
			thr.error += thr.error > 0 ? -min(thr.dist_x, thr.dist_y) : max(thr.dist_x, thr.dist_y)
			thr.dist_travelled++
			thing.throw_count++ // if hit_check stopped us let's end this now
			if(!thing.throwing || hit_thing)
				end_throwing = TRUE
				break

		if(end_throwing)
			thrown -= thr
			animate(thing, transform=thr.transform_original)
			thing.throw_end(thr.params, thrown_from=thr.thrown_from)

			if(thr.hitAThing)
				thr.params = null// if we hit something don't use the pixel x/y from the click params

			thing.throwing = 0
			thing.throw_unlimited = 0

			thing.throw_traveled = thr.dist_travelled //dist traveled is super innacurrate, especially when stacking throws
			if (thr.thrown_from) //if we have this param we should use it to get the REAL distance.
				thing.throw_traveled = get_dist(get_turf(thing), get_turf(thr.thrown_from))

			thing.throw_impact(get_turf(thing), thr.params)

			thing.throw_traveled = 0
			thing.throw_count = 0

			thing.throwforce -= thr.bonus_throwforce

			if(thr.target != thr.return_target && thing.throw_return)
				thing.throw_at(thr.return_target, thing.throw_range, thing.throw_speed)
	return TRUE
