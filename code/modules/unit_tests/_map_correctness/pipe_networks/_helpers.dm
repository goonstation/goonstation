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
	name = "pipenet test"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "mail-2"
	throwforce = 0
	var/obj/machinery/disposal/chute = null

/obj/item/pipenet_test_dummy/New(obj/machinery/disposal/chute)
	if (!istype(chute))
		CRASH("Pipe network test dummy spawned in a non-disposal chute object.")

	src.chute = chute
	. = ..()

/// Has this dummy has finished travelling?
/obj/item/pipenet_test_dummy/proc/arrived()
	return get_turf(src) in global.landmarks[LANDMARK_DISPOSALS_ENDPOINT]

/// Waits until every dummy has arrived for up to 5 seconds
/proc/wait_for_pipenet_dummies(list/obj/item/pipenet_test_dummy/dummies)
	var/give_up_at = world.time + 5 SECONDS
	for (var/obj/item/pipenet_test_dummy/dummy as anything in dummies)
		while (!dummy.arrived() && world.time < give_up_at)
			sleep(1)

/obj/item/pipenet_test_dummy/mail
	var/turf/ejection_turf = null
	var/obj/machinery/disposal/mail/ejection_chute = null
	var/destination_tag = null

/obj/item/pipenet_test_dummy/mail/New(obj/machinery/disposal/mail/chute, destination)
	src.name += " ([chute.mail_tag] ➔ [destination])"
	src.destination_tag = destination
	. = ..()

/obj/item/pipenet_test_dummy/mail/arrived()
	return !isnull(src.ejection_turf)

/obj/item/pipenet_test_dummy/mail/pipe_eject()
	src.ejection_turf = get_turf(src)
	src.ejection_chute = locate(/obj/machinery/disposal/mail) in src.ejection_turf
