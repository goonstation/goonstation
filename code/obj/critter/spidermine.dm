/obj/critter/spidermine
	name = "spidermine"
	desc = "This looks incredibly bad for your health."
	icon = 'icons/mob/robots.dmi'
	icon_state = "syndibot"
	density = 1
	health = 40
	aggressive = 1
	defensive = 0
	wanderer = 0
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 0
	atcritter = 0
	firevuln = 0
	brutevuln = 1
	is_syndicate = 1
	var/boredom_countdown = 0
	var/waiting = TRUE

	CritterDeath()
		..()
		explode()
		return

	seek_target()
		src.anchored = 0
		if (src.target)
			src.task = "chasing"
			return
		for (var/mob/living/C in hearers(src.seekrange,src))
			if (!isrobot(C) && !ishuman(C)) continue
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			//if (C.stat || C.health < 0) continue

			src.boredom_countdown = rand(0,1)
			src.target = C
			src.oldtarget_name = C.name
			src.task = "chasing"
			src.appear()
			break

	ChaseAttack(mob/M)
		playsound(src.loc, "sound/weapons/bombtimer.ogg", 75, 1)
		SPAWN_DBG(2 SECONDS)
			explode()

	on_sleep()
		..()
		src.disappear()

	process()
		..()
		if (!waiting)
			playsound(src.loc, "sound/weapons/bombloop.ogg", 50, 1)

	proc/appear()
		if (!waiting)
			return
		//src.icon_state = "wendigo_appear"
		src.waiting =! waiting
		set_density(1)
		SPAWN_DBG(1.2 SECONDS)
			playsound(src.loc, "sound/misc/ancientbot_beep1.ogg", 85, 1)
			src.visible_message("<span class='alert'><B>[src]</B> beeps!</span>")
		return

	proc/disappear()
		if (waiting)
			return

		//src.icon_state = "wendigo_melt"
		set_density(0)
		SPAWN_DBG(1.2 SECONDS)
			src.waiting =! waiting
		return

	proc/explode()
		// Duplication of /obj/item/old_grenade/stinger explosion
		var/turf/T = src.loc
		if (T)
			playsound(T, "sound/weapons/grenade.ogg", 25, 1)
			explosion(src, T, -1, -1, -0.25, 1)
			var/obj/overlay/O = new/obj/overlay(get_turf(T))
			O.anchored = 1
			O.name = "Explosion"
			O.layer = NOLIGHT_EFFECTS_LAYER_BASE
			O.icon = 'icons/effects/64x64.dmi'
			O.icon_state = "explo_fiery"
			var/datum/projectile/special/spreader/uniform_burst/circle/PJ = new /datum/projectile/special/spreader/uniform_burst/circle(T)
			PJ.pellets_to_fire = 20
			var/targetx = src.y - rand(-5,5)
			var/targety = src.y - rand(-5,5)
			var/turf/newtarget = locate(targetx, targety, src.z)
			shoot_projectile_ST(src, PJ, newtarget)
			SPAWN_DBG(0.5 SECONDS)
				qdel(O)
				qdel(src)
		else
			qdel(src)
		return
