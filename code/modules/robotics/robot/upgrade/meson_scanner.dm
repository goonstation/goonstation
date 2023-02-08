/obj/item/roboupgrade/opticmeson
	name = "cyborg optical meson upgrade"
	desc = "A sensing array that enables a cyborg to see into the meson spectrum."
	icon_state = "up-opticmes"
	drainrate = 5
	borg_overlay = "up-meson"

/obj/item/roboupgrade/opticmeson/upgrade_activate(var/mob/living/silicon/robot/user)
	if (..())
		return
	get_image_group(CLIENT_IMAGE_GROUP_MESON).add_mob(user)

/obj/item/roboupgrade/opticmeson/upgrade_deactivate(var/mob/living/silicon/robot/user)
	if (..())
		return
	get_image_group(CLIENT_IMAGE_GROUP_MESON).remove_mob(user)

