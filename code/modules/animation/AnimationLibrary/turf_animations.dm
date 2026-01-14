/obj/overlay/tile_effect/fake_fullbright
	icon = 'icons/effects/white.dmi'
	plane = PLANE_LIGHTING
	layer = LIGHTING_LAYER_FULLBRIGHT
	blend_mode = BLEND_OVERLAY


/obj/overlay/tile_effect/sliding_turf
	mouse_opacity = 0

/obj/overlay/tile_effect/sliding_turf/New(turf/T)
	. = ..()
	src.icon = T.icon
	src.icon_state = T.icon_state
	src.set_dir(T.dir)
	src.color = T.color
	src.layer = T.layer - 1
	src.plane = T.plane


ADD_TO_NAMESPACE(ANIMATE)(proc/turf_slideout(turf/T, new_turf_type, dir, time))
	var/image/orig = image(T.icon, T.icon_state, dir=T.dir)
	var/was_fullbright = T.fullbright
	orig.color = T.color
	orig.appearance_flags |= RESET_TRANSFORM
	T.ReplaceWith(new_turf_type)
	T.layer--
	switch(dir)
		if(WEST)
			T.transform = list(1, 0, 32, 0, 1, 0)
		if(EAST)
			T.transform = list(1, 0, -32, 0, 1, 0)
		if(SOUTH)
			T.transform = list(1, 0, 0, 0, 1, 32)
		if(NORTH)
			T.transform = list(1, 0, 0, 0, 1, -32)
	animate(T, transform=list(1, 0, 0, 0, 1, 0), time=time)
	if(was_fullbright) // eww
		var/obj/full_light = new/obj/overlay/tile_effect/fake_fullbright(T)
		full_light.color = orig.color
		var/list/trans
		switch(dir)
			if(WEST)
				trans = list(0, 0, -16, 0, 1, 0)
			if(EAST)
				trans = list(0, 0, 16, 0, 1, 0)
			if(SOUTH)
				trans = list(1, 0, 0, 0, 0, -16)
			if(NORTH)
				trans = list(1, 0, 0, 0, 0, 16)
		animate(full_light, transform=trans, time=time)

ADD_TO_NAMESPACE(ANIMATE)(proc/turf_slideout_cleanup(turf/T))
	T.layer++
	T.underlays.Cut()
	var/obj/overlay/tile_effect/fake_fullbright/full_light = locate() in T
	if(full_light)
		qdel(full_light)

ADD_TO_NAMESPACE(ANIMATE)(proc/turf_slidein(turf/T, new_turf_type, dir, time))
	var/obj/overlay/tile_effect/sliding_turf/slide = new(T)
	var/had_fullbright = T.fullbright
	if(station_repair.station_generator && T.z == Z_LEVEL_STATION)
		station_repair.repair_turfs(list(T))
	else
		T.ReplaceWith(new_turf_type)
	T.layer -= 2
	var/list/tr
	switch(dir)
		if(WEST)
			tr = list(1, 0, -32, 0, 1, 0)
		if(EAST)
			tr = list(1, 0, 32, 0, 1, 0)
		if(SOUTH)
			tr = list(1, 0, 0, 0, 1, -32)
		if(NORTH)
			tr = list(1, 0, 0, 0, 1, 32)
	animate(slide, transform=tr, time=time)
	if(!had_fullbright && T.fullbright) // eww
		T.fullbright = 0
		T.ClearSpecificOverlays("fullbright")
		T.RL_Init() // turning off fullbright
		var/obj/full_light = new/obj/overlay/tile_effect/fake_fullbright(T)
		full_light.color = T.color
		switch(dir)
			if(WEST)
				full_light.transform = list(0, 0, 16, 0, 1, 0)
			if(EAST)
				full_light.transform = list(0, 0, -16, 0, 1, 0)
			if(SOUTH)
				full_light.transform = list(1, 0, 0, 0, 0, 16)
			if(NORTH)
				full_light.transform = list(1, 0, 0, 0, 0, -16)
		animate(full_light, transform=matrix(), time=time)

ADD_TO_NAMESPACE(ANIMATE)(proc/turf_slidein_cleanup(turf/T))
	T.layer += 2
	T.underlays.Cut()
	var/obj/overlay/tile_effect/fake_fullbright/full_light = locate() in T
	if(full_light)
		qdel(full_light)
	var/obj/overlay/tile_effect/sliding_turf/slide = locate() in T
	if(slide)
		qdel(slide)
	if(initial(T.fullbright))
		T.fullbright = 1
		T.AddOverlays(new /image/fullbright, "fullbright")
		T.RL_Init()

ADD_TO_NAMESPACE(ANIMATE)(proc/open_from_floor(atom/A, time = 1 SECOND, self_contained = TRUE))
	A.add_filter("alpha white", 200, alpha_mask_filter(icon='icons/effects/white.dmi', x=16))
	A.add_filter("alpha black", 201, alpha_mask_filter(icon='icons/effects/black.dmi', x=-16)) // has to be a different dmi because byond
	animate(A.get_filter("alpha black"), x=0, time=time, easing=CUBIC_EASING | EASE_IN)
	animate(A.get_filter("alpha white"), x=0, time=time, easing=CUBIC_EASING | EASE_IN, flags=ANIMATION_PARALLEL)
	if(self_contained) // assume we're starting from being invisible
		A.alpha = 255
	if(self_contained)
		SPAWN(time)
			A.remove_filter(list("alpha white", "alpha black"))

ADD_TO_NAMESPACE(ANIMATE)(proc/close_into_floor(atom/A, time = 1 SECOND, self_contained = TRUE))
	A.add_filter("alpha white", 200, alpha_mask_filter(icon='icons/effects/white.dmi', x=0))
	A.add_filter("alpha black", 201, alpha_mask_filter(icon='icons/effects/black.dmi', x=0)) // has to be a different dmi because byond
	animate(A.get_filter("alpha black"), x=-16, time=time, easing=CUBIC_EASING | EASE_IN)
	animate(A.get_filter("alpha white"), x=16, time=time, easing=CUBIC_EASING | EASE_IN, flags=ANIMATION_PARALLEL)
	if(self_contained)
		SPAWN(time)
			A.remove_filter(list("alpha white", "alpha black"))
			A.alpha = 0
