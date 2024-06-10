/obj/item/roboupgrade/sechudgoggles
	name = "cyborg Security HUD upgrade"
	desc = "A hardened sensor array that indicates the current criminal status of humanoids."
	icon_state = "up-sechud"
	drainrate = 5

	upgrade_activate(var/mob/living/silicon/robot/user as mob)
		if (..())
			return
		get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).add_mob(user)

	upgrade_deactivate(var/mob/living/silicon/robot/user as mob)
		if (..())
			return
		get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(user)
