/obj/machinery/sleeperscanner
	name = "Hand Scanner"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "handscanner"

/obj/machinery/sleeperscanner/attackby(obj/item/W, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	if (user.mind?.get_antagonist(ROLE_SLEEPER_AGENT))
		user.visible_message("<span class='notice'>The [src] accepts the biometrics of the user and beeps, granting you access.</span>")
		for (var/obj/machinery/door/airlock/pyro/reinforced/syndicate/M in by_type[/obj/machinery/door])
			M.open
	else
		boutput(user, "<span class='alert'>Invalid biometric profile. Access denied.</span>")

/obj/machinery/sleeperscanner/attack_hand(mob/user)
	src.add_fingerprint(user)
	playsound(src.loc, 'sound/effects/handscan.ogg', 50, 1)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if (user.mind?.get_antagonist(ROLE_SLEEPER_AGENT))
			user.visible_message("<span class='notice'>The [src] accepts the biometrics of the user and beeps, granting you access.</span>")
			for (var/obj/machinery/door/airlock/pyro/reinforced/syndicate/M in by_type[/obj/machinery/door])
				M.open
		else
			boutput(user, "<span class='alert'>Invalid biometric profile. Access denied.</span>")
	else
		boutput(user, "<span class='alert'>Invalid biometric profile. Access denied.</span>")
