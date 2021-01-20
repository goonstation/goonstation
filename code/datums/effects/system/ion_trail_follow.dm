/datum/effects/system/ion_trail_follow
	var/atom/holder
	var/turf/oldposition
	var/processing = 1
	var/on = 1
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

/datum/effects/system/ion_trail_follow/proc/start() //todo : process loop. no spawn loop, ew
	if(!src.on)
		src.on = 1
		src.processing = 1
	if(src.processing)
		src.processing = 0
		SPAWN_DBG(0)
			var/turf/T = get_turf(src.holder)
			if(T != src.oldposition)
				if(istype(T, /turf/space) || (istype(holder, /obj/machinery/vehicle) && (istype(T, /turf/simulated) && T:allows_vehicles)) )
					if (istext(istate) && istate != "blank")
						var/obj/effects/ion_trails/I = unpool(/obj/effects/ion_trails)
						I.set_loc(src.oldposition)
						src.oldposition = T
						I.set_dir(src.holder.dir)
						flick(istate, I)
						I.icon_state = "blank"
						I.pixel_x = xoffset
						I.pixel_y = yoffset
						SPAWN_DBG( 20 )
							if (I && !I.disposed) pool(I)
				SPAWN_DBG(0.2 SECONDS)
					if(src.on)
						src.processing = 1
						src.start()
			else
				SPAWN_DBG(0.2 SECONDS)
					if(src.on)
						src.processing = 1
						src.start()

/datum/effects/system/ion_trail_follow/proc/stop()
	src.processing = 0
	src.on = 0
