// ----------------------------------------------------- //
// Defintion for the nuclear reactor engine
// ----------------------------------------------------- //
#define REACTOR_GRID_WIDTH 7
#define REACTOR_GRID_HEIGHT 7
#define REACTOR_TOO_HOT_TEMP 1200
#define REACTOR_ON_FIRE_TEMP 1500
#define REACTOR_MELTDOWN_TEMP 2000 //just so the components can melt before the catastrophic overload

/obj/machinery/nuclear_reactor
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
	anchored = ANCHORED
	density = TRUE
	mat_changename = FALSE
	dir = EAST
	custom_suicide = TRUE
	pixel_point = TRUE
	machine_registry_idx = MACHINES_FISSION
	processing_tier = PROCESSING_QUARTER
	/// 2D grid of reactor components, or null where there are no components. Size is REACTOR_GRID_WIDTH x REACTOR_GRID_HEIGHT
	var/list/obj/item/reactor_component/component_grid[REACTOR_GRID_WIDTH][REACTOR_GRID_HEIGHT]
	/// 2D grid of lists of neutrons in each grid slot of the component grid. Lists can be empty.
	var/list/list/datum/neutron/flux_grid[REACTOR_GRID_WIDTH][REACTOR_GRID_HEIGHT]
	/// Number of neutrons that hit the edge of the reactor grid last tick
	var/radiationLevel = 0
	/// Current gas mixture to process
	var/datum/gas_mixture/current_gas = null
	/// gas that has been processed, primarily used for atmos analyser
	var/datum/gas_mixture/air_contents = null
	/// Reactor casing temperature
	var/temperature = T20C
	/// Thermal mass. Basically how much energy it takes to heat this up 1Kelvin
	var/thermal_mass = 420*2000//specific heat capacity of steel (420 J/KgK) * mass of reactor (Kg)

	/// Volume of gas to process each tick
	var/reactor_vessel_gas_volume=200
	/// Reference to the power terminal we use to register onto the pnet
	var/obj/machinery/power/terminal/terminal = null
	/// ID of this object on the pnet
	var/net_id = null
	/// Flag indicating total meltdown has happened
	var/melted = FALSE
	var/obj/machinery/atmospherics/unary/node/input
	var/obj/machinery/atmospherics/unary/node/output

	/// INTERNAL: Used to detemine whether an icon update is needed for the component grid overlay
	VAR_PRIVATE/_comp_grid_overlay_update = TRUE
	/// ref to the turf the reactor light is stored on, because you can't center simple lights
	VAR_PRIVATE/turf/_light_turf
	/// INTERNAL: count of old pending grid updates, for the flicker prevention code
	VAR_PRIVATE/_pending_grid_updates = 0
	/// INTERNAL DEBUG: tracks total stored thermal energy in the reactor grid
	VAR_PRIVATE/_last_total_thermal_e = 0
	/// INTERNAL DEBUG: tracks total stored thermal energy in the coolant
	VAR_PRIVATE/_last_total_coolant_e = 0
	/// INTERNAL DEBUG: set to true to output debug messages
	VAR_PRIVATE/_debug_mode = FALSE

	New()
		. = ..()
		terminal = new /obj/machinery/power/terminal/netlink(src.loc)
		src.net_id = generate_net_id(src)
		terminal.set_dir(turn(src.dir,-90))
		terminal.master = src

		src.setMaterial(getMaterial("steel"), appearance = FALSE)
		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				src.flux_grid[x][y] = list()

		//Prevents unreachable turfs from being damaged, so as not to ruin engineer rounds
		for(var/turf/simulated/floor/F in src.locs)
			F.explosion_immune = TRUE

		src.air_contents = new /datum/gas_mixture()

		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Control Rods", PROC_REF(_set_controlrods_mechchomp))
		src._light_turf = get_turf(src)
		src._light_turf.add_medium_light("reactor_light", list(255,255,255,255))
		_comp_grid_overlay_update = TRUE
		src.input = new /obj/machinery/atmospherics/unary/node{dir = WEST}(get_step(get_steps(src, WEST, 2), SOUTH))
		src.output = new /obj/machinery/atmospherics/unary/node{dir = EAST}(get_step(get_steps(src, EAST, 2), NORTH))
		UpdateGasVolume()
		UpdateIcon()

	disposing()
		new /obj/fakeobject/nuclear_reactor_destroyed(src.loc)
		src._light_turf?.remove_medium_light("reactor_light")
		for(var/turf/simulated/floor/F in src.locs) //restore the explosion immune state of the original turf
			F.explosion_immune = initial(F.explosion_immune)
		. = ..()
		QDEL_NULL(src.input)
		QDEL_NULL(src.output)

	proc/MarkGridForUpdate()
		src._comp_grid_overlay_update = TRUE

	update_icon()
		//status lights
		//gas input/output
		if(src.input.air_contents && TOTAL_MOLES(src.input.air_contents) > 100)
			src.AddOverlays(image(icon, "lights_cool"), "gas_input_lights")
		else
			src.ClearSpecificOverlays("gas_input_lights")
		if(src.output.air_contents && TOTAL_MOLES(src.output.air_contents) > 100)
			src.AddOverlays(image(icon, "lights_heat"), "gas_output_lights")
		else
			src.ClearSpecificOverlays("gas_output_lights")

		//temperature & radiation warning
		if(src.temperature >= REACTOR_TOO_HOT_TEMP || src.radiationLevel > 50)
			if(temperature >= REACTOR_ON_FIRE_TEMP || src.radiationLevel > 75)
				src.AddOverlays(image(icon, "lights_meltdown"), "temp_warn_lights")
			else
				src.AddOverlays(image(icon, "lights_warning"), "temp_warn_lights")
		else
			src.ClearSpecificOverlays("temp_warn_lights")

		//status lights
		switch(src.temperature)
			if(-INFINITY to T20C) src.ClearSpecificOverlays("status_display")
			if(T20C to REACTOR_TOO_HOT_TEMP) src.AddOverlays(image(icon, "status_active"), "status_display")
			if(REACTOR_TOO_HOT_TEMP to REACTOR_ON_FIRE_TEMP) src.AddOverlays(image(icon, "status_overheat"), "status_display")
			if(REACTOR_ON_FIRE_TEMP to INFINITY) src.AddOverlays(image(icon, "status_meltdown"), "status_display")

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
				old_grid.layer -= 0.1
				src.AddOverlays(old_grid, "old_grid")
				_pending_grid_updates++
				SPAWN(0.5 SECONDS)
					if(_pending_grid_updates <= 1)
						src.ClearSpecificOverlays("old_grid")
					_pending_grid_updates--

			src.AddOverlays(image(base_grid), "reactor_grid")
			_comp_grid_overlay_update = FALSE



	proc/_set_controlrods_mechchomp(var/datum/mechanicsMessage/inp)
		if(!length(inp.signal)) return
		if(src.set_control_rods(text2num(inp.signal)))
			logTheThing(LOG_STATION, src, "set control rods to [text2num(inp.signal)] using mechcomp.")

	process()
		. = ..()
		if(melted)
			return

		//pass through last tick's air. We do this here so that atmos analyser can read it in between process calls
		var/coolant_thermal_e = THERMAL_ENERGY(src.air_contents)
		src.output.air_contents.merge(src.air_contents)
		//after merge, the original gas mixture is deleted, so create a new one
		src.air_contents = new /datum/gas_mixture()

		var/input_starting_pressure = MIXTURE_PRESSURE(src.input.air_contents)
		var/tmpRads = 0

		//PV=nRT
		//We're using volume because that makes sense
		//but we need to express that in moles so,  1/n = RT/PV .. n = PV/RT
		var/transfer_moles = 0
		if(input_starting_pressure)
			transfer_moles = (src.input.air_contents.volume*input_starting_pressure)/(R_IDEAL_GAS_EQUATION*src.input.air_contents.temperature)
		var/datum/gas_mixture/gas_input = src.input.air_contents.remove(transfer_moles)
		src.air_contents.volume = src.input.air_contents.volume
		gas_input?.volume = air_contents.volume
		_last_total_coolant_e = gas_input ? THERMAL_ENERGY(gas_input) : 0
		var/total_thermal_e = 0
		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				if(src.component_grid[x][y])
					src.component_grid[x][y].loc = src
					//flow gas through components
					var/obj/item/reactor_component/comp = src.component_grid[x][y]
					var/datum/gas_mixture/gas = comp.processGas(gas_input)
					gas_input?.volume -= comp.gas_volume
					if(gas)
						src.air_contents.merge(gas)

					//balance heat between components
					comp.processHeat(src.getGridNeighbors(x,y))

					//calculate neutron flux
					src.flux_grid[x][y] = comp.processNeutrons(src.flux_grid[x][y])

					total_thermal_e += comp.thermal_mass * comp.temperature

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
			src.air_contents.merge(gas)

		//if we somehow ended up with input gas still
		src.air_contents.merge(gas_input)

		if(temperature >= REACTOR_TOO_HOT_TEMP)
			if(!src.GetParticles("overheat_smoke"))
				src.UpdateParticles(new/particles/nuke_overheat_smoke(get_turf(src)),"overheat_smoke")
				src.visible_message(SPAN_ALERT("<b>The [src] begins to smoke!</b>"))
				logTheThing(LOG_STATION, src, "[src] is at [temperature]K and may meltdown")
				if(!ON_COOLDOWN(src, "pda_temp_alert", 30 SECONDS)) //prevent spam when it's on the edge
					src.alertPDA("ALERT: [src] has reached a dangerous temperature. Intervene immediately to prevent meltdown.")
					message_ghosts("<b>[src]</b> is getting dangerously hot! [log_loc(src.loc, ghostjump=TRUE)].")
			if(temperature >= REACTOR_ON_FIRE_TEMP && !src.GetParticles("overheat_fire"))
				src.UpdateParticles(new/particles/nuke_overheat_fire(get_turf(src)),"overheat_fire")
				src.visible_message(SPAN_ALERT("<b>The [src] begins to burn!</b>"))
				logTheThing(LOG_STATION, src, "[src] is at [temperature]K and is likely to meltdown")
				if(!ON_COOLDOWN(src, "pda_temp_alert_critical", 30 SECONDS)) //prevent spam when it's on the edge
					src.alertPDA("ALERT: [src] has reached CRITICAL temperature. MELTDOWN IMMINENT.", crisis = TRUE)
					message_ghosts("<b>[src]</b> is extremely close to melting down! [log_loc(src.loc, ghostjump=TRUE)].")
			else if(temperature < REACTOR_ON_FIRE_TEMP && src.GetParticles("overheat_fire"))
				src.visible_message(SPAN_ALERT("<b>The [src] stops burning.</b>"))
				logTheThing(LOG_STATION, src, "[src] is cooling from 2500K")
				src.ClearSpecificParticles("overheat_fire")
				if(!ON_COOLDOWN(src, "pda_temp_alert_critical", 30 SECONDS)) //prevent spam when it's on the edge
					src.alertPDA("ALERT: [src] has cooled below critical temperature. Meltdown averted. Have a nice day.", crisis = TRUE)
		else
			if(src.GetParticles("overheat_smoke"))
				src.visible_message(SPAN_ALERT("<b>The [src] stops smoking.</b>"))
				logTheThing(LOG_STATION, src, "[src] is cooling from [temperature]K")
				src.ClearSpecificParticles("overheat_smoke")
				if(!ON_COOLDOWN(src, "pda_temp_alert", 30 SECONDS)) //prevent spam when it's on the edge
					src.alertPDA("ALERT: [src] has cooled below dangerous temperature. Have a nice day.")

		src.radiationLevel = tmpRads
		if(tmpRads > 1000 || temperature > REACTOR_MELTDOWN_TEMP)
			src.catastrophicOverload() //we need this, otherwise neutron interactions go exponential and processing does too
			return

		processCaseRadiation(tmpRads)

		src.material_trigger_on_temp(src.temperature)

		total_thermal_e += src.thermal_mass * src.temperature
		if(src._debug_mode)
			boutput(world, "Reactor dE: [engineering_notation(total_thermal_e - src._last_total_thermal_e)]J Coolant dE:[engineering_notation(coolant_thermal_e - src._last_total_coolant_e)]J")
		src._last_total_thermal_e = total_thermal_e

		src.input.network?.update = TRUE
		src.output.network?.update = TRUE
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"temp=[temperature]&rads=[tmpRads]&flowrate=[src.air_contents.volume]")
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
			signal.data["noreply"] = TRUE
		signal.data["message"] = msg
		signal.data["sender"] = "00000000"
		signal.data["address_1"] = "00000000"

		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)

	proc/UpdateGasVolume()
		var/total_gas_volume = src.reactor_vessel_gas_volume
		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				if(src.component_grid[x][y])
					var/obj/item/reactor_component/comp = src.component_grid[x][y]
					total_gas_volume += comp.gas_volume
		src.input.air_contents.volume = total_gas_volume
		src.air_contents.volume = total_gas_volume

	proc/processCasingGas(var/datum/gas_mixture/inGas)
		if(src.current_gas)
			//first, define some helpful vars
			// temperature differential
			var/deltaT = src.temperature - src.current_gas.temperature
			// temp differential for radiative heating
			//this is equivelant to (src.temperature ** 4) - (src.current_gas.temperature ** 4), but factored so its less likely to hit overflow
			var/deltaTr = (src.temperature + src.current_gas.temperature)*(src.temperature - src.current_gas.temperature)*((src.temperature**2) + (src.current_gas.temperature**2))

			//thermal conductivity
			var/k = calculateHeatTransferCoefficient(null,src.material)
			//surface area in thermal contact (m^2)
			var/A = 1 * (MACHINE_PROC_INTERVAL*8) //multipied by process time to approximate flow rate

			var/thermal_e = THERMAL_ENERGY(current_gas)

			//commented out for later debugging purposes
			//var/coe_check = thermal_e + src.temperature*src.thermal_mass

			//okay, we're slightly abusing some things here. Notably we're using the thermal conductivity as a stand-in
			//for the convective heat transfer coefficient(h). It's wrong, since h generally depends on flow rate, but we
			//can assume a constant flow rate and then a dependence on the thermal conductivity of the material it's flowing over
			//which in this case is given by k
			//also radiative heating given by Steffan-Boltzman constant * area * (T1^4 - T2^4)
			//since this is a discrete approximation, it breaks down when the temperature diffs are low. As such, we linearise the equation
			//by clamping between hottest and coldest. It's not pretty, but it works.
			var/hottest = max(src.current_gas.temperature, src.temperature)
			var/coldest = min(src.current_gas.temperature, src.temperature)
			//max limit on the energy transfered is bounded between the coldest and hottest temperature of the thermal mass, to ensure that the
			//gas can't suck out more heat from the reactor than exists
			var/max_delta_e = clamp(((k * A * deltaT) + (5.67037442e-8 * A * deltaTr)), src.temperature*src.thermal_mass - hottest*src.thermal_mass, src.temperature*src.thermal_mass - coldest*src.thermal_mass)
			src.current_gas.temperature = clamp(src.current_gas.temperature + max_delta_e/HEAT_CAPACITY(src.current_gas), coldest, hottest)

			//after we've transferred heat to the gas, we remove that energy from the gas channel to preserve CoE
			src.temperature = clamp(src.temperature - (THERMAL_ENERGY(current_gas) - thermal_e)/src.thermal_mass, coldest, hottest)

			//commented out for later debugging purposes
			//var/coe2 = (THERMAL_ENERGY(current_gas) + src.temperature*src.thermal_mass)
			//if(abs(coe2 - coe_check) > 64)
			//	CRASH("COE VIOLATION REACTOR")
			if(src.current_gas.temperature <= 0 || src.temperature <= 0)
				CRASH("TEMP WENT NONPOSITIVE (hottest=[hottest], coldest=[coldest], max_delta_e=[max_delta_e], deltaT=[deltaT], deltaTr=[deltaTr])")

			. = src.current_gas
		if(inGas && (THERMAL_ENERGY(inGas) > 0))
			src.current_gas = inGas.remove((src.reactor_vessel_gas_volume*MIXTURE_PRESSURE(inGas))/(R_IDEAL_GAS_EQUATION*inGas.temperature))
			if(src.current_gas && TOTAL_MOLES(src.current_gas) < 1)
				if(istype(., /datum/gas_mixture))
					var/datum/gas_mixture/result = .
					result.merge(src.current_gas)
					src.current_gas = null
					return result
				else
					. = src.current_gas
					src.current_gas = null
					return .


	proc/processCaseRadiation(var/rads)
		if(rads <= 0)
			return

		src.AddComponent(/datum/component/radioactive, min(rads*3, 100), TRUE, FALSE, 5)
		rads -= 5

		if(rads <= 0)
			return

		for(var/i = min(ceil(rads / 2), 50), i>0, i--)
			shoot_projectile_XY(src, new /datum/projectile/neutron(max(5, min(rads*2,100))), rand(-10,10), rand(-10,10)) //for once, rand(range) returning int is useful

	proc/catastrophicOverload()
		world.save_intra_round_value("nuclear_accident_count_[map_settings.name]", 0)
		var/sound/alarm = sound('sound/machines/meltdown_siren.ogg')
		alarm.repeat = TRUE
		alarm.volume = 40
		alarm.channel = 5
		world << alarm //ew
		command_alert("A nuclear reactor aboard the station has catastrophically overloaded. Radioactive debris, nuclear fallout, and coolant fires are likely. Immediate evacuation of the surrounding area is strongly advised.", "NUCLEAR MELTDOWN")


		//explode, throw radioactive components everywhere, dump rad gas, throw radioactive debris everywhere
		src.melted = TRUE
		var/meltdown_badness = 0
		if(!src.current_gas)
			src.current_gas = new/datum/gas_mixture()

		//determine how bad this meltdown should be
		//basically this is a points system, more points = worser
		//at 49 fresh melted cerenkite rods, this is 1080 (feasible, but difficult). at 49 fresh melted plutonium rods this is 3038 (basically upper limit - it would be insane to reach this without admemes)
		//at 3 fresh melted cerenkite rods this is 60 (most common meltdown due to pipeburn)
		//total sum of radioactive junk
		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				if(src.component_grid[x][y])
					var/obj/item/reactor_component/comp = src.component_grid[x][y]
					//more radioactive material = higher score. Doubled if the component is already melted.
					meltdown_badness += (comp.material.getProperty("radioactive")*2 + comp.material.getProperty("n_radioactive")*5 + comp.material.getProperty("spent_fuel")*10) * (1 + comp.melted)
					if(istype(comp, /obj/item/reactor_component/gas_channel))
						var/obj/item/reactor_component/gas_channel/gascomp = comp
						src.current_gas.merge(gascomp.air_contents) //grab all the gas in the channels and put it back in the reactor so it can be vented into engineering

		src.current_gas.radgas += meltdown_badness*15
		src.current_gas.temperature = max(src.temperature, src.current_gas.temperature)
		var/turf/current_loc = get_turf(src)
		current_loc.assume_air(current_gas)

		for(var/i = 1 to rand(10,30))
			shoot_projectile_XY(src, new /datum/projectile/bullet/wall_buster_shrapnel(), rand(-10,10), rand(-10,10))

		message_ghosts("<b>[src]</b> is going BOOM! [log_loc(src.loc, ghostjump=TRUE)].")
		logTheThing(LOG_STATION, src, "[src] CATASTROPHICALLY OVERLOADS (this is bad) meltdown badness: [meltdown_badness]")

		explosion_new(src, current_loc, max(100, meltdown_badness*5), TRUE, 0, 360, TRUE)
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

					ui.user.visible_message(SPAN_ALERT("[ui.user] starts removing a [component_grid[x][y]]!"), SPAN_ALERT("You start removing the [component_grid[x][y]]!"))
					var/datum/action/bar/icon/callback/A = new(ui.user, src, 1 SECONDS, PROC_REF(remove_comp_callback), list(x,y,ui.user), component_grid[x][y].icon, component_grid[x][y].icon_state,\
					"", INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
					A.maximum_range=3
					actions.start(A,ui.user)
				else
					var/equipped = ui.user.equipped()
					if(!equipped)
						return

					if(!istype(equipped,/obj/item/reactor_component) && !istype(equipped,/obj/item/device/light/glowstick))
						ui.user.visible_message(SPAN_ALERT("[ui.user] tries to shove \a [equipped] into the reactor. Silly [ui.user]!"), SPAN_ALERT("You try to put \a [equipped] into the reactor. You feel very foolish."))
						return

					ui.user.visible_message(SPAN_ALERT("[ui.user] starts inserting \a [equipped]!"), SPAN_ALERT("You start inserting the [equipped]!"))
					var/datum/action/bar/icon/callback/A = new(ui.user, src, 1 SECONDS, PROC_REF(insert_comp_callback), list(x,y,ui.user,equipped), ui.user.equipped().icon, ui.user.equipped().icon_state, \
					"", INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
					A.maximum_range=3
					actions.start(A,ui.user)

	proc/insert_comp_callback(var/x,var/y,var/mob/user,var/obj/item/reactor_component/equipped)
		if(src.component_grid[x][y])
			return FALSE
		if(istype(equipped,/obj/item/device/light/glowstick))
			var/obj/item/device/light/glowstick/stick = equipped
			var/datum/material/glowstick_mat = getMaterial("glowstick")
			glowstick_mat = glowstick_mat.getMutable()
			glowstick_mat.setColor(rgb(stick.col_r*255, stick.col_g*255, stick.col_b*255))
			var/obj/item/reactor_component/fuel_rod/glowsticks/result_rod = new /obj/item/reactor_component/fuel_rod/glowsticks(glowstick_mat)
			src.component_grid[x][y]=result_rod
			result_rod.set_loc(src)
			user.u_equip(equipped)
			qdel(equipped)
		else
			src.component_grid[x][y]=equipped
			user.u_equip(equipped)
			equipped.set_loc(src)
		playsound(src, 'sound/machines/law_insert.ogg', 80)
		logTheThing(LOG_STATION, user, "[constructName(user)] <b>inserts</b> component into nuclear reactor([src]): [equipped] at slot [x],[y]")
		user.visible_message(SPAN_ALERT("[user] slides \a [equipped] into the reactor"), SPAN_ALERT("You slide the [equipped] into the reactor."))
		tgui_process.update_uis(src)
		_comp_grid_overlay_update = TRUE
		UpdateGasVolume()
		UpdateIcon()

	proc/remove_comp_callback(var/x,var/y,var/mob/user)
		playsound(src, 'sound/machines/law_remove.ogg', 80)
		logTheThing(LOG_STATION, user, "[constructName(user)] <b>removes</b> component from nuclear reactor([src]): [src.component_grid[x][y]] at slot [x],[y]")
		user.visible_message(SPAN_ALERT("[user] slides \a [src.component_grid[x][y]] out of the reactor"), SPAN_ALERT("You slide the [src.component_grid[x][y]] out of the reactor."))
		user.put_in_hand_or_drop(src.component_grid[x][y])
		src.component_grid[x][y] = null
		tgui_process.update_uis(src)
		_comp_grid_overlay_update = TRUE
		UpdateGasVolume()
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
				logTheThing(LOG_STATION, src, "[src] has been destroyed in an explosion!")

		var/turf/epicentre = get_turf(src)
		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				if(src.component_grid[x][y] && prob(comp_throw_prob))
					if(severity > 1)
						logTheThing(LOG_STATION, src, "a [src.component_grid[x][y]] has been removed from the [src] by an explosion")
						_comp_grid_overlay_update = TRUE
					if(prob(50))
						var/obj/item/reactor_component/throwcomp = src.component_grid[x][y]
						throwcomp.set_loc(epicentre)
						throwcomp.throw_at(get_ranged_target_turf(epicentre,pick(alldirs),rand(1,20)),rand(1,20),rand(1,20))
					else
						qdel(src.component_grid[x][y])
						var/obj/decal/cleanable/debris = make_cleanable(/obj/decal/cleanable/machine_debris/radioactive, epicentre)
						debris.streak_cleanable(dist_upper=20)
					src.component_grid[x][y] = null //get rid of the internal ref once we've thrown it out
		if(_comp_grid_overlay_update)
			UpdateGasVolume()
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
			user.visible_message(SPAN_ALERT("<b>[user] climbs into \the [src] and starts forcing [his_or_her(user)] body down into a channel!</b>"))
			var/list/chosen_slot = pick(free_slots)
			user.set_loc(src)
			SPAWN(1 SECOND)
				playsound(user, 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, TRUE)
				user.emote("scream")
			SPAWN(2.5 SECONDS)
				playsound(user, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, TRUE)
				user.emote("scream")
			SPAWN(4 SECONDS)
				playsound(user, 'sound/impact_sounds/Flesh_Crush_1.ogg', 50, TRUE)
				var/obj/item/reactor_component/fuel_rod/meat_rod = new /obj/item/reactor_component/fuel_rod("flesh")
				meat_rod.material.setName(user.name)
				if(user.bioHolder && user.bioHolder.HasEffect("radioactive"))
					meat_rod.material.setProperty("radioactive", 3)
				meat_rod.setMaterial(meat_rod.material)
				if(src.component_grid[chosen_slot[1]][chosen_slot[2]] == null) //double check, just in case
					src.component_grid[chosen_slot[1]][chosen_slot[2]] = meat_rod //hehe
				else
					meat_rod.throw_at(get_ranged_target_turf(get_turf(src),pick(alldirs),rand(1,20)),rand(1,20),rand(1,20))
				user.set_loc(get_turf(src))
				user.visible_message(SPAN_ALERT("<b>The bits of [user] that didn't fit spray everywhere!</b>"))
				user.gib()
				_comp_grid_overlay_update = TRUE
				UpdateIcon()
			return TRUE
		else
			user.visible_message(SPAN_ALERT("[user] tries to climb into \the [src], but it's full. What a moron!"))
			return FALSE

	/// Transmuting nuclear engine into jeans sometimes causes a client crash
	setMaterial(var/datum/material/mat1, var/appearance = TRUE, var/setname = TRUE, var/mutable = FALSE, var/use_descriptors = FALSE)
		if(mat1.getTexture())
			return
		. = ..()

	return_air(direct = FALSE)
		return air_contents

/datum/neutron //this is literally just a tuple
	var/dir = NORTH
	var/velocity = 1

	New(var/dir,var/velocity)
		..()
		src.dir = dir
		src.velocity = velocity

/obj/machinery/nuclear_reactor/prefilled/normal
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

		//enable for faster debugging
		if(src._debug_mode)
			src.component_grid[4][2] = new /obj/item/reactor_component/fuel_rod("cerenkite")
			src.component_grid[4][4] = new /obj/item/reactor_component/fuel_rod("cerenkite")
			src.component_grid[4][6] = new /obj/item/reactor_component/fuel_rod("cerenkite")


		..()

/obj/machinery/nuclear_reactor/prefilled/random
	New()
		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				switch(rand(1,4))
					if(1)
						src.component_grid[x][y] = new /obj/item/reactor_component/fuel_rod/random_material
					if(2)
						src.component_grid[x][y] = new /obj/item/reactor_component/control_rod/random_material
					if(3)
						src.component_grid[x][y] = new /obj/item/reactor_component/gas_channel/random_material
					if(4)
						src.component_grid[x][y] = new /obj/item/reactor_component/heat_exchanger/random_material
		..()

/obj/machinery/nuclear_reactor/prefilled/meltdown
	New()
		for(var/x=2 to REACTOR_GRID_WIDTH-1)
			for(var/y=2 to REACTOR_GRID_HEIGHT-1)
				if(x==4 && y==4)
					src.component_grid[x][y] = new /obj/item/reactor_component/fuel_rod("plutonium")
				else
					src.component_grid[x][y] = new /obj/item/reactor_component/fuel_rod("cerenkite")
		..()

/obj/machinery/nuclear_reactor/prefilled/insane
	New()
		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				src.component_grid[x][y] = new /obj/item/reactor_component/fuel_rod("plutonium")
				src.component_grid[x][y].melt()
		..()

/obj/machinery/nuclear_reactor/prefilled/glowstick
	New()
		var/datum/material/glowstick_mat = getMaterial("glowstick")
		glowstick_mat = glowstick_mat.getMutable()

		for(var/x=1 to REACTOR_GRID_WIDTH)
			for(var/y=1 to REACTOR_GRID_HEIGHT)
				glowstick_mat.setColor(rgb(rand(0,255), rand(0,255), rand(0,255)))
				src.component_grid[x][y] = new /obj/item/reactor_component/fuel_rod/glowsticks(glowstick_mat)
		..()

#undef REACTOR_GRID_WIDTH
#undef REACTOR_GRID_HEIGHT
#undef REACTOR_TOO_HOT_TEMP
#undef REACTOR_ON_FIRE_TEMP
#undef REACTOR_MELTDOWN_TEMP
/datum/projectile/neutron //neutron projectile for radiation shooting from reactor
	name = "neutron"
	icon_state = "neutron"
	icon = 'icons/obj/projectiles.dmi'
	invisibility = INVIS_INFRA
	override_color = TRUE
	color_icon = "#00FF00"
	power = 100
	cost = 30
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

	New(power=50)
		..()
		src.power = power
		src.ks_ratio = 1
		generate_inverse_stats()

	on_pre_hit(atom/hit, angle, var/obj/projectile/O)
		if(isintangible(hit) || isobserver(hit) || IS_OVERLAY_OR_EFFECT(hit) || istype(hit, /atom/movable/hotspot))
			return TRUE //don't irradiate ghosts, overlays, atmos fires etc.

		var/multiplier = istype(hit,/turf/simulated/wall/auto/reinforced) ? 10 : 5
		var/density = (hit.material ? hit.material.getProperty("density") : 3) //3 is default density

		//first are we colliding with this or ignoring it?
		if(prob(density*multiplier))
			//we hit it! now decide what that hit means
			//first, reflection
			if(hit.material && prob(hit.material.getProperty("hard")*10))
				//reflect
				var/obj/projectile/reflected = shoot_reflected_bounce(O, hit)
				reflected?.power = O.power
				return FALSE

			//then fission
			//fission basically hits like an AoE contamination effect
			if(hit.material && prob(hit.material.getProperty("n_radioactive")*10))
				for(var/turf/T in range(1, hit))
					T.AddComponent(/datum/component/radioactive, 50, TRUE, TRUE, 1)
				return FALSE
			if(hit.material && prob(hit.material.getProperty("radioactive")*10))
				for(var/turf/T in range(1, hit))
					T.AddComponent(/datum/component/radioactive, 50, TRUE, FALSE, 1)
				return FALSE
			//finally, moderation
			hit.AddComponent(/datum/component/radioactive, min(O.power, density*multiplier), TRUE, FALSE, 1) //make it all glowy
			O.power -= density*multiplier
			var/datum/gas_mixture/gasmix = hit.return_air()
			if(O.power < 1)
				O.power = 0
			else if (istype(gasmix) && !ON_COOLDOWN(hit, "world_gas_neutron_interaction", 3 SECONDS))
				var/neutron_count = gasmix.neutron_interact()
				if(neutron_count > 1) //if it returns more than one, new neutrons were created
					for(var/i in 1 to neutron_count)
						shoot_projectile_XY(hit, new /datum/projectile/neutron(rand(5,80)), rand(-10,10), rand(-10,10))
				else if(neutron_count < 1) //less than one, neutron was consumed
					O.power = 0
				// 1 = no reaction

			return TRUE //don't hit this, lose power and pass through it
		return TRUE

	tick(var/obj/projectile/P)
		if(P.power <= 0)
			P.die()
			return
		var/turf/simulated/T = get_turf(P)
		if (issimulatedturf(T) && istype(T.air) && !ON_COOLDOWN(T, "world_gas_neutron_interaction", 3 SECONDS))
			var/neutron_count = T.air.neutron_interact()
			if(neutron_count > 1)
				for(var/i in 1 to neutron_count)
					shoot_projectile_XY(T, new /datum/projectile/neutron(rand(5,80)), rand(-10,10), rand(-10,10))
			else if(neutron_count < 1)
				P.power = 0
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
