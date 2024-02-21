/obj/item/roboupgrade/spectro
	name = "cyborg spectroscopic scanner upgrade"
	desc = "A sensor array that provides a readout of the chemical composition of substances that are examined."
	icon_state = "up-spectro"
	drainrate = 5

/obj/item/roboupgrade/spectro/upgrade_activate(var/mob/living/silicon/robot/user as mob)
	if (..())
		return
	APPLY_ATOM_PROPERTY(user, PROP_MOB_SPECTRO, src)

/obj/item/roboupgrade/spectro/upgrade_deactivate(var/mob/living/silicon/robot/user as mob)
	if (..())
		return
	REMOVE_ATOM_PROPERTY(user, PROP_MOB_SPECTRO, src)
