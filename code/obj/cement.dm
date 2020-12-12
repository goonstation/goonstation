/obj/concrete_wet
	name = "wet concrete"
	icon = 'icons/effects/effects.dmi'
	icon_state = "concrete_wet"
	anchored = 1
	density = 0
	layer = OBJ_LAYER + 0.9
	event_handler_flags = USE_CANPASS
	var/health = 4 //how many hits to destroy + 1
	var/c_quality = 0
	var/created_time = 0

	New()
		..()
		created_time += world.time
		processing_items += src

	proc/process()
		if (world.time >= created_time + 150) //15secs
			var/obj/concrete_wall/C = new(get_turf(src))
			C.update_strength(c_quality)
			qdel(src)

	disposing()
		processing_items -= src
		..()

	CanPass(atom/A, turf/T)
		..()
		if(istype(A, /mob))
			var/mob/M = A
			M.setStatus("slowed", 5, optional = 4)
			boutput(M, "<span class='alert'>Running through the wet concrete is slowing you down...</span>")

	attack_hand(var/mob/user)
		if (health <= 0)
			user.visible_message("<span class='alert'>[user] breaks apart the lump of wet concrete with their bare hands!</span>")
			qdel(src)
			return
		health--
		if (health <= 0)
			user.visible_message("<span class='alert'>[user] breaks apart the lump of wet concrete with their bare hands!</span>")
			qdel(src)
			return
		..()

	attackby(var/obj/item/I, var/mob/user)
		if (health <= 0)
			user.visible_message("<span class='alert'>[user] breaks apart the lump of wet concrete!!</span>")
			qdel(src)
			return
		health -= 2
		if (health <= 0)
			user.visible_message("<span class='alert'>[user] breaks apart the lump of wet concrete!</span>")
			qdel(src)
			return
		..()

/obj/concrete_wall
	name = "concrete wall"
	icon = 'icons/effects/effects.dmi'
	icon_state = "concrete"
	density = 1
	opacity = 0 	// changed in New()
	anchored = 1
	name = "concrete wall"
	desc = "A heavy duty wall made of concrete! This thing is gonna take some manual labour to get through..."
	flags = FPRINT | CONDUCT | USEDELAY
	var/strength = 0 // 1=poor, 2=ok, 3=good, 4=perfect
	var/health = 30 //health num modified in New, 30 for poor, 60 for ok, 90 for good, 120 for perfect
	var/max_health = 0 //allows our description to show how close it is to dying

	New()
		..()

		flick("concrete_drying", src)

		if(istype(loc, /turf/space))
			loc:ReplaceWithConcreteFloor()

		update_nearby_tiles(1)
		SPAWN_DBG(0.1 SECONDS)
			RL_SetOpacity(1)

	disposing()
		RL_SetOpacity(0)
		density = 0
		update_nearby_tiles(1)
		..()

	proc/update_strength(var/quality)
		if(quality)
			strength = quality
			health *= strength
			max_health = health

	ex_act(severity) //hopefully this works
		if (health <= 0)
			playsound(src.loc, "sound/impact_sounds/Stone_Scrape_1.ogg", 50, 1)
			qdel(src)
			return
		switch(severity)
			if (3)
				health -= 40
			if (2)
				health -= 60
			if (1)
				qdel(src)
				return
		if (health <= 0)
			playsound(src.loc, "sound/impact_sounds/Stone_Scrape_1.ogg", 50, 1)
			qdel(src)
			return

	attack_hand(var/mob/user)
		src.add_fingerprint(user)
		user.lastattacked = src
		if (user.bioHolder.HasEffect("hulk") && (prob(100 - strength*20))) //hulk smash
			user.visible_message("<span class='alert'>[user] smashes through the concrete wall! OH YEAH!!!</span>")
			qdel(src)
		else
			boutput(user, "<span class='alert'>You hit the concrete wall and really hurt your hand!</span>")
			playsound(src.loc, pick(sounds_punch), 50, 1)
			random_brute_damage(user, 5)
		return

	attackby(var/obj/item/I, var/mob/user)
		src.add_fingerprint(user)
		user.lastattacked = src
		if (health <= 0)
			user.visible_message( "<span class='alert'>[user] smashes through the concrete wall.</span>", "<span class='notice'>You smash through the concrete wall with \the [I].</span>")
			playsound(src.loc, "sound/impact_sounds/Stone_Scrape_1.ogg", 50, 1)
			qdel(src)
			return
		health -= I.force
		if (health <= 0)
			user.visible_message( "<span class='alert'>[user] smashes through the concrete wall.</span>", "<span class='notice'>You smash through the concrete wall with \the [I].</span>")
			playsound(src.loc, "sound/impact_sounds/Stone_Scrape_1.ogg", 50, 1)
			qdel(src)
			return
		..()

	proc/update_nearby_tiles(need_rebuild)
		var/turf/simulated/source = loc
		if (istype(source))
			return source.update_nearby_tiles(need_rebuild)

		return 1

	get_desc()
		if (health / max_health == 1)
			. += "The wall looks great."
			return
		if (health / max_health >= 0.75)
			. += "The wall is showing some wear and tear."
			return
		if (health / max_health >= 0.5)
			. += "The wall is starting to look pretty beat up."
			return
		if (health / max_health >= 0.25)
			. += "The wall has suffered some major damage."
			return
		if (health / max_health >= 0)
			. += "The wall is almost in pieces."
			return
