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
		animate_bumble(src) //maybe a little busy? Idk let's try it, since we can't really do sprite animations due to alpha masking
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
		playsound(newloc, pick('sound/effects/bubble_pop1.ogg', 'sound/effects/bubble_pop2.ogg'), 50, 1)
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
		if (prob(30)) //sometimes you just walk through it
			return
		var/dir = AM.dir
		if (prob(40))
			dir = turn(dir, pick(90, -90))
		src.glide_size = AM.glide_size
		step(src, dir)

	pull(mob/user) //no pull
		return TRUE

	//I know this doesn't exactly make sense because we're underwater
	//but making them look convincingly like they're rising to the surface is really really hard
	//also I like popping bubbles :)
	proc/pop()
		if (src.scale > 0.5)
			src.visible_message(SPAN_ALERT("[src] bursts and dissipates into the water!"))
			//https://pixabay.com/sound-effects/bubble-pop-6395/
			//TODO: put this in the PR
			playsound(get_turf(src), pick('sound/effects/bubble_pop1.ogg', 'sound/effects/bubble_pop2.ogg'), 50, 1)
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

/obj/effects/bubbles //for when they're "popped"
	icon = 'icons/effects/particles.dmi'
	icon_state = "bubbles_rising"
	alpha = 200

	New()
		. = ..()
		SPAWN(2 SECONDS)
		qdel(src)

/obj/bubble_vent //sus
	icon = 'icons/obj/nadir_seaobj.dmi'
	icon_state = "bitelung"
#define _DEFINE_GAS(GAS, ...) var/GAS = FALSE;
	APPLY_TO_GASES(_DEFINE_GAS)
#undef _DEFINE_GAS
	///Total amount of gas per bubble
	var/amount = 30
	///Plus or minus this much
	var/variance = 10
	var/temperature = T20C

	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

	proc/process()
		if (prob(60))
			//welcome to the _SILLY_ATMOS_MACRO zone
			var/total_gases = 0
#define _COUNT_GASES(GAS, ...) total_gases += src.GAS;
			APPLY_TO_GASES(_COUNT_GASES)
#undef _COUNT_GASES
			var/total_amount = src.amount + rand(-src.variance, src.variance)
			var/datum/gas_mixture/gas_mixture = new()
			gas_mixture.temperature = src.temperature
#define _MAKE_GASES(GAS, ...) if (src.GAS) {gas_mixture.GAS = total_amount/total_gases};
			APPLY_TO_GASES(_MAKE_GASES)
#undef _MAKE_GASES
			new /obj/bubble(src.loc, gas_mixture)

/obj/bubble_vent/plasma
	toxins = TRUE

/obj/bubble_vent/oxygen
	oxygen = TRUE
