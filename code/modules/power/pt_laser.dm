#define PTLEFFICIENCY 0.1
#define PTLMINOUTPUT 1 MEGA WATT

/obj/machinery/power/pt_laser
	name = "power transmission laser"
	icon = 'icons/obj/pt_laser.dmi'
	desc = "Generates a laser beam used to transmit power vast distances across space."
	icon_state = "ptl"
	density = 1
	anchored = ANCHORED_ALWAYS
	dir = 4
	bound_height = 96
	bound_width = 96
	var/output = 0		//power output of the beam
	var/capacity = 1e15
	var/charge = 0
	var/charging = 0
	var/load_last_tick = 0	//how much load did we put on the network last tick?
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
	var/undistributed_earnings = 0
	var/excess = null //for tgui readout
	var/is_charging = FALSE //for tgui readout
	///A list of all laser segments from this PTL that reached the edge of the z-level
	var/list/selling_lasers = list()

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
	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_onln = online
	var/last_llt = load_last_tick
	var/last_firing = firing
	var/dont_update = 0
	var/adj_output = abs(output)

	if(terminal && !(src.status & BROKEN))
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
				start_firing() //creates all the laser objects then activates the right ones
				dont_update = 1 //so the firing animation runs
				charge -= adj_output
		else if(charge < adj_output && (adj_output >= PTLMINOUTPUT)) //firing but not enough charge to sustain
			stop_firing()
		else //firing and have enough power to carry on
			for(var/mob/living/L in affecting_mobs) //has to happen every tick
				if (!locate(/obj/linked_laser/ptl) in get_turf(L)) //safety because Uncross is somehow unreliable
					affecting_mobs -= L
					continue
				if(burn_living(L,adj_output*PTLEFFICIENCY)) //returns 1 if they are gibbed, 0 otherwise
					affecting_mobs -= L

			charge -= adj_output

			if(blocking_objects.len > 0)
				melt_blocking_objects()
			power_sold(adj_output)

	// only update icon if state changed
	if(dont_update == 0 && (last_firing != firing || last_disp != chargedisplay() || last_onln != online || ((last_llt > 0 && load_last_tick == 0) || (last_llt == 0 && load_last_tick > 0))))
		UpdateIcon()

/obj/machinery/power/pt_laser/proc/power_sold(adjusted_output)
	var/proportion = 0
	for (var/obj/linked_laser/ptl/laser in src.selling_lasers)
		proportion += laser.power
	adjusted_output *= proportion

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

	if (src.output < 0) //steals money since you emagged it
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
	if (!src.output)
		return
	var/turf/T = get_barrel_turf()
	if(!T) return //just in case

	firing = TRUE
	UpdateIcon(1)
	src.laser = new(T, src.dir)
	src.laser.source = src
	src.laser.try_propagate()

	melt_blocking_objects()

/obj/machinery/power/pt_laser/proc/laser_power()
	return round(abs(output)*PTLEFFICIENCY)

/obj/machinery/power/pt_laser/proc/stop_firing()
	qdel(src.laser)
	affecting_mobs = list()
	firing = 0
	blocking_objects = list()

/obj/machinery/power/pt_laser/proc/melt_blocking_objects()
	for (var/obj/O in blocking_objects)
		if (istype(O, /obj/machinery/door/poddoor) || istype(O, /obj/laser_sink) || istype(O, /obj/machinery/vehicle) || istype(O, /obj/machinery/bot/mulebot) || isrestrictedz(O.z))
			continue
		else if (prob((abs(output)*PTLEFFICIENCY)/5e5))
			O.visible_message("<b>[O.name] is melted away by the [src]!</b>")
			qdel(O)

/obj/machinery/power/pt_laser/add_load(var/amount)
	if(terminal?.powernet)
		terminal.powernet.newload += amount


/obj/machinery/power/pt_laser/proc/can_fire()
	return abs(src.output) <= src.charge

/obj/machinery/power/pt_laser/proc/update_laser_power()
	src.laser?.traverse(.proc/update_laser_segment)

/obj/machinery/power/pt_laser/proc/update_laser_segment(obj/linked_laser/ptl/laser)
	var/alpha = clamp(((log(10, max(1,laser.source.laser_power() * laser.power)) - 5) * (255 / 5)), 50, 255) //50 at ~1e7 255 at 1e11 power, the point at which the laser's most deadly effect happens
	laser.alpha = alpha

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
			if(online)
				src.start_firing()
			else
				src.stop_firing()
			. = TRUE
		if("setOutput")
			. = TRUE
			if (src.emagged)
				src.output_number = clamp(params["setOutput"], -999, 999)
			else
				src.output_number = clamp(params["setOutput"], 0, 999)
			src.output = src.output_number * src.output_multi
			if(!src.output || !src.can_fire())
				src.stop_firing()
				return
			if (src.firing)
				src.update_laser_power()
			else if (src.online)
				src.start_firing()
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

//why was this on /obj, what the fuck
/obj/machinery/power/pt_laser/proc/burn_living(var/mob/living/L, var/power = 0)
	if(power < 10)
		return
	if(isintangible(L) || L.nodamage || QDELETED(L))
		return

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

ABSTRACT_TYPE(/obj/laser_sink)
///The abstract concept of a thing that does stuff when hit by a laser
/obj/laser_sink //might end up being a component or something
	var/obj/linked_laser/in_laser = null
///When a laser hits this sink, return TRUE on successful connection
/obj/laser_sink/proc/incident(obj/linked_laser/laser)
	return TRUE

///"that's not a word" - 🤓
///When a laser stops hitting this sink
/obj/laser_sink/proc/exident(obj/linked_laser/laser)
	src.in_laser = null

///Another stub, should call traverse on all emitted laser segments with the proc passed through
/obj/laser_sink/proc/traverse(proc_to_call)
	return

/obj/laser_sink/Move()
	src.exident(src.in_laser)
	..()

/obj/laser_sink/set_loc(loc)
	if (loc != src.loc)
		src.exident(src.in_laser)
	..()

/obj/laser_sink/disposing()
	src.exident(src.in_laser)
	..()

#define NW_SE 0
#define SW_NE 1
TYPEINFO(/obj/laser_sink/mirror)
	mats = list("MET-1"=10, "CRY-1"=10, "REF-1"=30)
/obj/laser_sink/mirror
	name = "laser mirror"
	desc = "A highly reflective mirror designed to redirect extremely high energy laser beams."
	anchored = 0
	density = 1
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "laser_mirror0"

	var/obj/linked_laser/out_laser = null
	var/facing = NW_SE

/obj/laser_sink/mirror/attackby(obj/item/I, mob/user)
	if (isscrewingtool(I))
		playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] [src.anchored ? "un" : ""]screws [src] [src.anchored ? "from" : "to"] the floor.</span>")
		src.anchored = !src.anchored
	else
		..()

/obj/laser_sink/mirror/attack_hand(mob/user)
	if (ON_COOLDOWN(src, "rotate", 1 SECOND)) //this is probably a good idea
		return
	var/obj/linked_laser/laser = src.in_laser
	src.exident(laser)
	src.facing = 1 - src.facing
	src.icon_state = "laser_mirror[src.facing]"
	if (laser)
		src.incident(laser)

/obj/laser_sink/mirror/proc/get_reflected_dir(dir)
	//very stupid angle maths
	var/angle
	if (src.facing == NW_SE)
		if (dir in list(WEST, EAST))
			angle = 90
		else
			angle = -90
	else
		if (dir in list(WEST, EAST))
			angle = -90
		else
			angle = 90
	return turn(dir, angle) //rotate based on which way the mirror is facing

/obj/laser_sink/mirror/incident(obj/linked_laser/laser)
	if (src.in_laser) //no infinite loops allowed
		return FALSE
	src.in_laser = laser
	src.out_laser = laser.copy_laser(get_turf(src), src.get_reflected_dir(laser.dir))
	laser.next = src.out_laser
	src.out_laser.try_propagate()
	src.out_laser.icon_state = "[initial(src.out_laser.icon_state)]_corner[src.facing]"
	return TRUE

/obj/laser_sink/mirror/exident(obj/linked_laser/laser)
	qdel(src.out_laser)
	src.out_laser = null
	..()

/obj/laser_sink/mirror/bullet_act(obj/projectile/P)
	//cooldown to prevent client lag caused by infinite projectile loops
	if (istype(P.proj_data, /datum/projectile/laser/heavy) && !ON_COOLDOWN(src, "reflect_projectile", 1 DECI SECOND))
		var/obj/projectile/new_proj = shoot_projectile_DIR(src, P.proj_data, src.get_reflected_dir(P.dir))
		new_proj.travelled = P.travelled
		P.die()
	else
		..()

/obj/laser_sink/mirror/traverse(proc_to_call)
	src.out_laser.traverse(proc_to_call)

TYPEINFO(/obj/laser_sink/splitter)
	mats = list("MET-1"=20, "CRY-2"=20, "REF-1"=30)
/obj/laser_sink/splitter
	name = "beam splitter"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "laser_splitter"
	density = 1
	var/obj/linked_laser/left = null
	var/obj/linked_laser/right = null

//todo: componentize anchoring behaviour
/obj/laser_sink/splitter/attackby(obj/item/I, mob/user)
	if (isscrewingtool(I))
		playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] [src.anchored ? "un" : ""]screws [src] [src.anchored ? "from" : "to"] the floor.</span>")
		src.anchored = !src.anchored
	else if (ispryingtool(I))
		if (ON_COOLDOWN(src, "rotate", 0.3 SECONDS))
			return
		playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		src.dir = turn(src.dir, 90)
	else
		..()

/obj/laser_sink/splitter/incident(obj/linked_laser/laser)
	if (src.in_laser)
		return FALSE
	if (laser.dir != src.dir)
		return FALSE

	src.in_laser = laser

	src.left = src.in_laser.copy_laser(get_turf(src), turn(src.dir, -90))
	src.left.power = laser.power / 2
	src.left.icon = null
	src.left.try_propagate()

	src.right = src.in_laser.copy_laser(get_turf(src), turn(src.dir, 90))
	src.right.power = laser.power / 2
	src.right.icon = null
	src.right.try_propagate()

	return TRUE

/obj/laser_sink/splitter/exident(obj/linked_laser/laser)
	qdel(src.left)
	qdel(src.right)
	src.left = null
	src.right = null
	..()

/obj/laser_sink/splitter/traverse(proc_to_call)
	src.left.traverse(proc_to_call)
	src.right.traverse(proc_to_call)

///This is a stupid singleton sink that exists so that lasers that hit the edge of the z-level have something to connect to
/obj/laser_sink/ptl_seller

/obj/laser_sink/ptl_seller/incident(obj/linked_laser/ptl/laser)
	if (!istype(laser)) //we only care about PTL lasers
		return FALSE
	laser.source.selling_lasers |= laser
	return TRUE

/obj/laser_sink/ptl_seller/exident(obj/linked_laser/ptl/laser)
	laser.source.selling_lasers -= laser

#undef NW_SE
#undef SW_NE
/obj/linked_laser
	icon = 'icons/obj/power.dmi'
	icon_state = "ptl_beam"
	anchored = 2
	density = 0
	luminosity = 1
	mouse_opacity = 0
	///How many laser segments are behind us
	var/length = 0
	///Maximum number of segments in the beam, this exists to prevent nerds from blowing up the server
	var/max_length = 500
	var/obj/linked_laser/next = null
	var/obj/linked_laser/previous = null
	var/turf/current_turf = null
	///Are we at the very end of the beam, and so watching to see if the next turf becomes free
	var/is_endpoint = FALSE
	///A laser sink we're pointing into (null on most beams)
	var/obj/laser_sink/sink = null
	///Relative laser power, modified by splitters etc.
	var/power = 1

/obj/linked_laser/ex_act(severity)
	return

/obj/linked_laser/New(loc, dir)
	..()
	src.length = length
	src.dir = dir
	src.current_turf = get_turf(src)
	RegisterSignal(current_turf, COMSIG_TURF_REPLACED, .proc/current_turf_replaced)
	RegisterSignal(current_turf, COMSIG_TURF_CONTENTS_SET_DENSITY, .proc/current_turf_density_change)

///Attempt to propagate the laser by extending, interacting with sinks etc.
///Separated from New to allow setting up properties on a laser object without passing them as New args
/obj/linked_laser/proc/try_propagate()
	var/turf/next_turf = get_next_turf()
	if (!istype(next_turf) || next_turf == src.current_turf)
		return
	//check the turf for anything that might block us, and notify any laser sinks we find
	var/blocked = FALSE
	if (next_turf.density)
		blocked = TRUE
	else
		for (var/obj/object in next_turf)
			if (istype(object, /obj/laser_sink))
				var/obj/laser_sink/sink = object
				if (sink.incident(src))
					src.sink = sink
			if (src.is_blocking(object))
				blocked = TRUE
				break
	if (src.length >= src.max_length)
		return
	if (!blocked)
		SPAWN(0) //this is here because byond hates recursion depth
			src.extend()
	else
		src.become_endpoint()

/obj/linked_laser/proc/get_next_turf()
	return get_step(src, src.dir)

///Returns a new segment with all its properties copied over (override on child types)
/obj/linked_laser/proc/copy_laser(turf/T, dir)
	var/obj/linked_laser/new_laser = new src.type(T, dir)
	new_laser.length = src.length + 1
	new_laser.power = src.power
	return new_laser

///Set up a new laser on the next turf
/obj/linked_laser/proc/extend()
	src.next = src.copy_laser(src.get_next_turf(), src.dir)
	src.next.previous = src
	src.next.try_propagate()
	src.release_endpoint()

///Called on the last laser in the chain to make it watch for changes to the turf blocking it
/obj/linked_laser/proc/become_endpoint()
	src.is_endpoint = TRUE
	var/turf/next_turf = get_next_turf()
	RegisterSignal(next_turf, COMSIG_TURF_REPLACED, .proc/next_turf_replaced)
	RegisterSignal(next_turf, COMSIG_ATOM_UNCROSSED, .proc/next_turf_updated)
	RegisterSignal(next_turf, COMSIG_TURF_CONTENTS_SET_DENSITY, .proc/next_turf_updated)

///Called when we extend a new laser object and are therefore no longer an endpoint
/obj/linked_laser/proc/release_endpoint()
	src.is_endpoint = FALSE
	var/turf/next_turf = get_next_turf() //this may cause problems when the next turf changes, we'll need to handle re-registering signals waa
	UnregisterSignal(next_turf, COMSIG_TURF_REPLACED)
	UnregisterSignal(next_turf, COMSIG_ATOM_UNCROSSED)
	UnregisterSignal(next_turf, COMSIG_TURF_CONTENTS_SET_DENSITY)

///Kill any upstream laser objects
/obj/linked_laser/disposing()
	UnregisterSignal(src.current_turf, COMSIG_TURF_REPLACED)
	UnregisterSignal(src.current_turf, COMSIG_TURF_CONTENTS_SET_DENSITY)
	SPAWN(0)
		qdel(src.next)
		src.next = null
	src.sink?.exident(src)
	src.sink = null
	if (!QDELETED(src.previous))
		src.previous.become_endpoint()
	if (src.is_endpoint)
		src.release_endpoint()
	..()

///Does something block the laser?
/obj/linked_laser/proc/is_blocking(atom/movable/A)
	if(!istype(A,/obj/window) && !istype(A,/obj/grille) && !ismob(A) && A.density)
		return TRUE

///Does anything on a turf block the laser?
/obj/linked_laser/proc/turf_check(turf/T)
	. = TRUE
	if (!istype(T) || T.density)
		return FALSE
	for (var/obj/object in T)
		if (src.is_blocking(object))
			return FALSE

/obj/linked_laser/Crossed(atom/movable/A)
	..()
	if (istype(A, /obj/laser_sink) && src.previous)
		//we need this to happen after the crossing atom has finished moving otherwise mirrors will delete their own laser obj
		SPAWN(0)
			if (!QDELETED(src.previous))
				src.previous.sink = A
				src.previous.sink.incident(src.previous)
	if (src.is_blocking(A))
		qdel(src)

///Traverses all upstream laser segments and calls proc_to_call on each of them
/obj/linked_laser/proc/traverse(proc_to_call)
	var/obj/linked_laser/ptl/current_laser = src
	do
		call(proc_to_call)(current_laser)
		if (!current_laser.next)
			current_laser.sink?.traverse(proc_to_call)
		current_laser = current_laser.next
	while (current_laser)

//////////////clusterfuck signal registered procs///////////////

///Our turf is being replaced with another
/obj/linked_laser/proc/current_turf_replaced()
	SPAWN(1) //wait for the turf to actually be replaced
		var/turf/T = get_turf(src)
		if (!istype(T) || T.density)
			qdel(src)

///Something is changing density in our current turf
/obj/linked_laser/proc/current_turf_density_change(turf/T, old_density, atom/thing)
	if (src.is_blocking(thing))
		qdel(src)

///The next turf in line is being replaced with another, so check if it's now suitable to put another laser on
/obj/linked_laser/proc/next_turf_replaced()
	src.release_endpoint()
	SPAWN(1) //wait for the turf to actually be replaced
		var/turf/next_turf = get_next_turf()
		if (src.turf_check(next_turf))
			src.extend()
		else
			//if we can't put a new laser there, then register to watch the new turf
			src.become_endpoint()

///Something is crossing into or changing density in the next turf in line
/obj/linked_laser/proc/next_turf_updated()
	var/turf/next_turf = get_next_turf()
	if (turf_check(next_turf))
		src.extend()

/obj/linked_laser/ptl
	name = "laser"
	desc = "A powerful laser beam."
	icon = 'icons/obj/power.dmi'
	icon_state = "ptl_beam"
	event_handler_flags = USE_FLUID_ENTER
	var/obj/machinery/power/pt_laser/source = null
	var/datum/light/light

/obj/linked_laser/ptl/New(loc, dir)
	..()
	src.add_simple_light("laser_beam", list(0, 0.8 * 255, 0.1 * 255, 255))

/obj/linked_laser/ptl/try_propagate()
	. = ..()
	var/turf/T = get_next_turf()
	if (!T) //edge of z_level
		var/obj/laser_sink/ptl_seller/seller = get_singleton(/obj/laser_sink/ptl_seller)
		if (seller.incident(src))
			src.sink = seller
	var/power = src.source.laser_power()
	alpha = clamp(((log(10, max(power,1)) - 5) * (255 / 5)), 50, 255) //50 at ~1e7 255 at 1e11 power, the point at which the laser's most deadly effect happens
	if(istype(src.loc, /turf/simulated/floor) && prob(power/1e6))
		src.loc:burn_tile()

	for (var/mob/living/L in src.loc)
		if (isintangible(L))
			continue
		if (!source.burn_living(L,power)) //burn_living() returns 1 if they are gibbed, 0 otherwise
			source.affecting_mobs |= L

/obj/linked_laser/ptl/copy_laser(turf/T, dir)
	var/obj/linked_laser/ptl/new_laser = ..()
	new_laser.source = src.source
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
	for (var/obj/object in next_turf)
		if (src.is_blocking(object))
			src.source.blocking_objects |= object

/obj/linked_laser/ptl/release_endpoint()
	..()
	var/turf/next_turf = get_next_turf()
	for (var/obj/object in next_turf)
		if (src.is_blocking(object))
			src.source.blocking_objects -= object

/obj/linked_laser/ptl/disposing()
	src.remove_simple_light("laser_beam")
	src.next?.previous = null
	src.previous?.next = null
	..()

/obj/machinery/power/pt_laser/cheat
	charge = INFINITY

#undef PTLEFFICIENCY
#undef PTLMINOUTPUT
