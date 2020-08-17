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


/obj/machinery/power/apc
	name = "area power controller"
	icon_state = "apc0"
	anchored = 1
	plane = PLANE_NOSHADOW_ABOVE
	req_access = list(access_engineering_power)
	object_flags = CAN_REPROGRAM_ACCESS
	netnum = -1		// set so that APCs aren't found as powernet nodes
	text = ""
	machine_registry_idx = MACHINES_POWER
	var/area/area
	var/areastring = null
	var/autoname_on_spawn = 0 // Area.name
	var/obj/item/cell/cell
	var/start_charge = 90				// initial cell charge %
	var/cell_type = 2500				// 0=no cell, 1=regular, 2=high-cap (x5) <- old, now it's just 0=no cell, otherwise dictate cellcapacity by changing this value. 1 used to be 1000, 2 was 2500
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
//	luminosity = 1
	var/debug = 0
	mats = 10
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

	autoname_east
		name = "Autoname E APC"
		dir = EAST
		autoname_on_spawn = 1
		pixel_x = 24

		nopoweralert
			noalerts = 1
		noaicontrol
			noalerts = 1
			aidisabled = 1

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

	autoname_west
		name = "Autoname W APC"
		dir = WEST
		autoname_on_spawn = 1
		pixel_x = -24

		nopoweralert
			noalerts = 1
		noaicontrol
			noalerts = 1
			aidisabled = 1

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

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area

	tdir = dir		// to fix Vars bug
	// dir = SOUTH

	pixel_x = (tdir & 3)? 0 : (tdir == 4 ? 24 : -24)
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

	src.area.area_apc = src

	src.updateicon()

	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	if (setup_networkapc)
		terminal = new /obj/machinery/power/terminal/netlink(src.loc)
		src.net_id = generate_net_id(src)
	else
		terminal = new/obj/machinery/power/terminal(src.loc)
	terminal.dir = tdir
	terminal.master = src

	SPAWN_DBG(0.5 SECONDS)
		src.update()

/obj/machinery/power/apc/disposing()
	cell = null
	terminal.master = null
	terminal = null
	..()

/obj/machinery/power/apc/examine(mob/user)
	. = ..()

	if(status & BROKEN)
		return

	if(user && !user.stat)
		. += "A control terminal for the area electrical systems."
		if(opened)
			. += "The cover is open and the power cell is [ cell ? "installed" : "missing"]."
		else
			. += "The cover is closed."


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
/obj/machinery/power/apc/proc/updateicon()
	if(opened)
		icon_state = "[ cell ? "apc2" : "apc1" ]" // if opened, show cell if it's inserted
		ClearAllOverlays(1)
	else if(emagged)
		icon_state = "apcemag"
		ClearAllOverlays(1)
		return
	else if(wiresexposed)
		icon_state = "apcwires"
		ClearAllOverlays(1)
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

		UpdateOverlays(I_lock, "lock", 0, 1)
		UpdateOverlays(I_chrg, "charge", 0, 1)
		UpdateOverlays(I_brke, "breaker", 0, 1)

		if(operating && !do_not_operate)
			UpdateOverlays(I_lite, "lighting", 0, 1)
			UpdateOverlays(I_equp, "equipment", 0, 1)
			UpdateOverlays(I_envi, "environment", 0, 1)

/obj/machinery/power/apc/emp_act()
	..()
	if(src.cell)
		src.cell.charge -= 1000
		if (src.cell.charge < 0)
			src.cell.charge = 0
	src.lighting = 0
	src.equipment = 0
	src.environ = 0
	SPAWN_DBG(1 MINUTE)
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
				updateicon()
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
					playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
					return
				if (1)
					src.repair_status = 0
					boutput(user, "You secure the screw terminals on the control board.")
					playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
					return
				if (2)
					boutput(user, "<span class='alert'>Securing the terminals now without tuning the autotransformer could fry the control board.</span>")
					return
				if (3)
					boutput(user, "<span class='alert'>The control board must be reset before connection to the autotransformer..</span>")
					return
				if (4)
					src.repair_status = 0
					boutput(user, "You secure the screw terminals on the control board.")
					playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)

					if (!src.terminal)
						var/obj/machinery/power/terminal/newTerm = locate(/obj/machinery/power/terminal) in src.loc
						if (istype(newTerm) && !newTerm.master)
							src.terminal = newTerm
							newTerm.master = src
							newTerm.dir = initial(src.dir) //Can't use CURRENT dir because it is set to south on spawn.
						else
							if (src.setup_networkapc)
								src.terminal = new /obj/machinery/power/terminal/netlink(src.loc)
							else
								src.terminal = new /obj/machinery/power/terminal(src.loc)
							src.terminal.master = src
							src.terminal.dir = initial(src.dir)

					status &= ~BROKEN //Clear broken flag
					icon_state = initial(src.icon_state)
					operating = 1
					update()
					return
			return

		else if (istype(W, /obj/item/cable_coil))
			switch (src.repair_status)
				if (0)
					boutput(user, "<span class='alert'>The control board must be disconnected before you can repair the autotransformer.</span>")
					return
				if (1) //Repair the transformer with a cable.
					var/obj/item/cable_coil/theCoil = W
					if (theCoil.amount >= 4)
						boutput(user, "You unravel some cable..<br>Now repairing the autotransformer's windings.  This could take some time.")
					else
						boutput(user, "<span class='alert'>Not enough cable! <I>(Requires four pieces)</I></span>")
						return
					if(!do_after(user, 100))
						return
					theCoil.use(4)
					boutput(user, "You repair the autotransformer.")
					playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)

					src.repair_status = 2

					return
				if (2)
					boutput(user, "The autotransformer is already in good condition, it just needs tuning.")
					return
				else
					return

		else if (iswrenchingtool(W))
			switch (src.repair_status)
				if (0)
					boutput(user, "<span class='alert'>You must disconnect the control board prior to working on the autotransformer.</span>")
				if (1)
					boutput(user, "<span class='alert'>You must repair the autotransformer's windings prior to tuning it.</span>")
				if (2)
					boutput(user, "You begin to carefully tune the autotransformer.  This might take a little while.")
					if (!do_after(user, 60))
						return
					boutput(user, "You tune the autotransformer.")
					playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
					src.repair_status = 3
				else
					boutput(user, "The autotransformer is already tuned.")

			return

		else if (ispulsingtool(W))
			switch(src.repair_status)
				if (3)
					boutput(user, "<span class='alert'>You reset the control board.[prob(10) ? " Takes no time at all, eh?" : ""]</span>")
					src.repair_status = 4
				if (4)
					boutput(user, "The control board has already been reset. It just needs to be reconnected now.")
				else
					boutput(user, "<span class='alert'>You need to repair and tune the autotransformer before resetting the control board.</span>")
			return

		return
	if (ispryingtool(W))	// crowbar means open or close the cover
		if(opened)
			opened = 0
			updateicon()
		else
			if(coverlocked)
				boutput(user, "The cover is locked and cannot be opened.")
			else
				opened = 1
				updateicon()
	else if	(istype(W, /obj/item/cell) && opened)	// trying to put a cell inside
		if(cell)
			boutput(user, "There is a power cell already installed.")
		else
			if (user.drop_item())
				W.set_loc(src)
				cell = W
				boutput(user, "You insert the power cell.")
				chargecount = 0
		updateicon()
	else if	(isscrewingtool(W))
		if(opened)
			boutput(user, "Close the APC first")
		else if(emagged)
			boutput(user, "The interface is broken")
		else
			wiresexposed = !wiresexposed
			boutput(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"]")
			updateicon()

	else if (issilicon(user))
		if (istype(W, /obj/item/robojumper))
			if (!istype(user, /mob/living/silicon/robot))
				return
			var/mob/living/silicon/robot/S = user
			var/obj/item/robojumper/jumper = W
			var/obj/item/cell/donor_cell = null
			var/obj/item/cell/recipient_cell = null
			if (jumper.positive)
				donor_cell = S.cell
				recipient_cell = src.cell
			else
				donor_cell = src.cell
				recipient_cell = S.cell

			var/overspill = 250 - recipient_cell.charge
			if (!donor_cell) boutput(user, "<span class='alert'>You have no cell installed!</span>")
			else if (!recipient_cell) boutput(user, "<span class='alert'>[jumper.positive? "[src] has" : "you have"] no cell installed!</span>")
			else if (recipient_cell.charge >= recipient_cell.maxcharge) boutput(user, "<span class='notice'>[jumper.positive ? "[src]" : "Your"] cell is already fully charged.</span>")
			else if (donor_cell.charge <= 250) boutput(user, "<span class='alert'>You do not have enough charge left to do this!</span>")
			else if (overspill >= 250)
				donor_cell.charge -= overspill
				recipient_cell.charge += overspill
				if (jumper.positive)
					user.visible_message("<span class='notice'>[user] transfers some of their power to [src]!</span>", "<span class='notice'>You transfer [overspill] charge. The APC is now fully charged.</span>")
				else
					user.visible_message("<span class='notice'>[user] transfers some of the power from [src] to yourself!</span>", "<span class='notice'>You transfer [overspill] charge. You are now fully charged.</span>")

			else
				donor_cell.charge -= 250
				recipient_cell.charge += 250
				if (jumper.positive)
					user.visible_message("<span class='notice'>[user] transfers some of their power to [src]!</span>", "<span class='notice'>You transfer 250 charge.</span>")
				else
					user.visible_message("<span class='notice'>[user] transfers some of the power from [src] to yourself!</span>", "<span class='notice'>You transfer 250 charge.</span>")

		else return src.attack_hand(user)

	else if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card
	if (istype(W, /obj/item/card/id))			// trying to unlock the interface with an ID card
		if(emagged)
			boutput(user, "The interface is broken")
		else if(opened)
			boutput(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			boutput(user, "You must close the panel")
		else if (setup_networkapc > 1)
			boutput(user, "This APC doesn't have a local interface.")
		else
			if(src.allowed(usr))
				locked = !locked
				boutput(user, "You [ locked ? "lock" : "unlock"] the APC interface.")
				updateicon()
			else
				boutput(user, "<span class='alert'>Access denied.</span>")


/obj/machinery/power/apc/attack_ai(mob/user)
	if (src.aidisabled && !src.wiresexposed)
		boutput(user, "AI control for this APC interface has been disabled.")
	else
		return src.attack_hand(user)

// attack with hand - remove cell (if cover open) or interact with the APC

/obj/machinery/power/apc/attack_hand(mob/user)
	if (user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || user.stat)
		return

	add_fingerprint(user)

	if(status & BROKEN) return

	interact_particle(user,src)

	if(opened && (!issilicon(user) || isghostdrone(user)))
		if(cell)
			user.put_in_hand_or_drop(cell)
			cell.updateicon()
			src.cell = null
			boutput(user, "You remove the power cell.")
			charging = 0
			src.updateicon()

	else
		// do APC interaction
		src.interacted(user)



/obj/machinery/power/apc/proc/interacted(mob/user)
	if (user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || user.stat)
		return

	if ( (get_dist(src, user) > 1 ))
		if (!issilicon(user) && !isAI(user))
			src.remove_dialog(user)
			user.Browse(null, "window=apc")
			return
		else if ((issilicon(user) || isAI(user)) && src.aidisabled)
			boutput(user, "AI control for this APC interface has been disabled.")
			user.Browse(null, "window=apc")
			return
	if(wiresexposed && (!isAI(user)))
		src.add_dialog(user)
		var/t1 = text("<B>Access Panel</B><br>")
		t1 += text("An identifier is engraved above the APC's wires: <i>[net_id]</i><br><br>")
		var/list/apcwires = list(
			"Orange" = 1,
			"Dark red" = 2,
			"White" = 3,
			"Yellow" = 4,
		)
		for(var/wiredesc in apcwires)
			var/is_uncut = src.apcwires & APCWireColorToFlag[apcwires[wiredesc]]
			t1 += "[wiredesc] wire: "
			if(!is_uncut)
				t1 += "<a href='?src=\ref[src];apcwires=[apcwires[wiredesc]]'>Mend</a>"
			else
				t1 += "<a href='?src=\ref[src];apcwires=[apcwires[wiredesc]]'>Cut</a> "
				t1 += "<a href='?src=\ref[src];pulse=[apcwires[wiredesc]]'>Pulse</a> "
				t1 += "<a href='?src=\ref[src];bite=[apcwires[wiredesc]]'>Bite</a> "
			t1 += "<br>"
		t1 += text("<br><br>[(src.locked ? "The APC is locked." : "The APC is unlocked.")]<br><br>[(src.shorted ? "The APCs power has been shorted." : "The APC is working properly!")]<br><br>[(src.aidisabled ? "The 'AI control allowed' light is off." : "The 'AI control allowed' light is on.")]")
		t1 += text("<p><a href='?src=\ref[src];close2=1'>Close</a></p><br>")
		user.Browse(t1, "window=apcwires")
		onclose(user, "apcwires")

	src.add_dialog(user)
	var/t = "<TT><B>Area Power Controller</B> ([area.name])<HR>"

	if((locked || (setup_networkapc > 1)) && (!issilicon(user) && !isAI(user)))
		if (setup_networkapc < 2)
			t += "<I>(Swipe ID card to unlock inteface.)</I><BR>"
		else
			t += "Host Connection: <B>[src.host_id ? "<font color=green>OK</font>" : "<font color=red>NONE</font>"]</B><BR>"
		t += "Main breaker : <B>[operating ? "On" : "Off"]</B><BR>"
		t += "External power : <B>[ main_status ? (main_status ==2 ? "<FONT COLOR=#004000>Good</FONT>" : "<FONT COLOR=#D09000>Low</FONT>") : "<FONT COLOR=#F00000>None</FONT>"]</B><BR>"
		t += "Power cell: <B>[cell ? "[round(cell.percent())]%" : "<FONT COLOR=red>Not connected.</FONT>"]</B>"
		if(cell)
			t += " ([charging ? ( charging == 1 ? "Charging" : "Fully charged" ) : "Not charging"])"
			t += " ([chargemode ? "Auto" : "Off"])"

		t += "<BR><HR>Power channels<BR><PRE>"

		var/list/L = list ("Off","Off (Auto)", "On", "On (Auto)")

		t += "Equipment:    [add_lspace(lastused_equip, 6)] W : <B>[L[equipment+1]]</B><BR>"
		t += "Lighting:     [add_lspace(lastused_light, 6)] W : <B>[L[lighting+1]]</B><BR>"
		t += "Environmental:[add_lspace(lastused_environ, 6)] W : <B>[L[environ+1]]</B><BR>"

		t += "<BR>Total load: [lastused_light + lastused_equip + lastused_environ] W</PRE>"
		t += "<HR>Cover lock: <B>[coverlocked ? "Engaged" : "Disengaged"]</B>"

	else
		if (!issilicon(user) && !isAI(user))
			t += "<I>(Swipe ID card to lock interface.)</I><BR>"
		t += "Main breaker: [operating ? "<B>On</B> <A href='?src=\ref[src];breaker=1'>Off</A>" : "<A href='?src=\ref[src];breaker=1'>On</A> <B>Off</B>" ]<BR>"
		t += "External power : <B>[ main_status ? (main_status ==2 ? "<FONT COLOR=#004000>Good</FONT>" : "<FONT COLOR=#D09000>Low</FONT>") : "<FONT COLOR=#F00000>None</FONT>"]</B><BR>"
		if(cell)
			t += "Power cell: <B>[round(cell.percent())]%</B>"
			t += " ([charging ? ( charging == 1 ? "Charging" : "Fully charged" ) : "Not charging"])"
			t += " ([chargemode ? "<A href='?src=\ref[src];cmode=1'>Off</A> <B>Auto</B>" : "<B>Off</B> <A href='?src=\ref[src];cmode=1'>Auto</A>"])"

		else
			t += "Power cell: <B><FONT COLOR=red>Not connected.</FONT></B>"

		t += "<BR><HR>Power channels<BR><PRE>"


		t += "Equipment:    [add_lspace(lastused_equip, 6)] W : "
		switch(equipment)
			if(0)
				t += "<B>Off</B> <A href='?src=\ref[src];eqp=2'>On</A> <A href='?src=\ref[src];eqp=3'>Auto</A>"
			if(1)
				t += "<A href='?src=\ref[src];eqp=1'>Off</A> <A href='?src=\ref[src];eqp=2'>On</A> <B>Auto (Off)</B>"
			if(2)
				t += "<A href='?src=\ref[src];eqp=1'>Off</A> <B>On</B> <A href='?src=\ref[src];eqp=3'>Auto</A>"
			if(3)
				t += "<A href='?src=\ref[src];eqp=1'>Off</A> <A href='?src=\ref[src];eqp=2'>On</A> <B>Auto (On)</B>"
		t +="<BR>"

		t += "Lighting:     [add_lspace(lastused_light, 6)] W : "

		switch(lighting)
			if(0)
				t += "<B>Off</B> <A href='?src=\ref[src];lgt=2'>On</A> <A href='?src=\ref[src];lgt=3'>Auto</A>"
			if(1)
				t += "<A href='?src=\ref[src];lgt=1'>Off</A> <A href='?src=\ref[src];lgt=2'>On</A> <B>Auto (Off)</B>"
			if(2)
				t += "<A href='?src=\ref[src];lgt=1'>Off</A> <B>On</B> <A href='?src=\ref[src];lgt=3'>Auto</A>"
			if(3)
				t += "<A href='?src=\ref[src];lgt=1'>Off</A> <A href='?src=\ref[src];lgt=2'>On</A> <B>Auto (On)</B>"
		t +="<BR>"


		t += "Environmental:[add_lspace(lastused_environ, 6)] W : "
		switch(environ)
			if(0)
				t += "<B>Off</B> <A href='?src=\ref[src];env=2'>On</A> <A href='?src=\ref[src];env=3'>Auto</A>"
			if(1)
				t += "<A href='?src=\ref[src];env=1'>Off</A> <A href='?src=\ref[src];env=2'>On</A> <B>Auto (Off)</B>"
			if(2)
				t += "<A href='?src=\ref[src];env=1'>Off</A> <B>On</B> <A href='?src=\ref[src];env=3'>Auto</A>"
			if(3)
				t += "<A href='?src=\ref[src];env=1'>Off</A> <A href='?src=\ref[src];env=2'>On</A> <B>Auto (On)</B>"



		t += "<BR>Total load: [lastused_light + lastused_equip + lastused_environ] W</PRE>"
		t += "<HR>Cover lock: [coverlocked ? "<B><A href='?src=\ref[src];lock=1'>Engaged</A></B>" : "<B><A href='?src=\ref[src];lock=1'>Disengaged</A></B>"]"


		if (issilicon(user) || isAI(user))
			t += "<BR><HR><A href='?src=\ref[src];overload=1'><I>Overload lighting circuit</I></A><BR>"


	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</TT>"
	user.Browse(t, "window=apc")
	onclose(user, "apc")
	return

/obj/machinery/power/apc/proc/report()
	return "[area.name] : [equipment]/[lighting]/[environ] ([lastused_equip+lastused_light+lastused_environ]) : [cell? cell.percent() : "N/C"] ([charging])"




/obj/machinery/power/apc/proc/update()
	if(operating && !shorted && !do_not_operate)
		area.power_light = (lighting > 1)
		area.power_equip = (equipment > 1)
		area.power_environ = (environ > 1)
		/*for (var/area/relatedArea in area)
			relatedArea.power_light = (lighting > 1)
			relatedArea.power_equip = (equipment > 1)
			relatedArea.power_environ = (environ > 1)*/
	else
		area.power_light = 0
		area.power_equip = 0
		area.power_environ = 0
		/*for (var/area/relatedArea in area)
			relatedArea.power_light = 0
			relatedArea.power_equip = 0
			relatedArea.power_environ = 0*/
	area.power_change() //Note: the power_change() for areas ALREADY deals with relatedArea. Don't put it in the loops here!!

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

	if (user.bioHolder.HasEffect("resist_electric") == 2)
		var/healing = 0
		healing = shock_damage / 3
		user.HealDamage("All", healing, healing)
		user.take_toxin_damage(0 - healing)
		boutput(user, "<span class='notice'>You absorb the electrical shock, healing your body!</span>")
		return
	else if (user.bioHolder.HasEffect("resist_electric") == 1)
		boutput(user, "<span class='notice'>You feel electricity course through you harmlessly!</span>")
		return

	user.TakeDamage(user.hand == 1 ? "l_arm" : "r_arm", 0, shock_damage)
	boutput(user, "<span class='alert'><B>You feel a powerful shock course through your body!</B></span>")
	user.unlock_medal("HIGH VOLTAGE", 1)
	if (isliving(user))
		var/mob/living/L = user
		L.Virus_ShockCure(33)
		L.shock_cyberheart(33)
	sleep(0.1 SECONDS)

#ifdef USE_STAMINA_DISORIENT
	var/weak = (user.getStatusDuration("weakened") < shock_damage * 20) ? shock_damage * 20 : 0
	var/stun = (user.getStatusDuration("stunned") < shock_damage * 10) ? shock_damage * 10 : 2
	user.do_disorient(130, weakened = weak, stunned = stun, disorient = 80, remove_stamina_below_zero = 0)
#else
	if(user.getStatusDuration("stunned") < shock_damage * 10)	user.changeStatus("stunned", shock_damage * 10)
	if(user.getStatusDuration("weakened") < shock_damage * 20)	user.changeStatus("weakened", shock_damage * 20)
#endif
	for(var/mob/M in AIviewers(src))
		if(M == user)	continue
		M.show_message("<span class='alert'>[user.name] was shocked by the [src.name]!</span>", 3, "<span class='alert'>You hear a heavy electrical crack</span>", 2)
	return 1


/obj/machinery/power/apc/proc/cut(var/wireColor)
	if (usr.hasStatus(list("weakened", "paralysis", "stunned")) || !isalive(usr))
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

/obj/machinery/power/apc/proc/bite(var/wireColor) // are you fuckin huffing or somethin
	if (usr.hasStatus(list("weakened", "paralysis", "stunned")) || !isalive(usr))
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


/obj/machinery/power/apc/proc/mend(var/wireColor)
	if (usr.hasStatus(list("weakened", "paralysis", "stunned")) || !isalive(usr))
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

/obj/machinery/power/apc/proc/pulse(var/wireColor)
	if (usr.hasStatus(list("weakened", "paralysis", "stunned")) || !isalive(usr))
		usr.show_text("Not when you're incapacitated.", "red")
		return

	//var/wireFlag = apcWireColorToFlag[wireColor] //not used in this function
	var/wireIndex = APCWireColorToIndex[wireColor]
	switch(wireIndex)
		if(APC_WIRE_IDSCAN)			//unlocks the APC for 30 seconds, if you have a better way to hack an APC I'm all ears
			src.locked = 0
			SPAWN_DBG(30 SECONDS)
				src.locked = 1
				src.updateDialog()
		if (APC_WIRE_MAIN_POWER1)
			if(shorted == 0)
				shorted = 1
			SPAWN_DBG(2 MINUTES)
				if(shorted == 1)
					shorted = 0
				src.updateDialog()
		if (APC_WIRE_MAIN_POWER2)
			if(shorted == 0)
				shorted = 1
			SPAWN_DBG(2 MINUTES)
				if(shorted == 1)
					shorted = 0
				src.updateDialog()
		if (APC_WIRE_AI_CONTROL)
			if (src.aidisabled == 0)
				src.aidisabled = 1
			src.updateDialog()
			SPAWN_DBG(1 SECOND)
				if (src.aidisabled == 1)
					src.aidisabled = 0
				src.updateDialog()


/obj/machinery/power/apc/Topic(href, href_list)
	if(..())
		return
	if (usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat)
		return
	if ((in_range(src, usr) && istype(src.loc, /turf))||(issilicon(usr) || isAI(usr)))
		src.add_dialog(usr)
		if (href_list["apcwires"] && wiresexposed)
			var/t1 = text2num(href_list["apcwires"])
			if (!usr.find_tool_in_hand(TOOL_SNIPPING))
				boutput(usr, "You need a snipping tool!")
				return
			else if (src.isWireColorCut(t1))
				src.mend(t1)
			else
				src.cut(t1)

		else if (href_list["bite"] && wiresexposed)
			var/t1 = text2num(href_list["bite"])
			switch(alert("Really bite the wire off?",,"Yes","No"))
				if("Yes")
					src.bite(t1)
				if("No")
					return

		else if (href_list["pulse"] && wiresexposed)
			var/t1 = text2num(href_list["pulse"])
			if (!usr.find_tool_in_hand(TOOL_PULSING))
				boutput(usr, "You need a multitool or similar!")
				return
			else if (src.isWireColorCut(t1))
				boutput(usr, "You can't pulse a cut wire.")
				return
			else
				src.pulse(t1)
		else if (href_list["lock"] && ((!locked && setup_networkapc < 2) || issilicon(usr) || isAI(usr)))
			if ((issilicon(usr) || isAI(usr)) && src.aidisabled)
				boutput(usr, "AI control for this APC interface has been disabled.")
				src.updateUsrDialog()

			coverlocked = !coverlocked

		else if (href_list["breaker"] && ((!locked && setup_networkapc < 2) || issilicon(usr) || isAI(usr)))
			if ((issilicon(usr) || isAI(usr)) && src.aidisabled)
				boutput(usr, "AI control for this APC interface has been disabled.")
				src.updateUsrDialog()
				return

			operating = !operating
			src.update()
			updateicon()

		else if (href_list["cmode"] && ((!locked && setup_networkapc < 2) || issilicon(usr) || isAI(usr)))
			if ((issilicon(usr) || isAI(usr)) && src.aidisabled)
				boutput(usr, "AI control for this APC interface has been disabled.")
				src.updateUsrDialog()
				return

			chargemode = !chargemode
			if(!chargemode)
				charging = 0
				updateicon()

		else if (href_list["eqp"] && ((!locked && setup_networkapc < 2) || issilicon(usr) || isAI(usr)))
			if ((issilicon(usr) || isAI(usr)) && src.aidisabled)
				boutput(usr, "AI control for this APC interface has been disabled.")
				src.updateUsrDialog()
				return

			var/val = min(max(1, text2num(href_list["eqp"])), 3)

			// Fix for exploit that allowed synthetics to perma-stun intruders by cycling the APC
			// ad infinitum (activating power/turrets for one tick) despite missing power cell (Convair880).
			if ((!src.cell || src.shorted == 1) && (val == 2 || val == 3))
				if (usr && ismob(usr))
					usr.show_text("APC offline, can't toggle power.", "red")
				src.updateUsrDialog()
				return

			logTheThing("station", usr, null, "turned the APC equipment power [(val==1) ? "off" : "on"] at [log_loc(usr)].")
			equipment = (val==1) ? 0 : val

			updateicon()
			update()

		else if (href_list["lgt"] && ((!locked && setup_networkapc < 2) || issilicon(usr) || isAI(usr)))
			if ((issilicon(usr) || isAI(usr)) && src.aidisabled)
				boutput(usr, "AI control for this APC interface has been disabled.")
				src.updateUsrDialog()
				return

			var/val = min(max(1, text2num(href_list["lgt"])), 3)

			// Same deal.
			if ((!src.cell || src.shorted == 1) && (val == 2 || val == 3))
				if (usr && ismob(usr))
					usr.show_text("APC offline, can't toggle power.", "red")
				src.updateUsrDialog()
				return

			logTheThing("station", usr, null, "turned the APC lighting power [(val==1) ? "off" : "on"] at [log_loc(usr)].")
			lighting = (val==1) ? 0 : val

			updateicon()
			update()
		else if (href_list["env"] && ((!locked && setup_networkapc < 2) || issilicon(usr) || isAI(usr)))
			if ((issilicon(usr) || isAI(usr)) && src.aidisabled)
				boutput(usr, "AI control for this APC interface has been disabled.")
				src.updateUsrDialog()
				return

			var/val = min(max(1, text2num(href_list["env"])), 3)

			// Yep.
			if ((!src.cell || src.shorted == 1) && (val == 2 || val == 3))
				if (usr && ismob(usr))
					usr.show_text("APC offline, can't toggle power.", "red")
				src.updateUsrDialog()
				return

			logTheThing("station", usr, null, "turned the APC environment power [(val==1) ? "off" : "on"] at [log_loc(usr)].")
			environ = (val==1) ? 0 :val

			updateicon()
			update()
		else if( href_list["close"] )
			usr.Browse(null, "window=apc")
			src.remove_dialog(usr)
			return
		else if (href_list["close2"])
			usr.Browse(null, "window=apcwires")
			src.remove_dialog(usr)
			return

		else if (href_list["overload"])
			if (issilicon(usr) || isAI(usr))
				if(isghostdrone(usr)) //This does not help the station at all bad bad drones!
					boutput(usr, "Your internal law subroutines kick in and prevent you from overloading the lights!")
					src.updateUsrDialog()
					return
				if (src.aidisabled)
					boutput(usr, "AI control for this APC interface has been disabled.")
					src.updateUsrDialog()
					return
				message_admins("[key_name(usr)] overloaded the lights at [log_loc(usr)].")
				logTheThing("station", usr, null, "overloaded the lights at [log_loc(usr)].")
				src.overload_lighting()

		return

	else
		usr.Browse(null, "window=apc")
		src.remove_dialog(usr)

	return

/obj/machinery/power/apc/surplus()
	if(terminal && !circuit_disabled)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/add_load(var/amount)
	if(terminal && terminal.powernet && !circuit_disabled)
		terminal.powernet.newload += amount

/obj/machinery/power/apc/avail()
	if(terminal && !circuit_disabled)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()
	if(debug) boutput(world, "PROCESS [world.timeofday / 10]")

	if(status & BROKEN)
		return
	if(area && istype(area))
		if(!area.requires_power)
			return
	else
		CRASH("Broken-ass APC @[x],[y],[z] on [map_settings ? map_settings.name : "UNKNOWN"]")


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

	if (src.setup_networkapc && host_id && terminal)
		if(src.timeout == 0)
			src.post_status(host_id, "command","term_disconnect","data","timeout")
			src.host_id = null
			src.updateUsrDialog()
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
		else
			src.timeout--
			if(src.timeout <= 5 && !src.timeout_alert)
				src.timeout_alert = 1
				src.post_status(src.host_id, "command","term_ping","data","reply")

	//store states to update icon if any change
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	var/excess = surplus()

	if(!src.avail())
		main_status = 0
	else if(excess < 0)
		main_status = 1
	else
		main_status = 2

	var/perapc = 0
	if(terminal && terminal.powernet)
		perapc = terminal.powernet.perapc

	if(zapLimiter < APC_ZAP_LIMIT_PER_5 && prob(6) && !shorted && avail() > 3000000)
		SPAWN_DBG(0)
			if(zapStuff())
				zapLimiter += 1
				sleep(5 SECONDS)
				zapLimiter -= 1

	if(cell && !shorted)

		// draw power from cell as before

		var/cellused = min(cell.charge, CELLRATE * lastused_total)	// clamp deduction to a max, amount left in cell
		cell.use(cellused)

		if(excess > 0 || perapc > lastused_total)		// if power excess, or enough anyway, recharge the cell
														// by the same amount just used

			cell.give(cellused)
			add_load(cellused/CELLRATE)		// add the load used to recharge the cell


		else		// no excess, and not enough per-apc

			if( (cell.charge/CELLRATE+perapc) >= lastused_total)		// can we draw enough from cell+grid to cover last usage?

				cell.charge = min(cell.maxcharge, cell.charge + CELLRATE * perapc)	//recharge with what we can
				add_load(perapc)		// so draw what we can from the grid
				charging = 0

			else	// not enough power available to run the last tick!
				charging = 0
				chargecount = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)

		// set channels depending on how much charge we have left
		check_channel_thresholds()

		// now trickle-charge the cell

		if(chargemode && charging == 1 && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is perapc share, capped to cell capacity, or % per second constant (Whichever is smallest)
				var/ch = min(perapc, (cell.maxcharge - cell.charge), (cell.maxcharge*CHARGELEVEL))
				add_load(ch) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell

			else
				charging = 0		// stop charging
				chargecount = 0

		// show cell as fully charged if so

		if(cell.charge >= cell.maxcharge)
			charging = 2

		if(chargemode)
			if(!charging)
				if(excess > cell.maxcharge*CHARGELEVEL)
					chargecount++
				else
					chargecount = 0

				if(chargecount == 10)

					chargecount = 0
					charging = 1

		else // chargemode off
			charging = 0
			chargecount = 0

	else // no cell, switch everything off

		charging = 0
		chargecount = 0
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		if (!noalerts) area.poweralert(0, src)

	// update icon & area power if anything changed

	if(last_lt != lighting || last_eq != equipment || last_en != environ || last_ch != charging)
		updateicon()
		update()

	src.updateDialog()

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
	if (istype(cell,/obj/item/cell/erebite))
		src.visible_message("<span class='alert'><b>[src]'s</b> erebite cell violently detonates!</span>")
		explosion(src, src.loc, 1, 2, 4, 6, 1)
		SPAWN_DBG(1 DECI SECOND)
			qdel(src)
	else set_broken()
	return

/obj/machinery/power/apc/ex_act(severity)
	if (istype(cell,/obj/item/cell/erebite))
		src.visible_message("<span class='alert'><b>[src]'s</b> erebite cell violently detonates!</span>")
		explosion(src, src.loc, 1, 2, 4, 6, 1)
		SPAWN_DBG(1 DECI SECOND)
			qdel(src)
	else
		switch(severity)
			if(1.0)
				set_broken()
				qdel(src)
				return
			if(2.0)
				if (prob(50))
					set_broken()
			if(3.0)
				if (prob(25))
					set_broken()
			else return
	return

/obj/machinery/power/apc/temperature_expose(null, temp, volume)
	if (istype(cell,/obj/item/cell/erebite))
		src.visible_message("<span class='alert'><b>[src]'s</b> erebite cell violently detonates!</span>")
		explosion(src, src.loc, 1, 2, 4, 6, 1)
		SPAWN_DBG(1 DECI SECOND)
			qdel (src)

/obj/machinery/power/apc/blob_act(var/power)
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
	if( cell && cell.charge>=20)
		cell.charge-=20;
		SPAWN_DBG(0)
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
			SPAWN_DBG(0.5 SECONDS)
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
				SPAWN_DBG(0.3 SECONDS)
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
			SPAWN_DBG(0.2 SECONDS)
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
					var/newEquip = text2num(data["equip"])
					var/newLight = text2num(data["light"])
					var/newEnviron = text2num(data["environ"])
					var/newCover = text2num(data["cover"])

					if (!isnull(newEquip))
						equipment = round(max(0, min(newEquip, 3)))

					if (!isnull(newLight))
						lighting = round(max(0, min(newLight, 3)))

					if (!isnull(newEnviron))
						environ = round(max(0, min(newEnviron, 3)))

					if (newCover)
						coverlocked = 1
					else
						coverlocked = 0

					updateicon()
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
		if (src.aidisabled)
			boutput(user, "AI control for this APC interface has been disabled.")
			return

		operating = !operating
		boutput(user, "You have turned the [src] <B>[src.operating ? "on" : "off"]</B>.")
		src.update()
		updateicon()

/obj/machinery/power/apc/powered()
	//Always powered
	return 1
