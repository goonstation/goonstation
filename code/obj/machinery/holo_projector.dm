/obj/machinery/holo_projector
	name = "Holographic projector"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "puke_0"
	desc = "A pad that allows the on-station ai to make an hologram."
	density = 0
	anchored = 1
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WIRECUTTERS
	power_usage = 10
	var/list/mob/living/silicon/hologram/linked_holograms = list()
	New()
		START_TRACKING
		..()
	//todo check effect/distort/hologram

	disposing()
		for (var/mob/living/silicon/hologram/M in linked_holograms)
			M.death()
		STOP_TRACKING
		. = ..()

	//todo emag act
	//todo power usage

	attackby(var/obj/item/I, var/mob/user)
		return
