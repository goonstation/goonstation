/obj/item/roboupgrade/expand
	name = "cyborg expansion upgrade"
	desc = "A module that can accommodate space and interfacing for two upgrades, effectively expanding the amount of upgrades a cyborg can have."
	icon_state = "up-expand"
	active = 1
	charges = 1

/obj/item/roboupgrade/expand/upgrade_activate(var/mob/living/silicon/robot/user as mob)
	if (!user || src.qdeled)
		return
	user.max_upgrades++
	boutput(user, "<span class='notice'>You can now hold up to [user.max_upgrades] upgrades!</span>")
	user.upgrades.Remove(src)
	qdel(src)
