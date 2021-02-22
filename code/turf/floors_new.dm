/*
	Don't forget to use the generate_turf macro on any new turfs you add!

	simulated/floor		The inital floor turf, required to set variables for the others
	floor/pattern			Pattern floors, like the checkers you see around the station or in the chapel
	floor/decal				Decal pattern floors, ie the big sign outside manta's security
	floor/full				Fully-Coloured floors, think stuff like the white tiles in medical bag
	floor/misc				Random misc floors, such as the blob's floor
	floor/setpeice		Setpeice & azone floors. Cause we have some of those simulated?
	floor/side				The side turf floors, think what you see outside arrivals
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

////////////	Pattern floors

/turf/simulated/floor/pattern
	name = "Pattern Floors"
	icon_state = ""

////////////	Decal pattern floors

/turf/simulated/floor/decal
	name = "Decal Floors"
	icon_state = ""

////////////	Fully-Coloured floors

/turf/simulated/floor/full
	name = "Fully-Coloured Floors"
	icon_state = ""

////////////	Random misc floors

/turf/simulated/floor/misc
	name = "Miscellaneous Floors"
	icon_state = ""

////////////	Setpeice & azone floors

/turf/simulated/floor/setpeice
	name = "Setpeice/Azone floors"
	icon_state = ""

////////////	The side turf floors

/turf/simulated/floor/side
	name = "Floor edges"
	icon_state = ""
