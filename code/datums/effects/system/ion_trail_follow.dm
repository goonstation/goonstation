/datum/effects/system/ion_trail_follow
	var/atom/holder
	var/turf/oldposition
	var/on = 0
	var/xoffset = 0
	var/yoffset = 0
	var/istate = "ion_fade"

/datum/effects/system/ion_trail_follow/proc/set_up(atom/atom, pixel_offset = 0, state = 0)
	holder = atom
	oldposition = get_turf(atom)
	if (pixel_offset)
		xoffset = pixel_offset
		yoffset = pixel_offset
	if (state)
		istate = state

/datum/effects/system/ion_trail_follow/proc/on_vehicle_move(atom/movable/vehicle, atom/previous_loc, direction)
	var/turf/T = get_turf(vehicle)
	var/has_trailblazer = FALSE
	var/has_afterburner = FALSE
	if (istype(vehicle, /obj/machinery/vehicle))
		var/obj/machinery/vehicle/mover = vehicle
		if (istype(mover.sec_system, /obj/item/shipcomponent/secondary_system/trailblazer))
			has_trailblazer = TRUE
		else if (istype(mover.sec_system, /obj/item/shipcomponent/secondary_system/thrusters/afterburner))
			var/obj/item/shipcomponent/secondary_system/thrusters/afterburner/afterburner = mover.sec_system
			has_afterburner = afterburner.active
	if(T != src.oldposition)
		if(istype(oldposition, /turf) && istype(T, /turf/space) || (istype(vehicle, /obj/machinery/vehicle) && (istype(T, /turf/simulated) && T:allows_vehicles)) )
			if (istext(istate) && istate != "blank")
				if(src.oldposition)
					var/obj/I
					if (!has_trailblazer)
						I = new /obj/effects/ion_trails
						if (has_afterburner)
							I.color = "#ff09de"
						src.oldposition.vis_contents += I
						FLICK(istate, I)
						I.icon_state = "blank"
					else
						I = new /atom/movable/hotspot/chemfire(src.oldposition, CHEM_FIRE_BLUE)
					I.pixel_x = xoffset
					I.pixel_y = yoffset
					I.set_dir(direction)
					SPAWN(2 SECONDS)
						if (I && !I.disposed)
							if (!has_trailblazer)
								var/turf/vis_loc = I.vis_locs[1]
								vis_loc.vis_contents -= I
							qdel(I)
				src.oldposition = T

/datum/effects/system/ion_trail_follow/proc/start() //todo : process loop. no spawn loop, ew
	if(!src.on)
		src.on = 1
		RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_vehicle_move))

/datum/effects/system/ion_trail_follow/proc/stop()
	src.on = 0
	UnregisterSignal(holder, COMSIG_MOVABLE_MOVED)
