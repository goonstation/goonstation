/obj/machinery/atmospherics/unary/cryo_cell
	name = "cryogenic healing pod"
	desc = "A glass tube full of a strange fluid that uses supercooled oxygen and cryoxadone to rapidly heal patients."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "celltop-P"
	density = TRUE
	anchored = 1
	layer = EFFECTS_LAYER_BASE//MOB_EFFECT_LAYER
	flags = NOSPLASH
	var/on = FALSE //! Whether the cell is turned on or not
	var/datum/light/light
	var/ARCHIVED(temperature)
	var/mob/occupant = null //! Mob inside the tube being healed
	var/obj/item/beaker = null //! The beaker containing chems which are applied to the occupant. May or may not be present.
	var/show_beaker_contents = FALSE

	var/current_heat_capacity = 50
	var/pipe_direction //! Direction of the pipe leading into this, set in New() based on dir

	var/reagent_scan_enabled = 0
	var/reagent_scan_active = 0
	var/obj/item/robodefibrillator/defib

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	New()
		..()
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.6)
		light.set_height(1.5)
		light.set_color(0, 0.8, 0.5)
		build_icon()
		pipe_direction = src.dir
		initialize_directions = pipe_direction

	initialize()
		if(node) return
		var/node_connect = pipe_direction
		for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
			if(target.initialize_directions & get_dir(target,src))
				node = target
				break
		build_icon()

	disposing()
		if (src.occupant)
			src.go_out()
		for (var/mob/M in src)
			M.set_loc(src.loc)
		..()

	process()
		..()
		if(!node)
			return
		if(!on)
			src.updateUsrDialog()
			return

		if(src.occupant)
			if(!isdead(occupant))
				if (!ishuman(occupant))
					src.go_out() // stop turning into cyborgs thanks
				if (occupant.health < occupant.max_health || occupant.bioHolder.HasEffect("premature_clone"))

					process_occupant()
				else
					if(occupant.mind)
						src.go_out()
						playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)

		if(air_contents)
			ARCHIVED(temperature) = air_contents.temperature
			heat_gas_contents()
			expel_gas()

		if(abs(ARCHIVED(temperature)-air_contents.temperature) > 1)
			network.update = 1

		src.updateUsrDialog()
		return 1


	allow_drop()
		return 0

	MouseDrop_T(mob/living/target, mob/user)
		if (!istype(target) || isAI(user))
			return

		if (!can_reach(user, target) || !can_reach(user, src) || !can_act(user))
			return

		src.try_push_in(target, user)


	Exited(atom/movable/AM, atom/newloc)
		..()
		if (AM == occupant && newloc != src && newloc != get_turf(src)) // Don't need to do this if they exited normally
			src.go_out()

	relaymove(mob/user)
		if(!can_act(user, include_cuffs = FALSE))
			return
		src.go_out()

	attack_hand(mob/user)
		src.add_dialog(user)
		var/temp_text = ""
		if(air_contents.temperature > T0C)
			temp_text = "<FONT color=red>[air_contents.temperature - T0C]</FONT>"
		else if(air_contents.temperature > 170)
			temp_text = "<FONT color=black>[air_contents.temperature - T0C]</FONT>"
		else
			temp_text = "<FONT color=blue>[air_contents.temperature - T0C]</FONT>"

		var/dat = "<B>Cryo cell control system</B><BR>"
		dat += "<B>Current cell temperature:</B> [temp_text]&deg;C<BR>"
		dat += "<B>Eject Occupant:</B> [src.occupant ? "<A href='?src=\ref[src];eject_occupant=1'>Eject</A>" : "Eject"]<BR>"
		dat += "<B>Cryo status:</B> [src.on ? "<A href='?src=\ref[src];start=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];start=1'>On</A>"]<BR>"
		dat += "[draw_beaker_text()]<BR>"
		dat += "--------------------------------<BR>"
		dat += "[draw_beaker_reagent_scan()]<BR>"
		dat += "[draw_defib_zap()]"
		dat += "[scan_health(src.occupant, reagent_scan_active, 1)]"
		update_medical_record(src.occupant)
		user.Browse(dat, "window=cryo")
		onclose(user, "cryo")

	proc/draw_defib_zap()
		if (!src.defib)
			return ""
		else
			if (src.occupant)
				return "<B>Defibrillate Occupant : <A href='?src=\ref[src];defib=1'>ZAP!!!</A></B> <BR>"
			else
				return "<B>Defibrillate Occupant : No occupant!</B> <BR>"

	proc/draw_beaker_text()
		var/beaker_text = ""

		if(src.beaker)
			beaker_text = "<B>Beaker:</B> <A href='?src=\ref[src];eject=1'>Eject</A><BR>"
			beaker_text += "<B>Beaker Contents:</B> <A href='?src=\ref[src];show_beaker_contents=1'>[show_beaker_contents ? "Hide" : "Show"]</A> "
			if (show_beaker_contents)
				beaker_text += "<BR>[scan_reagents(src.beaker)]"
		else
			beaker_text = "<B>Beaker:</B> <FONT color=red>No beaker loaded</FONT>"

		return beaker_text

	proc/draw_beaker_reagent_scan()
		if (!reagent_scan_enabled)
			return ""
		else
			return "<B>Reagent Scan : </B>[ reagent_scan_active ? "<A href='?src=\ref[src];reagent_scan_active=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];reagent_scan_active=1'>On</A>"]"

	Topic(href, href_list)
		if (( usr.using_dialog_of(src) && ((BOUNDS_DIST(src, usr) == 0) && istype(src.loc, /turf))) || (isAI(usr)))
			if(href_list["start"])
				src.on = !src.on
				build_icon()
			if(href_list["eject"])
				beaker:set_loc(src.loc)
				usr.put_in_hand_or_eject(beaker) // try to eject it into the users hand, if we can
				beaker = null
			if(href_list["show_beaker_contents"])
				show_beaker_contents = !show_beaker_contents
			if (href_list["reagent_scan_active"])
				reagent_scan_active = !reagent_scan_active
			if (href_list["defib"])
				if(!ON_COOLDOWN(src.defib, "defib_cooldown", 10 SECONDS))
					src.defib.setStatus("defib_charged", 3 SECONDS)
				src.defib.attack(src.occupant, usr)
			if (href_list["eject_occupant"])
				go_out()

			src.updateUsrDialog()
			src.add_fingerprint(usr)
			return

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, /obj/item/reagent_containers/glass))
			if (I.cant_drop)
				boutput(user, "<span class='alert'>You can't put that in \the [src] while it's attached to you!")
			if(src.beaker)
				user.show_text("A beaker is already loaded into the machine.", "red")
				return

			src.beaker = I
			user.drop_item()
			I.set_loc(src)
			user.visible_message("[user] adds a beaker to \the [src]!", "You add a beaker to the [src]!")
			logTheThing(LOG_CHEMISTRY, user, "adds a beaker [log_reagents(G)] to [src] at [log_loc(src)].") // Rigging cryo is advertised in the 'Tip of the Day' list (Convair880).
			src.add_fingerprint(user)
		else if(istype(I, /obj/item/grab))
			var/obj/item/grab/G = I
			if (try_push_in(G.affecting, user))
				qdel(G)
		else if (istype(I, /obj/item/reagent_containers/syringe))
			//this is in syringe.dm
			logTheThing(LOG_CHEMISTRY, user, "injects [log_reagents(I)] to [src] at [log_loc(src)].")
			if (!src.beaker)
				boutput(user, "<span class='alert'>There is no beaker in [src] for you to inject reagents.</span>")
				return
			if (src.beaker.reagents.total_volume == src.beaker.reagents.maximum_volume)
				boutput(user, "<span class='alert'>The beaker in [src] is full.</span>")
				return
			var/transferred = I.reagents.trans_to(src.beaker, 5)
			src.visible_message("<span class='alert'><B>[user] injects [transferred] into [src].</B></span>")
			src.beaker.on_reagent_change()
			return
		else if (istype(I, /obj/item/device/analyzer/healthanalyzer_upgrade))
			if (reagent_scan_enabled)
				boutput(user, "<span class='alert'>This Cryo Cell already has a reagent scan upgrade!</span>")
				return
			else
				reagent_scan_enabled = 1
				boutput(user, "<span class='notice'>Reagent scan upgrade installed.</span>")
				playsound(src.loc , 'sound/items/Deconstruct.ogg', 80, 0)
				user.u_equip(I)
				qdel(I)
				return
		else if (istype(I, /obj/item/robodefibrillator))
			if (src.defib)
				boutput(user, "<span class='alert'>[src] already has a Defibrillator installed.</span>")
			else
				if (I.cant_drop)
					boutput(user, "<span class='alert'>You can't put that in [src] while it's attached to you!")
					return
				src.defib = I
				boutput(user, "<span class='notice'>Defibrillator installed into [src].</span>")
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 80, 0)
				user.u_equip(I)
				I.set_loc(src)
				build_icon()
				src.UpdateIcon()
		else if (iswrenchingtool(I))
			if (!src.defib)
				boutput(user, "<span class='alert'>[src] does not have a Defibrillator installed.</span>")
			else
				src.defib.set_loc(src.loc)
				src.defib = null
				src.UpdateIcon()
				src.visible_message("<span class='alert'>[user] removes the Defibrillator from [src].</span>")
				playsound(src.loc , 'sound/items/Ratchet.ogg', 50, 1)
		else if (istype(I, /obj/item/device/analyzer/healthanalyzer))
			if (!occupant)
				boutput(user, "<span class='notice'>This Cryo Cell is empty!</span>")
				return
			else
				I.attack(src.occupant, user)

		src.updateUsrDialog()

	proc/shock_icon()
		var/fake_overlay = new /obj/shock_overlay(src.loc)
		src.vis_contents += fake_overlay
		SPAWN(1 SECOND)
			src.vis_contents -= fake_overlay
			qdel(fake_overlay)
			if(!src.defib)
				src.UpdateOverlays(null, "defib")
				return
			src.UpdateOverlays(src.SafeGetOverlayImage("defib", 'icons/obj/Cryogenic2.dmi', "defib-off", 2, pixel_y=-32), "defib")
		SPAWN(src.defib.charge_time)
			if(!src.defib)
				src.UpdateOverlays(null, "defib")
				return
			src.UpdateOverlays(src.SafeGetOverlayImage("defib", 'icons/obj/Cryogenic2.dmi', "defib-on", 2, pixel_y=-32), "defib")

	proc/build_icon()
		if(on)
			light.enable()
			icon_state = "celltop"
		else
			light.disable()
			icon_state = "celltop-p"
		if(src.node)
			src.UpdateOverlays(src.SafeGetOverlayImage("bottom", 'icons/obj/Cryogenic2.dmi', "cryo_bottom_[src.on]", 1, pixel_y=-32), "bottom")
		else
			src.UpdateOverlays(src.SafeGetOverlayImage("bottom", 'icons/obj/Cryogenic2.dmi', "cryo_bottom", 1, pixel_y=-32), "bottom")
		src.pixel_y = 32
		if(src.defib)
			src.UpdateOverlays(src.SafeGetOverlayImage("defib", 'icons/obj/Cryogenic2.dmi', "defib-on", 2, pixel_y=-32), "defib")
		else
			src.UpdateOverlays(null, "defib")

	proc/process_occupant()
		if(TOTAL_MOLES(air_contents) < 10)
			return
		if(ishuman(occupant))
			if(isdead(occupant))
				return
			occupant.bodytemperature += 50*(air_contents.temperature - occupant.bodytemperature)*current_heat_capacity/(current_heat_capacity + HEAT_CAPACITY(air_contents))
			occupant.bodytemperature = max(occupant.bodytemperature, air_contents.temperature) // this is so ugly i'm sorry for doing it i'll fix it later i promise
			occupant.changeStatus("burning", -10 SECONDS)
			var/mob/living/carbon/human/H = 0
			if (ishuman(occupant))
				H = occupant
			if (H && isalive(H)) H.lastgasp()
			//setunconcious(occupant)
			if(occupant.bodytemperature < T0C)
				if(air_contents.oxygen > 2)
					if(occupant.get_oxygen_deprivation())
						occupant.take_oxygen_deprivation(-10)
				else
					occupant.take_oxygen_deprivation(-2)
		else
			src.go_out()
			return
		if(beaker)
			beaker.reagents.trans_to(occupant, 0.1, 10)
			beaker.reagents.reaction(occupant, TOUCH, 5, paramslist = list("nopenetrate")) //1/10th of small beaker - matches old rate for default beakers, give or take

	proc/heat_gas_contents()
		if(TOTAL_MOLES(air_contents) < 1)
			return
		var/air_heat_capacity = HEAT_CAPACITY(air_contents)
		var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
		if(combined_heat_capacity > 0)
			var/combined_energy = T20C*current_heat_capacity + air_heat_capacity*air_contents.temperature
			air_contents.temperature = combined_energy/combined_heat_capacity

	proc/expel_gas()
		if(TOTAL_MOLES(air_contents) < 1)
			return
		var/datum/gas_mixture/expel_gas
		var/remove_amount = TOTAL_MOLES(air_contents)/100
		expel_gas = air_contents.remove(remove_amount)
		expel_gas.temperature = T20C // Lets expel hot gas and see if that helps people not die as they are removed
		loc.assume_air(expel_gas)

	verb/move_eject()
		set src in oview(1)
		set category = "Local"

		if (!can_act(usr))
			return
		src.go_out()
		add_fingerprint(usr)

	verb/move_inside()
		set src in oview(1)
		set category = "Local"

		src.try_push_in(usr, usr)

	/// Proc for entering a cryo tube. If a mob is shoving another mob in, `user` and `target` are different. If a mob is entering on its own, `user` and `target` are the same.
	proc/try_push_in(mob/target, mob/user)
		. = FALSE
		if (src.status & (NOPOWER|BROKEN))
			boutput(user, "<span class='alert'>\the [src] is broken.</span>")
			return
		if (!(can_act(user) && can_reach(user, src) && can_reach(user, target)))
			return
		if (!ishuman(target))
			boutput(user, "<span class='alert'>You can't seem to fit [target == user ? "yourself" : "[target]"] into \the [src].</span>")
			return
		if (src.occupant)
			user.show_text("The cryo tube is already occupied.", "red")
			return

		logTheThing(LOG_COMBAT, user, "shoves [user == target ? "themselves" : constructTarget(target,"combat")] into [src] containing [src.beaker ? log_reagents(src.beaker) : "(no beaker)"] at [log_loc(src)].")
		target.remove_pulling()
		src.occupant = target
		src.occupant.set_loc(src)
		for (var/obj/O in src)
			if (O == src.beaker || O == src.defib)
				continue
			O.set_loc(get_turf(src))
		src.add_fingerprint(user)

		// Visual stuff
		src.vis_contents += target
		src.occupant.vis_flags |= VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
		src.occupant.add_filter("cryo alpha mask", 20, alpha_mask_filter(icon = icon('icons/effects/64x64.dmi', "60-alpha-mask")))
		src.occupant.add_filter("cryo blur", 1, gauss_blur_filter(size = 0.8))
		src.occupant.pixel_y = -8 // top of the tube is 32px offset upwards
		animate(src.occupant, pixel_y = -16, time = 3 SECONDS, loop = -1, easing = SINE_EASING)
		animate(pixel_y = -8, time = 3 SECONDS, loop = -1, easing = SINE_EASING)
		src.occupant.force_laydown_standup()
		src.UpdateIcon()
		return TRUE

	/// Proc to exit the cryo cell.
	proc/go_out()
		var/mob/living/exiter = src.occupant
		if (exiter)
			src.vis_contents -= exiter
			exiter.vis_flags &= ~(VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE)
			exiter.remove_filter("cryo alpha mask")
			exiter.remove_filter("cryo blur")
			exiter.pixel_y = 0
			animate(exiter)
		for (var/atom/movable/AM as anything in src)
			if (AM == src.beaker || AM == src.defib)
				continue
			AM.set_loc(get_turf(src))
		exiter?.force_laydown_standup()
		src.occupant = null
		src.UpdateIcon()

/obj/shock_overlay
	icon = 'icons/obj/Cryogenic2.dmi'
	layer = 3
	icon_state = "defib-shock"
