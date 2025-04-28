ABSTRACT_TYPE(/obj/item/roboupgrade)
/obj/item/roboupgrade
	name = "cyborg upgrade"
	desc = "A non-functional upgrade for a cyborg."
	icon = 'icons/obj/robot_parts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"

	/// Is this upgrade used like an item?
	var/active = 0
	/// Does this upgrade always work once installed?
	var/passive = 0
	/// live ingame variable
	var/activated = 0
	/// How much charge the upgrade consumes while installed
	var/drainrate = 0
	/// How many times a limited upgrade can be used before it is consumed (infinite if negative)
	var/charges = -1
	/// Can be removed from the cyborg
	var/removable = 1
	/// Used for cyborg update_appearance proc
	var/borg_overlay = null

/obj/item/roboupgrade/proc/upgrade_activate(mob/living/silicon/robot/user)
	if (!user)
		return 1
	if(user.hasStatus("upgrade_disabled") || user.hasStatus("lockdown_robot"))
		boutput(user, SPAN_ALERT("Your modules are currently disabled!"))
		return 1
	if (!src.activated && !src.active)
		src.activated = 1
	if (src.charges > 0)
		src.charges--
		if (src.charges == 0)
			boutput(user, "[src] has been activated. It has been used up.")
			user.upgrades.Remove(src)
			qdel(src)
		else
			if (src.charges < 0)
				boutput(user, "[src] has been activated.")
			else
				boutput(user, "[src] has been activated. [src.charges] uses left.")


/obj/item/roboupgrade/proc/upgrade_deactivate(mob/living/silicon/robot/user)
	if (!user)
		return 1
	src.activated = 0
