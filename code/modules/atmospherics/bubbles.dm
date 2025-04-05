/obj/bubble
	name = "bubble"
	desc = "A large bubble of gas."
	icon = 'icons/obj/bubbles.dmi'
	icon_state = "bubble"
	density = FALSE
	event_handler_flags = IMMUNE_TRENCH_WARP
	var/scale = 1
	///If null, automatically calculate lifetime from size of bubble
	var/lifetime = null

	var/datum/gas_mixture/air_contents = null
	///legally distinct from the turf version because this needs to be on a lower plane to work with filters
	var/static/list/mutable_appearance/gas_overlays = list(
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

	New(loc, datum/gas_mixture/gas)
		. = ..()
		src.air_contents = gas
		src.air_contents.volume = 500
		src.appearance_flags |= KEEP_TOGETHER
		src.update_graphics()
		if (isnull(src.lifetime))
			src.lifetime = (6 * src.scale)**2
			src.lifetime = clamp(lifetime, 2, 30) * rand(9, 11) //0.9 - 1.1 * SECONDS
		SPAWN(src.lifetime)
			if (!QDELETED(src))
				src.pop()

	Move(newloc, dir)
		. = ..()
		var/turf/T = newloc
		if (istype(T) && T.active_liquid?.my_depth_level)
			return
		if (istype(newloc, /turf/space/fluid))
			return
		if (!checkTurfPassable(newloc))
			src.pop()
			return
		playsound(newloc, 'sound/vox/popsound.ogg', 20, 1) //silly placeholder
		T.assume_air(src.air_contents)
		src.air_contents = null
		qdel(src)

	Crossed(atom/movable/AM)
		. = ..()
		if (!isturf(src.loc)) //we're being absorbed
			return
		if (!AM.density && !istype(AM, /obj/bubble)) //we can collide with other bubbles
			return
		if (istype(AM, /obj/turbine_shaft/turbine))
			src.pop()
			return
		if (prob(15)) //sometimes you just walk through it
			return
		var/dir = AM.dir
		if (prob(40))
			dir = turn(dir, pick(90, -90))
		src.glide_size = AM.glide_size
		step(src, dir)

	pull(mob/user) //no pull
		return TRUE

	proc/pop()
		if (src.scale > 0.5)
			src.visible_message(SPAN_ALERT("[src] bursts into smaller bubbles!"))
			playsound(get_turf(src), 'sound/vox/popsound.ogg', 20, 1)
		var/obj/effects/bubbles/bubbles = new(get_turf(src))
		bubbles.Scale(src.scale, src.scale)
		GAS_MIXTURE_COLOR(bubbles.color, src.air_contents.toxins, "#d27ce4")
		GAS_MIXTURE_COLOR(bubbles.color, src.air_contents.radgas, "#8cd359")
		qdel(src)

	attackby(obj/item/I, mob/user)
		src.pop()

	attack_hand(mob/user)
		src.pop()

	proc/update_graphics()
		src.scale = clamp(MIXTURE_PRESSURE(src.air_contents) / (ONE_ATMOSPHERE * 2), 0.2, 1)
		//trying out something here, three distinct sprites that get dynamically scaled between
		//the idea is that the total scaling from the quantized sprite should never be very large, leading to cleaner looking scaling
		//idk it kind of works, maybe I should just give up and fully quantize them
		var/modifier = ""
		if (scale <= 0.2)
			modifier = "small"
			//no scaling below this point
		else if (scale <= 0.4)
			modifier = "small"
			var/effective_scale = src.scale * 32/8
			src.Scale(effective_scale, effective_scale)
		else if (scale <= 0.6)
			modifier = "mid"
			//scale it down by less because we're using a smaller sprite
			var/effective_scale = src.scale * 32/18 //ratio of the medium sprite diameter to the large one
			src.Scale(effective_scale, effective_scale)
		else
			modifier = "large"
			src.Scale(src.scale, src.scale)
		src.icon_state = "bubble-[modifier]"
		src.add_filter("bubble_mask", 1, alpha_mask_filter(0,0, icon('icons/obj/bubbles.dmi', "bubble_mask-[modifier]")))
		src.air_contents.check_tile_graphic()
		UPDATE_TILE_GAS_OVERLAY(src.air_contents.graphic, src, GAS_IMG_PLASMA)
		UPDATE_TILE_GAS_OVERLAY(src.air_contents.graphic, src, GAS_IMG_N2O)
		UPDATE_TILE_GAS_OVERLAY(src.air_contents.graphic, src, GAS_IMG_RAD)

/obj/bubble/plasma
	lifetime = 30 SECONDS
	New(loc)
		var/datum/gas_mixture/plasma = new()
		plasma.toxins = 100
		plasma.temperature = T20C
		..(loc, plasma)

/obj/bubble/current
	lifetime = 2 MINUTES

/obj/effects/bubbles
	icon = 'icons/effects/particles.dmi'
	icon_state = "bubbles_rising"
	alpha = 200

	New()
		. = ..()
		SPAWN(2 SECONDS)
		qdel(src)
