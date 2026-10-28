/datum/targetable/ai/module/sec_huds
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

		var/obj/item/aiModule/ability_expansion/security_vision/expansion = src.get_law_module()
		var/obj/machinery/computer3/generic/secure_data/sec_comp = expansion.sec_comp
		sec_comp.Attackhand(src.holder.owner)

		// Issuing commands to a computer this way is a little cursed, but then again so is putting a computer inside an AI module.
		if (sec_comp.active_program.authenticated)
			sec_comp.unload_program(sec_comp.active_program)
		else
			sec_comp.active_program.input_text("login")

		sleep(1)
		sec_comp.active_program.input_text("SecMate")
		sleep(1)
		sec_comp.active_program.input_text("2")
		sleep(1)
		sec_comp.active_program.input_text(target.name)
