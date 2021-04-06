/obj/item/roboupgrade/healthgoggles
	name = "cyborg ProDoc scanner upgrade"
	desc = "An advanced sensor array that allows a cyborg to quickly determine the physical condition of organic life."
	icon_state = "up-prodoc"
	drainrate = 5

	var/client/assigned = null

/obj/item/roboupgrade/healthgoggles/process()
	if (assigned)
		src.assigned.images.Remove(health_mon_icons)
		addIcons()

		if (src.loc != assigned.mob)
			src.assigned.images.Remove(health_mon_icons)
			src.assigned = null

/obj/item/roboupgrade/healthgoggles/proc/addIcons()
	if (src.assigned)
		for (var/image/I in health_mon_icons)
			if (!I || !I.loc || !src)
				continue
			if (I.loc.invisibility && I.loc != src.loc)
				continue
			src.assigned.images.Add(I)

/obj/item/roboupgrade/healthgoggles/upgrade_activate(var/mob/living/silicon/robot/user as mob)
	if (..())
		return
	src.assigned = user.client
	processing_items |= src

/obj/item/roboupgrade/healthgoggles/upgrade_deactivate(var/mob/living/silicon/robot/user as mob)
	if (..())
		return
	if (src.assigned)
		src.assigned.images.Remove(health_mon_icons)
		src.assigned = null
	processing_items.Remove(src)
	return
