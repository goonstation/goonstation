// Disposal bin
// Holds items for disposal into pipe system
// Draws air from turf, gradually charges internal reservoir
// Once full (~1 atm), uses air resv to flush items into the pipes
// Automatically recharges air (unless off), will flush when ready if pre-set
// Can hold items and human size things, no other draggables

#define DISPOSAL_CHUTE_OFF 0
#define DISPOSAL_CHUTE_CHARGING 1
#define DISPOSAL_CHUTE_CHARGED 2

#define DISPOSAL_REPAIR_STEP_FIXED 0
#define DISPOSAL_REPAIR_STEP_SCREWDRIVER 1
#define DISPOSAL_REPAIR_STEP_CROWBAR 2

TYPEINFO(/obj/machinery/disposal)
	mats = 20			// whats the point of letting people build trunk pipes if they cant build new disposals?
ADMIN_INTERACT_PROCS(/obj/machinery/disposal, proc/flush, proc/eject)
/obj/machinery/disposal
	name = "disposal unit"
	desc = "A pressurized trashcan that flushes things you put into it through pipes, usually to disposals."
	icon = 'icons/obj/disposal.dmi'
	icon_state = "disposal"
	anchored = ANCHORED
	density = 1
	flags = NOSPLASH | TGUI_INTERACTIVE
	var/datum/gas_mixture/air_contents	// internal reservoir
	var/mode = DISPOSAL_CHUTE_CHARGING	// item mode 0=off 1=charging 2=charged
	var/flush = 0	// true if flush handle is pulled
	var/obj/disposalpipe/trunk/trunk = null // the attached pipe trunk
	var/flushing = FALSE	// true if flushing in progress
	var/icon_style = "disposal"
	var/handle_normal_state = null // this is the overlay added when the handle is in the non-flushing position (for the small chutes, mainly this can be ignored otherwise)
	var/light_style = "disposal" // for the lights and stuff
	var/image/handle_image = null
	var/destination_tag = null
	var/repair_step = DISPOSAL_REPAIR_STEP_FIXED
	///How fast do we repressurize
	var/repressure_speed = 0.1
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_SCREWDRIVER
	power_usage = 100

	var/is_processing = 1 //optimization thingy. kind of dumb. mbc fault. only process chute when flushed or recharging.

	// create a new disposal
	// find the attached trunk (if present) and init gas resvr.
	New()
		..()
		if((src.pixel_x == 0) && (src.dir == WEST))
			src.pixel_x += 5
		if((src.pixel_x == 0) && (src.dir == EAST))
			src.pixel_x += -5

		START_TRACKING
		src.AddComponent(/datum/component/obj_projectile_damage)
		SPAWN(0.5 SECONDS)
			if (src)
				src.trunk = locate() in src.loc
				if(!src.trunk)
					src.mode = DISPOSAL_CHUTE_OFF
					src.flush = 0
				else
					src.trunk.linked = src	// link the pipe trunk to self

				initair()
				update()

	disposing()
		if (src.trunk && src.trunk.linked == src)
			src.trunk.linked = null
		else
			src.trunk = locate() in src.loc //idk maybe this can happens
			if (src.trunk && src.trunk.linked == src)
				src.trunk.linked = null
		src.trunk = null

		if(air_contents)
			qdel(air_contents)
			air_contents = null
		STOP_TRACKING
		..()

	was_deconstructed_to_frame(mob/user)
		if (src.trunk && src.trunk.linked == src)
			src.trunk.linked = null
		else
			src.trunk = locate() in src.loc //idk maybe this can happens
			if (src.trunk && src.trunk.linked == src)
				src.trunk.linked = null
		src.trunk = null

		var/turf/T = get_turf(src)
		for (var/atom in src)
			var/atom/movable/A = atom
			A.set_loc(T)

		return ..()

	was_built_from_frame(mob/user, newly_built)
		if (!newly_built)
			src.trunk = locate() in src.loc
			if(!src.trunk)
				src.mode = DISPOSAL_CHUTE_OFF
				src.flush = 0
			else
				src.trunk.linked = src	// link the pipe trunk to self
		return ..()


	onDestroy()
		if (src.powered())
			elecflash(src, power = 2)
		playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 50, 1)
		. = ..()

	HELP_MESSAGE_OVERRIDE("Place held satches, boxes, and bags by clicking with the <b>Disarm</b>, <b>Grab</b>, or <b>Harm</b> intent.")

	get_help_message(dist, mob/user)
		. = ..()
		if (src.status & BROKEN)
			switch(src.repair_step)
				if(DISPOSAL_REPAIR_STEP_SCREWDRIVER)
					return "[src] is broken. You can begin repairing by using a <b>screwdriver</b>."
				if(DISPOSAL_REPAIR_STEP_CROWBAR)
					return "[src] is broken. You can finish repairing by using a <b>crowbar</b>."

	proc/initair()
		air_contents = new /datum/gas_mixture
		air_contents.volume = 255
		air_contents.nitrogen = 16.5
		air_contents.oxygen = 4.4
		air_contents.temperature = 293.15

	proc/fits_in(atom/movable/AM)
		return TRUE

	// attack by item places it in to disposal
	attackby(var/obj/item/I, var/mob/user)
		var/obj/item/storage/mechanics/mechitem = null
		if(status & BROKEN)
			switch(src.repair_step)
				if(DISPOSAL_REPAIR_STEP_SCREWDRIVER)
					if(isscrewingtool(I))
						playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, TRUE)
						src.visible_message("[user] loosens the jammed retaining screws.")
						src.repair_step = DISPOSAL_REPAIR_STEP_CROWBAR
					else
						boutput(user, SPAN_HINT("You need to <b>loosen</b> the retaining screws."))

				if(DISPOSAL_REPAIR_STEP_CROWBAR)
					if(ispryingtool(I))
						playsound(src.loc, 'sound/machines/airlock_pry.ogg', 35, TRUE)
						src.visible_message("[user] pries the chute locking panels back in place")
						src.repair_step = DISPOSAL_REPAIR_STEP_FIXED
						src.status &= ~BROKEN
						src.mode = DISPOSAL_CHUTE_CHARGING
						src.icon_state = initial(icon_state)
						src.update()
					else
						boutput(user, SPAN_HINT("You need to <b>pry</b> the locking panels."))
			return
		if (istype(I,/obj/item/deconstructor))
			user.visible_message(SPAN_ALERT("<B>[user] hits [src] with [I]!</B>"))
			return
		if (istype(I, /obj/item/handheld_vacuum))
			return
		if (istype(I,/obj/item/satchel/) && I.contents.len)
			var/action = input(user, "What do you want to do with the satchel?") in list("Place it in the Chute","Empty it into the Chute","Never Mind")
			if (!action || action == "Never Mind")
				return
			if (!in_interact_range(src, user))
				boutput(user, SPAN_ALERT("You need to be closer to the chute to do that."))
				return
			if (action == "Empty it into the Chute")
				var/obj/item/satchel/S = I
				for(var/obj/item/O in S.contents)
					if (src.fits_in(O))
						O.set_loc(src)
				S.UpdateIcon()
				S.tooltip_rebuild = 1
				user.visible_message("<b>[user.name]</b> dumps out [S] into [src].")
				src.update()
				return
		if(istype(I, /obj/item/storage/mechanics))
			mechitem = I
		//first time they click with a storage, it gets dumped. second time container itself is added
		if (length(I.storage?.get_contents()) && user.a_intent == INTENT_HELP && (!mechitem || mechitem.open)) //if they're not on help intent it'll default to placing it in while full.
			if(istype(I, /obj/item/storage/secure))
				var/obj/item/storage/secure/secS = I
				if (!src.fits_in(secS))
					return
				if(secS.locked)
					user.visible_message("[user.name] places \the [secS] into \the [src].",\
						"You place \the [secS] into \the [src].")
					user.drop_item()
					secS.set_loc(src)
					actions.interrupt(user, INTERRUPT_ACT)
					src.update()
					return
			for(var/obj/item/O in I.storage.get_contents())
				if (src.fits_in(O))
					I.storage.transfer_stored_item(O, src, user = user)
			user.visible_message("<b>[user.name]</b> dumps out [I] into [src].")
			actions.interrupt(user, INTERRUPT_ACT)
			src.update()
			return

		var/obj/item/magtractor/mag
		if (istype(I.loc, /obj/item/magtractor))
			mag = I.loc
		else if (issilicon(user))
			boutput(user, SPAN_ALERT("You can't put that in the trash when it's attached to you!"))
			return

		var/obj/item/grab/G = I
		if(istype(G))	// handle grabbed mob
			if (ismob(G.affecting))
				var/mob/GM = G.affecting
				if (istype(src, /obj/machinery/disposal/mail) && !GM.canRideMailchutes() || !src.fits_in(GM))
					boutput(user, SPAN_ALERT("That won't fit!"))
					return
				actions.start(new/datum/action/bar/icon/shoveMobIntoChute(src, GM, user), user)
				qdel(G)
		else
			if (istype(mag))
				actions.stopId(/datum/action/magPickerHold, user)
			else if (!src.fits_in(I) || !user.drop_item())
				return
			I.set_loc(src)
			user.visible_message("[user.name] places \the [I] into \the [src].",\
			"You place \the [I] into \the [src].")
			actions.interrupt(user, INTERRUPT_ACT)

		update()

	// mouse drop another mob or self
	//
	MouseDrop_T(atom/target, mob/user)
		//jesus fucking christ
		if (BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(target, src) > 0 || isAI(user) || is_incapacitated(user) || isghostcritter(user) || !src.fits_in(target))
			return
		if (src.status & BROKEN)
			return
		if (istype(target, /obj/machinery/bot))
			var/obj/machinery/bot/bot = target
			bot.set_loc(src)
			return
		if (iscritter(target))
			var/obj/critter/corpse = target
			if (!corpse.alive)
				corpse.set_loc(src)
				user.visible_message("[user.name] places \the [corpse] into \the [src].")
				actions.interrupt(user, INTERRUPT_ACT)
			return

		if (isliving(target))
			var/mob/living/mobtarget = target
			if  (mobtarget.buckled || isAI(mobtarget))
				return

			if (istype(src, /obj/machinery/disposal/mail))
				//Is this mob allowed to ride mailchutes?
				if (!mobtarget.canRideMailchutes())
					boutput(user, SPAN_ALERT("That won't fit!"))
					return

			actions.start(new/datum/action/bar/icon/shoveMobIntoChute(src, mobtarget, user), user)

	hitby(atom/movable/MO, datum/thrown_thing/thr)
		if (!src.fits_in(MO))
			return

		// if it has just been shot out of a mail chute, don't accept it.
		if (GET_COOLDOWN(MO, "PipeEject"))
			return

		if (isliving(MO))
			var/mob/living/mobtarget = MO
			if  (mobtarget.buckled || isAI(mobtarget))
				return

			if (istype(src, /obj/machinery/disposal/mail))
				//Is this mob allowed to ride mailchutes?
				if (!mobtarget.canRideMailchutes())
					return

		if(isitem(MO))
			var/obj/item/I = MO
			I.set_loc(src)
			update()
			src.visible_message(SPAN_ALERT("\The [I] lands cleanly in \the [src]!"))

		else if (istype(MO, /mob/living))
			var/mob/living/H = MO
			H.visible_message(SPAN_ALERT("<B>[H] falls into the disposal outlet!</B>"))
			logTheThing(LOG_COMBAT, H, "is thrown into a [src.name] at [log_loc(src)].")
			H.set_loc(src)
			if(prob(10) || H.bioHolder?.HasEffect("clumsy"))
				src.visible_message(SPAN_ALERT("<B><I>...accidentally hitting the handle!</I></B>"))
				H.show_text("<B><I>...accidentally hitting the handle!</I></B>", "red")
				flush = 1
				if (!is_processing)
					SubscribeToProcess()
					is_processing = 1
			update()
		else
			return ..()

	proc/set_broken()
		if(src.status & BROKEN)
			return
		src.eject()
		ZERO_GASES(src.air_contents)
		playsound(src, 'sound/impact_sounds/locker_break.ogg', 50, TRUE)
		src.status |= BROKEN
		src.repair_step = DISPOSAL_REPAIR_STEP_SCREWDRIVER
		src.update()

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
		if (!user.hasStatus("knockdown"))
			user.changeStatus("knockdown", 1 SECOND)
			user.force_laydown_standup()
		update()
		return

	ex_act(severity)
		switch(severity)
			if(1)
				qdel(src)
			if(2)
				if (prob(50))
					src.set_broken()
			if(3)
				if (prob(25))
					src.set_broken()

	bullet_act(obj/projectile/P)
		. = ..()
		switch (P.proj_data.damage_type)
			if (D_KINETIC, D_PIERCING, D_SLASHING)
				if (prob(P.power))
					if (!(status & BROKEN))
						src.set_broken()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "DisposalChute")
			ui.open()

	ui_data(mob/user)
		. = list(
			"flush" = src.flush,
			"mode" = src.mode,
			"name" = src.name,
			"pressure" = MIXTURE_PRESSURE(air_contents) / (2*ONE_ATMOSPHERE),
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch(action)
			if("eject")
				src.eject()
				. = TRUE
			if("toggleHandle")
				src.flush = !src.flush
				if (src.flush)
					if (!src.is_processing)
						SubscribeToProcess()
						src.is_processing = 1
				update()
				playsound(src, 'sound/misc/handle_click.ogg', 50, TRUE)
				. = TRUE
			if("togglePump")
				if (src.mode)
					power_usage = 100
					mode = DISPOSAL_CHUTE_OFF
				else
					power_usage = 600
					if ((MIXTURE_PRESSURE(air_contents) / (2*ONE_ATMOSPHERE) >= 1))
						mode = DISPOSAL_CHUTE_CHARGED
					else
						mode = DISPOSAL_CHUTE_CHARGING
				update()
				. = TRUE

	// eject the contents of the disposal unit
	proc/eject()
		for(var/atom/movable/AM in src)
			AM.set_loc(src.loc)
			AM.pipe_eject(0)
		update()

	// update the icon & overlays to reflect mode & status
	proc/update()
		if (status & BROKEN)
			icon_state = "[icon_style]-broken"
			ClearAllOverlays()
			mode = DISPOSAL_CHUTE_OFF
			flush = 0
			power_usage = 0
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
		if (length(contents) > 0)
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
			if (DISPOSAL_CHUTE_CHARGING)
				I.icon_state = "[light_style]-charge"
			if (DISPOSAL_CHUTE_CHARGED)
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

		if(flush && MIXTURE_PRESSURE(air_contents) >= 2*ONE_ATMOSPHERE)	// flush can happen even without power
			SPAWN(0) //Quit holding up the process you fucker
				flush()

		if(status & NOPOWER)			// won't charge if no power
			return

		if (!loc) return

		if(mode != DISPOSAL_CHUTE_CHARGING)		// if off or ready, no need to charge
			return

		var/atom/L = loc						// recharging from loc turf
		var/datum/gas_mixture/env = L.return_air()
		if (!air_contents)
			air_contents = new /datum/gas_mixture
		var/pressure_delta = (3.5 * ONE_ATMOSPHERE) - MIXTURE_PRESSURE(air_contents) // purposefully trying to overshoot the target of 2 atmospheres to make it faster

		if(env.temperature > 0)
			var/transfer_moles = src.repressure_speed * pressure_delta*air_contents.volume/(env.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = env.remove(transfer_moles)
			air_contents.merge(removed)


		// if full enough, switch to ready mode
		if(MIXTURE_PRESSURE(air_contents) >= 2*ONE_ATMOSPHERE)
			mode = DISPOSAL_CHUTE_CHARGED
			power_usage = 100
			update()
			if (is_processing && !flush)
				UnsubscribeProcess()
				is_processing = 0
		return

	// perform a flush
	proc/flush()

		flushing = 1
		flick("[icon_style]-flush", src)

		var/obj/disposalholder/H = new /obj/disposalholder	// virtual holder object which actually
																// travels through the pipes.

		H.init(src)	// copy the contents of disposer to holder
		if (!isnull(src.destination_tag))
			H.mail_tag = src.destination_tag

		ZERO_GASES(src.air_contents)

		sleep(1 SECOND)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, FALSE, 0)
		sleep(0.5 SECONDS) // wait for animation to finish


		H.start(src) // start the holder processing movement
		flushing = 0
		// now reset disposal state
		flush = 0
		if(mode == DISPOSAL_CHUTE_CHARGED)	// if was ready,
			mode = DISPOSAL_CHUTE_CHARGING	// switch to charging
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
		playsound(src, 'sound/machines/hiss.ogg', 50, FALSE, 0)
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))

			ON_COOLDOWN(AM, "PipeEject", 2 SECONDS)
			AM.set_loc(get_turf(src))
			AM.pipe_eject(0)
			AM.throw_at(target, 5, 1)

		H.vent_gas(loc)
		qdel(H)

	custom_suicide = 1
	suicide(var/mob/living/carbon/human/user as mob)
		if (!istype(user) || !src.user_can_suicide(user))
			return 0
		if (src.mode != DISPOSAL_CHUTE_CHARGED)
			return 0

		user.visible_message(SPAN_ALERT("<b>[user] sticks [his_or_her(user)] head into [src] and pulls the flush!</b>"))
		var/obj/head = user.organHolder.drop_organ("head")
		head.set_loc(src)
		src.flush()
		playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
		if (user) //ZeWaka: Fix for null.loc
			make_cleanable( /obj/decal/cleanable/blood,user.loc)
			health_update_queue |= user
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	return_air(direct = FALSE)
		if (!direct)
			return src.loc?.return_air()

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

/obj/machinery/disposal/botany
	name = "produce chute"
	icon_state = "botanchute"
	desc = "A pneumatic delivery chute for sending produce to the kitchen."
	icon_style = "botan"

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
	var/frequency = FREQ_PDA

	New()
		..()
		if(!src.net_id)
			src.net_id = generate_net_id(src)
		MAKE_SENDER_RADIO_PACKET_COMPONENT(src.net_id, null, frequency)

	expel(var/obj/disposalholder/H)
		..(H)

		if (message && mailgroup)
			var/datum/signal/newsignal = get_free_signal()
			newsignal.source = src
			newsignal.data["command"] = "text_message"
			newsignal.data["sender_name"] = "CHUTE-MAILBOT"
			newsignal.data["message"] = "[message]"
			newsignal.data["address_1"] = "00000000"
			newsignal.data["group"] = list(mailgroup, MGA_MAIL)
			newsignal.data["sender"] = src.net_id

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal)

/obj/machinery/disposal/cart_port
	name = "disposal cart port"
	desc = "A pneumatic disposal chute that carts can empty their contents into."
	icon_state = "cartport"
	icon_style = "cartport"
	light_style = "cartport"
	density = 0
	layer = OBJ_LAYER-0.1
	plane = PLANE_NOSHADOW_BELOW

	MouseDrop_T(obj/storage/cart/target, mob/user)
		if (!istype(target) || target.loc != src.loc || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, target) > 0 || is_incapacitated(user) || isAI(user))
			return ..()

		if (!target.contents.len)
			boutput(user, "[target] doesn't have anything in it to load!")
			return
		src.visible_message("[user] begins depositing [target]'s contents into [src].")
		playsound(src.loc , 'sound/items/Deconstruct.ogg', 80, 0)
		for (var/atom/movable/AM in target)
			if (BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, target) > 0 || is_incapacitated(user))
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

	Entered()
		. = ..()
		flush = 1

	MouseDrop_T(mob/target, mob/user)
		if (!istype(target) || target.buckled || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, target) > 0 || is_incapacitated(user) || isAI(user) || isAI(target) || isghostcritter(user))
			return
		..()

		if (!is_processing)
			SubscribeToProcess()
			is_processing = 1

		playsound(src, 'sound/misc/handle_click.ogg', 50, TRUE)

		update()
		return

	hitby(atom/movable/MO, datum/thrown_thing/thr)
		if(istype(MO,/mob/living))
			return ..()
		return

	attack_ai(mob/user as mob)
		return

	attack_hand(mob/user)
		return


/obj/machinery/disposal/chemlink
	name = "dispensary supply chute"
	desc = "A small chute designed to send chemical supplies to medbay. An attached monitoring console shows the levels of supplies present."
	icon_state = "chemlink_on"
	destination_tag = "chemlink"
	icon_style = "chemlink"
	//stuff to emulate computer look
	var/datum/light/light
	var/image/screen_image
	///A dummy object in vis_contents so we can use flick() to animate the flush overlay
	var/obj/dummy/flush_dummy = null
	///The vendor at the other end
	var/obj/machinery/vending/player/chemicals/linked = null
	///Copied from the vendor on link
	var/list/allowed_types = null
	var/static_data_invalid = FALSE

	New()
		..()
		light = new/datum/light/point
		light.set_brightness(0.4)
		light.set_color(0.7, 1, 0.7)
		light.attach(src)

		src.screen_image = image('icons/obj/disposal.dmi', "chemlink_screen", -1)
		screen_image.plane = PLANE_LIGHTING
		screen_image.blend_mode = BLEND_ADD
		screen_image.layer = LIGHTING_LAYER_BASE
		screen_image.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)
		src.UpdateOverlays(screen_image, "screen_image")

		src.flush_dummy = new()
		src.flush_dummy.icon = src.icon
		src.flush_dummy.layer = src.layer + 1
		src.flush_dummy.mouse_opacity = FALSE
		src.vis_contents += src.flush_dummy

		SPAWN(1)
			for_by_tcl(vendor, /obj/machinery/vending/player/chemicals)
				if (vendor.id == src.destination_tag)
					src.linked = vendor
					vendor.linked = src
					return

	disposing()
		. = ..()
		src.vis_contents -= src.flush_dummy
		qdel(src.flush_dummy)
		src.flush_dummy = null

	fits_in(atom/movable/AM)
		return src.linked?.acceptsProduct(AM)

	attackby(obj/item/I, mob/user)
		. = ..()
		if (length(src.contents))
			src.flush()

	hitby(atom/movable/MO, datum/thrown_thing/thr)
		if (!src.linked?.acceptsProduct(MO))
			return
		. = ..()
		src.flush()

	MouseDrop_T(atom/target, mob/user)
		return

	flush()
		var/obj/disposalholder/H = new /obj/disposalholder	// virtual holder object which actually
																// travels through the pipes.
		H.init(src)	// copy the contents of disposer to holder
		if (!isnull(src.destination_tag))
			H.mail_tag = src.destination_tag
		H.start(src)
		flick("chemlink_flush", src.flush_dummy)
		playsound(src, 'sound/misc/handle_click.ogg', 50, TRUE)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ChemChute")
			ui.open()

	ui_static_data(mob/user)
		. = ..() || list()
		. += src.linked?.ui_static_data(user)

	power_change()
		if(src.powered())
			icon_state = initial(icon_state)
			status &= ~NOPOWER
			light.enable()
			src.UpdateOverlays(screen_image, "screen_image")
		else
			SPAWN(rand(0, 15))
				src.icon_state = "chemlink_off"
				status |= NOPOWER
				light.disable()
				src.ClearSpecificOverlays("screen_image")

	//no overlays
	update()
		if(src.status & BROKEN)
			icon_state = "[icon_style]-broken"
			mode = DISPOSAL_CHUTE_OFF
			flush = 0
			power_usage = 0

	process()
		if (src.static_data_invalid)
			src.static_data_invalid = FALSE
			src.update_static_data_for_all_viewers()

/datum/action/bar/icon/shoveMobIntoChute
	duration = 0.2 SECONDS
	interrupt_flags =  INTERRUPT_STUNNED | INTERRUPT_ACT
	icon = 'icons/obj/disposal.dmi'
	icon_state = "shoveself-disposal" //varies, see below
	var/obj/machinery/disposal/chute
	var/mob/user
	var/mob/target

	New(var/obj/machinery/disposal/chute, var/mob/target, var/mob/user)
		..()
		src.chute = chute
		src.user = user
		src.target = target
		icon_state = "shoveself-[chute.icon_style]"
		if(target != user) icon_state = "shoveother-[chute.icon_style]"

	onStart()
		..()
		if(!checkStillValid()) return


	onUpdate()
		..()
		if(!checkStillValid()) return

	onEnd()
		if(checkStillValid())
			if (target.buckled || BOUNDS_DIST(user, chute) > 0 || BOUNDS_DIST(user, target) > 0 || ((is_incapacitated(user) && user != target)))
				..()
				return

			var/msg
			if(target == user)
				msg = "[user.name] climbs into the [chute]."
				boutput(user, "You climb into the [chute].")
			else if(target != user && !user.restrained())
				msg = "[user.name] stuffs [target.name] into the [chute]!"
				boutput(user, "You stuff [target.name] into the [chute]!")
				logTheThing(LOG_COMBAT, user, "places [constructTarget(target,"combat")] into [chute] at [log_loc(chute)].")
			else
				..()
				return
			target.set_loc(chute)

			if (msg)
				chute.visible_message(msg)

			chute.ui_interact(user)

			chute.update()
		..()

	onDelete()
		..()

	proc/checkStillValid()
		if(isnull(user) || isnull(target) || isnull(chute))
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		return TRUE


#undef DISPOSAL_REPAIR_STEP_FIXED
#undef DISPOSAL_REPAIR_STEP_SCREWDRIVER
#undef DISPOSAL_REPAIR_STEP_CROWBAR

#undef DISPOSAL_CHUTE_OFF
#undef DISPOSAL_CHUTE_CHARGING
#undef DISPOSAL_CHUTE_CHARGED
