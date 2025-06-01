/obj/linked_laser/ptl
	name = "laser"
	desc = "A powerful laser beam."
	icon = 'icons/obj/lasers/ptl_beam.dmi'
	icon_state = "ptl_beam"
	event_handler_flags = USE_FLUID_ENTER
	var/obj/machinery/power/pt_laser/source = null

/obj/linked_laser/ptl/New(loc, dir)
	..()
	src.add_simple_light("laser_beam", list(0, 0.8 * 255, 0.1 * 255, 255))

/obj/linked_laser/ptl/proc/update_source_power()
	src.alpha = clamp(((log(10, max(1,src.source.laser_power() * src.power)) - 5) * (255 / 5)), 50, 255) //50 at ~1e7 255 at 1e11 power, the point at which the laser's most deadly effect happens

/obj/linked_laser/ptl/try_propagate()
	. = ..()
	var/turf/T = get_next_turf()
	if (!T || istype(T, /turf/unsimulated/wall/trench)) //edge of z_level or oshan trench
		var/obj/laser_sink/ptl_seller/seller = get_singleton(/obj/laser_sink/ptl_seller)
		if (seller.incident(src))
			src.sink = seller
	var/power = src.source.laser_power()
	src.update_source_power()
	if(istype(src.loc, /turf/simulated/floor) && prob(power/1 MEGA WATT))
		src.loc:burn_tile()

	for (var/mob/living/L in src.loc)
		if (isintangible(L))
			continue
		if (!source.burn_living(L,power)) //burn_living() returns 1 if they are gibbed, 0 otherwise
			source.affecting_mobs |= L

/obj/linked_laser/ptl/copy_laser(turf/T, dir)
	var/wonky = FALSE //are we randomly turning?
	var/wonky_facing = -1 //var to mimic the PTL mirror's facing system so we can use the same corner icon states
	if (src.source.wacky && prob(10))
		wonky = TRUE
		dir = turn(dir, pick(-90, 90))
		if ((src.dir | dir) in list(NORTHWEST, SOUTHEAST))
			wonky_facing = 1
		else
			wonky_facing = 0

	var/obj/linked_laser/ptl/new_laser = ..(T, dir)
	new_laser.source = src.source

	if (wonky)
		new_laser.icon_state = src.get_corner_icon_state(wonky_facing)
	return new_laser

/obj/linked_laser/ptl/Crossed(atom/movable/AM)
	..()
	if (QDELETED(src))
		return
	if (isliving(AM) && !isintangible(AM))
		if (!src.source.burn_living(AM, src.source.laser_power())) //burn_living() returns 1 if they are gibbed, 0 otherwise
			source.affecting_mobs |= AM

/obj/linked_laser/ptl/Uncrossed(var/atom/movable/AM)
	if(isliving(AM) && source)
		source.affecting_mobs -= AM
	..()

/obj/linked_laser/ptl/proc/burn_all_living_contents()
	for(var/mob/living/L in src.loc)
		if(src.source.burn_living(L,src.source.laser_power()) && source) //returns 1 if they were gibbed
			source.affecting_mobs -= L

/obj/linked_laser/ptl/become_endpoint()
	..()
	var/turf/next_turf = get_next_turf()
	if (next_turf?.density)
		src.source.blocking_objects |= next_turf
	for (var/obj/object in next_turf)
		if (src.is_blocking(object))
			src.source.blocking_objects |= object

/obj/linked_laser/ptl/release_endpoint()
	..()
	var/turf/next_turf = get_next_turf()
	src.source.blocking_objects -= next_turf
	for (var/obj/object in next_turf)
		if (src.is_blocking(object))
			src.source.blocking_objects -= object

/obj/linked_laser/ptl/disposing()
	src.remove_simple_light("laser_beam")
	src.next?.previous = null
	src.previous?.next = null
	..()
