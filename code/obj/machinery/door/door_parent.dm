#define KNOCK_DELAY 10

/obj/machinery/door
	name = "door"
	icon_state = "door1"
	opacity = 1
	density = 1
	flags = FPRINT | ALWAYS_SOLID_FLUID
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS
	object_flags = BOTS_DIRBLOCK
	text = "<font color=#D2691E>+"
	var/secondsElectrified = 0
	var/visible = 1
	var/p_open = 0
	var/operating = 0
	var/operation_time = 10
	anchored = 1
	var/autoclose = 0
	var/interrupt_autoclose = 0
	var/last_used = 0
	var/cant_emag = 0
	var/hardened = 0 // Can't be hacked, RCD'd or controlled by silicon mobs.
	var/locked = 0
	var/next_deny = 0
	var/icon_base = "door"
	var/brainloss_stumble = 0 // Can a mob stumble into this door if they have enough brain damage? Won't work if you override Bumped() or attackby() and don't check for it separately.
	var/brainloss_nospam = 1 // In relation to world time.
	var/crush_delay = 60
	var/sound_deny = 0
	var/has_crush = 1 //flagged to true when the door has a secret admirer. also if the var == 1 then the door doesn't have the ability to crush items.
	var/close_trys = 0

	var/health = 600
	var/health_max = 600
	var/hitsound = "sound/impact_sounds/Generic_Hit_Heavy_1.ogg"
	var/knocksound = 'sound/impact_sounds/Door_Metal_Knock_1.ogg' //knock knock

	var/next_timeofday_opened = 0 //high tier jank

	var/ignore_light_or_cam_opacity = 0

/obj/machinery/door/Bumped(atom/AM)
	if (src.p_open || src.operating) return
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
		if (src.check_access(B.botcard))
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
		var/mob/living/carbon/human/C = user
		if (isdead(C)) //No need to call for dead people!
			return 0
		if (C.get_brain_damage() >= 60)
			// No text spam, please. Bumped() is called more than once by some doors, though.
			// If we just return 0, they will be able to bump-open the door and get past regardless
			// because mob paralysis doesn't take effect until the next tick.
			if (src.brainloss_nospam && world.time < src.brainloss_nospam + 10)
				return 1

			if (prob(20))
				playsound(src.loc, "sound/impact_sounds/Metal_Clang_3.ogg", 50, 1)
				src.visible_message("<span class='alert'><b>[C]</b> stumbles into [src] head-first. [pick("Ouch", "Damn", "Woops")]!</span>")
				if (!istype(C.head, /obj/item/clothing/head/helmet))
					var/obj/item/affecting = C.organs["head"]
					if (affecting)
						affecting.take_damage(9, 0)
						C.UpdateDamageIcon()
					C.changeStatus("weakened", 1 SECOND)
				else
					boutput(C, "<span class='notice'>Your helmet protected you from injury!</span>")

				src.brainloss_nospam = world.time
				return 1
	return 0

/obj/machinery/door/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	//if(air_group) return 0
	if(istype(mover, /obj/projectile))
		var/obj/projectile/P = mover
		if(P.proj_data.window_pass)
			return !opacity
	if(density && mover && mover.flags & DOORPASS && !src.cant_emag)
		if (ismob(mover) && mover:pulling && src.bumpopen(mover))
			// If they're pulling something and the door would open anyway,
			// just let the door open instead.
			return 0
		animate_door_squeeze(mover)
		return 1 // they can pass through a closed door

	if (density && next_timeofday_opened)
		return (world.timeofday >= next_timeofday_opened) //Hey this is a really janky fix. Makes it so the door 'opens' on realtime even if the animations and sounds are laggin

	return !density

/obj/machinery/door/proc/update_nearby_tiles(need_rebuild)
	var/turf/simulated/source = loc
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

/obj/machinery/door
	New()
		..()
		UnsubscribeProcess()
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", "toggleinput")
		update_nearby_tiles(need_rebuild=1)
		START_TRACKING
		for (var/turf/simulated/wall/auto/T in orange(1))
			T.update_icon()

	disposing()
		update_nearby_tiles()
		STOP_TRACKING
		..()

	proc/toggleinput()
		if(src.req_access && !(src.operating == -1))
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
	return src.attack_hand(user)

/obj/machinery/door/attack_hand(mob/user as mob)
	interact_particle(user,src)
	return src.attackby(null, user)

/obj/machinery/door/proc/tear_apart(mob/user as mob)
	if (!src.density)
		return src.attackby(null, user)

	if (istype(src, /obj/machinery/door/airlock) || istype(src, /obj/machinery/door/window))
		if (src.allowed(user)) // Don't override ID cards.
			return src.attackby(null, user)

	src.visible_message("<span class='alert'>[user] is attempting to pry open [src].</span>")
	user.show_text("You have to stand still...", "red")

	if (do_after(user, 100) && !(user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || user.getStatusDuration("paralysis") > 0 || !isalive(user) || user.restrained()))
		var/success = 0
		SPAWN_DBG (6)
			success = try_force_open(user)
			if (success != 0)
				src.operating = -1 // It's broken now.
				src.visible_message("<span class='alert'>[user] pries open [src]!</span>")
	else
		user.show_text("You were interrupted.", "red")

	return

/obj/machinery/door/proc/try_force_open(mob/user as mob)
	var/success = 0
	if (src)
		if (istype(src, /obj/machinery/door/poddoor))
			boutput(user, "<span class='alert'>The door is too strong for you!</span>")

		if (istype(src, /obj/machinery/door/unpowered/wood))
			var/obj/machinery/door/unpowered/wood/WD = src
			if (WD.locked)
				boutput(user, "<span class='alert'>It's shut tight!</span>")
			else
				WD.open()
				success = 1

		if (istype(src, /obj/machinery/door/firedoor))
			var/obj/machinery/door/firedoor/FD = src
			if (FD.blocked)
				boutput(user, "<span class='alert'>It's shut tight!</span>")
			else
				FD.open()
				success = 1

		if (istype(src, /obj/machinery/door/window))
			var/obj/machinery/door/window/SD = src
			if (SD.cant_emag != 0 || SD.isblocked() != 0)
				boutput(user, "<span class='alert'>It's shut tight!</span>")
			else
				SD.open(1)
				success = 1

		if (istype(src, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/AL = src
			if (AL.locked || AL.operating == -1 || AL.welded || AL.cant_emag != 0)
				boutput(user, "<span class='alert'>It's shut tight!</span>")
			else
				if (!AL.arePowerSystemsOn() || (AL.status & NOPOWER))
					AL.unpowered_open_close()
				else
					AL.open()
				success = 1

	return success

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (src.density && cant_emag <= 0)
		last_used = world.time
		src.operating = -1
		flick(text("[]_spark", src.icon_base), src)
		sleep(0.6 SECONDS)
		open()
		return 1
	return 0

/obj/machinery/door/demag(var/mob/user)
	if (src.operating != -1)
		return 0
	src.operating = 0
	sleep(0.6 SECONDS)
	close()
	return 1

/obj/machinery/door/attackby(obj/item/I as obj, mob/user as mob)
	if (user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || user.stat || user.restrained())
		return
	if(istype(I, /obj/item/grab))
		return ..() // handled in grab.dm + Bumped

	if (src.isblocked() == 1)
		if (src.density && !src.operating && I)
			user.lastattacked = src
			attack_particle(user,src)
			playsound(src.loc, src.hitsound , 50, 1, pitch = 1.6)
			src.take_damage(I.force, user)
			if (I.tool_flags & TOOL_CHOPPING)
				user.lastattacked = src
				attack_particle(user,src)
				playsound(src.loc, src.hitsound , 50, 1, pitch = 1.6)
				src.take_damage(I.force*4, user)

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

	if (src.allowed(user))
		if (src.density)
			src.last_used = world.time
			src.open()
		else
			src.last_used = world.time
			src.close()
	else if (src.density && world.time >= src.next_deny)
		play_animation("deny")
		src.next_deny = world.time + 10 // stop the sound from spamming, if there is one
		if (src.sound_deny)
			playsound(src.loc, src.sound_deny, 25, 0)

	if (src.density && !src.operating && I)
		user.lastattacked = src
		attack_particle(user,src)
		playsound(src.loc, src.hitsound , 50, 1, pitch = 1.6)
		src.take_damage(I.force, user)
/*
		var/resolvedForce = I.force
		if (I.tool_flags & TOOL_CHOPPING)
			resolvedForce *= 4
*/

		var/resolvedForce = I.force
		if (I.tool_flags & TOOL_CHOPPING)
			resolvedForce *= 4
			user.lastattacked = src
			attack_particle(user,src)
			playsound(src.loc, src.hitsound , 50, 1, pitch = 1.6)
			src.take_damage(resolvedForce, user)


	return ..(I,user)

/obj/machinery/door/proc/bumpopen(atom/movable/AM as mob|obj)
	if (src.operating)
		return 0
	if(world.time-last_used <= 10)
		return 0
	src.add_fingerprint(AM)
	if (!src.requiresID())
		AM = null

	if (src.allowed(AM))
		if (src.density)
			last_used = world.time
			if (src.open() == 1)
				return 1
			else
				return 0
	else if (src.density && world.time > src.next_deny)
		play_animation("deny")
		src.next_deny = world.time + 10
		if (src.sound_deny)
			playsound(src.loc, src.sound_deny, 25, 0)
		return 0

/obj/machinery/door/blob_act(var/power)
	if(prob(power))
		qdel(src)

/obj/machinery/door/ex_act(severity)
	if (isrestrictedz(src.z))
		return
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(25))
				qdel(src)
			else
				take_damage(health_max/2)
		if(3.0)
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
		if (src.material.getProperty("density") >= 10)
			armor += round(src.material.getProperty("density") / 10)
		else if (src.material.hasProperty("density") && src.material.getProperty("density") < 10)
			amount += rand(1,3)

	amount = get_damage_after_percentage_based_armor_reduction(armor,amount)

	src.health = max(0,min(src.health - amount,src.health_max))

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
			SPAWN_DBG(0)
				src.open()


/obj/machinery/door/bullet_act(var/obj/projectile/P)
	var/damage = 0
	if (!P || !istype(P.proj_data,/datum/projectile/))
		return
	damage = round((P.power*P.proj_data.ks_ratio), 1.0)
	if (damage < 1)
		return

	if(src.material) src.material.triggerOnBullet(src, src, P)

	switch(P.proj_data.damage_type)
		if(D_KINETIC)
			take_damage(damage * 3)
		if(D_PIERCING)
			take_damage(damage * 4)
		if(D_ENERGY)
			take_damage(damage * 2)
		if(D_BURNING)
			take_damage(damage)
		if(D_RADIOACTIVE)
			take_damage(damage/2)
	return

/obj/machinery/door/proc/update_icon(var/toggling = 0)
	if(toggling? !density : density)
		icon_state = "[icon_base]1"
	else
		icon_state = "[icon_base]0"
	return

/obj/machinery/door/proc/play_animation(animation)
	switch(animation)
		if("opening")
			if(p_open)
				flick("o_[icon_base]c0", src)
			else
				flick("[icon_base]c0", src)
			icon_state = "[icon_base]0"
		if("closing")
			if(p_open)
				flick("o_[icon_base]c1", src)
			else
				flick("[icon_base]c1", src)
			icon_state = "[icon_base]1"
		if("deny")
			flick("[icon_base]_deny", src)
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
	if (linked_forcefield)
		linked_forcefield.setactive(1)

	SPAWN_DBG(-1)
		play_animation("opening")
		next_timeofday_opened = world.timeofday + (src.operation_time)
		SPAWN_DBG(-1)
			if (ignore_light_or_cam_opacity)
				src.opacity = 0
			else
				src.RL_SetOpacity(0)
		use_power(100)
		sleep(src.operation_time / 2)
		src.set_density(0)
		update_icon(0)
		update_nearby_tiles()
		next_timeofday_opened = 0
		sleep(src.operation_time / 2)
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
				else if(isliving(A) || A.density) //Too big, let us not crush this
					close_trys += 1
					return 1

				if (--max <= 0) break

	if (linked_forcefield)
		linked_forcefield.setactive(0)

	src.operating = 1
	close_trys = 0
	SPAWN_DBG(-1)
		src.play_animation("closing")
		src.update_icon(1)
		src.set_density(1)
		src.update_nearby_tiles()

		var/did_crush = 0
		if (has_crush)
			// We don't care watever is inside the airlock when we close the airlock if we are unsafe, crush em.
			//Maybe moving this until just after the animation looks better.
			for(var/mob/living/L in get_turf(src))
				var/mob_layer = L.layer	//Make it look like we're inside the door
				L.layer = src.layer - 0.01
				playsound(get_turf(src), 'sound/impact_sounds/Flesh_Break_1.ogg', 100, 1)
				L.emote("scream")

				L.TakeDamageAccountArmor("All", rand(20, 50), 0, 0, DAMAGE_CRUSH)

				L.changeStatus("weakened", 3 SECONDS)
				L.stuttering += 10
				did_crush = 1
				SPAWN_DBG(src.operation_time * 1.5 + crush_delay)
					if (L) L.layer = mob_layer //Restore the mob's layer. Might be jarring...?

		sleep(src.operation_time)

		if(src.visible)
			if (ignore_light_or_cam_opacity)
				src.opacity = 1
			else
				src.RL_SetOpacity(1)

		src.closed()

		if(did_crush)
			interrupt_autoclose = 1
			src.visible_message("<span class='alert'>\The [src] whirrs [pick_string("descriptors.txt", "borg_shake")]!</span>")
			playsound(src.loc, 'sound/machines/hydraulic.ogg', 30,1)
			sleep(crush_delay) //If we crushed someone, wait a bit until resuming operations to prevent chaincrushing
			src.operating = 0
			src.open()

		else if(src.operating)
			src.operating = 0

/obj/machinery/door/proc/opened()
	if(autoclose)
		sleep(15 SECONDS)
		if(interrupt_autoclose)
			interrupt_autoclose = 0
		else
			autoclose()

/obj/machinery/door/proc/closed()
	SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"doorClosed")

/obj/machinery/door/proc/autoclose()
	if (!density && !operating && !locked)
		close()
	else return

/obj/machinery/door/proc/knockOnDoor(mob/user)
	if(world.time >= user.last_door_knock_time) //slow the fuck down cowboy
		user.last_door_knock_time = world.time + KNOCK_DELAY
		attack_particle(user,src)
		playsound(src.loc, src.knocksound, 100, 1) //knock knock

/obj/machinery/door/proc/checkForMultipleDoors()
	if(!src.loc)
		return 0
	for(var/obj/machinery/door/D in src.loc)
		if(!istype(D, /obj/machinery/door/window) && D.density)
			return 0
	return 1

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
	autoclose = 0
	cant_emag = 1

/obj/machinery/door/unpowered/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/unpowered/attack_hand(mob/user as mob)
	return src.attackby(null, user)

/obj/machinery/door/unpowered/attackby(obj/item/I as obj, mob/user as mob)
	if (src.operating)
		return
	src.add_fingerprint(user)
	if (src.allowed(user))
		if (src.density)
			open()
		else
			close()
	return

/obj/machinery/door/unpowered/shuttle
	icon = 'icons/turf/shuttle.dmi'
	name = "door"
	icon_state = "door1"
	opacity = 1
	density = 1

/obj/machinery/door/unpowered/martian
	icon = 'icons/turf/martian.dmi'
	name = "Orifice"
	icon_state = "door1"
	opacity = 1
	density = 1
	var/id = null

/obj/machinery/door/unpowered/martian/open()
	if(src.locked) return
	playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
	. = ..()

/obj/machinery/door/unpowered/martian/close()
	playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
	. = ..()

// APRIL FOOLS
/obj/machinery/door/unpowered/wood
	name = "door"
	icon = 'icons/obj/doors/door_wood.dmi'
	icon_state = "door1"
	opacity = 1
	density = 1
	p_open = 0
	operating = 0
	anchored = 1
	autoclose = 1
	var/blocked = null
	var/simple_lock = 0
	var/lock_dir = null // what direction you can lock/unlock the door from

/obj/machinery/door/unpowered/wood/New()
	..()
	if (!src.simple_lock)
		src.verbs -= /obj/machinery/door/unpowered/wood/verb/simple_lock

/obj/machinery/door/unpowered/wood/pyro
	icon = 'icons/obj/doors/SL_doors.dmi'
	icon_state = "wood1"
	icon_base = "wood"

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

/obj/machinery/door/unpowered/wood/attackby(obj/item/I as obj, mob/user as mob)
	if (src.operating)
		return
	src.add_fingerprint(user)
	if (!src.requiresID())
		//don't care who they are or what they have, act as if they're NOTHING
		user = null
	if(istype(I, /obj/item/device/key) && src.density)
		if (src.simple_lock)
			boutput(user, "<span class='alert'>You can't find a keyhole on this [src.name], it just has a little latch.</span>")
			return
		else if (src.lock_dir)
			var/checkdir = get_dir(src, user)
			if (!(checkdir & src.lock_dir))
				boutput(user, "<span class='alert'>[src]'s keyhole isn't on this side!</span>")
				return
		src.locked = !src.locked
		src.visible_message("<span class='notice'><B>[user] [!src.locked ? "un" : null]locks [src].</B></span>")
		return
	else if (isscrewingtool(I) && src.locked)
		actions.start(new /datum/action/bar/icon/door_lockpick(src, I, src.simple_lock ? 40 : 80), user)
		return
	if (user.is_hulk())
		src.visible_message("<span class='alert'><B>[user] smashes through the door!</B></span>")
		playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
		src.operating = -1
		src.locked = 0
		open()
		return 1
	if (!src.locked)
		if (src.density)
			open()
		else
			close()
	else if (src.density)
		play_animation("deny")
		playsound(src.loc, "sound/machines/door_locked.ogg", 50, 1, -2)
		boutput(user, "<span class='alert'>The door is locked!</span>")
	return

/obj/machinery/door/unpowered/wood/open()
	if(src.locked) return
	playsound(src.loc, "sound/machines/door_open.ogg", 50, 1)
	. = ..()

/obj/machinery/door/unpowered/wood/close()
	playsound(src.loc, "sound/machines/door_close.ogg", 50, 1)
	. = ..()

/obj/machinery/door/unpowered/wood/verb/simple_lock(mob/user)
	set name = "Lock Door"
	set category = "Local"
	set src in oview(1)

	if (!src.density || src.operating)
		boutput(user, "<span class='alert'>You COULD flip the lock on [src] while it's open, but it wouldn't actually accomplish anything!</span>")
		return
	if (src.lock_dir)
		var/checkdir = get_dir(src, user)
		if (!(checkdir & src.lock_dir))
			boutput(user, "<span class='alert'>[src]'s lock isn't on this side!</span>")
			return
	src.locked = !src.locked
	src.visible_message("<span class='notice'><B>[user] [!src.locked ? "un" : null]locks [src].</B></span>")
	return

/datum/action/bar/icon/door_lockpick
	id = "door_lockpick"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 80
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/machinery/door/unpowered/wood/the_door
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			the_door = O
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		if (the_door == null || the_tool == null || owner == null || get_dist(owner, the_door) > 1 || !the_door.locked || the_door.operating)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return
		if (prob(5) || (!the_door.simple_lock && prob(5)))
			owner.visible_message("<span class='alert'>[owner] messes up while picking [the_door]'s lock!</span>")
			playsound(get_turf(the_door), "sound/items/Screwdriver2.ogg", 50, 1)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		owner.visible_message("<span class='alert'>[owner] begins picking [the_door]'s lock!</span>")
		playsound(get_turf(the_door), "sound/items/Screwdriver2.ogg", 50, 1)

	onEnd()
		..()
		the_door.locked = 0
		owner.visible_message("<span class='alert'>[owner] jimmies [the_door]'s lock open!</span>")
		playsound(get_turf(the_door), "sound/items/Screwdriver2.ogg", 50, 1)

/obj/machinery/door/unpowered/bulkhead
	name = "bulkhead door"
	desc = "A heavy manually operated door. It looks rather beaten."
	icon = 'icons/obj/doors/bulkhead.dmi'
	operation_time = 20

/obj/machinery/door/unpowered/bulkhead/Bumped()
	return

/obj/machinery/door/control/oneshot
	var/broken = 0

#undef KNOCK_DELAY
