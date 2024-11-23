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
	var/max = T0C + 90
	var/min = T0C - 90
	var/heating_power = 400 /// fake heat capacity
	var/cooling_power = -300
	var/canBeWrenched = TRUE
	deconstruct_flags = DECON_WRENCH | DECON_WELDER
	flags = TGUI_INTERACTIVE

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
			ui = new(user, src, "SpaceHeater", src.name)
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
				src.max = T0C+400
				src.min = T0C-120
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
		src.max = initial(src.max)
		src.min = initial(src.min)
		return TRUE

	get_desc()
		. = ..()
		if (src.emagged)
			src.desc = "Made by Space Syndicates using traditional space techniques, this heater is guaranteed to set the station on fire."
		else
			src.desc = initial(src.desc)
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
		else if (canBeWrenched && iswrenchingtool(I))
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
					src.set_temperature = clamp((src.set_temperature + adjust_temperature), src.min, src.max)
				else if (text2num_safe(inputted_temperature) != null)
					src.set_temperature = clamp(text2num_safe(inputted_temperature), src.min, src.max)
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

TYPEINFO(/obj/machinery/space_heater/sauna_stove)
	mats = 8

/obj/machinery/space_heater/sauna_stove
	icon_state = "sauna0"
	name = "space saunastove"
	desc = "Made by Space Finnish using traditional space techniques, this space saunastove is guaranteed not to set the station on fire."
	canBeWrenched = FALSE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER

	update_icon()
		if (src.on)
			if (src.heating)
				icon_state = "saunaH"
			else
				icon_state = "saunaC"
		else
			icon_state = "sauna0"
		if (src.open)
			icon_state = "sauna-open"
		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		return FALSE

	demag(mob/user)
		return FALSE

