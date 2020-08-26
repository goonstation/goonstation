#define PTLEFFICIENCY 0.1
#define PTLMAXINPUT 1e12
#define PTLMAXOUTPUT 999e10
#define PTLMINOUTPUT 1e6

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
	var/output = PTLMINOUTPUT		//power output of the beam
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
	var/autorefresh = 1		//whether to autorefresh the browser menu. set to 0 while awaiting input() so it doesn't take focus away.
	var/laser_process_counter = 0
	var/input_number = 0
	var/output_number = 1
	var/input_multi = 1		//for kW, MW, GW etc
	var/output_multi = 1e6
	var/emagged = FALSE
	var/lifetime_earnings = 0

/obj/machinery/power/pt_laser/New()
	..()

	range = max(world.maxx,world.maxy)

	SPAWN_DBG(0.5 SECONDS)
		var/turf/origin = get_rear_turf()
		if(!origin) return //just in case
		dir_loop:
			for(var/d in cardinal)
				var/turf/T = get_step(origin, d)
				for(var/obj/machinery/power/terminal/term in T)
					if(term && term.dir == turn(d, 180))
						terminal = term
						break dir_loop

		if(!terminal)
			status |= BROKEN
			return

		terminal.master = src

		updateicon()

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

/obj/machinery/power/pt_laser/proc/updateicon(var/started_firing = 0)
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
	return min(round((charge/abs(output))*6),6) //how close it is to firing power, not to capacity.

/obj/machinery/power/pt_laser/process()
	if(status & BROKEN)
		return
	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_onln = online
	var/last_llt = load_last_tick
	var/last_firing = firing
	var/dont_update = 0

	if(terminal)
		var/excess = (terminal.surplus() + load_last_tick) //otherwise the charge used by this machine last tick is counted against the charge available to it this tick aaaaaaaaaaaaaa
		if(charging)
			if(excess >= chargelevel)		// if there's power available, try to charge
				var/load = min(capacity-charge, chargelevel)		// charge at set rate, limited to spare capacity
				charge += load		// increase the charge
				add_load(load)		// add the load to the terminal side network
				load_last_tick = load
			else load_last_tick = 0

	if(online) // if it's switched on
		if(!firing) //not firing
			if(charge >= abs(output)) //have power to fire
				if(laser_parts.len == 0)
					start_firing() //creates all the laser objects then activates the right ones
				else
					restart_firing() //if the laser was created already, just activate the existing objects
				dont_update = 1 //so the firing animation runs
				charge -= abs(output)
				if(selling)
					power_sold()
		else if(charge < abs(output)) //firing but not enough charge to sustain
			stop_firing()
		else //firing and have enough power to carry on
			for(var/mob/living/L in affecting_mobs) //has to happen every tick
				if(burn_living(L,abs(output)*PTLEFFICIENCY)) //returns 1 if they are gibbed, 0 otherwise
					affecting_mobs -= L

			if(laser_process_counter > 9)
				process_laser() //fine if it happens less often, just tile burning and hotspot exposure
				laser_process_counter = 0
			else
				laser_process_counter ++

			charge -= abs(output)
			if(selling)
				power_sold()
			else if(blocking_objects.len > 0)
				melt_blocking_objects()

			update_laser()

	// only update icon if state changed
	if(dont_update == 0 && (last_firing != firing || last_disp != chargedisplay() || last_onln != online || ((last_llt > 0 && load_last_tick == 0) || (last_llt == 0 && load_last_tick > 0))))
		updateicon()

	if(autorefresh)
		src.updateDialog()

/obj/machinery/power/pt_laser/proc/power_sold()
	if (round(output) == 0)
		return FALSE

	var/output_mw = output / 1e6

	#define BUX_PER_SEC_CAP 5000 //at inf power, generate 5000$/tick, also max amt to drain/tick
	#define ACCEL_FACTOR 69 //our acceleration factor towards cap
	#define STEAL_FACTOR 4 //Adjusts the curve of the stealing EQ (2nd deriv/concavity)

	//For equation + explaination, https://www.desmos.com/calculator/62w5igbqwo
	//Adjusted to give a decent amt. of cash/tick @ 50GW (said to be average hellburn)
	var/generated_moolah =   (2*output_mw*BUX_PER_SEC_CAP)/(2*output_mw + BUX_PER_SEC_CAP*ACCEL_FACTOR) //used if output_mw > 0

	if (output_mw < 0) //steals money since you emagged it
		generated_moolah = (-2*output_mw*BUX_PER_SEC_CAP)/(2*STEAL_FACTOR*output_mw - BUX_PER_SEC_CAP*STEAL_FACTOR*ACCEL_FACTOR)

	lifetime_earnings += generated_moolah

	var/list/accounts = list()
	for(var/datum/data/record/t in data_core.bank)
		if(t.fields["job"] == "Chief Engineer")
			accounts += t
			accounts += t //fuck it
		else if(t.fields["job"] == "Engineer")
			accounts += t

	if(abs(generated_moolah) >= accounts.len*2) //otherwise not enough to split evenly so don't bother I guess
		wagesystem.station_budget += round(generated_moolah/2)
		generated_moolah -= round(generated_moolah/2) //no coming up with $$$ out of air!

		for(var/datum/data/record/t in accounts)
			t.fields["current_money"] += round(generated_moolah/accounts.len)

	#undef STEAL_FACTOR
	#undef ACCEL_FACTOR
	#undef BUX_PER_SEC_CAP

/obj/machinery/power/pt_laser/proc/get_barrel_turf()
	var/x_off = 0
	var/y_off = 0
	switch(dir)
		if(1)
			x_off = 1
			y_off = 2
		if(2)
			x_off = 1
			y_off = 0
		if(4)
			x_off = 2
			y_off = 1
		if(8)
			x_off = 0
			y_off = 1

	var/turf/T = locate(src.x + x_off,src.y + y_off,src.z)

	return T

/obj/machinery/power/pt_laser/proc/get_rear_turf()
	var/x_off = 0
	var/y_off = 0
	switch(dir)
		if(1)
			x_off = 1
			y_off = 0
		if(2)
			x_off = 1
			y_off = 2
		if(4)
			x_off = 0
			y_off = 1
		if(8)
			x_off = 2
			y_off = 1

	var/turf/T = locate(src.x + x_off,src.y + y_off,src.z)

	return T

/obj/machinery/power/pt_laser/proc/start_firing()
	var/turf/T = get_barrel_turf()
	if(!T) return //just in case

	firing = 1
	updateicon(1)

	for(var/dist = 0, dist < range, dist += 1) // creates each field tile
		T = get_step(T, dir)
		if(!T) break //edge of the map
		var/obj/lpt_laser/laser = new/obj/lpt_laser(T)
		laser.dir = dir
		laser.power = round(abs(output)*PTLEFFICIENCY)
		laser.source = src
		laser.active = 0
		src.laser_parts += laser
		src.laser_turfs += T

	melt_blocking_objects()
	update_laser()

/obj/machinery/power/pt_laser/proc/restart_firing()
	firing = 1
	updateicon(1)
	melt_blocking_objects()
	update_laser()

/obj/machinery/power/pt_laser/proc/check_laser_active() //returns number of laser_parts that should be active starting at top of list
	blocking_objects = list()
	var/turf/T = get_barrel_turf()
	if(!T) return //just in case

	for(var/dist = 0, dist < range, dist += 1)
		T = get_step(T, dir)
		if(!T || T.density) return dist
		for(var/obj/O in T)
			if(!istype(O,/obj/window) && !istype(O,/obj/grille) && !ismob(O) && O.density)
				blocking_objects += O
		if(blocking_objects.len > 0) return dist


/obj/machinery/power/pt_laser/proc/stop_firing()
	for(var/obj/lpt_laser/L in laser_parts)
		L.invisibility = 101 //make it invisible
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
			L.invisibility = 0 //make it visible
			L.alpha = max(50,min(255,L.power/39e7)) //255 (max) alpha at 1e11 power, the point at which the laser's most deadly effect happens
			L.active = 1
			L.light.enable()
			L.burn_all_living_contents()
			counter++
		else
			L.invisibility = 101
			L.active = 0
			L.light.disable()

	if(active_num == laser_parts.len)
		selling = 1

/obj/machinery/power/pt_laser/proc/melt_blocking_objects()
	for (var/obj/O in blocking_objects)
		if (istype(O, /obj/machinery/door/poddoor))
			continue
		else if (prob((abs(output)*PTLEFFICIENCY)/5e5))
			O.visible_message("<b>[O.name] is melted away by the [src]!</b>")
			qdel(O)

/obj/machinery/power/pt_laser/add_load(var/amount)
	if(terminal && terminal.powernet)
		terminal.powernet.newload += amount

/obj/machinery/power/pt_laser/proc/update_laser_power()
	if(abs(output) > charge)
		stop_firing()
		return

	for(var/obj/lpt_laser/L in laser_parts)
		L.power = round(abs(output)*PTLEFFICIENCY)
		L.alpha = max(50,min(255,L.power/39e7)) //255 (max) alpha at 1e11 power, the point at which the laser's most deadly effect happens

/obj/machinery/power/pt_laser/attack_ai(mob/user)

	add_fingerprint(user)

	if(status & BROKEN) return

	interacted(user)

/obj/machinery/power/pt_laser/proc/interacted(mob/user)

	if ( (get_dist(src, user) > 1 ))
		if (!isAI(user))
			src.remove_dialog(user)
			user.Browse(null, "window=Power Transmission Laser")
			return

	src.add_dialog(user)

	var/t = "<TT><B>Power Transmission Laser</B><HR><PRE>"

	t += "Efficiency: [PTLEFFICIENCY]<BR><BR>"

	t += "Stored capacity: [engineering_notation(charge)]J ([round(100.0*charge/capacity, 0.1)]%)<BR>"

	t += "Input: [charging ? "Charging" : "Not Charging"]    [charging ? "<B>On</B> <A href = '?src=\ref[src];cmode=1'>Off</A>" : "<A href = '?src=\ref[src];cmode=1'>On</A> <B>Off</B> "]<BR>"

	switch(input_multi)
		if(1)
			t += "Input level: <A href = '?src=\ref[src];set_input=1'>[input_number]</A> <B>W</B> <A href = '?src=\ref[src];input=1'>kW</A> <A href = '?src=\ref[src];input=2'>MW</A> <A href = '?src=\ref[src];input=3'>GW</A> <A href = '?src=\ref[src];input=4'>TW</A><BR>"
		if(1e3)
			t += "Input level: <A href = '?src=\ref[src];set_input=1'>[input_number]</A> <A href = '?src=\ref[src];input=0'>W</A> <B>kW</B> <A href = '?src=\ref[src];input=2'>MW</A> <A href = '?src=\ref[src];input=3'>GW</A> <A href = '?src=\ref[src];input=4'>TW</A><BR>"
		if(1e6)
			t += "Input level: <A href = '?src=\ref[src];set_input=1'>[input_number]</A> <A href = '?src=\ref[src];input=0'>W</A> <A href = '?src=\ref[src];input=1'>kW</A> <B>MW</B> <A href = '?src=\ref[src];input=3'>GW</A> <A href = '?src=\ref[src];input=4'>TW</A><BR>"
		if(1e9)
			t += "Input level: <A href = '?src=\ref[src];set_input=1'>[input_number]</A> <A href = '?src=\ref[src];input=0'>W</A> <A href = '?src=\ref[src];input=1'>kW</A> <A href = '?src=\ref[src];input=2'>MW</A> <B>GW</B> <A href = '?src=\ref[src];input=4'>TW</A><BR>"
		if(1e12)
			t += "Input level: <A href = '?src=\ref[src];set_input=1'>[input_number]</A> <A href = '?src=\ref[src];input=0'>W</A> <A href = '?src=\ref[src];input=1'>kW</A> <A href = '?src=\ref[src];input=2'>MW</A> <A href = '?src=\ref[src];input=3'>GW</A> <B>TW</B><BR>"

	t += "<BR><BR>"

	t += "Output: [online ? "<B>Online</B> <A href = '?src=\ref[src];online=1'>Offline</A>" : "<A href = '?src=\ref[src];online=1'>Online</A> <B>Offline</B> "]<BR>"

	switch(output_multi)
		if(1e6)
			t += "Output level: <A href = '?src=\ref[src];set_output=1'>[output_number]</A> <B>MW</B> <A href = '?src=\ref[src];output=3'>GW</A> <A href = '?src=\ref[src];output=4'>TW</A><BR>"
		if(1e9)
			t += "Output level: <A href = '?src=\ref[src];set_output=1'>[output_number]</A> <A href = '?src=\ref[src];output=2'>MW</A> <B>GW</B> <A href = '?src=\ref[src];output=4'>TW</A><BR>"
		if(1e12)
			t += "Output level: <A href = '?src=\ref[src];set_output=1'>[output_number]</A> <A href = '?src=\ref[src];output=2'>MW</A> <A href = '?src=\ref[src];output=3'>GW</A> <B>TW</B><BR>"

	t += "<BR><br>lifetime earnings:<br>[engineering_notation(lifetime_earnings)] credits</PRE><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</TT>"
	user.Browse(t, "window=Power Transmission Laser;size=460x300")
	onclose(user, "Power Transmission Laser")
	return

/obj/machinery/power/pt_laser/Topic(href, href_list)
	..()

	if (usr.stat || usr.restrained() )
		return

	if (( usr.using_dialog_of(src) && ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (isAI(usr)))
		if( href_list["close"] )
			usr.Browse(null, "window=Power Transmission Laser")
			src.remove_dialog(usr)
			return

		else if( href_list["cmode"] )
			charging = !charging
			updateicon()

		else if( href_list["online"] )
			online = !online
			if(!online) stop_firing()
			updateicon()

		else if( href_list["input"] )
			var/i = text2num(href_list["input"])

			switch(i)
				if(0)
					input_multi = 1
				if(1)
					input_multi = 1e3
				if(2)
					input_multi = 1e6
				if(3)
					input_multi = 1e9
				if(4)
					input_multi = 1e12

			chargelevel = input_multi*input_number

		else if (href_list["set_input"])
			autorefresh = 0
			var/change = input(usr,"Input (0-999):","Enter desired input",input_number) as num
			autorefresh = 1
			if(!isnum(change)) return
			input_number = min(max(0, change),999)

			chargelevel = input_multi*input_number

		else if( href_list["output"] )
			var/i = text2num(href_list["output"])

			switch(i)
				if(2)
					output_multi = 1e6
				if(3)
					output_multi = 1e9
				if(4)
					output_multi = 1e12

			output = output_multi*output_number

			update_laser_power()

		else if (href_list["set_output"])
			autorefresh = 0
			var/change
			if (emagged)
				change = input(usr,"Output (-999-999):","Enter desired output",output) as num
				if(!isnum(change)) return
				output_number = min(max(-999, change),999)
			else
				change = input(usr,"Output (1-999):","Enter desired output",output) as num
				if(!isnum(change)) return
				output_number = min(max(1, change),999)
			autorefresh = 1
			updateicon() //so that the charge display updates

			output = output_multi*output_number

			update_laser_power()

		src.updateUsrDialog()

	else
		usr.Browse(null, "window=Power Transmission Laser")
		src.remove_dialog(usr)

	return

/obj/machinery/power/pt_laser/attack_hand(mob/user)

	add_fingerprint(user)

	if(status & BROKEN) return

	interacted(user)

/obj/machinery/power/pt_laser/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				status |= BROKEN
				updateicon()
		if(3.0)
			if (prob(25))
				status |= BROKEN
				updateicon()
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
	invisibility = 101
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER
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

	SPAWN_DBG(0)
		alpha = max(50,min(255,power/39e7)) //255 (max) alpha at 1e11 power, the point at which the laser's most deadly effect happens
		if(active)
			if(istype(src.loc, /turf) && power > 5e7)
				src.loc:hotspot_expose(power/1e5,5) //1000K at 100MW
			if(istype(src.loc, /turf/simulated/floor) && prob(power/1e6))
				src.loc:burn_tile()

			for (var/mob/living/L in src.loc)
				if (isintangible(L))
					continue
				if (!burn_living(L,power) && source) //burn_living() returns 1 if they are gibbed, 0 otherwise
					if (!source.affecting_mobs.Find(L))
						source.affecting_mobs.Add(L)

	..()

/obj/lpt_laser/ex_act(severity)
	return

/obj/lpt_laser/HasEntered(var/atom/movable/AM)
	if (src.active && isliving(AM) && !isintangible(AM))
		if (!burn_living(AM,power) && source) //burn_living() returns 1 if they are gibbed, 0 otherwise
			if (!source.affecting_mobs.Find(AM))
				source.affecting_mobs.Add(AM)

/obj/lpt_laser/Uncrossed(var/atom/movable/AM)
	if(isliving(AM) && source)
		source.affecting_mobs -= AM

/obj/lpt_laser/proc/burn_all_living_contents()
	for(var/mob/living/L in src.loc)
		if(burn_living(L,power) && source) //returns 1 if they were gibbed
			source.affecting_mobs -= L

/obj/proc/burn_living(var/mob/living/L,var/power = 0)
	if(power < 10) return
	if(isintangible(L)) return // somehow flocktraces are still getting destroyed by the laser. maybe this will fix it

	if(prob(min(power/1e5,50))) L.emote("scream") //might be spammy if they stand in it for ages, idk

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
			L.elecgib()
			return 1 //tells the caller to remove L from the laser's affecting_mobs
		if(1e11+1 to INFINITY) //you really, REALLY fucked up this time buddy
			L.unlock_medal("For Your Ohm Good", 1)
			L.visible_message("<b>[L.name] is detonated by the [src]!</b>")
			L.blowthefuckup(min(1+round(power/1e12),20),0)
			return 1 //tells the caller to remove L from the laser's affecting_mobs

	return 0
