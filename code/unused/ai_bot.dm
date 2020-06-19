/obj/machinery/ai_bot
	name = "Robot"
	icon = 'icons/mob/robots.dmi'
	icon_state = "ro"
	density = 1
	anchored = 1

	var/obj/item/weapon/cell/cell
	var/charge = 0
	var/operating = 1
	var/health = 150
	var/opened = 0
	var/locked = 1
	var/coverlocked = 0
	var/emagged = 0
	var/wiresexposed = 0

	var/now_pushing = null
	var/last_b_state = 1.0

	pressure_resistance = 3*ONE_ATMOSPHERE

	var/list/body_standing = list(  )
	var/list/body_lying = list(  )

/obj/machinery/ai_bot/proc/update()

	if(src.status & BROKEN)
		if(src.health > 0)
			status &= ~BROKEN
		else
			return
	if(src.health < 0)
		src.set_broken()
	updateicon()

/obj/machinery/ai_bot/proc/updateicon()
	if(src.status & BROKEN)
		icon_state = "ro+b"
		return
	if(opened)
		icon_state = "[ cell ? "apc2" : "apc1" ]"		// if opened, show cell if it's inserted
		src.overlays = null								// also delete all overlays

	else if(emagged)
		icon_state = "apcemag"
		src.overlays = null
		return

	else if(wiresexposed)
		icon_state = "ro+o"
		src.overlays = null
		return

	else
		icon_state = "ro"

		// if closed, update overlays for channel status

		src.overlays = null

//		overlays += image('icons/obj/power.dmi', "apcox-[locked]")	// 0=blue 1=red
//		overlays += image('icons/obj/power.dmi', "apco3-[charging]") // 0=red, 1=yellow/black 2=green


/*		if(operating)

			overlays += image('icons/obj/power.dmi', "apco0-[equipment]")	// 0=red, 1=green, 2=blue
			overlays += image('icons/obj/power.dmi', "apco1-[lighting]")
			overlays += image('icons/obj/power.dmi', "apco2-[environ]")
Yes yes stolen from APC code I know!
To-do: Add overlays here */

/obj/machinery/ai_bot/attackby(obj/item/W, mob/user)

	if (isweldingtool(W))
		if(!W:try_weld(user, 2))
			return
		src.health += 30
		src.add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("<span class='alert'>[user] has mended the robot!</span>"), 1)
		src.update()

	else if (ispryingtool(W))
		if(opened)
			opened = 0
			updateicon()
		else
			if(coverlocked)
				boutput(user, "The cover is locked and cannot be opened.")
			else
				opened = 1
				updateicon()

	else if (istype(W, /obj/item/cell) && opened)	// trying to put a cell inside
		if(cell)
			boutput(user, "There is a power cell already installed.")
		else
			user.drop_item()
			W.set_loc(src)
			cell = W
			boutput(user, "You insert the power cell.")
//			chargecount = 0
		updateicon()

	else if	(isscrewingtool(W))
		if(opened)
			boutput(user, "Close the Robot first")
		else if(emagged)
			boutput(user, "The interface is broken")
		else
			wiresexposed = !wiresexposed
			boutput(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"]")
			updateicon()

	else if (istype(W, /obj/item/card/id))			// trying to unlock the interface with an ID card
		if(emagged)
			boutput(user, "The interface is broken")
		else if(opened)
			boutput(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			boutput(user, "You must close the panel")
		else
			if(src.allowed(usr))
				locked = !locked
				boutput(user, "You [ locked ? "lock" : "unlock"] the APC interface.")
				updateicon()
			else
				boutput(user, "<span class='alert'>Access denied.</span>")

	else if (istype(W, /obj/item/card/emag) && !emagged)		// trying to unlock with an emag card
		if(opened)
			boutput(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			boutput(user, "You must close the panel first")
		else
			flick("apc-spark", src)
			sleep(0.6 SECONDS)
			if(prob(50))
				emagged = 1
				locked = 0
				boutput(user, "You emag the APC interface.")
				updateicon()
			else
				boutput(user, "You fail to [ locked ? "unlock" : "lock"] the APC interface.")

	else
		src.health -= W.force
		for(var/mob/O in viewers(user, null))
			O.show_message(text("<span class='alert'>[src] has been attacked by [user] with the [W]!</span>"), 5)
		src.update()

	return


/obj/machinery/ai_bot/ex_act(severity)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if(prob(50))
				src.health -= 200
			else
				qdel(src)
		if (3)
			if(prob(50))
				src.health -= 150
			else
				src.health -= 50
	src.update()

/obj/machinery/ai_bot/bullet_act(flag)
	if(src.material) src.material.triggerOnBullet(src, src, P)

	if (flag == PROJECTILE_BULLET)
		src.health -= 10

	else if (flag != PROJECTILE_LASER)
		src.health -= 20

	else
		src.health -= 40

	src.update()
	return

/obj/machinery/ai_bot/blob_act(var/power)
	if (prob(power * 2.5))
		src.health -= 40
		update()
	return

/obj/machinery/ai_bot/meteorhit(obj/O as obj)
	src.health -= 100
	src.update()
	return

/obj/machinery/ai_bot/proc/set_broken()
	status |= BROKEN
	icon_state = "ro+b"
	overlays = null

	operating = 0
	update()

