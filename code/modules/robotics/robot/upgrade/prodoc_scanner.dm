/obj/item/roboupgrade/healthgoggles
	name = "cyborg ProDoc scanner upgrade"
	desc = "An advanced sensor array that allows a cyborg to quickly determine the physical condition of organic life."
	icon_state = "up-prodoc"
	drainrate = 5

/obj/item/roboupgrade/healthgoggles/upgrade_activate(var/mob/living/silicon/robot/user)
	if (..())
		return
	APPLY_ATOM_PROPERTY(user,PROP_MOB_EXAMINE_HEALTH,src)
	get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_mob(user)

/obj/item/roboupgrade/healthgoggles/upgrade_deactivate(var/mob/living/silicon/robot/user)
	if (..())
		return
	REMOVE_ATOM_PROPERTY(user,PROP_MOB_EXAMINE_HEALTH,src)
	get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(user)
