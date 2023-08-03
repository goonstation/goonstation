
/obj/machinery/sleeperscanner
	name = "Hand Scanner"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "handscanner"
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if (user.mind?.get_antagonist(ROLE_SLEEPER_AGENT)) //Probably adjusting to only sleepers during map PR
			user.visible_message("<span class='notice'>The [src] accepts the biometrics of the user and beeps, granting you access.</span>")
			for (var/obj/machinery/door/airlock/pyro/reinforced/syndicate/M in by_type[/obj/machinery/door])
				M.open
			else
				boutput(user, "<span class='alert'>Invalid biometric profile. Access denied.</span>")
	else
		boutput(user, "<span class='alert'>Invalid biometric profile. Access denied.</span>")
