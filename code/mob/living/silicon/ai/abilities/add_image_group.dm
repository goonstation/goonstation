ABSTRACT_TYPE(/datum/targetable/ai/program/add_image_group)
/datum/targetable/ai/program/add_image_group
	var/image_group = CLIENT_IMAGE_GROUP_ARREST_ICONS
	var/on = TRUE

/datum/targetable/ai/program/add_image_group/onAttach(datum/abilityHolder/H)
	. = ..()
	get_image_group(image_group).add_mob(H.owner)
	var/mob/living/silicon/ai/AI = holder.owner
	if(istype(AI) && AI.eyecam)
		get_image_group(image_group).add_mob(AI.eyecam)

/datum/targetable/ai/program/add_image_group/disposing()
	get_image_group(image_group).remove_mob(holder.owner)
	var/mob/living/silicon/ai/AI = holder.owner
	if(istype(AI) && AI.eyecam)
		get_image_group(image_group).remove_mob(AI.eyecam)
	. = ..()

/datum/targetable/ai/program/add_image_group/cast(atom/target)
	. = ..()
	if (src.on)
		get_image_group(image_group).remove_mob(holder.owner)
		var/mob/living/silicon/ai/AI = holder.owner
		if(istype(AI) && AI.eyecam)
			get_image_group(image_group).remove_mob(AI.eyecam)
	else
		get_image_group(image_group).add_mob(holder.owner)
		var/mob/living/silicon/ai/AI = holder.owner
		if(istype(AI) && AI.eyecam)
			get_image_group(image_group).add_mob(AI.eyecam)
	src.on = !src.on
	boutput(src.holder.owner, SPAN_NOTICE("Turned [src.name] [src.on ? "on" : "off"]."))

/datum/targetable/ai/program/add_image_group/sechud
	name = "SecHud Vision"
	desc = "Toggle seeing arrest icons."
	icon_state = "vis_sec"
	image_group = CLIENT_IMAGE_GROUP_ARREST_ICONS

/datum/targetable/ai/program/add_image_group/prodoc
	name = "ProDoc Vision"
	desc = "Toggle seeing health icons."
	icon_state = "vis_doc"
	image_group = CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS

/datum/targetable/ai/program/add_image_group/mechcomp
	name = "MechComp Vision"
	desc = "Toggle seeing MechComp connections."
	icon_state = "vis_mech"
	image_group = CLIENT_IMAGE_GROUP_MECHCOMP

/datum/targetable/ai/program/add_image_group/mining
	name = "Mining Vision"
	desc = "Toggle seeing geological anomalies."
	icon_state = "vis_geo"
	image_group = CLIENT_IMAGE_GROUP_GEOLOGICAL_ANOMALIES
