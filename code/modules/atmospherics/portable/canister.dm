/obj/machinery/portable_atmospherics/canister
	name = "canister"
	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "empty"
	density = 1
	var/health = 100.0
	flags = FPRINT | CONDUCT | TGUI_INTERACTIVE
	p_class = 2

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

	var/global/image/atmos_dmi = image('icons/obj/atmospherics/atmos.dmi')
	var/global/image/bomb_dmi = image('icons/obj/canisterbomb.dmi')

	onMaterialChanged()
		..()
		if(istype(src.material))
			temperature_resistance = 400 + T0C + (((src.material.getProperty("flammable") - 50) * (-1)) * 3)
		return

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (src.release_pressure < 5*ONE_ATMOSPHERE || MIXTURE_PRESSURE(src.air_contents) < 5*ONE_ATMOSPHERE)
			return 0
		user.visible_message("<span class='alert'><b>[user] holds [his_or_her(user)] mouth to [src]'s release valve and briefly opens it!</b></span>")
		user.gib()
		return 1

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
	filled = 2.0
/obj/machinery/portable_atmospherics/canister/air/large
	name = "High-Volume Canister \[Air\]"
	icon_state = "greyred"
	casecolor = "greyred"
	filled = 5.0
/obj/machinery/portable_atmospherics/canister/empty
	name = "Canister \[Empty\]"
	icon_state = "empty"
	casecolor = "empty"

/obj/machinery/portable_atmospherics/canister/New()
	..()

/obj/machinery/portable_atmospherics/canister/update_icon()

	if (src.destroyed)
		src.icon_state = "[src.casecolor]-1"
		ClearAllOverlays()
	else
		icon_state = "[casecolor]"
		if (overlay_state)
			if (src.det && src.det.part_fs.timing && !src.det.safety && !src.det.defused)
				if (src.det.part_fs.time > 5)
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
		healthcheck()

/obj/machinery/portable_atmospherics/canister/proc/healthcheck()
	if(destroyed)
		return 1

	if (src.health <= 10)
		tgui_process.close_uis(src)
		message_admins("[src] was destructively opened, emptying contents at [log_loc(src)]. See station logs for atmos readout.")
		logTheThing("station", null, null, "[src] [log_atmos(src)] was destructively opened, emptying contents at [log_loc(src)].")

		var/atom/location = src.loc
		location.assume_air(air_contents)
		air_contents = null

		if (src.det)
			processing_items.Remove(src.det)

		src.destroyed = 1
		playsound(src.loc, "sound/effects/spray.ogg", 10, 1, -3)
		src.set_density(0)
		update_icon()

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
				playsound(src.loc, "sound/machines/hiss.ogg", 50, 1)
		if(14 to 16)
			if(prob(3) && !rupturing)
				rupture()
		if (16 to INFINITY)
			if (!rupturing)
				rupture()

	//Canister bomb grumpy sounds
	if (src.det && src.det.part_fs)
		if (src.det.part_fs.timing) //If it's counting down
			if (src.det.part_fs.time > 9)
				src.add_simple_light("canister", list(0.94 * 255, 0.94 * 255, 0.3 * 255, 0.6 * 255))
				if (prob(15))
					switch(rand(1,10))
						if (1)
							playsound(src.loc, "sparks", 75, 1, -1)
							elecflash(src)
						if (2)
							playsound(src.loc, "sound/machines/warning-buzzer.ogg", 50, 1)
						if (3)
							playsound(src.loc, "sound/machines/hiss.ogg", 50, 1)
						if (4)
							playsound(src.loc, "sound/machines/bellalert.ogg", 50, 1)
						if (5)
							for (var/obj/machinery/power/apc/theAPC in get_area(src))
								theAPC.lighting = 0
								theAPC.updateicon()
								theAPC.update()
								src.visible_message("<span class='alert'>The lights mysteriously go out!</span>")
						if (6)
							for (var/obj/machinery/power/apc/theAPC in get_area(src))
								theAPC.lighting = 3
								theAPC.updateicon()
								theAPC.update()

			else if (src.det.part_fs.time < 10 && src.det.part_fs.time > 7)  //EXPLOSION IMMINENT
				src.add_simple_light("canister", list(1 * 255, 0.03 * 255, 0.03 * 255, 0.6 * 255))
				src.visible_message("<span class='alert'>[src] flashes and sparks wildly!</span>")
				playsound(src.loc, "sound/machines/siren_generalquarters.ogg", 50, 1)
				playsound(src.loc, "sparks", 75, 1, -1)
				elecflash(src,power = 2)
			else if (src.det.part_fs.time <= 3)
				playsound(src.loc, "sound/machines/warning-buzzer.ogg", 50, 1)
		else //Someone might have defused it or the bomb failed
			src.remove_simple_light("canister")

	if(dialog_update_enabled) src.updateDialog()
	src.update_icon()
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
		del(src.det) //Otherwise canister bombs detonate after rupture
	if (!destroyed)
		rupturing = 1
		SPAWN_DBG(1 SECOND)
			src.visible_message("<span class='alert'>[src] hisses ominously!</span>")
			playsound(src.loc, "sound/machines/hiss.ogg", 55, 1)
			sleep(5 SECONDS)
			playsound(src.loc, "sound/machines/hiss.ogg", 60, 1)
			sleep(5 SECONDS)
			src.visible_message("<span class='alert'>[src] hisses loudly!</span>")
			playsound(src.loc, "sound/machines/hiss.ogg", 65, 1)
			sleep(5 SECONDS)
			src.visible_message("<span class='alert'>[src] bulges!</span>")
			playsound(src.loc, "sound/machines/hiss.ogg", 65, 1)
			sleep(5 SECONDS)
			src.visible_message("<span class='alert'>[src] cracks!</span>")
			playsound(src.loc, "sound/impact_sounds/Metal_Hit_Heavy_1.ogg", 65, 1)
			playsound(src.loc, "sound/machines/hiss.ogg", 65, 1)
			sleep(5 SECONDS)
			if(rupturing && !destroyed) // has anyone drained the tank?
				playsound(src.loc, "explosion", 70, 1)
				src.visible_message("<span class='alert'>[src] ruptures violently!</span>")
				src.health = 0
				src.disconnect()
				healthcheck()
				var/T = get_turf(src)

				for(var/obj/window/W in range(4, T)) // smash shit
					if(prob( get_dist(W,T)*6 ))
						continue
					W.health = 0
					W.smash()

				for(var/obj/displaycase/D in range(4,T))
					D.ex_act(1)

				for(var/obj/item/reagent_containers/glass/G in range(4,T))
					G.smash()

				for(var/obj/item/reagent_containers/food/drinks/drinkingglass/G in range(4,T))
					G.smash()

				for(var/atom/movable/A in view(3, T)) // wreck shit
					if(A.anchored) continue
					if(ismob(A))
						var/mob/M = A
						M.changeStatus("weakened", 80)
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

/obj/machinery/portable_atmospherics/canister/attackby(var/obj/item/W as obj, var/mob/user as mob)
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
				src.det.builtBy = usr
				logTheThing("bombing", user, null, "builds a canister bomb [log_atmos(src)] at [log_loc(src)].")
				message_admins("[key_name(user)] builds a canister bomb at [log_loc(src)]. See bombing logs for atmos readout.")
				tgui_process.update_uis(src)
				src.update_icon()
	else if (src.det && istype(W, /obj/item/tank))
		user.show_message("<span class='alert'>You cannot insert a tank, as the slot is shut closed by the detonator assembly.</span>")
		return
	else if (src.det && W && istool(W, TOOL_PULSING | TOOL_SNIPPING))
		src.attack_hand(user)

	else if (istype(W, /obj/item/cargotele))
		W:cargoteleport(src, user)
		return
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
		logTheThing("combat", user, null, "attacked [src] [log_atmos(src)] with [W] at [log_loc(src)].")
		src.health -= W.force
		healthcheck()
	..()

/obj/machinery/portable_atmospherics/canister/attack_ai(var/mob/user as mob)
	if(!src.connected_port && get_dist(src, user) > 7)
		return
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "GasCanister", name)
		ui.open()

/obj/machinery/portable_atmospherics/canister/ui_data(mob/user)
	var/list/data = list()
	data["pressure"] = MIXTURE_PRESSURE(src.air_contents)
	data["maxPressure"] = src.maximum_pressure
	data["connected"] = src.connected_port ? TRUE : FALSE
	data["releasePressure"] = src.release_pressure
	data["minRelease"] = PORTABLE_ATMOS_MIN_RELEASE_PRESSURE
	data["maxRelease"] = PORTABLE_ATMOS_MAX_RELEASE_PRESSURE
	data["valveIsOpen"] = src.valve_open
	data["hasValve"] = src.has_valve ? TRUE : FALSE

	data["holding"] = null // need to explicitly tell the client it doesn't exist so it renders properly
	if(src.holding)
		data["holding"] = list()
		data["holding"]["name"] = src.holding.name
		data["holding"]["pressure"] = MIXTURE_PRESSURE(src.holding.air_contents)
		data["holding"]["maxPressure"] = PORTABLE_ATMOS_MAX_RELEASE_PRESSURE

	data["detonator"] = null
	if(src.det)
		data["detonator"] = list()
		data["detonator"]["wireNames"] = src.det.WireNames
		data["detonator"]["wireStatus"] = src.det.WireStatus
		data["detonator"]["safetyIsOn"] = src.det.safety
		data["detonator"]["isAnchored"] = src.anchored
		data["detonator"]["isPrimed"] = src.det.part_fs.timing ? TRUE : FALSE
		data["detonator"]["time"] = src.det.part_fs.time * 10 // using tenths of a second on the client

		data["detonator"]["trigger"] = null
		if(src.det.trigger)
			data["detonator"]["trigger"] = src.det.trigger.name

	return data

/obj/machinery/portable_atmospherics/canister/ui_static_data(mob/user)
	var/list/static_data = list()

	if(src?.det?.attachments)
		static_data["detonatorAttachments"] = list()
		for(var/obj/item/I in src.det.attachments)
			static_data["detonatorAttachments"] += I.name

	return static_data

/obj/machinery/portable_atmospherics/canister/ui_state(mob/user)
	return tgui_physical_state

/obj/machinery/portable_atmospherics/canister/ui_status(mob/user)
  return min(
		tgui_physical_state.can_use_topic(src, user),
		tgui_not_incapacitated_state.can_use_topic(src, user)
	)

/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	if(..())
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
				playsound(src.loc, "sound/machines/click.ogg", 50, 1)
				. = TRUE
		if("safety")
			src.det.safety = 0
			src.overlay_state = "overlay_safety_off"
			. = TRUE
		if("prime")
			src.det.failsafe_engage()
			. = TRUE
		if("trigger")
			src.det.trigger.attack_self(usr)
			. = TRUE
		if("timer")
			if(!src.det.part_fs.timing)
				var/new_time = params["newTime"]
				if(isnum(new_time))
					src.det.part_fs.set_time(new_time/10)
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

/obj/machinery/portable_atmospherics/canister/attack_hand(var/mob/user as mob)
	if (src.destroyed)
		return

	return ..()

/obj/machinery/portable_atmospherics/canister/proc/toggle_valve()
	if(!src.has_valve)
		return FALSE

	src.valve_open = !(src.valve_open)
	if (!src.holding && !src.connected_port)
		logTheThing("station", usr, null, "[valve_open ? "opened [src] into" : "closed [src] from"] the air [log_atmos(src)] at [log_loc(src)].")
		playsound(src.loc, "sound/effects/valve_creak.ogg", 50, 1)
		if (src.valve_open)
			playsound(src.loc, "sound/machines/hiss.ogg", 50, 1)
			message_admins("[key_name(usr)] opened [src] into the air at [log_loc(src)]. See station logs for atmos readout.")
			if (src.det)
				src.det.leaking()
	return TRUE

/obj/machinery/portable_atmospherics/canister/proc/set_release_pressure(var/pressure as num)
	if(!src.has_valve)
		return FALSE

	playsound(src.loc, "sound/effects/valve_creak.ogg", 20, 1)
	src.release_pressure = clamp(pressure, PORTABLE_ATMOS_MIN_RELEASE_PRESSURE, PORTABLE_ATMOS_MAX_RELEASE_PRESSURE)
	return TRUE

/obj/machinery/portable_atmospherics/canister/proc/det_wires_interact(var/tool, var/which_wire as num, var/mob/user)
	if(!src.det || (which_wire <= 0 || which_wire > src.det.WireFunctions.len))
		return

	if(tool == TOOL_SNIPPING)
		if(!user.find_tool_in_hand(tool))
			usr.show_message("<span class='alert'>You need to have a snipping tool equipped for this.</span>")
		else
			if(src.det.shocked)
				var/mob/living/carbon/human/H = user
				H.show_message("<span class='alert'>You tried to cut a wire on the bomb, but got burned by it.</span>")
				H.TakeDamage("chest", 0, 30)
				H.changeStatus("stunned", 150)
			else
				src.visible_message("<b><font color=#B7410E>[user.name] cuts the [src.det.WireNames[which_wire]] on the detonator.</font></b>")
				switch(src.det.WireFunctions[which_wire])
					if("detonate")
						playsound(src.loc, "sound/machines/whistlealert.ogg", 50, 1)
						playsound(src.loc, "sound/machines/whistlealert.ogg", 50, 1)
						src.visible_message("<B><font color=#B7410E>The failsafe timer beeps three times before going quiet forever.</font></B>")
						SPAWN_DBG(0)
							src.det.detonate()
					if("defuse")
						playsound(src.loc, "sound/machines/ping.ogg", 50, 1)
						src.visible_message("<B><font color=#32CD32>The detonator assembly emits a sighing, fading beep. The bomb has been disarmed.</font></B>")
						src.det.defused = 1
					if("safety")
						if (!src.det.safety)
							src.visible_message("<B><font color=#B7410E>Nothing appears to happen.</font></B>")
						else
							playsound(src.loc, "sound/machines/click.ogg", 50, 1)
							src.visible_message("<B><font color=#B7410E>An unsettling click signals that the safety disengages.</font></B>")
							src.det.safety = 0
							src.det.failsafe_engage()
					if("losetime")
						src.det.failsafe_engage()
						playsound(src.loc, "sound/machines/twobeep.ogg", 50, 1)
						if (src.det.part_fs.time > 7)
							src.det.part_fs.time -= 7
						else
							src.det.part_fs.time = 2
							src.visible_message("<B><font color=#B7410E>The failsafe beeps rapidly for two moments. The external display indicates that the timer has reduced to [src.det.part_fs.time] seconds.</font></B>")
					if("mobility")
						src.det.failsafe_engage()
						playsound(src.loc, "sound/machines/click.ogg", 50, 1)
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
						playsound(src.loc, "sound/machines/hiss.ogg", 50, 1)
						src.det.leaking()
					else
						src.det.failsafe_engage()
						if (src.det.part_fs.timing)
							var/obj/item/attachment = src.det.WireFunctions[which_wire]
							attachment.detonator_act("cut", src.det)

				src.det.WireStatus[which_wire] = 0
	else if(tool == TOOL_PULSING)
		if (!usr.find_tool_in_hand(TOOL_PULSING))
			usr.show_message("<span class='alert'>You need to have a multitool or similar equipped for this.</span>")
		else
			if (src.det.shocked)
				var/mob/living/carbon/human/H = usr
				H.show_message("<span class='alert'>You tried to pulse a wire on the bomb, but got burned by it.</span>")
				H.TakeDamage("chest", 0, 30)
				H.changeStatus("stunned", 150)
				H.UpdateDamageIcon()
			else
				src.visible_message("<b><font color=#B7410E>[usr.name] pulses the [src.det.WireNames[which_wire]] on the detonator.</font></b>")
				switch (src.det.WireFunctions[which_wire])
					if ("detonate")
						if (src.det.part_fs.timing)
							playsound(src.loc, "sound/machines/buzz-sigh.ogg", 50, 1)
							if (src.det.part_fs.time > 7)
								src.det.part_fs.time = 7
								src.visible_message("<B><font color=#B7410E>The failsafe timer buzzes loudly and sets itself to 7 seconds.</font></B>")
							else
								src.visible_message("<B><font color=#B7410E>The failsafe timer buzzes refusingly before going quiet forever.</font></B>")
								SPAWN_DBG(0)
									src.det.detonate()
						else
							src.det.failsafe_engage()
							src.det.part_fs.time = rand(8,14)
							playsound(src.loc, "sound/machines/pod_alarm.ogg", 50, 1)
							src.visible_message("<B><font color=#B7410E>The failsafe timer buzzes loudly and activates. You have [src.det.part_fs.time] seconds to act.</font></B>")
					if ("defuse")
						src.det.failsafe_engage()
						if (src.det.grant)
							src.det.part_fs.time += 5
							playsound(src.loc, "sound/machines/ping.ogg", 50, 1)
							src.visible_message("<B><font color=#B7410E>The detonator assembly emits a reassuring noise. You notice that the failsafe timer has increased to [src.det.part_fs.time] seconds.</font></B>")
							src.det.grant = 0
						else
							playsound(src.loc, "sound/machines/buzz-two.ogg", 50, 1)
							src.visible_message("<B><font color=#B7410E>The detonator assembly emits a sinister noise, but there are no apparent changes visible externally.</font></B>")
					if ("safety")
						playsound(src.loc, "sound/machines/twobeep.ogg", 50, 1)
						if (!src.det.safety)
							src.visible_message("<B><font color=#B7410E>The display flashes with no apparent outside effect.</font></B>")
						else
							src.visible_message("<B><font color=#B7410E>An unsettling click signals that the safety disengages.</font></B>")
							src.det.safety = 0
					if ("losetime")
						src.det.failsafe_engage()
						src.det.shocked = 1
						var/losttime = rand(2,5)
						src.visible_message("<B><font color=#B7410E>The bomb buzzes oddly, emitting electric sparks. It would be a bad idea to touch any wires for the next [losttime] seconds.</font></B>")
						playsound(src.loc, "sparks", 75, 1, -1)
						elecflash(src,power = 2)
						SPAWN_DBG(10 * losttime)
							src.det.shocked = 0
							src.visible_message("<B><font color=#B7410E>The buzzing stops, and the countdown continues.</font></B>")
					if ("mobility")
						src.det.failsafe_engage()
						playsound(src.loc, "sound/machines/click.ogg", 50, 1)
						if (anchored)
							anchored = 0
							src.visible_message("<B><font color=#B7410E>A loud click is heard from the inside the canister, unsecuring itself.</font></B>")
						else
							anchored = 1
							src.visible_message("<B><font color=#B7410E>A loud click is heard from the bottom of the canister, securing itself.</font></B>")
					if ("leak")
						src.det.failsafe_engage()
						playsound(src.loc, "sound/machines/hiss.ogg", 50, 1)
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
	SPAWN_DBG( 0 )
		healthcheck()
		return
	return

/obj/machinery/portable_atmospherics/canister/toxins/New()

	..()

	src.air_contents.toxins = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/oxygen/New()

	..()

	src.air_contents.oxygen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/sleeping_agent/New()

	..()

	var/datum/gas/sleeping_agent/trace_gas = new
	if(!air_contents.trace_gases)
		air_contents.trace_gases = list()
	air_contents.trace_gases += trace_gas
	trace_gas.moles = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/nitrogen/New()

	..()

	src.air_contents.temperature = 80
	src.air_contents.nitrogen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/carbon_dioxide/New()

	..()
	src.air_contents.carbon_dioxide = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1


/obj/machinery/portable_atmospherics/canister/air/New()

	..()
	src.air_contents.oxygen = (O2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	src.air_contents.nitrogen = (N2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1
