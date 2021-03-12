/obj/item/roboupgrade/repairpack
	name = "cyborg repair pack"
	desc = "A single-use construction unit that can repair up to 50% of a cyborg's structure."
	icon_state = "up-reppack"
	active = 1
	charges = 1

/obj/item/roboupgrade/repairpack/upgrade_activate(var/mob/living/silicon/robot/user as mob)
	if (!user)
		return
	for (var/obj/item/parts/robot_parts/RP in user.contents)
		RP.ropart_mend_damage(100, 100)
	boutput(user, "<span class='notice'>All components repaired!</span>")
