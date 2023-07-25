/obj/machinery/power/rtg
	name = "Leigong RTG"
	desc = "The XIANG|GIESEL model '雷公' radio-thermal generator. Wrapped thermocouples produce power from the decay heat of nuclear fuel pellets."
	icon_state = "rtg_empty"
	anchored = ANCHORED
	density = 1
	var/lastgen = 0
	var/obj/item/fuel_pellet/fuel_pellet

	process()
		if (fuel_pellet?.material && fuel_pellet.material.hasProperty("radioactive"))
			lastgen = (4800 + rand(-100, 100)) * fuel_pellet.material.getProperty("radioactive") * 0.75
			fuel_pellet.material.adjustProperty("radioactive", -1)
			add_avail(lastgen)
			UpdateIcon()

		// shamelessly stolen from the SMES code, this is kinda stupid
		src.updateDialog()

	attack_ai(mob/user)
		add_fingerprint(user)
		if(status & BROKEN)
			return

		interacted(user)

	attack_hand(mob/user)
		add_fingerprint(user)
		if(status & BROKEN)
			return

		interacted(user)

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/fuel_pellet))
			if (!fuel_pellet)
				user.drop_item()
				I.set_loc(src)
				fuel_pellet = I
				UpdateIcon()
			else
				boutput(user, "<span class='notice'>A fuel pellet has already been inserted.</span>")

	Topic(href, href_list)
		if (..())
			return
		if (href_list["close"])
			usr.Browse(null, "window=rtg")
			src.remove_dialog(usr)
		else if (href_list["eject"] && in_interact_range(src, usr))
			fuel_pellet.set_loc(src.loc)
			usr.put_in_hand_or_eject(src.fuel_pellet) // try to eject it into the users hand, if we can
			fuel_pellet = null
			UpdateIcon()


	proc/interacted(mob/user)
		if (BOUNDS_DIST(src, user) > 0 && !isAI(user))
			src.remove_dialog(user)
			user.Browse(null, "window=rtg")
			return

		src.add_dialog(user)

		var/t = "<B>Radioisotope Thermoelectric Generator</B><br>"
		t += "Output: [src.lastgen]W<br>"
		if (fuel_pellet)
			t += "Fuel pellet: [round(fuel_pellet.material.getProperty("radioactive"), 0.1)] rads <a href='?src=\ref[src];eject=1'>Eject</a><br>"
		else
			t += "No fuel pellet inserted.<br>"
		t += "<a href='?src=\ref[src];close=1'>Close</a>"
		user.Browse(t, "window=rtg")
		onclose(user, "rtg")

	update_icon()
		if (fuel_pellet)
			if(status & BROKEN || !lastgen)
				icon_state = "rtg_off"
				src.UpdateOverlays(null, "rtg")
				return
			else
				icon_state = "rtg_on"
		else
			icon_state = "rtg_empty"
			src.UpdateOverlays(null, "rtg")
			return
		src.UpdateOverlays(image('icons/obj/power.dmi', "rtg-f[min(1 + ceil(fuel_pellet.material.getProperty("radioactive") / 2), 5)]"), "rtg")

	cerenkite_loaded
		New()
			..()
			fuel_pellet = new /obj/item/fuel_pellet/cerenkite

	erebite_loaded
		New()
			..()
			fuel_pellet = new /obj/item/fuel_pellet/erebite

/obj/item/fuel_pellet
	name = "fuel pellet"
	desc = "A rather small fuel pellet for use in RTGs."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "fuelpellet"
	throwforce = 5
	w_class = W_CLASS_TINY

	cerenkite
		New()
			..()
			src.setMaterial(getMaterial("cerenkite"))

	erebite
		New()
			..()
			src.setMaterial(getMaterial("erebite"))
