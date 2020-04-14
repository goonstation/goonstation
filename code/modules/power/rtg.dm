/obj/machinery/power/rtg
	name = "radioisotope thermoelectric generator"
	desc = "Made by wrapping thermocouples around a chunk of nuclear stuff, or something like that."
	icon_state = "rtg_empty"
	anchored = 1
	density = 1
	var/lastgen = 0
	var/obj/item/fuel_pellet/fuel_pellet

	process()
		if (fuel_pellet && fuel_pellet.material && fuel_pellet.material.hasProperty("radioactive"))
			lastgen = (4800 + rand(-100, 100)) * log(1 + fuel_pellet.material.getProperty("radioactive"))
			fuel_pellet.material.adjustProperty("radioactive", -1)
			add_avail(lastgen)
			updateicon()

		// shamelessly stolen from the SMES code, this is kinda stupid
		for(var/mob/M in range(1, src))
			if (M.client && M.machine == src)
				src.interact(M)
		AutoUpdateAI(src)

	attack_ai(mob/user)
		add_fingerprint(user)
		if(status & BROKEN)
			return

		interact(user)

	attack_hand(mob/user)
		add_fingerprint(user)
		if(status & BROKEN)
			return

		interact(user)

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/fuel_pellet))
			if (!fuel_pellet)
				user.drop_item()
				I.loc = src
				fuel_pellet = I
				updateicon()
			else
				boutput(usr, "<span style=\"color:blue\">A fuel pellet has already been inserted.</span>")

	Topic(href, href_list)
		if (..())
			return
		if (href_list["close"])
			usr.Browse(null, "window=rtg")
			usr.machine = null
		else if (href_list["eject"] && in_range(src, usr))
			fuel_pellet.loc = src.loc
			usr.put_in_hand_or_eject(src.fuel_pellet) // try to eject it into the users hand, if we can
			fuel_pellet = null
			updateicon()


	proc/interact(mob/user)
		if (get_dist(src, user) > 1 && !isAI(user))
			user.machine = null
			user.Browse(null, "window=rtg")
			return

		user.machine = src

		var/t = "<B>Radioisotope Thermoelectric Generator</B><br>"
		t += "Output: [src.lastgen]W<br>"
		if (fuel_pellet)
			t += "Fuel pellet: [round(fuel_pellet.material.getProperty("radioactive"), 0.1)] rads <a href='?src=\ref[src];eject=1'>Eject</a><br>"
		else
			t += "No fuel pellet inserted.<br>"
		t += "<a href='?src=\ref[src];close=1'>Close</a>"
		user.Browse(t, "window=rtg")
		onclose(user, "rtg")

	proc/updateicon()
		overlays = null
		if (fuel_pellet)
			if(status & BROKEN || !lastgen)
				icon_state = "rtg_off"
				return
			else
				icon_state = "rtg_on"
		else
			icon_state = "rtg_empty"
			return
		overlays += image('icons/obj/power.dmi', "rtg-f[min(1 + ceil(fuel_pellet.material.getProperty("radioactive") / 2), 5)]")

/obj/item/fuel_pellet
	name = "fuel pellet"
	desc = "A rather small fuel pellet for use in RTGs."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "fuelpellet"
	throwforce = 5
	w_class = 1

	cerenkite
		New()
			..()
			src.setMaterial(getMaterial("cerenkite"))
