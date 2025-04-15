/obj/concrete_wet
	name = "wet concrete"
	icon = 'icons/effects/effects.dmi'
	icon_state = "concrete_wet"
	anchored = ANCHORED
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

	Crossed(atom/movable/mover)
		if(istype(mover, /mob))
			var/mob/M = mover
			M.setStatus(statusId = "slowed", duration = 0.5 SECONDS, optional = 4)
			boutput(M, SPAN_ALERT("Running through \the [src] is slowing you down..."))
		return ..()

	attackby(var/obj/item/I, var/mob/user)
		changeHealth(-2)
		..()

	onDestroy()
		src.visible_message(SPAN_ALERT("\The [src] breaks apart!"))
		..()

/obj/concrete_wall
	name = "concrete wall"
	icon = 'icons/effects/effects.dmi'
	icon_state = "concrete"
	density = 1
	opacity = 0 	// changed in New()
	anchored = ANCHORED
	desc = "A heavy duty wall made of concrete! This thing is gonna take some manual labour to get through..."
	flags = CONDUCT | USEDELAY
	var/const/baseHealth = 30
	_max_health = baseHealth //Health related nums can be changed thru update_strength()
	_health = baseHealth
	var/strength = 0 // 1=poor, 2=ok, 3=good, 4=perfect

	New()
		..()

		FLICK("concrete_drying", src)

		if(istype(loc, /turf/space))
			loc:ReplaceWithConcreteFloor()

		update_nearby_tiles(1)
		SPAWN(0.1 SECONDS)
			set_opacity(1)

	disposing()
		set_opacity(0)
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
		user.lastattacked = get_weakref(src)
		if (user.bioHolder.HasEffect("hulk") && (prob(100 - strength*20))) //hulk smash
			user.visible_message(SPAN_ALERT("[user] smashes through \the [src]! OH YEAH!!!"))
			onDestroy()
		else
			boutput(user, SPAN_ALERT("You hit \the [src] and really hurt your hand!"))
			playsound(src.loc, pick(sounds_punch), 50, 1)
			random_brute_damage(user, 5)
		return

	attackby(var/obj/item/I, var/mob/user)
		src.add_fingerprint(user)
		user.lastattacked = get_weakref(src)
		changeHealth(-I.force)
		..()

	onDestroy()
		src.visible_message( SPAN_ALERT("\The [src] crumbles to dust!"))
		playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 50, 1)
		..()

	proc/update_nearby_tiles(need_rebuild)
		var/turf/source = src.loc
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
