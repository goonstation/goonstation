/obj/item/roboupgrade/physshield
	name = "cyborg force shield upgrade"
	desc = "A force field generator that protects a cyborg from physical harm."
	icon_state = "up-Pshield"
	drainrate = 100
	borg_overlay = "up-pshield"
	borg_overlay_alpha = 125
	var/damage_reduction = 4
	var/cell_drain_per_damage_reduction = 100

/obj/item/roboupgrade/physshield/upgrade_activate(var/mob/living/silicon/robot/user)
	if (..())
		return
	APPLY_ATOM_PROPERTY(user,PROP_MOB_EXPLOPROT,"cyborg_shield",50)

/obj/item/roboupgrade/physshield/upgrade_deactivate(var/mob/living/silicon/robot/user)
	if (..())
		return
	REMOVE_ATOM_PROPERTY(user,PROP_MOB_EXPLOPROT,"cyborg_shield")
