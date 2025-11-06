/obj/item/roboupgrade/magboot
	name = "cyborg magnetic traction upgrade"
	desc = "A set of mag-tractors attached to the underside of a cyborg that emulate magboots."
	icon_state = "up-mag"
	drainrate = 10
	//mmm yes composition
	var/obj/item/clothing/shoes/magnetic/magboots

/obj/item/roboupgrade/magboot/New()
	. = ..()
	src.magboots = new(src)

/obj/item/roboupgrade/magboot/upgrade_activate(var/mob/living/silicon/robot/user as mob)
	if (!user)
		return
	var/mob/living/silicon/robot/R = user
	if (!R.part_leg_r && !R.part_leg_l)
		boutput(user, "This upgrade cannot be used when you have no legs!")
		src.activated = 0
	if (istype(R.part_leg_l,/obj/item/parts/robot_parts/leg/left/thruster) || istype(R.part_leg_r,/obj/item/parts/robot_parts/leg/right/thruster))
		boutput(user, "This upgrade cannot be used without firm ground connection!")
		src.activated = 0
	else
		if (src.magboots.activate(user))
			APPLY_MOVEMENT_MODIFIER(user, /datum/movement_modifier/robot_mag_upgrade, src)
			user.anchored = ANCHORED
			..()
		else
			src.activated = 0

/obj/item/roboupgrade/magboot/upgrade_deactivate(var/mob/living/silicon/robot/user as mob)
	src.magboots.deactivate(user)
	REMOVE_MOVEMENT_MODIFIER(user, /datum/movement_modifier/robot_mag_upgrade, src)
	user.anchored = UNANCHORED
	..()
