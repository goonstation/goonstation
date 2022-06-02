/obj/machinery/power/combustion_generator
	name = "Portable Generator"
	desc = "A portable combustion generator that burns fuel from a fuel tank"
	icon_state = "furnace"
	density = 1
	anchored = 0
	flags = NOSPLASH
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS

	var/atmos_drain_rate = 0.08
	var/active = 0

	var/obj/item/reagent_containers/food/drinks/fueltank/fuel_tank // power scales with volatility
	var/obj/item/tank/inlet_tank

	attackby(obj/item/W, mob/user)
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

		else if (istype(W, /obj/item/reagent_containers/food/drinks/fueltank))
			if (src.fuel_tank)
				user.show_text("There appears to be a fuel tank loaded already.", "red")
				return

			if (!check_tank_fuel(W))
				user.show_text("The fuel tank doesn't contain any fuel.", "red")
				return

			src.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			src.fuel_tank = W
			src.UpdateIcon()

		else if (iswrenchingtool(W))
			if (src.anchored)
				boutput(user, "<span class='notice'>You unanchor [src] to the floor.</span>")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				src.disconnect()
				return

			src.connect()
			boutput(user, "<span class='notice'>You anchor [src] to the floor.</span>")
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)

	process()
		if (!src)
			return

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
			src.powernet.nodes += src

	proc/disconnect()
		if(src.powernet)
			src.powernet.nodes -= src
			src.powernet.data_nodes -= src
			netnum = 0

		if(src.directwired)
			if(!defer_powernet_rebuild)
				makepowernets()
			else
				defer_powernet_rebuild = 2

		src.anchored = 0
		return

	proc/start_engine()
		if (!src.ready_to_start())
			return

		src.active = 1
		playsound(src.loc, "sound/machines/tractorrev.ogg", 40, pitch=3)

	proc/stop_engine()
		src.active = 0
		playsound(src.loc, "sound/machines/tractorrev.ogg", 40, pitch=2)

	proc/ready_to_start()
		if (!anchored || !src.fuel_tank)
			return

		if (!get_average_volatility(src.fuel_tank.reagents))
			return

		return 1


	proc/check_tank_oxygen(obj/item/tank/T)
		if (!src || !T || !T.air_contents)
			return

		if (T.air_contents.oxygen <= 0)
			return

		return 1

	proc/check_tank_fuel(obj/item/reagent_containers/food/drinks/fueltank/T)
		if (!src || !T)
			return

		if (!get_average_volatility(T.reagents))
			return

		return 1

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

	verb/startstop()
		set name = "Start/Stop Generator"
		set src in oview(1)
		set category = "Local"
		if (!src.active)
			src.start_engine()
			return
		src.stop_engine()
