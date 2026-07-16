var/global/instant_pipe_network = FALSE
/proc/instant_pipe_network()
	if (global.instant_pipe_network)
		return

	global.instant_pipe_network = TRUE

	for_by_tcl(conveyor, /obj/machinery/conveyor)
		if (conveyor.z == Z_LEVEL_STATION)
			conveyor.move_lag = 0.1

	for_by_tcl(outlet, /obj/disposaloutlet)
		if (outlet.z == Z_LEVEL_STATION)
			outlet.throw_speed = 10


SET_UP_CI_TRACKING(/obj/machinery/conveyor)
SET_UP_CI_TRACKING(/obj/disposaloutlet)


/obj/item/pipenet_test_dummy
	name = "pipe network test dummy"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "mail-2"
	throwforce = 0
	var/obj/machinery/disposal/chute = null

/obj/item/pipenet_test_dummy/New(obj/machinery/disposal/chute)
	if (!istype(chute))
		CRASH("Pipe network test dummy spawned in a non-disposal chute object.")

	src.chute = chute
	. = ..()
