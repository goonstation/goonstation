/obj/item/roboupgrade/healthgoggles
	name = "cyborg ProDoc scanner upgrade"
	desc = "Fitted with an advanced miniature sensor array that allows the user to quickly determine the physical condition of others."
	icon_state = "up-prodoc"
	drainrate = 5

	var/client/assigned = null

/obj/item/roboupgrade/healthgoggles/proc/updateIcons()
	// I wouldve liked to avoid this but i dont want to put this inside the mobs life proc as that would be more code.
	// TODO: signals/components!
	while (src.assigned)
		src.assigned.images.Remove(health_mon_icons)
		src.addIcons()

		if (src.loc != assigned.mob)
			src.assigned.images.Remove(health_mon_icons)
			src.assigned = null

		sleep(2 SECONDS)

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
	SPAWN_DBG(-1)
		updateIcons()

/obj/item/roboupgrade/healthgoggles/upgrade_deactivate(var/mob/living/silicon/robot/user as mob)
	if (..())
		return
	if (src.assigned)
		src.assigned.images.Remove(health_mon_icons)
		src.assigned = null
	return
