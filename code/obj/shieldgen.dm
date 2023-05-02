/*

Shield and graivty well generators

*/

/obj/shieldgen
	name = "shield generator"
	desc = "Used to seal minor hull breaches."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldoff"

	density = 1
	opacity = 0
	anchored = UNANCHORED
	pressure_resistance = 2*ONE_ATMOSPHERE

	var/active = 0
	var/health = 100
	var/malfunction = 0



/obj/shieldgen/disposing()
	for(var/obj/shield/shield_tile in deployed_shields)
		shield_tile.dispose()

	..()

/obj/shieldgen/var/list/obj/shield/deployed_shields

/obj/shieldgen/proc
	shields_up()
		if(active) return 0

		for(var/turf/target_tile in range(2, src))
			if (istype(target_tile,/turf/space) && !(locate(/obj/shield) in target_tile))
				if (malfunction && prob(33) || !malfunction)
					deployed_shields += new /obj/shield(target_tile)

		src.anchored = ANCHORED
		src.active = 1
		src.icon_state = malfunction ? "shieldonbr":"shieldon"

		SPAWN(0) src.process()

	shields_down()
		if(!active) return 0

		for(var/obj/shield/shield_tile in deployed_shields)
			qdel(shield_tile)

		src.anchored = UNANCHORED
		src.active = 0
		src.icon_state = malfunction ? "shieldoffbr":"shieldoff"

/obj/shieldgen/proc/process()
	if(active)
		src.icon_state = malfunction ? "shieldonbr":"shieldon"

		if(malfunction)
			while(prob(10))
				qdel(pick(deployed_shields))

		SPAWN(3 SECONDS)
			src.process()
	return

/obj/shieldgen/proc/checkhp()
	if(health <= 30)
		src.malfunction = 1
	if(health <= 10 && prob(75))
		qdel(src)
	if (active)
		src.icon_state = malfunction ? "shieldonbr":"shieldon"
	else
		src.icon_state = malfunction ? "shieldoffbr":"shieldoff"
	return

/obj/shieldgen/meteorhit(obj/O as obj)
	src.health -= 25
	if (prob(5))
		src.malfunction = 1
	src.checkhp()
	return

/obj/shield/meteorhit(obj/O as obj)
	playsound(src.loc, 'sound/impact_sounds/Energy_Hit_1.ogg', 50, 1)
	return

/obj/shieldgen/ex_act(severity)
	switch(severity)
		if(1)
			src.health -= 75
			src.checkhp()
		if(2)
			src.health -= 30
			if (prob(15))
				src.malfunction = 1
			src.checkhp()
		if(3)
			src.health -= 10
			src.checkhp()
	return

/obj/shield/ex_act(severity)
	switch(severity)
		if(1)
			if (prob(75))
				qdel(src)
		if(2)
			if (prob(50))
				qdel(src)
		if(3)
			if (prob(25))
				qdel(src)
	return

/obj/shieldgen/attack_hand(mob/user)
	if (active)
		src.visible_message("<font color='blue'>[bicon(src)] [user] deactivated the shield generator.</font>")

		shields_down()

	else
		src.visible_message("<font color='blue'>[bicon(src)] [user] activated the shield generator.</font>")

		shields_up()

/obj/shield
	name = "shield"
	desc = "An energy shield."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	density = 1
	opacity = 0
	anchored = ANCHORED
	event_handler_flags = USE_FLUID_ENTER
	gas_impermeable = TRUE

	New()
		src.set_dir(pick(1,2,3,4))

		..()

		update_nearby_tiles(need_rebuild=1)

	disposing()
		update_nearby_tiles()

		..()
	proc/update_nearby_tiles(need_rebuild)
		var/turf/source = src.loc
		if (istype(source))
			return source.update_nearby_tiles(need_rebuild)

		return 1

/obj/shieldwall
	name = "shield"
	desc = "An energy shield."
	icon = 'icons/effects/effects.dmi'
	icon_state = "test"
	density = 1
	opacity = 0
	anchored = ANCHORED


TYPEINFO(/obj/gravity_well_generator)
	mats = 14

/obj/gravity_well_generator
	name = "gravity well generator"
	desc = "A complex piece of machinery that alters gravity."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gravgen-off"

	density = 1
	opacity = 0
	anchored = UNANCHORED
	pressure_resistance = 2*ONE_ATMOSPHERE

	var/active = 0
	var/strength = 144		//strength is basically G if you know your newton law of gravitation

/obj/gravity_well_generator

	meteorhit(obj/O as obj)
		if(prob(75))
			qdel(src)
			return

	ex_act(severity)
		switch(severity)
			if(1)
				if (prob(75))
					qdel(src)
			if(2)
				if (prob(50))
					qdel(src)
			if(3)
				if (prob(25))
					qdel(src)
		return

	attack_hand(mob/user)
		if (active)
			src.visible_message("<font color='blue'>[bicon(src)] [user] deactivated the gravity well.</font>")

			icon_state = "gravgen-off"
			src.anchored = UNANCHORED
			src.active = 0

		else
			src.visible_message("<font color='blue'>[bicon(src)] [user] activated the gravity well.</font>")

			icon_state = "gravgen-on"
			src.active = 1
			src.anchored = ANCHORED
			src.Life()

	proc/Life()

		if(!src.active)
			return

		//Computer the range
		var/range = round(sqrt(strength))

		for (var/atom/X in orange(range,src))
			//Skip if they're right beside the thing
			if (BOUNDS_DIST(src, X) == 0)
				continue
			//Get the distance
			var/dist = GET_DIST(src,X)

			//Adjust probability accordingly
			if ((istype(X,/obj) || isliving(X)) && prob(100/dist))
				//Skip if wearing magnetic shoes
				if (ishuman(X))
					var/mob/living/carbon/human/H = X
					if(H.shoes?.magnetic)
						continue
				//If not achored make them move towards it
				if (!X:anchored)
					step_towards(X,src)

		SPAWN(1.7 SECONDS)
			src.Life()

