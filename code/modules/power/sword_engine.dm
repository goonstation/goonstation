//The SWORD Engine.
//Essentially it should be a better, movable SMES with a removable core.
//However, as my knowledge of engineering is quite subpar, I will leave this in it's current, unfinished state - it doesn't work, although the UI is interactable.
//Someone with a larger affinity than me for such technological exploits can attempt to "restore" the engine to a functional form.
//For now, it will merely exist as a quasi-functional loot source. As in, people can extract the core from it for other purposes.
//I am disappointed in myself for not pushing forward enough to understand and finish what I've started, but I've been feeling more and more drained recently so I'd rather leave this to a "professional". Sorry.

#define SEMAXCHARGELEVEL 400000
#define SEMAXOUTPUT 400000

/obj/machinery/power/sword_engine
	name = "SWORD Engine"
	desc = "An odd-looking machine, covered in mangled metal."
	icon = 'icons/misc/retribution/SWORD_loot.dmi'
	icon_state = "engine_mangled"
	density = 1
	anchored = 0
	requires_power = FALSE
	var/output = 30000
	var/lastout = 0
	var/loaddemand = 0
	var/capacity = 2e8
	var/charge = 4e7
	var/charging = 0
	var/chargemode = 1
	var/chargecount = 0
	var/chargelevel = 30000
	var/lastexcess = 0
	var/online = 0
	var/integrity_state = 0		//0 - covered in mangled metal. 1 - normal, panel closed. 2 - normal, panel open.
	var/core_inserted = true
	var/obj/machinery/power/terminal/terminal = null
	var/image/glow
	var/image/core

	get_desc()
		. = {"It's [online ? "on" : "off"]line. [charging ? "It's charging, and it" : "It"] looks about [round(charge / capacity * 100, 20)]% full. [integrity_state ? "This engine, even with the metal debris removed, seems nigh unfixable" : "It looks quite broken"]. [core_inserted ? "It would be wise to repurpose it's core for something else, as it's still intact" : "The core is missing.."]."}


/obj/machinery/power/sword_engine/attackby(obj/item/W, mob/user)
	if (integrity_state == 0 && isweldingtool(W) && W:try_weld(user,1))
		boutput(user, "<span class='notice'>You removed the mangled metal from the SWORD Engine!</span>")
		desc = "The remains of the SWORD's Engine, salvaged to work as a better SMES unit. The core is installed."
		var/obj/item/material_piece/iridiumalloy/A = new /obj/item/material_piece/iridiumalloy(get_turf(src))
		A.amount = 1
		integrity_state = 1
		online = 0
		charging = 0
		UpdateIcon()

	else if (isscrewingtool(W))
		if(integrity_state == 0)
			boutput(user, "<span class='notice'>Pieces of mangled metal make screwing off the panel impossible!</span>")
			return
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		var/action_buffer = 0
		if(integrity_state == 1)
			boutput(user, "<span class='notice'>You unscrew the panel!</span>")
			integrity_state = 2
			action_buffer++
		if(integrity_state == 2 && action_buffer == 0)
			boutput(user, "<span class='notice'>You screw the panel back!</span>")
			integrity_state = 1
		UpdateIcon()

	else if (iswrenchingtool(W))
		if(integrity_state == 0)
			boutput(user, "<span class='notice'>Pieces of mangled metal make anchoring impossible!</span>")
			return
		if (!istype(src.loc, /turf/simulated/floor/))
			boutput(user, "<span class='alert'>Not sure what this floor is made of but you can't seem to wrench a hole for a bolt in it.</span>")
			return
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		var/turf/T = get_turf(user)
		if(src.anchored == 0)
			boutput(user, "<span class='notice'>Now securing the SWORD Engine.</span>")
		else
			boutput(user, "<span class='notice'>Now unsecuring the SWORD Engine.</span>")
		sleep(4 SECONDS)
		if (!istype(src.loc, /turf/simulated/floor/))
			boutput(user, "<span class='alert'>You feel like your body is being ripped apart from the inside. Maybe you shouldn't try that again. For your own safety, I mean.</span>")
			return
		if(get_turf(user) == T)
			if(src.anchored == 0)
				boutput(user, "<span class='notice'>You secured the SWORD Engine!</span>")
				src.anchored = 1
				//terminal_setup()
			else
				boutput(user, "<span class='notice'>You unsecured the SWORD Engine!</span>")
				src.anchored = 0
				//for(var/obj/machinery/power/terminal/temp_term in get_turf(src))
				//	if(temp_term.master == src)
				//		qdel(temp_term)
				//		terminal = null
		UpdateIcon()

	else if (integrity_state == 2 && ispryingtool(W) && core_inserted)
		if (user.hasStatus(list("weakened", "paralysis", "stunned")) || !isalive(user))
			user.show_text("Not when you're incapacitated.", "red")
		user.shock(src, rand(5000, 30000))
		elecflash(src)
		if (src.online)
			src.online = 0
		core_inserted = false
		user.put_in_hand_or_drop(new /obj/item/sword_core)
		user.show_message("<span class='notice'>You remove the SWORD core from the SWORD Engine!</span>", 1)
		desc = "The remains of the SWORD's Engine, salvaged to work as a better SMES unit. The core is missing."
		UpdateIcon()
	else if (integrity_state == 2 && (istype(W,/obj/item/sword_core) && !core_inserted))
		core_inserted = true
		qdel(W)
		user.show_message("<span class='notice'>You insert the SWORD core into the SWORD Engine!</span>", 1)
		desc = "The remains of the SWORD's Engine, salvaged to work as a better SMES unit. The core is installed."
		online = 0
		charging = 0
		UpdateIcon()


/obj/machinery/power/sword_engine/emp_act()
	..()
	src.online = 0
	src.charging = 0
	src.output = src.output / (rand(2, 8))
	src.charge -= 5e5
	if (src.charge < 0)
		src.charge = 0
	SPAWN(10 SECONDS)
		src.output = initial(src.output)
		src.charging = initial(src.charging)
		src.online = 1
	return


/obj/machinery/power/sword_engine/New()
	..()
	src.glow = image('icons/misc/retribution/SWORD_loot.dmi', "engine_o")
	src.glow.plane = PLANE_SELFILLUM
	src.core = image('icons/misc/retribution/SWORD_loot.dmi', "engine_open_o")
	src.core.plane = PLANE_SELFILLUM
	//terminal_setup()


/obj/machinery/power/sword_engine/proc/terminal_setup()
	SPAWN(1)
		terminal = new /obj/machinery/power/terminal
		terminal.set_loc(get_turf(src))
		terminal.dir = src.dir
		if (!terminal)
			status |= BROKEN
			return
		else
			terminal.master = src
		UpdateIcon()


/obj/machinery/power/sword_engine/update_icon()
	if (integrity_state == 0)
		icon_state = "engine_mangled"
		UpdateOverlays(null, "glow")
		UpdateOverlays(null, "core")
	else if (integrity_state == 1)
		icon_state = "engine"
		UpdateOverlays(null, "core")
	else
		icon_state = "engine_open"

	if (core_inserted && integrity_state == 2)
		UpdateOverlays(core, "core")
	else
		UpdateOverlays(null, "core")

	if (online == 1)
		UpdateOverlays(glow, "glow")
	else
		UpdateOverlays(null, "glow")


/obj/machinery/power/sword_engine/proc/chargedisplay()
	return round(5.5*charge/capacity)


/obj/machinery/power/sword_engine/process()
	if (prob(4))
		elecflash(src.loc)

	if (online == 1 && (!core_inserted || integrity_state == 0 || anchored != 1))
		src.charging = 0
		src.online = 0
		return

	//if (!terminal && core_inserted && integrity_state != 0 && anchored == 1)
	//	terminal_setup()
	//	return

	if (status & BROKEN)
		return
																//Stores the machine states to see if we need to update the icon overlays.
	var/last_disp = chargedisplay()
	var/last_chrg = charging
	var/last_onln = online

	if (terminal)
		var/excess = terminal.surplus()
		var/load = 0
		if (charging)
			if (excess >= 0)									//If there's power available, attempts to charge.
				load = min(capacity-charge, chargelevel)		//Charges at set rate, limited to the spare capacity.
				charge += load									//Increases the charge.
				add_load(load)									//Adds the load to the terminal side network.
			else												//If there is not enough capacity...
				charging = 0									//...it stops charging.
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

	if (online)
		if (prob(5))
			SPAWN(1 DECI SECOND)
				playsound(src.loc, pick(ambience_power), 60, 1)

		lastout = min(charge, output)	//Limits the output to what is stored.

		charge -= lastout				//Reduces the storage. (may be recovered in /restore() if excessive)

		add_avail(lastout)				//Adds the output to the powernet.

		if (charge < 0.0001)			//Stops the output if charge falls to zero.
			online = 0

	if (last_disp != chargedisplay() || last_chrg != charging || last_onln != online)
		UpdateIcon()

	src.updateDialog()

//Called after all power processes are finished.
//Restores the charge level if there was excess this ptick.


/obj/machinery/power/sword_engine/proc/restore()
	if (status & BROKEN)
		return

	if (!online)
		loaddemand = 0
		return

	var/excess = powernet.netexcess			//This was how much wasn't used on the network last ptick, minus any removed by other power-storing devices.
	excess = min(lastout, excess)			//Clamps it to how much was actually output by this machine last ptick.
	excess = min(capacity-charge, excess)	//For safety, also limits the recharge by space capacity of the machine. (shouldn't happen)

	var/clev = chargedisplay()
	charge += excess
	powernet.netexcess -= excess			//Removes the excess from the powernet, so later power-storing devices don't try to use it.
	loaddemand = lastout - excess

	if (clev != chargedisplay())
		UpdateIcon()


/obj/machinery/power/sword_engine/add_avail(var/amount)
	if (terminal && terminal.powernet)
		terminal.powernet.newavail += amount


/obj/machinery/power/sword_engine/add_load(var/amount)
	if (terminal && terminal.powernet)
		terminal.powernet.newload += amount


/obj/machinery/power/sword_engine/ui_state(mob/user)
	return tgui_default_state


/obj/machinery/power/sword_engine/ui_status(mob/user, datum/ui_state/state)
	return min(
		state.can_use_topic(src, user),
		tgui_broken_state.can_use_topic(src, user),
		tgui_not_incapacitated_state.can_use_topic(src, user)
	)


/obj/machinery/power/sword_engine/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smes", src.name)
		ui.open()


/obj/machinery/power/sword_engine/ui_data(mob/user)
	var/list/data = list()
	data["capacity"] = src.capacity
	data["charge"] = src.charge
	data["inputAttempt"] = src.chargemode
	data["inputting"] = src.charging
	data["inputLevel"] = src.chargelevel
	data["inputLevelMax"] = SEMAXCHARGELEVEL
	data["inputAvailable"] = src.lastexcess
	data["outputAttempt"] = src.online
	data["outputting"] = src.loaddemand
	data["outputLevel"] = src.output
	data["outputLevelMax"] = SEMAXOUTPUT
	return data


/obj/machinery/power/sword_engine/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggle-input")
			src.chargemode = !src.chargemode
			if (!chargemode)
				charging = 0
			. = TRUE
		if("toggle-output")
			src.online = !src.online
			. = TRUE
		if("set-input")
			var/target = params["target"]
			var/adjust = params["adjust"]
			if(target == "min")
				src.chargelevel = 0
				. = TRUE
			else if(target == "max")
				src.chargelevel = SEMAXCHARGELEVEL
				. = TRUE
			else if(adjust)
				src.chargelevel = clamp((src.chargelevel + adjust), 0 , SEMAXCHARGELEVEL)
				. = TRUE
			else if(text2num_safe(target) != null)
				src.chargelevel = clamp(text2num_safe(target), 0 , SEMAXCHARGELEVEL)
				. = TRUE
		if("set-output")
			var/target = params["target"]
			var/adjust = params["adjust"]
			if(target == "min")
				src.output = 0
				. = TRUE
			else if(target == "max")
				src.output = SEMAXOUTPUT
				. = TRUE
			else if(adjust)
				src.output = clamp((src.output + adjust), 0 , SEMAXOUTPUT)
				. = TRUE
			else if(text2num_safe(target) != null)
				src.output = clamp(text2num_safe(target), 0 , SEMAXOUTPUT)
				. = TRUE
	src.UpdateIcon()

#undef SEMAXCHARGELEVEL
#undef SEMAXOUTPUT
