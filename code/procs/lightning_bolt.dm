/proc/lightning_bolt(atom/center, var/caster, var/duration = 9 SECONDS)
	showlightning_bolt(center)
	playsound(center, 'sound/effects/lightning_strike.ogg', 70, TRUE)
	elecflash(center,0, power=4, exclude_center = 0)
	if(duration > 0 SECONDS)
		residual_spark(center, caster, duration)

	for(var/mob/living/M in range(1,center))
		if (M.bioHolder?.HasEffect("resist_electric") || M.traitHolder?.hasTrait("training_chaplain"))
			boutput(M, SPAN_NOTICE("The lightning bolt arcs around you harmlessly."))
		if (M != caster && iswizard(M))
			boutput(M, SPAN_NOTICE("The other wizard's lightning strike refuses to hurt you out of respect to other wizards."))
			continue
		else if (check_target_immunity(M))
			continue
		else
			M.TakeDamage("chest", 0, 10, 0, DAMAGE_BURN)
			boutput(M, SPAN_ALERT("You feel a strong electric shock!"))
			M.do_disorient(stamina_damage = 20, knockdown = 0, stunned = 0, disorient = 10)
			if (M.loc == center)
				M.TakeDamage("chest", 0, 25, 0, DAMAGE_BURN)
				M.emote("scream")

	for(var/obj/machinery/bot/b in range(1,center))
		b.explode()

/proc/residual_spark(atom/center, var/caster, var/duration = "9 SECONDS") //lingering shocky parts after lightning bolts
	for(var/turf/T in range(1,center))
		for (var/obj/residual_electricity/E in T.contents)
			qdel(E) //no stacked shocky tiles
		var/obj/residual_electricity/electricity = new /obj/residual_electricity(T)
		electricity.caster = caster

/obj/residual_electricity
	name = "residual spark"
	icon = 'icons/effects/effects.dmi'
	icon_state = "residual_electricity"
	density = 0
	opacity = 0
	anchored = ANCHORED
	plane = PLANE_NOSHADOW_ABOVE
	var/duration = 9 SECONDS
	var/caster

	New()
		FLICK("residual_electricity_start", src)
		SPAWN(duration)
			qdel(src)
		..()

	Crossed(atom/movable/M as mob|obj)
		if(iscarbon(M))
			var/mob/living/L = M
			if (L.bioHolder?.HasEffect("resist_electric") || L.traitHolder?.hasTrait("training_chaplain") || check_target_immunity(L))
				return
			if (L != src.caster && iswizard(L))
				return
			L.changeStatus("slowed", 1 SECONDS)
			L.do_disorient(stamina_damage = 0, knockdown = 0, stunned = 0, disorient = 20)
		..()

/obj/decal/lightning_bolt
	name = "lightning bolt"
	anchored = ANCHORED
	density = 0
	opacity = 0
	plane = PLANE_NOSHADOW_ABOVE
	icon = 'icons/effects/64x128.dmi'
	icon_state = "lightning_1"
	pixel_x = -4

	New()
		..()
		FLICK(pick("lightning_1", "lightning_2"), src)
		SPAWN(0.7 SECONDS)
			qdel(src)

/obj/lightning_target
	anchored = ANCHORED
	density = 0
	opacity = 0
	plane = PLANE_NOSHADOW_ABOVE
	icon = 'icons/effects/effects.dmi'
	icon_state = "lightning_target"
	var/delay = 3 SECONDS
	var/caster

	New()
		SPAWN(delay)
			lightning_bolt(src.loc, caster)
			qdel(src)
		..()
