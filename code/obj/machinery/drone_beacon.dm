#define PLAYER_SEEK_RANGE 12
#define DRONE_SEEK_RANGE 25

/obj/machinery/drone_beacon
	name = "Mysterious Beacon"
	desc = "Some strange transmitter."
	icon = 'icons/obj/ship.dmi'
	icon_state = "beacon_synd"
	anchored = TRUE
	density = TRUE
	processing_tier = PROCESSING_EIGHTH
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

	disposing()
		UnregisterSignal(src, COMSIG_ATOM_HITBY_PROJ)
		..()

	process()
		var/list/target_list = list()
		for(var/mob/M in range(PLAYER_SEEK_RANGE, src))
			if(M.stat == 2) //this feels like there should be a define for .stat
				continue
			if(istype(M.loc, /obj/machinery/vehicle))
				continue
			target_list += M
		if(!length(target_list))
			for(var/obj/machinery/vehicle/V in range(PLAYER_SEEK_RANGE, src))
				if(V.health <= 0)
					continue
				target_list += V
		if(!length(target_list))
			return
		for(var/obj/critter/gunbot/drone/D in range(DRONE_SEEK_RANGE, src))
			if(D.dying || D.health <= 0)
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
		for(var/turf/space/T in range(15, src))
			space_list += T
		for(var/i in 1 to amount)
			var/drone = pick(/obj/critter/gunbot/drone/cutterdrone, /obj/critter/gunbot/drone/buzzdrone, /obj/critter/gunbot/drone/minigundrone, /obj/critter/gunbot/drone/heavydrone)
			var/turf/tile = pick(space_list)
			new drone(tile)
			elecflash(tile)


#undef PLAYER_SEEK_RANGE
#undef DRONE_SEEK_RANGE
