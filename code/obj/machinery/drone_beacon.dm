#define PLAYER_SEEK_RANGE 15
#define DRONE_SEEK_RANGE 25
#define DRONE_SUMMON_RANGE 15

/obj/machinery/drone_beacon
	name = "Mysterious Beacon"
	desc = "Some strange transmitter."
	icon = 'icons/obj/ship.dmi'
	icon_state = "beacon_synd"
	anchored = TRUE
	density = TRUE
	processing_tier = PROCESSING_SIXTEENTH
	_max_health = 500
	_health = 500
	var/orig_drone_spawn = FALSE

	New()
		..()
		src.AddComponent(/datum/component/obj_projectile_damage)
		RegisterSignal(src, COMSIG_ATOM_HITBY_PROJ, .proc/hitby_proj)
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	ex_act(severity)
		summon_drones()
		..()

	attackby(obj/item/I, mob/user)
		summon_drones()
		..()

	meteorhit(obj/meteor)
		return

	process()
		var/list/target_list = list()
		for(var/mob/M in view(PLAYER_SEEK_RANGE, src))
			if(isdead(M))
				continue
			target_list += M
		if(!length(target_list))
			for(var/obj/machinery/vehicle/V in by_cat[TR_CAT_PODS_AND_CRUISERS])
				if(V.health <= 0)
					continue
				if(!IN_RANGE(src, V, PLAYER_SEEK_RANGE))
					continue
				target_list += V
		if(!length(target_list))
			return
		else if(!orig_drone_spawn)
			orig_drone_spawn = TRUE
			summon_drones(2, TRUE)
		for_by_tcl(D, /obj/critter/gunbot/drone)
			if(D.dying || D.health <= 0)
				continue
			if(!IN_RANGE(src, D, DRONE_SEEK_RANGE))
				continue
			var/atom/target_pick = pick(target_list)
			D.select_target(target_pick)
			if(istype(target_pick, /obj/machinery/vehicle))
				var/obj/machinery/vehicle/O = target_pick
				O.threat_alert(D)

	onDestroy()
		elecflash(src, power = 2)
		summon_drones(3, TRUE)
		for_by_tcl(C, /obj/storage)
			if(istype(C, /obj/storage/secure/crate/synd_debris) && (GET_DIST(C, src) <= 10))
				SEND_SIGNAL(C, COMSIG_DRONE_BEACON_DESTROYED, src)
				break
		for_by_tcl(X, /obj/machinery/sword_terminal)
			X.icon_beacon_update()
		..()

	proc/hitby_proj()
		summon_drones()

	proc/summon_drones(var/amount = 1, var/override_cd = FALSE)
		if(!override_cd)
			if(ON_COOLDOWN(src, "drone_summon", 15 SECONDS))
				return
		var/list/turf/space_list = list()
		for(var/turf/space/T in range(DRONE_SUMMON_RANGE, src))
			space_list += T
		for(var/i in 1 to amount)
			var/drone = pick(/obj/critter/gunbot/drone/cutterdrone, /obj/critter/gunbot/drone/buzzdrone, /obj/critter/gunbot/drone/minigundrone, /obj/critter/gunbot/drone/heavydrone, /obj/critter/gunbot/drone/cannondrone, /obj/critter/gunbot/drone/laserdrone)
			var/turf/tile = pick(space_list)
			new drone(tile)
			elecflash(tile)


#undef PLAYER_SEEK_RANGE
#undef DRONE_SEEK_RANGE

/obj/machinery/sword_terminal
	name = "Mysterious Computer"
	desc = "It's a computer terminal. Huh."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_sword_on"
	density = TRUE
	anchored = TRUE

	New()
		..()
		icon_beacon_update()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	ex_act(severity)
		return

	meteorhit(obj/meteor)
		return

	get_desc()
		var/beacon_amount = 0
		if(sword_summoned_before)
			. += "<br>The [src]'s screen is dark and is lightly sparking."
			return
		for_by_tcl(B, /obj/machinery/drone_beacon)
			if(B.z == 3)
				beacon_amount += 1
		if(beacon_amount)
			. += "<br>The [src]'s screen is on, flashing red. It states, \"Warning, heavy interference detected.\""
		else
			. += "<br>The [src]'s screen is on, a large popup onscreen."

	attack_hand(mob/user)
		var/beacon_amount = 0
		if(sword_summoned_before)
			boutput(user, "<span class='alert'>The terminal's circuitry seems to be fried.</span>")
			return

		for_by_tcl(B, /obj/machinery/drone_beacon)
			if(B.z == 3)
				beacon_amount += 1
		if(beacon_amount)
			boutput(user, "<span class='alert'>The terminal's wireless connection is being jammed. From the interference level, you can tell there [beacon_amount==1 ? "is [beacon_amount] beacon":"are [beacon_amount] beacons"] remaining.</span>")
			return

		SETUP_GENERIC_ACTIONBAR(user, src, 15 SECONDS, .proc/sword_summon, null, src.icon, src.icon_state, "You press \"Confirm\" on the computer, which then sparks and fries the screen. You get the feeling you should step back!", null)

	proc/sword_summon()
		sword_summoned_before = TRUE
		var/turf/T = src.loc
		icon_beacon_update()
		playsound(src.loc, "sound/machines/signal.ogg", 60, 1)
		sleep(2.5 SECONDS)
		playsound(src.loc, "sound/machines/satcrash.ogg", 60, 1)
		summon_drones(3) //H E H
		sleep(8 SECONDS)
		explosion_new(src, src.loc, 55)
		sleep(2 SECONDS)
		new/obj/critter/sword(T)
		qdel(src)

	proc/icon_beacon_update()
		if(sword_summoned_before)
			icon_state = "computer_sword_off"
		else
			var/beacon_amount = 0
			for_by_tcl(B, /obj/machinery/drone_beacon)
				if(B.z == 3)
					beacon_amount += 1
			if(beacon_amount)
				icon_state = "computer_sword_jammed"
			else
				icon_state = "computer_sword_on"

	proc/summon_drones(var/amount = 1)
		var/list/turf/space_list = list()
		for(var/turf/space/T in range(DRONE_SUMMON_RANGE, src))
			space_list += T
		for(var/i in 1 to amount)
			var/drone = pick(/obj/critter/gunbot/drone/cutterdrone, /obj/critter/gunbot/drone/buzzdrone, /obj/critter/gunbot/drone/minigundrone, /obj/critter/gunbot/drone/heavydrone, /obj/critter/gunbot/drone/cannondrone, /obj/critter/gunbot/drone/laserdrone)
			var/turf/tile = pick(space_list)
			new drone(tile)
			elecflash(tile)

#undef DRONE_SUMMON_RANGE
