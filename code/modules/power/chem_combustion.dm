#define FUEL_DRAIN_RATE 0.3
#define ATMOS_DRAIN_RATE 0.02
#define CARBON_OUTPUT_RATE 0.01 // for every part of fuel burnt
#define OPTIMAL_MIX 14.7 // how many parts oxygen for every part of fuel

#define INLET_MAX 1
#define INLET_MIN 0

/obj/machinery/power/combustion_generator
	name = "Portable Combustion Generator"
	desc = "A portable combustion generator that burns fuel from a fuel tank, there is a port for a gas tank. A warning reads: DO NOT RUN INDOORS, OR WHILE UNSECURE."
	icon_state = "chemportgen0"
	density = 1
	anchored = 0
	flags = FPRINT | FLUID_SUBMERGE | NOSPLASH
	mats = list("MET-2" = 80, "CON-1" = 60)
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS

	var/active = FALSE

	// 0 - 1
	var/fuel_inlet = 0.04
	var/atmos_inlet = 0.56

	var/output_multiplier = 1 // for bigger generators?

	var/last_output = 0
	var/last_mix = 0
	var/last_inlet = 0
	var/last_oxygen = 0
	var/last_fuel = 0

	// reagents
	var/valid_fuels = list(
		"dbreath" = 60000,
		"kerosene" = 45000,
		"firedust" = 30000,
		"phlogiston" = 25000,
		"napalm_goo" = 20000,
		"diethylamine" = 18000,
		"acetone" = 14000,
		"ethanol" = 12000,
		"oil" = 10000,
		"fuel" = 8000,
		"pyrosium" = 7000,
		"hydrogen" = 6500,
		"plasma" = 6000,
		"phosphorus" = 5000,
		"magnesium" = 4000
	) // wattage

	// bit wierd but a bunch of type checks feels bad
	var/valid_tanks = list(
		/obj/item/tank/air,
		/obj/item/tank/oxygen,
		/obj/item/tank/anesthetic
	)

	// tanks
	var/obj/item/reagent_containers/food/drinks/fueltank/fuel_tank
	var/obj/item/tank/inlet_tank

	// images
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

		src.ClearSpecificOverlays("fueltank", "inlettank")
		if (!src.fuel_tank_image)
			src.fuel_tank_image = image('icons/obj/power.dmi')
		if (!src.inlet_tank_image)
			src.inlet_tank_image = image('icons/obj/power.dmi')

		src.fuel_tank_image.icon_state = "genfueltank"

		if (istype(src.inlet_tank, /obj/item/tank/oxygen))
			src.inlet_tank_image.icon_state = "gengastank_o"
		else
			src.inlet_tank_image.icon_state = "gengastank"

		if (src.fuel_tank)
			src.UpdateOverlays(src.fuel_tank_image, "fueltank")
		if (src.inlet_tank)
			src.UpdateOverlays(src.inlet_tank_image, "inlettank")

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
		<A href='?src=\ref[src];inlet=1'>[src.inlet_tank ? "Eject [src.inlet_tank.name]" : "Connect Gas Tank"]</A><BR><BR>
		<b>Mix:</b><BR>
		Fuel: <A href='?src=\ref[src];fuel_inlet=-0.10'>\<\<</A> <A href='?src=\ref[src];fuel_inlet=-0.01'>\<</A> [fuel_inlet * 100]% <A href='?src=\ref[src];fuel_inlet=0.01'>\></A> <A href='?src=\ref[src];fuel_inlet=0.1'>\>\></A><BR>
		Air: <A href='?src=\ref[src];air_inlet=-0.10'>\<\<</A> <A href='?src=\ref[src];air_inlet=-0.01'>\<</A> [atmos_inlet * 100]% <A href='?src=\ref[src];air_inlet=0.01'>\></A> <A href='?src=\ref[src];air_inlet=0.1'>\>\></A>
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
					if (!src.get_fuel_power(I.reagents))
						boutput(usr, "<span class='alert'>The [I.name] doesn't contain any fuel!</span>")
						return

					src.visible_message("<span class='notice'>[usr] loads [I] into the [src].</span>")
					usr.u_equip(I)
					I.set_loc(src)
					src.fuel_tank = I
					src.UpdateIcon()
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

		else if (href_list["inlet"])
			if (src.inlet_tank)
				src.visible_message("<span class='notice'>[usr] removes [src.inlet_tank] from the [src].</span>")
				src.eject_inlet_tank(usr)

			else
				var/obj/item/tank/I = usr.equipped()
				if (istype(I) && (I.type in src.valid_tanks))
					if (!src.check_tank_oxygen(I))
						boutput(usr, "<span class='alert'>The [I.name] doesn't contain any oxygen.</span>")
						return

					src.visible_message("<span class='notice'>[usr] loads [I] into the [src].</span>")
					usr.u_equip(I)
					I.set_loc(src)
					src.inlet_tank = I
					src.UpdateIcon()
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

		// Add checks after input
		else if (href_list["fuel_inlet"])
			var/change_by = text2num_safe(href_list["fuel_inlet"])
			if (!change_by)
				return

			var/change_to = src.fuel_inlet + change_by
			src.fuel_inlet = clamp(change_to, INLET_MIN, INLET_MAX)

		else if (href_list["air_inlet"])
			var/change_by = text2num_safe(href_list["air_inlet"])
			if (!change_by)
				return

			var/change_to = src.atmos_inlet + change_by
			src.atmos_inlet = clamp(change_to, INLET_MIN, INLET_MAX)

		src.updateUsrDialog()
		return


	attackby(obj/item/W, mob/user)
		src.add_fingerprint(user)

		// atmos tank
		if (istype(W, /obj/item/tank) && (W.type in src.valid_tanks))
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
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)


		// fuel tank
		else if (istype(W, /obj/item/reagent_containers/food/drinks/fueltank))
			if (src.fuel_tank)
				boutput(user, "<span class='alert'>There appears to be a fuel tank loaded already!</span>")
				return

			if (!src.get_fuel_power(W.reagents))
				boutput(user, "<span class='alert'>The [W.name] doesn't contain any fuel!</span>")
				return

			src.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			src.fuel_tank = W
			src.UpdateIcon()
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

		else if (iswrenchingtool(W))
			if (src.anchored)
				if (src.active)
					src.visible_message("<span class='notice'>The [src] stops as it was unachored by [user].</span>")
					src.stop_engine()
				else
					src.visible_message("<span class='notice'>[user] removes the [src]'s bolts from the floor.</span>")

				src.anchored = FALSE
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				return

			src.anchored = TRUE
			src.visible_message("<span class='notice'>[user] secures the [src]'s bolts into the floor.</span>")
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)

		else if (ispulsingtool(W))
			if (!src.active)
				boutput(user, "<span class='alert'>You fail to interface with the [src]'s engine control system.</span>")
				return

			boutput(user, {"
			<hr>
			<span class='notice'><b>You take readings from the [src]'s engine control system:</b></span><br><br>
			<span class='notice'>Stoichiometric: [src.last_mix]</span><br>
			<span class='notice'>Inlet Flow: [(src.last_inlet * 100) / 2]%</span><br>
			<span class='notice'>Oxygen Purity: [src.last_oxygen * 100]%</span><br>
			<span class='notice'>Fuel Quality: [src.last_fuel]W</span>
			<hr>
			"})

		src.updateUsrDialog()
		return

	process(var/mult)
		if (!src || !src.active)
			return

		src.last_fuel = get_fuel_power(src.fuel_tank.reagents)
		src.last_oxygen = src.check_available_oxygen()
		if (!src.last_oxygen || !src.last_fuel || !src.fuel_inlet || !src.atmos_inlet)
			src.stop_engine()
			src.visible_message("<span class='alert'>The [src]'s engine fails to run, it has nothing to combust!</span>")
			return

		if (!src.anchored)
			src.stop_engine()
			src.visible_message("<span class='alert'>The [src] makes a horrible racket and shuts down, it has become unanchored!</span>")
			return

		var/fuel_air_mix = (src.atmos_inlet / src.fuel_inlet) // difference between current mix and optimal mix.
		if (fuel_air_mix < 8 || fuel_air_mix > 20) // too much or too little air or fuel
			src.stop_engine()
			src.visible_message("<span class='alert'>The [src] sputters for a moment and then stops, it failed to combust the reagents.</span>")
			return

		var/obj/cable/C = src.get_output_cable()
		if (!C)
			src.stop_engine()
			src.visible_message("<span class='alert'>Electricity begins to arc off the [src] causing it to shutdown, it has nothing to output to!</span>")
			elecflash(src.loc, 0, power = 3, exclude_center = 0)
			return

		src.last_mix = OPTIMAL_MIX / fuel_air_mix
		src.last_inlet = src.fuel_inlet + src.atmos_inlet
		var/oxygen_multiplier = clamp(src.last_oxygen * 5, 0, 3)

		src.last_output = src.last_fuel * src.last_mix * src.last_inlet * oxygen_multiplier * src.output_multiplier * mult

		var/turf/simulated/T = get_turf(src.loc)
		if (istype(T))
			var/datum/gas_mixture/payload = new /datum/gas_mixture
			payload.carbon_dioxide = CARBON_OUTPUT_RATE * src.last_mix * src.last_inlet * src.output_multiplier * mult
			payload.temperature = 323.15 // bit hotter since its exhaust
			T.assume_air(payload)

		if (src.check_tank_oxygen(src.inlet_tank))
			src.inlet_tank.remove_air(ATMOS_DRAIN_RATE * src.last_mix * src.last_inlet * src.output_multiplier * mult)
		else if (istype(T))
			T.remove_air(ATMOS_DRAIN_RATE * src.last_mix * src.last_inlet * mult)

		src.fuel_tank.reagents.remove_any(FUEL_DRAIN_RATE * src.last_mix * src.last_inlet * src.output_multiplier * mult) // TODO: adjustable fuel/air ratio

		src.UpdateIcon()
		src.updateDialog()

	proc/get_fuel_power(datum/reagents/R)
		if (!R || !R.total_volume)
			return

		var/average = 0
		for (var/reagent_id in R.reagent_list)
			var/datum/reagent/current_reagent = R.reagent_list[reagent_id]

			if (reagent_id in src.valid_fuels)
				average += src.valid_fuels[reagent_id] * current_reagent.volume

		if (!average)
			return FALSE

		return average / R.total_volume

	proc/start_engine()
		if (!src.active)
			if (!src.ready_to_start())
				return TRUE

			src.active = TRUE
			src.UpdateIcon()
			src.updateDialog()

			if (!ON_COOLDOWN(src, "tractor", 2 SECOND))
				playsound(src.loc, 'sound/machines/tractorrev.ogg', 40, pitch=2)

			return FALSE

	proc/stop_engine()
		if (src.active)
			src.active = FALSE
			src.UpdateIcon()
			src.updateDialog()

			if (!ON_COOLDOWN(src, "tractor", 2 SECOND))
				playsound(src.loc, 'sound/machines/tractorrev.ogg', 40, pitch=2)

			return FALSE

	proc/ready_to_start()
		if (!anchored || !src.fuel_tank)
			return FALSE

		if (!src.get_fuel_power(src.fuel_tank.reagents) || !src.check_available_oxygen())
			return FALSE

		return TRUE

	// Returns the concentration of oxygen in the available gas_mixture
	proc/check_available_oxygen()
		if (src.inlet_tank)
			return src.check_tank_oxygen(src.inlet_tank)

		var/turf/simulated/T = get_turf(src)
		if (!istype(T))
			return FALSE

		if (!T.air || T.air.oxygen <= 0)
			return FALSE

		return T.air.oxygen / TOTAL_MOLES(T.air)

	proc/check_tank_oxygen(obj/item/tank/T)
		if (!src || !T || !T.air_contents)
			return FALSE

		if (T.air_contents.oxygen <= 0)
			return FALSE

		return T.air_contents.oxygen / TOTAL_MOLES(T.air_contents)

	proc/get_output_cable()
		var/list/cables = src.get_connections()

		if (!length(cables) )
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
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)


	proc/eject_inlet_tank(var/mob/user)
		if (!src || !src.inlet_tank)
			return

		src.inlet_tank.set_loc(get_turf(src))
		if (istype(user))
			user.put_in_hand_or_eject(src.inlet_tank)

		src.inlet_tank = null

		src.UpdateIcon()
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

#undef FUEL_DRAIN_RATE
#undef ATMOS_DRAIN_RATE
#undef CARBON_OUTPUT_RATE
#undef OPTIMAL_MIX
#undef INLET_MAX
#undef INLET_MIN
