// ----------------------------------------------------- //
// Defintion for the turbine used by the nuclear reactor
// This is where the power comes from
// ----------------------------------------------------- //


/obj/machinery/atmospherics/binary/reactor_turbine
	name = "Gas Turbine"
	desc = "A large turbine used for generating power using hot gas."
	icon = 'icons/obj/large/96x160.dmi'
	icon_state = "turbine_main"
	anchored = ANCHORED
	density = 1
	bound_width = 96
	bound_height = 160
	pixel_x = -32
	pixel_y = -32
	bound_x = -32
	bound_y = -32
	dir = EAST
	custom_suicide = TRUE
	machine_registry_idx = MACHINES_FISSION
	/// Reference to the power terminal we use to dump power onto the net
	var/obj/machinery/power/terminal/terminal = null
	/// ID of this object on the pnet
	var/net_id = null
	/// How much power we generated last tick
	var/lastgen = 0
	/// Stator load is basically watts per revolution
	var/stator_load = 10000
	/// Current RPM of the turbing
	var/RPM = 0
	/// Calibration factor which determines how much inertia the turbine has - ie, resistance to change in RPM
	var/turbine_mass = 1000
	/// most efficient power generation at this value, overspeed at 1.2*this
	var/best_RPM = 600
	/// Volume of gas to process per tick for power generation
	var/flow_rate = 200

	var/static/sound_stall = 'sound/machines/tractor_running.ogg'
	var/static/list/grump_sound_list = list('sound/machines/engine_grump1.ogg','sound/machines/engine_grump2.ogg','sound/machines/engine_grump3.ogg', 'sound/impact_sounds/Metal_Clang_1.ogg', 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg')

	/// Flag for indicating that energy available is less than needed to turn the turbine
	var/stalling = FALSE
	/// Flag for RPM being > best_RPM*1.2
	var/overspeed = FALSE
	/// Flag for gas temperature being > 3000K
	var/overtemp = FALSE
	/// Flag for gas temperature being < T20C
	var/undertemp = FALSE
	/// INTERNAL: used to determine whether an icon update is required
	VAR_PRIVATE/_last_rpm_icon_update = 0
	/// INTERNAL: ref to the turf the turbine light is stored on, because you can't center simple lights
	VAR_PRIVATE/turf/_light_turf
	/// Turbine RPM/powergen/stator load history
	var/list/history
	var/const/history_max = 50
	/// Current gas for processing
	var/datum/gas_mixture/air_contents
	/// bodge factor for power generation
	var/power_multiplier = 1

	New()
		. = ..()
		terminal = new /obj/machinery/power/terminal/netlink(src.loc)
		src.net_id = generate_net_id(src)
		terminal.set_dir(turn(src.dir,-90))
		terminal.master = src
		src._light_turf = get_turf(src)
		src._light_turf.add_medium_light("turbine_light", list(255,255,255,255))
		//Prevents unreachable turfs from being damaged, so as not to ruin engineer rounds
		for(var/turf/simulated/floor/F in src.locs)
			F.explosion_immune = TRUE
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Stator Load", PROC_REF(_set_statorload_mechchomp))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Flow Rate", PROC_REF(_set_flowrate_mechchomp))
		src.history = list()

	disposing()
		src._light_turf?.remove_medium_light("turbine_light")
		new /obj/fakeobject/turbine_destroyed(src.loc)
		for(var/turf/simulated/floor/F in src.locs) //restore the explosion immune state of the original turf
			F.explosion_immune = initial(F.explosion_immune)
		. = ..()

	setMaterial(var/datum/material/mat1, var/appearance = TRUE, var/setname = TRUE, var/mutable = FALSE, var/use_descriptors = FALSE)
		if(mat1.getTexture()) //sigh
			return
		. = ..()

	proc/_set_statorload_mechchomp(var/datum/mechanicsMessage/inp)
		if(!length(inp.signal)) return
		var/newload = text2num(inp.signal)
		if(newload != src.stator_load && isnum_safe(newload) && newload > 0)
			src.stator_load = newload
			logTheThing(LOG_STATION, src, "set stator load to [newload] using mechcomp.")

	proc/_set_flowrate_mechchomp(var/datum/mechanicsMessage/inp)
		if(!length(inp.signal)) return
		var/newflow = text2num(inp.signal)
		if(newflow != src.flow_rate && isnum_safe(newflow) && newflow > 0)
			src.flow_rate = newflow
			logTheThing(LOG_STATION, src, "set flow rate to [newflow] using mechcomp.")


	//override the atmos/binary connection code, because it doesn't like big icons
	initialize()
		if(node1 && node2) return

		var/node2_connect = dir
		var/node1_connect = turn(dir, 180)

		for(var/obj/machinery/atmospherics/pipe/simple/target in get_steps(src,node1_connect,2))
			if(target.initialize_directions & node2_connect)
				if(target != src)
					node1 = target
					break

		for(var/obj/machinery/atmospherics/pipe/simple/target in get_steps(src,node2_connect,2))
			if(target.initialize_directions & node1_connect)
				if(target != src)
					node2 = target
					break

		UpdateIcon()

	proc/generate_icon()
		//this is mildly cursed, I am sorry
		var/icon/base_icon = new(initial(src.icon), "turbine_spin")
		var/icon/result_icon = new(initial(src.icon), "turbine_spin")
		result_icon.Insert(base_icon, "turbine_spin_speed", delay=max(2*(src.best_RPM/(8*src.RPM)), 0.125))
		return result_icon

	process()
		. = ..()
		if (length(src.history) > src.history_max)
			src.history.Cut(1, 2) //drop the oldest entry
		history += list(
					list(
						src.RPM,
						src.stator_load,
						src.lastgen
						)
					)
		if(src.RPM < 1)
			src._last_rpm_icon_update = -100 //force an update as soon as it starts moving
			if(src.icon_state != "turbine_main")
				src.icon = initial(src.icon)
				src.icon_state = "turbine_main"
				UpdateIcon()
		else
			if(abs(src._last_rpm_icon_update - src.RPM) > 10)
				src._last_rpm_icon_update = src.RPM
				// reduce image flicker while clients download the generated icon
				var/image/old_icon
				if(src.icon_state == "turbine_spin_speed")
					old_icon = src.SafeGetOverlayImage("old_icon", src.icon, "turbine_spin_speed", src.layer-0.1)
				else
					old_icon = src.SafeGetOverlayImage("old_icon", src.icon, "turbine_main", src.layer-0.1)
				src.AddOverlays(old_icon, "old_icon")
				SPAWN(0.5 SECONDS)
					src.ClearSpecificOverlays("old_icon")
				src.icon = src.generate_icon()
				src.icon_state = "turbine_spin_speed"
				UpdateIcon()


		var/input_starting_pressure = MIXTURE_PRESSURE(air1)

		//RPM - generate ideal power at 600RPM
		//Stator load - how much are we trying to slow the RPM
		//Energy generated = stator load * RPM
		var/transfer_moles = 0
		if(input_starting_pressure)
			transfer_moles = (air1.volume*input_starting_pressure)/(R_IDEAL_GAS_EQUATION*air1.temperature)
		air_contents =  air1.remove(transfer_moles)
		src.lastgen = 0
		src.overtemp = (air_contents?.temperature > 2500)
		src.undertemp = (air_contents?.temperature < T20C)
		if(air_contents?.temperature > 3000)
			//overheat
			src.assume_air(air_contents)
			if(!ON_COOLDOWN(src, "turbine_overheat_alarm", 10 SECOND))
				src.audible_message(SPAN_ALERT("[src] triggers the emergency overheat dump valve!"))
				playsound(src.loc, 'sound/misc/klaxon.ogg', 40, pitch=1.1)

			src.air2.merge(air_contents)
			ZERO_GASES(air_contents) //prevent power from being generated by the 1atmos of hot gas
		if(air_contents)
			var/input_starting_energy = THERMAL_ENERGY(air_contents)
			var/input_heat_cap = HEAT_CAPACITY(air_contents)
			if(input_starting_energy <= 0)
				input_starting_energy = 1 //runtime protection for weirdly empty gas packets
			if(input_heat_cap <= 0)
				input_heat_cap = 1
			if(air_contents.temperature > T20C) //only operate on the gas if it's above min temp
				air_contents.temperature = round(max((input_starting_energy - ((input_starting_energy - (input_heat_cap*T20C))*0.8))/input_heat_cap,T20C),0.01) //fucking rounding errors
			var/output_starting_energy = THERMAL_ENERGY(air_contents)
			var/energy_generated = src.stator_load*(src.RPM/60)

			var/delta_E = (input_starting_energy - output_starting_energy)
			//|a + v| = sqrt(2k/m)
			var/newRPM = 0
			if((delta_E - energy_generated) > 0)
				newRPM = src.RPM + sqrt(2*(max(delta_E - energy_generated,0))/turbine_mass)
			else
				newRPM = src.RPM - sqrt(2*(max(energy_generated - delta_E,0))/turbine_mass)

			var/nextgen = src.stator_load*(max(newRPM,0)/60)
			var/nextRPM = 0
			if((delta_E - nextgen) > 0)
				nextRPM = max(newRPM,0) + sqrt(2*(max(delta_E - nextgen,0))/turbine_mass)
			else
				nextRPM = max(newRPM,0) - sqrt(2*(max(nextgen - delta_E,0))/turbine_mass)

			if((newRPM < 0) || (nextRPM < 0))
				//stator load is too high
				src.stalling = TRUE
				src.RPM = 0

				playsound(src.loc, sound_stall, 60, 0)
			else
				src.stalling = FALSE
				src.RPM = nextRPM

			src.lastgen = src.power_multiplier * src.stator_load*(src.RPM/60) * sech((0.01*(src.RPM-src.best_RPM)))
			if(isnan(src.lastgen))
				CRASH("NaN power generated by turbine")
			src.overspeed = (src.RPM > src.best_RPM*1.2)
			if(overspeed && prob(40))
				hit_twitch(src)
				playsound(src, pick(src.grump_sound_list), 40, 2*rand())

			src.air2.merge(air_contents)
			src.terminal.add_avail(src.lastgen)

			src.air1.volume = src.flow_rate
			src.air_contents.volume = src.flow_rate

			src.network1?.update = TRUE
			src.network2?.update = TRUE
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "rpm=[src.RPM]&stator=[src.stator_load]&power=[src.lastgen]&powerfmt=[engineering_notation(src.lastgen)]W")

	suicide(mob/user)
		user.visible_message(SPAN_ALERT("<b>[user] puts their head into blades of \the [src]!</b>"))
		switch(src.RPM)
			if(0 to 1)
				SPAWN(1 SECOND) //little delay for comedic effect
					user.visible_message(SPAN_ALERT("...but the blades of \the [src] aren't moving, so [user] just looks like an idiot."))
				return FALSE
			if(0 to 60)
				user.visible_message(SPAN_ALERT("...but the blades of \the [src] are barely moving, so [user] just receives a bonk on the head."))
				user.TakeDamageAccountArmor("head", ceil(src.RPM/6), 0, 0, DAMAGE_BLUNT)
				user.changeStatus("stunned", 3 SECONDS)
				return FALSE
			if(60 to 100)
				user.visible_message(SPAN_ALERT("<b>The blades of \the [src] hit [user] with some force, giving them a nasty cut.</b>"))
				user.TakeDamageAccountArmor("head", src.RPM, 0, 0, DAMAGE_STAB)
				user.changeStatus("stunned", 6 SECONDS)
				user.changeStatus("knockdown", 3 SECONDS)
				return FALSE
			if(100 to INFINITY)
				user.visible_message(SPAN_ALERT("<b>The blades of \the [src] decapitate [user] instantly!</b>"))
				if(isliving(user))
					var/mob/living/suicider = user
					var/obj/item/organ/head = suicider.organHolder.drop_organ("head")
					head.splat(get_turf(user))
					qdel(head)
				else
					user.TakeDamage("head", 200, 0, 0, DAMAGE_CRUSH)
				return TRUE

	return_air(direct = FALSE)
		return air_contents

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "TurbineControl", src.name)
			ui.open()

	ui_static_data(mob/user)
		. = list(
		)

	ui_data(mob/user)
		. = list(
			"rpm" = src.RPM,
			"load" = src.stator_load,
			"power" = src.lastgen,
			"volume" = src.flow_rate,
			"history" = src.history,
			"overspeed" = src.overspeed,
			"overtemp" = src.overtemp,
			"undertemp" = src.undertemp,
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		if(..()) return

		switch(action)
			if("loadChange")
				var/x = params["newVal"]
				src.stator_load = min(max(x,1),10e30)
				logTheThing(LOG_STATION, src, "[src] stator load configured to [x] by [ui.user]")
			if("volChange")
				var/x = params["newVal"]
				src.flow_rate = min(max(x,1),10e5)
				logTheThing(LOG_STATION, src, "[src] flow rate configured to [x] by [ui.user]")
