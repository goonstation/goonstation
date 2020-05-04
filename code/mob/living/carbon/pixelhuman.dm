/proc/pixel_everyone()
	boutput(world, "<span class='alert'>Changing all human mobs - please wait a moment.</span>")
	sleep(1 SECOND)
	for(var/mob/living/carbon/human/H in mobs)
		var/mob/living/carbon/human/pixel/P = new/mob/living/carbon/human/pixel(get_turf(H.loc))
		P.real_name = H.real_name
		P.client = H.client

/mob/living/carbon/human/pixel
	var/speed_normal = 4
	var/speed_run = 8

/mob/living/carbon/human/pixel/proc/can_enter(var/turf/from_loc, var/turf/to_loc)
	if(!from_loc.Exit(src, to_loc))
		//boutput(world, "exit fail")
		return 0
	if(!to_loc.Enter(src, from_loc))
		//boutput(world, "enter fail")
		return 0
	return 1
