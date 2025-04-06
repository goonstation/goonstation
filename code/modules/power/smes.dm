// the SMES
// stores power

#define SMESMAXCHARGELEVEL 200000
#define SMESMAXOUTPUT 200000

TYPEINFO(/obj/machinery/power/smes/magical)
	mats = null
/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power, using magic."
	deconstruct_flags = DECON_NONE
	process()
		capacity = INFINITY
		charge = INFINITY
		..()

	set_broken()
		return TRUE

TYPEINFO(/obj/machinery/power/smes)
	mats = list("metal" = 40,
				"conductive_high" = 30,
				"energy_extreme" = 30)
/obj/machinery/power/smes
	name = "Dianmu power storage unit"
	desc = "The XIANG|GIESEL model '電母' high-capacity superconducting magnetic energy storage (SMES) unit. Acts as a giant capacitor for facility power grids, soaking up extra power or dishing it out."
	icon_state = "smes"
	density = 1
	anchored = ANCHORED
	requires_power = FALSE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL | DECON_CROWBAR | DECON_WELDER
	var/output = 30000
	var/lastout = 0
	var/loaddemand = 0
	var/capacity = 1e8
	var/charge = 2e7
	var/charging = 0
	var/chargemode = 1
	var/chargecount = 0
	var/chargelevel = 30000
	var/lastexcess = 0
	var/online = 1
	var/n_tag = null
	var/obj/machinery/power/terminal/terminal = null

	get_desc()
		. = {"It's [online ? "on" : "off"]line. [charging ? "It's charging, and it" : "It"] looks about [round(charge / capacity * 100, 20)]% full."}

/obj/machinery/power/smes/construction
	New(var/turf/iloc, var/idir = SOUTH)
		if (!isturf(iloc))
			qdel(src)
		set_dir(idir)
		var/turf/Q = get_step(iloc, idir)
		if (!Q)
			qdel(src)
			var/obj/machinery/power/terminal/term = new /obj/machinery/power/terminal(Q)
			term.set_dir(get_dir(Q, iloc))
		..()

/obj/machinery/power/smes/emp_act()
	..()
	src.online = 0
	src.charging = 0
	src.output = 0
	src.charge -= 1e6
	if (src.charge < 0)
		src.charge = 0
	SPAWN(10 SECONDS)
		src.output = initial(src.output)
		src.charging = initial(src.charging)
		src.online = initial(src.online)
	return

/obj/machinery/power/smes/New()
	..()

	SPAWN(0.5 SECONDS)
		dir_loop:
			for(var/d in cardinal)
				var/turf/T = get_step(src, d)
				for(var/obj/machinery/power/terminal/term in T)
					if (term?.dir == turn(d, 180))
						terminal = term
						break dir_loop

		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Toggle Power Input", PROC_REF(_toggle_input_mechchomp))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Power Input", PROC_REF(_set_input_mechchomp))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Togle Power Output", PROC_REF(_toggle_output_mechchomp))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Power Output", PROC_REF(_set_output_mechchomp))

		if (!terminal)
			status |= BROKEN
			return

		terminal.master = src

		UpdateIcon()


/obj/machinery/power/smes/update_icon()
	if (status & BROKEN)
		ClearAllOverlays()
		return

	var/image/I = SafeGetOverlayImage("operating", 'icons/obj/power.dmi', "smes-op[online]")
	UpdateOverlays(I, "operating")

	I = SafeGetOverlayImage("chargemode",'icons/obj/power.dmi', "smes-oc1")
	if (charging)
		I.icon_state = "smes-oc1"

	else if (chargemode)
		I.icon_state = "smes-oc0"
	else
		I = null

	UpdateOverlays(I, "chargemode", 0, 1)

	var/clevel = chargedisplay()
	if (clevel>0)
		I = SafeGetOverlayImage("chargedisp",'icons/obj/power.dmi',"smes-og[clevel]")
		UpdateOverlays(I, "chargedisp")

/obj/machinery/power/smes/set_broken()
	if(..()) return
	AddComponent(/datum/component/equipment_fault/dangerously_shorted, tool_flags = TOOL_WIRING | TOOL_SOLDERING | TOOL_WRENCHING | TOOL_SCREWING | TOOL_PRYING)

/obj/machinery/power/smes/ex_act(severity)
	. = ..()
	if (QDELETED(src))
		return
	switch(severity)
		if(2)
			if (prob(25))
				src.set_broken()
				return
		if(3)
			if (prob(20))
				src.set_broken()

/obj/machinery/power/smes/proc/chargedisplay()
	return round(5.5*charge/capacity)

/obj/machinery/power/smes/proc/_toggle_input_mechchomp()
	src.chargemode = !src.chargemode
	if (!chargemode)
		charging = 0
	src.UpdateIcon()

/obj/machinery/power/smes/proc/_set_input_mechchomp(var/datum/mechanicsMessage/inp)
	if(!length(inp.signal)) return
	var/newinput = text2num(inp.signal)
	if(newinput != src.chargelevel && isnum_safe(newinput))
		src.chargelevel = clamp((newinput), 0 , SMESMAXCHARGELEVEL)

/obj/machinery/power/smes/proc/_toggle_output_mechchomp()
	src.online = !src.online
	src.UpdateIcon()

/obj/machinery/power/smes/proc/_set_output_mechchomp(var/datum/mechanicsMessage/inp)
	if(!length(inp.signal)) return
	var/newoutput = text2num(inp.signal)
	if(newoutput != src.output && isnum_safe(newoutput))
		src.output = clamp((newoutput), 0 , SMESMAXCHARGELEVEL)

/obj/machinery/power/smes/process(mult)

	if (status & BROKEN)
		return


	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_chrg = charging
	var/last_onln = online

	// Had to revert a hack here that caused SMES to continue charging despite insufficient power coming in on the input (terminal) side.
	if (terminal)
		charge(mult)

	if (online)		// if outputting
		if (prob(5))
			SPAWN(1 DECI SECOND)
				playsound(src.loc, pick(ambience_power), 60, 1)

		lastout = min(charge, output)		//limit output to that stored

		charge -= lastout		// reduce the storage (may be recovered in /restore() if excessive)

		add_avail(lastout)				// add output to powernet (smes side)

		if (charge < 0.0001)
			online = 0					// stop output if charge falls to zero

	// only update icon if state changed
	if (last_disp != chargedisplay() || last_chrg != charging || last_onln != online)
		UpdateIcon()

	SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "output=[src.output]&outputting=[src.online]&charge=[src.chargelevel]&charging=[src.chargemode]")
	src.updateDialog()

/obj/machinery/power/smes/proc/charge(mult)
	var/excess = terminal.surplus()
	var/load = 0
	if (charging)
		if (excess >= 0)		// if there's power available, try to charge

			load = min(capacity-charge, chargelevel)		// charge at set rate, limited to spare capacity

			// Adjusting mult to other power sources would likely cause more harm than good as it would cause unusual surges
			// of power that would only be noticed though hotwire or be unrationalizable to player.  This will extrapolate power
			// benefits to charged value so that minimal loss occurs.
			if(terminal.add_load(load))			// add the load to the terminal side network
				charge += load * mult	// increase the charge if successful

		else					// if not enough capcity
			charging = 0		// stop charging
			chargecount  = 0

	else if (chargemode)
		if (chargecount > 2)
			charging = 1
			chargecount = 0
		else if (excess >= chargelevel)
			chargecount++
		else
			chargecount = 0

	lastexcess = load + excess

// called after all power processes are finished
// restores charge level to smes if there was excess this ptick

/obj/machinery/power/smes/proc/restore()
	if (status & BROKEN)
		return

	if (!online || isnull(powernet))
		loaddemand = 0
		return

	var/excess = powernet.netexcess		// this was how much wasn't used on the network last ptick, minus any removed by other SMESes

	excess = min(lastout, excess)				// clamp it to how much was actually output by this SMES last ptick

	excess = min(capacity-charge, excess)	// for safety, also limit recharge by space capacity of SMES (shouldn't happen)

	// now recharge this amount

	var/clev = chargedisplay()

	charge += excess
	powernet.netexcess -= excess		// remove the excess from the powernet, so later SMESes don't try to use it

	loaddemand = lastout - excess

	if (clev != chargedisplay())
		UpdateIcon()

/obj/machinery/power/smes/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smes", src.name)
		ui.open()

/obj/machinery/power/smes/ui_static_data(mob/user)
	. = list(
		"inputLevelMax" = SMESMAXCHARGELEVEL,
		"outputLevelMax" = SMESMAXOUTPUT,
	)

/obj/machinery/power/smes/ui_data(mob/user)
	. = list(
		"capacity" = src.capacity,
		"charge" = src.charge,

		"inputAttempt" = src.chargemode,
		"inputting" = src.charging,
		"inputLevel" = src.chargelevel,
		"inputAvailable" = src.lastexcess,

		"outputAttempt" = src.online,
		"outputting" = src.loaddemand,
		"outputLevel" = src.output,
	)

/obj/machinery/power/smes/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch(action)
		if("toggle-input")
			src.chargemode = !src.chargemode
			if (!chargemode)
				charging = 0
			src.UpdateIcon()
			. = TRUE
		if("toggle-output")
			src.online = !src.online
			src.UpdateIcon()
			. = TRUE
		if("set-input")
			var/target = params["target"]
			var/adjust = params["adjust"]
			if(target == "min")
				src.chargelevel = 0
				. = TRUE
			else if(target == "max")
				src.chargelevel = SMESMAXCHARGELEVEL
				. = TRUE
			else if(adjust)
				src.chargelevel = clamp((src.chargelevel + adjust), 0 , SMESMAXCHARGELEVEL)
				. = TRUE
			else if(text2num_safe(target) != null) //set by drag
				src.chargelevel = clamp(text2num_safe(target), 0 , SMESMAXCHARGELEVEL)
				. = TRUE
		if("set-output")
			var/target = params["target"]
			var/adjust = params["adjust"]
			if(target == "min")
				src.output = 0
				. = TRUE
			else if(target == "max")
				src.output = SMESMAXOUTPUT
				. = TRUE
			else if(adjust)
				src.output = clamp((src.output + adjust), 0 , SMESMAXOUTPUT)
				. = TRUE
			else if(text2num_safe(target) != null) //set by drag
				src.output = clamp(text2num_safe(target), 0 , SMESMAXOUTPUT)
				. = TRUE

/obj/machinery/power/smes/smart
	name = "Dianmu smart power storage unit"
	icon_state = "smes_smart"
	capacity = 1e7
	charge = 15e5


/obj/machinery/power/smes/smart/charge(mult)
	var/excess = terminal.surplus()
	var/load = 0
	if (charging)
		if (excess >= 0)		// if there's power available, try to charge

			load = min(capacity-charge, chargelevel)		// charge at set rate, limited to spare capacity

			// Adjusting mult to other power sources would likely cause more harm than good as it would cause unusual surges
			// of power that would only be noticed though hotwire or be unrationalizable to player.  This will extrapolate power
			// benefits to charged value so that minimal loss occurs.
			if(terminal.add_load(load))			// attempt to add the load to the terminal side network
				charge += load * mult	// increase the charge if successful

			// Simulate bad PID
			var/adjust = 0
			if(excess < 15 KILO WATTS)
				adjust = -5 KILO WATTS
			if(excess > 30 KILO WATTS)
				adjust = 5 KILO WATTS
			if(adjust)
				adjust += rand(-3 KILO WATTS, 3 KILO WATTS)
				src.chargelevel = clamp((src.chargelevel + adjust), 0 , SMESMAXCHARGELEVEL)
		else					// if not enough capcity
			charging = 0		// stop charging
			chargecount  = 0
			src.chargelevel = round(chargelevel*0.7)

	else if (chargemode)
		if (chargecount > 1)
			charging = 1
			chargecount = 0
		else if (excess >= chargelevel)
			chargecount++
		else
			chargecount = 0
			src.chargelevel = round(chargelevel*0.5)

	lastexcess = load + excess

#undef SMESMAXCHARGELEVEL
#undef SMESMAXOUTPUT
