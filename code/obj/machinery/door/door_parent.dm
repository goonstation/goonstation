#define KNOCK_DELAY 1 SECOND

ADMIN_INTERACT_PROCS(/obj/machinery/door, proc/open, proc/close, proc/break_me_complitely)
/obj/machinery/door
	name = "door"
	icon_state = "door1"
	#ifdef UPSCALED_MAP
	opacity = 0
	#else
	opacity = 1
	#endif
	density = 1
	flags = FLUID_DENSE
	event_handler_flags = USE_FLUID_ENTER
	object_flags = BOTS_DIRBLOCK
	pass_unstable = TRUE
	text = "<font color=#D2691E>+"
	var/secondsElectrified = 0
	var/visible = TRUE
	var/panel_open = FALSE
	var/operating = FALSE
	var/operation_time = 1 SECOND
	anchored = ANCHORED
	var/autoclose = FALSE
	var/interrupt_autoclose = FALSE
	var/last_used = 0
	var/cant_emag = FALSE
	var/hardened = FALSE // Can't be hacked, RCD'd or controlled by silicon mobs.
	var/cant_hack = FALSE //Like the above but can be RCD'd and controlled by silicons
	var/locked = FALSE
	var/icon_base = "door"
	var/brainloss_stumble = FALSE // Can a mob stumble into this door if they have enough brain damage? Won't work if you override Bumped() or attackby() and don't check for it separately.
	var/crush_delay = 6 SECONDS
	var/sound_deny = 0
	var/has_crush = TRUE //flagged to true when the door has a secret admirer. also if the var == 1 then the door does have the ability to crush items.
	var/close_trys = 0
	var/autoclose_delay = 15 SECONDS
	var/autoclose_timer = 0

	var/health = 400
	var/health_max = 400
	var/hitsound = 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg'
	var/knocksound = 'sound/impact_sounds/Door_Metal_Knock_1.ogg' //knock knock

	var/next_timeofday_opened = 0 //high tier jank

	var/ignore_light_or_cam_opacity = FALSE

	var/obj/forcefield/energyshield/linked_forcefield = null

	/// Set before calling open() for handling COMSIG_DOOR_OPENED. Can be null. This gets immediately set to null after the signal calls.
	var/atom/movable/bumper = null

/obj/machinery/door/Bumped(atom/AM)
	if (src.operating) return
	if (src.isblocked()) return

	if (ismob(AM))
		if (src.density && src.brainloss_stumble && src.do_brainstumble(AM) == 1)
			return
		else
			var/mob/M = AM
			if (!M.hasStatus("handcuffed"))
				src.bumpopen(M)

	else if (istype(AM, /obj/vehicle))
		var/obj/vehicle/V = AM
		var/mob/M2 = V.rider
		if (!M2 || !ismob(M2))
			return
		if (!M2.hasStatus("handcuffed"))
			src.bumpopen(M2)

	else if (istype(AM, /obj/machinery/vehicle/tank))
		var/obj/machinery/vehicle/tank/T = AM
		var/mob/M = T.pilot
		if (!M) return
		src.bumpopen(M)

	else if (istype(AM, /obj/machinery/bot))
		var/obj/machinery/bot/B = AM
		if (src.check_access(B.botcard) && !B.pulled_by) //no more dragging bots onto doors for makeshift AA
			if (src.density)
				src.open()

	else if (istype(AM, /obj/critter/))
		var/obj/critter/C = AM
		if (C.opensdoors == OBJ_CRITTER_OPENS_DOORS_PUBLIC)
			if (src.density)
				src.bumpopen(AM)
				C.frustration = 0
		else if (C.opensdoors == OBJ_CRITTER_OPENS_DOORS_ANY)
			src.open()
			C.frustration = 0
		else
			C.frustration++

	return

// Simple proc to avoid some duplicate code (Convair880).
/obj/machinery/door/proc/do_brainstumble(var/mob/user)
	if (!src || !user || !ismob(user))
		return 0

	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if (isdead(H)) //No need to call for dead people!
			return 0
		if (H.get_brain_damage() >= BRAIN_DAMAGE_MAJOR)
			// No text spam, please. Bumped() is called more than once by some doors, though.
			// If we just return 0, they will be able to bump-open the door and get past regardless
			// because mob paralysis doesn't take effect until the next tick.
			if (prob(20) && !ON_COOLDOWN(H, "brainstumble_cooldown", 1 SECOND))
				playsound(src, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, TRUE)
				src.visible_message(SPAN_ALERT("<b>[H]</b> stumbles into [src] head-first. [pick("Ouch", "Damn", "Woops")]!"))
				if (!istype(H.head, /obj/item/clothing/head/helmet))
					H.TakeDamageAccountArmor("head", 9, 0, 0, DAMAGE_BLUNT)
					H.changeStatus("knockdown", 1 SECOND)
				else
					boutput(H, SPAN_NOTICE("Your helmet protected you from injury!"))
				return 1
	return 0

/obj/machinery/door/Cross(atom/movable/mover)
	if(istype(mover, /obj/projectile))
		var/obj/projectile/P = mover
		if(P.proj_data.window_pass && !P.proj_data.always_hits_structures)
			return !opacity
	if(density && mover && mover.flags & DOORPASS && !src.cant_emag)
		if (ismob(mover))
			var/mob/M = mover
			if (M.pulling && src.bumpopen(M))
				// If they're pulling something and the door would open anyway,
				// just let the door open instead.
				return 0
			for (var/obj/item/grab/G in M.equipped_list(check_for_magtractor = 0))
				if (G.state >= GRAB_STRONG)
					return 0
		animate_door_squeeze(mover)
		return 1 // they can pass through a closed door

	if (density && next_timeofday_opened)
		return (world.timeofday >= next_timeofday_opened) //Hey this is a really janky fix. Makes it so the door 'opens' on realtime even if the animations and sounds are laggin

	return !density

/obj/machinery/door/gas_cross(turf/target)
	if (density && next_timeofday_opened)
		return (world.timeofday >= next_timeofday_opened) //Hey this is a really janky fix. Makes it so the door 'opens' on realtime even if the animations and sounds are laggin

	return !density

/obj/machinery/door/proc/update_nearby_tiles(need_rebuild)
	var/turf/source = src.loc
	if (istype(source))
		return source.update_nearby_tiles(need_rebuild)

	return 1

/obj/machinery/door/check_access(obj/item/I)
	if (src.density && src.operating == -1) //we are weldmagged or some shit... skip the rest of the ID checks, its not gonna open.
		return 0							//and look i know this appears to be the same as isblocked... DO NOT call isblocked. it is inherited by children and will kill access
	.= ..()

//cannot be opened by bots.
/obj/machinery/door/proc/isblocked()
	.= 0
	if (src.density && src.operating == -1)
		.= 1

/obj/machinery/door/New()
	..()
	UnsubscribeProcess()
	AddComponent(/datum/component/mechanics_holder)
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", PROC_REF(toggleinput))
	AddComponent(/datum/component/bullet_holes, 15, src.hardened ? 999 : 5) // no bullet holes if hardened; wouldn't want to get their hopes up
	src.update_nearby_tiles(need_rebuild=1)
	START_TRACKING
	for (var/turf/simulated/wall/auto/T in orange(1))
		T.UpdateIcon()
	#ifdef XMAS
	if(src.z == Z_LEVEL_STATION && current_state <= GAME_STATE_PREGAME)
		src.xmasify()
	#endif

/obj/machinery/door/disposing()
		src.update_nearby_tiles()
		if(ignore_light_or_cam_opacity)
				ignore_light_or_cam_opacity = FALSE
				src.set_opacity(0)
		STOP_TRACKING
		..()

/obj/machinery/door/proc/xmasify()
	var/obj/decal/garland/garland = new(src.loc)
	if(src.dir != NORTH)
		garland.dir = src.dir

/obj/machinery/door/proc/toggleinput()
	if(src.cant_emag || (src.req_access && !(src.operating == -1)))
		if (src.density) //only play if it's closed
			play_animation("deny")
		return
	if(density)
		open()
	else
		close()
	return

/obj/machinery/door/meteorhit(obj/M as obj)
	if (isrestrictedz(src.z))
		return
	qdel(src)
	return

/obj/machinery/door/attack_ai(mob/user as mob)
	return src.Attackhand(user)

/obj/machinery/door/attack_hand(mob/user)
	interact_particle(user,src)
	return src.Attackby(null, user)

/obj/machinery/door/proc/tear_apart(mob/user as mob)
	if (!src.density)
		return src.Attackby(null, user)

	if (istype(src, /obj/machinery/door/airlock) || istype(src, /obj/machinery/door/window))
		if (src.allowed(user)) // Don't override ID cards.
			return src.Attackby(null, user)

	src.visible_message(SPAN_ALERT("[user] is attempting to pry open [src]."))
	user.show_text("You have to stand still...", "red")

#ifdef HALLOWEEN
	user.emote("scream")
#endif
	SETUP_GENERIC_ACTIONBAR(user, src, 10 SECONDS, /obj/machinery/door/proc/try_force_open, list(user, TRUE), src.icon, src.icon_state, \
	SPAN_ALERT("[user] pries open [src]!"), \
	INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)


/obj/machinery/door/proc/try_force_open(mob/user as mob, var/break_door = FALSE)
	var/success = 0
	if (src)
		if (istype(src, /obj/machinery/door/poddoor))
			boutput(user, SPAN_ALERT("The door is too strong for you!"))

		if (istype(src, /obj/machinery/door/unpowered/wood))
			var/obj/machinery/door/unpowered/wood/WD = src
			if (WD.locked)
				boutput(user, SPAN_ALERT("It's shut tight!"))
			else
				WD.open()
				success = 1

		if (istype(src, /obj/machinery/door/firedoor))
			var/obj/machinery/door/firedoor/FD = src
			if (FD.blocked)
				boutput(user, SPAN_ALERT("It's shut tight!"))
			else
				FD.open()
				success = 1

		if (istype(src, /obj/machinery/door/window))
			var/obj/machinery/door/window/SD = src
			if (SD.cant_emag != 0 || SD.isblocked() != 0)
				boutput(user, SPAN_ALERT("It's shut tight!"))
			else
				SD.open()
				success = 1

		if (istype(src, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/AL = src
			if (AL.locked || AL.operating == -1 || AL.welded || AL.cant_emag != 0)
				boutput(user, SPAN_ALERT("It's shut tight!"))
			else
				if (!AL.arePowerSystemsOn() || (AL.status & NOPOWER))
					AL.unpowered_open_close()
				else
					AL.open()
				success = 1
	if(success && break_door)
		src.operating = -1
	return success

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (src.density && src.cant_emag <= 0)
		last_used = world.time
		src.operating = -1
		FLICK(text("[]_spark", src.icon_base), src)
		SPAWN(0.6 SECONDS)
			open()
		return TRUE
	return FALSE

/obj/machinery/door/demag(var/mob/user)
	if (src.operating != -1)
		return 0
	src.operating = 0
	SPAWN(0.6 SECONDS)
		close()
	return 1

/obj/machinery/door/attackby(obj/item/I, mob/user)
	if (user.getStatusDuration("stunned") || user.getStatusDuration("knockdown") || user.stat || user.restrained())
		return
	if(istype(I, /obj/item/grab))
		return ..() // handled in grab.dm + Bumped

	if (src.isblocked() == 1)
		if (src.density && src.operating != 1 && I)
			if (I.tool_flags & TOOL_CHOPPING)
				src.take_damage(I.force*4, user)
			else
				src.take_damage(I.force, user)
			user.lastattacked = get_weakref(src)
			attack_particle(user,src)
			playsound(src, src.hitsound , 50, 1, pitch = 1.6)
			..()

		return
	if (src.operating)
		return
	if (world.time - src.last_used <= 10)
		return

	src.add_fingerprint(user)

	if (src.density && src.brainloss_stumble && src.do_brainstumble(user) == 1)
		return

	if (!src.requiresID())
		if (src.density)
			src.last_used = world.time
			src.open()
		else
			src.last_used = world.time
			src.close()
		return

	if(istype(I, /obj/item/card/emag) && !src.cant_emag)
		return

	if (src.allowed(user))
		if (src.density)
			src.last_used = world.time
			src.open()
		else
			src.last_used = world.time
			src.close()
		return

	else if (src.density && !ON_COOLDOWN(src, "deny_sound", 1 SECOND)) // stop the sound from spamming, if there is one
		play_animation("deny")
		if (src.sound_deny)
			playsound(src, src.sound_deny, 25, 0)

	if (src.density && !src.operating && I?.force > 5)
		var/resolvedForce = I.force
		if (I.tool_flags & TOOL_CHOPPING)
			resolvedForce *= 4
		user.lastattacked = get_weakref(src)
		attack_particle(user,src)
		playsound(src, src.hitsound , 50, 1, pitch = 1.6)
		src.take_damage(resolvedForce, user)
		return ..(I,user) // only call parent if force > 5; no material hit or attack message otherwise

/obj/machinery/door/proc/bumpopen(atom/movable/AM)
	if (src.operating)
		return 0
	if(world.time-last_used <= 10)
		return 0
	src.add_fingerprint(AM)

	if (!src.requiresID() || src.allowed(AM))
		if (src.density)
			last_used = world.time
			src.bumper = AM
			if (src.open() == 1)
				return 1
			else
				return 0
	else if (src.density && !ON_COOLDOWN(src, "deny_sound", 1 SECOND))
		play_animation("deny")
		if (src.sound_deny)
			playsound(src, src.sound_deny, 25, 0)
		return 0

// we have to do these explicitly to bypass checks for smashing handcuffed people into doors
/obj/machinery/door/grab_smash(obj/item/grab/G, mob/user)
	var/mob/grabbee = G.affecting
	if (..())
		if (src.density)
			src.bumpopen(grabbee)

/obj/machinery/door/hitby(atom/movable/AM, datum/thrown_thing/thr)
	. = ..()
	if (src.density && ismob(AM))
		src.bumpopen(AM)

/obj/machinery/door/blob_act(var/power)
	if(prob(power))
		qdel(src)

/obj/machinery/door/ex_act(severity)
	if (isrestrictedz(src.z))
		return
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(66))
				qdel(src)
			else
				take_damage(health_max/2)
		if(3)
			if(prob(80))
				elecflash(src,power=2)
			take_damage(health_max/6)

/obj/machinery/door/proc/break_me_complitely()
	set waitfor = 0
	robogibs(src.loc)
	qdel(src)

/obj/machinery/door/proc/heal_damage()
	src.health = src.health_max

/obj/machinery/door/proc/take_damage(var/amount, var/mob/user = 0)
	if (!isnum(amount) || amount <= 0)
		return
	if (src.cant_emag)
		return

	var/armor = 0

	if (src.material)
		if (src.material.getProperty("density") >= 3)
			armor += round(src.material.getProperty("density"))
		else
			amount += rand(1,3)

	amount = get_damage_after_percentage_based_armor_reduction(armor,amount)

	src.health = clamp(src.health - amount, 0, src.health_max)

	if (src.health <= 0)
		break_me_complitely()
	else
		if(prob(30))
			elecflash(src,power=2)

		if (user && src.health <= health_max * 0.55 && istype(src, /obj/machinery/door/airlock) )
			var/obj/machinery/door/airlock/A = src
			A.shock(user, 3)
			elecflash(src,power=2)

		if (prob(2) && src.health <= health_max * 0.35 && istype(src, /obj/machinery/door/airlock) )
			SPAWN(0)
				src.open()


/obj/machinery/door/bullet_act(var/obj/projectile/P)
	var/damage = 0
	if (!P || !istype(P.proj_data,/datum/projectile/))
		return
	damage = round((P.power*P.proj_data.ks_ratio), 1.0)
	if (damage < 1)
		return

	src.material_trigger_on_bullet(src, P)

	switch(P.proj_data.damage_type)
		if(D_KINETIC)
			take_damage(round(damage * 1.5))
		if(D_PIERCING)
			take_damage(damage * 2)
		if(D_ENERGY)
			take_damage(damage)
		if(D_BURNING)
			take_damage(damage/2)
	return

/obj/machinery/door/update_icon(var/toggling = 0)
	if(toggling? !density : density)
		icon_state = "[icon_base]1"
	else
		icon_state = "[icon_base]0"
	return

/obj/machinery/door/proc/play_animation(animation)
	switch(animation)
		if("opening")
			if(src.panel_open)
				FLICK("o_[icon_base]c0", src)
			else
				FLICK("[icon_base]c0", src)
			icon_state = "[icon_base]0"
		if("closing")
			if(src.panel_open)
				FLICK("o_[icon_base]c1", src)
			else
				FLICK("[icon_base]c1", src)
			icon_state = "[icon_base]1"
		if("deny")
			FLICK("[icon_base]_deny", src)
	return

/obj/machinery/door/proc/open()
	if(!density)
		return 1
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	if (src.linked_forcefield && (src.powered() || !src.linked_forcefield.powered_locally))
		src.linked_forcefield.setactive(TRUE)
		if(src.linked_forcefield.powered_locally)
			SubscribeToProcess()

	SPAWN(-1)
		play_animation("opening")
		next_timeofday_opened = world.timeofday + (src.operation_time)
		SPAWN(-1)
			src.set_opacity(0)
		sleep(src.operation_time / 2)
		src.set_density(0)
		src.UpdateIcon(/*/toggling*/ 0)
		src.update_nearby_tiles()
		next_timeofday_opened = 0
		sleep(src.operation_time / 2)
		SEND_SIGNAL(src, COMSIG_DOOR_OPENED, src.bumper)
		src.bumper = null
		if(!(src.status & NOPOWER))
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"doorOpened")

		if(operating == 1) //emag again
			src.operating = 0
		opened()

		next_timeofday_opened = 0

	return 1

/obj/machinery/door/proc/close(var/unsafe = 0)
	if(density)
		return 1

	if (src.operating)
		return

	if(!unsafe && has_crush) //Make sure we're free from rubbish
		if(close_trys <= 0 || !prob(min(close_trys * 0.1, 7))) //close trys probability increases each time... makes doors overall less dangerous for crew but easier for the AI to fuck u by mashing
			var/max = 50
			for(var/atom/movable/A in get_turf(src))
				if (istype(A,/obj/fluid) || istype(A,/obj/machinery/door) || istype(A, /obj/forcefield/energyshield)) continue //don't let some dumb puddle prevent us from closing!
				else if((isliving(A) && !isintangible(A)) || A.density) //Too big, let us not crush this
					close_trys += 1
					return 1

				if (--max <= 0) break

	if (src.linked_forcefield?.isactive)
		src.linked_forcefield.setactive(FALSE)
		if(src.linked_forcefield.powered_locally)
			UnsubscribeProcess()

	src.operating = 1
	close_trys = 0
	SPAWN(-1)
		src.play_animation("closing")
		src.UpdateIcon(1)
		src.set_density(1)
		src.update_nearby_tiles()

		var/did_crush = 0
		if (has_crush)
			// We don't care watever is inside the airlock when we close the airlock if we are unsafe, crush em.
			//Maybe moving this until just after the animation looks better.
			for(var/mob/living/L in get_turf(src))
				if(isintangible(L))
					continue
				var/mob_layer = L.layer	//Make it look like we're inside the door
				L.layer = src.layer - 0.01
				if(!ON_COOLDOWN(L, "doorcrush", 0.5 SECONDS))
					playsound(src, 'sound/impact_sounds/Flesh_Break_1.ogg', 100, TRUE)
					L.emote("scream")

					L.TakeDamageAccountArmor("All", rand(20, 50), 0, 0, DAMAGE_CRUSH)

					L.changeStatus("knockdown", 3 SECONDS)
					logTheThing(LOG_COMBAT, L, "gets horribly crushed in a door at [log_loc(L)]")
				L.stuttering += 10
				did_crush = 1
				SPAWN(src.operation_time * 1.5 + crush_delay)
					if (L) L.layer = mob_layer //Restore the mob's layer. Might be jarring...?

		sleep(src.operation_time)

		if(src.visible)
			src.set_opacity(1)

		src.closed()

		if(did_crush)
			interrupt_autoclose = 1
			src.visible_message(SPAN_ALERT("\The [src] whirrs [pick_string("descriptors.txt", "borg_shake")]!"))
			playsound(src, 'sound/machines/hydraulic.ogg', 30,TRUE)
			sleep(crush_delay) //If we crushed someone, wait a bit until resuming operations to prevent chaincrushing
			src.operating = 0
			src.open()

		else if(src.operating)
			src.operating = 0

/obj/machinery/door/proc/opened()
	if(!autoclose)
		return

	// Create a local copy of the autoclose timer to detect changes if it has changed outside this proc
	src.autoclose_timer = TIME
	var/lcl_autoclose = src.autoclose_timer

	while(autoclose && !density && !QDELETED(src))
		sleep(src.autoclose_delay)

		if(lcl_autoclose != src.autoclose_timer) //newer open command received,  don't autoclose
			break

		if(interrupt_autoclose)
			interrupt_autoclose = 0
		else
			autoclose()

/obj/machinery/door/proc/closed()
	if(!(src.status & NOPOWER))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"doorClosed")

/obj/machinery/door/proc/autoclose()
	if (!density && !operating && !locked)
		close()
	else return

/// toggles the lock state of the door
/obj/machinery/door/proc/toggle_locked()
	if (locked)
		set_unlocked()
	else
		set_locked()

/// locks the door, aka bolt / key lock
/obj/machinery/door/proc/set_locked()
	src.locked = TRUE
	src.UpdateIcon()

/// unlocks the door, aka unbolt / un-key lock
/obj/machinery/door/proc/set_unlocked()
	src.locked = FALSE
	src.UpdateIcon()

/obj/machinery/door/power_change()
	. = ..()
	if (src.linked_forcefield)
		if (src.linked_forcefield.isactive && !powered() && src.linked_forcefield.powered_locally)
			//forcefield active, we don't have local power, field isn't from a generator? deactivate, and door is no longer using field power
			src.linked_forcefield.setactive(FALSE)
			UnsubscribeProcess()
			src.update_nearby_tiles()
		else if(!src.linked_forcefield.isactive && !density && (powered() || !src.linked_forcefield.powered_locally))
			//forcefield inactive - if we have local power, or field is from a generator, bring it online if our airlock's open
			src.linked_forcefield.setactive(TRUE)
			//and only start using power if door is providing field power
			if(src.linked_forcefield.powered_locally)
				SubscribeToProcess()

/obj/machinery/door/proc/knockOnDoor(mob/user)
	if(!ON_COOLDOWN(user, "knocking_cooldown", KNOCK_DELAY)) //slow the fuck down cowboy
		attack_particle(user,src)
		playsound(src, src.knocksound, 100, 1) //knock knock

/obj/machinery/door/proc/checkForMultipleDoors()
	if(!src.loc)
		return 0
	for(var/obj/machinery/door/D in src.loc)
		if(!istype(D, /obj/machinery/door/window) && D.density)
			return 0
	return 1

/obj/machinery/door/set_opacity(newopacity)
	if(ignore_light_or_cam_opacity)
		src.opacity = newopacity
	else
		. = ..()

/turf/simulated/wall/proc/checkForMultipleDoors()
	if(!src.loc)
		return 0
	for(var/obj/machinery/door/D in locate(src.x,src.y,src.z))
		if(!istype(D, /obj/machinery/door/window) && D.density)
			return 0
	//There are no false wall checks because that would be fucking idiotic
	return 1

//You could never suicide in all doors, just firelocks. Suicide moved to firedoor.dm -ZeWaka

/////////////////////////////////////////////////// Unpowered doors

/obj/machinery/door/unpowered
	autoclose = FALSE
	cant_emag = TRUE

/obj/machinery/door/unpowered/attack_ai(mob/user as mob)
	return

/obj/machinery/door/unpowered/attack_hand(mob/user)
	return src.Attackby(null, user)

/obj/machinery/door/unpowered/attackby(obj/item/I, mob/user)
	if (src.operating || isintangible(user) || isdead(user))
		return
	src.add_fingerprint(user)
	if (src.allowed(user))
		if (src.density)
			src.bumper = user
			open()
		else
			close()
	return

/obj/machinery/door/unpowered/shuttle
	icon = 'icons/obj/doors/shuttle.dmi';
	name = "door"
	icon_state = "door1"
	#ifdef UPSCALED_MAP
	opacity = 0
	#else
	opacity = 1
	#endif
	density = 1

/obj/machinery/door/unpowered/martian
	icon = 'icons/turf/martian.dmi'
	name = "Orifice"
	icon_state = "door1"
	#ifdef UPSCALED_MAP
	opacity = 0
	#else
	opacity = 1
	#endif
	density = 1
	var/id = null

/obj/machinery/door/unpowered/martian/open()
	if(src.locked) return
	playsound(src, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, TRUE)
	. = ..()

/obj/machinery/door/unpowered/martian/close()
	playsound(src, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, TRUE)
	. = ..()

// APRIL FOOLS
TYPEINFO(/obj/machinery/door/unpowered/wood)
	mat_appearances_to_ignore = list("wood")
/obj/machinery/door/unpowered/wood
	name = "door"
	icon = 'icons/obj/doors/door_wood.dmi'
	icon_state = "door1"
	#ifdef UPSCALED_MAP
	opacity = 0
	#else
	opacity = 1
	#endif
	density = 1
	panel_open = 0
	operating = 0
	layer = EFFECTS_LAYER_UNDER_1
	anchored = ANCHORED
	autoclose = TRUE
	material_amt = 0.3
	var/blocked = null
	var/simple_lock = 0
	var/lock_dir = null // what direction you can lock/unlock the door from

/obj/machinery/door/unpowered/wood/New()
	..()
	if (!src.simple_lock)
		src.verbs -= /obj/machinery/door/unpowered/wood/verb/simple_lock
	if (istype(get_area(src), /area/centcom/offices))
		var/area/centcom/offices/O = get_area(src)
		if (O.icon_state == "blue")
			src.locked = TRUE

/obj/machinery/door/unpowered/wood/pyro
	icon = 'icons/obj/doors/SL_doors.dmi'
	icon_state = "wood1"
	icon_base = "wood"
	material_amt = 0.6

/obj/machinery/door/unpowered/wood/stall
	name = "stall door"
	icon = 'icons/obj/doors/door_stall.dmi'
	simple_lock = 1

/obj/machinery/door/unpowered/wood/isblocked()
	if (src.density && (src.operating == -1 || src.locked))
		return 1
	return 0

/obj/machinery/door/unpowered/wood/get_desc()
	. = ..()
	. += " It's [!src.locked ? "un" : null]locked."

/obj/machinery/door/unpowered/wood/attackby(obj/item/I, mob/user)
	if (I) // eh, this'll work well enough.
		src.material_trigger_when_attacked(I, user, 1)
	if (src.operating)
		return
	src.add_fingerprint(user)
	if (!src.requiresID())
		//don't care who they are or what they have, act as if they're NOTHING
		user = null
	if(istype(I, /obj/item/device/key) && src.density)
		if (src.simple_lock)
			boutput(user, SPAN_ALERT("You can't find a keyhole on this [src.name], it just has a little latch."))
			return
		else if (src.lock_dir)
			var/checkdir = get_dir(src, user)
			if (!(checkdir & src.lock_dir))
				boutput(user, SPAN_ALERT("[src]'s keyhole isn't on this side!"))
				return
		src.toggle_locked()
		src.visible_message(SPAN_NOTICE("<B>[user] [!src.locked ? "un" : null]locks [src].</B>"))
		return
	else if (isscrewingtool(I) && src.locked)
		actions.start(new /datum/action/bar/icon/door_lockpick(src, I, src.simple_lock ? 40 : 80), user)
		return
	if (user.is_hulk())
		src.visible_message(SPAN_ALERT("<B>[user] smashes through the door!</B>"))
		playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, TRUE)
		src.operating = -1
		src.set_unlocked()
		open()
		return 1
	if (!src.locked)
		if (src.density)
			open()
		else
			close()
	else if (src.density)
		play_animation("deny")
		playsound(src, 'sound/machines/door_locked.ogg', 50, TRUE, -2)
		boutput(user, SPAN_ALERT("The door is locked!"))
	return

/obj/machinery/door/unpowered/wood/open()
	if(src.locked) return
	playsound(src, 'sound/machines/door_open.ogg', 50, TRUE)
	. = ..()

/obj/machinery/door/unpowered/wood/close()
	playsound(src, 'sound/machines/door_close.ogg', 50, TRUE)
	. = ..()

/obj/machinery/door/unpowered/wood/verb/simple_lock()
	set name = "Lock Door"
	set category = "Local"
	set src in oview(1)

	if (isdead(usr) || isintangible(usr))
		return
	if (!src.density || src.operating)
		boutput(usr, SPAN_ALERT("You COULD flip the lock on [src] while it's open, but it wouldn't actually accomplish anything!"))
		return
	if (src.lock_dir)
		var/checkdir = get_dir(src, usr)
		if (!(checkdir & src.lock_dir))
			boutput(usr, SPAN_ALERT("[src]'s lock isn't on this side!"))
			return
	src.toggle_locked()
	src.visible_message(SPAN_NOTICE("<B>[usr] [!src.locked ? "un" : null]locks [src].</B>"))
	return

/datum/action/bar/icon/door_lockpick
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 8 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/machinery/door/unpowered/wood/the_door
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			src.the_door = O
		if (tool)
			src.the_tool = tool
			src.icon = src.the_tool.icon
			src.icon_state = src.the_tool.icon_state
		if (duration_i)
			src.duration = duration_i

	onUpdate()
		..()
		if (src.the_door == null || src.the_tool == null || owner == null || BOUNDS_DIST(owner, src.the_door) > 0 || !src.the_door.locked || src.the_door.operating)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && src.the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return
		if (prob(5) || (!the_door.simple_lock && prob(5)))
			owner.visible_message(SPAN_ALERT("[owner] messes up while picking [src.the_door]'s lock!"))
			playsound(the_door, 'sound/items/Screwdriver2.ogg', 50, TRUE)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		owner.visible_message(SPAN_ALERT("[owner] begins picking [src.the_door]'s lock!"))
		playsound(src.the_door, 'sound/items/Screwdriver2.ogg', 50, 1)

	onEnd()
		..()
		src.the_door.set_unlocked()
		owner.visible_message(SPAN_ALERT("[owner] jimmies [src.the_door]'s lock open!"))
		playsound(src.the_door, 'sound/items/Screwdriver2.ogg', 50, 1)

/obj/machinery/door/control/oneshot
	var/broken = 0

#undef KNOCK_DELAY
