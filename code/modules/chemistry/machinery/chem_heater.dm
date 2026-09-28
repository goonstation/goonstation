TYPEINFO(/obj/machinery/chem_heater)
	mats = 15

/obj/machinery/chem_heater
	name = "Reagent Heater/Cooler"
	desc = "A device used for the slow but precise heating and cooling of chemicals."
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/heater.dmi'
	icon_state = "heater"
	flags = NOSPLASH | TGUI_INTERACTIVE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	power_usage = 50
	processing_tier = PROCESSING_HALF
	var/obj/beaker = null
	var/active = 0
	var/target_temp = T0C
	var/output_target = null
	var/mob/roboworking = null
	// The chemistry APC was largely meaningless, so I made dispensers/heaters require a power supply (Convair880).

	New()
		..()
		output_target = src.loc

	attackby(var/obj/item/reagent_containers/glass/B, var/mob/user)
		if (!tryInsert(B, user))
			return ..()

	proc/tryInsert(obj/item/reagent_containers/glass/B, var/mob/user)
		if(!istypes(B, list(/obj/item/reagent_containers/glass, /obj/item/reagent_containers/food/drinks/cocktailshaker))) //container paths are so baaad
			return
		if (status & (NOPOWER|BROKEN))
			user.show_text("[src] seems to be out of order.", "red")
			return

		if (isrobot(user) && beaker && beaker == B)
			// If a cyborg is using this, and is trying to stick the same beaker into the heater again,
			// treat it like they just want to open the UI for QOL
			attack_ai(user)
			return

		if(src.beaker)
			boutput(user, "A beaker is already loaded into the machine.")
			return

		src.beaker =  B
		if (!isrobot(user))
			if(B.cant_drop)
				boutput(user, "You can't add the beaker to the machine!")
				src.beaker = null
				return
			else
				user.drop_item()
				B.set_loc(src)
		else
			roboworking = user
			SPAWN(1 SECOND)
				robot_disposal_check()

		if(src.beaker || roboworking)
			boutput(user, "You add the beaker to the machine!")
			src.ui_interact(user)
			. = TRUE
		src.UpdateIcon()

	handle_event(var/event, var/sender)
		if (event == "reagent_holder_update")
			src.UpdateIcon()
			tgui_process.update_uis(src)

	ex_act(severity)
		switch(severity)
			if(1)
				qdel(src)
				return
			if(2)
				if (prob(50))
					qdel(src)
					return
				if (prob(75))
					src.set_broken()
					return
			if(3)
				if (prob(50))
					src.set_broken()

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)
			return
		if (prob(25 * power/20))
			src.set_broken()

	bullet_act(obj/projectile/P)
		if(P.proj_data.damage_type & (D_KINETIC | D_PIERCING | D_SLASHING))
			if(prob(P.power * P.proj_data?.ks_ratio / 2))
				src.set_broken()
		..()

	overload_act()
		return !src.set_broken()

	meteorhit()
		qdel(src)
		return

	attack_ai(mob/user as mob)
		return src.Attackhand(user)


	ui_interact(mob/user, datum/tgui/ui)
		if (src.beaker)
			SEND_SIGNAL(src.beaker.reagents, COMSIG_REAGENTS_ANALYZED, user)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ChemHeater", src.name)
			ui.open()

	ui_data(mob/user)
		. = list()
		var/obj/item/reagent_containers/glass/container = src.beaker
		// Container data
		var/list/containerData
		if(container)
			var/datum/reagents/R = container.reagents
			containerData = list(
				name = container.name,
				maxVolume = R.maximum_volume,
				totalVolume = R.total_volume,
				temperature = R.total_temperature,
				contents = list(),
				finalColor = "#000000"
			)

			var/list/contents = containerData["contents"]
			if(istype(R) && R.reagent_list.len>0)
				containerData["finalColor"] = R.get_average_rgb()
				// Reagent data
				for(var/reagent_id in R.reagent_list)
					var/datum/reagent/current_reagent = R.reagent_list[reagent_id]

					contents.Add(list(list(
						name = reagents_cache[reagent_id],
						id = reagent_id,
						colorR = current_reagent.fluid_r,
						colorG = current_reagent.fluid_g,
						colorB = current_reagent.fluid_b,
						volume = current_reagent.volume
					)))
		.["containerData"] = containerData
		.["targetTemperature"] = src.target_temp
		.["isActive"] = src.active

	ui_act(action, params)
		. = ..()
		if(.)
			return
		var/obj/item/reagent_containers/glass/container = src.beaker
		switch(action)
			if("eject")
				if(!container)
					return
				if (src.roboworking)
					if (usr != src.roboworking)
						// If a cyborg is using this, other people can't eject the beaker.
						usr.show_text("You cannot eject the beaker because it is part of [roboworking].", "red")
						return
					src.roboworking = null
				else
					container.set_loc(src.output_target) // causes Exited proc to be called
					usr.put_in_hand_or_eject(container) // try to eject it into the users hand, if we can
				src.beaker = null
				src.UpdateIcon()
				return

			if("insert")
				if (container)
					return
				tryInsert(usr.equipped(), usr)
			if("adjustTemp")
				src.target_temp = clamp(params["temperature"], 0, 1000)
				src.UpdateIcon()
			if("start")
				if (!container?.reagents.total_volume)
					return
				src.active = 1
				src.UpdateIcon()
			if("stop")
				set_inactive()
		. = TRUE

	//MBC : moved to robot_disposal_check
	/*
	ProximityLeave(atom/movable/AM as mob|obj)
		if (roboworking && AM == roboworking && BOUNDS_DIST(src, AM) > 0)
			// Cyborg is leaving (or getting pushed away); remove its beaker
			roboworking = null
			beaker = null
			set_inactive()
			// If the heater was working, the next iteration of active() will turn it off and fix power usage
		return ..(AM)
	*/

	process(mult)
		if (status & BROKEN)
			var/turf/simulated/T = src.loc
			if (istype(T))
				var/datum/gas_mixture/environment = T.return_air()

				// less efficient than an HVAC so people don't abuse these for changing air temps
				var/transfer_moles = 0.1 * TOTAL_MOLES(environment)
				var/datum/gas_mixture/removed = environment.remove(transfer_moles)
				if (removed && TOTAL_MOLES(removed) > 0)
					var/heat_capacity = HEAT_CAPACITY(removed)
					removed.temperature = (removed.temperature * heat_capacity + 200 * (src.target_temp-T20C))/heat_capacity
					use_power(2000 WATTS) // early return below stops normal power usage check
				T.assume_air(removed)

		if (!active) return
		if (status & (NOPOWER|BROKEN) || !beaker || !beaker.reagents.total_volume)
			set_inactive()
			return

		var/datum/reagents/R = beaker:reagents
		R.temperature_reagents(target_temp, exposed_volume = (400 + R.total_volume * 5) * mult, change_cap = 100) //it uses juice in if the beaker is filled more. Or something.

		src.power_usage = 2000 + R.total_volume * 25

		if(abs(R.total_temperature - target_temp) <= 3)
			active = 0

		tgui_process.update_uis(src)
		..()

	proc/robot_disposal_check()
		// Without this, the heater might occasionally show that a beaker is still inserted
		// when it in fact isn't. That should only happen when
		//  - a cyborg was using the machine, and
		//  - the cyborg lost its chest with the beaker still inserted, and
		//  - the heater was inactive at the time of death.
		// Since we don't get any callbacks in this case - the borg leaves the tile by
		// way of qdel, so there's no ProximityLeave notification - the only way to update
		// the icon promptly is to run a periodic check when a borg has its beaker inserted
		// into the heater, regardless of whether the heater is active or not.
		// MBC note : also moved distance check here
		if (!roboworking)
			// This proc is only called when a robot was at one point using the heater, so if
			// roboworking is unset then it must have been deleted
			set_inactive()
		else if (BOUNDS_DIST(src, roboworking) > 0)
			roboworking = null
			beaker = null
			set_inactive()
		else
			SPAWN(1 SECOND)
				robot_disposal_check()

	proc/set_inactive()
		power_usage = 50
		active = 0
		UpdateIcon()
		tgui_process.update_uis(src)

	power_change()
		. = ..()
		src.update_icon()

	update_icon()
		if (src.status & BROKEN)
			src.UpdateOverlays(null, "beaker", retain_cache=TRUE)
			src.icon_state = "heater-broken"
			return

		if (!src.beaker)
			src.UpdateOverlays(null, "beaker", retain_cache=TRUE)
			src.icon_state = "heater"
			return

		src.UpdateOverlays(SafeGetOverlayImage("beaker", 'icons/obj/heater.dmi', "heater-beaker"), "beaker")
		if (src.active && src.beaker:reagents && src.beaker:reagents:total_volume)
			if (target_temp > src.beaker:reagents:total_temperature)
				src.icon_state = "heater-heat"
			else if (target_temp < src.beaker:reagents:total_temperature)
				src.icon_state = "heater-cool"
			else
				src.icon_state = "heater-closed"
		else
			src.icon_state = "heater-closed"

	mouse_drop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, SPAN_ALERT("Only living mobs are able to set the Reagent Heater/Cooler's output target."))
			return

		if(BOUNDS_DIST(over_object, src) > 0)
			boutput(usr, SPAN_ALERT("The Reagent Heater/Cooler is too far away from the target!"))
			return

		if(BOUNDS_DIST(over_object, usr) > 0)
			boutput(usr, SPAN_ALERT("You are too far away from the target!"))
			return

		else if (istype(over_object,/turf/simulated/floor/))
			src.output_target = over_object
			boutput(usr, SPAN_NOTICE("You set the Reagent Heater/Cooler to output to [over_object]!"))

		else
			boutput(usr, SPAN_ALERT("You can't use that as an output target."))
		return

	set_broken()
		. = ..()
		if (.) return
		if(src.target_temp > T20C)
			AddComponent(/datum/component/equipment_fault/embers, tool_flags = TOOL_WRENCHING | TOOL_SCREWING | TOOL_PRYING)
		else
			AddComponent(/datum/component/equipment_fault/smoke, tool_flags = TOOL_WRENCHING | TOOL_SCREWING | TOOL_PRYING)
		animate_shake(src, 5, rand(3,8),rand(3,8))
		playsound(src, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1)

	Exited(Obj, newloc)
		if(Obj == src.beaker)
			src.beaker = null
			src.UpdateIcon()
			tgui_process.update_uis(src)

	chemistry
		icon = 'icons/obj/heater_chem.dmi'
