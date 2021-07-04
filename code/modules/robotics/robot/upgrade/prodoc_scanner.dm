/obj/item/roboupgrade/healthgoggles
	name = "cyborg ProDoc scanner upgrade"
	desc = "An advanced sensor array that allows a cyborg to quickly determine the physical condition of organic life."
	icon_state = "up-prodoc"
	drainrate = 5

/obj/item/roboupgrade/healthgoggles/upgrade_activate(var/mob/living/silicon/robot/user as mob)
	if (..())
		return
	get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_mob(user)

/obj/item/roboupgrade/healthgoggles/upgrade_deactivate(var/mob/living/silicon/robot/user as mob)
	if (..())
		return
	get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(user)
