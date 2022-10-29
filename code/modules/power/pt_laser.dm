#define PTLEFFICIENCY 0.1
#define PTLMINOUTPUT 1 MEGA WATT

/obj/machinery/power/pt_laser
	name = "power transmission laser"
	icon = 'icons/obj/pt_laser.dmi'
	desc = "Generates a laser beam used to transmit power vast distances across space."
	icon_state = "ptl"
	density = 1
	anchored = 1
	dir = 4
	bound_height = 96
	bound_width = 96
	var/range = 100			//how far the beam goes, set to max(world.maxx,world.maxy) in New()
	var/output = 0		//power output of the beam
	var/capacity = 1e15
	var/charge = 0
	var/charging = 0
	var/load_last_tick = 0	//how much load did we put on the network last tick?
	var/chargelevel = 0		//Power input
	var/online = FALSE
	var/obj/machinery/power/terminal/terminal = null
	var/firing = FALSE			//laser is currently active
	var/list/laser_parts = list()	//all the individual laser objects
	var/list/laser_turfs = list()	//every turf with a laser on it
	var/list/affecting_mobs = list()//mobs in the path of the beam
	var/list/blocking_objects = list()	//the objects blocking the laser, if any
	var/selling = FALSE
	var/laser_process_counter = 0
	var/input_number = 0
	var/output_number = 0
	var/input_multi = 1		//for kW, MW, GW etc
	var/output_multi = 1e6
	var/emagged = FALSE
	var/lifetime_earnings = 0
	var/undistributed_earnings = 0
	var/excess = null //for tgui readout
	var/is_charging = FALSE //for tgui readout

/obj/machinery/power/pt_laser/New()
	..()

	range = max(world.maxx,world.maxy)

	SPAWN(0.5 SECONDS)
		var/turf/origin = get_rear_turf()
		if(!origin) return //just in case
		dir_loop:
			for(var/d in cardinal)
				var/turf/T = get_step(origin, d)
				for(var/obj/machinery/power/terminal/term in T)
					if(term?.dir == turn(d, 180))
						terminal = term
						break dir_loop

		if(!terminal)
			status |= BROKEN
			return

		terminal.master = src

		UpdateIcon()

/obj/machinery/power/pt_laser/disposing()
	for(var/obj/O in laser_parts)
		qdel(O)

	for(var/x_off = 0 to 2)
		for(var/y_off = 0 to 2)
			var/turf/T = locate(src.x + x_off,src.y + y_off,src.z)
			if(T && prob(50))
				make_cleanable( /obj/decal/cleanable/machine_debris,T)

	..()

/obj/machinery/power/pt_laser/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (src.emagged)
		return 0
	src.emagged = TRUE
	if (user)
		src.add_fingerprint(user)
		src.visible_message("<span class='alert'>[src.name] looks a little wonky, as [user] has messed with the polarity using an electromagnetic card!</span>")
	return 1

/obj/machinery/power/pt_laser/update_icon(var/started_firing = 0)
	overlays = null
	if(status & BROKEN || charge == 0)
		overlays += image('icons/obj/pt_laser.dmi', "unpowered")
		return

	if(load_last_tick > 0)
		overlays += image('icons/obj/pt_laser.dmi', "green_light")

	if(online)
		overlays += image('icons/obj/pt_laser.dmi', "red_light")
		if(started_firing)
			overlays += image('icons/obj/pt_laser.dmi', "started_firing")
		else if(firing)
			overlays += image('icons/obj/pt_laser.dmi', "firing")

	var/clevel = chargedisplay()
	if(clevel == 6)
		overlays += image('icons/obj/pt_laser.dmi', "charge_full")
	else if(clevel>0)
		overlays += image('icons/obj/pt_laser.dmi', "charge_[clevel]")

/obj/machinery/power/pt_laser/proc/chargedisplay()
	if(!output)
		return 0
	return min(round((charge/abs(output))*6),6) //how close it is to firing power, not to capacity.

/obj/machinery/power/pt_laser/process(mult)
	if(status & BROKEN)
		return
	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_onln = online
	var/last_llt = load_last_tick
	var/last_firing = firing
	var/dont_update = 0
	var/adj_output = abs(output)

	if(terminal)
		src.excess = (terminal.surplus() + load_last_tick) //otherwise the charge used by this machine last tick is counted against the charge available to it this tick aaaaaaaaaaaaaa
		if(charging && src.excess >= src.chargelevel)		// if there's power available, try to charge
			var/load = min(capacity-charge, chargelevel)		// charge at set rate, limited to spare capacity
			charge += load * mult		// increase the charge
			add_load(load)		// add the load to the terminal side network
			load_last_tick = load
			if (!src.is_charging) src.is_charging = TRUE
		else
			load_last_tick = 0
			if (src.is_charging) src.is_charging = FALSE

	if( charge > adj_output*mult)
		adj_output *= mult

	if(online) // if it's switched on
		if(!firing) //not firing
			if(charge >= adj_output && (adj_output >= PTLMINOUTPUT)) //have power to fire
				if(laser_parts.len == 0)
					start_firing() //creates all the laser objects then activates the right ones
				else
					restart_firing() //if the laser was created already, just activate the existing objects
				dont_update = 1 //so the firing animation runs
				charge -= adj_output
				if(selling)
					power_sold(adj_output)
		else if(charge < adj_output && (adj_output >= PTLMINOUTPUT)) //firing but not enough charge to sustain
			stop_firing()
		else //firing and have enough power to carry on
			for(var/mob/living/L in affecting_mobs) //has to happen every tick
				if(burn_living(L,adj_output*PTLEFFICIENCY)) //returns 1 if they are gibbed, 0 otherwise
					affecting_mobs -= L

			if(laser_process_counter > 9)
				process_laser() //fine if it happens less often, just tile burning and hotspot exposure
				laser_process_counter = 0
			else
				laser_process_counter ++

			charge -= adj_output

			if(selling)
				power_sold(adj_output)
			else if(blocking_objects.len > 0)
				melt_blocking_objects()

			update_laser()

	// only update icon if state changed
	if(dont_update == 0 && (last_firing != firing || last_disp != chargedisplay() || last_onln != online || ((last_llt > 0 && load_last_tick == 0) || (last_llt == 0 && load_last_tick > 0))))
		UpdateIcon()

/obj/machinery/power/pt_laser/proc/power_sold(adjusted_output)
	if (round(adjusted_output) == 0)
		return FALSE

	var/output_mw = adjusted_output / 1e6

	#define LOW_CAP (20) //provide a nice scalar for deminishing returns instead of a slow steady climb
	#define BUX_PER_WORK_CAP (5000-LOW_CAP) //at inf power, generate 5000$/tick, also max amt to drain/tick
	#define ACCEL_FACTOR 69 //our acceleration factor towards cap
	#define STEAL_FACTOR 4 //Adjusts the curve of the stealing EQ (2nd deriv/concavity)

	//For equation + explanation, https://www.desmos.com/calculator/r8bsyz5gf9
	//Adjusted to give a decent amt. of cash/tick @ 50GW (said to be average hellburn)
	var/generated_moolah = (2*output_mw*BUX_PER_WORK_CAP)/(2*output_mw+BUX_PER_WORK_CAP*ACCEL_FACTOR) //used if output_mw > 0
	generated_moolah += (4*output_mw*LOW_CAP)/(4*output_mw + LOW_CAP)

	if (output_mw < 0) //steals money since you emagged it
		generated_moolah = (-2*output_mw*BUX_PER_WORK_CAP)/(2*STEAL_FACTOR*output_mw - BUX_PER_WORK_CAP*STEAL_FACTOR*ACCEL_FACTOR)

	lifetime_earnings += generated_moolah
	generated_moolah += undistributed_earnings
	undistributed_earnings = 0

	// the double chief engineer seems to be intentional however silly it may seem
	var/list/accounts = \
		data_core.bank.find_records("job", "Chief Engineer") + \
		data_core.bank.find_records("job", "Chief Engineer") + \
		data_core.bank.find_records("job", "Engineer")

	if(!length(accounts)) // no engineering staff but someone still started the PTL
		wagesystem.station_budget += generated_moolah
	else if(abs(generated_moolah) >= accounts.len*2) //otherwise not enough to split evenly so don't bother I guess
		wagesystem.station_budget += round(generated_moolah/2)
		generated_moolah -= round(generated_moolah/2) //no coming up with $$$ out of air!

		for(var/datum/db_record/t as anything in accounts)
			t["current_money"] += round(generated_moolah/accounts.len)
		undistributed_earnings += generated_moolah-(round(generated_moolah/accounts.len) * (length(accounts)))
	else
		undistributed_earnings += generated_moolah

	#undef STEAL_FACTOR
	#undef ACCEL_FACTOR
	#undef BUX_PER_WORK_CAP

/obj/machinery/power/pt_laser/proc/get_barrel_turf()
	var/x_off = 0
	var/y_off = 0
	var/bw = round(bound_width / world.icon_size)
	var/bh = round(bound_width / world.icon_size)
	switch(dir)
		if(1)
			x_off = round((bw - 1) / 2)
			y_off = bh - 1
		if(2)
			x_off = round((bw - 1) / 2)
			y_off = 0
		if(4)
			x_off = bw - 1
			y_off = round((bh - 1) / 2)
		if(8)
			x_off = 0
			y_off = round((bh - 1) / 2)

	var/turf/T = locate(src.x + x_off,src.y + y_off,src.z)

	return T

/obj/machinery/power/pt_laser/proc/get_rear_turf()
	var/x_off = 0
	var/y_off = 0
	var/bw = round(bound_width / world.icon_size)
	var/bh = round(bound_width / world.icon_size)
	switch(dir)
		if(1)
			x_off = round((bw - 1) / 2)
			y_off = 0
		if(2)
			x_off = round((bw - 1) / 2)
			y_off = bh - 1
		if(4)
			x_off = 0
			y_off = round((bh - 1) / 2)
		if(8)
			x_off = bw - 1
			y_off = round((bh - 1) / 2)

	var/turf/T = locate(src.x + x_off,src.y + y_off,src.z)

	return T

/obj/machinery/power/pt_laser/proc/start_firing()
	var/turf/T = get_barrel_turf()
	if(!T) return //just in case

	firing = 1
	UpdateIcon(1)

	var/scale_factor = round(bound_width / 96)
	for(var/dist = 0, dist < range / scale_factor, dist += scale_factor) // creates each field tile
		for(var/i in 1 to (dist == 0 ? 1 : scale_factor))
			T = get_step(T, dir)
		if(!T) break //edge of the map
		var/obj/lpt_laser/laser = new/obj/lpt_laser(T)
		laser.bound_width *= scale_factor
		laser.bound_height *= scale_factor
		laser.Scale(scale_factor, scale_factor)
		laser.Translate((scale_factor - 1) * world.icon_size / 2, (scale_factor - 1) * world.icon_size / 2)
		laser.set_dir(src.dir)
		laser.power = round(abs(output)*PTLEFFICIENCY)
		laser.source = src
		laser.active = 0
		src.laser_parts += laser
		src.laser_turfs += laser.locs

	melt_blocking_objects()
	update_laser()

/obj/machinery/power/pt_laser/proc/restart_firing()
	firing = 1
	UpdateIcon(1)
	melt_blocking_objects()
	update_laser()

/obj/machinery/power/pt_laser/proc/check_laser_active() //returns number of laser_parts that should be active starting at top of list
	blocking_objects = list()
	var/turf/T = get_barrel_turf()
	if(!T) return //just in case

	for(var/dist = 0, dist < range, dist += 1)
		T = get_step(T, dir)
		if(!T || T.density)
			if(!istype(T, /turf/unsimulated/wall/trench)) return dist
		for(var/obj/O in T)
			if(!istype(O,/obj/window) && !istype(O,/obj/grille) && !ismob(O) && O.density)
				blocking_objects += O
		if(blocking_objects.len > 0) return dist


/obj/machinery/power/pt_laser/proc/stop_firing()
	for(var/obj/lpt_laser/L in laser_parts)
		L.invisibility = INVIS_ALWAYS //make it invisible
		L.active = 0
		L.light.disable()
	affecting_mobs = list()
	selling = 0
	firing = 0
	blocking_objects = list()

/obj/machinery/power/pt_laser/proc/update_laser()
	firing = 1
	var/active_num = check_laser_active()

	var/counter = 1
	for(var/obj/lpt_laser/L in laser_parts)
		if(counter <= active_num)
			L.invisibility = INVIS_NONE //make it visible
			L.alpha = clamp(((log(10, L.power) - 5) * (255 / 5)), 50, 255) //50 at ~1e7 255 at 1e11 power, the point at which the laser's most deadly effect happens
			L.active = 1
			L.light.enable()
			L.burn_all_living_contents()
			counter++
		else
			L.invisibility = INVIS_ALWAYS
			L.active = 0
			L.light.disable()

	if(active_num == laser_parts.len)
		selling = 1

/obj/machinery/power/pt_laser/proc/melt_blocking_objects()
	for (var/obj/O in blocking_objects)
		if (istype(O, /obj/machinery/door/poddoor) || isrestrictedz(O.z))
			continue
		else if (prob((abs(output)*PTLEFFICIENCY)/5e5))
			O.visible_message("<b>[O.name] is melted away by the [src]!</b>")
			qdel(O)

/obj/machinery/power/pt_laser/add_load(var/amount)
	if(terminal?.powernet)
		terminal.powernet.newload += amount

/obj/machinery/power/pt_laser/proc/update_laser_power()
	//only call stop_firing() if output setting is hire than charge, and if we are actually firing
	if(src.firing && (abs(src.output) > src.charge))
		stop_firing()

	for(var/obj/lpt_laser/L in laser_parts)
		L.power = round(abs(src.output)*PTLEFFICIENCY)
		L.alpha = clamp(((log(10, max(1,L.power)) - 5) * (255 / 5)), 50, 255) //50 at ~1e7 255 at 1e11 power, the point at which the laser's most deadly effect happens

/obj/machinery/power/pt_laser/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PowerTransmissionLaser")
		ui.open()

/obj/machinery/power/pt_laser/ui_data(mob/user)
	. = list(
		"capacity" = src.capacity,
		"charge" = src.charge,
		"isEmagged" = src.emagged,
		"isChargingEnabled" = src.charging,
		"excessPower" = src.excess,
		"gridLoad" = src.terminal?.powernet.load,
		"inputLevel" = src.chargelevel,
		"inputMultiplier" = src.input_multi,
		"inputNumber" = src.input_number,
		"isCharging" = src.is_charging,
		"isFiring" = src.firing,
		"isLaserEnabled" = src.online,
		"lifetimeEarnings" = src.lifetime_earnings,
		"name" = src.name,
		"outputLevel" = src.output,
		"outputMultiplier" = src.output_multi,
		"outputNumber" = src.output_number,
		"totalGridPower" = src.terminal?.powernet.avail,
	)

/obj/machinery/power/pt_laser/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch(action)
		//Input controls
		if("toggleInput")
			src.charging = !src.charging
			. = TRUE
		if("setInput")
			src.input_number = clamp(params["setInput"], 0, 999)
			src.chargelevel = src.input_number * src.input_multi
			. = TRUE
		if("inputW")
			src.input_multi = 1 WATT
			src.chargelevel = src.input_number * src.input_multi
			. = TRUE
		if("inputkW")
			src.input_multi = 1 KILO WATT
			src.chargelevel = src.input_number * src.input_multi
			. = TRUE
		if("inputMW")
			src.input_multi = 1 MEGA WATT
			src.chargelevel = src.input_number * src.input_multi
			. = TRUE
		if("inputGW")
			src.input_multi = 1 GIGA WATT
			src.chargelevel = src.input_number * src.input_multi
			. = TRUE
		if("inputTW")
			src.input_multi = 1 TERA WATT
			src.chargelevel = src.input_number * src.input_multi
			. = TRUE
		//Output controls
		if("toggleOutput")
			src.online = !src.online
			if(!online) src.stop_firing()
			. = TRUE
		if("setOutput")
			if (src.emagged)
				src.output_number = clamp(params["setOutput"], -999, 999)
			else
				src.output_number = clamp(params["setOutput"], 0, 999)
			src.output = src.output_number * src.output_multi
			if(!src.output)
				src.stop_firing()
			src.update_laser_power()
			. = TRUE
		if("outputMW")
			src.output_multi = 1 MEGA WATT
			src.output = src.output_number * src.output_multi
			src.update_laser_power()
			. = TRUE
		if("outputGW")
			src.output_multi = 1 GIGA WATT
			src.output = src.output_number * src.output_multi
			src.update_laser_power()
			. = TRUE
		if("outputTW")
			src.output_multi = 1 TERA WATT
			src.output = src.output_number * src.output_multi
			src.update_laser_power()
			. = TRUE

/obj/machinery/power/pt_laser/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(50))
				status |= BROKEN
				UpdateIcon()
		if(3)
			if (prob(25))
				status |= BROKEN
				UpdateIcon()
	return

/obj/machinery/power/pt_laser/proc/process_laser()
	if(output == 0) return

	var/power = abs(output)*PTLEFFICIENCY

	for(var/turf/T in laser_turfs)
		if(power > 5e7)
			T.hotspot_expose(power/1e5,5) //1000K at 100MW
		if(istype(T, /turf/simulated/floor) && prob(power/1e5))
			T:burn_tile()


/obj/lpt_laser
	name = "laser"
	desc = "A powerful laser beam."
	icon = 'icons/obj/power.dmi'
	icon_state = "ptl_beam"
	anchored = 2
	density = 0
	luminosity = 1
	invisibility = INVIS_ALWAYS
	event_handler_flags = USE_FLUID_ENTER
	var/power = 0
	var/active = 1
	var/obj/machinery/power/pt_laser/source = null
	var/datum/light/light


/obj/lpt_laser/New()
	light = new /datum/light/point
	light.attach(src)
	light.set_color(0, 0.8, 0.1)
	light.set_brightness(0.4)
	light.set_height(0.5)
	light.enable()

	SPAWN(0)
		alpha = clamp(((log(10, max(src.power,1)) - 5) * (255 / 5)), 50, 255) //50 at ~1e7 255 at 1e11 power, the point at which the laser's most deadly effect happens
		if(active)
			if(istype(src.loc, /turf) && power > 5e7)
				src.loc:hotspot_expose(power/1e5,5) //1000K at 100MW
			if(istype(src.loc, /turf/simulated/floor) && prob(power/1e6))
				src.loc:burn_tile()

			for (var/mob/living/L in src.loc)
				if (isintangible(L))
					continue
				if (!burn_living(L,power) && source) //burn_living() returns 1 if they are gibbed, 0 otherwise
					source.affecting_mobs |= L

	..()

/obj/lpt_laser/ex_act(severity)
	return

/obj/lpt_laser/Crossed(atom/movable/AM)
	..()
	if (src.active && isliving(AM) && !isintangible(AM))
		if (!burn_living(AM,power) && source) //burn_living() returns 1 if they are gibbed, 0 otherwise
			source.affecting_mobs |= AM

/obj/lpt_laser/Uncrossed(var/atom/movable/AM)
	if(isliving(AM) && source)
		source.affecting_mobs -= AM

/obj/lpt_laser/proc/burn_all_living_contents()
	for(var/mob/living/L in src.loc)
		if(burn_living(L,power) && source) //returns 1 if they were gibbed
			source.affecting_mobs -= L

/obj/proc/burn_living(var/mob/living/L, var/power = 0)
	if(power < 10) return
	if(isintangible(L)) return // somehow flocktraces are still getting destroyed by the laser. maybe this will fix it

	if(prob(min(power/1e5,50)))
		INVOKE_ASYNC(L, /mob/living.proc/emote, "scream") //might be spammy if they stand in it for ages, idk

	if(L.dir == turn(src.dir,180) && ishuman(L)) //they're looking into the beam!
		var/safety = 1

/*	L:head:up broke for no reason so I had to rewrite it.
		if (istype(L:head, /obj/item/clothing/head/helmet/welding))
			if(!L:head:up)
				safety = 8*/
		var/mob/living/carbon/human/newL = L
		if (istype(newL.glasses, /obj/item/clothing/glasses/thermal) || newL.eye_istype(/obj/item/organ/eye/cyber/thermal))
			safety = 0.5
		else if (istype(newL.glasses, /obj/item/clothing/glasses/nightvision) || newL.eye_istype(/obj/item/organ/eye/cyber/nightvision))
			safety = 0.25
		else if (istype(newL.head, /obj/item/clothing/head/helmet/welding) && !newL.head:up)
			safety = 8
		else if (istype(newL.head, /obj/item/clothing/head/helmet/space))
			safety = 8
		else if (istype(newL.glasses, /obj/item/clothing/glasses/sunglasses) || newL.eye_istype(/obj/item/organ/eye/cyber/sunglass))
			safety = 2

		boutput(L, "<span class='alert'>Your eyes are burned by the laser!</span>")
		L.take_eye_damage(power/(safety*1e5)) //this will damage them a shitload at the sorts of power the laser will reach, as it should.
		L.change_eye_blurry(rand(power / (safety * 2e5)), 50) //don't stare into 100MW lasers, kids

	//this will probably need fiddling with, hard to decide on reasonable values
	switch(power)
		if(10 to 1e7)
			L.set_burning(power/1e5) //100 (max burning) at 10MW
			L.bodytemperature = max(power/1e4, L.bodytemperature) //1000K at 10MW. More than hotspot because it's hitting them not just radiating heat (i guess? idk)
		if(1e7+1 to 5e8)
			L.set_burning(100)
			L.bodytemperature = max(power/1e4, L.bodytemperature)
			L.TakeDamage("chest", 0, power/1e7) //ow
			if(ishuman(L) && prob(min(power/1e7,50)))
				var/limb = pick("l_arm","r_arm","l_leg","r_leg")
				L:sever_limb(limb)
				L.visible_message("<b>The [src.name] slices off one of [L.name]'s limbs!</b>")
		if(5e8+1 to 1e11) //you really fucked up this time buddy
			make_cleanable( /obj/decal/cleanable/ash,src.loc)
			L.unlock_medal("For Your Ohm Good", 1)
			L.visible_message("<b>[L.name] is vaporised by the [src]!</b>")
			logTheThing(LOG_COMBAT, L, "was elecgibbed by the PTL at [log_loc(L)].")
			L.elecgib()
			return 1 //tells the caller to remove L from the laser's affecting_mobs
		if(1e11+1 to INFINITY) //you really, REALLY fucked up this time buddy
			L.unlock_medal("For Your Ohm Good", 1)
			L.visible_message("<b>[L.name] is detonated by the [src]!</b>")
			logTheThing(LOG_COMBAT, L, "was explosively gibbed by the PTL at [log_loc(L)].")
			L.blowthefuckup(min(1+round(power/1e12),20),0)
			return 1 //tells the caller to remove L from the laser's affecting_mobs

	return 0

#undef PTLEFFICIENCY
#undef PTLMINOUTPUT
