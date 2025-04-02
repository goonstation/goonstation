/obj/bubble
	name = "bubble"
	desc = "A large bubble of gas."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bubble"
	density = FALSE

	var/datum/gas_mixture/air_contents = null
	///legally distinct from the turf version because this needs to be on a lower plane to work with filters
	var/static/list/icon/gas_overlays = list(
		#ifdef ALPHA_GAS_OVERLAYS
		mutable_appearance('icons/effects/tile_effects.dmi', "plasma-alpha", OBJ_LAYER - 0.1),
		mutable_appearance('icons/effects/tile_effects.dmi', "sleeping_agent-alpha", OBJ_LAYER - 0.1),
		mutable_appearance('icons/effects/tile_effects.dmi', "rad_particles-alpha", OBJ_LAYER - 0.1)
		#else
		mutable_appearance('icons/effects/tile_effects.dmi', "plasma", OBJ_LAYER - 0.1),
		mutable_appearance('icons/effects/tile_effects.dmi', "sleeping_agent", OBJ_LAYER - 0.1),
		mutable_appearance('icons/effects/tile_effects.dmi', "rad_particles", OBJ_LAYER - 0.1)
		#endif
	)

	New()
		. = ..()
		src.air_contents = new()
		src.air_contents.volume = 500
		src.appearance_flags |= KEEP_TOGETHER
		src.add_filter("bubble_mask", 1, alpha_mask_filter(0,0, icon('icons/obj/projectiles.dmi', "bubble_mask")))

	Move(newloc, dir)
		. = ..()
		var/turf/T = newloc
		if (istype(T) && T.active_liquid?.my_depth_level)
			return
		if (istype(newloc, /turf/space/fluid))
			return
		playsound(newloc, 'sound/vox/popsound.ogg', 20, 1) //silly placeholder
		T.assume_air(src.air_contents)
		src.air_contents = null
		qdel(src)

	Crossed(atom/movable/AM)
		. = ..()
		if (!AM.density && !istype(AM, /obj/bubble)) //we can collide with other bubbles
			return
		if (prob(15)) //sometimes you just walk through it
			return
		var/dir = AM.dir
		if (prob(40))
			dir = turn(dir, pick(90, -90))
		step(src, dir)

	pull(mob/user) //no pull
		return TRUE

	proc/pop()
		src.visible_message(SPAN_ALERT("[src] bursts into smaller bubbles!"))
		playsound(get_turf(src), 'sound/vox/popsound.ogg', 20, 1)
		var/obj/effects/bubbles/bubbles = new(get_turf(src))
		bubbles.color = src.color
		qdel(src)

	attackby(obj/item/I, mob/user)
		src.pop()

	attack_hand(mob/user)
		src.pop()

	proc/update_graphics()
		src.air_contents.check_tile_graphic()
		UPDATE_TILE_GAS_OVERLAY(src.air_contents.graphic, src, GAS_IMG_PLASMA)
		UPDATE_TILE_GAS_OVERLAY(src.air_contents.graphic, src, GAS_IMG_N2O)
		UPDATE_TILE_GAS_OVERLAY(src.air_contents.graphic, src, GAS_IMG_RAD)

/obj/bubble/plasma
	New()
		. = ..()
		src.air_contents.toxins = 100
		src.update_graphics()

/obj/effects/bubbles
	icon = 'icons/effects/particles.dmi'
	icon_state = "bubbles_rising"

	New()
		. = ..()
		SPAWN(2 SECONDS)
		qdel(src)
