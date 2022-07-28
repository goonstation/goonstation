/obj/item/roboupgrade/fireshield
	name = "cyborg heat shield upgrade"
	desc = "An air diffusion field that protects a cyborg from heat damage."
	icon_state = "up-Fshield"
	drainrate = 100
	borg_overlay = "up-fshield"
	var/damage_reduction = 4
	var/cell_drain_per_damage_reduction = 100
/obj/item/roboupgrade/fireshield/upgrade_activate(var/mob/living/silicon/robot/user)
	if (..())
		return
	APPLY_ATOM_PROPERTY(user,PROP_MOB_EXPLOPROT,src,30)

/obj/item/roboupgrade/fireshield/upgrade_deactivate(var/mob/living/silicon/robot/user)
	if (..())
		return
	REMOVE_ATOM_PROPERTY(user,PROP_MOB_EXPLOPROT,src)
