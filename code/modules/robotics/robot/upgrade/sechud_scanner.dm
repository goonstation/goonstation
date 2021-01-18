/obj/item/roboupgrade/sechudgoggles
	name = "cyborg Security HUD upgrade"
	desc = "An advanced sensor array that allows a cyborg to quickly determine the physical condition of organic life."
	icon_state = "up-sechud"
	drainrate = 5

	var/client/assigned = null

	process()
		if (assigned)
			src.assigned.images.Remove(arrestIconsAll)
			addIcons()

			if (src.loc != assigned.mob)
				src.assigned.images.Remove(arrestIconsAll)
				src.assigned = null

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
		processing_items |= src

	upgrade_deactivate(var/mob/living/silicon/robot/user as mob)
		if (..())
			return
		if (src.assigned)
			src.assigned.images.Remove(arrestIconsAll)
			src.assigned = null
		processing_items.Remove(src)
		return
