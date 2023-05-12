var/datum/explosion_controller/explosions
#define RSS_SCALE 2
//#define EXPLOSION_MAPTEXT_DEBUGGING
/datum/explosion_controller
	var/list/queued_explosions = list()
	var/list/turf/queued_turfs = list()
	var/list/queued_turfs_blame = list()
	var/distant_sound = 'sound/effects/explosionfar.ogg'
	var/exploding = 0
	var/next_turf_safe = FALSE

	proc/explode_at(atom/source, turf/epicenter, power, brisance = 1, angle = 0, width = 360, turf_safe=FALSE)
		SEND_SIGNAL(source, COMSIG_ATOM_EXPLODE, args)
		if(istype(source)) // Oshan hotspots rudely send a datum here 😐
			for(var/atom/movable/loc_ancestor in obj_loc_chain(source))
				SEND_SIGNAL(loc_ancestor, COMSIG_ATOM_EXPLODE_INSIDE, args)
		var/atom/A = epicenter
		if(istype(A))
			var/severity = power >= 6 ? 1 : power > 3 ? 2 : 3
			var/fprint = null
			if(istype(source))
				fprint = source.fingerprintslast
			while(!istype(A, /turf))
				if(!istype(A, /mob) && A != source)
					A.ex_act(severity, fprint, power)
				A = A.loc
		if (!istype(epicenter, /turf))
			epicenter = get_turf(epicenter)
		if (!epicenter)
			return
		if (epicenter.loc:sanctuary)
			return//no boom boom in sanctuary
		var/datum/explosion/E = new/datum/explosion(source, epicenter, power, brisance, angle, width, usr, turf_safe)
		if(exploding)
			queued_explosions += E
		else
			SPAWN(0)
				next_turf_safe |= E.turf_safe
				E.explode()

	proc/queue_damage(var/list/new_turfs, var/list/new_blame)
		var/c = 0
		for (var/turf/T as anything in new_turfs)
			queued_turfs[T] += new_turfs[T]
			queued_turfs_blame[T] = new_blame[T]
			if(c++ % 100 == 0)
				LAGCHECK(LAG_HIGH)

	proc/highest_explosion_power(obj/object)
		for (var/turf/T in object.locs)
			. = max(., queued_turfs[T])

	proc/kaboom()
		defer_powernet_rebuild = 1
		defer_camnet_rebuild = 1
		exploding = 1
		RL_Suspend()

		var/p
		var/datum/explosion/explosion

		for (var/turf/T as anything in queued_turfs)
			queued_turfs[T] = 2 * (queued_turfs[T])**(1 / (2 * RSS_SCALE))
			p = queued_turfs[T]
			explosion = queued_turfs_blame[T]
			//boutput(world, "P1 [p]")
			if (p >= 6)
				for (var/mob/M in T)
					M.ex_act(1, explosion?.last_touched, p)
			else if (p > 3)
				for (var/mob/M in T)
					M.ex_act(2, explosion?.last_touched, p)
			else
				for (var/mob/M in T)
					M.ex_act(3, explosion?.last_touched, p)

		LAGCHECK(LAG_HIGH)

		for (var/turf/T as anything in queued_turfs)
			explosion = queued_turfs_blame[T]
			for (var/obj/O in T)
				if(istype(O, /obj/overlay) || next_turf_safe && istype(O, /obj/window) || O.last_explosion == explosion)
					continue
				var/power = highest_explosion_power(O)
				var/severity
				if (power >= 6)
					severity = 1
				else if (power > 3)
					severity = 2
				else
					severity = 3
				O.ex_act(severity, explosion?.last_touched, power)
				O.last_explosion = explosion

		LAGCHECK(LAG_HIGH)

		// BEFORE that ordeal (which may sleep quite a few times), fuck the turfs up all at once to prevent lag
		for (var/turf/T as anything in queued_turfs)
#ifndef UNDERWATER_MAP
			if(istype(T, /turf/space))
				continue
#endif
			p = queued_turfs[T]
			explosion = queued_turfs_blame[T]
			//boutput(world, "P2 [p]")
#ifdef EXPLOSION_MAPTEXT_DEBUGGING
			if (p >= 6)
				T.maptext = "<span style='color: #ff0000;' class='pixel c sh'>[p]</span>"
			else if (p > 3)
				T.maptext = "<span style='color: #ffff00;' class='pixel c sh'>[p]</span>"
			else
				T.maptext = "<span style='color: #00ff00;' class='pixel c sh'>[p]</span>"

#else
			var/severity = p >= 6 ? 1 : p > 3 ? 2 : 3
			if(next_turf_safe)
				if(istype(T, /turf/simulated/wall))
					continue // they can break even on severity 3
				else if(istype(T, /turf/simulated))
					severity = max(severity, 3)
			T.ex_act(severity, explosion?.last_touched)
#endif
		LAGCHECK(LAG_HIGH)

		queued_turfs.len = 0
		queued_turfs_blame.len = 0
		defer_powernet_rebuild = 0
		defer_camnet_rebuild = 0
		exploding = 0
		RL_Resume()

		if(length(deferred_powernet_objs))
			deferred_powernet_objs = list()
			makepowernets()

		rebuild_camera_network()
		next_turf_safe = FALSE

	proc/process()
		if (exploding)
			return
		else if (length(queued_turfs))
			kaboom()

		if (length(queued_explosions))
			var/datum/explosion/E
			while (length(queued_explosions))
				E = queued_explosions[1]
				queued_explosions -= E
				E.explode()
				next_turf_safe |= E.turf_safe


/obj/var/datum/explosion/last_explosion = 1 //gross hack detected

/obj/disposing()
	src.last_explosion = null
	. = ..()

/datum/explosion
	var/atom/source
	var/turf/epicenter
	var/power
	var/brisance
	var/angle
	var/width
	var/user
	var/turf_safe
	var/last_touched = "*null*"

	New(atom/source, turf/epicenter, power, brisance, angle, width, user, turf_safe=FALSE)
		..()
		src.source = source
		src.epicenter = epicenter
		src.power = power
		src.brisance = brisance
		src.angle = angle
		src.width = width
		src.user = user
		src.turf_safe = turf_safe

	proc/logMe(var/power)
		if(istype(src.source))
			//I do not give a flying FUCK about what goes on in the colosseum and sims. =I
			var/area/A = get_area(epicenter)
			if(!A.dont_log_combat)
				// Cannot read null.name
				var/logmsg = "[turf_safe ? "Turf-safe e" : "E"]xplosion with power [power] (Source: [source ? "[source.name]" : "*unknown*"])  at [log_loc(epicenter)]. Source last touched by: [key_name(source?.fingerprintslast)] (usr: [ismob(user) ? key_name(user) : user])"
				var/mob/M = null
				if(ismob(user))
					M = user
				if(power > 10 && (source?.fingerprintslast || M?.last_ckey) && !istype(A, /area/mining/magnet) && !istype(source, /obj/machinery/vehicle/escape_pod))
					message_admins(logmsg)
				if (source?.fingerprintslast)
					logTheThing(LOG_BOMBING, source.fingerprintslast, logmsg)
					logTheThing(LOG_DIARY, source.fingerprintslast, logmsg, "combat")
				else
					logTheThing(LOG_BOMBING, user, logmsg)
					logTheThing(LOG_DIARY, user, logmsg, "combat")

	proc/explode()
		logMe(power)

		for(var/client/C in clients)
			if(C.mob && (C.mob.z == epicenter.z) && power > 20)
				shake_camera(C.mob, 8, 24) // remove if this is too laggy

				playsound(C.mob, explosions.distant_sound, 70, 0)

		playsound(epicenter.loc, "explosion", 100, 1, round(power, 1) )
		if(power > 10)
			var/datum/effects/system/explosion/E = new/datum/effects/system/explosion()
			E.set_up(epicenter)
			E.start()

		var/radius = round(sqrt(power), 1) * brisance

		if (istype(source)) // Cannot read null.fingerprintslast
			last_touched = source.fingerprintslast

		var/list/nodes = list()
		var/list/blame = list()
		var/index_open = 1
		var/list/open = list(epicenter)
		var/list/next_open = list()
		nodes[epicenter] = radius
		var/i = 0
		while (index_open <= length(open) || length(next_open))
			if(i++ % 500 == 0)
				LAGCHECK(LAG_HIGH)
			if(index_open > length(open))
				open = next_open
				next_open = list()
				index_open = 1
			var/turf/T = open[index_open++]
			var/value = nodes[T] - 1 - T.explosion_resistance
			var/value2 = nodes[T] - 1.4 - T.explosion_resistance
			for (var/atom/A as anything in T)
				if (A.density/* && !A.Cross(null, target)*/) // nothing actually used the Cross check
					value -= A.explosion_resistance
					value2 -= A.explosion_resistance
			if (value < 0)
				continue
			for (var/dir in alldirs)
				var/turf/target = get_step(T, dir)
				if (!target) continue // woo edge of map
				if( target.loc:sanctuary ) continue
				var/new_value = dir & (dir-1) ? value2 : value
				if(((get_dir(T, epicenter) in ordinal) && (dir & ~get_dir(epicenter, T)))	|| ((get_dir(T, epicenter) in cardinal) && !(dir & get_dir(epicenter, T))))
					new_value = new_value / 3 - 1
				if(width < 360)
					var/diff = abs(angledifference(get_angle(epicenter, target), angle))
					if(diff > width)
						continue
					else if(diff > width/2)
						new_value = new_value / 3 - 1
				if ((nodes[target] && nodes[target] >= new_value))
					continue
				nodes[target] = new_value
				next_open[target] = 1

		radius += 1 // avoid a division by zero
		for (var/turf/T as anything in nodes) // inverse square law (IMPORTANT) and pre-stun
			var/p = power / ((radius-nodes[T])**2)
			nodes[T] = p**RSS_SCALE
			blame[T] = src
			p = min(p, 10)
			if(prob(1))
				LAGCHECK(LAG_HIGH)
			for(var/mob/living/carbon/C in T)
				if (!isdead(C) && C.client)
					shake_camera(C, 3 * p, p * 4)
				C.setStatusMin("stunned", max(p, 0.5) SECONDS)
				C.stuttering += p
				C.lying = 1
				C.set_clothing_icon_dirty()

		explosions.queue_damage(nodes, blame)

#undef RSS_SCALE
