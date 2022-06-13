/obj/machinery/power/combustion_generator
	name = "Portable Generator"
	desc = "A portable combustion generator that burns fuel from a fuel tank, there is a port for a gas tank. A warning reads: DO NOT RUN INDOORS."
	icon_state = "chemportgen0"
	density = 1
	anchored = 0
	flags = NOSPLASH
	mats = list("MET-2" = 20, "CON-1" = 10)
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS

	var/active = 0
	var/fuel_drain_rate = 0.3
	var/atmos_drain_rate = 0.02
	var/carbon_output = 50
	var/standard_power_output = 2500 // around how much the generator will output running normally
	var/last_output

	var/obj/item/reagent_containers/food/drinks/fueltank/fuel_tank // power scales with volatility
	var/obj/item/tank/inlet_tank

	var/image/fuel_tank_image
	var/image/inlet_tank_image

	update_icon()
		if (src.active)
			if (src.last_output >= 40000)
				src.icon_state = "chemportgen2"
			else
				src.icon_state = "chemportgen1"
		else
			src.icon_state = "chemportgen0"

		src.overlays = null
		if (!src.fuel_tank_image)
			src.fuel_tank_image = image('icons/obj/power.dmi')
		if (!src.inlet_tank_image)
			src.inlet_tank_image = image('icons/obj/power.dmi')

		src.fuel_tank_image.icon_state = "genfueltank"
		src.inlet_tank_image.icon_state = "gengastank"
		if (src.fuel_tank)
			src.overlays += src.fuel_tank_image
		if (src.inlet_tank)
			src.overlays += src.inlet_tank_image

		signal_event("icon_updated")


	was_deconstructed_to_frame(mob/user)
		src.stop_engine()
		..()

	attackby(obj/item/W, mob/user)
		src.add_fingerprint(user)

		// atmos tank
		if (istype(W, /obj/item/tank))
			if (src.inlet_tank)
				user.show_text("There appears to be a tank loaded already.", "red")
				return

			if (!check_tank_oxygen(W))
				user.show_text("The tank doesn't contain any oxygen.", "red")
				return

			src.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			src.inlet_tank = W
			src.UpdateIcon()
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)


		// fuel tank
		else if (istype(W, /obj/item/reagent_containers/food/drinks/fueltank))
			if (src.fuel_tank)
				user.show_text("There appears to be a fuel tank loaded already.", "red")
				return

			if (!src.get_average_volatility(W.reagents))
				user.show_text("The fuel tank doesn't contain any fuel.", "red")
				return

			src.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			src.fuel_tank = W
			src.UpdateIcon()
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)

		else if (iswrenchingtool(W))
			if (src.anchored)
				src.disconnect()
				boutput(user, "<span class='notice'>You unanchor the [src] to the floor.</span>")
				src.visible_message("<span class='notice'>The [src] stops as it was unachored by [user].</span>")
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				return

			src.connect()
			boutput(user, "<span class='notice'>You anchor the [src] to the floor.</span>")
			src.visible_message("<span class='notice'>[user] anchors the [src] to the floor.</span>")
			playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)

	process()
		if (!src || !src.active)
			return

		var/average_volatility = get_average_volatility(src.fuel_tank.reagents)
		var/available_oxygen = src.check_available_oxygen()
		if (!available_oxygen || !src.fuel_tank || !average_volatility)
			src.stop_engine()
			playsound(src.loc, "sound/machines/tractorrev.ogg", 40, pitch=2)
			src.visible_message("<span class='notice'>The [src] stops, it seems like it ran out of something.</span>")
			return

		src.last_output = ((average_volatility * src.standard_power_output) * (available_oxygen * 5))
		src.add_avail(src.last_output WATTS)

		// src.visible_message("<span class='notice'>[src.last_output] WATTS</span>")

		var/turf/simulated/T = get_turf(src)
		if (istype(T))
			var/datum/gas_mixture/payload = new /datum/gas_mixture
			payload.carbon_dioxide = src.carbon_output * src.atmos_drain_rate
			payload.temperature = T20C
			T.assume_air(payload)

		if (src.inlet_tank)
			src.inlet_tank.air_contents.remove(src.atmos_drain_rate)
		else
			// Not sure if I should null check this
			T.air.remove(src.atmos_drain_rate)

		src.fuel_tank.reagents.remove_any(src.fuel_drain_rate)

		src.UpdateIcon()

	proc/connect()
		if (!get_turf(src))
			return

		src.anchored = 1
		src.netnum = 0

		if(makingpowernets)
			return

		for(var/obj/cable/C in src.get_connections())
			if(src.netnum == 0 && C.netnum != 0)
				src.netnum = C.netnum
			else if(C.netnum != 0 && C.netnum != src.netnum)
				if(!defer_powernet_rebuild)
					makepowernets()
				else
					defer_powernet_rebuild = 2
				return

		if(src.netnum)
			src.powernet = powernets[src.netnum]
			if (!(src in src.powernet.nodes))
				src.powernet.nodes += src

	proc/disconnect()
		if(src.powernet)
			for (var/node in src.powernet.nodes)
				if (node == src)
					src.powernet.nodes -= src

			for (var/node in src.powernet.data_nodes)
				if (node == src)
					src.powernet.data_nodes -= src
			netnum = 0

		if(!defer_powernet_rebuild)
			makepowernets()
		else
			defer_powernet_rebuild = 2

		src.stop_engine()
		src.anchored = 0
		return

	proc/start_engine(var/mob/user as mob)
		if (!src.active)
			if (!src.ready_to_start())
				if (istype(user))
					boutput(user, "<span class='notice'>You can't seem to get the [src] to start.</span>")
				return

			src.active = 1
			src.UpdateIcon()


			if (istype(user))
				src.visible_message("<span class='notice'>[user] starts the [src].</span>")
			playsound(src.loc, "sound/machines/tractorrev.ogg", 40, pitch=2)

	proc/stop_engine(var/mob/user as mob)
		if (src.active)
			src.active = 0
			src.UpdateIcon()
			if (istype(user))
				src.visible_message("<span class='notice'>[user] stops the [src].</span>")
			playsound(src.loc, "sound/machines/tractorrev.ogg", 40, pitch=2)

	proc/ready_to_start()
		if (!anchored || !src.fuel_tank)
			return

		if (!src.get_average_volatility(src.fuel_tank.reagents) || !src.check_available_oxygen())
			return

		return 1

	// Returns the concentration of oxygen in the available gas_mixture
	proc/check_available_oxygen()
		if (src.inlet_tank)
			return src.check_tank_oxygen(src.inlet_tank)

		var/turf/simulated/T = get_turf(src)
		if (!istype(T))
			return

		if (!T.air || T.air.oxygen <= 0)
			return

		/* src.visible_message("<span class='notice'>Oxygen Moles: [T.air.oxygen]</span>")
		src.visible_message("<span class='notice'>Total Moles: [TOTAL_MOLES(T.air)]</span>")
		src.visible_message("<span class='notice'>Oxygen Concentration: [T.air.oxygen / TOTAL_MOLES(T.air)]</span>") */
		return T.air.oxygen / TOTAL_MOLES(T.air)

	proc/check_tank_oxygen(obj/item/tank/T)
		if (!src || !T || !T.air_contents)
			return

		if (T.air_contents.oxygen <= 0)
			return

		// debug, remove dummy
		/* src.visible_message("<span class='notice'>Oxygen Moles: [T.air_contents.oxygen]</span>")
		src.visible_message("<span class='notice'>Total Moles: [TOTAL_MOLES(T.air_contents)]</span>")
		src.visible_message("<span class='notice'>Oxygen Concentration: [T.air_contents.oxygen / TOTAL_MOLES(T.air_contents)]</span>") */
		return T.air_contents.oxygen / TOTAL_MOLES(T.air_contents)

	proc/get_average_volatility(datum/reagents/R)
		if (!R || !R.total_volume)
			return

		var/average
		var/i
		for (var/reagent_id in R.reagent_list)
			var/datum/reagent/current_reagent = R.reagent_list[reagent_id]
			if (current_reagent)
				average += current_reagent.volatility
				i++

		return average / i

	proc/eject_fuel_tank(var/mob/user as mob)
		if (!src || !src.fuel_tank)
			return

		src.fuel_tank.set_loc(get_turf(src))
		if (istype(user))
			src.visible_message("<span class='notice'>[user] removes the [src.fuel_tank] from the [src].</span>")
			user.put_in_hand_or_eject(src.fuel_tank)

		playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
		src.fuel_tank = null
		src.stop_engine()
		src.visible_message("<span class='notice'>The [src] stops as the fuel tank is removed.</span>")
		src.UpdateIcon()

	proc/eject_inlet_tank(var/mob/user as mob)
		if (!src || !src.inlet_tank)
			return

		src.inlet_tank.set_loc(get_turf(src))
		if (istype(user))
			src.visible_message("<span class='notice'>[user] removes the [src.inlet_tank] from the [src].</span>")
			user.put_in_hand_or_eject(src.inlet_tank)

		playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
		src.inlet_tank = null
		src.UpdateIcon()

	// verbs, replace cause stinky
	verb/start_stop()
		set name = "Start/Stop Generator"
		set src in oview(1)
		set category = "Local"

		if (!src.active)
			src.start_engine(usr)
			return

		src.stop_engine()

	verb/eject_fuel()
		set name = "Eject Fuel Tank"
		set src in oview(1)
		set category = "Local"

		src.eject_fuel_tank(usr)

	verb/eject_inlet()
		set name = "Eject Oxygen Tank"
		set src in oview(1)
		set category = "Local"

		src.eject_inlet_tank(usr)


