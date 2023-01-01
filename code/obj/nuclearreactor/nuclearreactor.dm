// ----------------------------------------------------- //
// Defintion for the nuclear reactor engine
// ----------------------------------------------------- //
#define REACTOR_GRID_WIDTH 7
#define REACTOR_GRID_HEIGHT 7
#define REACTOR_TOO_HOT_TEMP 1200
#define REACTOR_ON_FIRE_TEMP 1500
#define REACTOR_MELTDOWN_TEMP 2000 //just so the components can melt before the catastrophic overload

/obj/machinery/atmospherics/binary/nuclear_reactor
	name = "Model NTBMK Nuclear Reactor"
	desc = "A nuclear reactor vessel, with slots for fuel rods and other components. Hey wait, didn't one of these explode once?"
	icon = 'icons/misc/nuclearreactor.dmi'
	icon_state = "reactor"
	bound_width = 160
	bound_height = 160
	pixel_x = -64
	pixel_y = -64
	bound_x = -64
	bound_y = -64
	anchored = TRUE
	density = TRUE
	mat_changename = FALSE
	dir = EAST
	custom_suicide = TRUE
	pixel_point = TRUE
	/// 2D grid of reactor components, or null where there are no components. Size is REACTOR_GRID_WIDTH x REACTOR_GRID_HEIGHT
	var/list/obj/item/reactor_component/component_grid[REACTOR_GRID_WIDTH][REACTOR_GRID_HEIGHT]
	/// 2D grid of lists of neutrons in each grid slot of the component grid. Lists can be empty.
	var/list/list/datum/neutron/flux_grid[REACTOR_GRID_WIDTH][REACTOR_GRID_HEIGHT]
	/// Number of neutrons that hit the edge of the reactor grid last tick
	var/radiationLevel = 0
	/// Current gas mixture to process
	var/datum/gas_mixture/current_gas = null
	/// Reactor casing temperature
	var/temperature = T20C

	/// Volume of gas to process each tick
	var/reactor_vessel_gas_volume=200
	/// Reference to the power terminal we use to register onto the pnet
	var/obj/machinery/power/terminal/terminal = null
	/// ID of this object on the pnet
	var/net_id = null
	/// Flag indicating total meltdown has happened
	var/melted = FALSE

	/// INTERNAL: Used to detemine whether an icon update is needed for the component grid overlay
	var/_comp_grid_overlay_update = TRUE
	/// ref to the turf the reactor light is stored on, because you can't center simple lights
	var/turf/_light_turf
	/// INTERNAL: count of old pending grid updates, for the flicker prevention code
	var/_pending_grid_updates = 0
	New()
		. = ..()
		terminal = new /obj/machinery/power/terminal/netlink(src.loc)
		src.net_id = generate_net_id(src)
		terminal.set_dir(turn(src.dir,-90))
		terminal.master = src

		src.setMaterial(getMaterial("steel"))
		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				src.flux_grid[x][y] = list()

		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Control Rods", .proc/_set_controlrods_mechchomp)
		src._light_turf = get_turf(src)
		src._light_turf.add_medium_light("reactor_light", list(255,255,255,255))
		_comp_grid_overlay_update = TRUE
		UpdateIcon()

	disposing()
		src._light_turf?.remove_medium_light("reactor_light")
		. = ..()

	update_icon()

		//status lights
		//gas input/output
		if(air1?.total_moles_full() > 100) //more than trace gas
			src.UpdateOverlays(image(icon, "lights_cool"), "gas_input_lights")
		else
			src.UpdateOverlays(null, "gas_input_lights")
		if(air2?.total_moles_full() > 100) //more than trace gas
			src.UpdateOverlays(image(icon, "lights_heat"), "gas_output_lights")
		else
			src.UpdateOverlays(null, "gas_output_lights")

		//temperature & radiation warning
		if(src.temperature >= REACTOR_TOO_HOT_TEMP || src.radiationLevel > 50)
			if(temperature >= REACTOR_ON_FIRE_TEMP || src.radiationLevel > 75)
				src.UpdateOverlays(image(icon, "lights_meltdown"), "temp_warn_lights")
			else
				src.UpdateOverlays(image(icon, "lights_warning"), "temp_warn_lights")
		else
			src.UpdateOverlays(null, "temp_warn_lights")

		//status lights
		switch(src.temperature)
			if(-INFINITY to T20C) src.UpdateOverlays(null, "status_display")
			if(T20C to REACTOR_TOO_HOT_TEMP) src.UpdateOverlays(image(icon, "status_active"), "status_display")
			if(REACTOR_TOO_HOT_TEMP to REACTOR_ON_FIRE_TEMP) src.UpdateOverlays(image(icon, "status_overheat"), "status_display")
			if(REACTOR_ON_FIRE_TEMP to INFINITY) src.UpdateOverlays(image(icon, "status_meltdown"), "status_display")

		//and finally, component grid
		if(_comp_grid_overlay_update)
			//base
			var/icon/base_grid = icon(icon, "reactor_empty")
			for(var/x=1 to REACTOR_GRID_WIDTH)
				for(var/y=1 to REACTOR_GRID_HEIGHT)
					if(src.component_grid[x][y])
						base_grid.Blend(src.component_grid[x][y].cap_icon, ICON_OVERLAY, ((y-1)*18)+11, (124-x*15)-4)
			//The following code is intended to prevent flicker when updating the reactor grid
			//it seems like byond will delete the old image before it finishes sending the new one, so you got flicker
			//this preserves the old image while sending the new one for half a second, which should hopefully prevent that
			var/image/old_grid = src.GetOverlayImage("reactor_grid")
			if(old_grid)
				old_grid.layer = old_grid.layer+0.1
				src.UpdateOverlays(old_grid, "old_grid")
				_pending_grid_updates++
				SPAWN(0.5 SECONDS)
					if(_pending_grid_updates <= 1)
						src.UpdateOverlays(null, "old_grid")
					_pending_grid_updates--

			src.UpdateOverlays(image(base_grid), "reactor_grid")
			_comp_grid_overlay_update = FALSE



	proc/_set_controlrods_mechchomp(var/datum/mechanicsMessage/inp)
		if(!length(inp.signal)) return
		if(src.set_control_rods(text2num(inp.signal)))
			logTheThing(LOG_STATION, src, "set control rods to [text2num(inp.signal)] using mechcomp.")

	process()
		. = ..()
		if(melted)
			return
		var/input_starting_pressure = MIXTURE_PRESSURE(air1)
		var/tmpRads = 0

		//PV=nRT
		//We're using volume because that makes sense
		//but we need to express that in moles so,  1/n = RT/PV .. n = PV/RT
		var/transfer_moles = 0
		if(input_starting_pressure)
			transfer_moles = (air1.volume*input_starting_pressure)/(R_IDEAL_GAS_EQUATION*air1.temperature)
		var/datum/gas_mixture/gas_input = air1.remove(transfer_moles)
		var/datum/gas_mixture/gas_output = air2
		var/total_gas_volume = 0

		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				if(src.component_grid[x][y])
					src.component_grid[x][y].loc = src
					//flow gas through components
					var/obj/item/reactor_component/comp = src.component_grid[x][y]
					total_gas_volume += comp.gas_volume
					var/datum/gas_mixture/gas = comp.processGas(gas_input)
					if(gas) gas_output.merge(gas)

					//balance heat between components
					comp.processHeat(src.getGridNeighbors(x,y))

					//calculate neutron flux
					src.flux_grid[x][y] = comp.processNeutrons(src.flux_grid[x][y])
				for(var/datum/neutron/N in src.flux_grid[x][y])
					var/xmod = 0
					var/ymod = 0
					xmod += ((N.dir & EAST) == EAST)
					xmod -= ((N.dir & WEST) == WEST)
					ymod += ((N.dir & SOUTH) == SOUTH)
					ymod -= ((N.dir & NORTH) == NORTH)
					if((x+xmod >= 1 & y+ymod >= 1) & (x+xmod <= REACTOR_GRID_WIDTH & y+ymod <= REACTOR_GRID_HEIGHT))
						src.flux_grid[x+xmod][y+ymod]+=N
						src.flux_grid[x][y]-=N
					else
						src.flux_grid[x][y]-=N
						tmpRads++ //neutrons hitting the casing get blasted in to the room - have fun with that engineers!

		var/datum/gas_mixture/gas = src.processCasingGas(gas_input) //the reactor has some inherent gas cooling channels
		if(gas)
			gas_output.merge(gas)

		//if we somehow ended up with input gas still
		gas_output.merge(gas_input)

		if(temperature >= REACTOR_TOO_HOT_TEMP)
			if(!src.GetParticles("overheat_smoke"))
				src.UpdateParticles(new/particles/nuke_overheat_smoke(get_turf(src)),"overheat_smoke")
				src.visible_message("<span class='alert'><b>The [src] begins to smoke!</b></span>")
				logTheThing("station", src, "[src] is at [temperature]K and may meltdown")
				if(!ON_COOLDOWN(src, "pda_temp_alert", 30 SECONDS)) //prevent spam when it's on the edge
					src.alertPDA("ALERT: [src] has reached a dangerous temperature. Intervene immediately to prevent meltdown.")
			if(temperature >= REACTOR_ON_FIRE_TEMP && !src.GetParticles("overheat_fire"))
				src.UpdateParticles(new/particles/nuke_overheat_fire(get_turf(src)),"overheat_fire")
				src.visible_message("<span class='alert'><b>The [src] begins to burn!</b></span>")
				logTheThing("station", src, "[src] is at [temperature]K and is likely to meltdown")
				if(!ON_COOLDOWN(src, "pda_temp_alert_critical", 30 SECONDS)) //prevent spam when it's on the edge
					src.alertPDA("ALERT: [src] has reached CRITICAL temperature. MELTDOWN IMMINENT.", crisis = TRUE)
			else if(temperature < REACTOR_ON_FIRE_TEMP && src.GetParticles("overheat_fire"))
				src.visible_message("<span class='alert'><b>The [src] stops burning.</b></span>")
				logTheThing("station", src, "[src] is cooling from 2500K")
				src.ClearSpecificParticles("overheat_fire")
				if(!ON_COOLDOWN(src, "pda_temp_alert_critical", 30 SECONDS)) //prevent spam when it's on the edge
					src.alertPDA("ALERT: [src] has cooled below critical temperature. Meltdown averted. Have a nice day.", crisis = TRUE)
		else
			if(src.GetParticles("overheat_smoke"))
				src.visible_message("<span class='alert'><b>The [src] stops smoking.</b></span>")
				logTheThing("station", src, "[src] is cooling from [temperature]K")
				src.ClearSpecificParticles("overheat_smoke")
				if(!ON_COOLDOWN(src, "pda_temp_alert", 30 SECONDS)) //prevent spam when it's on the edge
					src.alertPDA("ALERT: [src] has cooled below dangerous temperature. Have a nice day.")

		src.radiationLevel = tmpRads
		if(tmpRads > 1000 || temperature > REACTOR_MELTDOWN_TEMP)
			src.catastrophicOverload() //we need this, otherwise neutron interactions go exponential and processing does too
			return

		processCaseRadiation(tmpRads)
		total_gas_volume += src.reactor_vessel_gas_volume
		src.air1.volume = total_gas_volume

		src.network1?.update = TRUE
		src.network2?.update = TRUE
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"temp=[temperature]&rads=[tmpRads]&flowrate=[total_gas_volume]")
		UpdateIcon()

	attackby(obj/item/I, mob/user)
		if(istype(I,/obj/item/reactor_component))
			src.Attackhand(user)
		else
			. = ..()

	proc/alertPDA(msg, crisis=FALSE)
		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.data["command"] = "text_message"
		signal.data["sender_name"] = "ENGINE-MAILBOT"
		signal.data["group"] = list(MGO_ENGINEER, MGA_ENGINE)
		if(crisis)
			signal.data["group"] += MGA_CRISIS
		signal.data["message"] = msg
		signal.data["sender"] = "00000000"
		signal.data["address_1"] = "00000000"

		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)

	proc/processCasingGas(var/datum/gas_mixture/inGas)
		if(src.current_gas)
			var/heat_transfer_mult = 0.95
			//heat transfer equation = hA(T2-T1)
			//assume A = 1m^2
			var/deltaT = src.current_gas.temperature - src.temperature
			//heat transfer coefficient
			var/hTC = calculateHeatTransferCoefficient(null, src.material)
			if(hTC>0)
				var/gas_thermal_e = THERMAL_ENERGY(current_gas)
				src.current_gas.temperature += heat_transfer_mult*-deltaT*hTC
				//Q = mcT
				//dQ = mc(dT)
				//dQ/mc = dT
				src.temperature += (gas_thermal_e - THERMAL_ENERGY(current_gas))/(420*7700*2.5)
			. = src.current_gas
		if(inGas)
			src.current_gas = inGas.remove((src.reactor_vessel_gas_volume*MIXTURE_PRESSURE(inGas))/(R_IDEAL_GAS_EQUATION*inGas.temperature))


	proc/processCaseRadiation(var/rads)
		if(rads <= 0)
			return

		src.AddComponent(/datum/component/radioactive, min(rads*2, 100), TRUE, FALSE, 5)
		rads -= 10

		if(rads <= 0)
			return

		for(var/i = min(round(rads/2),50),i>0,i--)
			shoot_projectile_XY(src, new /datum/projectile/neutron(min(rads*2,100)), rand(-10,10), rand(-10,10)) //for once, rand(range) returning int is useful

	proc/catastrophicOverload()
		var/sound/alarm = sound('sound/misc/airraid_loop.ogg')
		alarm.repeat = TRUE
		alarm.volume = 50
		alarm.channel = 5
		world << alarm //ew
		command_alert("A nuclear reactor aboard the station has catastrophically overloaded. Radioactive debris, nuclear fallout, and coolant fires are likely. Immediate evacuation of the surrounding area is strongly advised.", "NUCLEAR MELTDOWN")

		logTheThing("station", src, "[src] CATASTROPHICALLY OVERLOADS (this is bad)")
		//explode, throw radioactive components everywhere, dump rad gas, throw radioactive debris everywhere
		src.melted = TRUE
		if(!src.current_gas)
			src.current_gas = new/datum/gas_mixture()
			src.current_gas.vacuum()
		src.current_gas.radgas += 6000
		src.current_gas.temperature = src.temperature
		var/turf/current_loc = get_turf(src)
		current_loc.assume_air(current_gas)
		explosion_new(src,current_loc,2500,1,0,360,TRUE)
		SPAWN(15 SECONDS)
			alarm.repeat = FALSE //haha this is horrendous, this cannot be the way to do this
			alarm.status = SOUND_UPDATE
			world << alarm

	proc/getGridNeighbors(var/x,var/y)
		. = list()
		if(x-1 < 1)
			. += null
		else
			. += src.component_grid[x-1][y]
		if(x+1 > REACTOR_GRID_WIDTH)
			. += null
		else
			. += src.component_grid[x+1][y]
		if(y-1 < 1)
			. += null
		else
			. += src.component_grid[x][y-1]
		if(y+1 > REACTOR_GRID_HEIGHT)
			. += null
		else
			. += src.component_grid[x][y+1]

	//override the atmos/binary connection code, because it doesn't like big icons
	initialize()
		if(node1 && node2) return

		var/node2_connect = dir
		var/node1_connect = turn(dir, 180)

		for(var/obj/machinery/atmospherics/pipe/simple/target in get_steps(get_steps(src, node1_connect, 3), SOUTH, 1))
			if(target.initialize_directions & node2_connect)
				if(target != src)
					node1 = target
					break

		for(var/obj/machinery/atmospherics/pipe/simple/target in get_steps(get_steps(src, node2_connect, 3), NORTH, 1))
			if(target.initialize_directions & node1_connect)
				if(target != src)
					node2 = target
					break

		UpdateIcon()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "NuclearReactor")
			ui.open()

	ui_static_data(mob/user)
		. = list(
			"gridW" = REACTOR_GRID_WIDTH,
			"gridH" = REACTOR_GRID_HEIGHT,
			"emptySlotIcon" = icon2base64(icon('icons/misc/reactorcomponents.dmi',"empty"))
		)

	ui_data(mob/user)
		var/can_see_neutrons = isadmin(user)
		var/comps[REACTOR_GRID_WIDTH][REACTOR_GRID_HEIGHT]
		var/control_rod_level = 0
		var/control_rod_level_true = 0
		var/control_rod_count = 0
		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				if(src.component_grid[x][y])
					var/obj/item/reactor_component/comp = src.component_grid[x][y]
					if(istype(comp,/obj/item/reactor_component/control_rod))
						var/obj/item/reactor_component/control_rod/CR = comp
						control_rod_count++
						control_rod_level+=CR.configured_insertion_level
						control_rod_level_true+=CR.neutron_cross_section
					comps[x][y]=list(
							"x" = x,
							"y" = y,
							"name" = comp.name,
							"img" = comp.ui_image,
							"temp" = comp.temperature,
							"extra" = comp.extra_info(),
							"flux" = can_see_neutrons? length(src.flux_grid[x][y]) : null
 						)

		. = list(
			"components" = comps,
			"reactorTemp" = src.temperature,
			"reactorRads" = src.radiationLevel,
			"configuredControlRodLevel" = (control_rod_level/max(1,control_rod_count))*100,
			"actualControlRodLevel" = (control_rod_level_true/max(1,control_rod_count))*100
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if(.)
			return
		if(isintangible(ui.user) || isdead(ui.user) || isunconscious(ui.user) || ui.user.hasStatus("resting"))
			return

		if(!in_interact_range(src, ui.user))
			return

		switch(action)
			if("adjustCR")
				src.set_control_rods(text2num(params["crvalue"]))

			if("slot")
				var/x = params["x"]
				var/y = params["y"]
				if(src.component_grid[x][y])
					if(issilicon(ui.user))
						boutput(ui.user,"Your clunky robot hands can't grip the [src.component_grid[x][y]]!")
						return

					if(src.component_grid[x][y].melted)
						boutput(ui.user, "The component is melted! It's stuck.")
						return

					ui.user.visible_message("<span class='alert'>[ui.user] starts removing a [component_grid[x][y]]!</span>", "<span class='alert'>You start removing the [component_grid[x][y]]!</span>")
					var/datum/action/bar/icon/callback/A = new(ui.user, src, 1 SECONDS, .proc/remove_comp_callback, list(x,y,ui.user), component_grid[x][y].icon, component_grid[x][y].icon_state,\
					"", INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
					A.maximum_range=3
					actions.start(A,ui.user)
				else
					var/equipped = ui.user.equipped()
					if(!equipped)
						return

					if(!istype(equipped,/obj/item/reactor_component))
						ui.user.visible_message("<span class='alert'>[ui.user] tries to shove \a [equipped] into the reactor. Silly [ui.user]!</span>", "<span class='alert'>You try to put \a [equipped] into the reactor. You feel very foolish.</span>")
						return

					ui.user.visible_message("<span class='alert'>[ui.user] starts inserting \a [equipped]!</span>", "<span class='alert'>You start inserting the [equipped]!</span>")
					var/datum/action/bar/icon/callback/A = new(ui.user, src, 1 SECONDS, .proc/insert_comp_callback, list(x,y,ui.user,equipped), ui.user.equipped().icon, ui.user.equipped().icon_state, \
					"", INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
					A.maximum_range=3
					actions.start(A,ui.user)

	proc/insert_comp_callback(var/x,var/y,var/mob/user,var/obj/item/reactor_component/equipped)
		if(src.component_grid[x][y])
			return FALSE
		src.component_grid[x][y]=equipped
		user.u_equip(equipped)
		equipped.set_loc(src)
		playsound(src, 'sound/machines/law_insert.ogg', 80)
		logTheThing("station", user, "[constructName(user)] <b>inserts</b> component into nuclear reactor([src]): [equipped] at slot [x],[y]")
		user.visible_message("<span class='alert'>[user] slides \a [equipped] into the reactor</span>", "<span class='alert'>You slide the [equipped] into the reactor.</span>")
		tgui_process.update_uis(src)
		_comp_grid_overlay_update = TRUE
		UpdateIcon()

	proc/remove_comp_callback(var/x,var/y,var/mob/user)
		playsound(src, 'sound/machines/law_remove.ogg', 80)
		logTheThing("station", user, "[constructName(user)] <b>removes</b> component from nuclear reactor([src]): [src.component_grid[x][y]] at slot [x],[y]")
		user.visible_message("<span class='alert'>[user] slides \a [src.component_grid[x][y]] out of the reactor</span>", "<span class='alert'>You slide the [src.component_grid[x][y]] out of the reactor.</span>")
		user.put_in_hand_or_drop(src.component_grid[x][y])
		src.component_grid[x][y] = null
		tgui_process.update_uis(src)
		_comp_grid_overlay_update = TRUE
		UpdateIcon()

	proc/set_control_rods(var/val)
		. = FALSE
		if(!isnum_safe(val) || val > 100 || val < 0)
			return
		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				if(src.component_grid[x][y])
					if(istype(src.component_grid[x][y],/obj/item/reactor_component/control_rod))
						var/obj/item/reactor_component/control_rod/CR = src.component_grid[x][y]
						if(CR.configured_insertion_level != val/100)
							CR.configured_insertion_level = val/100
							. = TRUE

	ex_act(severity)
		var/comp_throw_prob = 0
		switch(severity)
			if(3.0)
				comp_throw_prob = 10
			if(2.0)
				comp_throw_prob = 25
			if(1.0)
				comp_throw_prob = 100
				logTheThing("station", src, "[src] has been destroyed in an explosion!")

		var/turf/epicentre = get_turf(src)
		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				if(src.component_grid[x][y] && prob(comp_throw_prob))
					if(severity > 1)
						logTheThing("station", src, "a [src.component_grid[x][y]] has been removed from the [src] by an explosion")
						_comp_grid_overlay_update = TRUE
					if(prob(50))
						var/obj/item/reactor_component/throwcomp = src.component_grid[x][y]
						throwcomp.set_loc(epicentre)
						throwcomp.throw_at(get_ranged_target_turf(epicentre,pick(alldirs),rand(1,20)),rand(1,20),rand(1,20))
					else
						qdel(src.component_grid[x][y])
						var/obj/decal/cleanable/debris = make_cleanable(/obj/decal/cleanable/machine_debris, epicentre)
						debris.AddComponent(/datum/component/radioactive,100,TRUE,FALSE)
						debris.streak_cleanable(dist_upper=20)
					src.component_grid[x][y] = null //get rid of the internal ref once we've thrown it out
		if(severity <= 1)
			qdel(src)
		UpdateIcon()

	Exited(var/atom/movable/A)
		if(istype(A,/obj/item/reactor_component))
			for(var/x=1 to REACTOR_GRID_WIDTH)
				for(var/y=1 to REACTOR_GRID_HEIGHT)
					if(src.component_grid[x][y] == A)
						src.component_grid[x][y] = null
						break

	suicide(mob/user)
		var/list/free_slots = list()
		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				if(src.component_grid[x][y] == null)
					free_slots += list(list(x,y))
		if(length(free_slots))
			user.visible_message("<span class='alert'><b>[user] climbs into \the [src] and starts forcing [his_or_her(user)] body down into a channel!</b></span>")
			var/list/chosen_slot = pick(free_slots)
			user.set_loc(src)
			SPAWN(1 SECOND)
				playsound(user, 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
				user.emote("scream")
			SPAWN(2.5 SECONDS)
				playsound(user, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
				user.emote("scream")
			SPAWN(4 SECONDS)
				playsound(user, 'sound/impact_sounds/Flesh_Crush_1.ogg', 50, 1)
				var/obj/item/reactor_component/fuel_rod/meat_rod = new /obj/item/reactor_component/fuel_rod("flesh")
				meat_rod.material.name = user.name
				if(user.bioHolder && user.bioHolder.HasEffect("radioactive"))
					meat_rod.material.setProperty("radioactive", 3)
				meat_rod.setMaterial(meat_rod.material)
				if(src.component_grid[chosen_slot[1]][chosen_slot[2]] == null) //double check, just in case
					src.component_grid[chosen_slot[1]][chosen_slot[2]] = meat_rod //hehe
				else
					meat_rod.throw_at(get_ranged_target_turf(get_turf(src),pick(alldirs),rand(1,20)),rand(1,20),rand(1,20))
				user.visible_message("<span class='alert'><b>The bits of [user] that didn't fit spray everywhere!</b></span>")
				user.set_loc(get_turf(src))
				user.gib()
				_comp_grid_overlay_update = TRUE
				UpdateIcon()
			return TRUE
		else
			user.visible_message("<span class='alert'>[user] tries to climb into \the [src], but it's full. What a moron!</span>")
			return FALSE




/datum/neutron //this is literally just a tuple
	var/dir = NORTH
	var/velocity = 1

	New(var/dir,var/velocity)
		..()
		src.dir = dir
		src.velocity = velocity

/obj/machinery/atmospherics/binary/nuclear_reactor/prefilled/normal
	New()
		src.component_grid[3][1] = new /obj/item/reactor_component/gas_channel("steel")
		src.component_grid[3][3] = new /obj/item/reactor_component/gas_channel("steel")
		src.component_grid[3][5] = new /obj/item/reactor_component/gas_channel("steel")
		src.component_grid[3][7] = new /obj/item/reactor_component/gas_channel("steel")
		src.component_grid[5][1] = new /obj/item/reactor_component/gas_channel("steel")
		src.component_grid[5][3] = new /obj/item/reactor_component/gas_channel("steel")
		src.component_grid[5][5] = new /obj/item/reactor_component/gas_channel("steel")
		src.component_grid[5][7] = new /obj/item/reactor_component/gas_channel("steel")

		src.component_grid[3][2] = new /obj/item/reactor_component/heat_exchanger("steel")
		src.component_grid[3][4] = new /obj/item/reactor_component/heat_exchanger("steel")
		src.component_grid[3][6] = new /obj/item/reactor_component/heat_exchanger("steel")
		src.component_grid[5][2] = new /obj/item/reactor_component/heat_exchanger("steel")
		src.component_grid[5][4] = new /obj/item/reactor_component/heat_exchanger("steel")
		src.component_grid[5][6] = new /obj/item/reactor_component/heat_exchanger("steel")

		src.component_grid[4][1] = new /obj/item/reactor_component/heat_exchanger("steel")
		src.component_grid[4][7] = new /obj/item/reactor_component/heat_exchanger("steel")

		src.component_grid[4][3] = new /obj/item/reactor_component/control_rod("bohrum")
		src.component_grid[4][5] = new /obj/item/reactor_component/control_rod("bohrum")
		..()

/obj/machinery/atmospherics/binary/nuclear_reactor/prefilled/meltdown
	New()
		for(var/x=2 to REACTOR_GRID_WIDTH-1)
			for(var/y=2 to REACTOR_GRID_HEIGHT-1)
				src.component_grid[x][y] = new /obj/item/reactor_component/fuel_rod("plutonium")
		..()

#undef REACTOR_GRID_WIDTH
#undef REACTOR_GRID_HEIGHT
#undef REACTOR_TOO_HOT_TEMP
#undef REACTOR_ON_FIRE_TEMP
#undef REACTOR_MELTDOWN_TEMP
/datum/projectile/neutron //neutron projectile for radiation shooting from reactor
	name = "neutron"
	icon_state = ""
	icon = null
	power = 100
	cost = 20
//Kill/Stun ratio
	ks_ratio = 1.0
//name of the projectile setting, used when you change a guns setting
	sname = "neutron"
//file location for the sound you want it to play
	shot_sound = null
	shot_number = 1
	damage_type = D_TOXIC //would use D_SPECIAL but a few things don't use it properly.
	//With what % do we hit mobs laying down
	hit_ground_chance = 50
	window_pass = FALSE
	silentshot = TRUE

	New(power)
		..()
		src.power = power

	on_pre_hit(atom/hit, angle, var/obj/projectile/O)
		if(isintangible(hit) || isobserver(hit))
			return TRUE //don't irradiate ghosts

		var/multiplier = istype(hit,/turf/simulated/wall/auto/reinforced) ? 5 : 10
		var/density = (hit.material ? hit.material.getProperty("density") : 3) //3 is default density

		//first are we colliding with this or ignoring it?
		if(prob(density*multiplier))
			//we hit it! now decide what that hit means
			//first, reflection
			if(hit.material && prob(hit.material.getProperty("hard")*10))
				//reflect
				var/obj/projectile/reflected = shoot_reflected_bounce(O, hit)
				reflected.power = O.power
				return FALSE

			//then fission
			//fission basically hits like an AoE contamination effect
			if(hit.material && prob(hit.material.getProperty("n_radioactive")*10))
				for(var/turf/T in range(1, hit))
					T.AddComponent(/datum/component/radioactive, 50, TRUE, TRUE, 1)
			if(hit.material && prob(hit.material.getProperty("radioactive")*10))
				for(var/turf/T in range(1, hit))
					T.AddComponent(/datum/component/radioactive, 50, TRUE, FALSE, 1)

			//finally, moderation
			hit.AddComponent(/datum/component/radioactive, min(O.power, density*multiplier), TRUE, FALSE, 1) //make it all glowy
			O.power -= density*multiplier
			if(O.power < 1)
				O.power = 0
			return TRUE //don't hit this, lose power and pass through it
		return TRUE

	tick(var/obj/projectile/P)
		if(P.power <= 0)
			P.die()
			return

	get_power(obj/projectile/P, atom/A)
		return P.power

/particles/nuke_overheat_smoke
	icon = 'icons/effects/effects.dmi'
	icon_state = list("smoke")
	color = "#777777"
	width = 400
	height = 400
	spawning = 5
	count = 500
	lifespan = generator("num", 20, 35, UNIFORM_RAND)
	fade = generator("num", 50, 100, UNIFORM_RAND)
	position = generator("box", list(20,20,0), list(100,100,0), UNIFORM_RAND)
	velocity = generator("box", list(-1,0.5,0), list(1,2,0), UNIFORM_RAND)
	gravity = list(0.07, 0.2, 0)
	color_change = generator("num", 0, 0, UNIFORM_RAND)
	grow = list(0.02, 0)
	fadein = 0

/particles/nuke_overheat_fire
	icon = 'icons/effects/effects.dmi'
	icon_state = list("onfire")
	color = generator("color", "#ffffff", "#ff8000", UNIFORM_RAND)
	width = 400
	height = 400
	lifespan = generator("num", 3, 8, UNIFORM_RAND)
	fade = 11
	position = generator("box", list(20,20,0), list(100,100,0), UNIFORM_RAND)
	gravity = list(0.07, 0.02, 0)
	scale = generator("num", 0.8, 1.5, UNIFORM_RAND)
	spin = 1
	fadein = generator("num", 4, 7, UNIFORM_RAND)
