/datum/targetable/ai/module/prodocs
	name = "Camera Scan"
	desc = "Scan basic vitals on someone."
	targeted = TRUE
	target_anything = FALSE
	icon_state = "prodoc"

	disposing()
		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(holder.owner)
		var/mob/living/silicon/ai/AI = holder.owner
		if(istype(AI) && AI.eyecam)
			get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(AI.eyecam)
		. = ..()

	onAttach(datum/abilityHolder/H)
		. = ..()
		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_mob(H.owner)
		var/mob/living/silicon/ai/AI = holder.owner
		if(istype(AI) && AI.eyecam)
			get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_mob(AI.eyecam)

	cast(atom/target)
		if (..())
			return 1
		boutput(holder.owner, scan_health(target, disease_detection=FALSE, visible=TRUE))
