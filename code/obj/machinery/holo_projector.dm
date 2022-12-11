TYPEINFO(/obj/machinery/holo_projector)
	mats = list("MET-1"=1, "CON-1"=3, "CRY-1"=2)

/obj/machinery/holo_projector
	name = "Holographic projector"
	icon = 'icons/misc/holograms.dmi'
	icon_state = "projector_off"
	desc = "A pad that allows the on-station ai to make an hologram."
	density = 0
	anchored = 1
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WIRECUTTERS
	power_usage = 10
	_health = 25
	var/list/mob/living/silicon/hologram/linked_holograms = list()
	var/broken = FALSE
	New()
		START_TRACKING
		..()

	disposing()
		src.kill_holograms()
		STOP_TRACKING
		. = ..()

	process(mult)
		. = ..()
		if (status & NOPOWER && length(src.linked_holograms) > 0)
			src.visible_message("<span class='notice'>[src] shuts down.</span>")
			src.kill_holograms()
			return

	attackby(obj/item/P, mob/living/user)
		if (istype(P, /obj/item/weldingtool))
			var/obj/item/weldingtool/welder = P
			if (welder.try_weld(user, 3, 3))
				user.visible_message("<span class='notice'>[user] fixes the holographic projector.</span>")
				src.broken = FALSE
				src.UpdateIcon()
				return
		if (src.broken)
			return
		if (istype(P, /obj/item/wrench))
			if (src.anchored)
				src.anchored = FALSE
				user.visible_message("<span class='notice'>[user] unbolts [src] from the floor.</span>")
				return
			else
				src.anchored = TRUE
				user.visible_message("<span class='notice'>[user] bolts [src] to the floor.</span>")
				return
		attack_particle(user,src)
		user.lastattacked = src
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		src._health = src._health - P.force
		if (src._health <= 0)
			src.visible_message("<span class='notice'>[src] breaks!</span>")
			src.broken = TRUE
			src.kill_holograms()
			src.UpdateIcon()

	update_icon()
		if (src.broken)
			src.icon_state = "projector_broken"
		if (length(linked_holograms) > 0)
			src.icon_state = "projector_on"
		else
			src.icon_state = "projector_off"

	proc/kill_holograms()
		for (var/mob/living/silicon/hologram/M in linked_holograms)
			M.become_eye()
			M.death()
