// Overhauled the generator to incorporate APC.cell charging.
// It used to in the past, but that feature was reverted for reasons unknown.
// However, it's not a C&P job of the old code (Convair880).
/obj/machinery/power/lgenerator
	name = "Experimental Local Generator"
	desc = "This machine generates power through the combustion of plasma, charging either the local APC or an inserted power cell."
	icon_state = "ggen0"
	anchored = 0
	density = 1
	//layer = FLOOR_EQUIP_LAYER1 //why was this set to this
	mats = 10
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_MULTITOOL
	var/mode = 1 // 1 = charge APC, 2 = charge inserted power cell.
	var/active = 0

	// If either of these values aren't competitive, nobody will bother with the generator.
	// Remember, there's quite a bit of hassle involved when buying (i.e. QM) and using one of these.
	// And you can't even fully recharge a 15000 cell with these parameters and stock plasma tank.
	var/CL_charge_rate = 100 // Units per tick. Comparison: ~20 (APC), 250 (regular cell charger).
	var/P_drain_rate = 0.08 // Per tick. Stock (304 kPa) tank will last about 6 min when charging non-stop.

	var/obj/item/cell/CL = null
	var/obj/item/tank/P = null
	var/obj/machinery/power/apc/our_APC = null // Linked APC if mode == 1.
	var/last_APC_check = 1 // In relation to world time. Ideally, we don't want to run this every tick.
	var/datum/light/light


	var/image/spin_sprite = null
	var/image/tank_sprite = null

	New()
		..()
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.8)
		src.spin_sprite = new /image(src.icon,"ggen-spin")
		src.tank_sprite = new /image(src.icon,"ggen-tank")

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/tank/))
			if (src.P)
				user.show_text("There appears to be a tank loaded already.", "red")
				return
			if (src.check_tank(W) == 0)
				user.show_text("The tank doesn't contain any plasma.", "red")
				return
			src.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			src.P = W
			src.UpdateIcon()

		else if (istype(W, /obj/item/cell))
			if (src.CL)
				user.show_text("There appears to be a power cell inserted already.", "red")
				return
			src.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			src.CL = W

		else
			..()

		src.updateUsrDialog()
		return

	update_icon()
		if (src.active)
			src.UpdateOverlays(spin_sprite, "spin")
			light.enable()
		else
			src.UpdateOverlays(null, "spin")
			light.disable()

		if (src.P)
			tank_sprite.icon_state = "ggen-tank"
			src.UpdateOverlays(tank_sprite, "tank")
		else
			src.UpdateOverlays(null, "tank")

		return

	proc/APC_check()
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

	proc/check_tank(var/obj/item/tank/T)
		if (!src || !T || !T.air_contents)
			return 0
		if (T.air_contents.toxins <= 0)
			return 0
		return 1

	proc/eject_tank(var/mob/user as mob)
		if (!src)
			return
		if (src.P)
			src.P.set_loc(get_turf(src))

			if (istype(user))
				user.put_in_hand_or_eject(src.P) // try to eject it into the users hand, if we can

			src.P = null
			src.active = 0
			src.UpdateIcon()
		return

	proc/eject_cell(var/mob/user as mob)
		if (!src)
			return
		if (src.CL)
			src.CL.set_loc(get_turf(src))

			if (istype(user))
				user.put_in_hand_or_eject(src.CL) // try to eject it into the users hand, if we can

			src.CL = null
			if (src.mode == 2) // Generator doesn't need to shut down when in APC mode.
				src.active = 0
			src.UpdateIcon()
		return

	process()
		if (!src)
			return

		if (src.active)
			if (!src.anchored)
				src.visible_message("<span class='alert'>[src]'s retention bolts fail, triggering an emergency shutdown!</span>")
				playsound(src.loc, 'sound/machines/buzz-two.ogg', 100, 0)
				src.active = 0
				src.UpdateIcon()
				src.updateDialog()
				return

			if (!istype(src.loc, /turf/simulated/floor/))
				src.visible_message("<span class='alert'>[src]'s retention bolts fail, triggering an emergency shutdown!</span>")
				playsound(src.loc, 'sound/machines/buzz-two.ogg', 100, 0)
				src.anchored = 0 // It might have happened, I guess?
				src.active = 0
				src.UpdateIcon()
				src.updateDialog()
				return

			if (src.check_tank(src.P) == 0)
				src.visible_message("<span class='alert'>[src] runs out of fuel and shuts down! [src.P] is ejected!</span>")
				playsound(src.loc, 'sound/machines/buzz-two.ogg', 100, 0)
				src.eject_tank(null)
				src.updateDialog()
				return

			switch (src.mode)
				if (1)
					if (!src.our_APC)
						src.visible_message("<span class='alert'>[src] doesn't detect a local APC and shuts down!</span>")
						playsound(src.loc, 'sound/machines/buzz-two.ogg', 100, 0)
						src.active = 0
						src.our_APC = null
						src.UpdateIcon()
						src.updateDialog()
						return
					if (src.last_APC_check && world.time > src.last_APC_check + 50)
						if (src.APC_check() != 1)
							src.visible_message("<span class='alert'>[src] can't charge the local APC and shuts down!</span>")
							playsound(src.loc, 'sound/machines/buzz-two.ogg', 100, 0)
							src.active = 0
							src.our_APC = null
							src.UpdateIcon()
							src.updateDialog()
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
							APC_cell.give(src.CL_charge_rate)
							src.P.air_contents.toxins = max(0, (P.air_contents.toxins - src.P_drain_rate))
							// Call proc to trigger rigged cell and log entries.

				if (2)
					if (!src.CL)
						src.visible_message("<span class='alert'>[src] doesn't have a cell to charge and shuts down!</span>")
						playsound(src.loc, 'sound/machines/buzz-two.ogg', 100, 0)
						src.active = 0
						src.CL = null
						src.UpdateIcon()
						src.updateDialog()
						return

					if (src.CL.charge < 0)
						src.CL.charge = 0
					if (src.CL.charge > src.CL.maxcharge)
						src.CL.charge = src.CL.maxcharge
					if (src.CL.charge == src.CL.maxcharge)
						src.visible_message("<span class='alert'>[src.CL] is fully charged. [src] ejects the cell and shuts down!</span>")
						playsound(src.loc, 'sound/machines/ding.ogg', 100, 1)
						src.eject_cell(null)
						src.updateDialog()
						return
					if (src.CL.charge < src.CL.maxcharge)
						src.CL.give(src.CL_charge_rate)
						src.P.air_contents.toxins = max(0, (P.air_contents.toxins - src.P_drain_rate))
						// Call proc to trigger rigged cell and log entries.

		src.icon_state = "ggen[src.anchored]"

		src.UpdateIcon()
		src.updateDialog()
		return

	attack_hand(var/mob/user)
		src.add_fingerprint(user)

		src.add_dialog(user)
		var/dat = "<h4>[src]</h4>"

		if (src.P)
			var/datum/gas_mixture/air = src.P.return_air()
			dat += "<b>Tank:</b> <a href='?src=\ref[src];eject=1'>[src.P]</a> (Plasma: [air.toxins * R_IDEAL_GAS_EQUATION * air.temperature/air.volume] kPa)<br>"
		else
			dat += "<b>Tank: --------</b><br>"

		if (src.CL)
			dat += "<b>Cell:</b> <a href='?src=\ref[src];eject-c=1'>[src.CL]</a> (Charge: [round(src.CL.percent())]%)<br>"
		else
			dat += "<b>Cell: --------</b><br>"

		var/obj/item/cell/APCC = null
		if (src.our_APC && src.our_APC.cell)
			APCC = src.our_APC.cell
		dat += "<b>APC connection:</b> [src.our_APC ? "Established" : "None"] (<a href='?src=\ref[src];getAPC=1'>Refresh</a>)<br>"
		dat += "<b>APC charge:</b> [APCC ? "[round(APCC.percent())]%" : "N/A"]<br>"

		dat += "<hr>"

		dat += "<b>Generator anchors:</b> [src.anchored ? "Secured" : "Unsecured"] (<a href='?src=\ref[src];togglebolts=1'>Toggle</a>)<br>"
		dat += "<b>Generator mode:</b> [src.mode == 1 ? "<u>Charge APC</u> / Charge cell" : "Charge APC / <u>Charge cell</u>"] (<a href='?src=\ref[src];togglemode=1'>Toggle</a>)<br>"
		dat += "<b>Generator status:</b> [src.active ? "Running" : "Off"] (<a href='?src=\ref[src];togglepower=1'>Toggle</a>)<br>"

		user.Browse(dat, "window=generator")
		onclose(user, "generator")
		return

	Topic(href, href_list)
		if (!isturf(src.loc)) return
		if (usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat || usr.restrained()) return
		if (!issilicon(usr) && !in_interact_range(src, usr)) return

		src.add_fingerprint(usr)
		src.add_dialog(usr)

		if (href_list["eject"])
			if (src.active)
				usr.show_text("Turn the generator off first!", "red")
				return
			if (src.P)
				src.visible_message("<span class='alert'>[usr] ejects [src.P] from the [src]!</span>")
				src.eject_tank(usr ? usr : null)
			else
				usr.show_text("There's no tank to eject.", "red")

		if (href_list["eject-c"])
			if (src.active && src.mode == 2)
				usr.show_text("Turn the generator off first!", "red")
				return
			if (src.CL)
				src.visible_message("<span class='alert'>[usr] ejects [src.CL] from the [src]!</span>")
				src.eject_cell(usr ? usr : null)
			else
				usr.show_text("There's no cell to eject.", "red")

		if (href_list["getAPC"])
			switch (src.APC_check())
				if (0)
					src.our_APC = null
					usr.show_text("Unable to establish connection to local APC.", "red")
				if (1)
					src.our_APC = get_local_apc(src)
					usr.show_text("Connection to local APC established.", "blue")
				if (2)
					src.our_APC = null
					usr.show_text("Local APC doesn't have a power cell to charge.", "red")
				else
					src.our_APC = null
					usr.show_text("An error occurred, please try again.", "red")

		if (href_list["togglebolts"])
			if (!src.active)
				if (!istype(src.loc, /turf/simulated/floor/))
					usr.show_text("You can't secure the generator here.", "red")
					src.anchored = 0 // It might have happened, I guess?
					src.UpdateIcon()
					return
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				if (src.anchored)
					src.anchored = 0
					src.UpdateIcon()
					src.our_APC = null // It's just gonna cause trouble otherwise.
				else
					src.anchored = 1
					src.UpdateIcon()
				src.visible_message("<span class='alert'>[usr] [src.anchored ? "bolts" : "unbolts"] [src] [src.anchored ? "to" : "from"] the floor.</span>")
			else
				usr.show_text("Turn the generator off first!", "red")
				return

		if (href_list["togglemode"])
			if (src.mode == 1)
				src.mode = 2
			else
				src.mode = 1

		if (href_list["togglepower"])
			if (!src.anchored)
				usr.show_text("The generator can't be activated when it's not secured to the floor.", "red")
				return
			if (!src.P)
				usr.show_text("There's nothing powering the generator!", "red")
				return
			switch (src.mode)
				if (1)
					if (!src.active)
						if (!src.our_APC)
							usr.show_text("Please refresh APC connection first.", "red")
							return
						if (!src.our_APC.cell)
							usr.show_text("Local APC doesn't have a power cell to charge.", "red")
							return
				if (2)
					if (!src.active)
						if (!src.CL)
							usr.show_text("There's no cell to charge.", "red")
							return
			src.active = !src.active
			src.visible_message("<span class='notice'>[usr] [src.active ? "activates" : "deactivates"] the [src].</span>")

		src.updateUsrDialog()
		return

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.CL)
			src.CL = null
