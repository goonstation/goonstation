// TODO: Flash light when hologram, abilities, or skills are in use?

/obj/machinery/disk_rack/ai
	name = "AI Program Disk Rack"
	desc = "A disk rack for uploading AI-compatible programs from floppy disks."
	icon_state = "disk_rack_ai"
	accepted_disk_type = /obj/item/disk/data/floppy

	var/list/ai_abilities = list()
	var/list/hologram_libraries = list()
	var/list/ai_skills = list()

	New()
		. = ..()
		START_TRACKING
		src.trigger_ai_update()

	disposing()
		STOP_TRACKING
		for (var/i in 1 to MAX_DISKS)
			if (disks[i])
				src.remove_disk(i)
		src.trigger_ai_update()
		. = ..()

	power_change()
		. = ..()
		src.trigger_ai_update()

	was_deconstructed_to_frame(mob/user)
		. = ..()
		src.trigger_ai_update()

	was_built_from_frame(mob/user, newly_built)
		. = ..()
		src.trigger_ai_update()

	insert_disk(index, obj/item/disk/data/disk, mob/user)
		. = ..()
		src.trigger_ai_update()

	remove_disk(index, mob/user)
		. = ..()
		src.trigger_ai_update()

	proc/trigger_ai_update()
		if (src.status & (NOPOWER|BROKEN))
			src.ai_abilities = list()
			src.hologram_libraries = list()
			src.ai_skills = list()
			for_by_tcl(AI, /mob/living/silicon/ai)
				AI.update_programs()
			return

		var/list/new_abilities = list()
		var/list/new_holograms = list()
		var/list/new_skills = list()

		for(var/i in 1 to 8)
			var/obj/item/disk/data/floppy/disk = src.disks[i]
			if (!disk)
				continue
			for (var/datum/computer/file/ai_program/ai_program in disk.root.contents)
				if (istype(ai_program, /datum/computer/file/ai_program/ability))
					var/datum/computer/file/ai_program/ability/ability = ai_program
					new_abilities += ability.ai_abilities
				else if (istype(ai_program, /datum/computer/file/ai_program/hologram))
					var/datum/computer/file/ai_program/hologram/holo = ai_program
					new_holograms += holo.hologram_set
				else if (istype(ai_program, /datum/computer/file/ai_program/skill))
					var/datum/computer/file/ai_program/skill/skill = ai_program
					new_skills += skill.skill

		src.ai_abilities = new_abilities
		src.hologram_libraries = new_holograms
		src.ai_skills = new_skills

		for_by_tcl(AI, /mob/living/silicon/ai)
			AI.update_programs()

/// Program Rack with basic programs
/obj/machinery/disk_rack/ai/prefilled
	initialize()
		. = ..()
		var/i = 1
		for (var/typepath in list(/obj/item/disk/data/floppy/read_only/ai_program/hologram/standard,/obj/item/disk/data/floppy/read_only/ai_program/tracking,/obj/item/disk/data/floppy/read_only/ai_program/viewports,/obj/item/disk/data/floppy/read_only/ai_program/call_shuttle))
			src.insert_disk(i++, new typepath)
