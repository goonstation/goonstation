var/datum/maint_critter_controller/critter_controller

proc/initialize_maint_critter_controller()
	global.critter_controller = new
	global.critter_controller.populate_maintenance_areas()

/datum/maint_critter_controller
	var/list/turfs_by_area = list()

/datum/maint_critter_controller/New()
	..()
	var/list/turfs = get_area_turfs(/area/station/maintenance, TRUE)
	for (var/turf/T as anything in turfs)
		var/area/A = get_area(T)
		if (!(A in turfs_by_area))
			turfs_by_area[A] = list()
		turfs_by_area[A] += T

/datum/maint_critter_controller/proc/populate_maintenance_areas()
	for (var/area/station/maintenance/maint as anything in src.turfs_by_area)
		for (var/i in 1 to maint.max_maint_critters)
			maint.spawn_maint_critter(pick(turfs_by_area[maint]))

/datum/maint_critter_controller/proc/spawn_scheduled_critters()
	for (var/area/station/maintenance/A as anything in src.turfs_by_area)
		if (length(A.maint_critters) >= A.max_maint_critters)
			continue
		var/list/available_turfs = src.turfs_by_area[A]
		for (var/i in 1 to 10)
			var/turf/T = pick(available_turfs)
			if (!isfloor(T))
				continue
			A.spawn_maint_critter(T)
			break

/datum/maint_critter_controller/proc/check_critter_locations()
	for (var/area/station/maintenance/A as anything in src.turfs_by_area)
		for (var/mob/living/critter/C as anything in A.maint_critters)
			if (get_area(C) != A)
				A.process_critter_death(C)
