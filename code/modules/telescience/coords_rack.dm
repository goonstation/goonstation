/// Long-range teleporter disk rack
/obj/machinery/disk_rack/telesci
	name = "coordinates disk rack"
	desc = "A big clunky rack to load and save remote coordinates."
	icon_state = "disk_rack_lrt"
	var/list/blink_until[DISK::RACK::MAX_DISKS]
	var/blink_duration = 10 SECONDS

// TODO: Telesci console requires disks to use? Would need backup measures for disks?
// TODO: Network connected

/obj/machinery/disk_rack/telesci/New()
	. = ..()
	// tracking for LRT usage to trigger our lights
	START_TRACKING

/obj/machinery/disk_rack/telesci/disposing()
	STOP_TRACKING
	. = ..()

/obj/machinery/disk_rack/telesci/insert_disk(index, obj/item/disk/data/disk, mob/user)
	. = ..()
	if (!.)
		return

	for(var/datum/computer/file/lrt_data/galactic_position in disk.root.contents)
		if(global.special_places.Find(galactic_position.place_name))
			continue // already saved

		var/target
		for(var/turf/T in landmarks[LANDMARK_LRT])
			var/name = landmarks[LANDMARK_LRT][T]
			if(name == galactic_position.place_name)
				target = T
				break
		if (!target)
			continue // we didnt find a turf to send to
		else
			global.special_places.Add(galactic_position.place_name)

/// Returns a list of location Names on a given disk
/obj/machinery/disk_rack/telesci/proc/get_locations_on_disk(obj/item/disk/data/disk)
	RETURN_TYPE(/list)
	. = list()
	for(var/datum/computer/file/lrt_data/galactic_position in disk.root.contents)
		var/target
		for(var/turf/T in landmarks[LANDMARK_LRT])
			var/name = landmarks[LANDMARK_LRT][T]
			if(name == galactic_position.place_name)
				target = T
				break
		if (!target)
			continue // we didnt find a turf to send to

		. += galactic_position.place_name

// TODO: abstract disk light into common behaviour and flag

/obj/machinery/disk_rack/telesci/special_disk_data(obj/item/disk/data/floppy/disk, index)
	if (status & NOPOWER)
		return list("light" = FALSE)
	return list("light" = src.active_lights[index])

/obj/machinery/disk_rack/telesci/ui_data(mob/user)
	return ..() + list("has_lights" = TRUE)

/obj/machinery/disk_rack/telesci/process(mult)
	src.update_lights()

/obj/machinery/disk_rack/telesci/remove_disk(index, mob/user)
	. = ..()
	src.update_lights()

#define LIGHT_KEY "angry_light_[i]"

/obj/machinery/disk_rack/telesci/power_change()
	..()
	if (status & NOPOWER)
		for (var/i in 1 to DISK::RACK::MAX_DISKS)
			src.ClearSpecificOverlays(LIGHT_KEY)

/obj/machinery/disk_rack/telesci/proc/disk_should_blink(disk_slot)
	if(!disk_slot || disk_slot > DISK::RACK::MAX_DISKS)
		return FALSE
	if (!src.disks[disk_slot])
		return FALSE
	if (src.blink_until[disk_slot] > TIME)
		return TRUE
	return FALSE

/obj/machinery/disk_rack/telesci/proc/update_lights()
	if (status & NOPOWER)
		return
	for (var/i in 1 to DISK::RACK::MAX_DISKS)
		var/obj/item/disk/data/floppy/disk = src.disks[i]
		if (!disk || !src.disk_should_blink(i))
			src.active_lights[i] = FALSE
			src.ClearSpecificOverlays(LIGHT_KEY)
			continue
		src.active_lights[i] = TRUE
		if (src.GetOverlayImage(LIGHT_KEY))
			continue
		var/image/overlay = image(src.icon, "angry_light")
		overlay.plane = PLANE_SELFILLUM
		overlay.pixel_y = (i-1) * 2
		src.UpdateOverlays(overlay, LIGHT_KEY)
#undef LIGHT_KEY

/obj/machinery/disk_rack/telesci/proc/set_destination_light(location_name)
	for (var/i in 1 to DISK::RACK::MAX_DISKS)
		var/obj/item/disk/data/floppy/disk = src.disks[i]
		if (!disk)
			continue
		if (location_name in src.get_locations_on_disk(disk))
			src.blink_until[i] = TIME + src.blink_duration

TYPEINFO(/obj/machinery/disk_rack/telesci/prefilled)
	manufactured_type = /obj/machinery/disk_rack/telesci
/obj/machinery/disk_rack/telesci/prefilled
	initialize()
		. = ..()
		var/i = 1
		for (var/type in list(/obj/item/disk/data/floppy/lrt/observatory, /obj/item/disk/data/floppy/lrt/luna_museum))
			src.insert_disk(i++, new type)

/obj/spawner/disk_rack_lrt
	icon = 'icons/obj/disk_rack.dmi'
	icon_state = "spawner_lrt"

	New()
		. = ..()
		var/obj/machinery/disk_rack/telesci/prefilled/prefilled_rack = new(get_turf(src))
		prefilled_rack.pixel_x = 8
		var/obj/machinery/disk_rack/telesci/empty_rack = new(get_turf(src))
		empty_rack.pixel_x = -8
		qdel(src)
