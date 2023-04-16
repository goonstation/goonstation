#define PLAYER_SEEK_RANGE 15
#define DRONE_SEEK_RANGE 25
#define DRONE_SUMMON_RANGE 15

/obj/machinery/drone_beacon
	name = "Mysterious Beacon"
	desc = "Some strange transmitter."
	icon = 'icons/obj/ship.dmi'
	icon_state = "beacon_synd"
	anchored = ANCHORED
	density = TRUE
	processing_tier = PROCESSING_SIXTEENTH
	_max_health = 500
	_health = 500

	New()
		..()
		src.AddComponent(/datum/component/obj_projectile_damage)
		RegisterSignal(src, COMSIG_ATOM_HITBY_PROJ, .proc/hitby_proj)

	ex_act(severity)
		summon_drones()
		..()

	attackby(obj/item/I, mob/user)
		summon_drones()
		..()

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
		SEND_SIGNAL(src, COMSIG_DRONE_BEACON_DESTROYED) //UNUSED FOR NOW, PLANNED FEATURE
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
			var/drone = pick(/obj/critter/gunbot/drone/cutterdrone, /obj/critter/gunbot/drone/buzzdrone, /obj/critter/gunbot/drone/minigundrone, /obj/critter/gunbot/drone/heavydrone)
			var/turf/tile = pick(space_list)
			new drone(tile)
			elecflash(tile)


#undef PLAYER_SEEK_RANGE
#undef DRONE_SEEK_RANGE
#undef DRONE_SUMMON_RANGE
