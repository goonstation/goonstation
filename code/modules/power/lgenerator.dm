// Overhauled the generator to incorporate APC.cell charging.
// It used to in the past, but that feature was reverted for reasons unknown.
// However, it's not a C&P job of the old code (Convair880).
TYPEINFO(/obj/machinery/power/lgenerator)
	mats = 10

/obj/machinery/power/lgenerator
	name = "Experimental Local Generator"
	desc = "This machine generates power through the combustion of plasma, charging either the local APC or an inserted power cell."
	icon_state = "ggen0"
	anchored = UNANCHORED
	density = 1
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_MULTITOOL
	requires_power = FALSE
	var/chargeAPC = TRUE // TRUE = charge APC, FALSE = charge inserted power cell.
	var/active = FALSE

	// If either of these values aren't competitive, nobody will bother with the generator.
	// Remember, there's quite a bit of hassle involved when buying (i.e. QM) and using one of these.
	// And you can't even fully recharge a 15000 cell with these parameters and stock plasma tank.
	var/cellChargeRate = 100 // Units per tick. Comparison: ~20 (APC), 250 (regular cell charger).
	var/tankDrainRate = 0.08 // Per tick. Stock (304 kPa) tank will last about 6 min when charging non-stop.

	var/obj/item/cell/internalCell = null
	var/obj/item/tank/internalTank = null //held gas tank
	var/obj/machinery/power/apc/our_APC = null // Linked APC if charge APC == TRUE.
	var/last_APC_check = 1 // In relation to world time. Ideally, we don't want to run this every tick.
	var/datum/light/light


	var/image/spin_sprite = null
	var/image/tank_sprite = null

/obj/machinery/power/lgenerator/New()
	..()
	light = new /datum/light/point
	light.attach(src)
	light.set_brightness(0.8)
	src.spin_sprite = new /image(src.icon,"ggen-spin")
	src.tank_sprite = new /image(src.icon,"ggen-tank")

/obj/machinery/power/lgenerator/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/tank/))
		if (src.internalTank)
			user.show_text("There appears to be a tank loaded already.", "red")
			return
		if (src.check_tank(W) == 0)
			user.show_text("The tank doesn't contain any plasma.", "red")
			return
		src.visible_message(SPAN_NOTICE("[user] loads [W] into the [src]."))
		user.u_equip(W)
		W.set_loc(src)
		src.internalTank = W
		src.UpdateIcon()
		tgui_process.try_update_ui(user, src)

	else if (istype(W, /obj/item/cell))
		if (src.internalCell)
			user.show_text("There appears to be a power cell inserted already.", "red")
			return
		src.visible_message(SPAN_NOTICE("[user] loads [W] into the [src]."))
		user.u_equip(W)
		W.set_loc(src)
		src.internalCell = W
		tgui_process.try_update_ui(user, src)

	else
		..()

	return

/obj/machinery/power/lgenerator/update_icon()
	if (src.active)
		src.UpdateOverlays(spin_sprite, "spin")
		light.enable()
	else
		src.UpdateOverlays(null, "spin")
		light.disable()

	if (src.internalTank)
		tank_sprite.icon_state = "ggen-tank"
		src.UpdateOverlays(tank_sprite, "tank")
	else
		src.UpdateOverlays(null, "tank")

	return

/obj/machinery/power/lgenerator/proc/APC_check()
	if (!src)
		return 0

	var/area/A = get_area(src)
	if (!A || !A.requires_power)
		return 0

	var/obj/machinery/power/apc/AC = get_local_apc(src)
	if (!AC)
		return 0
	if (AC && !AC.cell)
		return 2
	return 1

/obj/machinery/power/lgenerator/proc/check_tank(var/obj/item/tank/T)
	if (!src || !T || !T.air_contents)
		return 0
	if (T.air_contents.toxins <= 0)
		return 0
	return 1

/obj/machinery/power/lgenerator/proc/eject_tank(var/mob/user as mob)
	if(internalTank)
		internalTank.set_loc(loc)
		user?.put_in_hand_or_eject(internalTank) // try to eject it into the users hand, if we can
		internalTank = null
		src.UpdateIcon()
	return

/obj/machinery/power/lgenerator/proc/eject_cell(var/mob/user as mob)
	if (!src)
		return
	if (src.internalCell)
		/* Ejecting it really isnt necessary since put_in_hand_or_eject does the same thing like two lines later
		var/obj/item/cell/_internalCell = src.internalCell
		src.internalCell.set_loc(get_turf(src))
		*/
		if (istype(user))
			user.put_in_hand_or_eject(internalCell) // try to eject it into the users hand, if we can

		src.internalCell = null
		if (!src.chargeAPC) // Generator doesn't need to shut down when in APC mode.
			src.active = FALSE
		src.UpdateIcon()
	return

/obj/machinery/power/lgenerator/process()
	if (!src)
		return

	if (src.active)
		if (!src.anchored)
			src.visible_message(SPAN_ALERT("[src]'s retention bolts fail, triggering an emergency shutdown!"))
			playsound(src.loc, 'sound/machines/buzz-two.ogg', 100, 0)
			src.active = FALSE
			src.UpdateIcon()
			return

		if (!istype(src.loc, /turf/simulated/floor/))
			src.visible_message(SPAN_ALERT("[src]'s retention bolts fail, triggering an emergency shutdown!"))
			playsound(src.loc, 'sound/machines/buzz-two.ogg', 100, 0)
			src.anchored = UNANCHORED // It might have happened, I guess?
			src.active = FALSE
			src.UpdateIcon()
			return

		if (src.check_tank(src.internalTank) == 0)
			src.visible_message(SPAN_ALERT("[src] runs out of fuel and shuts down! [src.internalTank] is ejected!"))
			playsound(src.loc, 'sound/machines/buzz-two.ogg', 100, 0)
			src.eject_tank(null)
			src.active = FALSE
			src.UpdateIcon()
			return

		switch (src.chargeAPC)
			if (TRUE)
				if (!src.our_APC)
					src.visible_message(SPAN_ALERT("[src] doesn't detect a local APC and shuts down!"))
					playsound(src.loc, 'sound/machines/buzz-two.ogg', 100, 0)
					src.active = FALSE
					src.our_APC = null
					src.UpdateIcon()
					return
				if (src.last_APC_check && world.time > src.last_APC_check + 50)
					if (src.APC_check() != 1)
						src.visible_message(SPAN_ALERT("[src] can't charge the local APC and shuts down!"))
						playsound(src.loc, 'sound/machines/buzz-two.ogg', 100, 0)
						src.active = FALSE
						src.our_APC = null
						src.UpdateIcon()
						src.last_APC_check = world.time
						return

				var/obj/item/cell/APC_cell = src.our_APC.cell
				if (APC_cell) // Because we don't run the check every tick.
					if (APC_cell.charge < 0)
						APC_cell.charge = 0
					if (APC_cell.charge > APC_cell.maxcharge)
						APC_cell.charge = APC_cell.maxcharge

					// Don't combust plasma if we don't have to.
					if (APC_cell.charge < APC_cell.maxcharge)
						APC_cell.give(src.cellChargeRate)
						src.internalTank.air_contents.toxins = max(0, (internalTank.air_contents.toxins - src.tankDrainRate))
						// Call proc to trigger rigged cell and log entries.

			if (FALSE)
				if (!src.internalCell)
					src.visible_message(SPAN_ALERT("[src] doesn't have a cell to charge and shuts down!"))
					playsound(src.loc, 'sound/machines/buzz-two.ogg', 100, 0)
					src.active = FALSE
					src.internalCell = null
					src.UpdateIcon()
					return

				if (src.internalCell.charge < 0)
					src.internalCell.charge = 0
				if (src.internalCell.charge > src.internalCell.maxcharge)
					src.internalCell.charge = src.internalCell.maxcharge
				if (src.internalCell.charge == src.internalCell.maxcharge)
					src.visible_message(SPAN_ALERT("[src.internalCell] is fully charged. [src] ejects the cell and shuts down!"))
					playsound(src.loc, 'sound/machines/ding.ogg', 100, 1)
					src.eject_cell(null)
					return
				if (src.internalCell.charge < src.internalCell.maxcharge)
					src.internalCell.give(src.cellChargeRate)
					src.internalTank.air_contents.toxins = max(0, (internalTank.air_contents.toxins - src.tankDrainRate))
					// Call proc to trigger rigged cell and log entries.

	src.icon_state = "ggen[src.anchored]"

	src.UpdateIcon()
	return

/obj/machinery/power/lgenerator/attack_hand(var/mob/user)
	src.add_fingerprint(user)
	src.ui_interact(user)

/obj/machinery/power/lgenerator/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LocalGenerator")
		ui.open()

/obj/machinery/power/lgenerator/ui_data(mob/user)
	. = list(
		"name" = src.name,
		"holding" = null, //represents the internal tank, the tank stats predefined UI block expects the name "holding"
		"internalCell" = null,
		"connectedAPC" = null,
		"chargeAPC" = src.chargeAPC,
		"boltsStatus" = src.anchored,
		"generatorStatus" = src.active,
	)
	if(src.internalTank)
		. += list(
			"holding" = list(
				"name" = src.internalTank.name,
				"pressure" = MIXTURE_PRESSURE(src.internalTank.air_contents),
				"maxPressure" = PORTABLE_ATMOS_MAX_RELEASE_PRESSURE,
			)
		)
	if(src.internalCell)
		. += list(
			"internalCell" = list(
				"name" = src.internalCell.name,
				"chargePercent" = src.internalCell.percent(),
			)
		)
	if(src.our_APC)
		. += list(
			"connectedAPC" = list(
				"name" = src.our_APC.name,
				"chargePercent" = src.our_APC.cell.percent(),
			)
		)

/obj/machinery/power/lgenerator/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if (.)
		return
	switch(action)
		if("toggle-bolts")
			if (!src.active)
				if (!istype(src.loc, /turf/simulated/floor/))
					ui.user.show_text("You can't secure the generator here.", "red")
					src.anchored = UNANCHORED // It might have happened, I guess?
					src.UpdateIcon()
					return
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				if (src.anchored)
					src.anchored = UNANCHORED
					src.UpdateIcon()
					src.our_APC = null //can't link to an APC while unbolted
				else
					src.anchored = ANCHORED
					src.UpdateIcon()
				src.visible_message(SPAN_ALERT("[ui.user] [src.anchored ? "bolts" : "unbolts"] [src] [src.anchored ? "to" : "from"] the floor."))
				. = TRUE
			else
				ui.user.show_text("Turn the generator off first!", "red")
				return

		if("toggle-generator")
			if (!src.anchored)
				ui.user.show_text("The generator can't be activated when it's not secured to the floor.", "red")
				return
			if (!src.internalTank)
				ui.user.show_text("There's nothing powering the generator!", "red")
				return
			switch (src.chargeAPC)
				if (TRUE)
					if (!src.active)
						if (!src.our_APC)
							ui.user.show_text("Please refresh APC connection first.", "red")
							return
						if (!src.our_APC.cell)
							ui.user.show_text("Local APC doesn't have a power cell to charge.", "red")
							return
				if (FALSE)
					if (!src.active)
						if (!src.internalCell)
							ui.user.show_text("There's no cell to charge.", "red")
							return
			src.active = !src.active
			src.visible_message(SPAN_NOTICE("[ui.user] [src.active ? "activates" : "deactivates"] the [src]."))
			. = TRUE

		if("swap-target")
			src.chargeAPC = !src.chargeAPC
			. = TRUE

		if("eject-tank")
			if (src.active)
				ui.user.show_text("Turn the generator off first!", "red")
				return
			if (src.internalTank)
				src.visible_message(SPAN_ALERT("[ui.user] ejects [src.internalTank] from the [src]!"))
				src.eject_tank(ui.user)
				. = TRUE
			else
				ui.user.show_text("There's no tank to eject.", "red")

		if("eject-cell")
			if (src.active && src.chargeAPC == FALSE)
				ui.user.show_text("Turn the generator off first!", "red")
				return
			if (src.internalCell)
				src.visible_message(SPAN_ALERT("[ui.user] ejects [src.internalCell] from the [src]!"))
				src.eject_cell(ui.user)
				. = TRUE
			else
				ui.user.show_text("There's no cell to eject.", "red")

		if("connect-APC")
			if(!src.anchored) //can't link to an APC while unbolted
				ui.user.show_text("Generator bolts must be active to connect to an APC.", "red")
				return
			switch (src.APC_check())
				if (0)
					src.our_APC = null
					ui.user.show_text("Unable to establish connection to local APC.", "red")
				if (1)
					src.our_APC = get_local_apc(src)
					ui.user.show_text("Connection to local APC established.", "blue")
					. = TRUE
				if (2)
					src.our_APC = null
					ui.user.show_text("Local APC doesn't have a power cell to charge.", "red")
				else
					src.our_APC = null
					ui.user.show_text("An error occurred, please try again.", "red")

/obj/machinery/power/lgenerator/Exited(Obj, newloc)
	. = ..()
	if(Obj == src.internalCell)
		src.internalCell = null
