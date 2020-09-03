// Disposal bin
// Holds items for disposal into pipe system
// Draws air from turf, gradually charges internal reservoir
// Once full (~1 atm), uses air resv to flush items into the pipes
// Automatically recharges air (unless off), will flush when ready if pre-set
// Can hold items and human size things, no other draggables

/obj/machinery/disposal
	name = "disposal unit"
	desc = "A pneumatic waste disposal unit."
	icon = 'icons/obj/disposal.dmi'
	icon_state = "disposal"
	anchored = 1
	density = 1
	flags = NOSPLASH
	var/datum/gas_mixture/air_contents	// internal reservoir
	var/mode = 1	// item mode 0=off 1=charging 2=charged
	var/flush = 0	// true if flush handle is pulled
	var/obj/disposalpipe/trunk/trunk = null // the attached pipe trunk
	var/flushing = 0	// true if flushing in progress
	var/icon_style = "disposal"
	var/handle_normal_state = null // this is the overlay added when the handle is in the non-flushing position (for the small chutes, mainly this can be ignored otherwise)
	var/light_style = "disposal" // for the lights and stuff
	var/image/handle_image = null
	var/destination_tag = null
	mats = 20			// whats the point of letting people build trunk pipes if they cant build new disposals?
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_SCREWDRIVER
	power_usage = 100

	var/is_processing = 1 //optimization thingy. kind of dumb. mbc fault. only process chute when flushed or recharging.

	// create a new disposal
	// find the attached trunk (if present) and init gas resvr.
	New()
		..()
		SPAWN_DBG(0.5 SECONDS)
			if (src)
				trunk = locate() in src.loc
				if(!trunk)
					mode = 0
					flush = 0
				else
					trunk.linked = src	// link the pipe trunk to self

				initair()
				update()

	disposing()
		if (trunk)
			trunk.linked = null
		else
			trunk = locate() in src.loc //idk maybe this can happens
			if (trunk)
				trunk.linked = null
		trunk = null

		if(air_contents)
			pool(air_contents)
			air_contents = null
		..()

	proc/initair()
		air_contents = unpool(/datum/gas_mixture)
		air_contents.volume = 255
		air_contents.nitrogen = 16.5
		air_contents.oxygen = 4.4
		air_contents.temperature = 293.15

	// attack by item places it in to disposal
	attackby(var/obj/item/I, var/mob/user)
		if(status & BROKEN)
			return
		if (istype(I,/obj/item/electronics/scanner))
			user.visible_message("<span class='alert'><B>[user] hits [src] with [I]!</B></span>")
			return
		if (istype(I,/obj/item/satchel/))
			var/action = input(usr, "What do you want to do with the satchel?") in list("Empty it into the Chute","Place it in the Chute","Never Mind")
			if (!action || action == "Never Mind") return
			if (get_dist(src,user) > 1)
				boutput(user, "<span class='alert'>You need to be closer to the chute to do that.</span>")
				return
			if (action == "Empty it into the Chute")
				var/obj/item/satchel/S = I
				for(var/obj/item/O in S.contents) O.set_loc(src)
				S.satchel_updateicon()
				user.visible_message("<b>[user.name]</b> dumps out [S] into [src].")
				return
		if (istype(I,/obj/item/storage/))
			var/action = input(user, "What do you want to do with [I]?") as null|anything in list("Empty it into the chute","Place it in the Chute")
			if (!in_range(src, user))
				boutput(user, "<span class='alert'>You need to be closer to the chute to do that.</span>")
				return
			if (action == "Empty it into the chute")
				var/obj/item/storage/S = I
				for(var/obj/item/O in S)
					O.set_loc(src)
					S.hud.remove_object(O)
				user.visible_message("<b>[user.name]</b> dumps out [S] into [src].")
				return
			if (isnull(action)) return
		var/obj/item/magtractor/mag
		if (istype(I.loc, /obj/item/magtractor))
			mag = I.loc
		else if (issilicon(user))
			boutput(user, "<span class='alert'>You can't put that in the trash when it's attached to you!</span>")
			return

		var/obj/item/grab/G = I
		if(istype(G))	// handle grabbed mob
			if (ismob(G.affecting))
				var/mob/GM = G.affecting
				if (istype(src, /obj/machinery/disposal/mail) && !GM.canRideMailchutes())
					boutput(user, "<span class='alert'>That won't fit!</span>")
					return
				GM.set_loc(src)
				user.visible_message("<span class='alert'><b>[user.name] stuffs [GM.name] into [src]!</b></span>")
				qdel(G)
				logTheThing("combat", user, GM, "places [constructTarget(GM,"combat")] into [src] at [log_loc(src)].")
				actions.interrupt(G.affecting, INTERRUPT_MOVE)
				actions.interrupt(user, INTERRUPT_ACT)
		else
			if (istype(mag))
				actions.stopId("magpickerhold", user)
			else if (!user.drop_item())
				return
			I.set_loc(src)
			user.visible_message("[user.name] places \the [I] into \the [src].",\
			"You place \the [I] into \the [src].")
			actions.interrupt(user, INTERRUPT_ACT)

		update()

	// mouse drop another mob or self
	//
	MouseDrop_T(mob/target, mob/user)
		//jesus fucking christ
		if (!istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || user.hasStatus(list("weakened", "paralysis", "stunned")) || isAI(user) || isAI(target) || isghostcritter(user))
			return

		if (istype(src, /obj/machinery/disposal/mail) && isliving(target))
			//Is this mob allowed to ride mailchutes?
			if (!target.canRideMailchutes())
				boutput(user, "<span class='alert'>That won't fit!</span>")
				return

		var/msg
		var/turf/Q = target.loc
		sleep (5)
		//heyyyy maybe we should check distance AFTER the sleep??											//If you get stunned while *climbing* into a chute, you can still go in
		if (target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || ((user.stat || hasStatus(list("weakened", "paralysis", "stunned"))) && user != target))
			return

		if(target == user && !user.stat)	// if drop self, then climbed in
												// must be awake
			msg = "[user.name] climbs into the [src]."
			boutput(user, "You climb into the [src].")
		else if(target != user && !user.restrained() && Q == target.loc)
			msg = "[user.name] stuffs [target.name] into the [src]!"
			boutput(user, "You stuff [target.name] into the [src]!")
			logTheThing("combat", user, target, "places [constructTarget(target,"combat")] into [src] at [log_loc(src)].")
		else
			return
		actions.interrupt(target, INTERRUPT_MOVE)
		actions.interrupt(user, INTERRUPT_ACT)
		target.set_loc(src)

		if (msg)
			src.visible_message(msg)

		if (target == user && !istype(src,/obj/machinery/disposal/transport))
			src.interacted(user)

		update()
		return

	hitby(MO as mob|obj)
		// This feature interferes with mail delivery, i.e. objects bouncing back into the chute.
		// Leaves people wondering where the stuff is, assuming they received a PDA alert at all.
		if (istype(src, /obj/machinery/disposal/mail))
			return ..()

		if(isitem(MO))
			var/obj/item/I = MO

			if(prob(20)) //It might land!
				I.set_loc(get_turf(src))
				if(prob(30)) //It landed cleanly!
					I.set_loc(src)
					src.visible_message("<span class='alert'>\The [I] lands cleanly in \the [src]!</span>")
				else	//Aaaa the tension!
					src.visible_message("<span class='alert'>\The [I] teeters on the edge of \the [src]!</span>")
					var/delay = rand(5, 15)
					SPAWN_DBG(0)
						var/in_x = I.pixel_x
						for(var/d = 0; d < delay; d++)
							if(I) I.pixel_x = in_x + rand(-1, 1)
							sleep(0.1 SECONDS)
						if(I) I.pixel_x = in_x
					sleep(delay)
					if(I && I.loc == src.loc)
						if(prob(40)) //It goes in!
							src.visible_message("<span class='alert'>\The [I] slips into \the [src]!</span>")
							I.set_loc(src)
						else
							src.visible_message("<span class='alert'>\The [I] slips off of the edge of \the [src]!</span>")

		else if (ishuman(MO))
			var/mob/living/carbon/human/H = MO
			H.set_loc(get_turf(src))
			if(prob(30))
				H.visible_message("<span class='alert'><B>[H] falls into the disposal outlet!</B></span>")
				logTheThing("combat", H, null, "is thrown into a [src.name] at [log_loc(src)].")
				H.set_loc(src)
				if(prob(20))
					src.visible_message("<span class='alert'><B><I>...accidentally hitting the handle!</I></B></span>")
					H.show_text("<B><I>...accidentally hitting the handle!</I></B>", "red")
					flush = 1
					if (!is_processing)
						SubscribeToProcess()
						is_processing = 1
					update()
		else
			return ..()


	// can breath normally in the disposal
	alter_health()
		return get_turf(src)

	// attempt to move while inside
	relaymove(mob/user as mob)
		if(user.stat || src.flushing)
			return
		src.go_out(user)
		step_rand(user)
		return

	// leave the disposal
	proc/go_out(mob/user)
		user.set_loc(src.loc)
		if (!user.hasStatus("weakened"))
			user.changeStatus("weakened", 1 SECOND)
			user.force_laydown_standup()
		update()
		return

	// ai as human but can't flush
	attack_ai(mob/user as mob)
		interacted(user, 1)

	// human interact with machine
	attack_hand(mob/user as mob)
		interacted(user, 0)
		interact_particle(user,src)

	proc/interacted(mob/user, var/ai=0)
		src.add_fingerprint(user)
		if(status & BROKEN)
			src.remove_dialog(user)
			return

		var/dat = "<head><title>Waste Disposal Unit</title></head><body><TT><B>Waste Disposal Unit</B><HR>"

		if(!ai)  // AI can't pull flush handle
			if(flush)
				dat += "Disposal handle: <A href='?src=\ref[src];handle=0'>Disengage</A> <B>Engaged</B>"
			else
				dat += "Disposal handle: <B>Disengaged</B> <A href='?src=\ref[src];handle=1'>Engage</A>"

			dat += "<BR><HR><A href='?src=\ref[src];eject=1'>Eject contents</A><HR>"

		if(mode == 0)
			dat += "Pump: <B>Off</B> <A href='?src=\ref[src];pump=1'>On</A><BR>"
		else if(mode == 1)
			dat += "Pump: <A href='?src=\ref[src];pump=0'>Off</A> <B>On</B> (pressurizing)<BR>"
		else
			dat += "Pump: <A href='?src=\ref[src];pump=0'>Off</A> <B>On</B> (idle)<BR>"

		if (!air_contents)
			initair()

		var/per = 100* MIXTURE_PRESSURE(air_contents) / (2*ONE_ATMOSPHERE)

		dat += "Pressure: [round(per, 1)]%<BR></body>"


		src.add_dialog(user)
		user.Browse(dat, "window=disposal;size=360x235")
		onclose(user, "disposal")

	// handle machine interaction

	Topic(href, href_list)
		if(..())
			return
		src.add_fingerprint(usr)
		if(status & BROKEN)
			DEBUG_MESSAGE("[src] is broken")
			return
		if(usr.stat || usr.restrained() || src.flushing)
			DEBUG_MESSAGE("[src] is flushing/usr.stat returned with someting/usr is restrained")
			return

		if (in_range(src, usr) && isturf(src.loc))
			DEBUG_MESSAGE("in range of [src] and it is on a turf")
			src.add_dialog(usr)

			if(href_list["close"])
				DEBUG_MESSAGE("closed [src]")
				src.remove_dialog(usr)
				usr.Browse(null, "window=disposal")
				return

			if(href_list["pump"])
				if(text2num(href_list["pump"]))
					DEBUG_MESSAGE("[src] pump engaged")
					power_usage = 600
					mode = 1
				else
					DEBUG_MESSAGE("[src] pump disengaged")
					power_usage = 100
					mode = 0
				update()

			if(href_list["handle"])
				DEBUG_MESSAGE("[src] handle")
				flush = text2num(href_list["handle"])
				if (flush)
					if (!is_processing)
						SubscribeToProcess()
						is_processing = 1
				update()
				playsound(get_turf(src), "sound/misc/handle_click.ogg", 50, 1)

			if(href_list["eject"])
				DEBUG_MESSAGE("[src] eject")
				eject()
		else
			if (!isturf(src.loc))
				DEBUG_MESSAGE("[src]'s loc is not a turf: [src.loc]")
			if (!in_range(src, usr))
				DEBUG_MESSAGE("[src] and [usr] are too far apart: [src] [log_loc(src)], [usr] [log_loc(usr)]")

			usr.Browse(null, "window=disposal")
			src.remove_dialog(usr)
			return

		src.updateDialog()
		return

	// eject the contents of the disposal unit
	proc/eject()
		for(var/atom/movable/AM in src)
			AM.set_loc(src.loc)
			AM.pipe_eject(0)
		update()

	// update the icon & overlays to reflect mode & status
	proc/update()
		if (status & BROKEN)
			icon_state = "disposal-broken"
			ClearAllOverlays()
			mode = 0
			flush = 0
			return

		// flush handle
		if (flush)
			ENSURE_IMAGE(src.handle_image, src.icon, "[icon_style]-fhandle")
			//if (!src.handle_image)
				//src.handle_image = image(src.icon, "[icon_style]-handle")
			//else if (!src.handle_state)
				//src.handle_image.icon_state = "[icon_style]-handle"
			UpdateOverlays(src.handle_image, "handle")
		else
			if (src.handle_normal_state)
				ENSURE_IMAGE(src.handle_image, src.icon, src.handle_normal_state)
				//if (!src.handle_image)
					//src.handle_image = image(src.icon, src.handle_normal_state)
				//else
					//src.handle_image.icon_state = src.handle_state
				UpdateOverlays(src.handle_image, "handle")
			else
				UpdateOverlays(null, "handle", 0, 1)

		// only handle is shown if no power
		if (status & NOPOWER)
			UpdateOverlays(null, "content_light", 0, 1)
			UpdateOverlays(null, "status", 0, 1)
			return

		// 	check for items in disposal - occupied light
		if (contents.len > 0)
			var/image/I = GetOverlayImage("content_light")
			if (!I)
				I = image(src.icon, "[light_style]-full")
			UpdateOverlays(I, "content_light")
		else
			UpdateOverlays(null, "content_light", 0, 1)

		// charging and ready light
		var/image/I = GetOverlayImage("status")
		if (!I)
			I = image(src.icon, "[light_style]-charge")
		switch (mode)
			if (1)
				I.icon_state = "[light_style]-charge"
			if (2)
				I.icon_state = "[light_style]-ready"
			else
				I = null

		UpdateOverlays(I, "status", 0, 1)
		/*
		if(mode == 1)
			overlays += image('icons/obj/disposal.dmi', "dispover-charge")
		else if(mode == 2)
			overlays += image('icons/obj/disposal.dmi', "dispover-ready")
		*/
	// timed process
	// charge the gas reservoir and perform flush if ready
	process()
		if(status & BROKEN)			// nothing can happen if broken
			return

		..()

		src.updateDialog()

		if(flush && MIXTURE_PRESSURE(air_contents) >= 2*ONE_ATMOSPHERE)	// flush can happen even without power
			SPAWN_DBG(0) //Quit holding up the process you fucker
				flush()

		if(status & NOPOWER)			// won't charge if no power
			return

		if (!loc) return

		use_power(100)		// base power usage

		if(mode != 1)		// if off or ready, no need to charge
			return

		// otherwise charge
		use_power(500)		// charging power usage

		var/atom/L = loc						// recharging from loc turf
		var/datum/gas_mixture/env = L.return_air()
		if (!air_contents)
			air_contents = unpool(/datum/gas_mixture)
		var/pressure_delta = (ONE_ATMOSPHERE*2.1) - MIXTURE_PRESSURE(air_contents)

		if(env.temperature > 0)
			var/transfer_moles = 0.1 * pressure_delta*air_contents.volume/(env.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = env.remove(transfer_moles)
			air_contents.merge(removed)


		// if full enough, switch to ready mode
		if(MIXTURE_PRESSURE(air_contents) >= 2*ONE_ATMOSPHERE)
			mode = 2
			power_usage = 100
			update()
			if (is_processing)
				UnsubscribeProcess()
				is_processing = 0
		return

	// perform a flush
	proc/flush()

		flushing = 1
		flick("[icon_style]-flush", src)

		var/obj/disposalholder/H = unpool(/obj/disposalholder)	// virtual holder object which actually
																// travels through the pipes.

		H.init(src)	// copy the contents of disposer to holder
		if (!isnull(src.destination_tag))
			H.mail_tag = src.destination_tag

		air_contents.zero()

		sleep(1 SECOND)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
		sleep(0.5 SECONDS) // wait for animation to finish


		H.start(src) // start the holder processing movement
		flushing = 0
		// now reset disposal state
		flush = 0
		if(mode == 2)	// if was ready,
			mode = 1	// switch to charging
		power_usage = 600
		update()
		return


	// called when area power changes
	power_change()
		..()	// do default setting/reset of stat NOPOWER bit
		update()	// update icon
		return


	// called when holder is expelled from a disposal
	// should usually only occur if the pipe network is modified
	proc/expel(var/obj/disposalholder/H)

		var/turf/target
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))

			AM.set_loc(src.loc)
			AM.pipe_eject(0)
			AM.throw_at(target, 5, 1)

		H.vent_gas(loc)
		qdel(H)

	custom_suicide = 1
	suicide(var/mob/living/carbon/human/user as mob)
		if (!istype(user) || !src.user_can_suicide(user))
			return 0
		if (src.mode != 2)//!hasvar(user,"organHolder")) I will END YOU
			return 0

		user.visible_message("<span class='alert'><b>[user] sticks [his_or_her(user)] head into [src] and pulls the flush!</b></span>")
		var/obj/head = user.organHolder.drop_organ("head")
		head.set_loc(src)
		src.flush()
		playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
		if (user) //ZeWaka: Fix for null.loc
			make_cleanable( /obj/decal/cleanable/blood,user.loc)
			health_update_queue |= user
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/obj/machinery/disposal/small
	icon = 'icons/obj/disposal_small.dmi'
	handle_normal_state = "disposal-handle"
	density = 0

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

/obj/machinery/disposal/brig
	name = "brig chute"
	icon_state = "brigchute"
	desc = "A pneumatic delivery chute for sending things directly to the brig."
	icon_style = "brig"

/obj/machinery/disposal/brig/small
	icon = 'icons/obj/disposal_small.dmi'
	handle_normal_state = "brig-handle"
	density = 0

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

/obj/machinery/disposal/morgue
	name = "morgue chute"
	icon_state = "morguechute"
	desc = "A pneumatic delivery chute for sending things directly to the morgue."
	icon_style = "morgue"

/obj/machinery/disposal/sci
	name = "research chute"
	icon_state = "scichute"
	desc = "A pneumatic delivery chute for sending completed research to the public."
	icon_style = "sci"

/obj/machinery/disposal/ore
	name = "ore chute"
	icon_state = "orechute"
	desc = "A pneumatic delivery chute for ferrying ore around the station."
	icon_style = "ore"

/obj/machinery/disposal/ore/small
	icon = 'icons/obj/disposal_small.dmi'
	handle_normal_state = "ore-handle"
	density = 0

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

/obj/machinery/disposal/alert_a_chump
	var/message = null
	var/mailgroup = null

	var/net_id = null
	var/frequency = 1149
	var/datum/radio_frequency/radio_connection

	New()
		..()
		SPAWN_DBG(0.8 SECONDS)
			if(radio_controller)
				radio_connection = radio_controller.add_object(src, "[frequency]")
			if(!src.net_id)
				src.net_id = generate_net_id(src)

	disposing()
		radio_controller.remove_object(src, "[frequency]")
		..()

	expel(var/obj/disposalholder/H)
		..(H)

		if (message && mailgroup && radio_connection)
			var/datum/signal/newsignal = get_free_signal()
			newsignal.source = src
			newsignal.transmission_method = TRANSMISSION_RADIO
			newsignal.data["command"] = "text_message"
			newsignal.data["sender_name"] = "CHUTE-MAILBOT"
			newsignal.data["message"] = "[message]"

			newsignal.data["address_1"] = "00000000"
			newsignal.data["group"] = mailgroup
			newsignal.data["sender"] = src.net_id

			radio_connection.post_signal(src, newsignal)

/obj/machinery/disposal/cart_port
	name = "disposal cart port"
	desc = "A pneumatic disposal chute that carts can empty their contents into."
	icon_state = "cartport"
	icon_style = "cartport"
	light_style = "cartport"
	density = 0
	layer = OBJ_LAYER-0.1

	MouseDrop_T(obj/storage/cart/target, mob/user)
		if (!istype(target) || target.loc != src.loc || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || user.getStatusDuration("paralysis") || user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || isAI(user))
			return ..()

		if (!target.contents.len)
			boutput(user, "[target] doesn't have anything in it to load!")
			return
		src.visible_message("[user] begins depositing [target]'s contents into [src].")
		playsound(src.loc ,"sound/items/Deconstruct.ogg", 80, 0)
		for (var/atom/movable/AM in target)
			if (get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || user.getStatusDuration("paralysis") || user.getStatusDuration("stunned") || user.getStatusDuration("weakened"))
				break
			if (AM.anchored || AM.loc != target)
				continue
			AM.set_loc(src)
			sleep(0.5 SECONDS)
		src.visible_message("[user] deposits [target]'s contents into [src].")
		update()

/obj/machinery/disposal/transport
	name = "transportation unit"
	icon = 'icons/obj/disposal.dmi'
	icon_state = "scichute"
	desc = "A pneumatic delivery chute for transporting people. Ever see Futurama? It's like that."
	icon_style = "sci"

	go_out(mob/user)
		user.set_loc(src.loc)
		update()
		return

	attackby(var/obj/item/I, var/mob/user)
		return

	MouseDrop_T(mob/target, mob/user)
		if (!istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || user.hasStatus(list("weakened", "paralysis", "stunned")) || isAI(user) || isAI(target) || isghostcritter(user))
			return
		..()
		flush = 1

		if (!is_processing)
			SubscribeToProcess()
			is_processing = 1

		playsound(get_turf(src), "sound/misc/handle_click.ogg", 50, 1)

		update()
		return

	hitby(MO as mob|obj)
		if(istype(MO,/mob/living))
			return ..()
		return

	attack_ai(mob/user as mob)
		return

	attack_hand(mob/user as mob)
		return
