/obj/machinery/space_heater
	anchored = 0
	density = 1
	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "sheater0"
	name = "space HVAC"
	desc = "Made by Space Amish using traditional space techniques, this space heater is guaranteed not to set the station on fire."
	var/emagged = 0
	var/obj/item/cell/cell
	var/on = 0
	var/heating = 0
	var/open = 0
	var/set_temperature = 50		// in celcius, add T0C for kelvin
	var/heating_power = 40000
	var/cooling_power = -30000
	mats = 8
	deconstruct_flags = DECON_WRENCH | DECON_WELDER
	flags = FPRINT


	New()
		..()
		cell = new(src)
		cell.charge = 1000
		cell.maxcharge = 1000
		UpdateIcon()
		return

	update_icon()
		if (on)
			if(heating)
				icon_state = "sheaterH"
			else
				icon_state = "sheaterC"
		else
			icon_state = "sheater0"
		if(open)
			icon_state = "sheater-open"
		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)
			if (open)
				if (user)
					user.show_text("You short out the temperature limiter circuit in the [src].", "blue")
				src.emagged = 1
				src.desc = "Made by Space Amish using traditional space techniques, this heater is guaranteed to set the station on fire."
				return 1
			else
				if (user)
					user.show_text("The internal circuitry must be exposed!", "red")
				return 0
		else
			if (user)
				user.show_text("The temperature limiter is already burned out.", "red")
				return 0

	demag(mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("You repair the temperature regulator in the [src].", "blue")
		src.desc = "Made by Space Amish using traditional space techniques, this heater is guaranteed not to set the station on fire."
		src.emagged = 0
		return 1


	examine()
		. = ..()
		. += "The HVAC is [on ? "on" : "off"], [heating ? "heating" : "cooling"] and the hatch is [open ? "open" : "closed"]."
		if(open)
			. += "The power cell is [cell ? "installed" : "missing"]."
		else
			. += "The charge meter reads [cell ? round(cell.percent(),1) : 0]%"


	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/cell))
			if(open)
				if(cell)
					boutput(user, "There is already a power cell inside.")
					return
				else
					// insert cell
					var/obj/item/cell/C = user.equipped()
					if(istype(C))
						user.drop_item()
						cell = C
						C.set_loc(src)
						C.add_fingerprint(user)

						user.visible_message("<span class='notice'>[user] inserts a power cell into [src].</span>", "<span class='notice'>You insert the power cell into [src].</span>")
			else
				boutput(user, "The hatch must be open to insert a power cell.")
				return
		else if (isscrewingtool(I))
			open = !open
			user.visible_message("<span class='notice'>[user] [open ? "opens" : "closes"] the hatch on the [src].</span>", "<span class='notice'>You [open ? "open" : "close"] the hatch on the [src].</span>")
			UpdateIcon()
			if(!open && user.using_dialog_of(src))
				user.Browse(null, "window=spaceheater")
				src.remove_dialog(user)
		else if (iswrenchingtool(I))
			if (user)
				user.show_text("You [anchored ? "release" : "anchor"] the [src]", "blue")
			src.anchored = !src.anchored
			playsound(src.loc, 'sound/items/Ratchet.ogg', 40, 0, 0)
		else
			..()
		return

	attack_hand(mob/user)
		src.add_fingerprint(user)
		if(open)

			var/dat
			dat = "Power cell: "
			if(cell)
				dat += "<A href='byond://?src=\ref[src];op=cellremove'>Installed</A><BR>"
			else
				dat += "<A href='byond://?src=\ref[src];op=cellinstall'>Removed</A><BR>"

			dat += "Power Level: [cell ? round(cell.percent(),1) : 0]%<BR><BR>"

			dat += "Set Temperature: "

			dat += "<A href='?src=\ref[src];op=temp;val=-10'>--</A> <A href='?src=\ref[src];op=temp;val=-5'>-</A>"

			dat += " <A href='?src=\ref[src];op=set_temp'>[set_temperature]&deg;C</A> "

			dat += "<A href='?src=\ref[src];op=temp;val=5'>+</A> <A href='?src=\ref[src];op=temp;val=10'>++</A><BR>"

			src.add_dialog(user)
			user.Browse("<HEAD><TITLE>Space Heater Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=spaceheater")
			onclose(user, "spaceheater")




		else
			if (on && src.emagged)
				user.show_text("The button seems to be stuck!", "red")
			else
				on = !on
				user.visible_message("<span class='notice'>[user] switches [on ? "on" : "off"] the [src].</span>","<span class='notice'>You switch [on ? "on" : "off"] the [src].</span>")
				UpdateIcon()



			if (on)
				playsound(src.loc, 'sound/machines/heater_on.ogg', 50, 1)
			else
				playsound(src.loc, 'sound/machines/heater_off.ogg', 50, 1)
		return


	Topic(href, href_list)
		if (usr.stat)
			return
		if ((in_interact_range(src, usr) && istype(src.loc, /turf)) || (issilicon(usr)))
			src.add_dialog(usr)

			switch(href_list["op"])
				if("set_temp")
					var/value = input(usr, "Target temperature (20C-[src.emagged ? 400 : 90]C):", "Enter Target Temperature", src.set_temperature)
					if (!isnum(value)) return
					var/max = src.emagged ? 400 : 90
					var/min = src.emagged ? -120 : 90

					set_temperature = clamp(value, -min, max)

				if("temp")
					var/value = text2num_safe(href_list["val"])
					var/max = src.emagged ? 400 : 90
					var/min = src.emagged ? -120 : 90

					// limit to 20-90 degC
					set_temperature = clamp(set_temperature + value, -min, max)

				if("cellremove")
					if(open && cell && !usr.equipped())
						cell.UpdateIcon()
						usr.put_in_hand_or_drop(cell)
						cell = null

						usr.visible_message("<span class='notice'>[usr] removes the power cell from \the [src].</span>", "<span class='notice'>You remove the power cell from \the [src].</span>")


				if("cellinstall")
					if(open && !cell)
						var/obj/item/cell/C = usr.equipped()
						if(istype(C))
							usr.drop_item()
							cell = C
							C.set_loc(src)
							C.add_fingerprint(usr)

							usr.visible_message("<span class='notice'>[usr] inserts a power cell into \the [src].</span>", "<span class='notice'>You insert the power cell into \the [src].</span>")

			updateDialog()
		else
			usr.Browse(null, "window=spaceheater")
			src.remove_dialog(usr)
		return



	process()
		if(on)
			if(cell?.charge > 0)

				var/turf/simulated/L = loc
				if(istype(L))
					var/datum/gas_mixture/env = L.return_air()
					if(env.temperature < (set_temperature+T0C))
						heating = 1
					else
						heating = 0

					var/transfer_moles = src.emagged ? 0.5 * TOTAL_MOLES(env) : 0.25 * TOTAL_MOLES(env)

					var/datum/gas_mixture/removed = env.remove(transfer_moles)

						//boutput(world, "got [transfer_moles] moles at [removed.temperature]")

					if(removed && TOTAL_MOLES(removed) > 0)

						var/heat_capacity = HEAT_CAPACITY(removed)
						//boutput(world, "heating ([heat_capacity])")
						var/current_power = 0
						if(heating)
							current_power = src.emagged ? src.heating_power * 3: src.heating_power
							removed.temperature = (removed.temperature*heat_capacity + current_power)/heat_capacity
						else
							current_power = src.emagged ? src.cooling_power * 3: src.cooling_power
							removed.temperature = (removed.temperature*heat_capacity + current_power)/heat_capacity

						cell.use(abs(current_power)/20000)

						//boutput(world, "now at [removed.temperature]")

					env.merge(removed)
					UpdateIcon()
					//boutput(world, "turf now at [env.temperature]")


			else
				on = 0
				UpdateIcon()


		return

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null

/obj/machinery/sauna_stove
	anchored = 0
	density = 1
	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "sauna0"
	name = "space saunastove"
	desc = "Made by Space Finnish using traditional space techniques, this space saunastove is guaranteed not to set the station on fire."
	var/obj/item/cell/cell
	var/on = 0
	var/heating = 0
	var/open = 0
	var/set_temperature = 50		// in celcius, add T0C for kelvin
	var/heating_power = 40000
	var/cooling_power = -30000
	mats = 8
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	flags = FPRINT


	New()
		..()
		cell = new(src)
		cell.charge = 1000
		cell.maxcharge = 1000
		UpdateIcon()
		return

	update_icon()
		if (on)
			if(heating)
				icon_state = "saunaH"
			else
				icon_state = "saunaC"
		else
			icon_state = "sauna0"
		if(open)
			icon_state = "sauna-open"
		return

	examine()
		. = ..()

		. += "The stove is [on ? "on" : "off"], [heating ? "heating" : "cooling"] and the hatch is [open ? "open" : "closed"]."
		if(open)
			. += "The power cell is [cell ? "installed" : "missing"]."
		else
			. += "The charge meter reads [cell ? round(cell.percent(),1) : 0]%"


	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/cell))
			if(open)
				if(cell)
					boutput(user, "There is already a power cell inside.")
					return
				else
					// insert cell
					var/obj/item/cell/C = user.equipped()
					if(istype(C))
						user.drop_item()
						cell = C
						C.set_loc(src)
						C.add_fingerprint(user)

						user.visible_message("<span class='notice'>[user] inserts a power cell into [src].</span>", "<span class='notice'>You insert the power cell into [src].</span>")
			else
				boutput(user, "The hatch must be open to insert a power cell.")
				return
		else if (isscrewingtool(I))
			open = !open
			user.visible_message("<span class='notice'>[user] [open ? "opens" : "closes"] the hatch on the [src].</span>", "<span class='notice'>You [open ? "open" : "close"] the hatch on the [src].</span>")
			UpdateIcon()
			if(!open && user.using_dialog_of(src))
				user.Browse(null, "window=saunastove")
				src.remove_dialog(user)
		else
			..()
		return

	attack_hand(mob/user)
		src.add_fingerprint(user)
		if(open)

			var/dat
			dat = "Power cell: "
			if(cell)
				dat += "<A href='byond://?src=\ref[src];op=cellremove'>Installed</A><BR>"
			else
				dat += "<A href='byond://?src=\ref[src];op=cellinstall'>Removed</A><BR>"

			dat += "Power Level: [cell ? round(cell.percent(),1) : 0]%<BR><BR>"

			dat += "Set Temperature: "

			dat += "<A href='?src=\ref[src];op=temp;val=-10'>--</A> <A href='?src=\ref[src];op=temp;val=-5'>-</A>"

			dat += " [set_temperature]&deg;C "
			dat += "<A href='?src=\ref[src];op=temp;val=5'>+</A> <A href='?src=\ref[src];op=temp;val=10'>++</A><BR>"

			src.add_dialog(user)
			user.Browse("<HEAD><TITLE>Sauna Stove Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=saunastove")
			onclose(user, "spaceheater")




		else
			on = !on
			user.visible_message("<span class='notice'>[user] switches [on ? "on" : "off"] the [src].</span>","<span class='notice'>You switch [on ? "on" : "off"] the [src].</span>")
			UpdateIcon()

			if (on)
				playsound(src.loc, 'sound/machines/heater_on.ogg', 50, 1)
			else
				playsound(src.loc, 'sound/machines/heater_off.ogg', 50, 1)
		return


	Topic(href, href_list)
		if (usr.stat)
			return
		if ((in_interact_range(src, usr) && istype(src.loc, /turf)) || (issilicon(usr)))
			src.add_dialog(usr)

			switch(href_list["op"])

				if("temp")
					var/value = text2num_safe(href_list["val"])

					// limit to 20-90 degC
					set_temperature = clamp(set_temperature + value, 0, 200)

				if("cellremove")
					if(open && cell && !usr.equipped())
						cell.UpdateIcon()
						usr.put_in_hand_or_drop(cell)
						cell = null

						usr.visible_message("<span class='notice'>[usr] removes the power cell from \the [src].</span>", "<span class='notice'>You remove the power cell from \the [src].</span>")


				if("cellinstall")
					if(open && !cell)
						var/obj/item/cell/C = usr.equipped()
						if(istype(C))
							usr.drop_item()
							cell = C
							C.set_loc(src)
							C.add_fingerprint(usr)

							usr.visible_message("<span class='notice'>[usr] inserts a power cell into \the [src].</span>", "<span class='notice'>You insert the power cell into \the [src].</span>")

			updateDialog()
		else
			usr.Browse(null, "window=saunastove")
			src.remove_dialog(usr)
		return



	process()
		if(on)
			if(cell?.charge > 0)

				var/turf/simulated/L = loc
				if(istype(L))
					var/datum/gas_mixture/env = L.return_air()
					if(env.temperature < (set_temperature+T0C))
						heating = 1
					else
						heating = 0

					var/transfer_moles = 0.25 * TOTAL_MOLES(env)

					var/datum/gas_mixture/removed = env.remove(transfer_moles)

						//boutput(world, "got [transfer_moles] moles at [removed.temperature]")

					if(removed)

						var/heat_capacity = HEAT_CAPACITY(removed)
						//boutput(world, "heating ([heat_capacity])")
						if(heating)
							removed.temperature = (removed.temperature*heat_capacity + heating_power)/heat_capacity
						else
							removed.temperature = (removed.temperature*heat_capacity + cooling_power)/heat_capacity

						cell.use(heating_power/20000)

						//boutput(world, "now at [removed.temperature]")

					env.merge(removed)
					UpdateIcon()
					//boutput(world, "turf now at [env.temperature]")


			else
				on = 0
				UpdateIcon()


		return

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null
