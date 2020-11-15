/obj/item/roboupgrade/sechudgoggles
	name = "cyborg Security HUD upgrade"
	desc = "An advanced sensor array that allows a cyborg to quickly determine the physical condition of organic life."
	icon_state = "up-sechud"
	drainrate = 5

	var/client/assigned = null

	proc/updateIcons()
		// I wouldve liked to avoid this but i dont want to put this inside the mobs life proc as that would be more code.
		// TODO: signals/components!
		while (src.assigned)
			src.assigned.images.Remove(arrestIconsAll)
			src.addIcons()

			if (src.loc != assigned.mob)
				src.assigned.images.Remove(arrestIconsAll)
				src.assigned = null

			sleep(2 SECONDS)

	proc/addIcons()
		if (src.assigned)
			for (var/image/I in arrestIconsAll)
				if (!I || !I.loc || !src)
					continue
				if (I.loc.invisibility && I.loc != src.loc)
					continue
				src.assigned.images.Add(I)

	upgrade_activate(var/mob/living/silicon/robot/user as mob)
		if (..())
			return
		src.assigned = user.client
		SPAWN_DBG(-1)
			updateIcons()

	upgrade_deactivate(var/mob/living/silicon/robot/user as mob)
		if (..())
			return
		if (src.assigned)
			src.assigned.images.Remove(arrestIconsAll)
			src.assigned = null
		return
