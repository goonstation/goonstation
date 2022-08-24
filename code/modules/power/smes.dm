// the SMES
// stores power

#define SMESMAXCHARGELEVEL 200000
#define SMESMAXOUTPUT 200000

/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power, using magic."
	process()
		capacity = INFINITY
		charge = INFINITY
		..()

/obj/machinery/power/smes
	name = "Dianmu power storage unit"
	desc = "The XIANG|GIESEL model '電母' high-capacity superconducting magnetic energy storage (SMES) unit. Acts as a giant capacitor for facility power grids, soaking up extra power or dishing it out."
	icon_state = "smes"
	density = 1
	anchored = 1
	requires_power = FALSE
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
	New(var/turf/iloc, var/idir = 2)
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

/obj/machinery/power/smes/proc/chargedisplay()
	return round(5.5*charge/capacity)

/obj/machinery/power/smes/process(mult)

	if (status & BROKEN)
		return


	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_chrg = charging
	var/last_onln = online

	// Had to revert a hack here that caused SMES to continue charging despite insufficient power coming in on the input (terminal) side.
	if (terminal)
		var/excess = terminal.surplus()
		var/load = 0
		if (charging)
			if (excess >= 0)		// if there's power available, try to charge

				load = min(capacity-charge, chargelevel)		// charge at set rate, limited to spare capacity

				// Adjusting mult to other power sources would likely cause more harm than good as it would cause unusual surges
				// of power that would only be noticed though hotwire or be unrationalizable to player.  This will extrapolate power
				// benefits to charged value so that minimal loss occurs.
				charge += load * mult	// increase the charge
				add_load(load)		// add the load to the terminal side network

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

	src.updateDialog()

// called after all power processes are finished
// restores charge level to smes if there was excess this ptick

/obj/machinery/power/smes/proc/restore()
	if (status & BROKEN)
		return

	if (!online)
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


///obj/machinery/power/smes/add_avail(var/amount)
//	if (terminal?.powernet)
//		terminal.powernet.newavail += amount

/obj/machinery/power/smes/add_load(var/amount)
	if (terminal?.powernet)
		terminal.powernet.newload += amount

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

/proc/rate_control(var/S, var/V, var/C, var/Min=1, var/Max=5, var/Limit=null)
	var/href = "<A href='?src=\ref[S];rate control=1;[V]"
	var/rate = "[href]=-[Max]'>-</A>[href]=-[Min]'>-</A> [(C?C : 0)] [href]=[Min]'>+</A>[href]=[Max]'>+</A>"
	if (Limit) return "[href]=-[Limit]'>-</A>"+rate+"[href]=[Limit]'>+</A>"
	return rate

#undef SMESMAXCHARGELEVEL
#undef SMESMAXOUTPUT
