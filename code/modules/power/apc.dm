#define APC_WIRE_IDSCAN 1
#define APC_WIRE_MAIN_POWER1 2
#define APC_WIRE_MAIN_POWER2 3
#define APC_WIRE_AI_CONTROL 4


var/zapLimiter = 0
#define APC_ZAP_LIMIT_PER_5 2

// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire conection to power network

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto


//NOTE: STUFF STOLEN FROM AIRLOCK.DM thx


TYPEINFO(/obj/machinery/power/apc)
	mats = 10

ADMIN_INTERACT_PROCS(/obj/machinery/power/apc, proc/toggle_operating, proc/zapStuff)

/obj/machinery/power/apc
	name = "area power controller"
	desc = "The smaller, more numerous sibling of the SMES. Controls the power of entire rooms, and if the generator goes offline, can supply electricity from an internal cell."
	icon_state = "apc0"
	anchored = ANCHORED
	plane = PLANE_NOSHADOW_ABOVE
	req_access = list(access_engineering_power)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	netnum = -1		// set so that APCs aren't found as powernet nodes
	text = ""
	var/area/area
	var/areastring = null
	var/autoname_on_spawn = 0 // Area.name
	var/obj/item/cell/cell
	var/start_charge = 90				// initial cell charge %
	var/cell_type = 2500				//  0=no cell, otherwise dictate cellcapacity by changing this value. 1 used to be 1000, 2 was 2500
	var/opened = 0
	var/circuit_disabled = 0
	var/shorted = 0
	var/lighting = 3
	var/equipment = 3
	var/environ = 3
	var/operating = 1
	var/do_not_operate = 0
	var/charging = 0
	var/chargemode = 1
	var/chargecount = 0
	var/locked = 1
	var/coverlocked = 1
	var/aidisabled = 0
	var/noalerts = 0
	var/tmp/tdir = null
	var/obj/machinery/power/terminal/terminal = null
	var/lastused_light = 0
	var/lastused_equip = 0
	var/lastused_environ = 0
	var/lastused_total = 0
	var/cycle_load = 0 //distinct from lastused_total; tracks state of expended power through the cycling process
	var/main_status = 0
	var/light_consumption = 0
	var/equip_consumption = 0
	var/environ_consumption = 0
	var/emagged = 0
	var/wiresexposed = 0
	var/apcwires = 15
	var/repair_status = 0 //0: Screwdriver - Disconnect Control Unit ->  1: 4 units of cable - repair autotransformer -> 2: Wrench - Tune autotransformer -> 3: Multitool - Reset control circuitry -> 4: Screwdriver - Reconnect circuitry.
	var/setup_networkapc = 1 //0: Local interface only, 1: Local interface and network interface, 2: network interface only.
	var/net_id = null
	var/host_id = null
	var/timeout = 60 //The time until we auto disconnect (if we don't get a refresh ping)
	var/timeout_alert = 0 //Have we sent a timeout refresh alert?
	var/hardened = 0 // azone/listening post apcs that you dont want fucked with. immune to explosions, blobs, meteors
	var/update_requested = FALSE // Whether the next APC process should include an update (set after turfs are reallocated to this APC's area)

//	luminosity = 1
	var/debug = 0
	mechanics_type_override = /obj/machinery/power/apc
	autoname_north
		name = "Autoname N APC"
		dir = NORTH
		autoname_on_spawn = 1
		pixel_y = 24

		nopoweralert
			noalerts = 1
		noaicontrol
			noalerts = 1
			aidisabled = 1
		hardened	//azone/listening post apcs
			noalerts = 1
			aidisabled = 1
			hardened = 1
			cell_type = 15000

	autoname_east
		name = "Autoname E APC"
		dir = EAST
		autoname_on_spawn = 1
		pixel_x = 20

		nopoweralert
			noalerts = 1
		noaicontrol
			noalerts = 1
			aidisabled = 1

		hardened
			noalerts = 1
			aidisabled = 1
			hardened = 1
			cell_type = 15000

	autoname_south
		name = "Autoname S APC"
		dir = SOUTH
		autoname_on_spawn = 1
		pixel_y = -24

		nopoweralert
			noalerts = 1
		noaicontrol
			noalerts = 1
			aidisabled = 1

		hardened
			noalerts = 1
			aidisabled = 1
			hardened = 1
			cell_type = 15000

	autoname_west
		name = "Autoname W APC"
		dir = WEST
		autoname_on_spawn = 1
		pixel_x = -20

		nopoweralert
			noalerts = 1
		noaicontrol
			noalerts = 1
			aidisabled = 1

		hardened
			noalerts = 1
			aidisabled = 1
			hardened = 1
			cell_type = 15000

/proc/RandomAPCWires()
	//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/apcwires = list(0, 0, 0, 0)
	APCIndexToFlag = list(0, 0, 0, 0)
	APCIndexToWireColor = list(0, 0, 0, 0)
	APCWireColorToIndex = list(0, 0, 0, 0)
	var/flagIndex = 1
	for (var/flag=1, flag<16, flag+=flag)
		var/valid = 0
		while (!valid)
			var/colorIndex = rand(1, 4)
			if (apcwires[colorIndex]==0)
				valid = 1
				apcwires[colorIndex] = flag
				APCIndexToFlag[flagIndex] = flag
				APCIndexToWireColor[flagIndex] = colorIndex
				APCWireColorToIndex[colorIndex] = flagIndex
		flagIndex+=1
	return apcwires



/obj/machinery/power/apc/New()
	..()
	START_TRACKING
	// offset 24 pixels in direction of dir
	//+excluding east and west which is now 20 pixels
	// this allows the APC to be embedded in a wall, yet still inside an area

	tdir = dir		// to fix Vars bug
	// dir = SOUTH

	pixel_x = (tdir & 3)? 0 : (tdir == 4 ? 20 : -20)
	pixel_y = (tdir & 3)? (tdir ==1 ? 24 : -24) : 0

	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
		src.cell = new/obj/item/cell(src)
		cell.maxcharge = cell_type	// cell_type is maximum charge (old default was 1000 or 2500 (values one and two respectively)
		cell.charge = start_charge * cell.maxcharge / 100.0 		// (convert percentage to actual value)

	if (!isnull(src.areastring) && !isnull(get_area_name(src.areastring)))
		src.area = get_area_name(src.areastring)
		src.name = "[src.areastring] APC"
	else
		src.area = get_area(src)
		// making life easy for mappers since 2013
		// 2015 addendum: The fixed name checks are kept for backward compatibility, I'm not gonna manually replace every APC of each of the six maps we have right now.
		if (src.autoname_on_spawn == 1 || (name == "N APC" || name == "E APC" || name == "S APC" || name == "W APC"))
			src.name = "[area.name] APC"
	if (!QDELETED(src.area))
		if(istype(src.area,/area/unconnected_zone)) //if we built in an as-yet APCless zone, we've created a new built zone as a consequence
			unconnected_zone.propagate_zone(get_turf(src))
		else
			src.area.area_apc = src

	src.UpdateIcon()

	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	if (setup_networkapc)
		terminal = new /obj/machinery/power/terminal/netlink(src.loc)
		src.net_id = generate_net_id(src)
	else
		terminal = new/obj/machinery/power/terminal(src.loc)
	terminal.set_dir(tdir)
	terminal.master = src

	SPAWN(0.5 SECONDS)
		src.update()

/obj/machinery/power/apc/disposing()
	STOP_TRACKING
	cell = null
	terminal?.master = null
	terminal = null
	..()

/obj/machinery/power/apc/was_deconstructed_to_frame(mob/user)
	. = ..()
	qdel(src.terminal)
	if(src.area?.area_apc == src)
		src.area.area_apc = null
	src.area = null

/obj/machinery/power/apc/was_built_from_frame(mob/user, newly_built)
	. = ..()
	src.New()

/obj/machinery/power/apc/examine(mob/user)
	. = ..()

	if(status & BROKEN)
		switch(repair_status)
			if(0)
				. += "<br>It's completely busted! It seems you need to use a screwdriver and disconnect the control board first, to begin the repair process.</br>"
			if(1)
				. += "<br>The control board has been disconnected. The autotransformer's wiring is all messed up! You need to grab some cables and fix it.</br>"
			if(2)
				. += "<br>The control panel is disconnected and the autotransformer seems to be in a good condition. You just need to tune it with a wrench now.</br>"
			if(3)
				. += "<br>The autotransformer seems to be working fine now. The next step is resetting the control board with a multitool.</br>"
			if(4)
				. += "<br>The autotransformer is working fine and the control board has been reset! Now you just need to reconnect it with a screwdriver, to finish the repair process.</br>"
		return

	if(user && !user.stat)
		. += "A control terminal for the area electrical systems."
		if(opened)
			. += "The cover is open and the power cell is [ cell ? "installed" : "missing"]."
		else
			. += "The cover is closed."

/obj/machinery/power/apc/proc/toggle_operating()
	src.operating = !src.operating
	src.update()
	UpdateIcon()

/obj/machinery/power/apc/proc/getMaxExcess()
	var/netexcess = 0
	if(terminal)
		if(terminal.powernet)
			netexcess = terminal.powernet.netexcess
			for(var/obj/machinery/power/smes/S in terminal.powernet.nodes)
				if(S.terminal)
					if(S.terminal.powernet)
						netexcess = max(netexcess, S.terminal.powernet.netexcess)
	return netexcess

/obj/machinery/power/apc/proc/zapStuff() // COGWERKS NOTE: disabling calls to this proc for now, it is ruining the live servers
	set name = "Zap Stuff"
	var/atom/target = null
	var/atom/last = src

	var/list/starts = new/list()
	for(var/mob/living/M in oview(5, src))
		if(M.invisibility) continue
		starts.Add(M)

	if(!starts.len) return 0

	target = pick(starts)

	arcFlash(last, target, 500000)

	return 1


// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/update_icon()
	ClearAllOverlays(1)
	if(opened)
		icon_state = "apc1"

		if (cell)
			// if opened, update overlays for cell
			var/image/I_cell = SafeGetOverlayImage("cell", 'icons/obj/power.dmi', "apc-[cell.icon_state]")
			AddOverlays(I_cell, "cell")

	else if(emagged)
		icon_state = "apcemag"
		return
	else if(wiresexposed)
		icon_state = "apcwires"
		var/image/I_wireorange = SafeGetOverlayImage("wireorange", 'icons/obj/power.dmi', "apccut-orange")
		var/image/I_wiredarkred = SafeGetOverlayImage("wiredarkred", 'icons/obj/power.dmi', "apccut-darkred")
		var/image/I_wirewhite = SafeGetOverlayImage("wirewhite", 'icons/obj/power.dmi', "apccut-white")
		var/image/I_wireyellow = SafeGetOverlayImage("wireyellow", 'icons/obj/power.dmi', "apccut-yellow")
		UpdateOverlays(isWireColorCut(APC_WIRE_IDSCAN) ? I_wireorange : null, "wireorange", 0, 1)
		UpdateOverlays(isWireColorCut(APC_WIRE_MAIN_POWER1) ? I_wiredarkred : null, "wiredarkred", 0, 1)
		UpdateOverlays(isWireColorCut(APC_WIRE_MAIN_POWER2) ? I_wirewhite : null, "wirewhite", 0, 1)
		UpdateOverlays(isWireColorCut(APC_WIRE_AI_CONTROL) ? I_wireyellow : null, "wireyellow", 0, 1)

		return
	else
		icon_state = "apc0"

		// if closed, update overlays for channel status
		var/image/I_lock = SafeGetOverlayImage("lock", 'icons/obj/power.dmi', "apcox-[locked]") // 0=blue 1=red
		var/image/I_chrg = SafeGetOverlayImage("charge", 'icons/obj/power.dmi', "apco3-[charging]") // 0=red, 1=yellow/black 2=green
		var/image/I_brke = SafeGetOverlayImage("breaker", 'icons/obj/power.dmi', "apcbr-[operating]")
		var/image/I_lite = SafeGetOverlayImage("lighting", 'icons/obj/power.dmi', "apco1-[lighting]") // 0=red, 1=green, 2=blue
		var/image/I_equp = SafeGetOverlayImage("equipment", 'icons/obj/power.dmi', "apco0-[equipment]")
		var/image/I_envi = SafeGetOverlayImage("environment", 'icons/obj/power.dmi', "apco2-[environ]")

		AddOverlays(I_lock, "lock")
		AddOverlays(I_chrg, "charge")
		AddOverlays(I_brke, "breaker")

		if(operating && !do_not_operate)
			AddOverlays(I_lite, "lighting",)
			AddOverlays(I_equp, "equipment")
			AddOverlays(I_envi, "environment")

/obj/machinery/power/apc/emp_act()
	..()
	if(!src.lighting && !src.equipment && !src.environ ) return //avoid stacking apc emp effects
	if(src.cell)
		src.cell.charge -= 1000
		if (src.cell.charge < 0)
			src.cell.charge = 0
	src.lighting = 0
	src.equipment = 0
	src.environ = 0
	SPAWN(1 MINUTE)
		src.equipment = 3
		src.environ = 3
	return

/obj/machinery/power/apc/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!emagged)		// trying to unlock with an emag card
		if(opened)
			if(user)
				boutput(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			if(user)
				boutput(user, "You must close the panel first")
		else if (setup_networkapc > 1)
			if (user)
				boutput(user, "This APC doesn't have a local interface to hack.")
		else
			flick("apc-spark", src)
			sleep(0.6 SECONDS)
			if(prob(50))
				emagged = 1
				locked = 0
				if (user)
					boutput(user, "You emag the APC interface.")
				UpdateIcon()
				return 1
			else
				if (user)
					boutput(user, "You fail to [ locked ? "unlock" : "lock"] the APC interface.")
				return 0
	return 0

/obj/machinery/power/apc/demag(var/mob/user)
	if (!emagged)
		return 0
	if (user)
		user.show_text("You repair the damage to the [src]'s electronics.", "blue")
	emagged = 0
	return 1

//attack with an item - open/close cover, insert cell, or (un)lock interface


/obj/machinery/power/apc/attackby(obj/item/W, mob/user)
	src.add_fingerprint(user)
	if(status & BROKEN) //APC REPAIR
		if (isscrewingtool(W))
			switch (src.repair_status)
				if (0)
					src.repair_status = 1
					boutput(user, "You loosen the screw terminals on the control board.")
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					return
				if (1)
					src.repair_status = 0
					boutput(user, "You secure the screw terminals on the control board.")
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					return
				if (2)
					boutput(user, SPAN_ALERT("Securing the terminals now without tuning the autotransformer could fry the control board."))
					return
				if (3)
					boutput(user, SPAN_ALERT("The control board must be reset before connection to the autotransformer.."))
					return
				if (4)
					src.repair_status = 0
					boutput(user, "You secure the screw terminals on the control board.")
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)

					if (!src.terminal)
						var/obj/machinery/power/terminal/newTerm = locate(/obj/machinery/power/terminal) in src.loc
						if (istype(newTerm) && !newTerm.master)
							src.terminal = newTerm
							newTerm.master = src
							newTerm.set_dir(initial(src.dir)) //Can't use CURRENT dir because it is set to south on spawn.
						else
							if (src.setup_networkapc)
								src.terminal = new /obj/machinery/power/terminal/netlink(src.loc)
							else
								src.terminal = new /obj/machinery/power/terminal(src.loc)
							src.terminal.master = src
							src.terminal.set_dir(initial(src.dir))

					status &= ~BROKEN //Clear broken flag
					icon_state = initial(src.icon_state)
					operating = 1
					update()
					UpdateIcon()
					return
			return

		else if (istype(W, /obj/item/cable_coil))
			switch (src.repair_status)
				if (0)
					boutput(user, SPAN_ALERT("The control board must be disconnected before you can repair the autotransformer."))
					return
				if (1) //Repair the transformer with a cable.
					var/obj/item/cable_coil/theCoil = W
					if (theCoil.amount >= 4)
						boutput(user, "You unravel some cable..<br>Now repairing the autotransformer's windings.  This could take some time.")
					else
						boutput(user, SPAN_ALERT("Not enough cable! <I>(Requires four pieces)</I>"))
						return
					SETUP_GENERIC_ACTIONBAR(user, src, 10 SECONDS, /obj/machinery/power/apc/proc/fix_wiring,\
					list(theCoil, user), W.icon, W.icon_state, null, null)
					return
				if (2)
					boutput(user, "The autotransformer is already in good condition, it just needs tuning.")
					return
				else
					return

		else if (iswrenchingtool(W))
			switch (src.repair_status)
				if (0)
					boutput(user, SPAN_ALERT("You must disconnect the control board prior to working on the autotransformer."))
				if (1)
					boutput(user, SPAN_ALERT("You must repair the autotransformer's windings prior to tuning it."))
				if (2)
					boutput(user, "You begin to carefully tune the autotransformer.  This might take a little while.")
					SETUP_GENERIC_ACTIONBAR(user, src, 6 SECONDS, /obj/machinery/power/apc/proc/fix_autotransformer,\
					list(user), W.icon, W.icon_state, null, null)
				else
					boutput(user, "The autotransformer is already tuned.")

			return

		else if (ispulsingtool(W))
			switch(src.repair_status)
				if (3)
					boutput(user, SPAN_ALERT("You reset the control board.[prob(10) ? " Takes no time at all, eh?" : ""]"))
					src.repair_status = 4
				if (4)
					boutput(user, "The control board has already been reset. It just needs to be reconnected now.")
				else
					boutput(user, SPAN_ALERT("You need to repair and tune the autotransformer before resetting the control board."))
			return

		return
	if (ispryingtool(W))	// crowbar means open or close the cover
		if(opened)
			opened = 0
			UpdateIcon()
		else
			if(coverlocked)
				boutput(user, "The cover is locked and cannot be opened.")
			else
				opened = 1
				UpdateIcon()
	else if	(istype(W, /obj/item/cell) && opened)	// trying to put a cell inside
		if(cell)
			boutput(user, "There is a power cell already installed.")
		else
			if (user.drop_item())
				W.set_loc(src)
				cell = W
				boutput(user, "You insert the power cell.")
				logTheThing(LOG_STATION, user, "inserted [cell] to APC [src] [log_loc(src)].")
				chargecount = 0
		UpdateIcon()
	else if	(isscrewingtool(W))
		if(opened)
			boutput(user, "Close the APC first")
		else if(emagged)
			boutput(user, "The interface is broken")
		else
			wiresexposed = !wiresexposed
			boutput(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"]")
			UpdateIcon()

	else if (wiresexposed && (issnippingtool(W) || ispulsingtool(W)))
		src.Attackhand(user)

	else if (issilicon(user))
		if (istype(W, /obj/item/robojumper))
			return
		else return src.Attackhand(user)
	else if (istype(get_id_card(W), /obj/item/card/id))			// trying to unlock the interface with an ID card
		if(emagged)
			boutput(user, "The interface is broken")
		else if(opened)
			boutput(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			boutput(user, "You must close the panel")
		else if (setup_networkapc > 1)
			boutput(user, "This APC doesn't have a local interface.")
		else
			if(src.allowed(user))
				locked = !locked
				boutput(user, "You [ locked ? "lock" : "unlock"] the APC interface.")
				UpdateIcon()
			else
				boutput(user, SPAN_ALERT("Access denied."))

/obj/machinery/power/apc/proc/fix_wiring(obj/item/W, mob/user)
	W.change_stack_amount(-4)
	boutput(user, "You repair the autotransformer.")
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	src.repair_status = 2

/obj/machinery/power/apc/proc/fix_autotransformer(mob/user)
	boutput(user, "You tune the autotransformer.")
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	src.repair_status = 3

/obj/machinery/power/apc/attack_ai(mob/user)
	if (src.aidisabled && !src.wiresexposed)
		boutput(user, "AI control for this APC interface has been disabled.")
	else
		return src.Attackhand(user)

// attack with hand - remove cell (if cover open) or interact with the APC

/obj/machinery/power/apc/attack_hand(mob/user)
	if (!can_act(user))
		return

	add_fingerprint(user)

	if(status & BROKEN) return

	interact_particle(user,src)

	if(opened && !isAIeye(user) && !issilicon(user))
		if(cell)
			cell.UpdateIcon()
			user.put_in_hand_or_drop(cell)
			boutput(user, "You remove the power cell.")
			logTheThing(LOG_STATION, user, "removed [cell] from APC [src] [log_loc(src)].")
			src.cell = null
			charging = 0
			src.UpdateIcon()

	else
		// do APC interaction
		src.interacted(user)

// ------------ UI Methods ------------
/obj/machinery/power/apc/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Apc")
		ui.open()

/obj/machinery/power/apc/ui_static_data(mob/user)
	. = list(
		"net_id" = net_id,
		"area_name" = area ? area.name : "Unknown",
		"area_requires_power" = area ? area.requires_power : null,
	)

/obj/machinery/power/apc/ui_data(mob/user)
	. = list(
		"cell_type" = cell_type, // 0=no cell, 1=regular, 2=high-cap (x5) <- old, now it's just 0=no cell, otherwise dictate cellcapacity by changing this value. 1 used to be 1000, 2 was 2500
		"cell_percent" = cell ? cell.percent() : null,
		"cell_present" = !!cell,
		"opened" = opened,
		"circuit_disabled" = circuit_disabled,
		"shorted" = shorted,
		"lighting" = lighting,
		"equipment" = equipment,
		"environ" = environ,
		"operating" = operating,
		"do_not_operate" = do_not_operate,
		"charging" = charging,
		"chargemode" = chargemode,
		"chargecount" = chargecount,
		"locked" = locked,
		"coverlocked" = coverlocked,
		"aidisabled" = aidisabled,
		"noalerts" = noalerts,
		"lastused_light" = lastused_light,
		"lastused_equip" = lastused_equip,
		"lastused_environ" = lastused_environ,
		"lastused_total" = lastused_total,
		"main_status" = main_status,
		"light_consumption" = light_consumption,
		"equip_consumption" = equip_consumption,
		"environ_consumption" = environ_consumption,
		"emagged" = emagged,
		"wiresexposed" = wiresexposed,
		"apcwires" = apcwires,
		"repair_status" = repair_status,
		"host_id" = host_id,
		"setup_networkapc" = setup_networkapc,
		"orange_cut" = isWireColorCut(1),
		"dark_red_cut" = isWireColorCut(2),
		"white_cut" = isWireColorCut(3),
		"yellow_cut" = isWireColorCut(4),
		"can_access_remotely" = can_access_remotely(user),
		"is_ai" = isAI(user),
		"is_silicon" = issilicon(user),
	)

/obj/machinery/power/apc/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	// All actions were copied and altered from /obj/machinery/power/apc/Topic
	. = ..()
	if (.)
		return
	if (!can_act(usr))
		return

	if ((in_interact_range(src, usr) && istype(src.loc, /turf)) || (issilicon(usr) || isAI(usr)))
		switch (action) // If action is valid, return true so ui updates
			if ("onMendWire")
				return onMendWire(usr, params);
			if ("onCutWire")
				return onCutWire(usr, params);
			if ("onPulseWire")
				return onPulseWire(usr, params);
			if ("onBiteWire")
				return onBiteWire(usr, params);
			if ("onCoverLockedChange")
				return onCoverLockedChange(usr, params)
			if ("onOperatingChange")
				return onOperatingChange(usr, params)
			if ("onChargeModeChange")
				return onChargeModeChange(usr, params)
			if ("onPowerChannelEquipmentStatusChange")
				return onPowerChannelEquipmentStatusChange(usr, params)
			if ("onPowerChannelLightingStatusChange")
				return onPowerChannelLightingStatusChange(usr, params)
			if ("onPowerChannelEnvironStatusChange")
				return onPowerChannelEnvironStatusChange(usr, params)
			if ("onOverload")
				return onOverload(usr, params)
			else
				return FALSE
// ------------ End UI Methods ------------


// ------------ Action Callbacks ------------
// Callbacks used by the UI - called from /tgui/packages/tgui/interfaces/Apc.js
/obj/machinery/power/apc/proc/onPowerChannelEquipmentStatusChange(mob/user, list/params)
	if (src.canAccessControls(user))
		if (src.isBlockedAI(user))
			boutput(user, "AI control for this APC interface has been disabled.")
			return FALSE

		var/val = clamp(text2num_safe(params["status"]), 1, 3)

		// Fix for exploit that allowed synthetics to perma-stun intruders by cycling the APC
		// ad infinitum (activating power/turrets for one tick) despite missing power cell (Convair880).
		if ((!src.cell || src.shorted == 1) && (val == 2 || val == 3))
			if (user && ismob(user))
				user.show_text("APC offline, can't toggle power.", "red")
			return FALSE

		logTheThing(LOG_STATION, user, "turned the APC equipment power [(val==1) ? "off" : "on"] at [log_loc(src)].")
		equipment = (val==1) ? 0 : val

		UpdateIcon()
		update()
		return TRUE
	else
		return FALSE

/obj/machinery/power/apc/proc/onPowerChannelLightingStatusChange(mob/user, list/params)
	if (src.canAccessControls(user))
		if (src.isBlockedAI(user))
			boutput(user, "AI control for this APC interface has been disabled.")
			return FALSE

		var/val = clamp(text2num_safe(params["status"]), 1, 3)

		// Same deal.
		if ((!src.cell || src.shorted == 1) && (val == 2 || val == 3))
			if (user && ismob(user))
				user.show_text("APC offline, can't toggle power.", "red")
			return FALSE

		logTheThing(LOG_STATION, user, "turned the APC lighting power [(val==1) ? "off" : "on"] at [log_loc(src)].")
		lighting = (val==1) ? 0 : val

		UpdateIcon()
		update()
		return TRUE
	else
		return FALSE

/obj/machinery/power/apc/proc/onPowerChannelEnvironStatusChange(mob/user, list/params)
	if (src.canAccessControls(user))
		if (src.isBlockedAI(user))
			boutput(user, "AI control for this APC interface has been disabled.")
			return FALSE

		var/val = clamp(text2num_safe(params["status"]), 1, 3)

		// Yep.
		if ((!src.cell || src.shorted == 1) && (val == 2 || val == 3))
			if (user && ismob(user))
				user.show_text("APC offline, can't toggle power.", "red")
			return FALSE

		logTheThing(LOG_STATION, user, "turned the APC environment power [(val==1) ? "off" : "on"] at [log_loc(src)].")
		environ = (val==1) ? 0 :val

		UpdateIcon()
		update()
		return TRUE
	return FALSE

/obj/machinery/power/apc/proc/onMendWire(mob/user, list/params)
	if (!src.canPhysicallyAccess(user))
		boutput(user, "You are too far away to mend a wire!.")
		return FALSE
	if (wiresexposed)
		var/t1 = text2num_safe(params["wire"])
		if (!user.find_tool_in_hand(TOOL_SNIPPING))
			boutput(user, "You need a snipping tool!")
			return FALSE
		else if (src.isWireColorCut(t1))
			src.mend(t1)
			return TRUE
	else
		return FALSE

/obj/machinery/power/apc/proc/onCutWire(mob/user, list/params)
	if (!src.canPhysicallyAccess(user))
		boutput(user, "You are too far away to cut a wire!")
		return FALSE
	if (wiresexposed)
		var/t1 = text2num_safe(params["wire"])
		if (!user.find_tool_in_hand(TOOL_SNIPPING))
			boutput(user, "You need a snipping tool!")
			return FALSE
		else if (!src.isWireColorCut(t1))
			src.cut(t1)
			return TRUE
	else
		return FALSE

/obj/machinery/power/apc/proc/onBiteWire(mob/user, list/params)
	if (issilicon(user) || isAIeye(user))
		boutput(user, "You don't have teeth, dummy!")
		return FALSE
	if (!src.canPhysicallyAccess(user))
		boutput(user, "You are too far away to bite a wire!")
		return FALSE
	if (wiresexposed)
		var/t1 = text2num_safe(params["wire"])
		if (src.isWireColorCut(t1))
			boutput(user, "You can't bite a cut wire.")
			return FALSE
		switch(alert("Really bite the wire off?",,"Yes","No"))
			if("Yes")
				src.bite(t1)
				return TRUE
			if("No")
				return FALSE
	else
		return FALSE

/obj/machinery/power/apc/proc/onPulseWire(mob/user, list/params)
	if (!src.canPhysicallyAccess(user))
		boutput(user, "You are too far away to pulse a wire!")
		return FALSE
	if (wiresexposed)
		var/t1 = text2num_safe(params["wire"])
		if (!user.find_tool_in_hand(TOOL_PULSING))
			boutput(user, "You need a multitool or similar!")
			return FALSE
		else if (src.isWireColorCut(t1))
			boutput(user, "You can't pulse a cut wire.")
			return FALSE
		else
			src.pulse(t1)
			return TRUE
	else
		return FALSE

/obj/machinery/power/apc/proc/onCoverLockedChange(mob/user, list/params)
	if (src.canAccessControls(user))
		if (src.isBlockedAI(user))
			boutput(user, "AI control for this APC interface has been disabled.")
			return FALSE
		coverlocked = params["coverlocked"]
		return TRUE
	else
		return FALSE

/obj/machinery/power/apc/proc/onOperatingChange(mob/user, list/params)
	if (src.canAccessControls(user))
		if (src.isBlockedAI(user))
			boutput(user, "AI control for this APC interface has been disabled.")
			src.updateUsrDialog()
			return FALSE
		operating = params["operating"]
		src.update()
		UpdateIcon()
		return TRUE
	else
		return FALSE

/obj/machinery/power/apc/proc/onChargeModeChange(mob/user, list/params)
	if (src.canAccessControls(user))
		if (src.isBlockedAI(user))
			boutput(user, "AI control for this APC interface has been disabled.")
			return FALSE
		chargemode = !chargemode
		if(!chargemode)
			charging = 0
			UpdateIcon()
		return TRUE
	else
		return FALSE

/obj/machinery/power/apc/proc/onOverload(mob/user, list/params)
	if (issilicon(user) || isAI(user))
		if(isghostdrone(user)) //This does not help the station at all bad bad drones!
			boutput(user, "Your internal law subroutines kick in and prevent you from overloading the lights!")
			return FALSE
		if (src.aidisabled)
			boutput(user, "AI control for this APC interface has been disabled.")
			return FALSE
		message_admins("[key_name(user)] overloaded the lights at [log_loc(src)].")
		logTheThing(LOG_STATION, user, "overloaded the lights at [log_loc(src)].")
		src.overload_lighting()
		return TRUE
	else
		return FALSE
// ------------ End Action Callbacks ------------

// ------------ Callback Helper Procs ------------
/obj/machinery/power/apc/proc/canAccessControls(mob/user)
	if (issilicon(user) || isAI(user))
		return TRUE
	else if (!locked && setup_networkapc < 2) // If the apc is unlocked and access isn't remote then we can access it
		return TRUE
	else
		return FALSE

/obj/machinery/power/apc/proc/isBlockedAI(mob/user)
	return (issilicon(user) || isAI(user)) && src.aidisabled

/obj/machinery/power/apc/proc/canPhysicallyAccess(mob/user)
	return (in_interact_range(src, user) && istype(src.loc, /turf) && !isAI(user))
// ------------ End Callback Helper Procs ------------


/obj/machinery/power/apc/proc/interacted(mob/user)
	if (user.getStatusDuration("stunned") || user.getStatusDuration("knockdown") || user.stat)
		return
	if (!in_interact_range(src, user))
		return
	if (can_access_remotely(user) && src.aidisabled)
		boutput(user, "AI control for this APC interface has been disabled.")
		return
	src.ui_interact(user)

/obj/machinery/power/apc/proc/report()
	return "[area.name] : [equipment]/[lighting]/[environ] ([lastused_equip+lastused_light+lastused_environ]) : [cell? cell.percent() : "N/C"] ([charging])"

/obj/machinery/power/apc/proc/request_update()
	src.update_requested = TRUE

/obj/machinery/power/apc/proc/update()
	if (!QDELETED(src.area))

		var/list/power_levels = src.get_power_levels()
		var/light = power_levels["power_light"]
		var/equip = power_levels["power_equip"]
		var/environ = power_levels["power_environ"]

		for(var/obj/machinery/power/apc/APC in src.area.machines)
			power_levels = APC.get_power_levels()
			light |= power_levels["power_light"]
			equip |= power_levels["power_equip"]
			environ |= power_levels["power_environ"]

		src.area.power_light = light
		src.area.power_equip = equip
		src.area.power_environ = environ

		src.area.power_change() //Note: the power_change() for areas ALREADY deals with relatedArea. Don't put it in the loops here!!

/obj/machinery/power/apc/proc/get_power_levels()
	if(operating && !shorted && !do_not_operate)
		return list(
		"power_light" = (lighting > 1),
		"power_equip" = (equipment > 1),
		"power_environ" = (environ > 1)
		)
	else
		return list(
		"power_light" = 0,
		"power_equip" = 0,
		"power_environ" = 0
		)

/obj/machinery/power/apc/proc/isWireColorCut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	return ((src.apcwires & wireFlag) == 0)

/obj/machinery/power/apc/proc/isWireCut(var/wireIndex)
	var/wireFlag = APCIndexToFlag[wireIndex]
	return ((src.apcwires & wireFlag) == 0)

/obj/machinery/power/apc/proc/get_connection()
	if(status & BROKEN)	return 0
	return 1

/obj/machinery/power/apc/proc/shock(mob/user, prb, bite)
	if(!prob(prb))
		return 0
	var/net = get_connection()		// find the powernet of the connected cable
	if(!net)		// cable is unpowered
		return 0
	return src.apcelectrocute(user, prb, net, bite)

/obj/machinery/power/apc/proc/apcelectrocute(mob/user, prb, netnum, bite)

	if(status == 2)
		return 0

	if(!prob(prb))
		return 0

	if(!netnum)		// unconnected cable is unpowered
		return 0

	var/prot = 1

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.gloves && bite == 0)
			var/obj/item/clothing/gloves/G = H.gloves
			prot = (G.hasProperty("conductivity") ? G.getProperty("conductivity") : 1)
		if (H.limbs.l_arm)
			prot = min(prot,H.limbs.l_arm.siemens_coefficient)
		if (H.limbs.r_arm)
			prot = min(prot,H.limbs.r_arm.siemens_coefficient)

	else if (issilicon(user) || isAI(user))
		return 0

	if(prot <= 0.29)
		return 0

	elecflash(src,power = 2)

	var/shock_damage = 0
	if(cell_type == 2500)	//someone juiced up the grid enough, people going to die!
		shock_damage = min(rand(70,145),rand(70,145))*prot
		cell_type = cell_type - 2000
	else if(cell_type >= 1750)
		shock_damage = min(rand(35,110),rand(35,110))*prot
		cell_type = cell_type - 1600
	else if(cell_type >= 1500)
		shock_damage = min(rand(30,100),rand(30,100))*prot
		cell_type = cell_type - 1000
	else if(cell_type >= 750)
		shock_damage = min(rand(25,90),rand(25,90))*prot
		cell_type = cell_type - 500
	else if(cell_type >= 250)
		shock_damage = min(rand(20,80),rand(20,80))*prot
		cell_type = cell_type - 125
	else if(cell_type >= 100)
		shock_damage = min(rand(20,65),rand(20,65))*prot
		cell_type = cell_type - 50
	else
		return 0

	if (user.bioHolder.HasEffect("resist_electric_heal"))
		var/healing = 0
		healing = shock_damage / 3
		user.HealDamage("All", healing, healing)
		user.take_toxin_damage(0 - healing)
		boutput(user, SPAN_NOTICE("You absorb the electrical shock, healing your body!"))
		return
	else if (user.bioHolder.HasEffect("resist_electric"))
		boutput(user, SPAN_NOTICE("You feel electricity course through you harmlessly!"))
		return

	user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 0, shock_damage)
	boutput(user, SPAN_ALERT("<B>You feel a powerful shock course through your body!</B>"))
	user.unlock_medal("HIGH VOLTAGE", 1)
	if (isliving(user))
		var/mob/living/L = user
		L.Virus_ShockCure(33)
		L.shock_cyberheart(33)
	sleep(0.1 SECONDS)

#ifdef USE_STAMINA_DISORIENT
	var/knockdown = (user.getStatusDuration("knockdown") < shock_damage * 20) ? shock_damage * 20 : 0
	var/stun = (user.getStatusDuration("stunned") < shock_damage * 10) ? shock_damage * 10 : 2
	user.do_disorient(130, knockdown = knockdown, stunned = stun, disorient = 80, remove_stamina_below_zero = 0)
#else
	if(user.getStatusDuration("stunned") < shock_damage * 10)	user.changeStatus("stunned", shock_damage SECONDS)
	if(user.getStatusDuration("knockdown") < shock_damage * 20)	user.changeStatus("knockdown", shock_damage * 2 SECONDS)
#endif
	for(var/mob/M in AIviewers(src))
		if(M == user)	continue
		M.show_message(SPAN_ALERT("[user.name] was shocked by the [src.name]!"), 3, SPAN_ALERT("You hear a heavy electrical crack"), 2)
	return 1


/obj/machinery/power/apc/proc/cut(var/wireColor)
	if (is_incapacitated(usr))
		usr.show_text("Not when you're incapacitated.", "red")
		return

	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor]
	apcwires &= ~wireFlag
	switch(wireIndex)
		if(APC_WIRE_MAIN_POWER1)
			src.shock(usr, 50, 0)			//this doesn't work for some reason, give me a while I'll figure it out
			src.shorted = 1
			src.updateUsrDialog()
		if(APC_WIRE_MAIN_POWER2)
			src.shock(usr, 50, 0)
			src.shorted = 1
			src.updateUsrDialog()
		if (APC_WIRE_AI_CONTROL)
			if (src.aidisabled == 0)
				src.aidisabled = 1
			src.updateUsrDialog()
//		if(APC_WIRE_IDSCAN)		nothing happens when you cut this wire, add in something if you want whatever
	UpdateIcon()

/obj/machinery/power/apc/proc/bite(var/wireColor) // are you fuckin huffing or somethin
	if (is_incapacitated(usr))
		usr.show_text("Not when you're incapacitated.", "red")
		return

	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor]
	apcwires &= ~wireFlag
	switch(wireIndex)
		if(APC_WIRE_MAIN_POWER1)
			src.shock(usr, 90, 1)			//this doesn't work for some reason, give me a while I'll figure it out
			src.shorted = 1
			src.updateUsrDialog()
		if(APC_WIRE_MAIN_POWER2)
			src.shock(usr, 90, 1)
			src.shorted = 1
			src.updateUsrDialog()
		if (APC_WIRE_AI_CONTROL)
			if (src.aidisabled == 0)
				src.aidisabled = 1
			src.updateUsrDialog()
		if(APC_WIRE_IDSCAN) // basically pulse but with a really good chance of dying
			src.shock(usr, 90, 1)
			src.locked = 0
	UpdateIcon()


/obj/machinery/power/apc/proc/mend(var/wireColor)
	if (is_incapacitated(usr))
		usr.show_text("Not when you're incapacitated.", "red")
		return

	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor] //not used in this function
	apcwires |= wireFlag
	switch(wireIndex)
		if(APC_WIRE_MAIN_POWER1)
			if ((!src.isWireCut(APC_WIRE_MAIN_POWER1)) && (!src.isWireCut(APC_WIRE_MAIN_POWER2)))
				src.shorted = 0
				src.shock(usr, 50, 0)
				src.updateUsrDialog()
		if(APC_WIRE_MAIN_POWER2)
			if ((!src.isWireCut(APC_WIRE_MAIN_POWER1)) && (!src.isWireCut(APC_WIRE_MAIN_POWER2)))
				src.shorted = 0
				src.shock(usr, 50, 0)
				src.updateUsrDialog()
		if (APC_WIRE_AI_CONTROL)
			//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
			//aidisabledDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
			if (src.aidisabled == 1)
				src.aidisabled = 0
			src.updateUsrDialog()
//		if(APC_WIRE_IDSCAN)		nothing happens when you cut this wire, add in something if you want whatever
	UpdateIcon()

/obj/machinery/power/apc/proc/pulse(var/wireColor)
	if (is_incapacitated(usr))
		usr.show_text("Not when you're incapacitated.", "red")
		return

	//var/wireFlag = apcWireColorToFlag[wireColor] //not used in this function
	var/wireIndex = APCWireColorToIndex[wireColor]
	switch(wireIndex)
		if(APC_WIRE_IDSCAN)			//unlocks the APC for 30 seconds, if you have a better way to hack an APC I'm all ears
			src.locked = 0
			SPAWN(30 SECONDS)
				src.locked = 1
				src.updateDialog()
		if (APC_WIRE_MAIN_POWER1)
			if(shorted == 0)
				shorted = 1
			SPAWN(2 MINUTES)
				if(shorted == 1)
					shorted = 0
				src.updateDialog()
		if (APC_WIRE_MAIN_POWER2)
			if(shorted == 0)
				shorted = 1
			SPAWN(2 MINUTES)
				if(shorted == 1)
					shorted = 0
				src.updateDialog()
		if (APC_WIRE_AI_CONTROL)
			if (src.aidisabled == 0)
				src.aidisabled = 1
			src.updateDialog()
			SPAWN(1 SECOND)
				if (src.aidisabled == 1)
					src.aidisabled = 0
				src.updateDialog()

/obj/machinery/power/apc/surplus()
	if(terminal && !circuit_disabled)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/add_load(var/amount)
	if(!circuit_disabled)
		. = terminal?.add_load(amount)

/obj/machinery/power/apc/avail()
	if(terminal && !circuit_disabled)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()
	if(!terminal || !terminal.powernet) // if no powernet is managing our cycling, do it on the APC
		if(load_cycle())
			cell_cycle()

///APC cycle phase 1: load cycle. Check if the APC's able to operate, and if so, combine and prepare the load for phase 2 where it gets expended.
/obj/machinery/power/apc/proc/load_cycle()
	if(debug) boutput(world, "PROCESS [world.timeofday / 10]")

	if(status & BROKEN)
		return
	if(area && istype(area))
		if(!area.requires_power)
			return
	else
		if (QDELETED(src)) //we're in the failed-to-gc pile, stop generating runtimes
			src.UnsubscribeProcess()
			return
		SPAWN(1)
			qdel(src)
		CRASH("Broken-ass APC [identify_object(src)] @[x],[y],[z] on [map_settings ? map_settings.name : "UNKNOWN"]")

	. = TRUE //APC is working and can proceed to the next phase

	/*
	if (equipment > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.equip_consumption, EQUIP)
	if (lighting > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.light_consumption, LIGHT)
	if (environ > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.environ_consumption, ENVIRON)

	area.calc_lighting() */

	lastused_light = area.usage(LIGHT)
	lastused_equip = area.usage(EQUIP)
	lastused_environ = area.usage(ENVIRON)
	area.clear_usage()

	lastused_total = lastused_light + lastused_equip + lastused_environ
	cycle_load = lastused_total

	if (src.setup_networkapc && host_id && terminal)
		if(src.timeout == 0)
			src.post_status(host_id, "command","term_disconnect","data","timeout")
			src.host_id = null
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
		else
			src.timeout--
			if(src.timeout <= 5 && !src.timeout_alert)
				src.timeout_alert = 1
				src.post_status(src.host_id, "command","term_ping","data","reply")

///APC cycle phase 2: cell cycle. Debit the load from cell, and if any external power is available, attempt to use it to "settle up"
/obj/machinery/power/apc/proc/cell_cycle(var/charge_percentile = 1)
	//store states to update icon if any change
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	if(!src.avail())
		main_status = 0
	else if(!(terminal?.powernet?.apc_charge_share))
		main_status = 1
	else
		main_status = 2

	if(zapLimiter < APC_ZAP_LIMIT_PER_5 && prob(6) && !shorted && avail() > 3000000)
		SPAWN(0)
			if(zapStuff())
				zapLimiter += 1
				sleep(5 SECONDS)
				zapLimiter -= 1

	if(cell && !shorted)

		// First, draw power from cell to the extent we're able

		var/cellused = min(cell.charge, CELLRATE * lastused_total) // Clamp deduction to a max, amount left in cell
		cell.use(cellused)

		// Current status: cell has had this update's power drawn to the extent possible
		// Next step: attempt to square up with the grid

		// If our load is supposed to be fully covered, double check that it actually is, and if so we're good to go!
		if(charge_percentile == 1 && add_load(cycle_load))
			cell.give(cellused)
			cycle_load = 0

		// If not, see if we can reimburse enough to stay online, or fall over and die otherwise
		else
			//Charge based on the share we're supposed to have or the actual remaining power (whichever is lower)
			var/attempt_to_supply = min(lastused_total * charge_percentile, terminal?.powernet?.avail - terminal?.powernet?.newload)
			if(!add_load(attempt_to_supply))
				attempt_to_supply = 0
			if( (cell.charge/CELLRATE) + attempt_to_supply >= cycle_load )
				// do we have enough power in the cell + apc allotment to run?
				// if yes, reimburse what power we can and don't enter a failure state
				cell.charge = min(cell.maxcharge, cell.charge + (attempt_to_supply * CELLRATE))
				cycle_load -= attempt_to_supply

				// status: core allotment is empty and we recharged the cell
				// we can pop a power usage change here: the total we couldn't recharge
				if (zamus_dumb_power_popups)
					new /obj/maptext_junk/power(get_turf(src), change = -(cycle_load - attempt_to_supply), channel = -1)

			else
				// not enough power available to run the last tick!
				// we are 100% out of power.
				charging = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)

		// set channels depending on how much charge we have left
		check_channel_thresholds()

	else // no cell, switch everything off

		charging = 0
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		if (!noalerts) area.poweralert(0, src)

	// update icon & area power if anything changed

	if(last_lt != lighting || last_eq != equipment || last_en != environ || last_ch != charging || update_requested)
		if(update_requested)
			update_requested = FALSE
		UpdateIcon()
		update()

///Post-cycle APC proc; updates charging status, and delivers discretionary recharging if excess power is available.
/obj/machinery/power/apc/proc/accept_excess(var/allocated_excess)
	var/last_ch = charging
	if(cell && !shorted && chargemode)
		if(cell.charge < cell.maxcharge) // check to make sure we're still at a net positive and actually need to charge
			if(allocated_excess > cycle_load)
				charging = 1
			else
				charging = 0

			//adjust the charge rate cap for APC's current processing tier
			var/chargelevel_adj = CHARGELEVEL * PROCESSING_TIER_MULTI(src)

			//determine how much charge we can (or should) give the cell
			var/charge_to_add = min(allocated_excess*CELLRATE, (cell.maxcharge - cell.charge), (cell.maxcharge*chargelevel_adj))
			//then apply that charge
			cell.give(charge_to_add)

			if(cell.charge >= cell.maxcharge) charging = 2 // capped off for this tick? report fully charged

			. = charge_to_add / CELLRATE // return the amount of consumed power for subtraction from netexcess

			if (zamus_dumb_power_popups)
				new /obj/maptext_junk/power(get_turf(src), change = charge_to_add / CELLRATE, channel = -1)
		else
			charging = 2	// didn't need to charge but power is still good. report fully charged

	else // chargemode off
		charging = 0

	if(last_ch != charging)
		UpdateIcon()
		update()

// set channels depending on how much charge we have left
/obj/machinery/power/apc/proc/check_channel_thresholds()
	if(cell.charge <= 0)					// zero charge, turn all off
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		if (!noalerts) area.poweralert(0, src)
	else if(cell.percent() < 15)			// <15%, turn off lighting & equipment
		equipment = autoset(equipment, 2)
		lighting = autoset(lighting, 2)
		environ = autoset(environ, 1)
		if (!noalerts) area.poweralert(0, src)
	else if(cell.percent() < 30)			// <30%, turn off equipment
		equipment = autoset(equipment, 1)
		lighting = autoset(lighting, 2)
		environ = autoset(environ, 1)
		if (!noalerts) area.poweralert(0, src)
	else									// otherwise all can be on
		equipment = autoset(equipment, 1)
		lighting = autoset(lighting, 1)
		environ = autoset(environ, 1)
		if(cell.percent() > 75)
			if (!noalerts) area.poweralert(1, src)



// val 0=off, 1=off(auto) 2=on 3=on(auto)
// on 0=off, 1=on, 2=autooff
//This was global? For no reason?
/obj/machinery/power/apc/proc/autoset(var/val, var/on)

	if(on==0)
		if(val==2)			// if on, return off
			return 0
		else if(val==3)		// if auto-on, return auto-off
			return 1

	else if(on==1)
		if(val==1)			// if auto-off, return auto-on
			return 3

	else if(on==2)
		if(val==3)			// if auto-on, return auto-off
			return 1

	return val

// damage and destruction acts

/obj/machinery/power/apc/meteorhit(var/obj/O as obj)
	if (src.hardened)
		return

	if (istype(cell,/obj/item/cell/erebite))
		src.visible_message(SPAN_ALERT("<b>[src]'s</b> erebite cell violently detonates!"))
		explosion(src, src.loc, 1, 2, 4, 6)
		SPAWN(1 DECI SECOND)
			qdel(src)
	else set_broken()
	return

/obj/machinery/power/apc/ex_act(severity)
	if (src.hardened)
		return

	if (istype(cell,/obj/item/cell/erebite))
		src.visible_message(SPAN_ALERT("<b>[src]'s</b> erebite cell violently detonates!"))
		explosion(src, src.loc, 1, 2, 4, 6)
		SPAWN(1 DECI SECOND)
			qdel(src)
	else
		switch(severity)
			if(1)
				set_broken()
				qdel(src)
				return
			if(2)
				if (prob(50))
					set_broken()
			if(3)
				if (prob(25))
					set_broken()
			else return
	return

/obj/machinery/power/apc/temperature_expose(null, temp, volume)
	if (src.hardened)
		return

	if (istype(cell,/obj/item/cell/erebite))
		src.visible_message(SPAN_ALERT("<b>[src]'s</b> erebite cell violently detonates!"))
		explosion(src, src.loc, 1, 2, 4, 6)
		SPAWN(1 DECI SECOND)
			qdel (src)

/obj/machinery/power/apc/blob_act(var/power)
	if (src.hardened)
		return

	if (prob(power * 2.5))
		set_broken()


/obj/machinery/power/apc/proc/set_broken()
	status |= BROKEN
	icon_state = "apc-b"
	ClearAllOverlays() //no need to cache since nobody repairs these

	operating = 0
	update()

// overload all the lights in this APC area

/obj/machinery/power/apc/proc/overload_lighting(var/omit_emergency_lights)
	if(!get_connection() || !operating || shorted)
		return
	if( cell?.charge>=20)
		cell.use(20)
		SPAWN(0)
			for(var/obj/machinery/light/L in area)
				if (L.type == /obj/machinery/light/emergency && omit_emergency_lights)
					continue
				L.on = 1
				L.broken()
				sleep(0.1 SECONDS)

/obj/machinery/power/apc/proc/post_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
	if(!istype(src.terminal, /obj/machinery/power/terminal/netlink) || !target_id)
		return

	var/datum/signal/signal = get_free_signal()
	signal.source = src
	signal.transmission_method = TRANSMISSION_WIRE
	signal.data[key] = value
	if(key2)
		signal.data[key2] = value2
	if(key3)
		signal.data[key3] = value3

	signal.data["address_1"] = target_id
	signal.data["sender"] = src.net_id

	var/obj/machinery/power/terminal/netlink/theLink = src.terminal
	theLink.post_signal(src, signal)

/obj/machinery/power/apc/receive_signal(datum/signal/signal)
	if((status & BROKEN) || !src.setup_networkapc || src.aidisabled)
		return
	if(!signal || !src.net_id || signal.encryption)
		return

	if(signal.transmission_method != TRANSMISSION_WIRE) //We should only receive signals relayed from our terminal.
		return

	var/target = signal.data["sender"]

	if(signal.data["address_1"] != src.net_id)
		if((signal.data["address_1"] == "ping") && signal.data["sender"])
			SPAWN(0.5 SECONDS)
				src.post_status(target, "command", "ping_reply", "device", "PNET_PWR_CNTRL", "netid", src.net_id)

		return

	var/sigcommand = lowertext(signal.data["command"])
	if(!sigcommand || !signal.data["sender"])
		return

	switch(sigcommand)
		if("term_connect")
			if(target == src.host_id)

				src.host_id = null
				src.updateUsrDialog()
				SPAWN(0.3 SECONDS)
					src.post_status(target, "command","term_disconnect")
				return

			if(src.host_id)
				return

			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
			src.host_id = target
			if(signal.data["data"] != "noreply")
				src.post_status(target, "command","term_connect","data","noreply","device","PNET_PWR_CNTRL")
			//src.updateUsrDialog()
			SPAWN(0.2 SECONDS)
				src.post_status(target,"command","term_message","data","command=register&data=[ckey("[src.area]")]")
			return

		if("term_message","term_file")
			if(target != src.host_id) //Huh, who is this?
				return

			var/list/data = params2list(signal.data["data"])
			if(!data)
				return

			switch(lowertext(data["command"]))
				if ("status")
					src.post_status(src.host_id,"command","term_message","data","command=status&area=[ckey("[src.area]")]&charge=[cell ? round(cell.percent()) : "00"]&equip=[equipment]&light=[lighting]&environ=[environ]&cover=[coverlocked]")
					return
				if ("setmode")
					var/newEquip = text2num_safe(data["equip"])
					var/newLight = text2num_safe(data["light"])
					var/newEnviron = text2num_safe(data["environ"])
					var/newCover = text2num_safe(data["cover"])

					if (!isnull(newEquip))
						equipment = round(clamp(newEquip, 0, 3))

					if (!isnull(newLight))
						lighting = round(clamp(newLight, 0, 3))

					if (!isnull(newEnviron))
						environ = round(clamp(newEnviron, 0, 3))

					if (!isnull(newCover))
						coverlocked = newCover ? TRUE : FALSE

					UpdateIcon()
					update()
					src.post_status(src.host_id,"command","term_message","data","command=ack")
					return

			return

		if("term_ping")
			if(target != src.host_id)
				return
			if(signal.data["data"] == "reply")
				src.post_status(target, "command","term_ping")
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
			return

		if("term_disconnect")
			if(target == src.host_id)
				src.host_id = null
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
			//src.updateUsrDialog()
			return

	return

/obj/machinery/power/apc/receive_silicon_hotkey(var/mob/user)
	..()

	if (!isAI(user) && !issilicon(user))
		return

	if (user.client.check_key(KEY_OPEN))
		. = 1
		if (status & BROKEN)
			boutput(user, "This APC needs repairs before you can turn it back on!")
			return
		if (src.aidisabled)
			boutput(user, "AI control for this APC interface has been disabled.")
			return

		operating = !operating
		boutput(user, "You have turned \the [src] <B>[src.operating ? "on" : "off"]</B>.")
		src.update()
		UpdateIcon()

/obj/machinery/power/apc/powered()
	//Always powered
	return 1

/obj/machinery/power/apc/proc/is_not_default()
	var/vars_to_check = list("operating", "chargemode", "shorted", "equipment", "lighting", "environ", "coverlocked")

	for (var/v in vars_to_check)
		if (src.vars[v] != initial(src.vars[v]))
			return TRUE

	return FALSE

/obj/machinery/power/apc/proc/set_default()
	operating = TRUE
	chargemode = TRUE
	if (!shorted)
		equipment = 3
		lighting = 3
		environ = 3
	coverlocked = TRUE

	update()
	UpdateIcon()

/obj/machinery/power/apc/Exited(Obj, newloc)
	. = ..()
	if(Obj == src.cell)
		src.cell = null
