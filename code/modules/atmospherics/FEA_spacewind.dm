/atom/movable
	var/pressure_resistance = 20

	///The most recent cycle of spacewind this movable was moved at.
	VAR_FINAL/last_airflow_movement = 0
	///The density of the object prior to airflow beginning its process
	VAR_FINAL/pre_airflow_density = null
	///The "speed" this object is travelling during airflow
	VAR_FINAL/airflow_speed = 0
	///The delay between each airflow process, typically based on speed.
	VAR_FINAL/airflow_process_delay = 0
	///The source turf of the pressure experience
	VAR_FINAL/turf/airflow_origin
	///The amount of ticks an object has been in airflow
	VAR_FINAL/airflow_time = 0
	///Some magic bullshit relating to spacewind movement.
	VAR_FINAL/airflow_skip_speedcheck = null
	///The direction the pressure hit us in
	VAR_FINAL/airflow_direction = 0
	///Set to TRUE during airflow movement for special Bump() behavior
	VAR_FINAL/movement_by_airflow = FALSE

/mob
	VAR_FINAL/last_airflow_stun = 0

///Put all your movement-blocking stuff here like magboots.
/atom/movable/proc/CanAirflowMove(delta)
	return TRUE

/mob/living/carbon/human/CanAirflowMove(delta)
	. = ..()
	if(src.shoes && src.shoes.magnetic)
		return FALSE

/atom/movable/proc/experience_pressure_difference(pressure_difference, direction, turf/origin)
	if(last_airflow_movement > world.time - AIRFLOW_MOVE_DELAY)
		return FALSE

	if(anchored)
		return FALSE

	if(airflow_speed)
		return FALSE

	if(pressure_difference > pressure_resistance)
		SPAWN(0)
			AirflowMove(pressure_difference, origin)

	return TRUE

/mob/living/carbon/human/experience_pressure_difference(pressure_difference, direction, turf/origin)
	if(pressure_difference >= AIRFLOW_MOB_KNOCKDOWN_THRESHOLD && world.time > last_airflow_stun + AIRFLOW_STUN_COOLDOWN)
		src.changeStatus("weakened", 2 SECONDS)
	. = ..()

/atom/movable/proc/AirflowMove(delta, turf/origin)
	set waitfor = FALSE

	if(!PrepareAirflow(delta, origin))
		return

	while(src.airflow_speed > 0)
		if(QDELETED(src))
			break
		if(!isturf(src.loc))
			break
		if(!CanAirflowMove(delta))
			break

		LAGCHECK(LAG_MED)

		src.airflow_speed = min(src.airflow_speed, AIRFLOW_SPEED_MIN)
		src.airflow_speed -= AIRFLOW_SPEED_DECAY

		if(src.airflow_speed > AIRFLOW_SPEED_SKIP_CHECK)
			if(src.airflow_time++ >= src.airflow_speed - AIRFLOW_SPEED_SKIP_CHECK)
				sleep(1 DECI SECOND)
		else
			sleep(max(1, 10 - (src.airflow_speed + 3)) DECI SECONDS)

		src.set_density(TRUE)
		src.movement_by_airflow = TRUE

		var/old_dir = src.dir

		var/dirfromoriginasangle = dir2angle(get_dir(src.airflow_origin, src))
		var/airflow_angle = dir2angle(src.airflow_direction)
		var/angle = max(dirfromoriginasangle, airflow_angle) - min(dirfromoriginasangle, airflow_angle)


		if(src.loc == src.airflow_origin)
			step(src, src.airflow_direction)
		else
			switch(angle)
				if(0 to 45)
					step_away(src, src.airflow_origin)
				if(46 to 90)
					step(src, src.airflow_direction)
				if(91 to 360)
					step_towards(src, src.airflow_origin)

		src.set_density(pre_airflow_density)
		src.set_dir(old_dir)
		src.movement_by_airflow = FALSE

	src.set_density(pre_airflow_density)
	src.pre_airflow_density = null
	src.airflow_speed = 0
	src.airflow_origin = null
	src.airflow_skip_speedcheck = null
	src.airflow_time = 0
	src.airflow_direction = 0

/atom/movable/proc/PrepareAirflow(delta as num, turf/origin)
	. = TRUE

	if(src.anchored)
		return FALSE

	if (!origin || src.airflow_speed < 0 || src.last_airflow_movement > world.time - AIRFLOW_MOVE_DELAY)
		return FALSE

	if (src.airflow_speed)
		src.airflow_speed = delta / max(get_dist(src, origin), 1)
		return FALSE

	// A movement occurs here, but it doesn't mean the mob will be queued to the airflow loop.
	if (origin == loc)
		step(src, origin.pressure_direction)

	if(ismob(src))
		boutput(src, "<span class='notice'>You are pushed away by a rush of air!</span>")

	src.last_airflow_movement = world.time

	//Get the distance from the flow origin to create some feeling of natural falloff
	var/airflow_falloff = 9 - get_dist(src, origin)
	if (airflow_falloff < 1)
		return FALSE

	// At this point, we're locked into an airflow movement.
	src.airflow_speed = min(max(delta * (9 / airflow_falloff), 1), 9)
	src.pre_airflow_density = src.density
	src.airflow_origin = origin
	src.airflow_direction = origin.pressure_direction

/atom/movable/bump(atom/A)
	if(src.airflow_speed > 0 && src.airflow_origin && src.movement_by_airflow)
		var/turf/T = get_turf(A)
		if(airflow_speed > 1)
			airflow_hit(A)
			A.airflow_hit_act(src)
		else if(istype(src, /mob/living/carbon/human) && ismovable(A) && (A:pre_airflow_density == 0))
			var/mob/living/carbon/human/H = src
			boutput(src, "<span class='notice'>You are pinned against [A] by airflow!</span>")
			H.changeStatus("stunned", 3 SECONDS) // :)
		/*
		If the turf of the atom we bumped is NOT dense, then we check if the flying object is dense.
		We check the special var because flying objects gain density so they can Bump() objects.
		If the object is NOT normally dense, we remove our density and the target's density,
		enabling us to step into their turf. Then, we set the density back to the way its supposed to be for airflow.
		*/
		if(!T.density)
			if(ismovable(A) && A:pre_airflow_density == 0)
				set_density(FALSE)
				A.set_density(FALSE)
				step_towards(src, A)
				set_density(TRUE)
				A.set_density(TRUE)

	return ..()

///Called when src collides with A during airflow
/atom/movable/proc/airflow_hit(atom/A)
	SHOULD_CALL_PARENT(TRUE)
	airflow_speed = 0
	airflow_origin = null

///Called when "flying" calls airflow_hit() on src
/atom/proc/airflow_hit_act(atom/movable/flying)
	return

/mob/living/carbon/human/airflow_hit(atom/A)
	if(istype(A, /obj/structure) || istype(A, /turf/simulated/wall))
		if(src.airflow_speed > 10)
			src.changeStatus("stun", (round(src.airflow_speed * 1 SECONDS) + 3))
			loc.add_blood(src)
			src.visible_message(
				"<span class='alert'>[src] splats against \the [A]!</span>",
				"<span class='alert'>You slam into \the [A] with tremendous force!</span>"
			)

			src.emote("scream")

		else
			src.changeStatus(round(airflow_speed * 1 SECONDS)/2)
			visible_message(
				"<span class='alert'>[src] slams into \the [A]!</span>",
				"<span class='alert'>You're thrown against \the [A] by pressure!</span>"
			)

	return ..()

/mob/living/carbon/human/airflow_hit_act(atom/movable/flying)
	. = ..()
	if(prob(33))
		loc.add_blood(src)

/mob/living/airflow_hit_act(atom/movable/flying)
	. = ..()
	src.visible_message(
		"<span class='alert'>A flying [flying.name] slams into \the [src]!</span>",
		"<span class='alert'>You're hit by a flying [flying]!</span>"
	)

	playsound(src.loc, pick(sounds_punch), 100, 1, -1)
	var/weak_amt
	if(istype(flying,/obj/item))
		weak_amt = flying:w_class*2 ///Heheheh
	else if(flying.pre_airflow_density == TRUE)
		weak_amt = 5 //Getting crushed by a flying canister or computer is going to fuck you up
	else
		weak_amt = rand(1, 3)

	src.changeStatus("weakened", weak_amt SECONDS)

/obj/airflow_hit_act(atom/movable/flying)
	. = ..()

	var/damage
	if(ismob(flying))
		damage = 10
	else if(isitem(flying))
		damage = flying:w_class*5 ///Heheheh
	else if(flying.pre_airflow_density == TRUE)
		damage = 30//Getting crushed by a flying canister or computer is going to fuck you up
	else
		damage = rand(5,15)

	src.changeHealth(-damage)

	if(flying.pre_airflow_density == TRUE)
		src.visible_message(
			"<span class='alert'>A flying [flying.name] slams into \the [src]!</span>",
		)

	//playsound(src.loc, "smash.ogg", 25, 1, -1)
