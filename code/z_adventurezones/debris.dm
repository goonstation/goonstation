////Martian Turf stuff//////////////
/turf/simulated/martian
	name = "martian"
	icon = 'icons/turf/martian.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0

/turf/simulated/martian/floor
	name = "organic floor"
	icon_state = "floor1"

/turf/unsimulated/martian/floor
	icon = 'icons/turf/martian.dmi'
	name = "organic floor"
	icon_state = "floor1"

/turf/simulated/martian/wall
	name = "organic wall"
	icon_state = "wall1"
	opacity = 1
	density = 1
	gas_impermeable = 1

	var/health = 40

	proc/checkhealth()
		if(src.health <= 0)
			SPAWN(0)
				gib(src.loc)
				ReplaceWithSpace()

/turf/simulated/martian/wall/ex_act(severity)
	switch(severity)
		if(1)
			src.health -= 40
			checkhealth()
		if(2)
			src.health -= 20
			checkhealth()
		if(3)
			src.health -= 5
			checkhealth()

/turf/simulated/martian/wall/proc/gib(atom/location)
	if (!location) return

	var/obj/decal/cleanable/machine_debris/gib = null
	var/obj/decal/cleanable/blood/gibs/gib2 = null

	// NORTH
	gib = make_cleanable( /obj/decal/cleanable/machine_debris,location)
	if (prob(25))
		gib.icon_state = "gibup1"
	gib.streak_cleanable(NORTH)
	LAGCHECK(LAG_LOW)

	// SOUTH
	gib2 = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	if (prob(25))
		gib2.icon_state = "gibdown1"
	gib2.streak_cleanable(SOUTH)
	LAGCHECK(LAG_LOW)

	// RANDOM
	gib2 = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	gib2.streak_cleanable(cardinal)
