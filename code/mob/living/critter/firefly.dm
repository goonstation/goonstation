
TYPEINFO(/mob/living/critter)
	var/captured_per_container = FALSE

TYPEINFO(/mob/living/critter/small_animal/firefly)
	captured_per_container = 10

/mob/living/critter/small_animal/firefly
	name = "firefly"
	desc = "A perfectly normal bioluminescent insect."
	hand_count = 2
	icon = 'icons/mob/insect.dmi'
	icon_state = "firefly"
	blood_id = "hemolymph"
	var/light_color = "#ADFF2F"
	var/image/bulb
	var/image/bulb_light

	speechverb_say = "bzzs"
	speechverb_exclaim = "bzzts"
	speechverb_ask = "hums"

	health_brute = 10
	health_burn = 10

	flags = TABLEPASS
	fits_under_table = 1
	base_move_delay = 1.5
	base_walk_delay = 3.5
	isFlying = 1

	New()
		..()
		UpdateIcon()

		SPAWN(rand(0.5 SECOND, 2 SECONDS))

			//modified bumble
			var/floatspeed = rand(1 SECOND,1.4 SECONDS)
			animate(src, pixel_y = 3, time = floatspeed, loop = -1, easing = LINEAR_EASING, , flags=ANIMATION_PARALLEL)
			animate(pixel_y = -3, time = floatspeed, easing = LINEAR_EASING)

			animate(src, pixel_y = 4, time = floatspeed*4.7, loop = -1, easing = LINEAR_EASING, , flags=ANIMATION_PARALLEL)
			animate(pixel_y = -4, time = floatspeed*4.7, easing = LINEAR_EASING)

			// I spent fucking hours trying to get DIR to animate... it does not like being parallelized FUCK
			// Pending https://www.byond.com/forum/post/2773733 514.1582
			// var/swap = 1
			// if(prob(50))
			// 	swap = -1

			// var/duration = rand(7 SECONDS, 10 SECONDS)

			// animate(src, time=5 SECOND, loop = -1, dir=EAST)
			// animate(time=5 SECOND, dir=WEST)

			// animate(src, time=duration, loop = -1, pixel_x=6*swap, easing=CIRCULAR_EASING, flags=ANIMATION_PARALLEL)
			// animate(time=duration, pixel_x=-6*swap, easing=CIRCULAR_EASING)

			// swap = 1
			// if(prob(50))
			// 	swap = -1
			// animate(src, time=duration*(2+rand()), loop = -1, pixel_x=4*swap, flags=ANIMATION_PARALLEL)
			// animate(time=duration*(2+rand()), loop = -1, pixel_x=-4*swap)

		hotkey("walk")

	attackby(obj/item/W, mob/living/user)
		// Move to TYPEINFO if more containers are whitelisted, k thx
		if(istype(W, /obj/item/reagent_containers/glass/jar) || istype(W, /obj/item/reagent_containers/glass/beaker/large))
			W.AddComponent(/datum/component/bug_capture, W, src, user)
		else
			..()

	on_reagent_change(add)
		. = ..()
		light_color = reagents.get_average_rgb()
		UpdateIcon()

	update_icon(...)
		. = ..()

		bulb = SafeGetOverlayImage("bulb", src.icon, "firefly-bulb")
		bulb.appearance_flags = RESET_COLOR
		bulb.color = light_color
		UpdateOverlays(bulb, "bulb")

		bulb_light = SafeGetOverlayImage("bulb-light", src.icon, "firefly-light")
		bulb_light.appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR | KEEP_APART
		bulb_light.layer = LIGHTING_LAYER_BASE
		bulb_light.plane = PLANE_LIGHTING
		bulb_light.blend_mode = BLEND_ADD
		bulb_light.color = light_color
		UpdateOverlays(bulb_light, "bulb-light")

	death(var/gibbed)
		..()
		animate(src,flags=ANIMATION_END_NOW)
		ClearAllOverlays()

	ai_controlled
		is_npc = 1
		New()
			..()
			src.ai = new /datum/aiHolder/wanderer(src)
			remove_lifeprocess(/datum/lifeprocess/blindness)
			remove_lifeprocess(/datum/lifeprocess/viruses)

		death(var/gibbed)
			qdel(src.ai)
			src.ai = null
			reduce_lifeprocess_on_death()
			..()

/mob/living/critter/small_animal/firefly/pyre
	desc = "A bioluminescent insect that appears to be on fire."
	light_color = "#FF2F2F"
	var/obj/effects/firefly_pyre/pyre

	New()
		. = ..()
		pyre = new(src)
		pyre.layer = src.layer + 1
		src.bioHolder.AddEffect("fire_resist")

	disposing()
		qdel(pyre)
		pyre = null
		..()

	death(var/gibbed)
		..()
		desc = "A squashed bug."
		qdel(pyre)


	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		..()
		if(isalive(src))
			pop(M)

	proc/pop()
		src.visible_message("<span class='alert'><b>[src]</b> erupts into a huge column of flames! That was unexpected!</span>")
		fireflash_sm(get_turf(src), 1, 3000, 1000)
		death()

	update_icon()
		..()
		UpdateOverlays(null, "bulb")

	ai_controlled
		is_npc = 1
		New()
			..()
			src.ai = new /datum/aiHolder/wanderer(src)
			remove_lifeprocess(/datum/lifeprocess/blindness)
			remove_lifeprocess(/datum/lifeprocess/viruses)

		death(var/gibbed)
			qdel(src.ai)
			src.ai = null
			reduce_lifeprocess_on_death()
			..()

/obj/effects/firefly_pyre
	name = "firefly_fire"
	desc = ""
	icon = 'icons/effects/fire.dmi'
	icon_state = "fire1"
	vis_flags = VIS_INHERIT_ID
	mouse_opacity = 0

	New(newLoc)
		..()
		if(ismovable(newLoc))
			var/atom/movable/A = newLoc
			A.vis_contents += src

		var/image/fire_light = SafeGetOverlayImage("pyre_light", 'icons/effects/fire.dmi', "1old")
		fire_light.appearance_flags = RESET_COLOR | RESET_TRANSFORM | NO_CLIENT_COLOR | KEEP_APART
		fire_light.layer = LIGHTING_LAYER_BASE
		fire_light.plane = PLANE_LIGHTING
		fire_light.blend_mode = BLEND_ADD
		fire_light.alpha = 200
		fire_light.transform *= 2
		UpdateOverlays(fire_light, "pyre_light" )

	disposing()
		src.vis_locs = null
		..()

/mob/living/critter/small_animal/firefly/lightning
	desc = "A bioluminescent insect that has some suspecious extra glow to it."
	var/obj/effects/firefly_lightning/lightning

	New()
		. = ..()
		lightning = new(src)

	disposing()
		qdel(lightning)
		lightning = null
		..()

	death(var/gibbed)
		..()
		qdel(lightning)

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		..()
		if(isalive(src))
			zap(M)

	proc/zap(mob/target)
		if(isturf(src.loc) && istype(target) && !ON_COOLDOWN(src,"zap", 20 SECONDS))
			arcFlash(src, target, 5000, 0.5)
			lightning.recharge(20 SECONDS)

	ai_controlled
		is_npc = 1
		New()
			..()
			src.ai = new /datum/aiHolder/wanderer(src)
			remove_lifeprocess(/datum/lifeprocess/blindness)
			remove_lifeprocess(/datum/lifeprocess/viruses)

		death(var/gibbed)
			qdel(src.ai)
			src.ai = null
			reduce_lifeprocess_on_death()
			..()

/obj/effects/firefly_lightning
	name = "firefly_lightning"
	desc = ""
	icon = 'icons/effects/effects.dmi'
	icon_state = "energyorb"
	vis_flags = VIS_INHERIT_ID
	mouse_opacity = 0
	var/list/color_on = list(1.0, 0.0, 0.0, -0.5, \
					 0.0, 1.0, 0.0, -0.5, \
					 0.0, 0.0, 1.0,  1.0, \
					 0.0, 0.0, 0.0,  0.0, \
					 0.0, 0.0, 0.0,  0.0 )

	var/list/color_off = list(1.0, 0.0, 0.0, -0.5, \
					 0.0, 1.0, 0.0, -0.5, \
					 0.0, 0.0, 1.0,  0.0, \
					 0.0, 0.0, 0.0,  0.0, \
					 0.0, 0.0, 0.0,  0.0 )

	New(newLoc)
		..()
		color = color_on
		if(ismovable(newLoc))
			var/atom/movable/A = newLoc
			A.vis_contents += src

		var/image/lightning = image('icons/effects/effects.dmi', "energyorb")
		lightning.appearance_flags = RESET_COLOR | RESET_TRANSFORM | NO_CLIENT_COLOR | KEEP_APART | PIXEL_SCALE
		lightning.layer = LIGHTING_LAYER_BASE
		lightning.plane = PLANE_LIGHTING
		lightning.blend_mode = BLEND_ADD
		lightning.transform *= 1.5
		UpdateOverlays(lightning, "lightning-l")

	disposing()
		src.vis_locs = null
		..()

	proc/recharge(duration)
		animate(src, color=color_off, time=1 SECOND)
		animate(color=color_on, time=max(duration-1 SECOND, 0))

TYPEINFO(/mob/living/critter/small_animal/dragonfly)
	captured_per_container = 1

/mob/living/critter/small_animal/dragonfly
	name = "dragonfly"
	desc = "A big ol' flappy winged insect."
	hand_count = 2
	icon = 'icons/mob/insect.dmi'
	icon_state = "dragonfly"
	blood_id = "hemolymph"

	speechverb_say = "bzzs"
	speechverb_exclaim = "bzzts"
	speechverb_ask = "hums"

	health_brute = 10
	health_burn = 10

	flags = TABLEPASS
	fits_under_table = 1
	base_move_delay = 1.3
	base_walk_delay = 2
	health_brute = 10
	health_burn = 10
	isFlying = 1

	ai_controlled
		is_npc = 1
		New()
			..()
			src.ai = new /datum/aiHolder/wanderer(src)
			remove_lifeprocess(/datum/lifeprocess/blindness)
			remove_lifeprocess(/datum/lifeprocess/viruses)

		death(var/gibbed)
			qdel(src.ai)
			src.ai = null
			reduce_lifeprocess_on_death()
			..()

	Move(NewLoc, direct)
		. = ..()
		animate(src, time=5 SECONDS, pixel_x=rand(-4,4), pixel_y=rand(-8,8))

	attackby(obj/item/W, mob/living/user)
		if(istype(W, /obj/item/reagent_containers/glass/jar) || istype(W, /obj/item/reagent_containers/glass/beaker/large))
			W.AddComponent(/datum/component/bug_capture, W, src, user)
		else
			..()

/datum/component/bug_capture
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/light_color
	var/firefly_count

TYPEINFO(/datum/component/bug_capture)
	initialization_args = list()

/datum/component/bug_capture/Initialize(atom/A, mob/living/critter/B, mob/living/carbon/human/user)
	if(add_bug(A, B, user))
		RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/pickup)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/dropped)
		RegisterSignal(parent, COMSIG_ATOM_POST_UPDATE_ICON, .proc/update_icon)
		RegisterSignals(parent, list(COMSIG_ATOM_REAGENT_CHANGE, COMSIG_ITEM_ATTACK_SELF), .proc/bye_bugs)

		update_jar(A,user)
	else
		qdel(src) //Capturing the crash is not desired

/datum/component/bug_capture/InheritComponent(datum/component/bug_capture/C, i_am_original, atom/A, mob/living/critter/B, mob/living/carbon/human/user)
	add_bug(A, B, user)

/datum/component/bug_capture/proc/add_bug(atom/A, mob/living/critter/B, mob/living/carbon/human/user)
	var/allowed_bug_count = can_jar(B)
	if(allowed_bug_count)
		if(B.client)
			boutput(user, "<span class='alert'>[B] seems just to squirley to capture!  Need a more lazy one.</span>")
			return FALSE
	else
		return FALSE
	var/bug_count = 0
	for(var/atom/C in A.contents)
		if(!istype(C, B.type) && !istype(B, C.type))
			boutput(user, "<span class='alert'>[B] doesn't seem like it belongs with anything else.</span>")
			return FALSE
		else
			bug_count++

	if(bug_count >= allowed_bug_count)
		boutput(user, "<span class='alert'>[B] won't first with everything else inside of [A].</span>")
		return FALSE

	if(A != user && A.reagents?.total_volume)
		boutput(user, "<span class='alert'>You should probably pour out [A] first.</span>")
		return FALSE

	B.set_loc(A)
	update_jar(A,user)
	return TRUE

/datum/component/bug_capture/proc/can_jar(atom/A)
	. = FALSE
	var/mob/living/critter/C = A
	if(istype(C))
		var/typeinfo/mob/living/critter/typeinfo = C.get_typeinfo()
		return typeinfo.captured_per_container

/datum/component/bug_capture/proc/bye_bugs()
	var/atom/A = parent
	var/mob/user = A?.loc
	if(istype(A))
		for(var/atom/movable/B in A)
			if(can_jar(B))
				B.set_loc(get_turf(A))
		if(istype(user))
			boutput(user, "<span class='alert'>The contents of the [A] take this moment to escape!</span>")
		firefly_count = 0
	qdel(src)

/datum/component/bug_capture/proc/pickup(atom/A, mob/user)
	update_jar(A, user)

/datum/component/bug_capture/proc/update_jar(atom/A, mob/user)
	light_color = list(0, 0, 0)
	firefly_count = 0
	for(var/mob/living/critter/small_animal/firefly/F in A)
		var/firefly_color = hex_to_rgb_list(F.light_color)
		light_color[1] += firefly_color[1]
		light_color[2] += firefly_color[2]
		light_color[3] += firefly_color[3]
		firefly_count++
	if(firefly_count)
		light_color[1] /= firefly_count
		light_color[2] /= firefly_count
		light_color[3] /= firefly_count
		user?.add_sm_light("firefly_\ref[A]", list(light_color[1], light_color[2], light_color[3], clamp(firefly_count*20,40,300)))
	else
		user?.remove_sm_light("firefly_\ref[A]")

	A.UpdateIcon()

/datum/component/bug_capture/proc/dropped(atom/A, mob/user)
	user.remove_sm_light("firefly_\ref[A]")

/datum/component/bug_capture/proc/update_icon(atom/A)
	var/pixel_y_offset = 0
	var/has_bugs = FALSE

	if(istype(A, /obj/item/reagent_containers/glass/jar))
		A.icon_state = "mason_jar"
	else if(istype(A,/obj/item/reagent_containers/glass/beaker/large))
		pixel_y_offset = 4

	if(firefly_count && light_color)
		has_bugs = TRUE
		var/firefly_image_count
		switch(firefly_count)
			if(1 to 2)
				firefly_image_count = 1
			if(3 to 4)
				firefly_image_count = 2
			else
				firefly_image_count = 3

		var/image/bulb = image('icons/mob/insect.dmi', "jar_fire_[firefly_image_count]", pixel_y=pixel_y_offset)
		bulb.appearance_flags = RESET_COLOR
		bulb.color = rgb(light_color[1], light_color[2], light_color[3])
		A.underlays = list(bulb)

		var/image/bulb_light = A.SafeGetOverlayImage("bulb-light", 'icons/mob/insect.dmi', "jar_glow")
		bulb_light.pixel_y = pixel_y_offset
		bulb_light.appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR | KEEP_APART
		bulb_light.layer = LIGHTING_LAYER_BASE
		bulb_light.plane = PLANE_LIGHTING
		bulb_light.blend_mode = BLEND_ADD
		bulb_light.color = bulb.color
		A.UpdateOverlays(bulb_light, "bulb-light")

		A.add_sm_light("firefly", list(light_color[1], light_color[2], light_color[3], clamp(firefly_count*10, 40, 200)))
	else
		A.underlays = null
		A.UpdateOverlays(null, "bulb-light")
		A.remove_sm_light("firefly")

	if(locate(/mob/living/critter/small_animal/dragonfly) in A)
		has_bugs = TRUE
		var/image/dfly = image('icons/mob/insect.dmi', "jar_dragon", pixel_y=pixel_y_offset)
		A.underlays = list(dfly)

	if(!has_bugs)
		A.underlays = null


/datum/component/bug_capture/UnregisterFromParent()
	var/atom/A = parent
	var/mob/user = A?.loc

	update_jar(A, user)
	UnregisterSignal(parent, list(COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED, COMSIG_ATOM_POST_UPDATE_ICON, COMSIG_ATOM_REAGENT_CHANGE, COMSIG_ITEM_ATTACK_SELF))
	. = ..()

