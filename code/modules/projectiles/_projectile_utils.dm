//Global procs for firing, reflecting projectiles

// THIS IS INTENDED FOR POINTBLANKING.
/proc/hit_with_projectile(var/S, var/datum/projectile/DATA, var/atom/T)
	if (!S || !T)
		return
	var/times = max(1, DATA.shot_number)
	for (var/i = 1, i <= times, i++)
		var/obj/projectile/P = initialize_projectile_pixel_spread(S, DATA, T)
		if (S == T)
			P.shooter = null
			P.mob_shooter = S
		hit_with_existing_projectile(P, T)

/proc/hit_with_existing_projectile(var/obj/projectile/P, var/atom/T)
	if (!P || !T)
		return
	if (ismob(T))
		var/immunity = check_target_immunity(T) // Point-blank overrides, such as stun bullets (Convair880).
		if (immunity)
			log_shot(P, T, 1)
			T.visible_message(SPAN_ALERT("<b>...but the projectile bounces off uselessly!</b>"))
			P.die()
			return
		if (P.proj_data)
			P.proj_data.on_pointblank(P, T)
	P.collide(T) // The other immunity check is in there (Convair880).

/proc/shoot_projectile_DIR(var/atom/movable/S, var/datum/projectile/DATA, var/dir, var/datum/callback/alter_proj = null, var/atom/called_target = null, var/atom/movable/remote_sound_source = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return null
	var/turf/T = get_step(get_turf(S), dir)
	if (T)
		return shoot_projectile_ST_pixel_spread(S, DATA, T, alter_proj = alter_proj, called_target = called_target, remote_sound_source = remote_sound_source)
	return null

/proc/shoot_projectile_ST_pixel_spread(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy, var/spread_angle, var/datum/callback/alter_proj = null, var/atom/called_target = null, var/atom/movable/remote_sound_source = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return null
	var/obj/projectile/Q = shoot_projectile_relay_pixel_spread(S, DATA, T, pox, poy, spread_angle, alter_proj = alter_proj, called_target = called_target, remote_sound_source = remote_sound_source)
	if (DATA.shot_number > 1)
		SPAWN(-1)
			for (var/i = 2, i <= DATA.shot_number, i++)
				sleep(DATA.shot_delay)
				shoot_projectile_relay_pixel_spread(S, DATA, T, pox, poy, spread_angle, alter_proj = alter_proj, called_target = called_target, remote_sound_source = remote_sound_source)
	return Q

/proc/shoot_projectile_relay_pixel_spread(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy, var/spread_angle, var/datum/callback/alter_proj = null, var/atom/called_target = null, var/atom/movable/remote_sound_source = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/obj/projectile/P = initialize_projectile_pixel_spread(S, DATA, T, pox, poy, spread_angle, alter_proj = alter_proj, called_target = called_target, remote_sound_source = remote_sound_source)
	if (P)
		P.launch()
	return P

/proc/initialize_projectile_pixel_spread(var/atom/movable/S, var/datum/projectile/DATA, var/T, var/pox, var/poy, var/spread_angle, var/datum/callback/alter_proj = null, var/atom/called_target = null, var/atom/movable/remote_sound_source = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/turf/Q1 = get_turf(S)
	var/turf/Q2 = get_turf(T)
	if (!(Q1 && Q2))
		return
	var/obj/projectile/P = initialize_projectile(Q1, DATA, (Q2.x - Q1.x) * 32 + pox, (Q2.y - Q1.y) * 32 + poy, S, alter_proj = alter_proj, called_target = called_target, remote_sound_source = remote_sound_source)
	if (P && spread_angle)
		if (spread_angle < 0)
			spread_angle = -spread_angle
		var/spread = rand(spread_angle * 10) / 10
		P.rotateDirection(prob(50) ? spread : -spread)
	return P

/proc/shoot_projectile_XY(var/atom/movable/S, var/datum/projectile/DATA, var/xo, var/yo, var/datum/callback/alter_proj = null, var/atom/called_target = null, var/atom/movable/remote_sound_source = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/obj/projectile/Q = shoot_projectile_XY_relay(S, DATA, xo, yo, alter_proj = alter_proj, called_target = called_target, remote_sound_source = remote_sound_source)
	if (DATA.shot_number > 1)
		SPAWN(-1)
			for (var/i = 2, i <= DATA.shot_number, i++)
				sleep(DATA.shot_delay)
				shoot_projectile_XY_relay(S, DATA, xo, yo, alter_proj = alter_proj, called_target = called_target, remote_sound_source = remote_sound_source)
	return Q

/proc/shoot_projectile_XY_relay(var/atom/movable/S, var/datum/projectile/DATA, var/xo, var/yo, var/datum/callback/alter_proj = null, var/atom/called_target = null, var/atom/movable/remote_sound_source = null)
	if (!S)
		return
	if (!isturf(S) && !isturf(S.loc))
		return
	var/obj/projectile/P = initialize_projectile(get_turf(S), DATA, xo, yo, S, alter_proj = alter_proj, called_target = called_target, remote_sound_source = remote_sound_source)
	if (P)
		P.launch()
	return P

/proc/initialize_projectile(var/turf/S, var/datum/projectile/DATA, var/xo, var/yo, var/shooter = null, var/turf/remote_sound_source = null, var/play_shot_sound = TRUE, var/datum/callback/alter_proj = null, var/atom/called_target = null)
	if (!S)
		return
	var/obj/projectile/P = new
	if(!P)
		return

	P.set_loc(S)
	P.orig_turf = get_turf(S)
	P.shooter = shooter
	P.power = DATA.power

	P.proj_data = DATA
	alter_proj?.Invoke(P)

	if(P.proj_data == DATA)
		P.initial_power = P.power //allows us to set projectile power in callback without needing a new projectile datum
	else
		DATA = P.proj_data //could have been changed by alter_projectile
		P.initial_power = DATA.power

	P.set_icon()
	P.name = DATA.name
	P.setMaterial(DATA.material)


	if (DATA.implanted)
		P.implanted = DATA.implanted

	P.called_target = called_target
	P.called_target_turf = get_turf(called_target)

	if(remote_sound_source)
		shooter = remote_sound_source

	if (play_shot_sound)
		var/atom/sound_source = S
		if(S == get_turf(shooter))
			sound_source = shooter
		if (narrator_mode) // yeah sorry I don't have a good way of getting rid of this one
			playsound(sound_source, 'sound/vox/shoot.ogg', 50, TRUE)
		else if(DATA.shot_sound && DATA.shot_volume && shooter)
			var/flags = DATA.sound_los ? SOUND_DO_LOS : 0
			playsound(sound_source, DATA.shot_sound, DATA.shot_volume, 1,DATA.shot_sound_extrarange, pitch = DATA.shot_pitch == 1 ? null : DATA.shot_pitch, flags = flags)

#ifdef DATALOGGER
	if (game_stats && istype(game_stats))
		game_stats.Increment("gunfire")
#endif
	if (DATA.brightness)
		P.add_simple_light("proj", list(DATA.color_red*255, DATA.color_green*255, DATA.color_blue*255, DATA.brightness * 255))

	P.xo = xo
	P.yo = yo

	if(DATA.dissipation_rate <= 0)
		P.max_range = DATA.max_range
	else
		P.max_range = min(DATA.dissipation_delay + round(P.power / DATA.dissipation_rate), DATA.max_range)

	if (DATA.reagent_payload)
		P.create_reagents(15)
		P.reagents.add_reagent(DATA.reagent_payload, 15)

	return P

/proc/shoot_reflected_to_sender(var/obj/projectile/P, var/obj/reflector, var/max_reflects = 3)
	if(P.reflectcount >= max_reflects)
		return
	var/obj/projectile/Q = initialize_projectile(get_turf(reflector), P.proj_data, -P.xo, -P.yo, reflector)
	if (!Q)
		return null
	SEND_SIGNAL(reflector, COMSIG_ATOM_PROJECTILE_REFLECTED)
	Q.reflectcount = P.reflectcount + 1
	if (ismob(P.shooter))
		Q.mob_shooter = P.shooter
	Q.name = "reflected [Q.name]"
	Q.launch(do_delay = (Q.reflectcount % 5 == 0))
	return Q

/*
 * shoot_reflected_true seemed half broken...
 * So I made my own proc, but left the old one in place just in case -- Sovexe
 * var/reflect_on_nondense_hits - flag for handling hitting objects that let bullets pass through like secbots, rather than duplicating projectiles
 */
/proc/shoot_reflected_bounce(var/obj/projectile/P, var/atom/reflector, var/max_reflects = 3, var/mode = PROJ_RAPID_HEADON_BOUNCE, var/reflect_on_nondense_hits = FALSE, var/play_shot_sound = TRUE, var/turf/fire_from = null)
	if (!P || !reflector)
		return

	if(P.reflectcount >= max_reflects)
		return

	SEND_SIGNAL(reflector, COMSIG_ATOM_PROJECTILE_REFLECTED)

	switch (mode)
		if (PROJ_NO_HEADON_BOUNCE) //no head-on bounce
			if ((P.shooter.x == reflector.x) || (P.shooter.y == reflector.y))
				return
		if (PROJ_HEADON_BOUNCE) // no rapid head-on bounce
			if ((P.shooter.x == reflector.x) && abs(P.shooter.y - reflector.y) == 2)
				return
			else if (abs(P.shooter.x - reflector.x) == 2 && (P.shooter.y == reflector.y))
				return
		if (PROJ_RAPID_HEADON_BOUNCE)
			if (P.proj_data.shot_sound)
				if ((P.shooter.x == reflector.x) && abs(P.shooter.y - reflector.y) == 2)
					play_shot_sound = FALSE //anti-ear destruction
				else if (abs(P.shooter.x - reflector.x) == 2 && (P.shooter.y == reflector.y))
					play_shot_sound = FALSE //anti-ear destruction
		else
			return

	/*
		* We have to calculate our incidence each time
		* Otherwise we risk the reflect projectile using the same incidence over and over
		* resulting in bumping same wall repeatadly
	*/
	var/x_diff = reflector.x - P.x
	var/y_diff = reflector.y - P.y

	if (!x_diff && !y_diff)
		return //we are inside the reflector or something went terribly wrong
	else if (x_diff > 0 && y_diff == 0)
		P.incidence = WEST
	else if (x_diff < 0 && y_diff == 0)
		P.incidence = EAST
	else if (x_diff == 0 && y_diff > 0)
		P.incidence = SOUTH
	else if (x_diff == 0 && y_diff < 0)
		P.incidence = NORTH
	else if (x_diff < 0 && y_diff < 0)
		P.incidence = pick(EAST, NORTH)
	else if (x_diff < 0 && y_diff > 0)
		P.incidence = pick(EAST, SOUTH)
	else if (x_diff > 0 && y_diff < 0)
		P.incidence = pick(WEST, NORTH)
	else if (x_diff > 0 && y_diff > 0)
		P.incidence = pick(WEST, SOUTH)
	else
		return //please no runtimes

	var/rx = 0
	var/ry = 0

	//x and y components of the surface normal vector
	var/nx = reflector.normal_x(P.incidence)
	var/ny = reflector.normal_y(P.incidence)

	var/dn = 2 * (P.xo * nx + P.yo * ny) // incident direction DOT normal * 2
	rx = P.xo - dn * nx // r = d - 2 * (d * n) * n
	ry = P.yo - dn * ny

	if (rx == ry && rx == 0)
		logTheThing(LOG_DEBUG, null, "<b>Reflecting Projectiles</b>: Reflection failed for [P.name] (incidence: [P.incidence], direction: [P.xo];[P.yo]).")
		return // unknown error

	//spawns the new projectile in the same location as the existing one, not inside the hit thing
	var/obj/projectile/Q = initialize_projectile(fire_from || get_turf(P), P.proj_data, rx, ry, reflector, play_shot_sound = play_shot_sound)
	if (!Q)
		return
	Q.reflectcount = P.reflectcount + 1
	if (ismob(P.shooter))
		Q.mob_shooter = P.shooter

	//fix for duplicating projectiles when hitting nondense objects like secbots that don't kill projectiles
	if (isobj(reflector) && reflector.density == 0)
		if (reflect_on_nondense_hits)
			P.die()
		else
			Q.die()
			if (P)
				return P
			else
				return

	Q.name = "reflected [Q.name]"
	Q.launch(do_delay = (Q.reflectcount % 5 == 0))
	return Q
