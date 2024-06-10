// How 2 use: run /proc/test_disposal_system via Advanced ProcCall
// locate the X and Y where normally disposed stuff should end up (usually the last bit of conveyor belt in front of the crusher door
// wait and see what comes up!
/proc/test_disposal_system(var/expected_x, var/expected_y, var/sleep_time = 1200, var/include_mail = TRUE)
	if (!usr && (isnull(expected_x) || isnull(expected_y)))
		return
	if (isnull(expected_x))
		expected_x = input(usr,"Please enter X coordinate") as null|num
		if (isnull(expected_x))
			return
	if (isnull(expected_y))
		expected_y = input(usr,"Please enter Y coordinate") as null|num
		if (isnull(expected_y))
			return

	var/list/dummy_list = list()
	for_by_tcl(D, /obj/machinery/disposal)
		if (!inonstationz(D))
			break
		var/obj/item/disposal_test_dummy/TD
		// Mail chute test
		if(istype(D, /obj/machinery/disposal/mail))
			if(include_mail)
				var/obj/machinery/disposal/mail/mail_chute = D

				SPAWN(2 SECONDS)
					for(var/dest in mail_chute.destinations)
						var/obj/item/disposal_test_dummy/mail_test/MD = new /obj/item/disposal_test_dummy/mail_test(mail_chute, sleep_time)
						MD.source_disposal = mail_chute
						MD.destination_tag = dest
						mail_chute.destination_tag = dest
						dummy_list.Add(MD)
						mail_chute.flush()

		else
			//Regular chute
			TD = new /obj/item/disposal_test_dummy(D)
			TD.expected_x = expected_x
			TD.expected_y = expected_y
			dummy_list.Add(TD)
			TD.source_disposal = D
			SPAWN(0)
				D.flush()

	logTheThing(LOG_DEBUG, usr, "called test_disposal_system() with a sleep time of [sleep_time]")
	message_coders("test_disposal_system() sleeping [sleep_time] and spawned [dummy_list.len] dummies")
	sleep(sleep_time)

	var/failures = 0
	for (var/obj/item/disposal_test_dummy/TD in dummy_list)
		if (TD.report_fail())
			failures++

		qdel(TD)

	message_coders("Disposal test completed with [failures] failures")

/obj/item/disposal_test_dummy
	icon = 'icons/obj/items/items.dmi'
	icon_state = "mail-2"
	name = "disposal test dummy"
	var/obj/machinery/disposal/source_disposal = null
	var/expected_x = 0
	var/expected_y = 0

	proc/report_fail()
		if(src.x != expected_x || src.y != expected_y)
			message_coders("test dummy misrouted at [log_loc(src)][src.source_disposal ? " from [src.source_disposal] [log_loc(src.source_disposal)]" : " (source disposal destroyed)"]")
			return TRUE
		return FALSE

/obj/item/disposal_test_dummy/mail_test
	var/obj/machinery/disposal/mail/destination_disposal = null
	var/destination_tag = null
	var/success = FALSE

/obj/item/disposal_test_dummy/mail_test/pipe_eject()
	destination_disposal = locate(/obj/machinery/disposal/mail) in src.loc
	if(destination_disposal && destination_disposal.mail_tag == destination_tag)
		success = TRUE
	..()

/obj/item/disposal_test_dummy/mail_test/report_fail()
	if(!success)
		message_coders("mail dummy misrouted at [log_loc(src)] from [log_loc(source_disposal)], destination: [destination_tag], reached: [log_loc(destination_disposal)]")
		return TRUE
	return FALSE
