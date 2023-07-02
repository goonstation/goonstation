/obj/mapping_helper/turfs
	layer = TURF_LAYER

/obj/mapping_helper/turfs/burner
	icon = 'icons/turf/floors.dmi'
	icon_state = "floorscorched1"

	setup()
		var/turf/simulated/floor/T = src.loc
		if (istype(T, /turf/unsimulated/floor) || istype(T, /turf/simulated/floor))
			T.burn_tile()

/obj/mapping_helper/turfs/damager
	icon = 'icons/turf/floors.dmi'
	icon_state = "damaged1"

	setup()
		var/turf/simulated/floor/T = src.loc
		if (istype(T, /turf/unsimulated/floor) || istype(T, /turf/simulated/floor))
			T.break_tile()
