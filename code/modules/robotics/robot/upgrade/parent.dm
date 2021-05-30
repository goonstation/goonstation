ABSTRACT_TYPE(/obj/item/roboupgrade)
/obj/item/roboupgrade
	name = "cyborg upgrade"
	desc = "A non-functional upgrade for a cyborg."
	icon = 'icons/obj/robot_parts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"

	// Is this upgrade used like an item?
	var/active = 0
	// Does this upgrade always work once installed?
	var/passive = 0
	// live ingame variable
	var/activated = 0
	// How much charge the upgrade consumes while installed
	var/drainrate = 0
	// How many times a limited upgrade can be used before it is consumed (infinite if negative)
	var/charges = -1
	// Can be removed from the cyborg
	var/removable = 1
	// Used for cyborg update_appearance proc
	var/borg_overlay = null

/obj/item/roboupgrade/attack_self(mob/user as mob)
	if (!isrobot(user))
		boutput(user, "<span class='alert'>Only cyborgs can activate this item.</span>")
	else
		if (!src.activated)
			src.upgrade_activate()
		else
			src.upgrade_deactivate()

/obj/item/roboupgrade/proc/upgrade_activate(mob/living/silicon/robot/user as mob)
	if (!user)
		return 1
	if (!src.activated)
		src.activated = 1

/obj/item/roboupgrade/proc/upgrade_deactivate(mob/living/silicon/robot/user as mob)
	if (!user)
		return 1
	src.activated = 0
