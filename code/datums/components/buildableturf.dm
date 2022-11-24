

/datum/component/buildable_turf

TYPEINFO(/datum/component/buildable_turf)
	initialization_args = list()

/datum/component/buildable_turf/Initialize()
	if(!istype(parent, /turf))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATTACKBY, .proc/check_build_item)
	var/turf/unsimulated/T = parent
	if(istype(T))
		T.can_replace_with_stuff = TRUE

/datum/component/buildable_turf/proc/check_build_item(turf/location, obj/item/I, mob/user)
	PRIVATE_PROC(TRUE)
	var/area/A = get_area(user)

	if (istype(I, /obj/item/tile))
		if (istype(A, /area/supply/spawn_point || /area/supply/delivery_point || /area/supply/sell_point))
			boutput(user, "<span class='alert'>You can't build here.</span>")
			return TRUE

		var/obj/item/tile/T = I
		if (T.amount >= 1)
			for(var/obj/lattice/L in location)
				qdel(L)
			playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 50, 1)
			T.build(location)
			T.vis_contents -= station_repair.ambient_obj
			return TRUE

	if(istype(I, /obj/item/rcd))
		var/obj/item/rcd/RCD = I
		if ((isrestrictedz(user.z) || isrestrictedz(location.z)) && !RCD.really_actually_bypass_z_restriction)
			boutput(user, "\The [RCD] won't work here for some reason. Oh well!")
			return

		if (BOUNDS_DIST(get_turf(RCD), get_turf(location)) > 0)
			return

		switch(RCD.mode)
			if (1)
				if (RCD.do_thing(user, location, "building a floor", RCD.matter_create_floor, RCD.time_create_floor))
					SPAWN(0.5)	// delay to not allow afterattack to trigger
						var/turf/simulated/floor/T = location.ReplaceWithFloor()
						T.inherit_area()
						T.setMaterial(getMaterial(RCD.material_name))
						clear_edge_overlays(location)
						T.vis_contents -= station_repair.ambient_obj
					return TRUE

/datum/component/buildable_turf/proc/clear_edge_overlays(turf/location)
	for (var/turf/T in orange(location,1))
		var/direction = get_dir(T,location)
		T.ClearSpecificOverlays("edge_[direction]")
