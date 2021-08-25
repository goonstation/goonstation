/obj/item/roboupgrade/thermaloptics
	name = "cyborg Thermal Vision Upgrade"
	desc = "An advanced vision array that allows a cyborg to see further in the dark, in addition to fully cloaked beings."
	icon_state = "up-thermal"
	drainrate = 10

	upgrade_activate(var/mob/living/silicon/robot/user as mob)
		if (..())
			return
		APPLY_MOB_PROPERTY(user, PROP_THERMALVISION, src)


	upgrade_deactivate(var/mob/living/silicon/robot/user as mob)
		if (..())
			return
		REMOVE_MOB_PROPERTY(user, PROP_THERMALVISION, src)
