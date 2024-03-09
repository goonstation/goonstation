TYPEINFO(/obj/machinery/space_heater)
	mats = 8

/obj/machinery/space_heater
	anchored = UNANCHORED
	density = 1
	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "sheater0"
	name = "space HVAC"
	desc = "Made by Space Amish using traditional space techniques, this space heater is guaranteed not to set the station on fire."
	var/emagged = FALSE
	var/obj/item/cell/cell
	var/open = FALSE
	var/on = FALSE
	var/heating = FALSE // If its cooling down (false) or heating up (true) the current atmosphere
	var/set_temperature = T0C+50
	var/heating_power = 400 /// fake heat capacity
	var/cooling_power = -300
	deconstruct_flags = DECON_WRENCH | DECON_WELDER
	flags = FPRINT | TGUI_INTERACTIVE

	#define max (src.emagged ? T0C+400 : T0C+90)
	#define min (src.emagged ? T0C-120 : T0C-90)

	New()
		..()
		src.cell = new(src)
		src.cell.charge = 1000
		src.cell.maxcharge = 1000
		UpdateIcon()
		return

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "space_heater", src.name)
			ui.open()

	ui_data(mob/user)
		. = list()
		.["on"] = src.on
		.["max"] = max
		.["min"] = min
		.["heating"] = src.heating
		.["emagged"] = src.emagged
		.["set_temperature"] = src.set_temperature
		.["cell"] = src.cell
		if (src.cell != null) // Cant get the cell variables if it doesnt exist
			.["cell_name"] = src.cell.name
			.["cell_charge"] = src.cell.percent()

	update_icon()
		if (src.on)
			if(src.heating)
				icon_state = "sheaterH"
			else
				icon_state = "sheaterC"
		else
			icon_state = "sheater0"
		if (src.open)
			icon_state = "sheater-open"
		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)
			if (src.open)
				if (user)
					user.show_text("You short out the temperature limiter circuit in the [src].", "blue")
				src.emagged = TRUE
				return TRUE
			else
				if (user)
					user.show_text("The internal circuitry must be exposed!", "red")
				return FALSE
		else
			if (user)
				user.show_text("The temperature limiter is already burned out.", "red")
				return FALSE

	demag(mob/user)
		if (!src.emagged)
			return FALSE
		if (user)
			user.show_text("You repair the temperature regulator in the [src].", "blue")
		src.emagged = FALSE
		return TRUE

	get_desc()
		. = ..()
		if (src.emagged)
			src.desc = "Made by Space Amish using traditional space techniques, this heater is guaranteed to set the station on fire."
		else
			src.desc = "Made by Space Amish using traditional space techniques, this heater is guaranteed not to set the station on fire."
		. += "The HVAC is [src.on ? "on" : "off"], and [src.heating ? "heating" : "cooling"] the environment."
		. += "The power cell is [src.cell ? "installed" : "missing"]."
		if(src.open)
			. += "The power cell is [cell ? "installed" : "missing"]."
		if (src.cell != null)
			. += "The charge meter reads [src.cell ? round(src.cell.percent(),1) : 0]%"

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/cell))
			if(src.open)
				if(src.cell)
					boutput(user, "There is already a power cell inside.")
					return
				else
					// insert cell
					var/obj/item/cell/C = user.equipped()
					if(istype(C))
						user.drop_item()
						src.cell = C
						C.set_loc(src)
						C.add_fingerprint(user)

						user.visible_message(SPAN_NOTICE("[user] inserts a power cell into [src]."), SPAN_NOTICE("You insert the power cell into [src]."))
			else
				boutput(user, "The hatch must be open to insert a power cell.")
				return
		else if (isscrewingtool(I))
			src.open = !src.open
			user.visible_message(SPAN_NOTICE("[user] [open ? "opens" : "closes"] the hatch on the [src]."), SPAN_NOTICE("You [src.open ? "open" : "close"] the hatch on the [src]."))
			if (!src.open)
				tgui_process.close_uis(src)
			UpdateIcon()
		else if (iswrenchingtool(I))
			if (user)
				user.show_text("You [src.anchored ? "release" : "anchor"] the [src]", "blue")
			src.anchored = !src.anchored
			playsound(src.loc, 'sound/items/Ratchet.ogg', 40, 0, 0)
		else
			..()
		return

	attack_hand(mob/user)
		src.add_fingerprint(user)
		if(src.open)
			ui_interact(user)
		else
			if (src.on && src.emagged)
				user.show_text("The button seems to be stuck!", "red")
			else
				src.on = !src.on
				user.visible_message(SPAN_NOTICE("[user] switches [src.on ? "on" : "off"] the [src]."),SPAN_NOTICE("You switch [src.on ? "on" : "off"] the [src]."))
				UpdateIcon()
			if (src.on)
				playsound(src.loc, 'sound/machines/heater_on.ogg', 50, 1)
			else
				playsound(src.loc, 'sound/machines/heater_off.ogg', 50, 1)
		return

	ui_act(action, list/params)
		. = ..()
		if (.)
			return
		switch(action)
			if("set_temp")
				var/adjust_temperature = params["temperature_adjust"]
				var/inputted_temperature = params["inputted_temperature"] // For dragging
				if (adjust_temperature)
					src.set_temperature = clamp((src.set_temperature + adjust_temperature), min , max)
				else if (text2num_safe(inputted_temperature) != null)
					src.set_temperature = clamp(text2num_safe(inputted_temperature), min , max)
				. = TRUE

			if("cellremove")
				var/obj/item/I = src.cell
				if (!I)
					boutput(usr, SPAN_ALERT("No cell found to eject."))
					return
				I.set_loc(src.loc)
				src.on = FALSE
				usr.put_in_hand_or_eject(I)
				usr.visible_message(SPAN_NOTICE("[usr] removes the power cell from \the [src]."),
				SPAN_NOTICE("You remove the power cell from \the [src]."))
				UpdateIcon()
				. = TRUE

			if("cellinstall")
				var/obj/item/cell = usr.equipped()
				if(istype(cell, /obj/item/cell))
					if(src.cell)
						boutput(usr, SPAN_ALERT("A cell is already loaded into the machine."))
						return
					src.cell =  cell
					usr.drop_item()
					cell.set_loc(src)
					usr.visible_message(SPAN_NOTICE("[usr] inserts a power cell into \the [src]."), SPAN_NOTICE("You insert the power cell into \the [src]."))
				. = TRUE

	process()
		if(src.on)
			if(src.cell?.charge > 0)

				var/turf/simulated/L = loc
				if(istype(L))
					var/datum/gas_mixture/env = L.return_air()
					if(env.temperature < (set_temperature))
						heating = TRUE
					else
						heating = FALSE

					var/transfer_moles = src.emagged ? 0.5 * TOTAL_MOLES(env) : 0.25 * TOTAL_MOLES(env)

					var/datum/gas_mixture/removed = env.remove(transfer_moles)

						//boutput(world, "got [transfer_moles] moles at [removed.temperature]")

					if(removed && TOTAL_MOLES(removed) > 0)

						var/heat_capacity = HEAT_CAPACITY(removed)
						//boutput(world, "heating ([heat_capacity])")
						var/current_power = 0
						if(src.heating)
							current_power = src.emagged ? src.heating_power * 3: src.heating_power
							removed.temperature = (removed.temperature*heat_capacity + current_power * src.set_temperature)/heat_capacity
						else
							current_power = src.emagged ? src.cooling_power * 3: src.cooling_power
							removed.temperature = (removed.temperature*heat_capacity + current_power * src.set_temperature)/heat_capacity

						src.cell.use(abs(current_power)/20000)

						//boutput(world, "now at [removed.temperature]")

					L.assume_air(removed)
					UpdateIcon()
					//boutput(world, "turf now at [env.temperature]")


			else
				src.on = 0
				UpdateIcon()


		return

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null

	#undef max
	#undef min

TYPEINFO(/obj/machinery/sauna_stove)
	mats = 8

/obj/machinery/sauna_stove
	anchored = UNANCHORED
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

						user.visible_message(SPAN_NOTICE("[user] inserts a power cell into [src]."), SPAN_NOTICE("You insert the power cell into [src]."))
			else
				boutput(user, "The hatch must be open to insert a power cell.")
				return
		else if (isscrewingtool(I))
			open = !open
			user.visible_message(SPAN_NOTICE("[user] [open ? "opens" : "closes"] the hatch on the [src]."), SPAN_NOTICE("You [open ? "open" : "close"] the hatch on the [src]."))
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
			user.visible_message(SPAN_NOTICE("[user] switches [on ? "on" : "off"] the [src]."),SPAN_NOTICE("You switch [on ? "on" : "off"] the [src]."))
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

						usr.visible_message(SPAN_NOTICE("[usr] removes the power cell from \the [src]."), SPAN_NOTICE("You remove the power cell from \the [src]."))


				if("cellinstall")
					if(open && !cell)
						var/obj/item/cell/C = usr.equipped()
						if(istype(C))
							usr.drop_item()
							cell = C
							C.set_loc(src)
							C.add_fingerprint(usr)

							usr.visible_message(SPAN_NOTICE("[usr] inserts a power cell into \the [src]."), SPAN_NOTICE("You insert the power cell into \the [src]."))

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
