///Station's transception anrray, used for cargo I/O operations on maps that include one
var/global/obj/machinery/communications_dish/transception/transception_array

//Cost to "kick-start" a transception, charged against area APC in cell units of power
#define ARRAY_STARTCOST 80
//Cost to follow through on the transception, charged against grid in grid units of power
#define ARRAY_TELECOST 2500

//Alert codes for the transception array-to-pad "handshake"
#define TRANSCEIVE_BUSY 0
#define TRANSCEIVE_NOPOWER 1
#define TRANSCEIVE_POWERWARN 2
#define TRANSCEIVE_NOWIRE 3
#define TRANSCEIVE_OK 4

//Minimum required interval between transceptions, on the array side
#define TRANSCEPTION_COOLDOWN 0.1

//Bounds for internal capacitor charging management; can be adjusted within these ranges by the array control computer
#define MIN_FREE_POWER 10 KILO WATTS
#define MAX_FREE_POWER 200 KILO WATTS
#define MAX_CHARGE_RATE 50 KILO WATTS

//Transception array's fully-repaired state number
#define TRSC_FULLREPAIR 8

/*
Breakdown of each transception (sending or receiving of a thing through the transception system), as happens through standard cargo operations:

If purchasing an item, it'll be put in the shipping market's pending crates queue, to be pulled from later

Interlink computer sends an instruction (build_command), optionally with an index from that queue (presence of this index makes it a "receive" signal)

Transception pad receives its signal, and attempts to operate (attempt_transceive); this proc takes care of checking whether the pad and array can
serve the transception request, and if they can, delegates the actual receiving or sending to receive_a_thing or send_a_thing respectively

send_a_thing passes the things it sends into the shipping market, assuming they're of a compatible type

receive_a_thing pulls a thing out of a queue (shipping market or direct queue) when the transception starts,
and delivers it to the pad after a few seconds, or returns it to the queue it came from if the transception fails
*/

/obj/machinery/communications_dish/transception
	name = "Transception Array"
	desc = "Sends and receives both energy and matter over a considerable distance. Questionably safe."
	icon = 'icons/obj/machines/transception.dmi'
	icon_state = "array"
	bound_height = 64
	bound_width = 96
	mats = 0

	///Whether array is currently transceiving (interfacing with a pad for the process of sending or receiving a thing)
	var/is_transceiving = FALSE
	///Beam overlay (this was made an object overlay for the purpose of having access to flick)
	var/obj/overlay/telebeam

	///Determines if failsafe threshold is equipment power threshold plus transception cost (true) or transception cost (false).
	var/use_standard_failsafe = TRUE
	///Whether array permits transception (false means just comms); disabled by the failsafe when power gets too low
	var/primed = TRUE

	///Internal capacitor; cell installed inside the array itself. Draws from grid surplus when available, configurable from the array computer.
	var/obj/item/cell/intcap = null
	///Whether the array's conditions for refilling its internal capacitor are satisfied; used for load logic and overlay control
	var/intcap_charging = FALSE
	///Whether the door for the internal capacitor's compartment is open
	var/intcap_door_open = FALSE
	///How fast the internal capacitor will attempt to draw down grid power while intcap_charging is true
	var/intcap_draw_rate = 10 KILO WATTS
	///Amount of surplus past intcap_draw_rate that's required for charging, as a safeguard against spikes in demand
	var/grid_surplus_threshold = 20 KILO WATTS

	//If the internal capacitor is sabotaged, it will rupture, damaging the capacitor cabinet and bringing the array offline.
	///This condition tracks the progress of array repair; status of 8 (defined above, change if process changes) indicates full condition
	var/repair_status = TRSC_FULLREPAIR

	New()
		. = ..()
		src.intcap = new /obj/item/cell(src)
		src.intcap.give(1000)
		src.telebeam = new /obj/overlay/transception_beam()
		src.vis_contents += telebeam
		src.UpdateIcon()
		if(!transception_array)
			transception_array = src

	power_change()
		. = ..()
		src.UpdateIcon()

	process()
		. = ..()
		if(!(status & BROKEN))
			src.charge_intcap()
			if(!src.primed)
				src.attempt_restart()
			src.UpdateIcon() //because of apc/intcap reporting, mainly

	///Respond to a pad's inquiry of whether a transception can occur
	proc/can_transceive(var/pad_netnum)
		. = TRANSCEIVE_BUSY
		if(src.is_transceiving)
			return
		if(!powered() || !src.primed || status & BROKEN)
			return TRANSCEIVE_NOPOWER
		if(src.failsafe_inquiry())
			return TRANSCEIVE_POWERWARN
		var/datum/powernet/powernet = src.get_direct_powernet()
		var/netnum = powernet.number
		if(netnum != pad_netnum)
			return TRANSCEIVE_NOWIRE
		return TRANSCEIVE_OK

	///Respond to a pad's request to do a transception; if successful, do the transception animation, power draw and cooldown
	proc/transceive(var/pad_netnum)
		. = FALSE
		if(src.is_transceiving)
			return
		if(!powered() || !src.primed)
			return
		if(src.failsafe_inquiry())
			return
		var/datum/powernet/powernet = src.get_direct_powernet()
		var/netnum = powernet.number
		if(netnum != pad_netnum)
			return
		if(!src.pay_startcost(ARRAY_STARTCOST))
			return
		src.is_transceiving = TRUE
		use_power(ARRAY_TELECOST)
		playsound(src.loc, 'sound/effects/mag_forcewall.ogg', 50, 0)
		flick("beam",src.telebeam)
		SPAWN(TRANSCEPTION_COOLDOWN)
			src.is_transceiving = FALSE
		return TRUE

	///Attempt to pay the "kick-start" cost for transception; uses internal capacitor first, then area power cell
	proc/pay_startcost(var/use_amount)
		var/cost_to_apc = use_amount
		if(src.intcap && src.intcap.charge > 0)
			if(src.intcap.charge >= use_amount) //can use internal capacitor to fully cover cost, skip the APC calcs
				return use_intcap(use_amount)
			else //internal capacitor lacks enough charge to handle the kick-start solo; prepare to expend from APC
				cost_to_apc -= src.intcap.charge
		var/obj/machinery/power/apc/AC = get_local_apc(src)
		if (!AC)
			return 0
		var/obj/item/cell/C = AC.cell
		if (!C || C.charge < cost_to_apc)
			return 0
		else
			C.use(cost_to_apc)
			if(cost_to_apc < use_amount)
				return use_intcap(use_amount - cost_to_apc)
			return 1

	///Checks status of local APC, activates failsafe if power is insufficient (30% plus 1 startcost with standard failsafe, 1 startcost otherwise)
	proc/failsafe_inquiry() //returns true if failsafe kicked in
		var/obj/machinery/power/apc/AC = get_local_apc(src)
		if (!AC)
			return
		if (AC && !AC.cell)
			return
		var/obj/item/cell/C = AC.cell
		var/combined_cost = (0.3 * C.maxcharge) + ARRAY_STARTCOST
		if (use_standard_failsafe && C.charge < combined_cost)
			playsound(src.loc, 'sound/effects/manta_alarm.ogg', 50, 1)
			src.primed = FALSE
			src.UpdateIcon()
			. = TRUE
		else if(C.charge <= ARRAY_STARTCOST)
			playsound(src.loc, 'sound/effects/manta_alarm.ogg', 50, 1)
			src.primed = FALSE
			src.UpdateIcon()
			. = TRUE

	///When array has failsafe active, this is called each machine tick to see if power has sufficiently recovered to restart transception
	proc/attempt_restart()
		var/obj/machinery/power/apc/AC = get_local_apc(src)
		if (!AC)
			return
		if (AC && !AC.cell)
			return
		var/obj/item/cell/C = AC.cell
		var/combined_cost
		if (use_standard_failsafe) //slightly over failsafe values in each case so it doesn't just turn right back on again
			combined_cost = (0.4 * C.maxcharge) + ARRAY_STARTCOST
		else
			combined_cost = (0.1 * C.maxcharge) + ARRAY_STARTCOST
		if (C.charge > combined_cost)
			playsound(src.loc, 'sound/machines/shieldgen_startup.ogg', 50, 1)
			src.primed = TRUE
			src.UpdateIcon()
			. = TRUE
		return

	proc/charge_intcap()
		if(src.intcap && src.intcap_draw_rate > 0)
			if(src.intcap.rigged)
				intcap_failure()
				return

			var/datum/powernet/powernet = src.get_direct_powernet()

			//if we're not charging a cell yet, figure out what we'd be billing the powernet if we were
			var/total_load = src.intcap_charging ? powernet.load : powernet.load + src.intcap_draw_rate

			if(powernet.avail - total_load >= src.grid_surplus_threshold) //netexcess exists but... isn't ever actually set up?
				src.intcap_charging = TRUE
				if(src.intcap.charge < src.intcap.maxcharge)
					var/yield_to_cell = src.intcap_draw_rate * CELLRATE
					var/final_draw = src.intcap_draw_rate
					//this bit is so you don't spend more on charge than you actually need to charge the cell
					if(intcap.charge + yield_to_cell > src.intcap.maxcharge)
						yield_to_cell = src.intcap.maxcharge - src.intcap.charge
						final_draw = yield_to_cell * 500
					src.intcap.give(yield_to_cell)
					powernet.newload += final_draw
					var/area/arrayarea = get_area(src) //gotta let the grid know!
					arrayarea.use_power(final_draw,EQUIP)
			else
				src.intcap_charging = FALSE
		else
			src.intcap_charging = FALSE

	///Layer for using internal capacitor; separated to intercept rigged cells and handle with custom damage behavior
	proc/use_intcap(var/use_amount)
		. = TRUE
		if(src.intcap.rigged)
			intcap_failure()
			. = FALSE
		else
			src.intcap.use(use_amount)

	///Sabotaged cells, instead of blowing out the turf, will blow out the associated microvoltage cabinet and bring the array offline
	proc/intcap_failure()
		src.intcap.rigged = FALSE
		src.intcap_charging = FALSE
		src.status |= BROKEN
		src.primed = FALSE
		src.intcap_door_open = FALSE
		src.repair_status = 0
		src.UpdateIcon()
		if (intcap.rigger)
			message_admins("[key_name(intcap.rigger)]'s rigged cell damaged the transception array at [log_loc(src)].")
			logTheThing(LOG_COMBAT, intcap.rigger, "'s rigged cell damaged the transception array at [log_loc(src)].")

		src.visible_message("<span class='alert'><b>[src]'s internal capacitor compartment explodes!</b></span>")

		for(var/client/C in clients)
			playsound(C.mob, 'sound/effects/explosionfar.ogg', 35, 0)

		var/epicenter = get_turf(src)
		playsound(epicenter, "explosion", 90, 1)
		//this doesn't actually explode because turf safe explosions don't respect "space" (ocean) turfs, and I'd like surroundings not punctured

		SPAWN(0)
			qdel(src.intcap)
			src.intcap = null

	ex_act(severity)
		return //it's a tough critter if you're not damaging it from the inside

/obj/machinery/communications_dish/transception/attack_hand(mob/user)
	if(src.intcap && intcap_door_open)
		boutput(user, "<span class='notice'>You remove \the [intcap] from the cabinet's cell compartment.</span>")
		playsound(src, 'sound/items/Deconstruct.ogg', 40, 1)

		user.put_in_hand_or_drop(src.intcap)
		src.intcap = null
		return
	..()

/obj/machinery/communications_dish/transception/attackby(obj/item/I, mob/user)
	src.add_fingerprint(user)
	if(status & BROKEN && !istype(I, /obj/item/grab/))
		var/tell_you_what_to_do_next = TRUE //probably-simpler way to tell people what to do next

		if (isweldingtool(I))
			if (src.repair_status <= 2)
				boutput(user, "You start repairing the damaged sections of the outer cabinet plating.")
				actions.start(new/datum/action/bar/icon/array_repair_weld(user,I,src), user)
				tell_you_what_to_do_next = FALSE

		else if (iswrenchingtool(I))
			if (src.repair_status == 3 || src.repair_status == 7)
				var/cursed_check = src.repair_status - 3
				boutput(user, "You start [cursed_check ? "reinstalling" : "removing"] the rod retention bolts.")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, 6 SECONDS, /obj/machinery/communications_dish/transception/proc/wrench_cabinet,\
				list(user), I.icon, I.icon_state, null, null)
				tell_you_what_to_do_next = FALSE

		else if (ispryingtool(I))
			if (src.repair_status == 4)
				boutput(user, "You start prying out the damaged frame rods.")
				playsound(src.loc, 'sound/items/Crowbar.ogg', 75, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, 4 SECONDS, /obj/machinery/communications_dish/transception/proc/pry_cabinet,\
				list(user), I.icon, I.icon_state, null, null)
				tell_you_what_to_do_next = FALSE

		else if(istype(I, /obj/item/sheet))
			if (src.repair_status == 5)
				var/obj/item/sheet/S = I
				if (S.material && S.material.material_flags & MATERIAL_METAL)
					S.change_stack_amount(-1)
					boutput(user, "You install a new compartment door.")
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					src.repair_status++
					src.UpdateIcon()
					tell_you_what_to_do_next = FALSE

		else if(istype(I, /obj/item/rods))
			if (src.repair_status == 6)
				var/obj/item/rods/R = I
				if (R.material && R.material.material_flags & MATERIAL_METAL && R.amount > 1)
					R.change_stack_amount(-2)
					boutput(user, "You install new structural rods.")
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					src.repair_status++
					src.UpdateIcon()
					tell_you_what_to_do_next = FALSE

		if (tell_you_what_to_do_next)
			switch (src.repair_status)
				if(0 to 2)
					boutput(user, "The array looks pretty beat. A good place to start would be welding the microvoltage cabinet's plating.")
				if(3)
					boutput(user, "The cabinet is mostly back together, but some of the rods are shredded. There are bolts holding them in place.")
				if(4)
					boutput(user, "The bolts for the broken rods have been removed, but it seems they'll need some prying to come out.")
				if(5)
					boutput(user, "With broken rods gone, this seems like a good time to grab some metal sheets and make a new compartment door.")
				if(6)
					boutput(user, "The internal capacitor's microvoltage cabinet seems intact now. Some rods for the frame would be good.")
				if(7)
					boutput(user, "The newly-repaired rods seem a bit shaky; they haven't been bolted in yet.")
	else
		if (ispryingtool(I))
			boutput(user, "You [intcap_door_open ? "close" : "open"] the internal capacitor cabinet's cell compartment.")
			src.intcap_door_open = !src.intcap_door_open
			src.UpdateIcon()
		else if(!src.intcap && intcap_door_open && istype(I,/obj/item/cell))
			boutput(user, "You install [I] into the cabinet's cell compartment.")
			user.u_equip(I)
			I.set_loc(src)
			src.intcap = I
		else
			..(I,user)

/obj/machinery/communications_dish/transception/proc/wrench_cabinet(mob/user)
	var/cursed_check = src.repair_status - 3
	boutput(user, "You finish [cursed_check ? "reinstalling" : "removing"] the rod retention bolts.")
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	src.repair_status++
	if(src.repair_status == TRSC_FULLREPAIR)
		src.status &= ~BROKEN
	src.UpdateIcon()

/obj/machinery/communications_dish/transception/proc/pry_cabinet(mob/user)
	boutput(user, "You finish prying out the damaged rods.")
	playsound(src.loc, 'sound/items/Crowbar.ogg', 75, 1)
	src.repair_status++
	src.UpdateIcon()

/datum/action/bar/icon/array_repair_weld
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	id = "array_repair_weld"
	icon = 'icons/obj/items/tools/weldingtool.dmi'
	icon_state = "weldingtool-on"
	var/mob/living/user
	var/obj/weldingtool
	var/obj/machinery/communications_dish/transception/target

	New(usermob,tool,array)
		user = usermob
		weldingtool = tool
		target = array
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(user, target) > 0 || user == null || target == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(user, target) > 0 || user == null || target == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		src.loopStart()

	loopStart()
		..()
		if (!isweldingtool(weldingtool) || !istype(target))
			logTheThing(LOG_DEBUG, null, "Transception array welding action bar was passed improper objects. Somehow.")
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		if(BOUNDS_DIST(user, target) > 0 || user == null || target == null || !user.find_in_hand(weldingtool))
			..()
			interrupt(INTERRUPT_ALWAYS)
			return

		if(weldingtool:try_weld(user, 1))
			target.repair_status++
			target.UpdateIcon()
		else
			interrupt(INTERRUPT_ALWAYS)
			return

		if(target.repair_status > 2)
			user.show_text("You finish welding the array cabinet.", "blue")
			..()
			return

		src.onRestart()

/obj/machinery/communications_dish/transception/update_icon()
	if(repair_status < TRSC_FULLREPAIR)
		src.icon_state = "array_busted[repair_status]"
	else
		src.icon_state = "array[intcap_door_open ? "_panelopen" : null]"

	if(powered() && !(status & BROKEN))
		var/image/commglow = SafeGetOverlayImage("commglow", 'icons/obj/machines/transception.dmi', "powered")
		commglow.plane = PLANE_ABOVE_LIGHTING
		UpdateOverlays(commglow, "commglow", 0, 1)

		var/primed_state = "trsc_sys_warn"
		if(src.primed)
			primed_state = "trsc_sys_primed"
		var/image/primer = SafeGetOverlayImage("primed", 'icons/obj/machines/transception.dmi', primed_state)
		primer.plane = PLANE_ABOVE_LIGHTING
		UpdateOverlays(primer, "primed", 0, 1)

		var/intcap_charger = "allquiet"
		if(src.intcap_charging == TRUE)
			intcap_charger = "intcap_charging"
		var/image/chargelight = SafeGetOverlayImage("charger", 'icons/obj/machines/transception.dmi', intcap_charger)
		chargelight.plane = PLANE_ABOVE_LIGHTING
		UpdateOverlays(chargelight, "charger", 0, 1)

		var/intcap_power = "allquiet"
		if(src.intcap?.charge > 0)
			var/charge_tier = ceil((src.intcap.charge / src.intcap.maxcharge) * 5) * 20
			intcap_power = "intcap[charge_tier]"
		var/image/intcapbar = SafeGetOverlayImage("intcap", 'icons/obj/machines/transception.dmi', intcap_power)
		intcapbar.plane = PLANE_ABOVE_LIGHTING
		UpdateOverlays(intcapbar, "intcap", 0, 1)

		var/apc_power = "allquiet"
		var/obj/machinery/power/apc/AC = get_local_apc(src)
		if(AC?.cell?.charge > 0)
			var/failsafe_maxcharge = AC.cell.maxcharge * 0.7
			var/charge_over_threshold = max(0,AC.cell.charge - (AC.cell.maxcharge * 0.3))
			var/charge_tier = ceil((charge_over_threshold / failsafe_maxcharge) * 5) * 20
			apc_power = "apc[charge_tier]"
		var/image/apcbar = SafeGetOverlayImage("apcbar", 'icons/obj/machines/transception.dmi', apc_power)
		apcbar.plane = PLANE_ABOVE_LIGHTING
		UpdateOverlays(apcbar, "apcbar", 0, 1)
	else
		ClearAllOverlays()

/obj/overlay/transception_beam
	icon = 'icons/obj/machines/transception.dmi'
	icon_state = "allquiet"
	plane = PLANE_ABOVE_LIGHTING
	mouse_opacity = 0

/obj/machinery/computer/trsc_array
	name = "Transception Array Control"
	desc = "Endpoint for status reporting and configuration for a nearby transception array."

	icon = 'icons/obj/computer.dmi'
	icon_state = "alert:0"
	flags = TGUI_INTERACTIVE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WIRECUTTERS | DECON_MULTITOOL

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "TrscArray")
			ui.open()

	ui_data(mob/user)
		var/safe_transceptions
		var/max_transceptions
		var/safe_transception_readout
		var/max_transception_readout

		var/obj/machinery/power/apc/arrayapc = get_local_apc(transception_array)
		var/obj/item/cell/apc_cell = arrayapc.cell
		var/apc_cellstat_formatted
		var/apc_celldiff_val
		if(apc_cell)
			apc_cellstat_formatted = "[round(apc_cell.charge)]/[apc_cell.maxcharge]"
			apc_celldiff_val = apc_cell.charge / apc_cell.maxcharge
			safe_transceptions += round((apc_cell.charge - (0.3 * apc_cell.maxcharge)) / ARRAY_STARTCOST)
			max_transceptions += round(apc_cell.charge / ARRAY_STARTCOST)
		else
			apc_cellstat_formatted = "ERROR"
			apc_celldiff_val = 0

		var/obj/item/cell/arraycell = transception_array.intcap
		var/array_cellstat_formatted
		var/array_celldiff_val
		if(arraycell)
			array_cellstat_formatted = "[round(arraycell.charge)]/[arraycell.maxcharge]"
			array_celldiff_val = arraycell.charge / arraycell.maxcharge
			safe_transceptions += round(arraycell.charge / ARRAY_STARTCOST)
			max_transceptions += round(arraycell.charge / ARRAY_STARTCOST)
		else
			array_cellstat_formatted = "NONE FOUND"
			array_celldiff_val = 0

		if(safe_transceptions > 0)
			safe_transception_readout = "[safe_transceptions]"
		else
			safe_transception_readout = "0"
		if(max_transceptions > 0)
			max_transception_readout = "[max_transceptions]"
		else
			max_transception_readout = "0"

		var/arrayborked = "NOMINAL"
		if(transception_array.repair_status < TRSC_FULLREPAIR)
			arrayborked = "BREACH"

		. = list(
			"apcCellStat" = apc_cellstat_formatted,
			"apcCellDiff" = apc_celldiff_val,
			"arrayCellStat" = array_cellstat_formatted,
			"arrayCellDiff" = array_celldiff_val,
			"sendsSafe" = safe_transception_readout,
			"sendsMax" = max_transception_readout,
			"failsafeThreshold" = transception_array.use_standard_failsafe ? "STANDARD" : "MINIMUM",
			"failsafeStat" = transception_array.primed ? "OPERATIONAL" : "FAILSAFE HALT",
			"drawRateTarget" = transception_array.intcap_draw_rate,
			"surplusThreshold" = transception_array.grid_surplus_threshold,
			"arrayImage" = icon2base64(icon(initial(transception_array.icon), initial(transception_array.icon_state))),
			"arrayHealth" = arrayborked
		)

	ui_act(action, list/params)
		. = ..()
		if (.)
			return
		switch(action)
			if ("toggle_failsafe")
				transception_array.use_standard_failsafe = !(transception_array.use_standard_failsafe)
			if ("set_surplus")
				var/new_surplus_value = params["surplusThreshold"]
				if(text2num(new_surplus_value) != null)
					transception_array.grid_surplus_threshold = clamp(text2num(new_surplus_value), MIN_FREE_POWER, MAX_FREE_POWER)
					. = TRUE
			if ("set_draw_rate")
				var/new_draw_rate = params["drawRateTarget"]
				if(text2num(new_draw_rate) != null)
					transception_array.intcap_draw_rate = clamp(text2num(new_draw_rate), 0, MAX_CHARGE_RATE)
					. = TRUE


#undef ARRAY_STARTCOST
#undef ARRAY_TELECOST
#undef TRANSCEPTION_COOLDOWN

#undef MIN_FREE_POWER
#undef MAX_FREE_POWER
#undef MAX_CHARGE_RATE

#undef TRSC_FULLREPAIR

/obj/machinery/transception_pad
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "neopad"
	name = "\proper transception pad"
	anchored = 1
	density = 0
	layer = FLOOR_EQUIP_LAYER1
	mats = list("MET-2"=5,"CON-2"=2,"CON-1"=5)
	desc = "A sophisticated cargo pad capable of utilizing the station's transception antenna when connected by cable. Keep clear during operation."
	var/is_transceiving = FALSE
	var/frequency = FREQ_TRANSCEPTION_SYS
	var/net_id
	///Fancy identifier, which you can see in the pad's name; lets you know which pad you're operating from the transception interlink computer
	var/pad_id = null

	New()
		START_TRACKING
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, src.frequency)
		src.pad_id = "[pick(vowels_upper)][prob(20) ? pick(consonants_upper) : rand(0,9)]-[rand(0,9)][rand(0,9)][rand(0,9)]"
		src.name = "transception pad [pad_id]"
		..()

	disposing()
		STOP_TRACKING
		..()

	receive_signal(datum/signal/signal)
		if(status & NOPOWER)
			return

		if(!signal || signal.encryption || !signal.data["sender"])
			return

		var/sender = signal.data["sender"]
		if(!sender)
			return

		switch(signal.data["address_1"])
			if("ping")
				var/area/where_pad_is = get_area(src)
				var/name_of_place = where_pad_is.name ? where_pad_is.name : "UNKNOWN"
				var/datum/signal/reply = new
				reply.data["address_1"] = sender
				reply.data["command"] = "ping_reply"
				reply.data["device"] = "PNET_TRANSC_PAD"
				reply.data["netid"] = src.net_id
				reply.data["data"] = name_of_place
				reply.data["padid"] = src.pad_id
				reply.data["opstat"] = src.check_transceive()
				SPAWN(0.5 SECONDS)
					src.post_signal(reply)
			else
				if(signal.data["address_1"] != src.net_id) //this is dumb redundant
					return
				var/sigcommand = lowertext(signal.data["command"])
				switch(sigcommand)
					if("send")
						src.attempt_transceive()
					if("receive")
						var/sigindex = signal.data["data"]
						if(isnum_safe(sigindex))
							src.attempt_transceive(sigindex)


	proc/post_signal(datum/signal/signal,var/newfreq)
		if(!signal)
			return
		var/freq = newfreq
		if(!freq)
			freq = src.frequency

		signal.source = src
		signal.data["sender"] = src.net_id

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, 20, freq)

	///Polls to see if the pad can connect to the array, and if it can, whether said array is capable of completing the pad's request
	proc/check_transceive()
		. = "ERR_NO_ARRAY"
		if(!transception_array)
			return
		var/datum/powernet/powernet = src.get_direct_powernet()
		if(!powernet)
			return "NO_WIRE_ENDPOINT"
		var/netnum = powernet.number
		var/error_code = transception_array.can_transceive(netnum)
		switch(error_code)
			if(TRANSCEIVE_BUSY) //connection's fine it's just busy at this particular time
				return "OK"
			if(TRANSCEIVE_NOPOWER)
				return "ERR_ARRAY_APC"
			if(TRANSCEIVE_POWERWARN)
				return "ARRAY_POWER_LOW"
			if(TRANSCEIVE_NOWIRE)
				return "ERR_WIRE"
			if(TRANSCEIVE_OK)
				return "OK"
			else
				return "ERR_OTHER" //what

	///Try to receive or send a thing, contextually; receive if it was passed an index for pending inbound cargo or a manual receive, send otherwise
	proc/attempt_transceive(var/cargo_index = null,var/obj/manual_receive = null)
		if(src.is_transceiving)
			return
		if(!transception_array)
			return
		var/datum/powernet/powernet = src.get_direct_powernet()
		if(!powernet)
			return
		var/netnum = powernet.number
		if(transception_array.can_transceive(netnum) != TRANSCEIVE_OK)
			return
		if(cargo_index || manual_receive)
			var/obj/inbound_target
			if(manual_receive)
				inbound_target = manual_receive
			else if(shippingmarket.pending_crates[cargo_index])
				inbound_target = shippingmarket.pending_crates[cargo_index]
			else
				return
			if(inbound_target)
				receive_a_thing(netnum,inbound_target)
		else
			send_a_thing(netnum)


	proc/send_a_thing(var/netnumber)
		src.is_transceiving = TRUE
		playsound(src.loc, 'sound/effects/ship_alert_minor.ogg', 50, 0) //outgoing cargo warning (stand clear)
		SPAWN(2 SECONDS)
			flick("neopad_activate",src)
			SPAWN(0.3 SECONDS)
				var/obj/thing2send
				var/list/oofed_nerds = list()
				for(var/atom/movable/AM as obj|mob in src.loc)
					if(AM.anchored) continue
					if(AM == src) continue
					if(istype(AM,/mob/living/carbon/human) && prob(25)) //telefrag
						oofed_nerds += AM
						continue
					if(isobj(AM))
						var/obj/O = AM
						if(istype(O,/obj/storage/crate) || O.artifact)
							thing2send = O
							break //only one thing at a time!
				for(var/nerd in oofed_nerds)
					telefrag(nerd) //did I mention NO MOBS
				if(thing2send && transception_array.transceive(netnumber))
					thing2send.loc = src
					SPAWN(1 SECOND)

						if (istype(thing2send, /obj/storage/crate/biohazard/cdc))
							QM_CDC.receive_pathogen_samples(thing2send)

						else if(istype(thing2send,/obj/storage/crate) || istype(thing2send,/obj/storage/secure/crate))
							var/sold_to_trader = FALSE
							for (var/datum/trader/T in shippingmarket.active_traders)
								if (T.crate_tag == thing2send.delivery_destination)
									shippingmarket.sell_crate(thing2send, T.goods_buy)
									sold_to_trader = TRUE
									break
							if(!sold_to_trader)
								shippingmarket.sell_crate(thing2send)

						else if(thing2send.artifact)
							var/datum/artifact/art = thing2send.artifact
							shippingmarket.sell_artifact(thing2send,art)

						else //how even
							logTheThing("debug", null, null, "Telepad attempted to send [thing2send], which is not a crate or artifact")

				showswirl(src.loc)
				use_power(200) //most cost is at the array
				src.is_transceiving = FALSE


	proc/receive_a_thing(var/netnumber,var/atom/movable/thing2get)
		src.is_transceiving = TRUE
		if(thing2get in shippingmarket.pending_crates)
			shippingmarket.pending_crates.Remove(thing2get) //avoid received thing being queued into multiple pads at once
		playsound(src.loc, 'sound/effects/ship_alert_minor.ogg', 50, 0) //incoming cargo warning (stand clear)
		SPAWN(2 SECONDS)
			flick("neopad_activate",src)
			SPAWN(0.4 SECONDS)
				var/tele_obstructed = FALSE
				var/turf/receive_turf = get_turf(src)
				if(length(receive_turf.contents) < 10) //fail if there is excessive clutter or dense object
					for(var/atom/movable/O in receive_turf)
						if(istype(O,/obj))
							if(O.density)
								tele_obstructed = TRUE
						if(istype(O,/mob/living/carbon/human) && prob(25))
							telefrag(O) //get out the way
				else
					tele_obstructed = TRUE
				if(!tele_obstructed && transception_array.transceive(netnumber))
					thing2get.loc = src.loc
					showswirl(src.loc)
					use_power(200) //most cost is at the array
				else
					shippingmarket.pending_crates.Add(thing2get)
					playsound(src.loc, 'sound/machines/pod_alarm.ogg', 30, 0)
					src.visible_message("<span class='alert'><B>[src]</B> emits an [tele_obstructed ? "obstruction" : "array status"] warning.</span>")
				src.is_transceiving = FALSE


	///Standing on the pad while it's trying to transport cargo is an extremely dumb idea, prepare to get owned
	proc/telefrag(var/mob/living/carbon/human/M)
		var/dethflavor = pick("suddenly vanishes","tears off in the teleport stream","disappears in a flash","violently disintegrates")
		var/limb_ripped = FALSE

		switch(rand(1,4))
			if(1)
				if(M.limbs.l_arm)
					limb_ripped = TRUE
					M.limbs.l_arm.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s arm [dethflavor]!</span>")
			if(2)
				if(M.limbs.r_arm)
					limb_ripped = TRUE
					M.limbs.r_arm.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s arm [dethflavor]!</span>")
			if(3)
				if(M.limbs.l_leg)
					limb_ripped = TRUE
					M.limbs.l_leg.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s leg [dethflavor]!</span>")
			if(4)
				if(M.limbs.r_leg)
					limb_ripped = TRUE
					M.limbs.r_leg.delete()
					M.visible_message("<span class='alert'><B>[M]</B>'s leg [dethflavor]!</span>")

		if(limb_ripped)
			playsound(M.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 75)
			M.emote("scream")
			M.changeStatus("stunned", 5 SECONDS)
			M.changeStatus("weakened", 5 SECONDS)


/obj/machinery/computer/transception
	name = "\improper Transception Interlink"
	desc = "A console capable of remotely connecting to and operating cargo transception pads."
	icon = 'icons/obj/computer.dmi'
	icon_state = "QMpad"
	req_access = list(access_cargo)
	circuit_type = /obj/item/circuitboard/transception
	object_flags = CAN_REPROGRAM_ACCESS
	frequency = FREQ_TRANSCEPTION_SYS
	var/net_id
	///list of transception pads known to the interlink
	var/list/known_pads = list()
	///formatted version of above pad list
	var/formatted_list = null
	///thing to avoid having to update the list every time you click the window
	var/list_is_updated = FALSE
	///variable to queue dialog update after list is refreshed
	var/queue_dialog_update = FALSE

	light_r = 1
	light_g = 0.9
	light_b = 0.7

	New()
		..()
		if(prob(1))
			desc = "A console capable of remotely connecting to and operating cargo transception pads. Smells faintly of cilantro."
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, src.frequency)

	receive_signal(datum/signal/signal)
		if(status & NOPOWER)
			return

		if(!signal || signal.encryption || !signal.data["sender"])
			return

		var/sender = signal.data["sender"]

		if(sender)
			switch(signal.data["command"])
				if("ping_reply")
					if(signal.data["device"] != "PNET_TRANSC_PAD")
						return
					src.list_is_updated = FALSE
					var/device_netid = "DEV_[signal.data["netid"]]" //stored like this so it overwrites existing entries for partial refreshes
					var/list/manifest = new()
					manifest["Identifier"] = signal.data["padid"]
					manifest["INT_TARGETID"] = signal.data["netid"]
					manifest["Location"] = signal.data["data"]
					manifest["Array Link"] = signal.data["opstat"]
					src.known_pads[device_netid] = manifest
					src.queue_dialog_update = TRUE


	process()
		..()
		if(src.queue_dialog_update)
			src.updateUsrDialog()
			src.queue_dialog_update = FALSE

	//construct command packet to send out; specify cargo index for receive, otherwise defaults to send
	proc/build_command(var/com_target,var/cargo_index)
		if(com_target)
			var/datum/signal/yell = new
			yell.data["address_1"] = com_target
			if(cargo_index)
				yell.data["command"] = "receive"
				yell.data["data"] = cargo_index
			else
				yell.data["command"] = "send"
			SPAWN(0.5 SECONDS)
				src.post_signal(yell)


	proc/try_pad_ping()
		if( ON_COOLDOWN(src, "ping", 1 SECOND) || !src.net_id)
			return 1

		src.known_pads.Cut()
		src.list_is_updated = FALSE

		var/datum/signal/newsignal = get_free_signal()
		newsignal.data["address_1"] = "ping"
		newsignal.data["sender"] = src.net_id
		newsignal.source = src
		src.post_signal(newsignal)

	proc/post_signal(datum/signal/signal,var/newfreq)
		if(!signal)
			return
		var/freq = newfreq
		if(!freq)
			freq = src.frequency

		signal.source = src
		signal.data["sender"] = src.net_id

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, 20, freq)

/obj/machinery/computer/transception/attack_hand(var/mob/user as mob)
	if(!src.allowed(user))
		boutput(user, "<span class='alert'>Access Denied.</span>")
		return

	if(..())
		return

	src.add_dialog(user)
	var/HTML

	var/header_thing_chui_toggle = (user.client && !user.client.use_chui) ? {"
		<style type='text/css'>
			body {
				font-family: Verdana, sans-serif;
				background: #222228;
				color: #ddd;
				text-align: center;
				}
			strong {
				color: #fff;
				}
			a {
				color: #6ce;
				text-decoration: none;
				}
			a:hover, a:active {
				color: #cff;
				}
			img, a img {
				border: 0;
				}
		</style>
	"} : {"
	<style type='text/css'>
		/* when chui is on apparently do nothing, cargo cult moment */
	</style>
	"}

	HTML += {"
	[header_thing_chui_toggle]
	<title>Transception Interlink</title>
	<style type="text/css">
		h1, h2, h3, h4, h5, h6 {
			margin: 0.2em 0;
			background: #111520;
			text-align: center;
			padding: 0.2em;
			border-top: 1px solid #456;
			border-bottom: 1px solid #456;
		}

		h2 { font-size: 130%; }
		h3 { font-size: 110%; margin-top: 1em; }
	</style>"}

	var/pending_crate_ct = length(shippingmarket.pending_crates)
	HTML += "PENDING CARGO ITEMS: [pending_crate_ct]<br>"

	src.build_formatted_list()
	if (src.formatted_list)
		HTML += src.formatted_list

	user.Browse(HTML, "window=transception_\ref[src];title=Transception Interlink;size=350x550;")
	onclose(user, "transception_\ref[src]")

/obj/machinery/computer/transception/proc/build_formatted_list()
	if(src.list_is_updated) return
	var/rollingtext = "<h2>Connected Pads <A href='[topicLink("ping")]'>(Ping)</A></h2>" //ongoing contents chunk, begun with head bit

	if(!length(src.known_pads))
		rollingtext += "NO DEVICES DETECTED<br>"
		rollingtext += "Please Use Refresh Ping,<br>"
		rollingtext += "Then Wait For Reply"
	else
		rollingtext += "Receive command will pick from<br>"
		rollingtext += "pending cargo, or immediately import<br>"
		rollingtext += "if pending cargo is label-identical.<br><br>"

	for (var/device_index in src.known_pads)
		var/minitext = ""
		var/list/manifest = known_pads[device_index]
		for(var/field in manifest)
			if(field != "INT_TARGETID")
				minitext += "<strong>[field]</strong> &middot; [tidy_net_data(manifest[field])]<br>"
		rollingtext += minitext
		rollingtext += "<A href='[topicLink("send","\ref[device_index]")]'>Send</A> | "
		rollingtext += "<A href='[topicLink("receive","\ref[device_index]")]'>Receive</A><br><br>"

	src.formatted_list = rollingtext
	src.list_is_updated = TRUE

//aa ee oo
/obj/machinery/computer/transception/proc/topicLink(action, subaction, var/list/extra)
	return "?src=\ref[src]&action=[action][subaction ? "&subaction=[subaction]" : ""]&[extra && islist(extra) ? list2params(extra) : ""]"

/obj/machinery/computer/transception/Topic(href, href_list)
	if(..())
		return

	var/subaction = (href_list["subaction"] ? href_list["subaction"] : null)

	switch (href_list["action"])
		if ("ping")
			src.try_pad_ping()

		if ("receive")
			var/manifest_identifier = locate(subaction) in src.known_pads
			var/list/manifest = known_pads[manifest_identifier]
			if(manifest["Identifier"])
				var/wanted_thing = input(usr,"! WORK IN PROGRESS !","Select Cargo",null) in shippingmarket.pending_crates
				var/thingpos = shippingmarket.pending_crates.Find(wanted_thing)
				if(thingpos)
					src.build_command(manifest["INT_TARGETID"],thingpos)

		if ("send")
			var/manifest_identifier = locate(subaction) in src.known_pads
			var/list/manifest = known_pads[manifest_identifier]
			if(manifest["Identifier"])
				src.build_command(manifest["INT_TARGETID"])

	src.add_fingerprint(usr)


#undef TRANSCEIVE_BUSY
#undef TRANSCEIVE_NOPOWER
#undef TRANSCEIVE_POWERWARN
#undef TRANSCEIVE_NOWIRE
#undef TRANSCEIVE_OK
