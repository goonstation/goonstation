// Dummies so they can be put on the public maps
/obj/submachine/chicken_incubator
	name = "\improper Chicken Egg Incubator"

/obj/submachine/ranch_feed_grinder
	name = "feed grinder"

/obj/chicken_nesting_box
	name = "nesting box"

/obj/item/chicken_carrier
	name = "chicken carrier"

/mob/living/critter/small_animal/ranch_base/chicken

/obj/item/reagent_containers/food/snacks/ranch_feed_bag
	rand_pos = 0

/obj/dialogueobj/dreambee

/obj/item/old_grenade/chicken

/turf/unsimulated/floor/dream/beach

/turf/unsimulated/floor/dream/space

/obj/fakeobject/dreambeach/earth

/obj/fakeobject/dreambeach/biggest/big_palm_with_nuts

/obj/fakeobject/dreambeach/sticks

/obj/fakeobject/dreambeach/biggest/big_palm

/obj/fakeobject/dreambeach/mars

/obj/fakeobject/dreambeach/saturn

/obj/fakeobject/dreambeach/stones

/obj/fakeobject/dreambeach/seashells

/obj/fakeobject/dreambeach/big/palm1

/obj/fakeobject/dreambeach/palm_leaf

/obj/fakeobject/dreambeach/mercury

/mob/living/critter/small_animal/ranch_base/sheep/white/dolly/ai_controlled

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/sheep
	var/secret_thing = 0

/mob/living/critter/robotic/bot/engibot

/obj/overlay/simple_light/disco_lighting
	var/randomize_start = 0
	name = "disco_overlay"

#ifdef IN_MAP_EDITOR
	icon_state = "simp"
#endif

/obj/machinery/light/small/floor/centcom_nightlight
	name = "night light"
	desc = "A light that gets brighter at night."
	light_type = /obj/item/light/bulb/neutral
	New()
		var/centcom_color = daynight_controllers[AMBIENT_LIGHT_SRC_EARTH]?.light.color
		var/list/light_outside = rgb2num(centcom_color,COLORSPACE_HSL)
		brightness = (1 - (light_outside[3]/255))*1.3
		. = ..()



/obj/overlay/simple_light/disco_lighting/rainbow
	New()
		. = ..()
		if(randomize_start)
			spawn(rand(0,13))
				animate_rainbow_glow(src)
		else
			animate_rainbow_glow(src)

	random_start
		randomize_start = 1

/obj/overlay/simple_light/disco_lighting/oscillator
	var/color_1 = "#FF0000"
	var/color_2 = "#0000FF"

	New()
		. = ..()
		if(randomize_start)
			spawn(rand(0,13))
				oscillate_colors(src,list(color_1,color_2))
		else
			oscillate_colors(src,list(color_1,color_2))

	random_start
		randomize_start = 1

	purple_white
		color_1 = "#AA00FF"
		color_2 = "#FFFFFF"

		random_start
			randomize_start = 1

	green_pink
		color_1 = "#00FF00"
		color_2 = "#FF55AA"

		random_start
			randomize_start = 1

	blue_orange
		color_1 = "#0000FF"
		color_2 = "#FF9900"

		random_start
			randomize_start = 1

	white_black
		color_1 = "#FFFFFF"
		color_2 = "#000000"

		random_start
			randomize_start = 1

/obj/item/storage/box/nametags
	name = "box of nametags"
	desc = "A box of little nametags for your favorite ranch animals!"
	icon_state = "box"
	#ifdef SECRETS_ENABLED
	spawn_contents = list(/obj/item/ranch_nametag= 7)
	#endif


/obj/item/kitchen/egg_box
	name = "egg carton"
	desc = "A carton that holds a bunch of eggs. What kind of eggs? What grade are they? Are the eggs from space? Space chicken eggs?"
	icon = 'icons/obj/foodNdrink/food_related.dmi'
	icon_state = "eggbox-closed"
	var/count = 0
	var/init_count = 12
	var/max_count = 12
	var/contained_food = /obj/item/reagent_containers/food/snacks/ingredient/egg
	var/allowed_food = /obj/item/reagent_containers/food/snacks/ingredient/egg
	var/contained_food_name = "egg"
	var/list/obj/carton_egg_proxy/egg_list = null
	tooltip_flags = REBUILD_DIST

	half
		init_count = 6

	rancher
		name = "ranch starter eggs"
		init_count = 4

		//BR variants
		void
			name = "nebulous carton"
			desc = "A egg carton with purple eggs, a label mentions squeezing and vulnerability."
			contained_food = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/purple
		wizard
			name = "magical carton"
			desc = "A oddly mystical egg carton, there is a wizard using a spell on the top."
			contained_food = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/wizard
		snow
			name = "cold carton"
			desc = "This carton chills your hands to hold it, a slipping warning is printed on the back."
			contained_food = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/snow
		plant
			name = "overgrown carton"
			desc = "Vines try to nudge out of this carton, it has a picture of the sun on it."
			contained_food = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/plant
		mime
			name = "monochrome carton"
			desc = "This monochrome box shows a mime making a stop motion with their hands."
			contained_food = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/mime
		knight
			name = "chivalrous carton"
			desc = "This plate-mailed carton has a shield printed onto it."
			contained_food = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/knight

	empty
		init_count = 0

	New()
		..()
		SPAWN(1 SECOND)
			if(!ispath(src.contained_food))
				logTheThing(LOG_DEBUG, src, "has a non-path contained_food, \"[src.contained_food]\", and is being disposed of to prevent errors")
				qdel(src)
				return
			else
				src.egg_list = list()
				for (var/i = 1, i <= src.max_count, i++)
					var/obj/carton_egg_proxy/proxy = new /obj/carton_egg_proxy(src,src)
					src.egg_list += proxy
					src.vis_contents += proxy
					proxy.my_index = i
					RegisterSignal(proxy, COMSIG_ATTACKHAND, PROC_REF(remove_egg))
				if (src.init_count>0)
					for (var/i = 1, i <= init_count, i++)
						src.insert_egg(new src.contained_food(src))
						src.egg_list[src.egg_list[i]].mouse_opacity = 1
				src.hide_eggs()

	get_desc(dist)
		if(dist <= 1)
			. += "There's [(src.count > 0) ? src.count : "no" ] [src.contained_food_name][s_es(src.count)] in [src]."

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/tongs))
			return src.Attackhand(user)
		// Stops trying to fit sticker in the box when we want it ON the box
		if (istype(W, /obj/item/sticker))
			return
		if(src.count >= src.max_count)
			boutput(user, "You can't fit anything else in [src]!")
			return
		else
			if(istype(W, src.allowed_food))
				user.drop_item()
				W.set_loc(src)
				src.insert_egg(W)
				tooltip_rebuild = TRUE
				boutput(user, "You place [W] into [src].")
				src.update()
				SEND_SIGNAL(W, COMSIG_ITEM_STORED, user)
			else return ..()

	mouse_drop(mob/user as mob) // no I ain't even touchin this mess it can keep doin whatever it's doin
		if(user == usr && !user.restrained() && !user.stat && (user.contents.Find(src) || in_interact_range(src, user)))
			if(!user.put_in_hand(src))
				return ..()

	MouseDrop_T(var/atom/movable/target, var/mob/user)
		if (src.icon_state == "eggbox-closed" || !istype(target, /obj/item/reagent_containers/food/snacks/ingredient/egg) || !in_interact_range(src, user)  || BOUNDS_DIST(target, user) > 0 || !can_act(user))
			return
		if (src.count < src.max_count)
			user.visible_message(SPAN_NOTICE("[user] begins quickly filling \the [src]."))
			var/turf/staystill = get_turf(user)
			for(var/obj/item/checked_item in view(1,user))
				if (!istype(checked_item, target.type) || (checked_item in user) || QDELETED(checked_item)) continue
				if (get_turf(user) != staystill) break
				checked_item.add_fingerprint(user)
				checked_item.set_loc(src)
				src.insert_egg(checked_item)
				SEND_SIGNAL(checked_item, COMSIG_ITEM_STORED, user)
				sleep(0.2 SECONDS)
				if (src.count >= src.max_count)
					boutput(user, SPAN_NOTICE("\The [src] is now full!"))
					break
			boutput(user, SPAN_NOTICE("You finish filling \the [src]."))

	proc/insert_egg(var/obj/item/egg = null)
		if (src.count < src.max_count)
			for (var/i = 1, i<=src.max_count, i++)
				var/obj/carton_egg_proxy/proxy = src.egg_list[i]
				if (isnull(proxy.icon_state))
					src.egg_list[proxy] = egg
					var/egg_color = global.mult_colors(egg.get_average_color(),"#FFFFFF")
					proxy.color = egg_color
					proxy.icon_state = "eggbox[i]"
					proxy.mouse_opacity = 1
					src.count ++
					return


	proc/get_egg_index(var/egg = null)
		if (src.count > 0)
			if (isnull(egg))
				for (var/i = 1, i<=src.max_count, i++)
					var/obj/carton_egg_proxy/proxy = src.egg_list[i]
					if (!isnull(src.egg_list[proxy]))
						return i
			else
				for (var/i = 1, i<=src.max_count, i++)
					if (isnull(src.egg_list[egg_list[i]]))
						continue
					else if (src.egg_list[egg_list[i]] == egg)
						return i


	proc/get_egg(var/index = null)
		if (src.count > 0)
			if (isnull(index))
				return src.egg_list[src.get_egg_index()]
			else
				return egg_list[src.egg_list[index]]

	proc/show_eggs()
		for (var/i = 1, i<=src.max_count, i++)
			if (isnull(src.egg_list[egg_list[i]]))
				continue
			else
				src.egg_list[i].icon_state = "eggbox[egg_list[i].my_index]"
				src.egg_list[i].mouse_opacity = 1

	proc/hide_eggs()
		for (var/obj/carton_egg_proxy/proxy in src.egg_list)
			proxy.icon_state = null
			proxy.mouse_opacity = 0

	proc/remove_egg(comsig_target, mob/attacker)
		var/obj/carton_egg_proxy/proxy = comsig_target
		var/obj/item/egg = src.get_egg(proxy.my_index)
		if(src.count >= 1)
			src.count--
			tooltip_rebuild = TRUE
		src.egg_list[src.egg_list[proxy.my_index]] = null
		src.egg_list[proxy.my_index].icon_state = null
		src.egg_list[proxy.my_index].mouse_opacity = 0
		attacker.put_in_hand_or_drop(egg)
		boutput(attacker, "You take [egg] out of [src].")


	attack_hand(mob/user)
		if((!istype(src.loc, /turf) && !user.is_in_hands(src)) || src.count == 0)
			..()
			return
		src.add_fingerprint(user)

		if(src.icon_state == "eggbox-closed")
			src.AttackSelf(user)

		else
			var/index= src.get_egg_index()
			if(index)
				remove_egg(src.egg_list[index], user)
		src.update()

	attack_self(mob/user as mob)
		if(src.icon_state == "eggbox-closed")
			src.icon_state = "eggbox-open"
			src.show_eggs()
			boutput(user, "You open [src].")
		else
			src.icon_state = "eggbox-closed"
			src.hide_eggs()
			boutput(user, "You close [src].")

	proc/update()
		return



/obj/carton_egg_proxy
	name = null
	icon = 'icons/obj/foodNdrink/food_related.dmi'
	icon_state = null
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE |  VIS_INHERIT_LAYER
	var/obj/item/kitchen/egg_box/my_egg_box = null
	var/my_index = null

	New(loc,var/obj/item/kitchen/egg_box/egg_box)
		..()
		src.my_egg_box = egg_box

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/tongs))
			return src.Attackhand(user)
		. = ..()

	attack_hand(mob/user)
		. = ..()

