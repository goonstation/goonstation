/obj/machinery/power/combustion_generator
	name = "Portable Generator"
	desc = "A portable combustion generator that burns fuel from a fuel tank, there is a port for a gas tank. A warning reads: DO NOT RUN INDOORS, OR WHILE UNSECURE."
	icon_state = "chemportgen0"
	density = 1
	anchored = 0
	flags = FPRINT | FLUID_SUBMERGE | NOSPLASH
	mats = list("MET-2" = 12, "CON-1" = 8)
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS

	var/active = 0
	var/fuel_drain_rate = 0.3
	var/atmos_drain_rate = 0.02
	var/standard_power_output = 5000 // around how much the generator will output running normally
	var/last_output

	var/obj/item/reagent_containers/food/drinks/fueltank/fuel_tank
	var/obj/item/tank/inlet_tank

	var/image/fuel_tank_image
	var/image/inlet_tank_image

	update_icon()
		if (src.active)
			if (src.last_output >= 40000)
				src.icon_state = "chemportgen3"
			else if (src.last_output >= 20000)
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

		if (istype(src.inlet_tank, /obj/item/tank/oxygen) || istype(src.inlet_tank, /obj/item/tank/emergency_oxygen))
			src.inlet_tank_image.icon_state = "gengastank_o"
		else
			src.inlet_tank_image.icon_state = "gengastank"

		if (src.fuel_tank)
			src.overlays += src.fuel_tank_image
		if (src.inlet_tank)
			src.overlays += src.inlet_tank_image

		signal_event("icon_updated")

	was_deconstructed_to_frame(mob/user)
		. = ..()
		src.stop_engine()


	attack_hand(var/mob/user, params)
		if (..(user, params))
			return

		var/dat = {"
		<b>Status:</b><BR>
		Engine: [src.active ? "Active" : "Stopped"] <BR>
		Floor Bolts: [src.anchored ? "Anchored" : "Unanchored"] <BR>
		Power Output: [src.active && src.last_output ? src.last_output : 0]W<BR><BR>
		<b>Controls:</b><BR>
		<A href='?src=\ref[src];engine=1'>Engine: [active ? "Stop" : "Start"]</A><BR>
		<A href='?src=\ref[src];fuel=1'>[src.fuel_tank ? "Eject [src.fuel_tank.name]" : "Connect Fuel Tank"]</A><BR>
		<A href='?src=\ref[src];inlet=1'>[src.inlet_tank ? "Eject [src.inlet_tank.name]" : "Connect Gas Tank"]</A><BR>
		"}

		if (user.client.tooltipHolder)
			user.client.tooltipHolder.showClickTip(src, list(
				"params" = params,
				"title" = src.name,
				"content" = dat,
			))

		return

	Topic(href, href_list)
		if (..(href, href_list))
			return

		src.add_dialog(usr)

		if (href_list["engine"])
			if (!src.active)
				if (src.start_engine())
					boutput(usr, "<span class='alert'>The [src] fails to start!</span>")

				else
					src.visible_message("<span class='notice'>[usr] starts the [src].</span>")

			else
				src.stop_engine()
				src.visible_message("<span class='notice'>[usr] stops the [src].</span>")

		else if (href_list["fuel"])
			if (src.fuel_tank)
				src.visible_message("<span class='notice'>[usr] removes [src.fuel_tank] from the [src].</span>")
				src.eject_fuel_tank(usr)

			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/reagent_containers/food/drinks/fueltank))
					if (src.fuel_tank)
						boutput(usr, "<span class='alert'>There appears to be a fuel tank loaded already!</span>")
						return

					if (!src.get_average_volatility(I.reagents))
						boutput(usr, "<span class='alert'>The [I.name] doesn't contain any fuel!</span>")
						return

					src.visible_message("<span class='notice'>[usr] loads [I] into the [src].</span>")
					usr.u_equip(I)
					I.set_loc(src)
					src.fuel_tank = I
					src.UpdateIcon()
					playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)

		else if (href_list["inlet"])
			if (src.inlet_tank)
				src.visible_message("<span class='notice'>[usr] removes [src.inlet_tank] from the [src].</span>")
				src.eject_inlet_tank(usr)

			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/tank) && !(istype(I, /obj/item/tank/plasma) || istype(I, /obj/item/tank/jetpack)))
					if (src.inlet_tank)
						boutput(usr, "<span class='alert'>There appears to be a tank loaded already!</span>")
						return

					if (src.check_tank_oxygen(I))
						boutput(usr, "<span class='alert'>The [I.name] doesn't contain any oxygen.</span>")
						return

					src.visible_message("<span class='notice'>[usr] loads [I] into the [src].</span>")
					usr.u_equip(I)
					I.set_loc(src)
					src.inlet_tank = I
					src.UpdateIcon()
					playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)

		src.updateUsrDialog()
		return


	attackby(obj/item/W, mob/user)
		src.add_fingerprint(user)

		// atmos tank
		if (istype(W, /obj/item/tank) && (!istype(W, /obj/item/tank/plasma) || !istype(W, /obj/item/tank/jetpack)))
			if (src.inlet_tank)
				boutput(user, "<span class='alert'>There appears to be a tank loaded already!</span>")
				return

			if (!src.check_tank_oxygen(W))
				boutput(user, "<span class='alert'>The [W.name] doesn't contain any oxygen.</span>")
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
				boutput(user, "<span class='alert'>There appears to be a fuel tank loaded already!</span>")
				return

			if (!src.get_average_volatility(W.reagents))
				boutput(user, "<span class='alert'>The [W.name] doesn't contain any fuel!</span>")
				return

			src.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			src.fuel_tank = W
			src.UpdateIcon()
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)

		else if (iswrenchingtool(W))
			if (src.anchored)
				if (src.active)
					src.visible_message("<span class='notice'>The [src] stops as it was unachored by [user].</span>")
					src.stop_engine()
				else
					src.visible_message("<span class='notice'>[user] secures the [src]'s bolts into the floor.</span>")

				src.anchored = 0
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				return

			src.anchored = 1
			src.visible_message("<span class='notice'>[user] removes the [src]'s bolts from the floor.</span>")
			playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)

		src.updateUsrDialog()
		return

#define FUEL_QUALITY_VERY_HIGH 8
#define FUEL_QUALITY_HIGH 5
#define FUEL_QUALITY_AVERAGE 3
#define FUEL_QUALITY_LOW 2
#define FUEL_QUALITY_VERY_LOW 1

	process()
		if (!src || !src.active)
			return

		var/average_volatility = get_average_volatility(src.fuel_tank.reagents)
		var/available_oxygen = src.check_available_oxygen()
		if (!available_oxygen || !average_volatility)
			src.stop_engine()
			src.visible_message("<span class='alert'>The [src]'s engine fails to run, it has nothing to combust!</span>")
			return

		if (!src.anchored)
			src.stop_engine()
			src.visible_message("<span class='alert'>The [src] makes a horrible racket and shuts down, it has become unanchored!</span>")
			return

		var/obj/cable/C = src.get_output_cable()
		if (!C)
			src.stop_engine()
			src.visible_message("<span class='alert'>Electricity begins to arc off the [src] causing it to shutdown, it has nothing to output to!</span>")
			elecflash(src.loc, 0, power = 3, exclude_center = 0)
			return

		src.last_output = src.standard_power_output * ((average_volatility / FUEL_QUALITY_AVERAGE) * (available_oxygen * 5))
		var/datum/powernet/P = C.get_powernet()
		P.newavail += src.last_output WATTS

		var/turf/simulated/T = get_turf(src)
		if (istype(T))
			var/datum/gas_mixture/payload = new /datum/gas_mixture
			payload.carbon_dioxide = src.atmos_drain_rate * average_volatility
			payload.temperature = T20C
			T.assume_air(payload)

		if (src.inlet_tank)
			src.inlet_tank.air_contents.remove(src.atmos_drain_rate * average_volatility)
		else
			T.air.remove(src.atmos_drain_rate * average_volatility)

		src.fuel_tank.reagents.remove_any(src.fuel_drain_rate)

		src.UpdateIcon()
		src.updateDialog()

	proc/get_average_volatility(datum/reagents/R)
		if (!R || !R.total_volume)
			return

		var/average = 0
		for (var/reagent_id in R.reagent_list)
			var/datum/reagent/current_reagent = R.reagent_list[reagent_id]
			if (current_reagent)
				switch(reagent_id)
					if ("foof", "kerosene", "nitrotri_dry", "dbreath")
						average += (FUEL_QUALITY_VERY_HIGH * current_reagent.volume)

					if ("blackpowder", "phlogiston", "napalm_goo", "sorium", "firedust")
						average += (FUEL_QUALITY_HIGH * current_reagent.volume)

					if ("fuel", "acetone")
						average += (FUEL_QUALITY_AVERAGE * current_reagent.volume)

					if ("oil", "butter", "diethylamine", "ethanol")
						average += (FUEL_QUALITY_LOW * current_reagent.volume)

					if ("plasma", "magnesium", "phosphorus")
						average += (FUEL_QUALITY_VERY_LOW * current_reagent.volume)

					else
						var/datum/reagent/fooddrink/alcoholic/current_alcoholic_reagent = current_reagent
						if (istype(current_alcoholic_reagent) && current_alcoholic_reagent.alch_strength >= 0.5)
							average += 3

		if (!average)
			return 0

		return average / R.total_volume

#undef FUEL_QUALITY_VERY_HIGH
#undef FUEL_QUALITY_HIGH
#undef FUEL_QUALITY_AVERAGE
#undef FUEL_QUALITY_LOW
#undef FUEL_QUALITY_VERY_LOW

	proc/start_engine()
		if (!src.active)
			if (!src.ready_to_start())
				return 1

			src.active = 1
			src.UpdateIcon()
			src.updateDialog()

			if (!ON_COOLDOWN(src, "tractor", 2 SECOND))
				playsound(src.loc, "sound/machines/tractorrev.ogg", 40, pitch=2)

			return 0

	proc/stop_engine()
		if (src.active)
			src.active = 0
			src.UpdateIcon()
			src.updateDialog()

			if (!ON_COOLDOWN(src, "tractor", 2 SECOND))
				playsound(src.loc, "sound/machines/tractorrev.ogg", 40, pitch=2)

			return 0

	proc/ready_to_start()
		if (!anchored || !src.fuel_tank)
			return 0

		if (!src.get_average_volatility(src.fuel_tank.reagents) || !src.check_available_oxygen())
			return 0

		return 1

	// Returns the concentration of oxygen in the available gas_mixture
	proc/check_available_oxygen()
		if (src.inlet_tank)
			return src.check_tank_oxygen(src.inlet_tank)

		var/turf/simulated/T = get_turf(src)
		if (!istype(T))
			return 0

		if (!T.air || T.air.oxygen <= 0)
			return 0

		return T.air.oxygen / TOTAL_MOLES(T.air)

	proc/check_tank_oxygen(obj/item/tank/T)
		if (!src || !T || !T.air_contents)
			return 0

		if (T.air_contents.oxygen <= 0)
			return 0

		return T.air_contents.oxygen / TOTAL_MOLES(T.air_contents)

	proc/get_output_cable()
		var/list/cables = src.get_connections()

		if (!cables.len)
			return

		for (var/obj/cable/C in cables)
			if (C.get_powernet())
				return C

		return

	proc/eject_fuel_tank(var/mob/user)
		if (!src || !src.fuel_tank)
			return

		if (src.active)
			src.visible_message("<span class='notice'>The [src] stops as the fuel tank is removed.</span>")
			src.stop_engine()

		src.fuel_tank.set_loc(get_turf(src))
		if (istype(user))
			user.put_in_hand_or_eject(src.fuel_tank)

		src.fuel_tank = null
		src.UpdateIcon()
		playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)


	proc/eject_inlet_tank(var/mob/user)
		if (!src || !src.inlet_tank)
			return

		src.inlet_tank.set_loc(get_turf(src))
		if (istype(user))
			user.put_in_hand_or_eject(src.inlet_tank)

		src.inlet_tank = null

		src.UpdateIcon()
		playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
