var/datum/explosion_controller/explosions

/datum/explosion_controller
	var/list/queued_explosions = list()
	var/list/turf/queued_turfs = list()
	var/list/queued_turfs_blame = list()
	var/distant_sound = 'sound/effects/explosionfar.ogg'
	var/exploding = 0

	proc/explode_at(atom/source, turf/epicenter, power, brisance = 1, angle = 0, width = 360)
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

		queued_explosions += new/datum/explosion(source, epicenter, power, brisance, angle, width)

	proc/queue_damage(var/list/new_turfs)
		for (var/turf/T in new_turfs)
			queued_turfs[T] += new_turfs[T]

	proc/kaboom()
		defer_powernet_rebuild = 1
		defer_camnet_rebuild = 1
		exploding = 1
		RL_Suspend()

		var/needrebuild = 0
		var/p
		var/last_touched

		for (var/turf/T as() in queued_turfs)
			queued_turfs[T]=sqrt(queued_turfs[T])*2
			p = queued_turfs[T]
			last_touched = queued_turfs_blame[T]
			//boutput(world, "P1 [p]")
			if (p >= 6)
				for (var/mob/M in T)
					M.ex_act(1, last_touched, p)
			else if (p > 3)
				for (var/mob/M in T)
					M.ex_act(2, last_touched, p)
			else
				for (var/mob/M in T)
					M.ex_act(3, last_touched, p)

		LAGCHECK(LAG_HIGH)

		for (var/turf/T as() in queued_turfs)
			p = queued_turfs[T]
			last_touched = queued_turfs_blame[T]
			//boutput(world, "P1 [p]")
			if (p >= 6)
				for (var/obj/O in T)
					if(istype(O, /obj/overlay))
						continue
					O.ex_act(1, last_touched, p)
					if (istype(O, /obj/cable)) // these two are hacky, newcables should relieve the need for this
						needrebuild = 1
			else if (p > 3)
				for (var/obj/O in T)
					if(istype(O, /obj/overlay))
						continue
					O.ex_act(2, last_touched, p)
					if (istype(O, /obj/cable))
						needrebuild = 1
			else
				for (var/obj/O in T)
					if(istype(O, /obj/overlay))
						continue
					O.ex_act(3, last_touched, p)

		LAGCHECK(LAG_HIGH)

		// BEFORE that ordeal (which may sleep quite a few times), fuck the turfs up all at once to prevent lag
		for (var/turf/T as() in queued_turfs)
#ifndef UNDERWATER_MAP
			if(istype(T, /turf/space))
				continue
#endif
			p = queued_turfs[T]
			last_touched = queued_turfs_blame[T]
			//boutput(world, "P2 [p]")
#ifdef EXPLOSION_MAPTEXT_DEBUGGING
			if (p >= 6)
				T.maptext = "<span style='color: #ff0000;' class='pixel c sh'>[p]</span>"
			else if (p > 3)
				T.maptext = "<span style='color: #ffff00;' class='pixel c sh'>[p]</span>"
			else
				T.maptext = "<span style='color: #00ff00;' class='pixel c sh'>[p]</span>"

#else
			if (p >= 6)
				T.ex_act(1, last_touched)
			else if (p > 3)
				T.ex_act(2, last_touched)
			else
				T.ex_act(3, last_touched)
#endif
		LAGCHECK(LAG_HIGH)

		queued_turfs.len = 0
		queued_turfs_blame.len = 0
		defer_powernet_rebuild = 0
		defer_camnet_rebuild = 0
		exploding = 0
		RL_Resume()
		if (needrebuild)
			makepowernets()

		rebuild_camera_network()

	proc/process()
		if (exploding)
			return
		else if (queued_turfs.len)
			kaboom()
		else if (queued_explosions.len)
			var/datum/explosion/E
			while (queued_explosions.len)
				E = queued_explosions[1]
				queued_explosions -= E
				E.explode()

/datum/explosion
	var/atom/source
	var/turf/epicenter
	var/power
	var/brisance
	var/angle
	var/width

	New(atom/source, turf/epicenter, power, brisance, angle, width)
		..()
		src.source = source
		src.epicenter = epicenter
		src.power = power
		src.brisance = brisance
		src.angle = angle
		src.width = width

	proc/logMe()
		//I do not give a flying FUCK about what goes on in the colosseum. =I
		if(!istype(get_area(epicenter), /area/colosseum))
			// Cannot read null.name
			var/logmsg = "Explosion with power [power] (Source: [source ? "[source.name]" : "*unknown*"])  at [log_loc(epicenter)]. Source last touched by: [source ? "[source.fingerprintslast]" : "*null*"]"
			message_admins(logmsg)
			logTheThing("bombing", null, null, logmsg)
			logTheThing("diary", null, null, logmsg, "combat")

	proc/explode()
		if(power > 10)
			logMe()

		for(var/client/C in clients)
			if(C.mob && (C.mob.z == epicenter.z) && power > 15)
				shake_camera(C.mob, 8, 24) // remove if this is too laggy

				C << sound(explosions.distant_sound)

		playsound(epicenter.loc, "explosion", 100, 1, round(power, 1) )
		if(power > 10)
			var/datum/effects/system/explosion/E = new/datum/effects/system/explosion()
			E.set_up(epicenter)
			E.start()

		var/radius = round(sqrt(power), 1) * brisance

		var/last_touched
		if (source) // Cannot read null.fingerprintslast
			last_touched = source.fingerprintslast
		else
			last_touched = "*null*"

		var/list/nodes = list()
		var/list/blame = list()
		var/list/open = list(epicenter)
		nodes[epicenter] = radius
		while (open.len)
			var/turf/T = open[1]
			open.Cut(1, 2)
			var/value = nodes[T] - 1 - T.explosion_resistance
			var/value2 = nodes[T] - 1.4 - T.explosion_resistance
			for (var/atom/A in T.contents)
				if (A.density/* && !A.CanPass(null, target)*/) // nothing actually used the CanPass check
					value -= A.explosion_resistance
					value2 -= A.explosion_resistance
			if (value < 0)
				continue
			for (var/dir in alldirs)
				var/turf/target = get_step(T, dir)
				if (!target) continue // woo edge of map
				if( target.loc:sanctuary ) continue
				var/new_value = dir & (dir-1) ? value2 : value
				if(width < 360)
					var/diff = abs(angledifference(get_angle(epicenter, target), angle))
					if(diff > width)
						continue
					else if(diff > width/2)
						new_value = new_value / 3 - 1
				if ((nodes[target] && nodes[target] >= new_value))
					continue
				nodes[target] = new_value
				open |= target

		radius += 1 // avoid a division by zero
		for (var/turf/T in nodes) // inverse square law (IMPORTANT) and pre-stun
			var/p = power / ((radius-nodes[T])**2)
			nodes[T] = p
			blame[T] = last_touched
			p = min(p, 10)
			for(var/mob/living/carbon/C in T)
				if (!isdead(C) && C.client)
					shake_camera(C, 3 * p, p * 4)
				C.changeStatus("stunned", p * 10)
				C.stuttering += p
				C.lying = 1
				C.set_clothing_icon_dirty()

		explosions.queue_damage(nodes)
		explosions.queued_turfs_blame += blame
