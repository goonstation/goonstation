/datum/unit_test/phone_crash

/datum/unit_test/phone_crash/Run()
	var/mob/living/carbon/human/tdummy/tdummy = new(run_loc_floor_bottom_left)
	var/obj/machinery/phone/phone = new(run_loc_floor_bottom_left)
	var/i=0
	while(i < 500)
		i++
		phone.Attackhand(tdummy)
		sleep(1)
		phone.Attackby(tdummy.equipped(), tdummy)
		sleep(1)
