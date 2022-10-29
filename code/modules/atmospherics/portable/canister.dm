/obj/machinery/portable_atmospherics/canister
	name = "canister"
	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "empty"
	density = 1
	var/health = 100
	flags = FPRINT | CONDUCT | TGUI_INTERACTIVE
	object_flags = NO_GHOSTCRITTER | NO_GHOSTCRITTER
	p_class = 2
	status = REQ_PHYSICAL_ACCESS

	var/has_valve = 1
	var/valve_open = 0
	var/release_pressure = ONE_ATMOSPHERE

	var/casecolor = "empty"
	var/filled = 0.5
	pressure_resistance = 7*ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	desc = "A container which holds a large amount of the labelled gas. It's possible to transfer the gas to a pipe system, the air, or to a tank that you attach to it."
	var/overpressure = 0 // for canister explosions
	var/rupturing = 0
	var/obj/item/assembly/detonator/det = null
	var/overlay_state = null
	var/dialog_update_enabled = 1 //For preventing the DAMNABLE window taking focus when manually inputting pressure

	var/image/atmos_dmi
	var/image/bomb_dmi

	New()
		..()
		src.AddComponent(/datum/component/bullet_holes, 5, 0)
		atmos_dmi = image('icons/obj/atmospherics/atmos.dmi')
		bomb_dmi = image('icons/obj/canisterbomb.dmi')

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return FALSE
		if (src.release_pressure < 5*ONE_ATMOSPHERE || MIXTURE_PRESSURE(src.air_contents) < 5*ONE_ATMOSPHERE)
			boutput(user, "<span class='alert'>You hold your mouth to the release valve and open it. Nothing happens. You close the valve in shame.<br><i>Maybe if you used more pressure...?</i></span>")
			return FALSE
		user.visible_message("<span class='alert'><b>[user] holds [his_or_her(user)] mouth to [src]'s release valve and briefly opens it!</b></span>")
		src.valve_open = TRUE
		user.gib()
		return TRUE

	powered()
		return 1

/obj/machinery/portable_atmospherics/canister/sleeping_agent
	name = "Canister: \[N2O\]"
	icon_state = "redws"
	casecolor = "redws"
/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Canister: \[N2\]"
	icon_state = "red"
	casecolor = "red"
/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Canister: \[O2\]"
	icon_state = "blue"
	casecolor = "blue"
/obj/machinery/portable_atmospherics/canister/toxins
	name = "Canister \[Plasma\]"
	icon_state = "orange"
	casecolor = "orange"
/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Canister \[CO2\]"
	icon_state = "black"
	casecolor = "black"
/obj/machinery/portable_atmospherics/canister/air
	name = "Canister \[Air\]"
	icon_state = "grey"
	casecolor = "grey"
	filled = 2
/obj/machinery/portable_atmospherics/canister/air/large
	name = "High-Volume Canister \[Air\]"
	icon_state = "greyred"
	casecolor = "greyred"
	filled = 5
/obj/machinery/portable_atmospherics/canister/empty
	name = "Canister \[Empty\]"
	icon_state = "empty"
	casecolor = "empty"

/obj/machinery/portable_atmospherics/canister/update_icon()
	if (src.destroyed)
		src.icon_state = "[src.casecolor]-1"
		ClearAllOverlays()
	else
		icon_state = "[casecolor]"
		if (overlay_state)
			if (src.det && src.det.part_fs.timing && !src.det.safety && !src.det.defused)
				if (src.det.part_fs.time > 5 SECONDS)
					bomb_dmi.icon_state = "overlay_ticking"
					UpdateOverlays(bomb_dmi, "canbomb")
				else
					bomb_dmi.icon_state = "overlay_exploding"
					UpdateOverlays(bomb_dmi, "canbomb")
			else
				bomb_dmi.icon_state = overlay_state
				UpdateOverlays(bomb_dmi, "canbomb")
		else
			UpdateOverlays(null, "canbomb")

		if(holding)
			atmos_dmi.icon_state = "can-oT"
			UpdateOverlays(atmos_dmi, "holding")
		else
			UpdateOverlays(null, "holding")
		var/tank_pressure = MIXTURE_PRESSURE(air_contents)

		if (tank_pressure < 10)
			atmos_dmi.icon_state = "can-o0"
		else if (tank_pressure < ONE_ATMOSPHERE)
			atmos_dmi.icon_state = "can-o1"
		else if (tank_pressure < 15*ONE_ATMOSPHERE)
			atmos_dmi.icon_state = "can-o2"
		else
			atmos_dmi.icon_state = "can-o3"

		UpdateOverlays(atmos_dmi, "pressure")
	return

/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(reagents) reagents.temperature_reagents(exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		health -= 5
		if(src.material?.getProperty("flammable") > 3) //why would you make a canister out of wood/etc
			health -= 1000 //BURN
		healthcheck()

/obj/machinery/portable_atmospherics/canister/proc/healthcheck(mob/user)
	if(destroyed)
		return 1

	if (src.health <= 10)
		tgui_process.close_uis(src)
		if(src.air_contents.check_if_dangerous())
			message_admins("[src] [alert_atmos(src)] was destructively opened[user ? " by [key_name(user)]" : ""], emptying contents at [log_loc(src)].")
		logTheThing(LOG_STATION, null, "[src] [log_atmos(src)] was destructively opened[user ? " by [key_name(user)]" : ""], emptying contents at [log_loc(src)].")

		var/atom/location = src.loc
		location.assume_air(air_contents)
		air_contents = null

		if (src.det)
			processing_items.Remove(src.det)

		src.destroyed = 1
		playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
		src.set_density(0)
		UpdateIcon()

		if (src.holding)
			src.holding.set_loc(src.loc)
			src.holding = null
		return 1
	else
		return 1


/obj/machinery/portable_atmospherics/canister/process()
	if (!loc) return
	if (destroyed) return
	if (src.contained) return

	..()

	var/datum/gas_mixture/environment

	if(holding)
		environment = holding.air_contents
	else
		environment = loc.return_air()

	if (!environment)
		return

	var/env_pressure = MIXTURE_PRESSURE(environment)

	if(valve_open)
		var/pressure_delta = min(release_pressure - env_pressure, (MIXTURE_PRESSURE(air_contents) - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure

		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

			if(holding)
				environment.merge(removed)
			else
				loc.assume_air(removed)

	overpressure = MIXTURE_PRESSURE(air_contents) / maximum_pressure

	switch(overpressure) // should the canister blow the hell up?

		if(-INFINITY to 12)
			if(rupturing) rupturing = 0
		if(12 to 14)
			if(prob(4))
				src.visible_message("<span class='alert'>[src] hisses!</span>")
				playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
		if(14 to 16)
			if(prob(3) && !rupturing)
				rupture()
		if (16 to INFINITY)
			if (!rupturing)
				rupture()

	//Canister bomb grumpy sounds
	if (src.det && src.det.part_fs)
		if (src.det.part_fs.timing) //If it's counting down
			if (src.det.part_fs.time > 9 SECONDS)
				src.add_simple_light("canister", list(0.94 * 255, 0.94 * 255, 0.3 * 255, 0.6 * 255))
				if (prob(8)) //originally 5ish
					switch(rand(1,6))
						if (1)
							playsound(src.loc, "sparks", 75, 1, -1)
							elecflash(src)
						if (2)
							playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, 1)
						if (3)
							playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
						if (4)
							playsound(src.loc, 'sound/machines/bellalert.ogg', 50, 1)
						if (5)
							for (var/obj/machinery/power/apc/theAPC in get_area(src))
								theAPC.lighting = 0
								theAPC.UpdateIcon()
								theAPC.update()
								src.visible_message("<span class='alert'>The lights mysteriously go out!</span>")
						if (6)
							for (var/obj/machinery/power/apc/theAPC in get_area(src))
								theAPC.lighting = 3
								theAPC.UpdateIcon()
								theAPC.update()

			else if (src.det.part_fs.time < 10 SECONDS && src.det.part_fs.time > 7 SECONDS)  //EXPLOSION IMMINENT
				src.add_simple_light("canister", list(1 * 255, 0.03 * 255, 0.03 * 255, 0.6 * 255))
				src.visible_message("<span class='alert'>[src] flashes and sparks wildly!</span>")
				playsound(src.loc, 'sound/machines/siren_generalquarters.ogg', 50, 1)
				playsound(src.loc, "sparks", 75, 1, -1)
				elecflash(src,power = 2)
			else if (src.det.part_fs.time <= 3 SECONDS)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, 1)
		else //Someone might have defused it or the bomb failed
			src.remove_simple_light("canister")

	if(dialog_update_enabled) src.updateDialog()
	src.UpdateIcon()
	return

/obj/machinery/portable_atmospherics/canister/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/canister/blob_act(var/power)
	src.health -= power / 10
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/eject_tank()
	..()
	if(valve_open && !connected_port)
		toggle_valve() // auto closing valves from the future

/obj/machinery/portable_atmospherics/canister/proc/rupture() // cogwerks- high pressure tank explosions
	if (src.det)
		qdel(src.det) //Otherwise canister bombs detonate after rupture
		src.det = null
	if (!destroyed)
		rupturing = 1
		SPAWN(1 SECOND)
			src.visible_message("<span class='alert'>[src] hisses ominously!</span>")
			playsound(src.loc, 'sound/machines/hiss.ogg', 55, 1)
			sleep(5 SECONDS)
			playsound(src.loc, 'sound/machines/hiss.ogg', 60, 1)
			sleep(5 SECONDS)
			src.visible_message("<span class='alert'>[src] hisses loudly!</span>")
			playsound(src.loc, 'sound/machines/hiss.ogg', 65, 1)
			sleep(5 SECONDS)
			src.visible_message("<span class='alert'>[src] bulges!</span>")
			playsound(src.loc, 'sound/machines/hiss.ogg', 65, 1)
			sleep(5 SECONDS)
			src.visible_message("<span class='alert'>[src] cracks!</span>")
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 65, 1)
			playsound(src.loc, 'sound/machines/hiss.ogg', 65, 1)
			sleep(5 SECONDS)
			if(rupturing && !destroyed) // has anyone drained the tank?
				playsound(src.loc, "explosion", 70, 1)
				src.visible_message("<span class='alert'>[src] ruptures violently!</span>")
				src.health = 0
				src.disconnect()
				healthcheck()
				var/T = get_turf(src)

				for(var/obj/window/W in range(4, T)) // smash shit
					if(prob( GET_DIST(W,T)*6 ))
						continue
					W.health = 0
					W.smash()

				for(var/obj/displaycase/D in range(4,T))
					D.ex_act(1)

				for(var/obj/item/reagent_containers/glass/G in range(4,T))
					if(G.can_recycle)
						G.smash()

				for(var/obj/item/reagent_containers/food/drinks/drinkingglass/G in range(4,T))
					if(G.can_recycle)
						G.smash()

				for(var/atom/movable/A in view(3, T)) // wreck shit
					if(A.anchored) continue
					if(ismob(A))
						var/mob/M = A
						M.changeStatus("weakened", 8 SECONDS)
						random_brute_damage(M, 20)//armor won't save you from the pressure wave or something
						var/atom/targetTurf = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
						M.throw_at(targetTurf, 200, 4)
					else if (prob(50)) // cut down the number of things that get blown around
						var/atom/targetTurf = get_edge_target_turf(A, get_dir(src, get_step_away(A, src)))
						A.throw_at(targetTurf, 200, 4)

/obj/machinery/portable_atmospherics/canister/meteorhit(var/obj/O as obj)
	src.health = 0
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/attackby(var/obj/item/W, var/mob/user)
	if (istype(W, /obj/item/assembly/detonator)) //Wire: canister bomb stuff
		if (holding)
			user.show_message("<span class='alert'>You must remove the currently inserted tank from the slot first.</span>")
		else
			var/obj/item/assembly/detonator/Det = W
			if (Det.det_state != 4)
				user.show_message("<span class='alert'>The assembly is incomplete.</span>")
			else
				Det.set_loc(src)
				Det.master = src
				Det.layer = initial(W.layer)
				user.u_equip(Det)
				overlay_state = "overlay_safety_on"
				src.det = Det
				src.det.attachedTo = src
				src.det.builtBy = user
				logTheThing(LOG_BOMBING, user, "builds a canister bomb [log_atmos(src)] at [log_loc(src)].")
				if(src.air_contents.check_if_dangerous())
					message_admins("[key_name(user)] builds a canister bomb [alert_atmos(src)] at [log_loc(src)].")
				tgui_process.update_uis(src)
				src.UpdateIcon()
	else if (src.det && istype(W, /obj/item/tank))
		user.show_message("<span class='alert'>You cannot insert a tank, as the slot is shut closed by the detonator assembly.</span>")
		return
	else if (src.det && W && istool(W, TOOL_PULSING | TOOL_SNIPPING))
		src.Attackhand(user)

	else if(istype(W, /obj/item/atmosporter))
		var/obj/item/atmosporter/porter = W
		if (porter.contents.len >= porter.capacity) boutput(user, "<span class='alert'>Your [W] is full!</span>")
		else if (src.anchored) boutput(user, "<span class='alert'>\The [src] is attached!</span>")
		else
			user.visible_message("<span class='notice'>[user] collects the [src].</span>", "<span class='notice'>You collect the [src].</span>")
			src.contained = 1
			src.set_loc(W)
			elecflash(src)
	else if(!iswrenchingtool(W) && !istype(W, /obj/item/tank) && !istype(W, /obj/item/device/analyzer/atmospheric) && !istype(W, /obj/item/device/pda2))
		src.visible_message("<span class='alert'>[user] hits the [src] with a [W]!</span>")
		user.lastattacked = src
		attack_particle(user,src)
		hit_twitch(src)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		logTheThing(LOG_COMBAT, user, "attacked [src] [log_atmos(src)] with [W] at [log_loc(src)].")
		src.health -= W.force
		healthcheck(user)
	..()

/obj/machinery/portable_atmospherics/canister/attack_ai(var/mob/user as mob)
	if(!src.connected_port && GET_DIST(src, user) > 7)
		return
	return src.Attackhand(user)

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "GasCanister", name)
		ui.open()

/obj/machinery/portable_atmospherics/canister/ui_data(mob/user)
	. = list(
		"pressure" = MIXTURE_PRESSURE(src.air_contents),
		"maxPressure" = src.maximum_pressure,
		"connected" = src.connected_port ? TRUE : FALSE,
		"releasePressure" = src.release_pressure,
		"valveIsOpen" = src.valve_open,
		"hasValve" = src.has_valve ? TRUE : FALSE,
		"holding" = null, // need to explicitly tell the client it doesn't exist so it renders properly
		"detonator" = null,
	)

	if(src.holding)
		. += list(
			"holding" = list(
				"name" = src.holding.name,
				"pressure" = MIXTURE_PRESSURE(src.holding.air_contents),
				"maxPressure" = PORTABLE_ATMOS_MAX_RELEASE_PRESSURE,
			)
		)

	if(src.det)
		. += list(
			"detonator" = list(
				"wireNames" = src.det.WireNames,
				"wireStatus" = src.det.WireStatus,
				"safetyIsOn" = src.det.safety,
				"isAnchored" = src.anchored,
				"isPrimed" = src.det.part_fs.timing ? TRUE : FALSE,
				"time" = src.det.part_fs.time,
				"trigger" = src.det.trigger ? src.det.trigger.name : null,
			)
		)

/obj/machinery/portable_atmospherics/canister/ui_static_data(mob/user)
	. = list(
		"minRelease" = PORTABLE_ATMOS_MIN_RELEASE_PRESSURE,
		"maxRelease" = PORTABLE_ATMOS_MAX_RELEASE_PRESSURE,
	)
	if(src?.det?.attachments)
		var/list/attach_names = list()
		for(var/obj/item/I as anything in src.det.attachments)
			attach_names += I.name
		. += list("detonatorAttachments" = attach_names)

		var/has_paper = false
		for(var/obj/item/paper/sheet in src.det.attachments)
			. += list("paperData" = sheet.ui_static_data())
			has_paper = true
		. += list("hasPaper" = has_paper)

/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch(action)
		if("toggle-valve")
			. = toggle_valve()
		if("set-pressure")
			var/target_pressure = params["releasePressure"]
			if(isnum(target_pressure))
				. = set_release_pressure(target_pressure)
		if("eject-tank")
			eject_tank()
			. = TRUE
		if("anchor")
			if(!src.anchored)
				src.anchored = 1
				src.visible_message("<B><font color=#B7410E>A loud click is heard from the bottom of the canister, securing itself.</font></B>")
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
				. = TRUE
		if("safety")
			src.det.safety = 0
			src.overlay_state = "overlay_safety_off"
			. = TRUE
		if("prime")
			src.det.failsafe_engage()
			. = TRUE
		if("trigger")
			src.det.trigger.AttackSelf(usr)
			. = TRUE
		if("timer")
			if(!src.det.part_fs.timing)
				var/new_time = params["newTime"]
				if(isnum(new_time))
					src.det.part_fs.set_time(new_time)
					. = TRUE
		if("wire-interact")
			var/tool = null
			switch(params["toolAction"])
				if("cut")
					tool = TOOL_SNIPPING
				if("pulse")
					tool = TOOL_PULSING
			var/index = params["index"]
			var/mob/user = usr
			if(isnum(index) && tool && istype(user))
				src.det_wires_interact(tool, index+1, user)
				. = TRUE

/obj/machinery/portable_atmospherics/canister/attack_hand(var/mob/user)
	if (src.destroyed)
		return

	return ..()

/obj/machinery/portable_atmospherics/canister/proc/toggle_valve()
	if(!src.has_valve)
		return FALSE

	src.valve_open = !(src.valve_open)
	if (!src.holding && !src.connected_port)
		logTheThing(LOG_STATION, usr, "[valve_open ? "opened [src] into" : "closed [src] from"] the air [log_atmos(src)] at [log_loc(src)].")
		playsound(src.loc, 'sound/effects/valve_creak.ogg', 50, 1)
		if (src.valve_open)
			playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
			if(src.air_contents.check_if_dangerous())
				message_admins("[key_name(usr)] opened [src] into the air [alert_atmos(src)] at [log_loc(src)]")
			if (src.det)
				src.det.leaking()
	return TRUE

/obj/machinery/portable_atmospherics/canister/proc/set_release_pressure(var/pressure as num)
	if(!src.has_valve)
		return FALSE

	playsound(src.loc, 'sound/effects/valve_creak.ogg', 20, 1)
	src.release_pressure = clamp(pressure, PORTABLE_ATMOS_MIN_RELEASE_PRESSURE, PORTABLE_ATMOS_MAX_RELEASE_PRESSURE)
	return TRUE

/obj/machinery/portable_atmospherics/canister/proc/det_wires_interact(var/tool, var/which_wire as num, var/mob/user)
	if(!src.det || (which_wire <= 0 || which_wire > src.det.WireFunctions.len))
		return

	if(tool == TOOL_SNIPPING)
		if(!user.find_tool_in_hand(tool))
			user.show_message("<span class='alert'>You need to have a snipping tool equipped for this.</span>")
		else
			if(src.det.shocked)
				var/mob/living/carbon/human/H = user
				H.show_message("<span class='alert'>You tried to cut a wire on the bomb, but got burned by it.</span>")
				H.TakeDamage("chest", 0, 30)
				H.changeStatus("stunned", 15 SECONDS)
			else
				src.visible_message("<b><font color=#B7410E>[user.name] cuts the [src.det.WireNames[which_wire]] on the detonator.</font></b>")
				switch(src.det.WireFunctions[which_wire])
					if("detonate")
						playsound(src.loc, 'sound/machines/whistlealert.ogg', 50, 1)
						playsound(src.loc, 'sound/machines/whistlealert.ogg', 50, 1)
						src.visible_message("<B><font color=#B7410E>The failsafe timer beeps three times before going quiet forever.</font></B>")
						SPAWN(0)
							src.det.detonate()
					if("defuse")
						playsound(src.loc, 'sound/machines/ping.ogg', 50, 1)
						src.visible_message("<B><font color=#32CD32>The detonator assembly emits a sighing, fading beep. The bomb has been disarmed.</font></B>")
						src.det.defused = 1
					if("safety")
						if (!src.det.safety)
							src.visible_message("<B><font color=#B7410E>Nothing appears to happen.</font></B>")
						else
							playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
							src.visible_message("<B><font color=#B7410E>An unsettling click signals that the safety disengages.</font></B>")
							src.det.safety = 0
							src.det.failsafe_engage()
					if("losetime")
						src.det.failsafe_engage()
						playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
						if (src.det.part_fs.time > 7 SECONDS)
							src.det.part_fs.time -= 7 SECONDS
						else
							src.det.part_fs.time = 2 SECONDS
							src.visible_message("<B><font color=#B7410E>The failsafe beeps rapidly for two moments. The external display indicates that the timer has reduced to [src.det.part_fs.time SECONDS] seconds.</font></B>")
					if("mobility")
						src.det.failsafe_engage()
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if (anchored)
							src.visible_message("<B><font color=#B7410E>A faint click is heard from inside the canister, but the effect is not immediately apparent.</font></B>")
						else
							anchored = 1
							src.visible_message("<B><font color=#B7410E>A loud click is heard from the bottom of the canister, securing itself.</font></B>")
					if("leak")
						src.det.failsafe_engage()
						src.has_valve = 0
						src.valve_open = 1
						src.release_pressure = PORTABLE_ATMOS_MAX_RELEASE_PRESSURE
						src.visible_message("<B><font color=#B7410E>An electric buzz is heard before the release valve flies off the canister.</font></B>")
						playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
						src.det.leaking()
					else
						src.det.failsafe_engage()
						if (src.det.part_fs.timing)
							var/obj/item/attachment = src.det.WireFunctions[which_wire]
							attachment.detonator_act("cut", src.det)

				src.det.WireStatus[which_wire] = 0
	else if(tool == TOOL_PULSING)
		if (!user.find_tool_in_hand(TOOL_PULSING))
			user.show_message("<span class='alert'>You need to have a multitool or similar equipped for this.</span>")
		else
			if (src.det.shocked)
				var/mob/living/carbon/human/H = user
				H.show_message("<span class='alert'>You tried to pulse a wire on the bomb, but got burned by it.</span>")
				H.TakeDamage("chest", 0, 30)
				H.changeStatus("stunned", 15 SECONDS)
				H.UpdateDamageIcon()
			else
				src.visible_message("<b><font color=#B7410E>[user.name] pulses the [src.det.WireNames[which_wire]] on the detonator.</font></b>")
				switch (src.det.WireFunctions[which_wire])
					if ("detonate")
						if (src.det.part_fs.timing)
							playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 1)
							if (src.det.part_fs.time > 7 SECONDS)
								src.det.part_fs.time = 7 SECONDS
								src.visible_message("<B><font color=#B7410E>The failsafe timer buzzes loudly and sets itself to 7 seconds.</font></B>")
							else
								src.visible_message("<B><font color=#B7410E>The failsafe timer buzzes refusingly before going quiet forever.</font></B>")
								SPAWN(0)
									src.det.detonate()
						else
							src.det.failsafe_engage()
							src.det.part_fs.time = rand(8,14) SECONDS
							playsound(src.loc, 'sound/machines/pod_alarm.ogg', 50, 1)
							src.visible_message("<B><font color=#B7410E>The failsafe timer buzzes loudly and activates. You have [src.det.part_fs.time / 10] seconds to act.</font></B>")
					if ("defuse")
						src.det.failsafe_engage()
						if (src.det.grant)
							src.det.part_fs.time += 5 SECONDS
							playsound(src.loc, 'sound/machines/ping.ogg', 50, 1)
							src.visible_message("<B><font color=#B7410E>The detonator assembly emits a reassuring noise. You notice that the failsafe timer has increased to [src.det.part_fs.time / 10] seconds.</font></B>")
							src.det.grant = 0
						else
							playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 1)
							src.visible_message("<B><font color=#B7410E>The detonator assembly emits a sinister noise, but there are no apparent changes visible externally.</font></B>")
					if ("safety")
						playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
						if (!src.det.safety)
							src.visible_message("<B><font color=#B7410E>The display flashes with no apparent outside effect.</font></B>")
						else
							src.visible_message("<B><font color=#B7410E>An unsettling click signals that the safety disengages.</font></B>")
							src.det.safety = 0
					if ("losetime")
						src.det.failsafe_engage()
						src.det.shocked = 1
						var/losttime = rand(2,5) SECONDS
						src.visible_message("<B><font color=#B7410E>The bomb buzzes oddly, emitting electric sparks. It would be a bad idea to touch any wires for the next [losttime / 10] seconds.</font></B>")
						playsound(src.loc, "sparks", 75, 1, -1)
						elecflash(src,power = 2)
						SPAWN(losttime)
							src.det.shocked = 0
							src.visible_message("<B><font color=#B7410E>The buzzing stops, and the countdown continues.</font></B>")
					if ("mobility")
						src.det.failsafe_engage()
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if (anchored)
							anchored = 0
							src.visible_message("<B><font color=#B7410E>A loud click is heard from the inside the canister, unsecuring itself.</font></B>")
						else
							anchored = 1
							src.visible_message("<B><font color=#B7410E>A loud click is heard from the bottom of the canister, securing itself.</font></B>")
					if ("leak")
						src.det.failsafe_engage()
						playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
						if (prob(min(src.det.leaks * 8, 100)))
							has_valve = 0
							valve_open = 1
							release_pressure = PORTABLE_ATMOS_MAX_RELEASE_PRESSURE
							src.visible_message("<B><font color=#B7410E>An electric buzz is heard before the release valve flies off the canister.</font></B>")
						else
							valve_open = 1
							release_pressure = min(PORTABLE_ATMOS_MAX_RELEASE_PRESSURE, (src.det.leaks + 1) * ONE_ATMOSPHERE)
							src.visible_message("<B><font color=#B7410E>The release valve rumbles a bit, leaking some of the gas into the air.</font></B>")
						src.det.leaking()
						src.det.leaks++
					else
						src.det.failsafe_engage()
						if (src.det.part_fs.timing)
							var/obj/item/attachment = src.det.WireFunctions[which_wire]
							attachment.detonator_act("pulse", src.det)
		return

/obj/machinery/portable_atmospherics/canister/bullet_act(var/obj/projectile/P)
	var/damage = 0
	damage = round((P.power*P.proj_data.ks_ratio), 1.0)

	//if (src.det)
	//	src.det.detonate()
	//	return

	if(src.material) src.material.triggerOnBullet(src, src, P)

	if(P.proj_data.damage_type == D_KINETIC)
		src.health -= damage
	else if(P.proj_data.damage_type == D_PIERCING)
		src.health -= (damage * 2)
	else if(P.proj_data.damage_type == D_ENERGY)
		src.health -= damage
	log_shot(P,src)
	SPAWN( 0 )
		healthcheck()
		return
	return

/obj/machinery/portable_atmospherics/canister/toxins/New()

	..()

	src.air_contents.toxins = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.UpdateIcon()
	return 1

/obj/machinery/portable_atmospherics/canister/oxygen/New()

	..()

	src.air_contents.oxygen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.UpdateIcon()
	return 1

/obj/machinery/portable_atmospherics/canister/sleeping_agent/New()

	..()

	var/datum/gas/sleeping_agent/trace_gas = air_contents.get_or_add_trace_gas_by_type(/datum/gas/sleeping_agent)
	trace_gas.moles = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.UpdateIcon()
	return 1

/obj/machinery/portable_atmospherics/canister/nitrogen/New()

	..()

	src.air_contents.temperature = 80
	src.air_contents.nitrogen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.UpdateIcon()
	return 1

/obj/machinery/portable_atmospherics/canister/carbon_dioxide/New()

	..()
	src.air_contents.carbon_dioxide = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.UpdateIcon()
	return 1


/obj/machinery/portable_atmospherics/canister/air/New()

	..()
	src.air_contents.oxygen = (O2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	src.air_contents.nitrogen = (N2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.UpdateIcon()
	return 1
