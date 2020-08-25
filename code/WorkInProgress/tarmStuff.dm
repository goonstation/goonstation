// sniper
/obj/item/gun/kinetic/light_machine_gun/fullauto
	name = "M90 machine gun"
	desc = "Looks pretty heavy to me. Hold shift to begin automatic fire!"
	icon = 'icons/obj/64x32.dmi'
	slowdown = 0
	var/shooting = 0
	var/turf/target = null

	New()
		..()
		ammo.amount_left=1000

	dropped(mob/M)
		remove_self(M)
		..()

	proc/remove_self(var/mob/living/M)
		if (ishuman(M))
			UnregisterSignal(M, COMSIG_LIVING_SPRINT_START)
		src.shooting = 0

	attack_hand(mob/user as mob)
		if (..() && ishuman(user))
			RegisterSignal(user, COMSIG_LIVING_SPRINT_START, .proc/begin_shootloop)

	proc/begin_shootloop(mob/living/L)
		if(!shooting)
			shooting = 1
			target = null
			current_projectile.shot_number = 1
			current_projectile.cost = 1
			current_projectile.shot_delay = 1.5
			APPLY_MOB_PROPERTY(L, PROP_CANTSPRINT, src)
			SPAWN_DBG(0)
				src.shootloop(L)

	proc/shootloop(mob/living/L)
		var/delay = 1.5 DECI SECONDS
		while(shooting && canshoot() && L?.client.check_key(KEY_RUN))
			src.shoot(target ? target : get_step(L, L.betterdir()), get_turf(L), L)
			src.suppress_fire_msg = 1
			sleep(max(delay*=0.9, 1.5))
		//loop ended - reset values
		shooting = 0
		REMOVE_MOB_PROPERTY(L, PROP_CANTSPRINT, src)
		current_projectile.shot_number = initial(current_projectile.shot_number)
		current_projectile.cost = initial(current_projectile.cost)
		current_projectile.shot_delay = initial(current_projectile.shot_delay)
		suppress_fire_msg = 0

	pixelaction(atom/target, params, mob/user, reach, continuousFire = 0)
		if(shooting)
			src.target = get_turf(target)
			src.suppress_fire_msg = 0
		else
			..()

/mob/living/proc/betterdir()
	return ((src.dir in ordinal) || (src.last_move_dir in cardinal)) ? src.dir : src.last_move_dir


/obj/item/gun/kinetic/pistol/autoaim
	name = "aimbot pistol"
	silenced = 1

	shoot(target, start, mob/user, POX, POY) //checks clicked turf first, so you can choose a target if need be
		for(var/mob/M in range(2, target))
			if(M == user || istype(M.get_id(), /obj/item/card/id/syndicate)) continue
			..(get_turf(M), start, user, POX, POY)
			return
		..()

/obj/item/gun/kinetic/pistol/smart
	name = "smart pistol"
	silenced = 1
	var/list/targets = list()
	var/targetting = 0

	dropped(mob/M)
		remove_self(M)
		..()

	proc/remove_self(var/mob/living/M)
		if (ishuman(M))
			UnregisterSignal(M, COMSIG_LIVING_SPRINT_START)
		src.targetting = 0

	attack_hand(mob/user as mob)
		if (..() && ishuman(user))
			RegisterSignal(user, COMSIG_LIVING_SPRINT_START, .proc/begin_targetloop)

	proc/begin_targetloop(mob/living/L)
		if(!targetting)
			targetting = 1
			targets.len = 0
			APPLY_MOB_PROPERTY(L, PROP_CANTSPRINT, src)
			SPAWN_DBG(0)
				src.targetloop(L)


	proc/targetloop(mob/living/L)
		var/ding = 0
		var/shotcount = 0
		while(targetting)
			sleep(1 SECOND)
			ding = 0
			for(var/mob/M in view(7, usr))
				if(!src || !(L?.client.check_key(KEY_RUN)))
					targetting = 0
					break
				if(in_cone_of_vision(usr, M) && !(targets[M] >= 3 || istype(M.get_id(), /obj/item/card/id/syndicate)) && shotcount < src.ammo.amount_left)
					targets[M] = targets[M] ? targets[M] + 1 : 1
					ding = 1
					shotcount++
					continue
			if(ding)
				L.playsound_local(L, "sound/machines/chime.ogg", 5, 0)
		//loop ended - reset values
		REMOVE_MOB_PROPERTY(L, PROP_CANTSPRINT, src)

	proc/validtarget(mob/M)
		return !(targets[M] >= 3 || istype(M.get_id(), /obj/item/card/id/syndicate))

	pixelaction(atom/target, params, mob/user, reach, continuousFire = 0)
		if(c_firing) return
		if(targetting)
			c_firing = 1
			for(var/mob/M in targets)
				for(var/i in 1 to targets[M])
					src.shoot(get_turf(M),get_turf(usr),usr)
					sleep(1)
			targets.len = 0
			c_firing = 0
		else
			..()