/obj/item/roboupgrade/jetpack
	name = "cyborg propulsion upgrade"
	desc = "A small jetpack allowing cyborgs to move freely in space."
	icon_state = "up-jetpack"
	drainrate = 25
	borg_overlay = "up-jetpack"

/obj/item/roboupgrade/jetpack/upgrade_activate(var/mob/living/silicon/robot/user as mob)
	if (..())
		return
	user.jetpack = 1

/obj/item/roboupgrade/jetpack/upgrade_deactivate(var/mob/living/silicon/robot/user as mob)
	if (..())
		return
	user.jetpack = 0
