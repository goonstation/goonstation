/obj/item/roboupgrade/speed
	name = "cyborg speed upgrade"
	desc = "A booster unit that safely allows cyborgs to move at high speed."
	icon_state = "up-speed"
	drainrate = 100
	borg_overlay = "up-speed"

/obj/item/roboupgrade/speed/upgrade_activate(var/mob/living/silicon/robot/user as mob)
	if (!user)
		return
	var/mob/living/silicon/robot/R = user
	if (!R.part_leg_r && !R.part_leg_l)
		boutput(user, "This upgrade cannot be used when you have no legs!")
		src.activated = 0
	else
		..()
