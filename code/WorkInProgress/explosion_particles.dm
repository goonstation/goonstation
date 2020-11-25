/obj/effects/expl_particles
	name = "fire"
	icon = 'icons/effects/effects.dmi'
	icon_state = "explosion_particle"
	opacity = 0
	anchored = 1
	mouse_opacity = 0

/obj/effects/expl_particles/New()
	..()
	SPAWN_DBG (10)
		dispose()
	return

/datum/effects/system/expl_particles
	var/number = 10
	var/turf/location
	var/total_particles = 0

/datum/effects/system/expl_particles/proc/set_up(n = 10, loca)
	number = n
	if(istype(loca, /turf/)) location = loca
	else location = get_turf(loca)

/datum/effects/system/expl_particles/proc/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		SPAWN_DBG(0)
			var/obj/effects/expl_particles/expl = new /obj/effects/expl_particles(src.location)
			var/direct = pick(alldirs)
			for(i=0, i<pick(1;25,2;55,3,4;200), i++)
				sleep(0.1 SECONDS)
				step(expl,direct)

/obj/effects/explosion
	name = "fire"
	icon = 'icons/effects/224x224.dmi'
	icon_state = "superexpl"
	opacity = 0
	anchored = 1
	mouse_opacity = 0
	pixel_x = -96
	pixel_y = -96
	layer = NOLIGHT_EFFECTS_LAYER_BASE

	dangerous // cogwerks testing thing, use with caution. a spreading infestation of this is FUCKING AWESOME to watch

		New()
			..()
			SPAWN_DBG(rand(0,1))
				explosion(src, src.loc, -1,0,1,1)
			return

	tiny_baby
		New()
			..()
			src.transform = matrix(0.5, MATRIX_SCALE)

/obj/effects/explosion/New()
	..()
	SPAWN_DBG (30)
		dispose()
	return

/datum/effects/system/explosion
	var/turf/location
	var/atom/source

/datum/effects/system/explosion/proc/set_up(loca)
	if(istype(loca, /turf/)) location = loca
	else location = get_turf(loca)
	source = loca

/datum/effects/system/explosion/proc/start()
	var/obj/effects/explosion/E = new/obj/effects/explosion( location )
	E.fingerprintslast = source.fingerprintslast
	var/datum/effects/system/expl_particles/P = new/datum/effects/system/expl_particles()
	P.set_up(10,location)
	P.start()
	SPAWN_DBG(3 SECONDS)
		var/datum/effects/system/harmless_smoke_spread/S = new/datum/effects/system/harmless_smoke_spread()
		S.set_up(3,0,location,null)
		S.start()
