/obj/concrete_wet
	name = "wet concrete"
	icon = 'icons/effects/effects.dmi'
	icon_state = "concrete_wet"
	anchored = 1
	density = 0
	layer = OBJ_LAYER + 0.9

	var/const/initial_health = 10
	_health = initial_health
	_max_health = initial_health
	var/c_quality = 0
	var/created_time = 0
	gas_impermeable = TRUE

	New()
		..()
		created_time += world.time
		processing_items += src

	proc/process()
		if (world.time >= created_time + 15 SECONDS)
			var/obj/concrete_wall/C = new(get_turf(src))
			C.update_strength(c_quality)
			qdel(src)

	disposing()
		processing_items -= src
		..()

	Cross(atom/movable/mover)
		if(istype(mover, /mob))
			var/mob/M = mover
			M.setStatus(statusId = "slowed", duration = 0.5 SECONDS, optional = 4)
			boutput(M, "<span class='alert'>Running through \the [src] is slowing you down...</span>")
		return ..()

	attackby(var/obj/item/I, var/mob/user)
		changeHealth(-2)
		..()

	onDestroy()
		src.visible_message("<span class='alert'>\The [src] breaks apart!</span>")
		..()

/obj/concrete_wall
	name = "concrete wall"
	icon = 'icons/effects/effects.dmi'
	icon_state = "concrete"
	density = 1
	opacity = 0 	// changed in New()
	anchored = 1
	desc = "A heavy duty wall made of concrete! This thing is gonna take some manual labour to get through..."
	flags = FPRINT | CONDUCT | USEDELAY
	var/const/baseHealth = 30
	_max_health = baseHealth //Health related nums can be changed thru update_strength()
	_health = baseHealth
	var/strength = 0 // 1=poor, 2=ok, 3=good, 4=perfect

	New()
		..()

		flick("concrete_drying", src)

		if(istype(loc, /turf/space))
			loc:ReplaceWithConcreteFloor()

		update_nearby_tiles(1)
		SPAWN(0.1 SECONDS)
			RL_SetOpacity(1)

	disposing()
		RL_SetOpacity(0)
		density = 0
		update_nearby_tiles(1)
		..()

	proc/update_strength(var/quality)
		if(quality)
			strength = quality
			_max_health = baseHealth * strength
			setHealth(_max_health)

	ex_act(severity)
		switch(severity)
			if (3)
				changeHealth(-40)
			if (2)
				changeHealth(-60)
			if (1)
				qdel(src)
				return

	attack_hand(var/mob/user)
		src.add_fingerprint(user)
		user.lastattacked = src
		if (user.bioHolder.HasEffect("hulk") && (prob(100 - strength*20))) //hulk smash
			user.visible_message("<span class='alert'>[user] smashes through \the [src]! OH YEAH!!!</span>")
			onDestroy()
		else
			boutput(user, "<span class='alert'>You hit \the [src] and really hurt your hand!</span>")
			playsound(src.loc, pick(sounds_punch), 50, 1)
			random_brute_damage(user, 5)
		return

	attackby(var/obj/item/I, var/mob/user)
		src.add_fingerprint(user)
		user.lastattacked = src
		changeHealth(-I.force)
		..()

	onDestroy()
		src.visible_message( "<span class='alert'>\The [src] crumbles to dust!</span>")
		playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 50, 1)
		..()

	proc/update_nearby_tiles(need_rebuild)
		var/turf/simulated/source = loc
		if (istype(source))
			return source.update_nearby_tiles(need_rebuild)

		return 1

	get_desc()
		if (_health / _max_health == 1)
			. += "The wall looks great."
			return
		if (_health / _max_health >= 0.75)
			. += "The wall is showing some wear and tear."
			return
		if (_health / _max_health >= 0.5)
			. += "The wall is starting to look pretty beat up."
			return
		if (_health / _max_health >= 0.25)
			. += "The wall has suffered some major damage."
			return
		if (_health / _max_health >= 0)
			. += "The wall is almost in pieces."
			return
