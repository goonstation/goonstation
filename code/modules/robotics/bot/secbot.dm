#define IS_NOT_BEEPSKY_AND_HAS_SOME_GENERIC_BATON 0				// Just some everyday bot on the beat
#define IS_BEEPSKY_AND_HAS_HIS_SPECIAL_BATON 1						// Full-assed Beepsky
#define IS_NOT_BEEPSKY_BUT_HAS_HIS_SPECIAL_BATON 2				// A Beepsky brand secboton
#define IS_BEEPSKY_BUT_HAS_SOME_GENERIC_BATON 3						// A generic-ass shitcurity baton
#define IS_NOT_BEEPSKY_BUT_HAS_A_GENERIC_SPECIAL_BATON 4	// A generic, non-Beepsky brand secboton

/obj/machinery/bot/secbot
	name = "Securitron"
#ifdef HALLOWEEN
	desc = "A little security robot, apparently carved out of a pumpkin.  He looks...spooky?"
	icon = 'icons/misc/halloween.dmi'
#else
	desc = "A little security robot.  He looks less than thrilled."
	icon = 'icons/obj/bots/aibots.dmi'
#endif
	icon_state = "secbot0"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = 0
	luminosity = 2
//	weight = 1.0E7
	req_access = list(access_security)
	var/weapon_access = access_carrypermit
	var/contraband_access = access_contrabandpermit
	var/obj/item/baton/secbot/our_baton // Our baton

	on = 1
	locked = 1 //Behavior Controls lock
	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
	var/frustration = 0
	emagged = 0 //Emagged Secbots view everyone as a criminal
	health = 25
	var/idcheck = 1 //If false, all station IDs are authorized for weapons.
	var/check_records = 1 //Does it check security records?
	var/arrest_type = 0 //If true, don't handcuff
	var/report_arrests = 0 //If true, report arrests over PDA messages.
	var/is_beepsky = IS_NOT_BEEPSKY_AND_HAS_SOME_GENERIC_BATON	// How Beepsky are we?
	var/botcard_access = "Head of Security" //Job access for doors.
	var/hat = null //Add an overlay from bots/aibots.dmi with this state.  hats.
	var/our_baton_type = /obj/item/baton/secbot
	var/loot_baton_type = /obj/item/scrap
	var/stun_type = "stun"
	var/mode = 0
#define SECBOT_IDLE 		0		// idle
#define SECBOT_HUNT 		1		// found target, hunting
#define SECBOT_PREP_ARREST 	2		// at target, preparing to arrest
#define SECBOT_ARREST		3		// arresting target
#define SECBOT_START_PATROL	4		// start patrol
#define SECBOT_PATROL		5		// patrolling
#define SECBOT_SUMMON		6		// summoned by PDA

	var/auto_patrol = 0		// set to make bot automatically patrol

	var/beacon_freq = 1445		// navigation beacon frequency
	var/control_freq = 1447		// bot control frequency


	var/turf/patrol_target	// this is turf to navigate to (location of beacon)
	var/new_destination		// pending new destination (waiting for beacon response)
	var/destination			// destination description tag
	var/next_destination	// the next destination in the patrol route
	var/list/path = null	// list of path turfs

	var/moving = 0 //Are we currently ON THE MOVE?
	var/current_movepath = 0
	var/datum/secbot_mover/mover = null
	var/arrest_move_delay = 2.5
	var/emag_stages = 2 //number of times we can emag this thing

	var/blockcount = 0		//number of times retried a blocked path
	var/awaiting_beacon	= 0	// count of pticks awaiting a beacon response

	var/nearest_beacon			// the nearest beacon's tag
	var/turf/nearest_beacon_loc	// the nearest beacon's location

	var/last_attack = 0
	var/attack_per_step = 0 // Tries to attack every step. 1 = 75% chance to attack, 2 = 25% chance to attack

	disposing()
		if(mover)
			mover.dispose()
			mover = null
		if(our_baton)
			our_baton.dispose()
			our_baton = null
		target = null
		radio_controller.remove_object(src, "1149")
		radio_controller.remove_object(src, "[control_freq]")
		radio_controller.remove_object(src, "[beacon_freq]")
		..()

/obj/machinery/bot/secbot/autopatrol
	auto_patrol = 1

/obj/machinery/bot/secbot/beepsky
	name = "Officer Beepsky"
	desc = "It's Officer Beepsky! He's a loose cannon but he gets the job done."
	idcheck = 1
	auto_patrol = 1
	report_arrests = 1
	loot_baton_type = /obj/item/baton/beepsky
	is_beepsky = IS_BEEPSKY_AND_HAS_HIS_SPECIAL_BATON
	hat = "nt"
	attack_per_step = 1

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	explode()
		//////PDA NOTIFY/////
		var/bot_location = get_area(src)
		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="SECURITY-MAILBOT",  "group"=MGD_SECURITY, "sender"="00000000", "message"="Notification: [src] destroyed in [bot_location]! Officer down!")
		pdaSignal.transmission_method = TRANSMISSION_RADIO
		if(transmit_connection != null)
			transmit_connection.post_signal(src, pdaSignal)

		..()

/obj/machinery/bot/secbot/warden
	name = "Warden Jack"
	desc = "The mechanical guardian of the brig."
	auto_patrol = 1
	beacon_freq = 1444
	hat = "helm"

/obj/machinery/bot/secbot/commissar
	name = "Commissar Beepevich"
	desc = "Nobody gets in his way and lives to tell about it."
	health = 40000
	hat = "hos"

/obj/machinery/bot/secbot/formal
	name = "Lord Beepingshire"
	desc = "The most distinguished of security robots."
	hat = "that"

/obj/machinery/bot/secbot/haunted
	name = "Beep-o-Lantern"
	desc = "A little security robot, apparently carved out of a pumpkin.  He looks...spooky?"
	icon = 'icons/misc/halloween.dmi'

/obj/machinery/bot/secbot/brute
	name = "Komisarz Beepinarska"
	desc = "This little security robot seems to have a particularly large chip on its... shoulder? ...head?"
	our_baton_type = /obj/item/baton/classic
	loot_baton_type = /obj/item/baton/classic
	stun_type = "harm_classic"
	emagged = 2
	control_freq = 0

	demag()
		//Nope
		return

/obj/machinery/bot/secbot/stamina_test
	name = "test secbot"
	desc = "stamina test"
	our_baton_type = /obj/item/baton/stamina
	loot_baton_type = /obj/item/baton/stamina

/obj/item/secbot_assembly
	name = "helmet/signaler assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/is_dead_beepsky = 0
	var/build_step = 0
	var/created_name = "Securitron" //To preserve the name if it's a unique securitron I guess
	var/beacon_freq = 1445 //If it's running on another beacon circuit I guess
	var/hat = null


/obj/machinery/bot/secbot
	New()
		..()
		src.icon_state = "secbot[src.on]"
		if (!src.our_baton || !istype(src.our_baton))
			src.our_baton = new our_baton_type(src)
		#if ASS_JAM
		src.emag_stages = 3
		#endif

		add_simple_light("secbot", list(255, 255, 255, 0.4 * 255))


		SPAWN_DBG(0.5 SECONDS)
			src.botcard = new /obj/item/card/id(src)
			src.botcard.access = get_access(src.botcard_access)
			if(radio_controller)
				radio_controller.add_object(src, "[control_freq]")
				radio_controller.add_object(src, "[beacon_freq]")
			if(src.hat)
				src.overlays += image('icons/obj/bots/aibots.dmi', "hat-[src.hat]")

	attack_hand(mob/user as mob, params)
		var/dat

		dat += {"
<TT><B>Automatic Security Unit v2.0</B></TT><BR><BR>
Status: <A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A><BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]"}

		if(!src.locked)
			dat += {"<hr>
Check for Unauthorised Equipment: <A href='?src=\ref[src];operation=idcheck'>[src.idcheck ? "Yes" : "No"]</A><BR>
Check Security Records: <A href='?src=\ref[src];operation=ignorerec'>[src.check_records ? "Yes" : "No"]</A><BR>
Operating Mode: <A href='?src=\ref[src];operation=switchmode'>[src.arrest_type ? "Detain" : "Arrest"]</A><BR>
Auto Patrol: <A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A><BR>
Report Arrests: <A href='?src=\ref[src];operation=report'>[report_arrests ? "On" : "Off"]</A>"}

		if (user.client.tooltipHolder)
			user.client.tooltipHolder.showClickTip(src, list(
				"params" = params,
				"title" = "Securitron v2.0 controls",
				"content" = dat,
			))

		return

	Topic(href, href_list)
		if(..())
			return
		src.add_dialog(usr)
		src.add_fingerprint(usr)
		if ((href_list["power"]) && (!src.locked || src.allowed(usr)))
			src.on = !src.on
			if (src.on)
				add_simple_light("secbot", list(255, 255, 255, 0.4 * 255))
			else
				remove_simple_light("secbot")
			src.target = null
			src.oldtarget_name = null
			src.anchored = 0
			src.mode = SECBOT_IDLE
			walk_to(src,0)
			src.icon_state = "secbot[src.on][(src.on && src.emagged >= 2) ? "-wild" : null]"
			src.updateUsrDialog()

		switch(href_list["operation"])
			if ("idcheck")
				src.idcheck = !src.idcheck
				src.updateUsrDialog()
			if ("ignorerec")
				src.check_records = !src.check_records
				src.updateUsrDialog()
			if ("switchmode")
				src.arrest_type = !src.arrest_type
				src.updateUsrDialog()
			if("patrol")
				auto_patrol = !auto_patrol
				mode = SECBOT_IDLE
				updateUsrDialog()
			if("report")
				report_arrests = !src.report_arrests
				updateUsrDialog()

	attack_ai(mob/user as mob)
		if (src.on && src.emagged)
			boutput(user, "<span class='alert'>[src] refuses your authority!</span>")
			return
		src.on = !src.on
		src.target = null
		src.oldtarget_name = null
		mode = SECBOT_IDLE
		src.anchored = 0
		src.icon_state = "secbot[src.on][(src.on && src.emagged >= 2) ? "-wild" : null]"
		walk_to(src,0)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (src.emagged < emag_stages)
			if (emagged)
				if (user)
					boutput(user, "<span class='alert'>You short out [src]'s system clock inhibition circuis.</span>")
				src.overlays.len = 0
			else if (user)
				boutput(user, "<span class='alert'>You short out [src]'s target assessment circuits.</span>")
			SPAWN_DBG(0)
				for(var/mob/O in hearers(src, null))
					O.show_message("<span class='alert'><B>[src] buzzes oddly!</B></span>", 1)

			src.anchored = 0
			src.emagged++
			src.on = 1
			src.icon_state = "secbot[src.on][(src.on && src.emagged >= 2) ? "-wild" : null]"
			mode = SECBOT_IDLE
			src.target = null

			#if ASS_JAM
			if(src.emagged >= 3)
				src.stun_type = "harm_classic"
				arrest_move_delay = 1.5
				playsound(src.loc, 'sound/effects/elec_bzzz.ogg', 99, 1, 0.1, 0.7)
			#endif

			if(user)
				src.oldtarget_name = user.name
				src.last_found = world.time
			logTheThing("station", user, null, "emagged a [src] at [log_loc(src)].")
			return 1
		return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("You repair [src]'s damaged electronics. Thank God.", "blue")
		src.emagged = 0
		mode = SECBOT_IDLE
		src.target = null
		src.anchored = 0
		src.icon_state = "secbot0"
		return 1


	emp_act()
		..()
		if(!src.emagged && prob(75))
			src.emagged = 1
			src.visible_message("<span class='alert'><B>[src] buzzes oddly!</B></span>")
			src.on = 1
		else
			src.explode()
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/device/pda2) && W:ID_card)
			W = W:ID_card
		if (istype(W, /obj/item/card/id))
			if (src.allowed(user))
				src.locked = !src.locked
				boutput(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
				src.updateUsrDialog()
			else
				boutput(user, "<span class='alert'>Access denied.</span>")

		else if (isscrewingtool(W))
			if (src.health < initial(health))
				src.health = initial(health)
				src.visible_message("<span class='alert'>[user] repairs [src]!</span>", "<span class='alert'>You repair [src].</span>")
		else
			switch(W.hit_type)
				if (DAMAGE_BURN)
					src.health -= W.force * 0.75
				else
					src.health -= W.force * 0.5
			if (src.health <= 0)
				src.explode()
			else if (W.force && (!iscarbon(src.target) || (src.mode != SECBOT_HUNT)))
				src.target = user
				src.mode = SECBOT_HUNT
			..()

	proc/navigate_to(atom/the_target,var/move_delay=3,var/adjacent=0)
		if(src.moving) return 1
		src.moving = 1
		src.frustration = 0
		if(src.mover)
			src.mover.master = null
			src.mover = null

		current_movepath = world.time

		src.mover = new /datum/secbot_mover(src)

		// drsingh for cannot modify null.delay
		if (!isnull(src.mover))
			src.mover.master_move(the_target,current_movepath,adjacent)

		// drsingh again for the same thing further down in a moment.
		// Because master_move can delete the mover

		if (!isnull(src.mover))
			src.mover.delay = max(min(move_delay,5),2)

		return 0

	proc/baton_attack(var/mob/living/carbon/M)
		src.icon_state = "secbot-c[src.emagged >= 2 ? "-wild" : null]"
		var/maxstuns = 4
		var/stuncount = (src.emagged >= 2) ? rand(5,10) : 1

		last_attack = world.time

		while (stuncount > 0 && src.target)
			// No need for unnecessary hassle, just make it ignore charges entirely for the time being.
			if (src.our_baton && istype(src.our_baton))
				if (src.our_baton.uses_electricity == 0)
					src.our_baton.uses_electricity = 1
				if (src.our_baton.uses_charges != 0)
					src.our_baton.uses_charges = 0
			else
				src.our_baton = new our_baton_type(src)

			stuncount--
			src.our_baton.do_stun(src, M, src.stun_type, 2)
			if (!stuncount && maxstuns-- <= 0)
				target = null
			if (stuncount > 0)
				sleep(0.3 SECONDS)

		SPAWN_DBG(0.2 SECONDS)
			src.icon_state = "secbot[src.on][(src.on && src.emagged >= 2) ? "-wild" : null]"
		if (src.target.getStatusDuration("weakened"))
			mode = SECBOT_PREP_ARREST
			src.anchored = 1
			src.target_lastloc = M.loc
			moving = 0

			//qdel(src.mover)
			if (src.mover)
				src.mover.master = null
				src.mover = null
			src.frustration = 0
		return

	Move(var/turf/NewLoc, direct)
		var/oldloc = src.loc
		..()
		if (src.attack_per_step && prob(src.attack_per_step == 2 ? 25 : 75))
			if (oldloc != NewLoc && world.time != last_attack)
				if (mode == SECBOT_HUNT && target)
					if (get_dist(src, src.target) <= 1)
						src.baton_attack(src.target)

	process()
		if (!src.on)
			return

		switch(mode)

			if(SECBOT_IDLE)		// idle

				walk_to(src,0)
				look_for_perp()	// see if any criminals are in range
				if(!mode && auto_patrol)	// still idle, and set to patrol
					mode = SECBOT_START_PATROL	// switch to patrol mode

			if(SECBOT_HUNT)		// hunting for perp

				// if can't reach perp for long enough, go idle
				if (src.frustration >= 8)
			//		for(var/mob/O in hearers(src, null))
			//			boutput(O, "<span class='game say'><span class='name'>[src]</span> beeps, \"Backup requested! Suspect has evaded arrest.\"")
					src.target = null
					src.last_found = world.time
					src.frustration = 0
					src.mode = 0
					//qdel(src.mover)
					if (src.mover)
						src.mover.master = null
						src.mover = null
					src.moving = 0
					//walk_to(src,0)

				if (target)		// make sure target exists
					if (get_dist(src, src.target) <= 1)		// if right next to perp
						src.baton_attack(src.target)
					else								// not next to perp
						if(!(src.target in view(7,src)) || !moving)
							//qdel(src.mover)
							if (src.mover)
								src.mover.master = null
								src.mover = null
							src.moving = 0
							navigate_to(src.target,(src.emagged >= 2) ? (arrest_move_delay/2) : arrest_move_delay)
							return
					/*
						var/turf/olddist = get_dist(src, src.target)
						walk_to(src, src.target,1,4)
						if ((get_dist(src, src.target)) >= (olddist))
							src.frustration++
						else
							src.frustration = 0
					*/

			if(SECBOT_PREP_ARREST)		// preparing to arrest target

				// see if he got away
				if ((get_dist(src, src.target) > 1) || ((src.target:loc != src.target_lastloc) && src.target:getStatusDuration("weakened") < 20))
					src.anchored = 0
					mode = SECBOT_HUNT
					if (!src.mover)
						src.moving = 0
						navigate_to(src.target)
					return
/*
				if (ishuman(src.target))
					var/mob/living/carbon/human/H = src.target
					if(isabomination(H))
						return
*/
				if (!src.target.hasStatus("handcuffed") && !src.arrest_type)
					playsound(src.loc, "sound/weapons/handcuffs.ogg", 30, 1, -2)
					mode = SECBOT_ARREST
					src.visible_message("<span class='alert'><B>[src] is trying to put handcuffs on [src.target]!</B></span>")

					SPAWN_DBG(6 SECONDS)
						if (get_dist(src, src.target) <= 1)
							if (!src.target || src.target.hasStatus("handcuffed"))
								return

							var/uncuffable = 0
							if (ishuman(src.target))
								var/mob/living/carbon/human/H = src.target
								//if(H.bioHolder.HasEffect("lost_left_arm") || H.bioHolder.HasEffect("lost_right_arm"))
								if(!H.limbs.l_arm || !H.limbs.r_arm)
									uncuffable = 1

							if (!isturf(src.target.loc))
								uncuffable = 1

							if(ishuman(src.target) && !uncuffable)
								src.target.handcuffs = new /obj/item/handcuffs(src.target)
								src.target.setStatus("handcuffed", duration = INFINITE_STATUS)

							var/last_target = target

							mode = SECBOT_IDLE
							src.target = null
							src.anchored = 0
							src.last_found = world.time
							src.frustration = 0

							if(!uncuffable) playsound(src.loc, pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg'), 50, 0, 0, 1)
			//					var/arrest_message = pick("Have a secure day!","I AM THE LAW.", "God made tomorrow for the crooks we don't catch today.","You can't outrun a radio.")
			//					src.speak(arrest_message)
							if (src.report_arrests && !uncuffable)
								var/bot_location = get_area(src)
									//////PDA NOTIFY/////
								var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
								var/datum/signal/pdaSignal = get_free_signal()
								pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="SECURITY-MAILBOT",  "group"=MGD_SECURITY, "sender"="00000000", "message"="Notification: [last_target] detained by [src] in [bot_location].")
								pdaSignal.transmission_method = TRANSMISSION_RADIO
								if(transmit_connection != null)
									transmit_connection.post_signal(src, pdaSignal)

			if(SECBOT_ARREST)		// arresting

				if (src.frustration >= 8)
					src.target = null
					src.last_found = world.time
					src.frustration = 0
					src.mode = 0
					//qdel(src.mover)
					if (src.mover)
						src.mover.master = null
						src.mover = null
					src.moving = 0

				if(src.target)
					if (src.target.hasStatus("handcuffed"))
						src.anchored = 0
						mode = SECBOT_IDLE
						return
					else if (!src.target.getStatusDuration("weakened"))
						src.anchored = 0
						mode = SECBOT_HUNT

					if (get_dist(src, src.target) > 1 && (!src.mover || !src.moving))
						//qdel(src.mover)
						if (src.mover)
							src.mover.master = null
							src.mover = null
						src.moving = 0
						navigate_to(src.target)
						return
				else
					mode = SECBOT_IDLE
					return


			if(SECBOT_START_PATROL)	// start a patrol

				if(path && path.len && patrol_target) // have a valid path, so just resume
					mode = SECBOT_PATROL
					return

				else if(patrol_target)		// has patrol target already
					SPAWN_DBG(0)
						calc_path()		// so just find a route to it
						if(!path || !path.len)
							patrol_target = 0
							return
						mode = SECBOT_PATROL


				else					// no patrol target, so need a new one
					find_patrol_target()
						//speak("Engaging patrol mode.")


			if(SECBOT_PATROL)		// patrol mode

				patrol_step()
				SPAWN_DBG(0.5 SECONDS)
					if(mode == SECBOT_PATROL)
						patrol_step()

			if(SECBOT_SUMMON)		// summoned to PDA
				patrol_step()
				SPAWN_DBG(0.4 SECONDS)
					if(mode == SECBOT_SUMMON)
						patrol_step()
						sleep(0.4 SECONDS)
						patrol_step()

		return


	// perform a single patrol step

	proc/patrol_step()

		if(loc == patrol_target)		// reached target
			at_patrol_target()
			return

		else if (path && path.len && patrol_target) // valid path

			var/turf/next = path[1]
			if(next == loc)
				path -= next
				return


			if(istype( next, /turf/simulated))

				var/moved = step_towards(src, next)	// attempt to move
				if(moved)	// successful move
					blockcount = 0
					path -= loc

					look_for_perp()
				else		// failed to move

					blockcount++

					if(blockcount > 5)	// attempt 5 times before recomputing
						// find new path excluding blocked turf

						SPAWN_DBG(0.2 SECONDS)
							calc_path(next)
							if (!path)
								find_patrol_target()
							else
								blockcount = 0

						return

					return

			else	// not a valid turf
				mode = SECBOT_IDLE
				return

		else	// no path, so calculate new one
			mode = SECBOT_START_PATROL


	// finds a new patrol target
	proc/find_patrol_target()
		send_status()
		if(awaiting_beacon)			// awaiting beacon response
			awaiting_beacon++
			if(awaiting_beacon > 5)	// wait 5 secs for beacon response
				find_nearest_beacon()	// then go to nearest instead
				return 0
			else
				return 1

		if(next_destination)
			set_destination(next_destination)
			return 1
		else
			find_nearest_beacon()
			return 0


	// finds the nearest beacon to self
	// signals all beacons matching the patrol code
	proc/find_nearest_beacon()
		nearest_beacon = null
		new_destination = "__nearest__"
		post_signal(beacon_freq, "findbeacon", "patrol")
		awaiting_beacon = 1
		SPAWN_DBG(1 SECOND)
			awaiting_beacon = 0
			if(nearest_beacon)
				set_destination(nearest_beacon)
			else
				auto_patrol = 0
				mode = SECBOT_IDLE
				//speak("Disengaging patrol mode.")
				send_status()


	proc/at_patrol_target()
		find_patrol_target()
		return


	// sets the current destination
	// signals all beacons matching the patrol code
	// beacons will return a signal giving their locations
	proc/set_destination(var/new_dest)
		new_destination = new_dest
		post_signal(beacon_freq, "findbeacon", "patrol")
		awaiting_beacon = 1


	// receive a radio signal
	// used for beacon reception

	receive_signal(datum/signal/signal)

		if(!on)
			return

		/*
		boutput(world, "rec signal: [signal.source]")
		for(var/x in signal.data)
			boutput(world, "* [x] = [signal.data[x]]")
		*/

		var/recv = signal.data["command"]
		// process all-bot input
		if(recv=="bot_status")
			send_status()

		// check to see if we are the commanded bot
		if(signal.data["active"] == src)
		// process control input
			switch(recv)
				if("stop")
					mode = SECBOT_IDLE
					auto_patrol = 0
					return

				if("go")
					mode = SECBOT_IDLE
					auto_patrol = 1
					return

				if("summon")
					patrol_target = signal.data["target"]
					next_destination = destination
					destination = null
					awaiting_beacon = 0
					mode = SECBOT_SUMMON
					calc_path()
					speak("Responding.")

					return



		// receive response from beacon
		recv = signal.data["beacon"]
		var/valid = signal.data["patrol"]
		if(!recv || !valid)
			return

		if(recv == new_destination)	// if the recvd beacon location matches the set destination
									// the we will navigate there
			destination = new_destination
			patrol_target = signal.source.loc
			next_destination = signal.data["next_patrol"]
			awaiting_beacon = 0

		// if looking for nearest beacon
		else if(new_destination == "__nearest__")
			var/dist = get_dist(src,signal.source.loc)
			if(nearest_beacon)

				// note we ignore the beacon we are located at
				if(dist>1 && dist<get_dist(src,nearest_beacon_loc))
					nearest_beacon = recv
					nearest_beacon_loc = signal.source.loc
					return
				else
					return
			else if(dist > 1)
				nearest_beacon = recv
				nearest_beacon_loc = signal.source.loc
		return


	// send a radio signal with a single data key/value pair
	proc/post_signal(var/freq, var/key, var/value)
		post_signal_multiple(freq, list("[key]" = value) )

	// send a radio signal with multiple data key/values
	proc/post_signal_multiple(var/freq, var/list/keyval)

		var/datum/radio_frequency/frequency = radio_controller.return_frequency("[freq]")

		if(!frequency) return

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = 1
		for(var/key in keyval)
			signal.data[key] = keyval[key]
			//boutput(world, "sent [key],[keyval[key]] on [freq]")
		frequency.post_signal(src, signal)

	// signals bot status etc. to controller
	proc/send_status()
		var/list/kv = new()
		kv["type"] = "secbot"
		kv["name"] = name
		kv["loca"] = get_area(src)
		kv["mode"] = mode
		post_signal_multiple(control_freq, kv)



// calculates a path to the current destination
// given an optional turf to avoid
	proc/calc_path(var/turf/avoid = null)
		if (!isturf(src.loc))
			return
		src.path = AStar(src.loc, patrol_target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 120, botcard, avoid)


// look for a criminal in view of the bot

	proc/look_for_perp()
		src.anchored = 0
		for (var/mob/living/carbon/C in view(7,src)) //Let's find us a criminal
			if ((C.stat) || (C.hasStatus("handcuffed")))
				continue
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100))
				continue
			if (ishuman(C))
				src.threatlevel = src.assess_perp(C)
			if (!src.threatlevel)
				continue

			else if (src.threatlevel >= 4)
				src.target = C
				src.oldtarget_name = C.name
				src.speak("Level [src.threatlevel] infraction alert!")
				playsound(src.loc, pick('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg'), 50, 0)
				src.visible_message("<b>[src]</b> points at [C.name]!")
				mode = SECBOT_HUNT
				SPAWN_DBG(0)
					src.frustration = 0
					if(!src.moving || !src.mover)
						src.moving = 0
						src.navigate_to(src.target)
					process()	// ensure bot quickly responds to a perp
				// sorry for making a mess here i will clean it up later i promise xoxoxo -drsingh
				SPAWN_DBG(0)
					var/weeoo = 10
					playsound(src.loc, "sound/machines/siren_police.ogg", 50, 1)

					while (weeoo)
						add_simple_light("secbot", list(255 * 0.9, 255 * 0.1, 255 * 0.1, 0.8 * 255))
						sleep(0.3 SECONDS)
						add_simple_light("secbot", list(255 * 0.1, 255 * 0.1, 255 * 0.9, 0.8 * 255))
						sleep(0.3 SECONDS)
						weeoo--

					//old one in case we still want that
					/*
					light.set_brightness(0.8)
					while (weeoo)
						light.set_color(0.9, 0.1, 0.1)
						sleep(0.3 SECONDS)
						light.set_color(0.1, 0.1, 0.9)
						sleep(0.3 SECONDS)
						weeoo--
					light.set_brightness(0.4)
					light.set_color(1, 1, 1)
					*/

					add_simple_light("secbot", list(255, 255, 255, 0.4 * 255))
				break
			else
				continue


//If the security records say to arrest them, arrest them
//Or if they have weapons and aren't security, arrest them.
	proc/assess_perp(mob/living/carbon/human/perp as mob)
		var/threatcount = 0

		if(src.emagged) return 10 //Everyone is a criminal!

		if((src.idcheck)) // bot is set to actively search for contraband
			var/obj/item/card/id/perp_id = perp.equipped()
			if (!istype(perp_id))
				perp_id = perp.wear_id

			var/has_carry_permit = 0
			var/has_contraband_permit = 0

			if(perp_id) //Checking for permits
				if(weapon_access in perp_id.access)
					has_carry_permit = 1
				if(contraband_access in perp_id.access)
					has_contraband_permit = 1

			/*
			if(istype(perp.l_hand, /obj/item/gun) || istype(perp.l_hand, /obj/item/baton) || istype(perp.l_hand, /obj/item/sword))
				threatcount += 4

			if(istype(perp.r_hand, /obj/item/gun) || istype(perp.r_hand, /obj/item/baton) || istype(perp.r_hand, /obj/item/sword))
				threatcount += 4

			if(istype(perp:belt, /obj/item/gun) || istype(perp:belt, /obj/item/baton) || istype(perp:belt, /obj/item/sword))
				threatcount += 2

			if(istype(perp:wear_suit, /obj/item/clothing/suit/wizrobe))
				threatcount += 4
			*/
			if (istype(perp.l_hand))
				if (istype(perp.l_hand, /obj/item/gun/)) // perp is carrying a gun
					if(!has_carry_permit)
						threatcount += perp.l_hand.contraband
				else // not carrying a gun, but potential contraband?
					if(!has_contraband_permit)
						threatcount += perp.l_hand.contraband

			if (istype(perp.r_hand))
				if (istype(perp.r_hand, /obj/item/gun/)) // perp is carrying a gun
					if(!has_carry_permit)
						threatcount += perp.r_hand.contraband
				else // not carrying a gun, but potential contraband?
					if(!has_contraband_permit)
						threatcount += perp.r_hand.contraband

			if (istype(perp.belt))
				if (istype(perp.belt, /obj/item/gun/))
					if (!has_carry_permit)
						threatcount += perp.belt.contraband * 0.5
				else
					if (!has_contraband_permit)
						threatcount += perp.belt.contraband * 0.5

			if (istype(perp.wear_suit))
				if (!has_contraband_permit)
					threatcount += perp.wear_suit.contraband

			if (istype(perp.back))
				if (istype(perp.back, /obj/item/gun/)) // some weapons can be put on backs
					if (!has_carry_permit)
						threatcount += perp.back.contraband * 0.5
				else // at moment of doing this we don't have other contraband back items, but maybe that'll change
					if (!has_contraband_permit)
						threatcount += perp.back.contraband * 0.5


		if(istype(perp.mutantrace, /datum/mutantrace/abomination))
			threatcount += 5

		//Agent cards lower threat level
		if((istype(perp.wear_id, /obj/item/card/id/syndicate)))
			threatcount -= 2

		// we have grounds to make an arrest, don't bother with further analysis
		if(threatcount >= 4)
			return threatcount

		if (src.check_records) // bot is set to actively compare security records
			var/see_face = 1
			if (istype(perp.wear_mask) && !perp.wear_mask.see_face)
				see_face = 0
			else if (istype(perp.head) && !perp.head.see_face)
				see_face = 0
			else if (istype(perp.wear_suit) && !perp.wear_suit.see_face)
				see_face = 0

			var/perpname = see_face ? perp.real_name : perp.name

			for (var/i in data_core.general)
				var/datum/data/record/E = i
				if (E.fields["name"] == perpname)
					for (var/j in data_core.security)
						var/datum/data/record/R = j
						if ((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
							threatcount = 4
							break
					break

		return threatcount

	Bumped(M as mob|obj)
		SPAWN_DBG(0)
			var/turf/T = get_turf(src)
			M:set_loc(T)

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round(((P.power/4)*P.proj_data.ks_ratio), 1.0)

		if(P.proj_data.damage_type == D_KINETIC)
			src.health -= damage
		else if(P.proj_data.damage_type == D_PIERCING)
			src.health -= (damage*2)
		else if(P.proj_data.damage_type == D_ENERGY)
			src.health -= damage

		if (src.health <= 0)
			src.explode()
			return

		if (ismob(P.shooter))
			var/mob/living/M = P.shooter
			if (P && iscarbon(M) && (!iscarbon(src.target) || (src.mode != SECBOT_HUNT)))
				src.target = M
				src.mode = SECBOT_HUNT
		return

	speak(var/message)
		if (src.emagged >= 2)
			message = capitalize(ckeyEx(message))
			..(message)

	//Generally we want to explode() instead of just deleting the securitron.
	ex_act(severity)
		switch(severity)
			if(1.0)
				src.explode()
				return
			if(2.0)
				src.health -= 15
				if (src.health <= 0)
					src.explode()
				return
		return

	meteorhit()
		src.explode()
		return

	blob_act(var/power)
		if(prob(25 * power / 20))
			src.explode()
		return

	explode()
		if(src.exploding) return
		src.exploding = 1
		walk_to(src,0)
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
		var/turf/Tsec = get_turf(src)

		var/obj/item/secbot_assembly/Sa = new /obj/item/secbot_assembly(Tsec)
		Sa.build_step = 1
		Sa.overlays += image('icons/obj/bots/aibots.dmi', "hs_hole")
		Sa.created_name = src.name
		Sa.beacon_freq = src.beacon_freq
		Sa.hat = src.hat
		if (src.is_beepsky == IS_BEEPSKY_AND_HAS_HIS_SPECIAL_BATON || src.is_beepsky == IS_BEEPSKY_BUT_HAS_SOME_GENERIC_BATON)	// Being Beepsky doesnt give you his baton, but it does mean you're him
			Sa.is_dead_beepsky = 1
		new /obj/item/device/prox_sensor(Tsec)

		// Not charged when dropped (ran on Beepsky's internal battery or whatever).
		if (istype(loot_baton_type, /obj/item/baton)) // Now we can drop *any* baton!
			var/obj/item/baton/B = new loot_baton_type(Tsec)
			B.status = 0
			B.process_charges(-INFINITY)
			if (src.is_beepsky == IS_BEEPSKY_AND_HAS_HIS_SPECIAL_BATON || src.is_beepsky == IS_NOT_BEEPSKY_BUT_HAS_HIS_SPECIAL_BATON)	// Holding Beepsky's baton doesnt make you him, but it does mean you're holding his baton
				B.name = "Beepsky's stun baton"
				B.beepsky_held_this = 1 // Just as a flag so we can know if this baton used to be Beepsky's. Maybe secbots just dont like people walking around with his sidearm vOv
		else
			new loot_baton_type(Tsec)

		if (prob(50))
			new /obj/item/parts/robot_parts/arm/left(Tsec)

		elecflash(src, radius=1, power=3, exclude_center = 0)
		qdel(src)


//movement control datum. Why yes, this is copied from guardbot.dm
/datum/secbot_mover
	var/obj/machinery/bot/secbot/master = null
	var/delay = 3

	New(var/newmaster)
		..()
		if(istype(newmaster, /obj/machinery/bot/secbot))
			src.master = newmaster
		return

	disposing()
		if(master.mover == src)
			master.mover = null
		src.master = null
		..()

	proc/master_move(var/atom/the_target as obj|mob, var/current_movepath,var/adjacent=0)
		if(!master || !isturf(master.loc))
			src.master = null
			//dispose()
			return
		var/target_turf = null
		if(isturf(the_target))
			target_turf = the_target
		else
			target_turf = get_turf(the_target)
		SPAWN_DBG(0)
			if (!master)
				return
			var/compare_movepath = current_movepath
			master.path = AStar(get_turf(master), target_turf, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 60, master.botcard)
			if(adjacent && master.path && master.path.len) //Make sure to check it isn't null!!
				master.path.len-- //Only go UP to the target, not the same tile.
			if(!master.path || !master.path.len || !the_target)
				//if(master.task)
				//	master.task.task_input("path_error")

				master.frustration = INFINITY
				master.mover = null
				master = null
				//dispose()
				return 1

			while(master && master.path && master.path.len && target_turf && master.moving)
//				boutput(world, "[compare_movepath] : [current_movepath]")
				if(compare_movepath != current_movepath) break
				if(!master.on)
					master.frustration = 0
					break
				step_to(master, master.path[1])
				if(master.loc != master.path[1])
					master.frustration++
					sleep(delay)
					continue
				master?.path -= master?.path[1]
				sleep(delay)

			if (master)
				master.moving = 0
				master.mover = null
				master = null

			//dispose()
			return

		return



//Secbot Construction

/obj/item/clothing/head/helmet/hardhat/security/attackby(var/obj/item/device/radio/signaler/S, mob/user as mob)
	if (!istype(S, /obj/item/device/radio/signaler))
		..()
		return

	if (!S.b_stat)
		return
	else
		var/obj/item/secbot_assembly/A = new /obj/item/secbot_assembly
		user.u_equip(S)
		user.put_in_hand_or_drop(A)
		boutput(user, "You add the signaler to the helmet.")
		qdel(S)
		qdel(src)


/obj/item/secbot_assembly/attackby(obj/item/W as obj, mob/user as mob)
	if ((isweldingtool(W)) && (!src.build_step))
		if(W:try_weld(user, 1))
			src.build_step++
			src.overlays += image('icons/obj/bots/aibots.dmi', "hs_hole")
			boutput(user, "You weld a hole in [src]!")

	else if (istype(W, /obj/item/device/prox_sensor) && src.build_step == 1)
		src.build_step++
		boutput(user, "You add the prox sensor to [src]!")
		src.overlays += image('icons/obj/bots/aibots.dmi', "hs_eye")
		src.name = "helmet/signaler/prox sensor assembly"
		qdel(W)

	else if (istype(W, /obj/item/parts/robot_parts/arm/) && src.build_step == 2)
		src.build_step++
		boutput(user, "You add the robot arm to [src]!")
		src.name = "helmet/signaler/prox sensor/robot arm assembly"
		src.overlays += image('icons/obj/bots/aibots.dmi', "hs_arm")
		user.u_equip(W)
		qdel(W)

	else if (istype(W, /obj/item/baton/) && src.build_step >= 3)
		if (istype(W, /obj/item/baton/beepsky))	// If we used Beepsky's dropped baton
			var/obj/item/baton/Y = W
			if (src.is_dead_beepsky)							// on Beepsky's corpse
				boutput(user, "You return Officer Beepsky his trusty baton, reassembling the Securitron! Beep boop.")
				new /obj/machinery/bot/secbot/beepsky(get_turf(src))
				qdel(src)
				user.u_equip(W)
				qdel(W)
			else												// On any other securitron assembly?
				boutput(user, "You give the [src] [W] and connect a cable in the arm to the baton's parallel port, completing the Securitron! Beep boop.")
				var/obj/machinery/bot/secbot/S = new /obj/machinery/bot/secbot(get_turf(src))
				S.beacon_freq = src.beacon_freq
				S.hat = src.hat
				S.name = src.created_name		// We get an upgraded securitron
				S.attack_per_step = 2				// 25% chance to attack_on_move, as opposed to 75%
				S.loot_baton_type = W.type	// So we can drop it all over again.
				if (Y.beepsky_held_this == 1)
					S.is_beepsky = IS_NOT_BEEPSKY_BUT_HAS_HIS_SPECIAL_BATON	// So we drop Beepsky's baton, and not just some generic secbot one
				else
					S.is_beepsky = IS_NOT_BEEPSKY_BUT_HAS_A_GENERIC_SPECIAL_BATON // So we drop some generic secboton
				qdel(src)
				user.u_equip(W)
				qdel(W)
		else												// If we used any old stun baton
			if (src.is_dead_beepsky)	// On Beepsky's corpse
				boutput(user, "You give Officer Beepsky a stun baton, reassembling the Securitron! Beep boop.")
				var/obj/machinery/bot/secbot/beepsky/S = new /obj/machinery/bot/secbot/beepsky(get_turf(src))
				S.attack_per_step = 0		// We just get a surly head of robosecurity
				S.is_beepsky = IS_BEEPSKY_BUT_HAS_SOME_GENERIC_BATON // So Beepsky's corpse is his corpse
				S.loot_baton_type = W.type	// Our baton isn't special
				qdel(src)
				user.u_equip(W)
				qdel(W)
			else											// On any other securitron assembly?
				boutput(user, "You give the [src] a stun baton, completing the Securitron! Beep boop.")
				var/obj/machinery/bot/secbot/S = new /obj/machinery/bot/secbot(get_turf(src))
				S.beacon_freq = src.beacon_freq
				S.hat = src.hat
				S.name = src.created_name
				S.attack_per_step = 0		// We get a loot pinata
				S.is_beepsky = IS_NOT_BEEPSKY_AND_HAS_SOME_GENERIC_BATON // You're still not Beepsky
				S.loot_baton_type = W.type	// Our baton isn't special either
				qdel(src)
				user.u_equip(W)
				qdel(W)

	else if (istype(W, /obj/item/rods) && src.build_step == 3)
		if (W.amount < 1)
			boutput(user, "You need a non-zero amount of rods. How did you even do that?")
		else
			src.build_step++
			boutput(user, "You add a rod to [src]'s robot arm!")
			src.name = "helmet/signaler/prox sensor/robot arm/rod assembly"
			src.overlays += image('icons/obj/bots/aibots.dmi', "hs_rod")
			W.amount -= 1
			if (W.amount < 1)
				user.u_equip(W)
				qdel(W)

	else if (istype(W, /obj/item/cable_coil) && src.build_step >= 4)
		var/obj/item/cable_coil/C = W
		if (!C.use(5))
			boutput(user, "You need a longer length of cable! A length of five should be enough.")
		else if (src.is_dead_beepsky)	// On Beepsky's corpse
			boutput(user, "You add wires to Officer Beepsky, reassembling the Securitron! Beep boop.")
			var/obj/machinery/bot/secbot/beepsky/S = new /obj/machinery/bot/secbot/beepsky(get_turf(src))
			S.attack_per_step = 0		// We just get a surly head of robosecurity
			S.is_beepsky = IS_BEEPSKY_BUT_HAS_SOME_GENERIC_BATON	// So Beepsky's corpse is his corpse
			S.loot_baton_type = /obj/item/scrap	// our baton's a hunk of junk!
			qdel(src)
		else
			src.build_step++
			boutput(user, "You add the wires to the rod, completing the Securitron! Beep boop.")
			var/obj/machinery/bot/secbot/S = new /obj/machinery/bot/secbot(get_turf(src))
			S.beacon_freq = src.beacon_freq
			S.hat = src.hat
			S.name = src.created_name
			qdel(src)

	else if (istype(W, /obj/item/pen))
		var/t = input(user, "Enter new robot name", src.name, src.created_name) as text
		t = strip_html(replacetext(t, "'",""))
		t = copytext(t, 1, 45)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t

#undef IS_NOT_BEEPSKY_AND_HAS_SOME_GENERIC_BATON
#undef IS_BEEPSKY_AND_HAS_HIS_SPECIAL_BATON
#undef IS_NOT_BEEPSKY_BUT_HAS_HIS_SPECIAL_BATON
#undef IS_BEEPSKY_BUT_HAS_SOME_GENERIC_BATON
#undef IS_NOT_BEEPSKY_BUT_HAS_A_GENERIC_SPECIAL_BATON
