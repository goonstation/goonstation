obj/movable

	icon = 'icons/turf/shuttle.dmi'

	anchored = 1

	var/tmp/obj/hotspot/active_hotspot
	var/blocks_air = 0

	proc
		teleport(turf/destination)
			for(var/atom/movable/AM in loc)
				AM.set_loc(destination)

	CanPass(atom/movable/mover, turf/target, height, air_group)
		if(!height || air_group)
			return !blocks_air
		else return ..()
	
	New()
		..()
		air = unpool(/datum/gas_mixture)
		
	disposing()
		if(air)
			pool(air)
			air = null
		..()
		
		
	wall
		icon_state = "wall"
		opacity = 1
		density = 1
		blocks_air = 1

	floor

		icon_state = "floor"

		var
			oxygen = 0
			nitrogen = 0
			carbon_dioxide = 0
			toxins = 0

			temperature = T20C

			tmp
				air_check_directions = 0
				group_border = 0
				processing
				archived_cycle = 0
				current_cycle = 0

				datum/air_group/object/parent
				datum/gas_mixture/air

		proc
			process_cell()
			update_air_properties()

			archive()
			mimic_air_with_tile()
			share_air_with_tile()

