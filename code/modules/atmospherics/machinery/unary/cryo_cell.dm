TYPEINFO(/obj/machinery/atmospherics/unary/cryo_cell)
	mats = list("cobryl" = 100,
				"crystal" = 50,
				"energy_high" = 20)
/obj/machinery/atmospherics/unary/cryo_cell
	name = "cryogenic healing pod"
	desc = "A glass tube full of a strange fluid that uses supercooled oxygen and cryoxadone to rapidly heal patients."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "celltop-P"
	density = TRUE
	anchored = ANCHORED_ALWAYS
	layer = EFFECTS_LAYER_BASE//MOB_EFFECT_LAYER
	flags = NOSPLASH
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_DESTRUCT
	power_usage = 50 WATTS
	var/on = FALSE //! Whether the cell is turned on or not
	var/datum/light/light
	var/ARCHIVED(temperature)
	var/mob/occupant = null //! Mob inside the tube being healed
	var/obj/item/beaker = null //! The beaker containing chems which are applied to the occupant. May or may not be present.
	var/show_beaker_contents = FALSE
	var/current_heat_capacity = 50
	var/occupied_power_use = 500 WATTS //! Additional power usage when the pod is occupied (and on)

	var/reagent_scan_enabled = FALSE
	var/reagent_scan_active = FALSE
	var/obj/item/robodefibrillator/defib

/obj/machinery/atmospherics/unary/cryo_cell/New()
	..()
	src.light = new /datum/light/point
	src.light.attach(src)
	src.light.set_brightness(0.6)
	src.light.set_height(1.5)
	src.light.set_color(0, 0.8, 0.5)
	src.build_icon()
	src.initialize_directions = src.dir

/obj/machinery/atmospherics/unary/cryo_cell/disposing()
	if (src.occupant)
		src.go_out()
	for (var/mob/M in src)
		M.set_loc(src.loc)
	..()

/obj/machinery/atmospherics/unary/cryo_cell/process()
	..()
	if(!src.node)
		return
	if(!src.on)
		tgui_process.update_uis(src)
		return

	if(src.occupant)
		if(!isdead(src.occupant))
			if (!ishuman(src.occupant))
				src.go_out() // stop turning into cyborgs thanks
			if (src.occupant.health < src.occupant.max_health || src.occupant.bioHolder.HasEffect("premature_clone"))
				src.use_power(src.occupied_power_use, EQUIP)
				src.process_occupant()
			else
				if(src.occupant.mind)
					src.go_out()
					playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)

	if(src.air_contents)
		src.ARCHIVED(temperature) = src.air_contents.temperature
		src.heat_gas_contents()
		src.expel_gas()

	if(abs(src.ARCHIVED(temperature)-src.air_contents.temperature) > 1 KELVIN)
		src.network.update = TRUE

	tgui_process.update_uis(src)
	return TRUE


/obj/machinery/atmospherics/unary/cryo_cell/allow_drop()
	return FALSE

/obj/machinery/atmospherics/unary/cryo_cell/MouseDrop_T(mob/living/target, mob/user)
	if (!istype(target) || isAI(user))
		return

	if (!can_reach(user, target) || !can_reach(user, src) || !can_act(user))
		return

	src.try_push_in(target, user)

/obj/machinery/atmospherics/unary/cryo_cell/Click(location, control, params)
	if(!ghost_observe_occupant(usr, src.occupant))
		. = ..()

/obj/machinery/atmospherics/unary/cryo_cell/Exited(atom/movable/AM, atom/newloc)
	..()
	if (AM == occupant && newloc != src && newloc != get_turf(src)) // Don't need to do this if they exited normally
		src.go_out()

/obj/machinery/atmospherics/unary/cryo_cell/relaymove(mob/user)
	if(!can_act(user, include_cuffs = FALSE))
		return
	src.go_out()

/obj/machinery/atmospherics/unary/cryo_cell/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CryoCell", name)
		ui.open()
	update_medical_record(src.occupant)

/obj/machinery/atmospherics/unary/cryo_cell/ui_data(mob/user)
	. = list()

	.["occupant"] = src.get_occupant_data()
	.["cellTemp"] = src.air_contents.temperature
	.["status"] = src.on

	.["showBeakerContents"] = src.show_beaker_contents
	.["reagentScanEnabled"] = src.reagent_scan_enabled
	.["reagentScanActive"] = src.reagent_scan_active
	.["containerData"] = src.beaker ? get_reagents_data(src.beaker.reagents, src.beaker.name) : null

	.["hasDefib"] = src.defib

/obj/machinery/atmospherics/unary/cryo_cell/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("start")
			src.on = !src.on
			src.build_icon()
		if("eject")
			src.beaker:set_loc(src.loc)
			usr.put_in_hand_or_eject(beaker) // try to eject it into the users hand, if we can
			src.beaker = null
		if("show_beaker_contents")
			src.show_beaker_contents = !src.show_beaker_contents
		if ("reagent_scan_active")
			src.reagent_scan_active = !src.reagent_scan_active
		if ("defib")
			var/area/A = get_area(src)
			if (!A.powered(EQUIP))
				boutput(usr, SPAN_ALERT("There's no local power to prime [src.defib]!"))
				return FALSE
			if(!ON_COOLDOWN(src.defib, "defib_cooldown", 10 SECONDS))
				src.defib.setStatus("defib_charged", 3 SECONDS)
			src.use_power(src.defib.cost)
			src.defib.attack(src.occupant, usr)
		if ("eject_occupant")
			src.go_out()
		if ("insert")
			var/obj/item/I = usr.equipped()
			if(istype(I, /obj/item/reagent_containers/glass))
				src.insert_beaker(I, usr)
	. = TRUE


/obj/machinery/atmospherics/unary/cryo_cell/ui_status(mob/user)
	if (user == src.occupant)
		return UI_UPDATE
	. = ..()
	if (!src.allowed(user))
		. = min(., UI_UPDATE)

/obj/machinery/atmospherics/unary/cryo_cell/proc/get_occupant_data()
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

/obj/machinery/atmospherics/unary/cryo_cell/proc/get_reagents_data(var/datum/reagents/R, var/container_name)
	. = list(
		name = container_name,
		maxVolume = R.maximum_volume,
		totalVolume = R.total_volume,
		temperature = R.total_temperature,
		contents = list(),
		finalColor = "#000000"
	)

	var/list/contents = .["contents"]
	if(istype(R) && length(R.reagent_list))
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

/obj/machinery/atmospherics/unary/cryo_cell/attack_hand(var/mob/user)
	if(..())
		return
	src.ui_interact(user)

/obj/machinery/atmospherics/unary/cryo_cell/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/reagent_containers/glass))
		src.insert_beaker(I, user)
	else if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if (try_push_in(G.affecting, user))
			qdel(G)
	else if (istype(I, /obj/item/reagent_containers/syringe))
		//this is in syringe.dm
		logTheThing(LOG_CHEMISTRY, user, "injects [log_reagents(I)] to [src] at [log_loc(src)].")
		if (!src.beaker)
			boutput(user, SPAN_ALERT("There is no beaker in [src] for you to inject reagents."))
			return
		if (src.beaker.reagents.total_volume == src.beaker.reagents.maximum_volume)
			boutput(user, SPAN_ALERT("The beaker in [src] is full."))
			return
		var/transferred = I.reagents.trans_to(src.beaker, 5)
		src.visible_message(SPAN_ALERT("<B>[user] injects [transferred] units into [src]'s beaker.</B>"))
		src.beaker.on_reagent_change()
		return
	else if (istype(I, /obj/item/device/analyzer/healthanalyzer_upgrade))
		if (src.reagent_scan_enabled)
			boutput(user, SPAN_ALERT("This Cryo Cell already has a reagent scan upgrade!"))
			return
		else
			src.reagent_scan_enabled = TRUE
			boutput(user, SPAN_NOTICE("Reagent scan upgrade installed."))
			playsound(src.loc , 'sound/items/Deconstruct.ogg', 80, 0)
			user.u_equip(I)
			qdel(I)
			return
	else if (istype(I, /obj/item/robodefibrillator))
		if (src.defib)
			boutput(user, SPAN_ALERT("[src] already has a defibrillator installed."))
		else
			if (I.cant_drop)
				boutput(user, SPAN_ALERT("You can't put that in [src] while it's attached to you!"))
				return
			var/obj/item/robodefibrillator/defibrillator = I
			if(!istype_exact(defibrillator, /obj/item/robodefibrillator))
				boutput(user, SPAN_ALERT("You can't install [defibrillator] into [src]!"))
				return
			src.defib = I
			boutput(user, SPAN_NOTICE("[defibrillator] installed into [src]."))
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 80, 0)
			user.u_equip(I)
			I.set_loc(src)
			src.build_icon()
			src.UpdateIcon()
	else if (iswrenchingtool(I))
		if (!src.defib)
			boutput(user, SPAN_ALERT("[src] does not have a defibrillator installed."))
		else
			src.defib.set_loc(src.loc)
			src.defib = null
			src.UpdateIcon()
			src.visible_message(SPAN_ALERT("[user] removes the defibrillator from [src]."))
			playsound(src.loc , 'sound/items/Ratchet.ogg', 50, 1)
			src.build_icon()
			src.UpdateIcon()
	else if (istype(I, /obj/item/device/analyzer/healthanalyzer))
		if (!src.occupant)
			boutput(user, SPAN_NOTICE("This Cryo Cell is empty!"))
			return
		else
			I.attack(src.occupant, user)

	tgui_process.update_uis(src)

/obj/machinery/atmospherics/unary/cryo_cell/was_built_from_frame(mob/user, newly_built)
	..()
	src.initialize_directions = src.dir
	src.initialize(TRUE)

/obj/machinery/atmospherics/unary/cryo_cell/proc/insert_beaker(var/obj/item/reagent_containers/glass/I, var/mob/user)
	if (!can_act(user))
		return
	if (I.cant_drop)
		boutput(user, SPAN_ALERT("You can't put that in \the [src] while it's attached to you!"))
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

/obj/machinery/atmospherics/unary/cryo_cell/proc/shock_icon()
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

/obj/machinery/atmospherics/unary/cryo_cell/proc/build_icon()
	if(src.on)
		src.light.enable()
		src.icon_state = "celltop"
	else
		src.light.disable()
		src.icon_state = "celltop-p"
	src.UpdateOverlays(src.SafeGetOverlayImage("bottom", 'icons/obj/Cryogenic2.dmi', "cryo_bottom_[src.on]", 1, pixel_y= -32), "bottom")
	src.UpdateOverlays(src.SafeGetOverlayImage("pipes", 'icons/obj/Cryogenic2.dmi', "cryo_pipes", 2, pixel_y = -32), "pipes")
	src.pixel_y = 32
	if(src.defib)
		src.UpdateOverlays(src.SafeGetOverlayImage("defib", 'icons/obj/Cryogenic2.dmi', "defib-on", 3, pixel_y=-32), "defib")
	else
		src.UpdateOverlays(null, "defib")

/obj/machinery/atmospherics/unary/cryo_cell/proc/process_occupant()
	if(TOTAL_MOLES(src.air_contents) < 10 MOLES)
		return
	if(ishuman(src.occupant))
		if(isdead(src.occupant))
			return
		src.occupant.bodytemperature += 50*(src.air_contents.temperature - src.occupant.bodytemperature)*src.current_heat_capacity/(src.current_heat_capacity + HEAT_CAPACITY(src.air_contents))
		src.occupant.bodytemperature = max(src.occupant.bodytemperature, src.air_contents.temperature) // this is so ugly i'm sorry for doing it i'll fix it later i promise
		src.occupant.changeStatus("burning", -10 SECONDS)
		var/mob/living/carbon/human/H = null
		if (ishuman(occupant))
			H = occupant
		if (H && isalive(H)) H.lastgasp(grunt = pick("GLUB", "blblbl", "BLUH", "BLURGH"))
		//setunconcious(occupant)
		if(src.occupant.bodytemperature < T0C)
			if(src.air_contents.oxygen > 2 MOLES)
				if(src.occupant.get_oxygen_deprivation())
					src.occupant.take_oxygen_deprivation(-10)
			else
				src.occupant.take_oxygen_deprivation(-2)
	else
		src.go_out()
		return
	if(src.beaker)
		src.beaker.reagents.trans_to(occupant, 0.1, 10)
		src.beaker.reagents.reaction(occupant, TOUCH, 5, paramslist = list("nopenetrate")) //1/10th of small beaker - matches old rate for default beakers, give or take

/// Slowly heats air_contents to 20C
/obj/machinery/atmospherics/unary/cryo_cell/proc/heat_gas_contents()
	if(TOTAL_MOLES(air_contents) < 1 MOLE)
		return
	var/air_heat_capacity = HEAT_CAPACITY(src.air_contents)
	var/combined_heat_capacity = src.current_heat_capacity + air_heat_capacity
	if(combined_heat_capacity > 0)
		var/combined_energy = T20C*src.current_heat_capacity + air_heat_capacity*src.air_contents.temperature
		src.air_contents.temperature = combined_energy/combined_heat_capacity

/// Leaks some gas out.
/obj/machinery/atmospherics/unary/cryo_cell/proc/expel_gas()
	if(TOTAL_MOLES(src.air_contents) < 1)
		return
	var/remove_amount = TOTAL_MOLES(src.air_contents)/100
	var/datum/gas_mixture/expel_gas = air_contents.remove(remove_amount)
	if (expel_gas.temperature < T20C)
		expel_gas.temperature = T20C // Lets expel hot gas and see if that helps people not die as they are removed
	loc.assume_air(expel_gas)

/obj/machinery/atmospherics/unary/cryo_cell/verb/move_eject()
	set src in oview(1)
	set category = "Local"

	if (!can_act(usr))
		return
	src.go_out()
	add_fingerprint(usr)

/obj/machinery/atmospherics/unary/cryo_cell/verb/move_inside()
	set src in oview(1)
	set category = "Local"

	src.try_push_in(usr, usr)

/// Proc for entering a cryo tube. If a mob is shoving another mob in, `user` and `target` are different. If a mob is entering on its own, `user` and `target` are the same.
/obj/machinery/atmospherics/unary/cryo_cell/proc/try_push_in(mob/target, mob/user)
	. = FALSE
	if (src.status & (NOPOWER|BROKEN))
		boutput(user, SPAN_ALERT("\the [src] is broken."))
		return
	if (!(can_act(user) && can_reach(user, src) && can_reach(user, target)))
		return
	if (!ishuman(target))
		boutput(user, SPAN_ALERT("You can't seem to fit [target == user ? "yourself" : "[target]"] into \the [src]."))
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
/obj/machinery/atmospherics/unary/cryo_cell/proc/go_out()
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
