/obj/item/roboupgrade/magboot
    name = "cyborg magnetic traction upgrade"
    desc = "A set of mag-tractors attached to the underside of the cyborg that emulate magboots."
    icon_state = "up-opticmes"
    drainrate = 10
    
 /obj/item/roboupgrade/magboot/upgrade_activate(var/mob/living/silicon/robot/user as mob)
	if (!user)
		return
	var/mob/living/silicon/robot/R = user
	if (!R.part_leg_r && !R.part_leg_l)
		boutput(user, "This upgrade cannot be used when you have no legs!")
		src.activated = 0
	else
        mob.magnetic = 1
		APPLY_MOVEMENT_MODIFIER(user, /datum/movement_modifier/robot_mag_upgrade, src)
		..()

/obj/item/magboot/speed/upgrade_deactivate(var/mob/living/silicon/robot/user as mob)
    mob.magnetic = 0
	REMOVE_MOVEMENT_MODIFIER(user, /datum/movement_modifier/robot_mag_upgrade, src)
	..()