//Your offensive weapon against wraiths and invisible folks
/obj/item/device/light/spirit_candle
	name = "spirit candle"
	desc = "Feels vaguely ominous!"
	icon = 'icons/obj/items/skull_candle.dmi'
	icon_state = "unmelted-unlit"
	w_class = W_CLASS_SMALL
	density = 0
	anchored = 0
	opacity = 0
	col_r = 0.2
	col_g = 0.2
	col_b = 0.8
	var/sparks = 7
	var/burn_state = 0
	var/burnt = FALSE
	var/light_ticks = 60

	New()
		..()

	attack_self(mob/user)
		if (src.on)
			src.visible_message("<span class='notice'>[user] blows on [src], its eyes emit a threatening glow!</span>")
			for(var/mob/living/intangible/wraith/W in orange(4, user))
				//Small grace period to run away after being manifested if you managed to survive so you dont get chain-manifested
				if ((W.last_spirit_candle_time + (W.forced_haunt_duration + 6 SECONDS)) < TIME)
					W.last_spirit_candle_time = TIME
					W.setStatus("corporeal", W.forced_haunt_duration, TRUE)
					boutput(W, "<span class='alert'>A malignant spirit pulls you into the physical world! You begin to gather your forces to try and escape to the spirit realm...</span>")
				else
					boutput(user, "<span class='notice'>[src] vibrates slightly in your hand. A hostile entity lurks nearby but resisted our attempts to reveal it!</span>")
			var/turf/T = get_turf(src)
			playsound(src.loc, 'sound/voice/chanting.ogg', 50, 0)
			new /obj/overlay/darkness_field(T, 10 SECOND, radius = 5.5, max_alpha = 250)
			new /obj/overlay/darkness_field{plane = PLANE_SELFILLUM}(T, 10 SECOND, radius = 5.5, max_alpha = 250)
			src.put_out(user)

	attackby(obj/item/W, mob/user)
		if (!src.on && !burnt)
			if (isweldingtool(W) && W:try_weld(user,0,-1,0,0))
				src.light(user, "<span class='alert'><b>[user]</b> casually lights [src] with [W], what a badass.</span>")

			else if (istype(W, /obj/item/clothing/head/cakehat) && W:on)
				src.light(user, "<span class='alert'>Did [user] just light \his [src] with [W]? Holy Shit.</span>")

			else if (istype(W, /obj/item/device/igniter))
				src.light(user, "<span class='alert'><b>[user]</b> fumbles around with [W]; sparks erupt from [src].</span>")

			else if (istype(W, /obj/item/device/light/zippo) && W:on)
				src.light(user, "<span class='alert'>With a single flick of their wrist, [user] smoothly lights [src] with [W]. Damn they're cool.</span>")

			else if ((istype(W, /obj/item/match) || istype(W, /obj/item/device/light/candle)) && W:on)
				src.light(user, "<span class='alert'><b>[user] lights [src] with [W].</span>")

			else if (W.burning)
				src.light(user, "<span class='alert'><b>[user]</b> lights [src] with [W]. Goddamn.</span>")
		else if (burnt)
			boutput(user, "<span class='notice'>The spirit inside has departed, you cannot use the candle again</span>")
		else
			return ..()

	process()
		if (src.on)
			light_ticks --
		else
			return
		if ((light_ticks < 40) && (burn_state < 1))
			burn_state = 1
			src.icon_state = "smelted-lit"
			src.visible_message("<span class='notice'>[src]'s light begins to flicker!</span>")
		else if ((light_ticks < 20) && (burn_state < 2))
			burn_state = 2
			src.icon_state = "melted-lit"
			src.visible_message("<span class='notice'>[src]'s light is almost out!</span>")
		if (light_ticks <= 0)
			src.put_out()
			return
		var/turf/T = get_turf(src)
		for_by_tcl(W, /mob/living/intangible/wraith)
			if (IN_RANGE(W, T, WIDE_TILE_WIDTH / 2))
				W.changeStatus("spirit_candle", 5 SECONDS)


	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if((temperature > T0C+400))
			src.light()
		..()

	proc/light(var/mob/user, var/message)
		if (!src) return
		if (burnt) return
		if (!src.on)
			logTheThing(LOG_COMBAT, user, "lights the [src] at [log_loc(src)].")
			src.on = 1
			src.hit_type = DAMAGE_BURN
			src.force = 3
			src.icon_state = "unmelted-lit"
			light.enable()
			processing_items |= src
			if(user)
				user.update_inhands()
				master = user
		return

	proc/put_out(var/mob/user = null)
		if (!src) return
		if (src.on)
			src.on = 0
			src.hit_type = DAMAGE_BLUNT
			src.force = 0
			switch(burn_state)
				if(0)
					src.icon_state = "unmelted-unlit"
				if(1)
					src.icon_state = "smelted-unlit"
				if(2)
					src.icon_state = "melted-unlit"
			src.burnt = TRUE
			light.disable()
			processing_items -= src
			if(user)
				user.update_inhands()
		return

/obj/decal/wraith_shadow
	name = "dark shadow"
	desc = "A dark shadow indicating the presence of an evil spirit."
	alpha = 0
	icon = 'icons/effects/wraitheffects.dmi'
	icon_state = "acursed"
	New(loc, lifespan = 3 SECONDS)
		. = ..()
		animate(src, time = lifespan / 2, alpha = 255)
		animate(time = lifespan / 2, alpha = 0)
		SPAWN(lifespan)
			qdel(src)

/// applied to waith by spirit candle, causes them to spawn dark shadows
/datum/statusEffect/spirit_candle
	id = "spirit_candle"
	desc = "You've been revealed!"
	unique = TRUE
	maxDuration = 5 SECONDS
	visible = FALSE

	onUpdate(timePassed)
		. = ..()
		if (GET_COOLDOWN(owner, "spirit_candle")) return
		new /obj/decal/wraith_shadow(owner.loc)
		ON_COOLDOWN(owner, "spirit_candle", 1 SECOND)
