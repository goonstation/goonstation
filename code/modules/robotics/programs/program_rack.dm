// TODO: Flash light when hologram, abilities, or skills are in use?

/obj/machinery/disk_rack/ai
	name = "\improper AI program disk rack"
	desc = "A disk rack for uploading AI-compatible programs from floppy disks."
	icon_state = "disk_rack_wide_ai"
	disk_overlay_state = "disk_overlay_wide"
	accepted_disk_type = /obj/item/disk/data/wide_floppy
	var/obj/machinery/lawrack/linked_rack

	var/can_track = FALSE
	var/can_call_shuttle = FALSE
	var/viewport_limit = 0

	var/list/ai_abilities = list()
	var/list/hologram_libraries = list()
	var/list/ai_skills = list()

	New()
		. = ..()
		START_TRACKING
		src.attempt_claim()

	disposing()
		STOP_TRACKING
		src.linked_rack?.link_to_program_rack(null)
		for (var/i in 1 to DISK::RACK::MAX_DISKS)
			if (disks[i])
				src.remove_disk(i)
		. = ..()

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/device/borg_linker))
			var/obj/item/device/borg_linker/linker = I
			if (!linker.linked_rack)
				user?.show_message(SPAN_ALERT("\The [linker] isn't linked to a law rack!"))
				return
			if (src.linked_rack == linker.linked_rack)
				user?.show_message(SPAN_ALERT("[src] is already linked to the same law rack as \the [linker]!"))
				return
			if (src.linked_rack)
				if (user)
					if (tgui_alert(user, "This is linked to [src.linked_rack], really change the linked rack?", "Change Linked Rack", list("Yes", "No")) != "Yes")
						return
			linker.linked_rack.link_to_program_rack(src)
			src.linked_rack = linker.linked_rack
			return
		. = ..()

	get_desc(dist, mob/user)
		. = ..()
		. += "<br>It is [src.linked_rack ? "" : "NOT "]linked to a law rack."

	power_change()
		. = ..()
		src.update_offerings()

	was_deconstructed_to_frame(mob/user)
		. = ..()
		src.update_offerings()
		src.linked_rack?.link_to_program_rack(null)
		src.linked_rack = null

	was_built_from_frame(mob/user, newly_built)
		. = ..()
		src.update_offerings()

	insert_disk(index, obj/item/disk/data/disk, mob/user)
		. = ..()
		src.update_offerings()

	remove_disk(index, mob/user)
		. = ..()
		src.update_offerings()

	proc/attempt_claim()
		if (ticker?.ai_law_rack_manager?.default_ai_rack?.program_rack)
			return
		ticker?.ai_law_rack_manager?.default_ai_rack?.link_to_program_rack(src)

	proc/update_offerings()
		if (src.status & (NOPOWER|BROKEN))
			src.ai_abilities = list()
			src.hologram_libraries = list()
			src.ai_skills = list()
			return

		var/list/new_abilities = list()
		var/list/new_holograms = list()
		var/list/new_skills = list()

		for(var/i in 1 to DISK::RACK::MAX_DISKS)
			var/obj/item/disk/data/disk = src.disks[i]
			if (!disk)
				continue
			for (var/datum/computer/file/ai_program/ai_program in disk.root.contents)
				if (istype(ai_program, /datum/computer/file/ai_program/ability))
					var/datum/computer/file/ai_program/ability/ability = ai_program
					new_abilities |= ability.ai_abilities
				else if (istype(ai_program, /datum/computer/file/ai_program/hologram))
					var/datum/computer/file/ai_program/hologram/holo = ai_program
					new_holograms |= holo.hologram_set
				else if (istype(ai_program, /datum/computer/file/ai_program/skill))
					var/datum/computer/file/ai_program/skill/skill = ai_program
					new_skills |= skill.skill

		src.ai_abilities = new_abilities
		src.hologram_libraries = new_holograms
		src.ai_skills = new_skills

		if (src.ai_skills.Find(SILICON::AI::SKILL::TRACKING))
			src.can_track = TRUE
		else
			src.can_track = FALSE

		if (src.ai_skills.Find(SILICON::AI::SKILL::VIEWPORT))
			if (src.ai_skills.Find(SILICON::AI::SKILL::VIEWPORT_EXP))
				src.viewport_limit = 3
			else
				src.viewport_limit = 2
		else
			src.viewport_limit = 0

		src.linked_rack?.update_ai_programs()

/obj/machinery/disk_rack/ai/ui_data(mob/user)
	return ..() + list("is_wide" = TRUE)

TYPEINFO(/obj/machinery/disk_rack/ai/prefilled)
	manufactured_type = /obj/machinery/disk_rack/ai
/// Program Rack with basic programs
/obj/machinery/disk_rack/ai/prefilled
	initialize()
		. = ..()
		var/i = 1
		for (var/typepath in list(
			/obj/item/disk/data/wide_floppy/read_only/ai_program/hologram/standard,
			/obj/item/disk/data/wide_floppy/read_only/ai_program/tracking,
			/obj/item/disk/data/wide_floppy/read_only/ai_program/viewports,
			/obj/item/disk/data/wide_floppy/read_only/ai_program/call_shuttle
		))
			src.insert_disk(i++, new typepath)

TYPEINFO(/obj/machinery/disk_rack/ai/syndicate)
	manufactured_type = /obj/machinery/disk_rack/ai
/obj/machinery/disk_rack/ai/syndicate
	desc = "A disk rack for uploading AI-compatible programs from floppy disks. This one has a tiny S motif on the top."
	icon_state = "disk_rack_wide_ai_syn"

	initialize()
		. = ..()
		var/i = 1
		for (var/typepath in list(
			/obj/item/disk/data/wide_floppy/read_only/ai_program/hologram/syndicate,
			/obj/item/disk/data/wide_floppy/read_only/ai_program/tracking,
			/obj/item/disk/data/wide_floppy/read_only/ai_program/viewports,
		))
			src.insert_disk(i++, new typepath)

	attempt_claim()
		if (ticker?.ai_law_rack_manager?.default_ai_rack_syndie?.program_rack)
			return
		ticker?.ai_law_rack_manager?.default_ai_rack_syndie?.link_to_program_rack(src)
