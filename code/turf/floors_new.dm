/*
	here i will organise the floors
	the current organisation, while it works well enough for coders, yes, is fucking
	horribly, horrendously, painful to use. to the point where I- a MAPPER am fucking organising it.
	now, WHY change it this much? because its easier to add organise this way
	- f191

	simulated/floor		setting the variables for other floors
	floor/checker			this was painful. never again.
	floor/decal				jesus FUCKING CHRIST why why WHY are these turfs and not decals?? why were these not organised??
	floor/full				these should have an actual path rather then just /floor/black, floor/blue ect
	floor/misc				this will contain random shit that was just randomly added as a turf
	floor/setpeice		please. please god seperate adventure shit from actual shit adjjkjjkjdi
	floor/side				having these sometimes be children of random turfs was painful. no, just no
		this is all alphabetical because its easier to organise to use in a mapeditor . . .
*/
////////////	Inital floor turf

/turf/simulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	thermal_conductivity = 0.040
	heat_capacity = 225000

	turf_flags = IS_TYPE_SIMULATED | MOB_SLIP | MOB_STEP

	var/broken = 0
	var/burnt = 0
	var/plate_mat = null
	var/reinforced = FALSE

	New()
		..()
		plate_mat = getMaterial("steel")
		setMaterial(getMaterial("steel"))
		var/obj/plan_marker/floor/P = locate() in src
		if (P)
			src.icon = P.icon
			src.icon_state = P.icon_state
			src.icon_old = P.icon_state
			allows_vehicles = P.allows_vehicles
			var/pdir = P.dir
			SPAWN_DBG(0.5 SECONDS)
				src.set_dir(pdir)
			qdel(P)

////////////	Checker pattern floors

/turf/simulated/floor/checker
	name = "Checkered Floors"

//////////// Decal pattern floors (ie the big sign outside manta's security)

/turf/simulated/floor/decal
	name = "Decal Floors"

////////////	Fully-Coloured Floors (Think stuff like the white tiles in medical bay)

/turf/simulated/floor/full
	name = "Fully-Coloured Floors"

////////////	Random misc floors, like the blob's floor

/turf/simulated/floor/misc
	name = "Miscellaneous Floors"

/turf/simulated/floor/misc/Vspace
	name = "Vspace"
	icon_state = "flashyblue"
	var/network = "none"
	var/network_ID = "none"
	fullbright = 1

/turf/simulated/floor/misc/Vspace/brig
	name = "Brig"
	icon_state = "floor"
	network = "prison"

////////////	Setpeice & azone floors. Cause we have some of those simulated????

/turf/simulated/floor/setpeice
	name = "Setpeice/Azone floors"

////////////	the side turf files, thin what you see outside arrivals

/turf/simulated/floor/side
	name = "Floor edges"
