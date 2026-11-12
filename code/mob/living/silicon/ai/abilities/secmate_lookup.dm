/datum/targetable/ai/program/sec_huds
	name = "Security Lookup Scan"
	desc = "Check someone's security records."
	targeted = TRUE
	target_anything = FALSE
	icon_state = "sec"

	disposing()
		get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(holder.owner)
		var/mob/living/silicon/ai/AI = holder.owner
		if(istype(AI) && AI.eyecam)
			get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(AI.eyecam)

		. = ..()

	onAttach(datum/abilityHolder/H)
		. = ..()
		get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).add_mob(H.owner)
		var/mob/living/silicon/ai/AI = holder.owner
		if(istype(AI) && AI.eyecam)
			get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).add_mob(AI.eyecam)

	cast(atom/target)
		if (..())
			return 1

		if (istype(src.holder.owner, /mob/living/silicon/ai))
			var/mob/living/silicon/ai/AI = src.holder.owner

			var/datum/db_record/GR = data_core.general.find_record("name", target.name)
			var/datum/db_record/SR = data_core.security.find_record("name", target.name)
			if (!SR)
				return SPAN_ALERT("ERROR: NO RECORD FOUND")

			//Find security records program
			var/list/programs = null
			for (var/obj/item/disk/data/mod in AI.internal_pda.contents)
				programs += mod.root.contents.Copy()
			var/datum/computer/file/pda_program/records/security/record_prog = locate(/datum/computer/file/pda_program/records/security) in programs
			if (!record_prog)
				return SPAN_ALERT("ERROR: NO SECURITY RECORD FILE")
			AI.internal_pda.run_program(record_prog)
			record_prog.active1 = GR
			record_prog.active2 = SR
			record_prog.mode = 1
			AI.internal_pda.AttackSelf(usr)
