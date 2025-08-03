/datum/unit_test/phone_crash

/datum/unit_test/phone_crash/Run()
	var/mob/living/carbon/human/tdummy/tdummy = new(run_loc_floor_bottom_left)
	var/obj/machinery/phone/phone = new(run_loc_floor_bottom_left)
	var/i=0
	while(i < 100)
		i++
		phone.Attackhand(tdummy)
		sleep(1)
		phone.Attackby(tdummy.equipped(), tdummy)
		sleep(1)
	world.log << "Phone crash test finished, if you are seeing this, the test did not crash the game."
	boutput(world, "Phone crash test finished, if you are seeing this, the test did not crash the game.")
