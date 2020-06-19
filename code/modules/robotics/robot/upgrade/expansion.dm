/obj/item/roboupgrade/expand
	name = "cyborg expansion upgrade"
	desc = "A matter miniaturizer that frees up room in a cyborg for more upgrades."
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
