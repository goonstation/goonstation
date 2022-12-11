TYPEINFO(/obj/machinery/holo_projector)
	mats = list("MET-1"=1, "CON-1"=3, "CRY-1"=2)

/obj/machinery/holo_projector
	name = "Holographic projector"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "puke_0"
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
		for (var/mob/living/silicon/hologram/M in linked_holograms)
			M.death()
		STOP_TRACKING
		. = ..()

	//todo emag act
	//todo power usage

	attackby(obj/item/P, mob/living/user)
		if (istype(P, /obj/item/weldingtool))
			var/obj/item/weldingtool/welder = P
			if (welder.try_weld(user, 3, 3))
				user.visible_message("<span class='notice'>[user] fixes the holographic projector.</span>")
				src.broken = FALSE
				return
		attack_particle(user,src)
		user.lastattacked = src
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		src._health = src._health - P.force
		if (src._health <= 0)
			src.visible_message("<span class='notice'>[src] breaks!</span>")
			src.broken = TRUE

/obj/item/holo_projector
	//todo battery life
