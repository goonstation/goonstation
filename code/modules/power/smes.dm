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
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = 1
	anchored = 1
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
		dir = idir
		var/turf/Q = get_step(iloc, idir)
		if (!Q)
			qdel(src)
			var/obj/machinery/power/terminal/term = new /obj/machinery/power/terminal(Q)
			term.dir = get_dir(Q, iloc)
		..()

/obj/machinery/power/smes/emp_act()
	..()
	src.online = 0
	src.charging = 0
	src.output = 0
	src.charge -= 1e6
	if (src.charge < 0)
		src.charge = 0
	SPAWN_DBG(10 SECONDS)
		src.output = initial(src.output)
		src.charging = initial(src.charging)
		src.online = initial(src.online)
	return

/obj/machinery/power/smes/New()
	..()

	SPAWN_DBG(0.5 SECONDS)
		dir_loop:
			for(var/d in cardinal)
				var/turf/T = get_step(src, d)
				for(var/obj/machinery/power/terminal/term in T)
					if (term && term.dir == turn(d, 180))
						terminal = term
						break dir_loop

		if (!terminal)
			status |= BROKEN
			return

		terminal.master = src

		updateicon()


/obj/machinery/power/smes/proc/updateicon()

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

/obj/machinery/power/smes/process()

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

				charge += load	// increase the charge
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
			SPAWN_DBG(1 DECI SECOND)
				playsound(src.loc, pick(ambience_power), 60, 1)

		lastout = min(charge, output)		//limit output to that stored

		charge -= lastout		// reduce the storage (may be recovered in /restore() if excessive)

		add_avail(lastout)				// add output to powernet (smes side)

		if (charge < 0.0001)
			online = 0					// stop output if charge falls to zero

	// only update icon if state changed
	if (last_disp != chargedisplay() || last_chrg != charging || last_onln != online)
		updateicon()

	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.interacted(M)
	AutoUpdateAI(src)

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
		updateicon()


///obj/machinery/power/smes/add_avail(var/amount)
//	if (terminal && terminal.powernet)
//		terminal.powernet.newavail += amount

/obj/machinery/power/smes/add_load(var/amount)
	if (terminal && terminal.powernet)
		terminal.powernet.newload += amount

/obj/machinery/power/smes/attack_ai(mob/user)

	add_fingerprint(user)

	if (status & BROKEN) return

	interacted(user)

/obj/machinery/power/smes/attack_hand(mob/user)

	add_fingerprint(user)

	if (status & BROKEN) return

	interacted(user)



/obj/machinery/power/smes/proc/interacted(mob/user)

	if ( (get_dist(src, user) > 1 ))
		if (!isAI(user) && !issilicon(user))
			user.machine = null
			user.Browse(null, "window=smes")
			return

	user.machine = src

	// @todo fix this later
	var/t = {"
<title>SMES Status [n_tag ? " - [n_tag]" : null]</title>
<style type="text/css">
	h3, h4 {
		margin: 0;
	}

	#powerMenu > div {
		box-sizing: border-box;
	}

	.bar {
		height: 8px;
		max-height: 8px;
		background: #363;
		border: 1px solid white;
		padding: 1px;
		position: relative;
		margin: 0.25em 0;
	}

	.bar .inner {
		height: 100%;
		margin: 0;
		padding: 0;
		background: #4e4;
	}

	.bar .marker {
		position: absolute;
		top: 0px;
		width: 1px;
		margin-left: -1px;
		height: 40%;
		background: white;
		border: 1px solid black;
		border-top: none;
	}

	p {
		margin: 0.25em 0;
	}
</style>
<div id="#powerMenu">
<h3 style="text-align: center;">SMES Power Storage Unit [n_tag ? "- [n_tag]" : null]</h3>
<br>
	<strong>Stored Charge: [round(100.0*charge/capacity, 0.1)]%</strong> <em>([charging ? "Charging" : ((chargecount > 0) ? "Preparing to charge..." : "Not Charging")])</em>
	<div class='bar'><div class='inner' style="width: [round(100 * (charge / capacity), 0.01)]%;"></div></div>
<br>
	<strong>Charging:</strong> [chargemode ? "<b>Enabled</b> (<a href='?src=\ref[src];cmode=1'>Disable</a>)" : "<b>Disabled</b> (<a href='?src=\ref[src];cmode=1'>Enable</a>)"]
	<br><strong>Input level:</strong> <a href='?src=\ref[src];input=set'>[chargelevel]</a> (<a href='?src=\ref[src];input=min'>Min</a> &middot; <a href='?src=\ref[src];input=max'>Max</a>)
	<div class='bar-outer'><div class='bar'><div class='inner' style="width: [max(0, min(100, round(100 * (lastexcess / SMESMAXCHARGELEVEL), 0.01)))]%;"></div><div class='marker' style="left: [round(100 * (chargelevel / SMESMAXCHARGELEVEL), 0.01)]%;"></div></div>
	<strong>Available:</strong> [round(lastexcess)] W
<br>
<br>
	<strong>Output:</strong> [online ? "<b>Enabled</b> (<a href='?src=\ref[src];online=1'>Disable</a>)" : "<b>Disabled</b> (<a href='?src=\ref[src];online=1'>Enable</a>)"]
	<br><strong>Output level:</strong> <a href='?src=\ref[src];output=set'>[output]</a> (<a href='?src=\ref[src];output=min'>Min</a> &middot; <a href='?src=\ref[src];output=max'>Max</a>)
	<div class='bar'><div class='inner' style="width: [min(100, round(100 * (loaddemand / SMESMAXOUTPUT), 0.01))]%;"></div><div class='marker' style="left: [round(100 * (output / SMESMAXCHARGELEVEL), 0.01)]%;"></div></div>
	<strong>Current load:</strong> [round(loaddemand)] W
</div>
"}

	user.Browse(t, "window=smes;size=400x340")
	onclose(user, "smes")
	return

/obj/machinery/power/smes/Topic(href, href_list)
	..()

	if (usr.stat || usr.restrained() )
		return

	if (( usr.machine==src && ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (isAI(usr) || issilicon(usr)))
		if (href_list["close"])
			usr.Browse(null, "window=smes")
			usr.machine = null
			return

		else if ( href_list["cmode"] )
			chargemode = !chargemode
			if (!chargemode)
				charging = 0
			updateicon()

		else if ( href_list["online"] )
			online = !online
			updateicon()
		else if (href_list["input"])
			switch (href_list["input"])
				if ("min")
					chargelevel = 0
				if ("max")
					chargelevel = SMESMAXCHARGELEVEL
				if ("set")
					var/newnum = input(usr, "New target charge level? 0 to [SMESMAXCHARGELEVEL].", "SMES Config", chargelevel) as null|num
					if (newnum)
						chargelevel	= newnum

			chargelevel = max(0, min(SMESMAXCHARGELEVEL, chargelevel))	// clamp to range

		else if (href_list["output"])
			switch (href_list["output"])
				if ("min")
					output = 0
				if ("max")
					output = SMESMAXOUTPUT
				if ("set")
					var/newnum = input(usr, "New output level? 0 to [SMESMAXOUTPUT].", "SMES Config", output) as null|num
					if (newnum)
						output = newnum

			output = max(0, min(SMESMAXOUTPUT, output))	// clamp to range


		src.updateUsrDialog()

	else
		usr.Browse(null, "window=smes")
		usr.machine = null

	return

/proc/rate_control(var/S, var/V, var/C, var/Min=1, var/Max=5, var/Limit=null)
	var/href = "<A href='?src=\ref[S];rate control=1;[V]"
	var/rate = "[href]=-[Max]'>-</A>[href]=-[Min]'>-</A> [(C?C : 0)] [href]=[Min]'>+</A>[href]=[Max]'>+</A>"
	if (Limit) return "[href]=-[Limit]'>-</A>"+rate+"[href]=[Limit]'>+</A>"
	return rate

#undef SMESMAXCHARGELEVEL
#undef SMESMAXOUTPUT
