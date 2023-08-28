/obj/machinery/atmospherics/unary/cryo_cell
	name = "cryogenic healing pod"
	desc = "A glass tube full of a strange fluid that uses supercooled oxygen and cryoxadone to rapidly heal patients."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "celltop-P"
	density = TRUE
	anchored = ANCHORED_ALWAYS
	layer = EFFECTS_LAYER_BASE//MOB_EFFECT_LAYER
	flags = NOSPLASH
	power_usage = 50
	var/on = FALSE //! Whether the cell is turned on or not
	var/datum/light/light
	var/ARCHIVED(temperature)
	var/mob/occupant = null //! Mob inside the tube being healed
	var/obj/item/beaker = null //! The beaker containing chems which are applied to the occupant. May or may not be present.
	var/show_beaker_contents = FALSE

	var/current_heat_capacity = 50
	var/pipe_direction //! Direction of the pipe leading into this, set in New() based on dir
	var/occupied_power_use = 500 //! Additional power usage when the pod is occupied (and on)

	var/reagent_scan_enabled = 0
	var/reagent_scan_active = 0
	var/obj/item/robodefibrillator/defib

	New()
		..()
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.6)
		light.set_height(1.5)
		light.set_color(0, 0.8, 0.5)
		build_icon()
		pipe_direction = src.dir
		initialize_directions = pipe_direction

	initialize()
		if(node) return
		var/node_connect = pipe_direction
		for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
			if(target.initialize_directions & get_dir(target,src))
				node = target
				break
		build_icon()

	disposing()
		if (src.occupant)
			src.go_out()
		for (var/mob/M in src)
			M.set_loc(src.loc)
		..()

	process()
		..()
		if(!node)
			return
		if(!on)
			tgui_process.update_uis(src)
			return

		if(src.occupant)
			if(!isdead(occupant))
				if (!ishuman(occupant))
					src.go_out() // stop turning into cyborgs thanks
				if (occupant.health < occupant.max_health || occupant.bioHolder.HasEffect("premature_clone"))
					use_power(occupied_power_use, EQUIP)
					process_occupant()
				else
					if(occupant.mind)
						src.go_out()
						playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)

		if(air_contents)
			ARCHIVED(temperature) = air_contents.temperature
			heat_gas_contents()
			expel_gas()

		if(abs(ARCHIVED(temperature)-air_contents.temperature) > 1)
			network.update = 1

		tgui_process.update_uis(src)
		return 1


	allow_drop()
		return 0

	MouseDrop_T(mob/living/target, mob/user)
		if (!istype(target) || isAI(user))
			return

		if (!can_reach(user, target) || !can_reach(user, src) || !can_act(user))
			return

		src.try_push_in(target, user)


	Exited(atom/movable/AM, atom/newloc)
		..()
		if (AM == occupant && newloc != src && newloc != get_turf(src)) // Don't need to do this if they exited normally
			src.go_out()

	relaymove(mob/user)
		if(!can_act(user, include_cuffs = FALSE))
			return
		src.go_out()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "CryoCell", name)
			ui.open()
		update_medical_record(src.occupant)

	ui_data(mob/user)
		. = list()

		.["occupant"] = get_occupant_data()
		.["cellTemp"] = air_contents.temperature
		.["status"] = src.on

		.["showBeakerContents"] = show_beaker_contents
		.["reagentScanEnabled"] = reagent_scan_enabled
		.["reagentScanActive"] = reagent_scan_active
		.["containerData"] = src.beaker ? get_reagents_data(src.beaker.reagents, src.beaker.name) : null

		.["hasDefib"] = src.defib

	ui_act(action, params)
		. = ..()
		if(.)
			return

		switch(action)
			if("start")
				src.on = !src.on
				build_icon()
			if("eject")
				beaker:set_loc(src.loc)
				usr.put_in_hand_or_eject(beaker) // try to eject it into the users hand, if we can
				beaker = null
			if("show_beaker_contents")
				show_beaker_contents = !show_beaker_contents
			if ("reagent_scan_active")
				reagent_scan_active = !reagent_scan_active
			if ("defib")
				if(!ON_COOLDOWN(src.defib, "defib_cooldown", 10 SECONDS))
					src.defib.setStatus("defib_charged", 3 SECONDS)
				src.defib.attack(src.occupant, usr)
			if ("eject_occupant")
				go_out()
			if ("insert")
				var/obj/item/I = usr.equipped()
				if(istype(I, /obj/item/reagent_containers/glass))
					insert_beaker(I, usr)
		. = TRUE


	ui_status(mob/user)
		if (user == src.occupant)
			return UI_UPDATE
		. = ..()
		if (!src.allowed(user))
			. = min(., UI_UPDATE)

	proc/get_occupant_data()
		if (!src.occupant)
			return null

		. = list(
			"occupied" = TRUE,
			"occupantStat" = src.occupant.stat,
			"health" = src.occupant.health / src.occupant.max_health,
			"oxyDamage" = src.occupant.get_oxygen_deprivation(),
			"toxDamage" = src.occupant.get_toxin_damage(),
			"burnDamage" = src.occupant.get_burn_damage(),
			"bruteDamage" = src.occupant.get_brute_damage()
		)
		if (isliving(src.occupant))
			var/mob/living/L = src.occupant
			var/mob/living/carbon/human/H = L

			var/death_state = L.stat
			if (L.bioHolder && L.bioHolder.HasEffect("dead_scan"))
				death_state = 2

			var/datum/statusEffect/simpledot/radiation/R = L.hasStatus("radiation")

			var/list/brain_damage = call(/obj/machinery/computer/operating/proc/calc_brain_damage_severity)(L)

			. += list(
				"patient_status" = death_state,
				"blood_pressure_rendered" = L.blood_pressure["rendered"],
				"blood_pressure_status" = L.blood_pressure["status"],

				"body_temp" = L.bodytemperature,
				"optimal_temp" = L.base_body_temp,
				"embedded_objects" = call(/obj/machinery/computer/operating/proc/check_embedded_objects)(L),

				"rad_stage" = R?.stage ? R.stage : 0,
				"rad_dose" = R?.stage ? L.radiation_dose : 0,

				"brain_damage" = list (
					"value" = L.get_brain_damage(),
					"desc" = brain_damage[1],
					"color" = brain_damage[2],
				),
			)

			if (reagent_scan_active)
				. += list(
					"blood_volume" = L.blood_pressure["total"],
					"reagents" = get_reagents_data(L.reagents, null)
				)

			if (istype(H))
				. += list("hasRoboticOrgans" = H.robotic_organs > 0)

	proc/get_reagents_data(var/datum/reagents/R, var/container_name)
		. = list(
			name = container_name,
			maxVolume = R.maximum_volume,
			totalVolume = R.total_volume,
			temperature = R.total_temperature,
			contents = list(),
			finalColor = "#000000"
		)

		var/list/contents = .["contents"]
		if(istype(R) && R.reagent_list.len>0)
			.["finalColor"] = R.get_average_rgb()
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

	attack_hand(var/mob/user)
		if(..())
			return
		ui_interact(user)

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, /obj/item/reagent_containers/glass))
			insert_beaker(I, user)
		else if(istype(I, /obj/item/grab))
			var/obj/item/grab/G = I
			if (try_push_in(G.affecting, user))
				qdel(G)
		else if (istype(I, /obj/item/reagent_containers/syringe))
			//this is in syringe.dm
			logTheThing(LOG_CHEMISTRY, user, "injects [log_reagents(I)] to [src] at [log_loc(src)].")
			if (!src.beaker)
				boutput(user, "<span class='alert'>There is no beaker in [src] for you to inject reagents.</span>")
				return
			if (src.beaker.reagents.total_volume == src.beaker.reagents.maximum_volume)
				boutput(user, "<span class='alert'>The beaker in [src] is full.</span>")
				return
			var/transferred = I.reagents.trans_to(src.beaker, 5)
			src.visible_message("<span class='alert'><B>[user] injects [transferred] into [src].</B></span>")
			src.beaker.on_reagent_change()
			return
		else if (istype(I, /obj/item/device/analyzer/healthanalyzer_upgrade))
			if (reagent_scan_enabled)
				boutput(user, "<span class='alert'>This Cryo Cell already has a reagent scan upgrade!</span>")
				return
			else
				reagent_scan_enabled = 1
				boutput(user, "<span class='notice'>Reagent scan upgrade installed.</span>")
				playsound(src.loc , 'sound/items/Deconstruct.ogg', 80, 0)
				user.u_equip(I)
				qdel(I)
				return
		else if (istype(I, /obj/item/robodefibrillator))
			if (src.defib)
				boutput(user, "<span class='alert'>[src] already has a Defibrillator installed.</span>")
			else
				if (I.cant_drop)
					boutput(user, "<span class='alert'>You can't put that in [src] while it's attached to you!")
					return
				src.defib = I
				boutput(user, "<span class='notice'>Defibrillator installed into [src].</span>")
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 80, 0)
				user.u_equip(I)
				I.set_loc(src)
				build_icon()
				src.UpdateIcon()
		else if (iswrenchingtool(I))
			if (!src.defib)
				boutput(user, "<span class='alert'>[src] does not have a Defibrillator installed.</span>")
			else
				src.defib.set_loc(src.loc)
				src.defib = null
				src.UpdateIcon()
				src.visible_message("<span class='alert'>[user] removes the Defibrillator from [src].</span>")
				playsound(src.loc , 'sound/items/Ratchet.ogg', 50, 1)
		else if (istype(I, /obj/item/device/analyzer/healthanalyzer))
			if (!occupant)
				boutput(user, "<span class='notice'>This Cryo Cell is empty!</span>")
				return
			else
				I.attack(src.occupant, user)

		tgui_process.update_uis(src)

	proc/insert_beaker(var/obj/item/reagent_containers/glass/I, var/mob/user)
		if (!can_act(user))
			return
		if (I.cant_drop)
			boutput(user, "<span class='alert'>You can't put that in \the [src] while it's attached to you!")
			return
		if(src.beaker)
			user.show_text("A beaker is already loaded into the machine.", "red")
			return

		src.beaker = I
		user.drop_item()
		I.set_loc(src)
		user.visible_message("[user] adds a beaker to \the [src]!", "You add a beaker to the [src]!")
		logTheThing(LOG_CHEMISTRY, user, "adds a beaker [log_reagents(I)] to [src] at [log_loc(src)].") // Rigging cryo is advertised in the 'Tip of the Day' list (Convair880).
		src.add_fingerprint(user)

	proc/shock_icon()
		var/fake_overlay = new /obj/shock_overlay(src.loc)
		src.vis_contents += fake_overlay
		SPAWN(1 SECOND)
			src.vis_contents -= fake_overlay
			qdel(fake_overlay)
			if(!src.defib)
				src.UpdateOverlays(null, "defib")
				return
			src.UpdateOverlays(src.SafeGetOverlayImage("defib", 'icons/obj/Cryogenic2.dmi', "defib-off", 2, pixel_y=-32), "defib")
		SPAWN(src.defib.charge_time)
			if(!src.defib)
				src.UpdateOverlays(null, "defib")
				return
			src.UpdateOverlays(src.SafeGetOverlayImage("defib", 'icons/obj/Cryogenic2.dmi', "defib-on", 2, pixel_y=-32), "defib")

	proc/build_icon()
		if(on)
			light.enable()
			icon_state = "celltop"
		else
			light.disable()
			icon_state = "celltop-p"
		if(src.node)
			src.UpdateOverlays(src.SafeGetOverlayImage("bottom", 'icons/obj/Cryogenic2.dmi', "cryo_bottom_[src.on]", 1, pixel_y=-32), "bottom")
		else
			src.UpdateOverlays(src.SafeGetOverlayImage("bottom", 'icons/obj/Cryogenic2.dmi', "cryo_bottom", 1, pixel_y=-32), "bottom")
		src.pixel_y = 32
		if(src.defib)
			src.UpdateOverlays(src.SafeGetOverlayImage("defib", 'icons/obj/Cryogenic2.dmi', "defib-on", 2, pixel_y=-32), "defib")
		else
			src.UpdateOverlays(null, "defib")

	proc/process_occupant()
		if(TOTAL_MOLES(air_contents) < 10)
			return
		if(ishuman(occupant))
			if(isdead(occupant))
				return
			occupant.bodytemperature += 50*(air_contents.temperature - occupant.bodytemperature)*current_heat_capacity/(current_heat_capacity + HEAT_CAPACITY(air_contents))
			occupant.bodytemperature = max(occupant.bodytemperature, air_contents.temperature) // this is so ugly i'm sorry for doing it i'll fix it later i promise
			occupant.changeStatus("burning", -10 SECONDS)
			var/mob/living/carbon/human/H = 0
			if (ishuman(occupant))
				H = occupant
			if (H && isalive(H)) H.lastgasp()
			//setunconcious(occupant)
			if(occupant.bodytemperature < T0C)
				if(air_contents.oxygen > 2)
					if(occupant.get_oxygen_deprivation())
						occupant.take_oxygen_deprivation(-10)
				else
					occupant.take_oxygen_deprivation(-2)
		else
			src.go_out()
			return
		if(beaker)
			beaker.reagents.trans_to(occupant, 0.1, 10)
			beaker.reagents.reaction(occupant, TOUCH, 5, paramslist = list("nopenetrate")) //1/10th of small beaker - matches old rate for default beakers, give or take

	proc/heat_gas_contents()
		if(TOTAL_MOLES(air_contents) < 1)
			return
		var/air_heat_capacity = HEAT_CAPACITY(air_contents)
		var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
		if(combined_heat_capacity > 0)
			var/combined_energy = T20C*current_heat_capacity + air_heat_capacity*air_contents.temperature
			air_contents.temperature = combined_energy/combined_heat_capacity

	proc/expel_gas()
		if(TOTAL_MOLES(air_contents) < 1)
			return
		var/datum/gas_mixture/expel_gas
		var/remove_amount = TOTAL_MOLES(air_contents)/100
		expel_gas = air_contents.remove(remove_amount)
		expel_gas.temperature = T20C // Lets expel hot gas and see if that helps people not die as they are removed
		loc.assume_air(expel_gas)

	verb/move_eject()
		set src in oview(1)
		set category = "Local"

		if (!can_act(usr))
			return
		src.go_out()
		add_fingerprint(usr)

	verb/move_inside()
		set src in oview(1)
		set category = "Local"

		src.try_push_in(usr, usr)

	/// Proc for entering a cryo tube. If a mob is shoving another mob in, `user` and `target` are different. If a mob is entering on its own, `user` and `target` are the same.
	proc/try_push_in(mob/target, mob/user)
		. = FALSE
		if (src.status & (NOPOWER|BROKEN))
			boutput(user, "<span class='alert'>\the [src] is broken.</span>")
			return
		if (!(can_act(user) && can_reach(user, src) && can_reach(user, target)))
			return
		if (!ishuman(target))
			boutput(user, "<span class='alert'>You can't seem to fit [target == user ? "yourself" : "[target]"] into \the [src].</span>")
			return
		if (src.occupant)
			user.show_text("The cryo tube is already occupied.", "red")
			return

		logTheThing(LOG_COMBAT, user, "shoves [user == target ? "themselves" : constructTarget(target,"combat")] into [src] containing [src.beaker ? log_reagents(src.beaker) : "(no beaker)"] at [log_loc(src)].")
		target.remove_pulling()
		src.occupant = target
		src.occupant.set_loc(src)
		for (var/obj/O in src)
			if (O == src.beaker || O == src.defib)
				continue
			O.set_loc(get_turf(src))
		src.add_fingerprint(user)

		// Visual stuff
		src.vis_contents += target
		src.occupant.vis_flags |= VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
		src.occupant.add_filter("cryo alpha mask", 20, alpha_mask_filter(icon = icon('icons/effects/64x64.dmi', "60-alpha-mask")))
		src.occupant.add_filter("cryo blur", 1, gauss_blur_filter(size = 0.8))
		src.occupant.pixel_y = -8 // top of the tube is 32px offset upwards
		animate(src.occupant, pixel_y = -16, time = 3 SECONDS, loop = -1, easing = SINE_EASING)
		animate(pixel_y = -8, time = 3 SECONDS, loop = -1, easing = SINE_EASING)
		src.occupant.force_laydown_standup()
		src.UpdateIcon()
		ui_interact(target)
		tgui_process.update_uis(src)
		return TRUE

	/// Proc to exit the cryo cell.
	proc/go_out()
		var/mob/living/exiter = src.occupant
		if (exiter)
			src.vis_contents -= exiter
			exiter.vis_flags &= ~(VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE)
			exiter.remove_filter("cryo alpha mask")
			exiter.remove_filter("cryo blur")
			exiter.pixel_y = 0
			animate(exiter)
		for (var/atom/movable/AM as anything in src)
			if (AM == src.beaker || AM == src.defib)
				continue
			AM.set_loc(get_turf(src))
		exiter?.force_laydown_standup()
		src.occupant = null
		src.UpdateIcon()
		tgui_process.update_uis(src)

/obj/shock_overlay
	icon = 'icons/obj/Cryogenic2.dmi'
	layer = 3
	icon_state = "defib-shock"
