/obj/machinery/atmospherics/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "celltop-P"
	density = 1
	anchored = 1.0
	layer = EFFECTS_LAYER_BASE//MOB_EFFECT_LAYER
	flags = NOSPLASH
	var/on = 0
	var/datum/light/light
	var/ARCHIVED(temperature)
	var/obj/overlay/O1 = null
	var/mob/occupant = null
	var/obj/item/beaker = null
	var/show_beaker_contents = 0

	var/current_heat_capacity = 50
	var/pipe_direction = 1

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

	disposing()
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
				if (occupant.health < 100) process_occupant()
				else
					src.go_out()
					playsound(src.loc, "sound/machines/ding.ogg", 50, 1)

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

		if (get_dist(src,user) > 1 || get_dist(user, target) > 1)
			return

		if (target == user)
			move_inside()
		else if (can_operate(user,target))
			var/previous_user_intent = user.a_intent
			user.a_intent = INTENT_GRAB
			user.drop_item()
			target.attack_hand(user)
			user.a_intent = previous_user_intent
			SPAWN_DBG(user.combat_click_delay + 2)
				if (can_operate(user,target))
					if (istype(user.equipped(), /obj/item/grab))
						src.attackby(user.equipped(), user)
		return

	proc/can_operate(var/mob/M, var/mob/living/target)
		if (!isalive(M))
			return 0
		if (get_dist(src,M) > 1)
			return 0
		if (M.getStatusDuration("paralysis") || M.getStatusDuration("stunned") || M.getStatusDuration("weakened"))
			return 0
		if (src.occupant)
			boutput(M, "<span class='notice'><B>The scanner is already occupied!</B></span>")
			return 0
		if(ismobcritter(target))
			boutput(M, "<span class='alert'><B>The scanner doesn't support this body type.</B></span>")
			return 0
		if(!iscarbon(target) )
			boutput(M, "<span class='alert'><B>The scanner supports only carbon based lifeforms.</B></span>")
			return 0

		.= 1

	relaymove(mob/user as mob)
		if(user.stat)
			return
		src.go_out()
		return

	attack_hand(mob/user as mob)
		src.add_dialog(user)
		var/temp_text = ""
		if(air_contents.temperature > T0C)
			temp_text = "<FONT color=red>[air_contents.temperature]</FONT>"
		else if(air_contents.temperature > 170)
			temp_text = "<FONT color=black>[air_contents.temperature]</FONT>"
		else
			temp_text = "<FONT color=blue>[air_contents.temperature]</FONT>"

		var/dat = "<B>Cryo cell control system</B><BR>"
		dat += "<B>Current cell temperature:</B> [temp_text]K<BR>"
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
		if (( usr.using_dialog_of(src) && ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (isAI(usr)))
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
				src.defib.attack(src.occupant, usr)
			if (href_list["eject_occupant"])
				go_out()

			src.updateUsrDialog()
			src.add_fingerprint(usr)
			return

	attackby(var/obj/item/G as obj, var/mob/user as mob)
		if(istype(G, /obj/item/reagent_containers/glass))
			if(src.beaker)
				user.show_text("A beaker is already loaded into the machine.", "red")
				return

			src.beaker = G
			user.drop_item()
			G.set_loc(src)
			user.visible_message("[user] adds a beaker to \the [src]!", "You add a beaker to the [src]!")
			logTheThing("combat", user, null, "adds a beaker [log_reagents(G)] to [src] at [log_loc(src)].") // Rigging cryo is advertised in the 'Tip of the Day' list (Convair880).
			src.add_fingerprint(user)
		else if(istype(G, /obj/item/grab))
			push_in(G)
		else if (istype(G, /obj/item/reagent_containers/syringe))
			//this is in syringe.dm
			logTheThing("combat", user, null, "injects [log_reagents(G)] to [src] at [log_loc(src)].")
			if (src.beaker == null)
				boutput(user, "<span class='alert'>There is no beaker in [src] for you to inject reagents.</span>")
				return
			if (src.beaker.reagents.total_volume == src.beaker.reagents.maximum_volume)
				boutput(user, "<span class='alert'>The beaker in [src] is full.</span>")
				return
			var/transferred = G.reagents.trans_to(src.beaker, 5)
			src.visible_message("<span class='alert'><B>[user] injects [transferred] into [src]!</B></span>")
			src.beaker:on_reagent_change()
			return
		else if (istype(G, /obj/item/device/analyzer/healthanalyzer_upgrade))
			if (reagent_scan_enabled)
				boutput(user, "<span class='alert'>This Cryo Cell already has a reagent scan upgrade!</span>")
				return
			else
				reagent_scan_enabled = 1
				boutput(user, "<span class='notice'>Reagent scan upgrade installed.</span>")
				playsound(src.loc ,"sound/items/Deconstruct.ogg", 80, 0)
				user.u_equip(G)
				qdel(G)
				return
		else if (istype(G, /obj/item/robodefibrillator))
			if (src.defib)
				boutput(user, "<span class='alert'>[src] already has a Defibrillator installed.</span>")
			else
				var/obj/item/robodefibrillator/D = G
				src.defib = D
				boutput(user, "<span class='notice'>Defibrillator installed into [src].</span>")
				playsound(src.loc ,"sound/items/Deconstruct.ogg", 80, 0)
				user.u_equip(G)
		else if (istype(G, /obj/item/wrench))
			if (!src.defib)
				boutput(user, "<span class='alert'>[src] does not have a Defibrillator installed.</span>")
			else
				src.defib.set_loc(src.loc)
				src.defib = null
				src.visible_message("<span class='alert'>[user] removes the Defibrillator from [src].</span>")
				playsound(src.loc ,"sound/items/Ratchet.ogg", 50, 1)
		else if (istype(G, /obj/item/device/analyzer/healthanalyzer))
			if (!occupant)
				boutput(user, "<span class='notice'>This Cryo Cell is empty!</span>")
				return
			else
				boutput(user, "<span class='notice'>You scan the occupant of the cell!</span>")
				G.attack(src.occupant, user)

				return

		src.updateUsrDialog()
		return

	proc/push_in(var/obj/item/grab/G, var/mob/user as mob)
		if(!ismob(G.affecting))
			return
		if (src.occupant)
			user.show_text("The cryo tube is already occupied.", "red")
			return
		logTheThing("combat", user, G.affecting, "shoves [constructTarget(G.affecting,"combat")] into [src] at [log_loc(src)].") // Ditto (Convair880).
		var/mob/M = G.affecting
		M.set_loc(src)
		src.occupant = M
		for (var/obj/O in src)
			if (O == src.beaker)
				continue
			O.set_loc(get_turf(src))
		src.add_fingerprint(user)
		build_icon()
		qdel(G)


	proc/add_overlays()
		src.overlays = list(O1)

	proc/build_icon()
		if(on)
			light.enable()
			if(src.occupant)
				icon_state = "celltop_1"
			else
				icon_state = "celltop"
		else
			light.disable()
			icon_state = "celltop-p"
		O1 = new /obj/overlay(  )
		O1.icon = 'icons/obj/Cryogenic2.dmi'
		if(src.node)
			O1.icon_state = "cryo_bottom_[src.on]"
		else
			O1.icon_state = "cryo_bottom"
		O1.pixel_y = -32.0
		src.pixel_y = 32
		add_overlays()

	proc/process_occupant()
		if(TOTAL_MOLES(air_contents) < 10)
			return
		if(ishuman(occupant))
			if(isdead(occupant))
				return
			occupant.bodytemperature += 50*(air_contents.temperature - occupant.bodytemperature)*current_heat_capacity/(current_heat_capacity + HEAT_CAPACITY(air_contents))
			occupant.bodytemperature = max(occupant.bodytemperature, air_contents.temperature) // this is so ugly i'm sorry for doing it i'll fix it later i promise
			occupant.changeStatus("burning",-100)
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
			beaker.reagents.reaction(occupant, TOUCH, 5) //1/10th of small beaker - matches old rate for default beakers, give or take

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

	proc/go_out()
		if(!( src.occupant ))
			return
		for (var/obj/O in src)
			if (O == src.beaker)
				continue
			O.set_loc(get_turf(src))
		if (src.occupant.loc == src)
			src.occupant.set_loc(src.loc)
		src.occupant = null
		build_icon()
		return

	verb/move_eject()
		set src in oview(1)
		set category = "Local"
		if (!isalive(usr))
			return
		src.go_out()
		add_fingerprint(usr)
		return

	verb/move_inside()
		set src in oview(1)
		set category = "Local"
		if (!isalive(usr) || status & (NOPOWER|BROKEN))
			return
		if (!ishuman(usr))
			boutput(usr, "<span class='alert'>You can't seem to fit into \the [src].</span>")
			return
		if (src.occupant)
			boutput(usr, "<span class='notice'><B>The cell is already occupied!</B></span>")
			return
		if(!src.node)
			boutput(usr, "The cell is not corrrectly connected to its pipe network!")
			return

		usr.pulling = null
		usr.set_loc(src)
		src.occupant = usr
		for (var/obj/O in src)
			if (O == src.beaker)
				continue
			O.set_loc(get_turf(src))
		src.add_fingerprint(usr)
		build_icon()
		return

/datum/data/function/proc/reset()
	return

/datum/data/function/proc/r_input(href, href_list, mob/user as mob)
	return

/datum/data/function/proc/display()
	return
