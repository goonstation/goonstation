/atom/var/throw_count = 0	  //Counts up for tiles traveled in throw mode. Stacks on diagonals, stacks on stacked throws.
/atom/var/throw_traveled = 0	//same as above, however if throw_at is provided a source param it will refer to the ACTUAL distance of the throw (dist proc)
/atom/var/throw_unlimited = 0 //Setting this to 1 before throwing will make the object behave as if in space. //If set on turf, the turf will allow infinite throwing over itself.
/atom/var/throw_return = 0    //When 1 item will return like a boomerang.
/atom/var/throw_spin = 1      //If the icon spins while thrown
/atom/var/throw_pixel = 1		//1 if the pixel vars will be adjusted depending on aiming/mouse params, on impact.
/atom/var/last_throw_x = 0
/atom/var/last_throw_y = 0
/mob/var/gib_flag = 0 	      //Sorry about this.

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
				src.throwing = 0
			// **TODO: Better behaviour for windows
			// which are dense, but shouldn't always stop movement
			if(isobj(A))
				if(!A.CanPass(src, src.loc, 1.5))
					src.throw_impact(A)
					src.throwing = 0


/atom/proc/throw_begin(atom/target)
	return

/atom/proc/throw_end(list/params) //throw ends (callback regardless of whether we impacted something)
	return

/atom/movable/proc/throw_impact(atom/hit_atom, list/params)
	var/turf/t = get_turf(hit_atom)
	if( t && t.loc && t.loc:sanctuary ) return
	var/impact_sfx = 0

	if (isliving(hit_atom))
		impact_sfx = 'sound/impact_sounds/Generic_Hit_2.ogg'

		if(iscarbon(hit_atom))
			var/mob/living/carbon/human/C = hit_atom //fuck you, monkeys
			var/turf/T = get_turf(C)
			var/turf/U = get_step(C, C.dir)


			if(C && istype(src, /atom/movable))
				var/atom/movable/A = src
				if (C.find_type_in_hand(/obj/item/bat))
					if (prob(1))
						A.throw_at(get_edge_target_turf(C,get_dir(C, U)), 50, 60)
						playsound(T, 'sound/items/woodbat.ogg', 50, 1)
						playsound(T, 'sound/items/batcheer.ogg', 50, 1)
						C.visible_message("<span class='alert'>[C] hits the [src.name] with the bat and scores a HOMERUN! Woah!!!!</span>")
					else
						A.throw_at(get_edge_target_turf(C,get_dir(C, U)), 50, 25)
						playsound(T, 'sound/items/woodbat.ogg', 50, 1)
						C.visible_message("<span class='alert'>[C] hits the [src.name] with the bat!</span>")

					return 1

	if(src.material) src.material.triggerOnAttack(src, src, hit_atom)

	if (throw_pixel && islist(params) && params["icon-y"] && params["icon-x"])
		src.pixel_x = text2num(params["icon-x"]) - 16
		src.pixel_y = text2num(params["icon-y"]) - 16

	for(var/atom/A in hit_atom)
		if(A.material)
			A.material.triggerOnAttacked(A, src, hit_atom, src)

	if (reagents)
		reagents.physical_shock(20)

	if (ishuman(hit_atom)) // Haine fix for undefined proc or verb /mob/living/carbon/wall/meatcube/juggling()
		var/mob/living/carbon/human/C = hit_atom //fuck you, monkeys

		if (!ismob(src))
			if (C.juggling())
				if (prob(40))
					C.visible_message("<span class='alert'><b>[C]<b> gets hit in the face by [src]!</span>")
					if (hasvar(src, "throwforce"))
						C.TakeDamageAccountArmor("head", src:throwforce, 0)
				else
					if (prob(C.juggling.len * 5)) // might drop stuff while already juggling things
						C.drop_juggle()
					else
						C.add_juggle(src)
				return

		if(((C.in_throw_mode && C.a_intent == "help") || (C.client && C.client.check_key(KEY_THROW))) && !C.equipped())
			if((C.hand && (!C.limbs.l_arm)) || (!C.hand && (!C.limbs.r_arm)) || C.hasStatus("handcuffed") || (prob(60) && C.bioHolder.HasEffect("clumsy")) || ismob(src) || (throw_traveled <= 1 && last_throw_x == src.x && last_throw_y == src.y))
				C.visible_message("<span class='alert'>[C] has been hit by [src].</span>") //you're all thumbs!!!
				// Added log_reagents() calls for drinking glasses. Also the location (Convair880).
				logTheThing("combat", C, null, "is struck by [src] [src.is_open_container() ? "[log_reagents(src)]" : ""] at [log_loc(C)].")
				if(src.vars.Find("throwforce"))
					random_brute_damage(C, src:throwforce,1)

			#ifdef DATALOGGER
				game_stats.Increment("violence")
			#endif

				if(src.vars.Find("throwforce") && src:throwforce >= 40)
					C.throw_at(get_edge_target_turf(C,get_dir(src, C)), 10, 1)
					C.changeStatus("stunned", 3 SECONDS)

				if(ismob(src)) src:throw_impacted(hit_atom)

			else
				src.attack_hand(C)	// nice catch, hayes. don't ever fuckin do it again
				C.visible_message("<span class='alert'>[C] catches the [src.name]!</span>")
				logTheThing("combat", C, null, "catches [src] [src.is_open_container() ? "[log_reagents(src)]" : ""] at [log_loc(C)].")
				C.throw_mode_off()
			#ifdef DATALOGGER
				game_stats.Increment("catches")
			#endif

		else  //normmal thingy hit me
			if (src.throwing & THROW_CHAIRFLIP)
				C.visible_message("<span class='alert'>[src] slams into [C] midair!</span>")
			else
				C.visible_message("<span class='alert'>[C] has been hit by [src].</span>")
				if(src.vars.Find("throwforce"))
					random_brute_damage(C, src:throwforce,1)

				logTheThing("combat", C, null, "is struck by [src] [src.is_open_container() ? "[log_reagents(src)]" : ""] at [log_loc(C)].")

			//bleed check here
			if (isitem(src))
				if ((src:hit_type == DAMAGE_STAB && prob(20)) || (src:hit_type == DAMAGE_CUT && prob(40)))
					take_bleeding_damage(C, null, 1, src:hit_type)
					impact_sfx = 'sound/impact_sounds/Flesh_Stab_3.ogg'


		#ifdef DATALOGGER
			game_stats.Increment("violence")
		#endif

			if(src.vars.Find("throwforce") && src:throwforce >= 40)
				C.throw_at(get_edge_target_turf(C,get_dir(src, C)), 10, 1)
				C.changeStatus("stunned", 3 SECONDS)

			if(ismob(src)) src:throw_impacted(hit_atom)


	else if(issilicon(hit_atom))
		var/mob/living/silicon/S = hit_atom
		S.visible_message("<span class='alert'>[S] has been hit by [src].</span>")
		logTheThing("combat", S, null, "is struck by [src] [src.is_open_container() ? "[log_reagents(src)]" : ""] at [log_loc(S)].")
		if(src.vars.Find("throwforce"))
			random_brute_damage(S, src:throwforce,1)

	#ifdef DATALOGGER
		game_stats.Increment("violence")
	#endif

		if(src.vars.Find("throwforce") && src:throwforce >= 40)
			S.throw_at(get_edge_target_turf(S,get_dir(src, S)), 10, 1)

		if(ismob(src)) src:throw_impacted(hit_atom)

		impact_sfx = impact_sfx = 'sound/impact_sounds/Metal_Clang_3.ogg'


	else if(isobj(hit_atom))
		var/obj/O = hit_atom
		if(!O.anchored) step(O, src.dir)
		O.hitby(src)
		if(ismob(src)) src:throw_impacted(hit_atom)
		if(O && src.vars.Find("throwforce") && src:throwforce >= 40)
			if(!O.anchored && !O.throwing)
				O.throw_at(get_edge_target_turf(O,get_dir(src, O)), 10, 1)
			else if(src:throwforce >= 80 && !isrestrictedz(O.z))
				O.meteorhit(src)

	else if(isturf(hit_atom))
		var/turf/T = hit_atom
		if(T.density)
			//SPAWN_DBG(0.2 SECONDS) step(src, turn(src.dir, 180))
			if(ismob(src)) src:throw_impacted(hit_atom)
			/*if(istype(hit_atom, /turf/simulated/wall) && isitem(src))
				var/turf/simulated/wall/W = hit_atom
				W.take_hit(src)*/
			if(src.vars.Find("throwforce") && src:throwforce >= 80)
				T.meteorhit(src)

			impact_sfx = impact_sfx = 'sound/impact_sounds/Generic_Stab_1.ogg'

	if (impact_sfx && src)
		playsound(src, impact_sfx, 40, 1)

/atom/movable/Bump(atom/O)
	if(src.throwing)
		src.throw_impact(O)
		src.throwing = 0
	..()

/atom/movable/proc/throw_at(atom/target, range, speed, list/params, turf/thrown_from, throw_type = 1, allow_anchored = 0)
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target
	if (!target) return
	if (src.anchored && !allow_anchored) return
	if (reagents)
		reagents.physical_shock(14)
	src.throwing = throw_type

	if (src.throwing & (THROW_CHAIRFLIP | THROW_GUNIMPACT | THROW_SLIP))
		if (ismob(src))
			var/mob/M = src
			M.force_laydown_standup()

	src.throw_traveled = 0
	src.last_throw_x = src.x
	src.last_throw_y = src.y
	src.throw_begin(target)

	//Gotta do this in 4 steps or byond decides that the best way to interpolate between (0 and) 180 and 360 is to just flip the icon over, not turn it.
	if(!istype(src)) return

	var/matrix/transform_original = src.transform
	if (src.throw_spin == 1 && !(throwing & THROW_SLIP))
		animate(src, transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = -1)
		animate(transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = -1)
		animate(transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = -1)

	var/hitAThing = 0
	var/target_true_x = target.x
	var/target_true_y = target.y

	if (isobj(target.loc))
		var/obj/container = target.loc
		if (target in container.contents)
			target_true_x = container.x
			target_true_y = container.y


	var/dist_x = abs(target_true_x - src.x)
	var/dist_y = abs(target_true_y - src.y)

	var/dx
	if (target_true_x  > src.x)
		dx = EAST
	else
		dx = WEST

	var/dy
	if (target_true_y  > src.y)
		dy = NORTH
	else
		dy = SOUTH

	var/dist_travelled = 0
	var/dist_since_sleep = 0

	if(dist_x > dist_y)
		var/error = dist_x/2 - dist_y
		var/turf/T = src.loc
		while (target && ( (((src.x < target_true_x && dx == EAST) || (src.x > target_true_x && dx == WEST)) && dist_travelled < range) || (T && T.throw_unlimited) || src.throw_unlimited) && src.throwing && isturf(src.loc))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
#if ASS_JAM
			while(src.throwing_paused)//timestop effect
				sleep(1 SECOND)
#endif
			if(error < 0)
				var/atom/step = get_step(src, dy)
				if(!step || step == src.loc) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.glide_size = (32 / (1/speed)) * world.tick_lag
				if (!Move(step))  // Grayshift: Race condition fix. Bump proc calls are delayed past the end of the loop and won't trigger end condition
					hitAThing = 1 // of !throwing on their own, so manually checking if Move failed as end condition
					break
				src.glide_size = (32 / (1/speed)) * world.tick_lag
				hit_check()
				error += dist_x
				dist_travelled++
				src.throw_count++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(0.1 SECONDS)
			else
				var/atom/step = get_step(src, dx)
				if(!step || step == src.loc) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.glide_size = (32 / (1/speed)) * world.tick_lag
				if (!Move(step))
					hitAThing = 1
					break
				src.glide_size = (32 / (1/speed)) * world.tick_lag
				hit_check()
				error -= dist_y
				dist_travelled++
				src.throw_count++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(0.1 SECONDS)
			T = src.loc
	else
		var/error = dist_y/2 - dist_x
		var/turf/T = src.loc
		while (target && ( (((src.y < target_true_y && dy == NORTH) || (src.y > target_true_y && dy == SOUTH)) && dist_travelled < range) || (T && T.throw_unlimited) || src.throw_unlimited) && src.throwing && isturf(src.loc))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
#if ASS_JAM
			while(src.throwing_paused)//timestop effect
				sleep(1 SECOND)
#endif
			if(error < 0)
				var/atom/step = get_step(src, dx)
				if(!step || step == src.loc) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.glide_size = (32 / (1/speed)) * world.tick_lag
				if (!Move(step))
					hitAThing = 1
					break
				src.glide_size = (32 / (1/speed)) * world.tick_lag
				hit_check()
				error += dist_y
				dist_travelled++
				src.throw_count++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(0.1 SECONDS)
			else
				var/atom/step = get_step(src, dy)
				if(!step || step == src.loc) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.glide_size = (32 / (1/speed)) * world.tick_lag
				if (!Move(step))
					hitAThing = 1
					break
				src.glide_size = (32 / (1/speed)) * world.tick_lag
				hit_check()
				error -= dist_x
				dist_travelled++
				src.throw_count++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(0.1 SECONDS)
			T = src.loc

	//done throwing, either because it hit something or it finished moving

	animate(src, transform = transform_original)

	src.throw_end(params)

	if (!hitAThing) // Bump proc requires throwing flag to be set, so if we hit a thing, leave it on and let Bump turn it off
		src.throwing = 0
	else // if we hit something don't use the pixel x/y from the click params
		params = null

	src.throw_unlimited = 0


	//Wire note: Small fix stemming from pie science. Throw a pie at yourself! Whoa!
	//if (target == usr)
	//	src.throw_impact(target)
	//	src.throwing = 0
	//Somepotato note: this is gross. Way to make wireless killing machines!!!

	throw_traveled = dist_travelled //dist traveled is super innacurrate, especially when stacking throws
	if (thrown_from)//if we have htis param we should use it to get the REAL distance.
		throw_traveled = get_dist(get_turf(src),get_turf(thrown_from))

	if(isobj(src)) src:throw_impact(get_turf(src), params)

	src.throw_traveled = 0
	src.throw_count = 0

	if(target != usr && src.throw_return) throw_at(usr, src.throw_range, src.throw_speed)
	//testing boomrang stuff
	//throw_at(atom/target, range, speed)//
	//if(target != usr) throw_at(usr, 10, 1)
