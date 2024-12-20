#define PTLMINOUTPUT 1 MEGA WATT
#define LASER_COOLDOWN_ID "PTL laser change cooldown"

/obj/machinery/power/pt_laser
	name = "power transmission laser"
	icon = 'icons/obj/pt_laser.dmi'
	desc = "Generates a laser beam used to transmit power vast distances across space."
	icon_state = "ptl"
	density = 1
	anchored = ANCHORED_ALWAYS
	dir = EAST
	layer = ABOVE_OBJ_LAYER + 0.1 //over lasers which are over mirrors :screm:
	bound_height = 96
	bound_width = 96
	req_access = list(access_engineering_power)
	var/output = 0		//power output of the beam
	var/max_dial_value = 999 // limitation of what can be set on the ui dial.
	var/capacity = 200 MEGA WATTS // Under the gib amount to prevent players from pulsing a death laser.
	var/charge = 0
	var/charging = 0
	var/load_last_tick = 0	//how much load did we put on the network last tick?
	// How often you can change the output/firing status of the PTL
	var/laser_cooldown = 1 SECOND
	var/laser_output_needs_update = FALSE	// Does the PTL need to be updated this loop?
	var/chargelevel = 0		//Power input
	var/online = FALSE
	var/obj/machinery/power/terminal/terminal = null
	var/firing = FALSE			//laser is currently active
	///the first laser object
	var/obj/linked_laser/ptl/laser = null
	var/list/affecting_mobs = list()//mobs in the path of the beam
	var/list/blocking_objects = list()	//the objects blocking the laser, if any
	var/input_number = 0
	var/output_number = 0
	var/input_multi = 1		//for kW, MW, GW etc
	var/output_multi = 1e6
	var/emagged = FALSE
	var/lifetime_earnings = 0
	var/current_balance = 0
	var/excess = null //for tgui readout
	var/is_charging = FALSE //for tgui readout
	///A list of all laser segments from this PTL that reached the edge of the z-level
	var/list/selling_lasers = list()
	///Is this PTL so wacky, weird and whimsical that its laser goes in squiggles?
	var/wacky = FALSE

	cheat
		charge = INFINITY
		can_fire()
			return TRUE

/obj/machinery/power/pt_laser/New()
	..()

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

		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Toggle Power Input", PROC_REF(_toggle_input_mechchomp))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Power Input", PROC_REF(_set_input_mechchomp))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Togle Power Output", PROC_REF(_toggle_output_mechchomp))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Power Output", PROC_REF(_set_output_mechchomp))

		if(!terminal)
			status |= BROKEN
			return

		terminal.master = src

		UpdateIcon()

/obj/machinery/power/pt_laser/disposing()
	qdel(src.laser)
	src.laser = null
	src.selling_lasers = null
	for(var/x_off = 0 to 2)
		for(var/y_off = 0 to 2)
			var/turf/T = locate(src.x + x_off,src.y + y_off,src.z)
			if(T && prob(50))
				make_cleanable( /obj/decal/cleanable/machine_debris,T)

	..()

/obj/machinery/power/pt_laser/proc/_toggle_input_mechchomp()
	src.charging = !src.charging

/obj/machinery/power/pt_laser/proc/_set_input_mechchomp(var/datum/mechanicsMessage/inp)
	if(!length(inp.signal)) return
	var/newinput = text2num(inp.signal)
	if (newinput != src.chargelevel && isnum_safe(newinput) && newinput > 0)
		src.chargelevel = newinput
		// Working backwards to update the ui based on the power we've set up.
		if(chargelevel < 1 KILO WATT)
			src.input_multi = 1 WATT
		else if(chargelevel < 1 MEGA WATT)
			src.input_multi = 1 KILO WATT
		else if(chargelevel < 1 GIGA WATT)
			src.input_multi = 1 MEGA WATT
		else if(chargelevel < 1 TERA WATT)
			src.input_multi = 1 GIGA WATT
		else
			src.input_multi = 1 TERA WATT
		src.input_number = clamp((src.chargelevel/src.input_multi), 0, src.max_dial_value)

/obj/machinery/power/pt_laser/proc/_toggle_output_mechchomp()
	src.online = !src.online
	src.update_output()

/obj/machinery/power/pt_laser/proc/_set_output_mechchomp(var/datum/mechanicsMessage/inp)
	if(!length(inp.signal)) return
	var/newoutput = text2num(inp.signal)
	// We check against the absolute value of the current charge level, in case the PTL has been emagged.
	if (newoutput != abs(src.output) && isnum_safe(newoutput) && newoutput > 0)
		src.output = src.emagged ? -newoutput : newoutput
		// Working backwards to update the ui based on the power we've set up.
		if(newoutput >= 1 TERA WATT)
			src.output_multi = 1 TERA WATT
		else if(newoutput >= 1 GIGA WATT)
			src.output_multi = 1 GIGA WATT
		else
			src.output_multi = 1 MEGA WATT
		var/abs_output_number = clamp((newoutput / src.output_multi), 0, src.max_dial_value)
		src.output_number = src.emagged ? -abs_output_number : abs_output_number
		src.update_output()


/obj/machinery/power/pt_laser/attackby(obj/item/I, mob/user)
	var/obj/item/card/id/id_card = get_id_card(I)
	if (istype(id_card))
		if (!src.check_access(id_card))
			boutput(user, SPAN_ALERT("Access denied."))
			return TRUE
		var/datum/db_record/account = FindBankAccountByName(id_card.registered)
		if (!account)
			boutput(user, SPAN_ALERT("No bank account associated with this ID found."))
			return TRUE
		// var/amount = tgui_input_number(user, "Withdraw how much?", "Withdraw amount", src.current_balance, src.current_balance, 0, 0, FALSE)
		var/amount = input(user, "Withdraw how much?", "Withdraw amount", src.current_balance)
		amount = clamp(amount, 0, src.current_balance)
		if (!amount)
			return TRUE
		src.current_balance -= amount
		account["current_money"] += amount

		src.send_pda_message("PT LASER: Transferring [amount][CREDIT_SIGN] to account of [id_card.registered] ([id_card.assignment])")
		return TRUE
	else
		. = ..()

/obj/machinery/power/pt_laser/proc/send_pda_message(msg)
	var/datum/signal/signal = get_free_signal()
	signal.source = src
	signal.data["command"] = "text_message"
	signal.data["sender_name"] = "ENGINE-MAILBOT"
	signal.data["group"] = list(MGO_ENGINEER, MGA_ENGINE)
	signal.data["message"] = msg
	signal.data["sender"] = "00000000"
	signal.data["address_1"] = "00000000"
	radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)

/obj/machinery/power/pt_laser/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (src.emagged)
		return 0
	src.emagged = TRUE
	src.output_number = -src.output_number
	src.output = src.output_number * src.output_multi
	if (src.firing)
		src.stop_firing()
		src.start_firing()
	if (user)
		src.add_fingerprint(user)
		playsound(src.loc, 'sound/machines/bweep.ogg', 10, TRUE)
		src.audible_message(SPAN_ALERT("The [src.name] chirps 'OUTPUT CONTROLS UNLOCKED: INVERSE POLARITY ENABLED' \
		from some unseen speaker, then goes quiet."))
	return TRUE

/obj/machinery/power/pt_laser/demag(var/mob/user)
	if (!src.emagged)
		return FALSE

	if (user)
		user.show_text("You reset the [src.name]'s power output protocols.", "blue")

	if (src.output_number < 0 || src.output < 0) //Checking both is redundant, but just in case
		src.output_number = 0
		src.output = 0
	src.emagged = FALSE
	return TRUE

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

#define START_FIRING "START_FIRING"
#define CONTINUE_FIRING "CONTINUE_FIRING"
#define STOP_FIRING "STOP_FIRING"
#define NO_CHANGE "NO_CHANGE"
/**
	1. Calculate available power.
	2. Figure out next state and power available.
	3. Adjust battery charge and, `terminal.add_load` and set last_load.
	4. Execute the new laser state.
*/
/obj/machinery/power/pt_laser/process(mult)
	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_onln = online
	var/last_llt = load_last_tick
	var/last_firing = firing
	var/dont_update = 0
	var/adj_output = abs(output)
	var/starting_surplus = src.get_available_input_power() // Incoming power beyond battery charge we can use to fuel the laser, capped by chargelevel.
	var/new_state = NO_CHANGE
	var/power_used = 0
	var/connected = terminal && !(src.status & BROKEN)

	if(connected)
		src.excess = src.get_available_terminal_power()

	// Calculate next state and power needed
	var/can_fire = src.can_fire()
	if(online) // if it's switched on
		if(!firing) //not firing
			if(can_fire) //have power to fire
				power_used += adj_output
				new_state = START_FIRING
		else if(!can_fire) //firing but not enough charge to sustain
			power_used = starting_surplus + src.charge // We use all the surplus plus whats left of the charge.
			new_state = STOP_FIRING
		else //firing and have enough power to carry on
			power_used += adj_output
			new_state = CONTINUE_FIRING
	else if (firing)
		new_state = STOP_FIRING

	// Consume power from network
	var/adj_charge = clamp(starting_surplus - power_used, -src.charge, src.capacity - src.charge)
	power_used -= min(0, adj_charge)
	var/load = clamp(power_used, 0, starting_surplus)
	if(terminal?.add_load(load))						// attempt to add the load to the terminal side network
		src.charge += adj_charge				// adjust the charge if we did
		src.load_last_tick = load
	else if (connected) // So /cheat doesn't break
		new_state = STOP_FIRING
		src.is_charging = FALSE
		load_last_tick = 0

	// Execute new laser state
	adj_output *= mult
	switch(new_state)
		if(START_FIRING)
			start_firing() //creates all the laser objects then activates the right ones
			dont_update = 1 //so the firing animation runs
		if(CONTINUE_FIRING)
			if (src.laser_output_needs_update)
				src.update_laser_power()
			for(var/mob/living/L in affecting_mobs) //has to happen every tick
				if (!locate(/obj/linked_laser/ptl) in get_turf(L)) //safety because Uncross is somehow unreliable
					affecting_mobs -= L
					continue
				if(burn_living(L,adj_output)) //returns 1 if they are gibbed, 0 otherwise
					affecting_mobs -= L

			if(length(blocking_objects) > 0)
				melt_blocking_objects()
			power_sold(adj_output)
		if(STOP_FIRING) stop_firing()

	SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "output=[src.output]&firing=[src.firing]&charge=[src.charge]&currentbalance=[src.current_balance]&lifetimeearnings=[src.lifetime_earnings]")
	src.laser_output_needs_update = FALSE
	src.is_charging = src.charging && power_used > 0 ? FALSE : TRUE

	// only update icon if state changed
	if(dont_update == 0 && (last_firing != firing || last_disp != chargedisplay() || last_onln != online || ((last_llt > 0 && load_last_tick == 0) || (last_llt == 0 && load_last_tick > 0))))
		UpdateIcon()
#undef START_FIRING
#undef CONTINUE_FIRING
#undef STOP_FIRING
#undef NO_CHANGE

/obj/machinery/power/pt_laser/proc/power_sold(adjusted_output)
	var/proportion = 0
	for (var/obj/linked_laser/ptl/laser in src.selling_lasers)
		proportion += laser.power
	adjusted_output *= proportion

	if (round(adjusted_output) == 0)
		return FALSE

	var/output_mw = adjusted_output / 1e6

	#define LOW_CAP (23) //provide a nice scalar for deminishing returns instead of a slow steady climb
	#define BUX_PER_WORK_CAP (5000-LOW_CAP) //at inf power, generate 5000$/tick, also max amt to drain/tick
	#define ACCEL_FACTOR 15 //our acceleration factor towards cap
	#define STEAL_FACTOR 4 //Adjusts the curve of the stealing EQ (2nd deriv/concavity)

	//For equation + explanation, https://www.desmos.com/calculator/6pft2ayzt9
	//Adjusted to give a decent amt. of cash/tick @ 50GW (said to be average hellburn)
	var/generated_moolah = (2*output_mw*BUX_PER_WORK_CAP)/(2*output_mw+BUX_PER_WORK_CAP*ACCEL_FACTOR) //used if output_mw > 0
	generated_moolah += (5*output_mw*LOW_CAP)/(2*output_mw + LOW_CAP)

	generated_moolah = round(generated_moolah)

	src.lifetime_earnings += generated_moolah
	src.current_balance += generated_moolah

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
	if (!src.output)
		return
	var/turf/T = src.emagged ? get_rear_turf() : get_barrel_turf()
	if(!T) return //just in case

	firing = TRUE
	UpdateIcon(1)
	src.laser = new(T, src.emagged ? turn(src.dir, 180) : src.dir)
	src.laser.source = src
	src.laser.try_propagate()

	melt_blocking_objects()

/obj/machinery/power/pt_laser/proc/laser_power()
	return round(abs(output))

/obj/machinery/power/pt_laser/proc/stop_firing()
	qdel(src.laser)
	affecting_mobs = list()
	firing = 0
	blocking_objects = list()

/obj/machinery/power/pt_laser/proc/melt_blocking_objects()
	for (var/atom/A as anything in blocking_objects)
		if (istype(A, /obj/machinery/door/poddoor) || \
				istype(A, /obj/laser_sink) || \
				istype(A, /obj/machinery/vehicle) || \
				istype(A, /obj/machinery/bot/mulebot) || \
				istype(A, /obj/machinery/the_singularity) || /* could be interesting to add some interaction here, maybe when singulo behviours are abstracted away in #16731*/ \
				isrestrictedz(A.z))
			continue

		var/melt_prob = 0 //this var only exists for debug really
		if (isturf(A))
			var/turf_mult = istype(A, /turf/simulated/wall/auto/asteroid) ? 0.1 : 1
			if (abs(output) < 100 MEGA WATTS * turf_mult) //hard threshold for turfs, you need a beeg laser
				melt_prob = 0
			else
				melt_prob = abs(output) / (25 MEGA WATTS * turf_mult)
			if (prob(melt_prob))
				A.ex_act(2)
			if (A.density && melt_prob) //turfs keep refs so this will be the new turf if it does get replaced in ex_act
				animate_meltspark(A)
		else
			melt_prob = (abs(output)) / (0.5 MEGA WATTS)
			if (prob(melt_prob))
				if (istype(A, /obj/geode))
					A.ex_act(melt_prob > 20 ? 1 : 3, null, melt_prob / 4) //lazy severity because it doesn't really matter here
				else
					A.visible_message(SPAN_ALERT("[A] is melted away by [src]!"))
					qdel(A)

		if (QDELETED(A))
			src.blocking_objects -= A //mmm yes for loop list modification


/obj/machinery/power/pt_laser/proc/get_available_terminal_power()
	return src.terminal?.surplus() + src.load_last_tick //otherwise the charge used by this machine last tick is counted against the charge available to it this tick aaaaaaaaaaaaaa

/obj/machinery/power/pt_laser/proc/get_available_input_power()
	return src.charging * min(src.chargelevel, src.get_available_terminal_power())

/obj/machinery/power/pt_laser/proc/can_fire()
	return (abs(src.output) <= src.charge + src.get_available_input_power()) & (abs(src.output) >= PTLMINOUTPUT)

/obj/machinery/power/pt_laser/proc/update_laser_power()
	src.laser?.traverse(/obj/linked_laser/ptl/proc/update_source_power)

/obj/machinery/power/pt_laser/broken_state_topic(mob/user)
	if (src.charge)
		return UI_INTERACTIVE
	return ..()

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
		"storedBalance" = src.current_balance,
		"name" = src.name,
		"outputLevel" = src.output,
		"outputMultiplier" = src.output_multi,
		"outputNumber" = src.output_number,
		"totalGridPower" = src.terminal?.powernet.avail,
	)


/obj/machinery/power/pt_laser/proc/update_output()
	if(ON_COOLDOWN(src, LASER_COOLDOWN_ID, src.laser_cooldown))
		src.laser_output_needs_update = TRUE
		return

	if(!src.output || !src.can_fire() || !src.online)
		src.stop_firing()
		return
	if (src.firing)
		src.update_laser_power()
	else if (src.online)
		src.start_firing()

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
			src.update_output()
			. = TRUE
		if("setOutput")
			. = TRUE
			if (src.emagged)
				src.output_number = clamp(params["setOutput"], -999, 0)
			else
				src.output_number = clamp(params["setOutput"], 0, 999)
			src.output = src.output_number * src.output_multi
			src.update_output()
		if("outputMW")
			src.output_multi = 1 MEGA WATT
			src.output = src.output_number * src.output_multi
			src.update_output()
			. = TRUE
		if("outputGW")
			src.output_multi = 1 GIGA WATT
			src.output = src.output_number * src.output_multi
			src.update_output()
			. = TRUE
		if("outputTW")
			src.output_multi = 1 TERA WATT
			src.output = src.output_number * src.output_multi
			src.update_output()
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

//why was this on /obj, what the fuck
/obj/machinery/power/pt_laser/proc/burn_living(var/mob/living/L, var/power = 0)
	if(power < 10)
		return
	if(isintangible(L) || L.nodamage || QDELETED(L))
		return

	if(prob(min(power/1e5,50)))
		INVOKE_ASYNC(L, TYPE_PROC_REF(/mob/living, emote), "scream") //might be spammy if they stand in it for ages, idk

	if(L.dir == turn(src.dir,180) && ishuman(L)) //they're looking into the beam!
		var/safety = 1

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

		boutput(L, SPAN_ALERT("Your eyes are burned by the laser!"))
		L.take_eye_damage(power/(safety*1e5)) //this will damage them a shitload at the sorts of power the laser will reach, as it should.
		L.change_eye_blurry(rand(power / (safety * 2e5)), 50) //don't stare into 100MW lasers, kids

	//this will probably need fiddling with, hard to decide on reasonable values
	switch(power)
		if(10 to 5 MEGA WATTS)
			L.set_burning(power/1e5) //100 (max burning) at 10MW
			L.bodytemperature = max(power/1e4, L.bodytemperature) //1000K at 10MW. More than hotspot because it's hitting them not just radiating heat (i guess? idk)
		if(5 MEGA WATTS + 1 to 200 MEGA WATTS)
			L.set_burning(100)
			L.bodytemperature = max(power/1e4, L.bodytemperature)
			L.TakeDamage("chest", 0, power/(1 MEGA WATT)) //ow
			if(ishuman(L) && prob(min(power/(1 MEGA WATT),50)))
				var/limb = pick("l_arm","r_arm","l_leg","r_leg")
				if(L:sever_limb(limb))
					L.visible_message("<b>The [src.name] slices off one of [L.name]'s limbs!</b>")
		if(200 MEGA WATTS + 1 to 5 GIGA WATTS) //you really fucked up this time buddy
			make_cleanable( /obj/decal/cleanable/ash,src.loc)
			L.unlock_medal("For Your Ohm Good", 1)
			L.visible_message("<b>[L.name] is vaporised by the [src]!</b>")
			logTheThing(LOG_COMBAT, L, "was elecgibbed by the PTL at [log_loc(L)].")
			L.elecgib()
			return 1 //tells the caller to remove L from the laser's affecting_mobs
		if(5 GIGA WATTS + 1 to INFINITY) //you really, REALLY fucked up this time buddy
			L.unlock_medal("For Your Ohm Good", 1)
			L.visible_message("<b>[L.name] is detonated by the [src]!</b>")
			logTheThing(LOG_COMBAT, L, "was explosively gibbed by the PTL at [log_loc(L)].")
			L.blowthefuckup(min(1+round(power/(1 GIGA WATT)),20),0)
			return 1 //tells the caller to remove L from the laser's affecting_mobs

	return 0


/obj/linked_laser/ptl
	name = "laser"
	desc = "A powerful laser beam."
	icon = 'icons/obj/power.dmi'
	icon_state = "ptl_beam"
	event_handler_flags = USE_FLUID_ENTER
	var/obj/machinery/power/pt_laser/source = null

/obj/linked_laser/ptl/New(loc, dir)
	..()
	src.add_simple_light("laser_beam", list(0, 0.8 * 255, 0.1 * 255, 255))

/obj/linked_laser/ptl/proc/update_source_power()
	src.alpha = clamp(((log(10, max(1,src.source.laser_power() * src.power)) - 5) * (255 / 5)), 50, 255) //50 at ~1e7 255 at 1e11 power, the point at which the laser's most deadly effect happens

/obj/linked_laser/ptl/try_propagate()
	. = ..()
	var/turf/T = get_next_turf()
	if (!T || istype(T, /turf/unsimulated/wall/trench)) //edge of z_level or oshan trench
		var/obj/laser_sink/ptl_seller/seller = get_singleton(/obj/laser_sink/ptl_seller)
		if (seller.incident(src))
			src.sink = seller
	var/power = src.source.laser_power()
	src.update_source_power()
	if(istype(src.loc, /turf/simulated/floor) && prob(power/1 MEGA WATT))
		src.loc:burn_tile()

	for (var/mob/living/L in src.loc)
		if (isintangible(L))
			continue
		if (!source.burn_living(L,power)) //burn_living() returns 1 if they are gibbed, 0 otherwise
			source.affecting_mobs |= L

/obj/linked_laser/ptl/copy_laser(turf/T, dir)
	var/wonky = FALSE //are we randomly turning?
	var/wonky_facing = -1 //var to mimic the PTL mirror's facing system so we can use the same corner icon states
	if (src.source.wacky && prob(10))
		wonky = TRUE
		dir = turn(dir, pick(-90, 90))
		if ((src.dir | dir) in list(NORTHWEST, SOUTHEAST))
			wonky_facing = 1
		else
			wonky_facing = 0

	var/obj/linked_laser/ptl/new_laser = ..(T, dir)
	new_laser.source = src.source

	if (wonky)
		new_laser.icon_state = src.get_corner_icon_state(wonky_facing)
	return new_laser

/obj/linked_laser/ptl/Crossed(atom/movable/AM)
	..()
	if (QDELETED(src))
		return
	if (isliving(AM) && !isintangible(AM))
		if (!src.source.burn_living(AM, src.source.laser_power())) //burn_living() returns 1 if they are gibbed, 0 otherwise
			source.affecting_mobs |= AM

/obj/linked_laser/ptl/Uncrossed(var/atom/movable/AM)
	if(isliving(AM) && source)
		source.affecting_mobs -= AM
	..()

/obj/linked_laser/ptl/proc/burn_all_living_contents()
	for(var/mob/living/L in src.loc)
		if(src.source.burn_living(L,src.source.laser_power()) && source) //returns 1 if they were gibbed
			source.affecting_mobs -= L

/obj/linked_laser/ptl/become_endpoint()
	..()
	var/turf/next_turf = get_next_turf()
	if (next_turf?.density)
		src.source.blocking_objects |= next_turf
	for (var/obj/object in next_turf)
		if (src.is_blocking(object))
			src.source.blocking_objects |= object

/obj/linked_laser/ptl/release_endpoint()
	..()
	var/turf/next_turf = get_next_turf()
	src.source.blocking_objects -= next_turf
	for (var/obj/object in next_turf)
		if (src.is_blocking(object))
			src.source.blocking_objects -= object

/obj/linked_laser/ptl/disposing()
	src.remove_simple_light("laser_beam")
	src.next?.previous = null
	src.previous?.next = null
	..()


///This is a stupid singleton sink that exists so that lasers that hit the edge of the z-level have something to connect to
/obj/laser_sink/ptl_seller

/obj/laser_sink/ptl_seller/incident(obj/linked_laser/ptl/laser)
	if (!istype(laser)) //we only care about PTL lasers
		return FALSE
	laser.source.selling_lasers |= laser
	return TRUE

/obj/laser_sink/ptl_seller/exident(obj/linked_laser/ptl/laser)
	laser.source.selling_lasers -= laser

#undef PTLMINOUTPUT
