#define cycle_pause 5 //min 1
#define viewrange 7 //min 2




// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
// Includes spacetiles
/turf/proc/CardinalTurfsWithAccessSpace(var/obj/item/card/id/ID)
	var/L[] = new()
	for(var/d in cardinal)
		var/turf/simulated/T = get_step(src, d)
		if((istype(T) || istype(T,/turf/space))&& !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L



/obj/alien/facehugger
	name = "alien"
	desc = "An alien, looks pretty scary!"
	icon_state = "facehugger"
	layer = MOB_LAYER
	density = 1
	anchored = 0

	var/state = 0

	var/list/path = null

	var/frustration = 0
	var/mob/living/carbon/target
	var/list/path_target = null

	var/turf/trg_idle
	var/list/path_idle = null

	var/alive = 1 //1 alive, 0 dead
	var/health = 25
	var/maxhealth = 25

	flags = FPRINT | TABLEPASS

	New()
		..()
		health = maxhealth
		src.process()

	examine()
		. = ..()
		if(src.hiddenFrom?.Find(usr.client)) //invislist
			return
		if(!alive)
			. += "<span class='alert'><B>the alien is not moving</B></span>"
		else if (src.health > 15)
			. += "<span class='alert'><B>the alien looks fresh, just out of the egg</B></span>"
		else
			. += "<span class='alert'><B>the alien looks pretty beat up</B></span>"


	attack_hand(user)
		return

	attackby(obj/item/W, mob/user)
		switch(W.damtype)
			if("fire")
				src.health -= W.force * 0.75
			if("brute")
				src.health -= W.force * 0.5
			else
		if (src.health <= 0)
			src.death()
		else if (W.force)
			if(ishuman(user), ismonkey(user))
				src.target = user
				src.state = 1
		..()

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round((P.power*P.ks_ratio), 1.0)

		if((P.damage_type == D_KINETIC)||(P.damage_type == D_SLASHING))
			src.health -= (damage*2)
		else if(P.damage_type == D_PIERCING)
			src.health -= damage
		else if(P.damage_type == D_ENERGY)
			src.health -= damage
		else if(P.damage_type == D_BURNING)
			src.health -= damage
		else if(P.damage_type == D_RADIOACTIVE)
			src.health -= damage
		else if(P.damage_type == D_TOXIC)
			src.health += damage
		healthcheck()

	ex_act(severity)
		switch(severity)
			if(1)
				src.death()
			if(2)
				src.health -= 15
				healthcheck()
		return

	meteorhit()
		src.death()
		return

	blob_act(var/power)
		if(prob(25))
			src.death()
		return

	Bumped(AM as mob|obj)
		if(ismob(AM) && (ishuman(AM) || ismonkey(AM)) )
			src.target = AM
			set_attack()
		else if(ismob(AM))
			SPAWN(0)
				var/turf/T = get_turf(src)
				AM:set_loc(T)

	bump(atom/A)
		if(ismob(A) && (ishuman(A) || ismonkey(A)))
			src.target = A
			set_attack()
		else if(ismob(A))
			src.set_loc(A:loc)




/*
	verb/follow()
		set src in view()
		set name = "follow me"
		if(!alive) return
		if(!isalien(usr))
			boutput(usr, text("<span class='alert'><B>The alien ignores you.</B></span>"))
			return
		if(state != 2 || health < maxhealth)
			boutput(usr, text("<span class='alert'><B>The alien is too busy to follow you.</B></span>"))
			return
		boutput(usr, text("<span class='success'><B>The alien will now try to follow you.</B></span>"))
		trg_idle = usr
		path_idle = new/list()
		return

	verb/stop()
		set src in view()
		set name = "stop following"
		if(!alive) return
		if(!isalien(usr))
			boutput(usr, text("<span class='alert'><B>The alien ignores you.</B></span>"))
			return
		if(state != 2)
			boutput(usr, text("<span class='alert'><B>The alien is too busy to follow you.</B></span>"))
			return
		boutput(usr, text("<span class='success'><B>The alien stops following you.</B></span>"))
		set_null()
		return
*/



	proc/call_to(var/mob/user)
		if(!alive || !isalien(user) || state != 2) return
		trg_idle = user
		path_idle = null
		return

	proc/set_attack()
		state = 1
		path_idle = null
		trg_idle = null

	proc/set_idle()
		state = 2
		path_target = null
		target = null
		frustration = 0

	proc/set_null()
		state = 0
		path_target = null
		path_idle = null
		target = null
		trg_idle = null
		frustration = 0

	proc/process()
		var/quick_move = 0

		if (!alive)
			return

		if (!target)
			path_target = null

			var/last_health = INFINITY

			for (var/mob/living/carbon/C in range(viewrange-2,src.loc))
				if (isalien(C) || C.alien_egg_flag || !can_see(src,C,viewrange))
					continue
				if(C:stunned || C:getStatusDuration("paralysis") || C:weakened)
					target = C
					break
				if(C:health < last_health)
					last_health = C:health
					target = C

			if(target)
				set_attack()
			else if(state != 2)
				set_idle()
				idle()

		else if(target)
			var/turf/distance = GET_DIST(src, target)
			set_attack()

			if(can_see(src,target,viewrange))
				// This doesn't work, it only returns whenever a human is lying down on a tile
				// TO-DO think of a way to make it so they can't go through windows
				//var/turf/trg_turf = get_turf(target)
				if(distance <= 1) //&& trg_turf.Enter(src))
					for(var/mob/O in AIviewers(world.view,src))
						O.show_message("<span class='alert'><B>[src.target] has been leapt on by the alien!</B></span>", 1, "<span class='alert'>You hear someone fall</span>", 2)
					random_brute_damage(target, 10)
					target:paralysis = max(target:paralysis, 10)
					src.set_loc(target.loc)

					if(!target.alien_egg_flag && ( ishuman(target) || ismonkey(target) ) )
						target.alien_egg_flag = 1
						var/mob/trg = target
						src.death()
						trg.contract_disease(new /datum/ailment/parasite/alien_embryo, 1)
						return
					else
						set_null()
						SPAWN(cycle_pause) src.process()
						return

				step_towards(src,get_step_towards2(src , target))
			else
				if(!path_target || !path_target.len )

					path_attack(target)
					if(!path_target)
						set_null()
						SPAWN(cycle_pause) src.process()
						return
				else
					var/turf/next = path_target[1]

					if(next in range(1,src))
						path_attack(target)

					if(!path_target || !length(path_target))
						src.frustration += 5
					else
						next = path_target[1]
						path_target -= next
						step_towards(src,next)
						quick_move = 1

			if (GET_DIST(src, src.target) >= distance) src.frustration++
			else src.frustration--
			if(frustration >= 35) set_null()

		if(quick_move)
			SPAWN(1 DECI SECOND)
				src.process()
		else
			SPAWN(cycle_pause)
				src.process()

	proc/idle()
		var/quick_move = 0

		if(state != 2 || !alive || target) return

		if(locate(/obj/alien/weeds) in src.loc && health < maxhealth)
			health++
			SPAWN(cycle_pause) idle()
			return

		if(!path_idle || !length(path_idle))

			if(isalien(trg_idle))
				if(can_see(src,trg_idle,viewrange))
					step_towards(src,get_step_towards2(src , trg_idle))
				else
					path_idle(trg_idle)
					if(!path_idle)
						trg_idle = null
						set_idle()
						SPAWN(cycle_pause) src.idle()
						return
			else
				var/obj/alien/weeds/W = null
				if(health < maxhealth)
					var/list/the_weeds = new/list()

					find_weeds:
						for(var/obj/alien/weeds/weed in range(viewrange,src.loc))
							if(!can_see(src,weed,viewrange)) continue
							for(var/atom/A in get_turf(weed))
								if(A.density) continue find_weeds
							the_weeds += weed
					W = pick(the_weeds)

				if(W)
					path_idle(W)
					if(!path_idle)
						trg_idle = null
						SPAWN(cycle_pause) src.idle()
						return
				else
					for(var/mob/living/carbon/alien/humanoid/H in range(1,src))
						SPAWN(cycle_pause) src.idle()
						return
					step(src,pick(cardinal))

		else

			if(can_see(src,trg_idle,viewrange))
				switch(GET_DIST(src, trg_idle))
					if(1)
						if(istype(trg_idle,/obj/alien/weeds))
							step_towards(src,get_step_towards2(src , trg_idle))
					if(2 to INFINITY)
						step_towards(src,get_step_towards2(src , trg_idle))
						path_idle = null
					/*
					if(viewrange+1 to INFINITY)
						step_towards(src,get_step_towards2(src , trg_idle))
						if(path_idle.len) path_idle = new/list()
						quick_move = 1
					*/
			else
				var/turf/next = path_idle[1]
				if(!next in range(1,src))
					path_idle(trg_idle)

				if(!path_idle)
					SPAWN(cycle_pause) src.idle()
					return
				else
					next = path_idle[1]
					path_idle -= next
					step_towards(src,next)
					quick_move = 1

		if(quick_move)
			SPAWN(1 DECI SECOND)
				idle()
		else
			SPAWN(cycle_pause)
				idle()

	proc/path_idle(var/atom/trg)
		path_idle = AStar(src.loc, get_turf(trg), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance)

	proc/path_attack(var/atom/trg)
		target = trg
		path_target = AStar(src.loc, target.loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance)


	proc/death()
		if(!alive) return
		src.alive = 0
		set_density(0)
		icon_state = "facehugger_l"
		set_null()
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='alert'><B>[src] curls up into a ball!</B></span>", 1)

	proc/healthcheck()
		if (src.health <= 0)
			src.death()
