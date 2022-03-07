
/mob/living/critter/small_animal/firefly
	name = "firefly"
	desc = "A perfectly normal bioluminescent insect."
	hand_count = 2
	icon = 'icons/misc/bee.dmi'
	icon_state = "firefly-wings"
	//icon_body = "firefly"
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
	base_walk_delay = 2.5
	health_brute = 8
	health_burn = 8
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

	attackby(obj/item/W as obj, mob/living/user as mob)
		if(istype(W, /obj/item/reagent_containers/glass/jar))
			W.AddComponent(/datum/component/firefly_glow, W, src, user)
		else
			..()

	on_reagent_change(add)
		. = ..()
		light_color = reagents.get_average_rgb()
		UpdateIcon()

	update_icon(...)
		. = ..()
		bulb = image(src.icon, "firefly-bulb")
		bulb.appearance_flags = RESET_COLOR
		bulb.color = light_color
		UpdateOverlays(bulb, "bulb")

		bulb_light = image(src.icon, "firefly-light")
		bulb_light.appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR | KEEP_APART
		bulb_light.layer = LIGHTING_LAYER_BASE
		bulb_light.plane = PLANE_LIGHTING
		bulb_light.blend_mode = BLEND_ADD
		bulb_light.color = light_color
		UpdateOverlays(bulb_light, "bulb-light")

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




/datum/component/firefly_glow
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/light_color
	var/firefly_count
TYPEINFO(/datum/component/firefly_glow)
	initialization_args = list()

/datum/component/firefly_glow/Initialize(atom/A, mob/living/critter/small_animal/firefly/F, mob/living/carbon/human/user)
	if(add_firefly(A, F, user))
		RegisterSignal(parent, list(COMSIG_ITEM_PICKUP), .proc/pickup)
		RegisterSignal(parent, list(COMSIG_ITEM_DROPPED), .proc/dropped)
		RegisterSignal(parent, list(COMSIG_ATOM_POST_UPDATE_ICON), .proc/update_icon)
		RegisterSignal(parent, list(COMSIG_ATOM_REAGENT_CHANGE, COMSIG_ITEM_ATTACK_SELF), .proc/bye_fireflies)

		update_glow(A,user)
	else
		qdel(src) //Capturing the crash is not desired

/datum/component/firefly_glow/InheritComponent(datum/component/firefly_glow/C, i_am_original, atom/A, mob/living/critter/small_animal/firefly/F, mob/living/carbon/human/user)
	add_firefly(A, F, user)

/datum/component/firefly_glow/proc/add_firefly(atom/A, mob/living/critter/small_animal/firefly/F, mob/living/carbon/human/user)
	if(istype(F))
		if(F.client)
			boutput(user, "<span class='alert'>[F] seems just to squirley to capture!  Need a more lazy one.</span>")
			return FALSE
	for(var/atom/C in A.contents)
		if(!istype(C, /mob/living/critter/small_animal/firefly))
			boutput(user, "<span class='alert'>[F] doesn't seem like it belongs with anything else.</span>")
			return FALSE
	if(A != user && A.reagents?.total_volume)
		boutput(user, "<span class='alert'>You should probably pour out [A] first.</span>")
		return FALSE

	F.set_loc(A)
	update_glow(A,user)
	return TRUE

/datum/component/firefly_glow/proc/bye_fireflies()
	var/atom/A = parent
	var/mob/user = A?.loc
	if(istype(A))
		for(var/mob/living/critter/small_animal/firefly/F in A)
			F.set_loc(get_turf(A))
		if(istype(user))
			boutput(user, "<span class='alert'>The fireflies take this moment to escape from [A].</span>")
		firefly_count = 0
	qdel(src)

/datum/component/firefly_glow/proc/pickup(atom/A, mob/user)
	update_glow(A, user)

/datum/component/firefly_glow/proc/update_glow(atom/A, mob/user)
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
		user?.add_sm_light("firefly_\ref[A]", list(light_color[1], light_color[2], light_color[3], clamp(firefly_count*40,0,255)))
	else
		user?.remove_sm_light("firefly_\ref[A]")
	A.UpdateIcon()

/datum/component/firefly_glow/proc/dropped(atom/A, mob/user)
	user.remove_sm_light("firefly_\ref[A]")

/datum/component/firefly_glow/proc/update_icon(atom/A)
	if(firefly_count && light_color)
		if(istype(A, /obj/item/reagent_containers/glass/jar))
			A.icon_state = "mason_jar"

		var/firefly_image_count
		switch(firefly_count)
			if(1 to 2)
				firefly_image_count = 1
			if(3 to 4)
				firefly_image_count = 2
			else
				firefly_image_count = 3

		var/image/bulb = image('icons/misc/bee.dmi', "jar_fly_[firefly_image_count]")
		bulb.appearance_flags = RESET_COLOR
		bulb.color = rgb(light_color[1], light_color[2], light_color[3])
		A.underlays = list(bulb)

		var/image/bulb_light = image('icons/misc/bee.dmi', "jar_glow")
		bulb_light.appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR | KEEP_APART
		bulb_light.layer = LIGHTING_LAYER_BASE
		bulb_light.plane = PLANE_LIGHTING
		bulb_light.blend_mode = BLEND_ADD
		bulb_light.color = bulb.color
		A.UpdateOverlays(bulb_light, "bulb-light")

		A.add_sm_light("firefly", list(light_color[1], light_color[2], light_color[3], clamp(firefly_count*10, 40, 180)))
	else
		A.underlays = null
		A.UpdateOverlays(null, "bulb-light")
		A.remove_sm_light("firefly")

/datum/component/firefly_glow/UnregisterFromParent()
	var/atom/A = parent
	var/mob/user = A?.loc

	update_glow(A, user)
	UnregisterSignal(parent, list(COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED, COMSIG_ATOM_POST_UPDATE_ICON, COMSIG_ATOM_REAGENT_CHANGE, COMSIG_ITEM_ATTACK_SELF))
	. = ..()

