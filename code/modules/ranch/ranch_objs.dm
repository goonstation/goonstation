/*

TODO:

- Make feed bags for various items somehow use the colors from the items

*/

// Incubator

TYPEINFO(/obj/submachine/chicken_incubator)
	mats = 8

/obj/submachine/chicken_incubator
	name = "\improper Chicken Egg Incubator"
	desc = "Put an egg in here to make a chicken!"
	icon = 'icons/obj/ranch/ranch_obj.dmi'
	icon_state = "incubator"
	density = 1
	anchored = 1
	var/obj/item/reagent_containers/food/snacks/ingredient/egg/my_egg = null
	var/incubate_count = 0
	var/image/egg_overlay = null
	var/image/lights_overlay = null
	var/heating = 0
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH

	New()
		..()
		src.egg_overlay = image('icons/obj/ranch/ranch_obj.dmi', src, "incubator-egg")
		src.lights_overlay = image('icons/obj/ranch/ranch_obj.dmi', src, "incubator-lights")
		processing_items |= src

	disposing()
		processing_items.Remove(src)
		my_egg = null
		egg_overlay = null
		lights_overlay = null
		..()

	proc/process()
		if(!my_egg)
			if(incubate_count)
				incubate_count = 0
			if(heating)
				heating = 0
				ClearSpecificOverlays("lights_overlay")
		else
			if(!heating)
				heating = 1
				UpdateOverlays(lights_overlay, "lights_overlay")
			if(incubate_count)
				if(incubate_count > 30)
					SPAWN(0)
						make_chooken()
					incubate_count = 0
					ClearSpecificOverlays("egg_overlay")
				else
					incubate_count++
			else
				incubate_count = 1

	proc/make_chooken()
		if(istype(my_egg,/obj/item/reagent_containers/food/snacks/ingredient/egg/critter))
			var/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/E = my_egg
			E.warm_count = 0
			E.hatch_check(0, null, get_turf(src))
		else if(istype(my_egg,/obj/item/reagent_containers/food/snacks/ingredient/egg/bee))
			var/obj/item/reagent_containers/food/snacks/ingredient/egg/bee/E = my_egg
			E.hatch(null,get_turf(src))
		else
			//TODO: Special chickens
			my_egg.hatch_c()
		my_egg = null

	attackby(obj/item/W, mob/user)

		if(iswrenchingtool(W))
			var/turf/T = user.loc
			user.show_message("You begin to disassemble the incubator.")
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)

			sleep(2 SECONDS)

			if ((user.loc == T && user.equipped() == W))
				user.visible_message(SPAN_NOTICE("<b>[user]</b> disassembles [src]"),SPAN_NOTICE("You disassemble [src]"))
				var/obj/chicken_nesting_box/N = new /obj/chicken_nesting_box(get_turf(src))
				N.anchored = 1
				new /obj/item/incubator_parts(get_turf(src))
				qdel(src)
			return

		else if(istype(W,/obj/item/reagent_containers/food/snacks/ingredient/egg))
			if(my_egg)
				boutput(user, SPAN_ALERT("<b>There's already an egg in there!</b>"))
			else
				var/obj/item/reagent_containers/food/snacks/ingredient/egg/E = W
				user.u_equip(E)
				E.set_loc(src)
				my_egg = E
				if (istype(E, /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken))
					var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/chicken_egg = E
					egg_overlay.icon_state = "incubator-egg-[chicken_egg.chicken_egg_props.chicken_id]"
				else
					egg_overlay.icon_state = "incubator-egg-white"
				UpdateOverlays(egg_overlay, "egg_overlay")
				incubate_count = 0
		else if(istype(W,/obj/item/space_thing))
			boutput(user, SPAN_ALERT("<b>[W] opens to reveal some sort of egg!</b>"))
			user.u_equip(W)
			W.set_loc(src)
			qdel(W)

			var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E = null
			if(W.icon_state == "thing2")
				E = new /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/time(src)
			else
				E = new /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/space(src)
			my_egg = E
			egg_overlay.icon_state = "incubator-egg-[E.chicken_egg_props.chicken_id]"

			UpdateOverlays(egg_overlay, "egg_overlay")
			incubate_count = 0

		else
			..()

	attack_hand(mob/user)
		if(my_egg)
			ClearSpecificOverlays("egg_overlay")
			user.put_in_hand_or_drop(my_egg)
			my_egg = null
			incubate_count = 0
		else
			..()

/obj/item/incubator_parts
	name = "incubator parts"
	icon = 'icons/obj/ranch/ranch_obj.dmi'
	icon_state = "incubator_parts"
	w_class = W_CLASS_NORMAL

// Ranch Feed Proxy

/obj/item/reagent_containers/food/ranch_food_proxy
	name = "temp"
	desc = "temp"
	food_color = "#FFFFFF"
	var/ranch_flag = null

// Feed Grinder

TYPEINFO(/obj/submachine/ranch_feed_grinder)
	mats = 8

/obj/submachine/ranch_feed_grinder
	name = "feed grinder"
	icon = 'icons/obj/ranch/ranch_obj.dmi'
	icon_state = "feed_grinder"
	density = 1
	anchored = 1
	var/work_cycle = 0
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER
	var/obj/item/reagent_containers/food/current_food = null

	New()
		..()
		processing_items |= src

	disposing()
		processing_items.Remove(src)
		..()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ranch_feed_bag))
			..()
			return
		if (istype(W,/obj/item/satchel/) && W.contents.len)
			var/action = input(user, "What do you want to do with the satchel?") in list("Place it in the Chute","Empty it into the Chute","Never Mind")
			if (!action || action == "Never Mind")
				return
			if (!in_interact_range(src, user))
				boutput(user, SPAN_ALERT("You need to be closer to the chute to do that."))
				return
			if (action == "Empty it into the Chute")
				var/obj/item/satchel/S = W
				for(var/obj/item/O in S.contents)
					src.add_item(O)
				S.UpdateIcon()
				S.tooltip_rebuild = 1
				user.visible_message("<b>[user.name]</b> dumps out [S] into [src].")
				return

		if(istype(W,/obj/item/grab) || W.cant_drop)
			..()
			return

		user.u_equip(W)

		src.add_item(W)

	proc/add_item(var/obj/item/item)
		if(istype(item,/obj/item/reagent_containers/food))
			item.set_loc(src)
		else
			var/obj/item/reagent_containers/food/F = src.preprocess(item)
			qdel(item)
			F.set_loc(src)

	proc/preprocess(var/obj/item/I)

		var/obj/item/reagent_containers/food/ranch_food_proxy/R = new()

		R.name = I.name

		I.reagents?.copy_to(R.reagents)

		R.force = I.force
		R.throwforce = I.throwforce

		if (istype(I, /obj/item/reagent_containers/balloon/naturally_grown))
			var/obj/item/reagent_containers/balloon/naturally_grown/O = I
			if (O.reagents.has_reagent("helium"))
				R.ranch_flag = "helium"
				R.reagents.add_reagent("helium", 40)
				R.food_color = "#0000FF"
			else if (O.reagents.has_reagent("hydrogen"))
				R.ranch_flag = "hydrogen"
				R.reagents.add_reagent("hydrogen", 40)
				R.food_color = "#FF0000"

		else if (istype(I,/obj/item/organ/tail/lizard))
			R.ranch_flag = "lizard_tail"
			R.food_color = "#FF0000"

		else if (istype(I,/obj/item/plant/wheat/metal))
			R.ranch_flag = "wheat_steel"
			R.food_color = "#444444"

		else if (istype(I,/obj/item/plant/wheat))
			R.ranch_flag = "wheat"
			R.food_color = "#DDBB00"

		else if (I.material && I.material.getID() == "gold")
			R.ranch_flag = "gold"
			R.food_color = "#DDBB00"

		return(R)

	proc/process()
		if(length(src.contents))
			switch(work_cycle)
				if(0)
					if(QDELETED(current_food))
						current_food = locate(/obj/item/reagent_containers/food) in src.contents
						work_cycle++
				if(1 to 2)
					playsound(src.loc, 'sound/machines/mixer.ogg', 50, 1)
					work_cycle++
					return
				if(3)
					if(QDELETED(current_food))
						current_food = null
						work_cycle = 0
						return
					make_feed(current_food)
					current_food = null
					playsound(src.loc, 'sound/machines/ding.ogg', 100, 1)
					work_cycle = 0
					return

	proc/make_feed(var/obj/item/reagent_containers/food/F)
		var/obj/item/reagent_containers/food/snacks/ranch_feed_bag/B = new()
		B.feed_color = F.food_color
		B.update_overlays()
		B.happiness_mod = 0
		B.hunger_mod = 0
		B.name += " ([F.name])"

		// Food Based

		if(istype(F,/obj/item/reagent_containers/food/snacks/plant/corn/clear))
			B.happiness_mod = 3
			B.hunger_mod = 5
			B.feed_flags |= list("glass")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/plant/corn))
			B.happiness_mod = 3
			B.hunger_mod = 5

		else if (istype(F,/obj/item/reagent_containers/food/snacks/plant/chili/chilly))
			B.happiness_mod = -5 // cold!
			B.hunger_mod = 5
			B.feed_flags |= list("snow")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/plant/peanuts))
			B.happiness_mod = 5
			B.hunger_mod = 5
			B.feed_flags |= list("peanut")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/plant/chili/ghost_chili))
			B.happiness_mod = -10 // AAAAAAA
			B.hunger_mod = 0
			B.feed_flags |= list("ghost")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/plant/chili))
			B.happiness_mod = -5
			B.hunger_mod = -10
			B.feed_flags |= list("spicy")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/ingredient/rice_sprig))
			B.happiness_mod = 3
			B.hunger_mod = 5
			B.feed_flags |= list("rice")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/ingredient/rice))
			B.happiness_mod = 3
			B.hunger_mod = 5
			B.feed_flags |= list("rice")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/plant/tomato))
			B.happiness_mod = 3
			B.hunger_mod = 5
			B.feed_flags |= list("tomato")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/plant/peas))
			B.happiness_mod = 5
			B.hunger_mod = 7
			B.feed_flags |= list("peas")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/plant/orange/clockwork))
			B.happiness_mod = 3
			B.hunger_mod = 5
			B.feed_flags |= list("clockwork")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/plant/apple))
			B.happiness_mod = 3
			B.hunger_mod = 5
			B.feed_flags |= list("silkie")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/plant/eggplant))
			B.happiness_mod = 3
			B.hunger_mod = 5
			B.feed_flags |= list("eggplant")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget))
			B.happiness_mod = 3
			B.hunger_mod = 5
			B.feed_flags |= list("chicken_meat")
			B.feed_flags |= list("raptor")

		else if(istype(F,/obj/item/reagent_containers/food/snacks/ice_cream))
			B.happiness_mod = 5
			B.hunger_mod = 2
			B.feed_flags |= list("icecream")

		else if(istype(F,/obj/item/reagent_containers/food/snacks/popsicle))
			B.happiness_mod = 5
			B.hunger_mod = 2
			B.feed_flags |= list("icecream")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat))
			B.happiness_mod = 3
			B.hunger_mod = 5
			B.feed_flags |= list("synth")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/ingredient/meat/fish))
			B.happiness_mod = 5
			B.hunger_mod = 8
			B.feed_flags |= list("raptor")
			B.feed_flags |= list("fish")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/ingredient/meat))
			B.happiness_mod = 5
			B.hunger_mod = 8
			B.feed_flags |= list("raptor")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/plant/banana) || istype(F,/obj/item/reagent_containers/food/snacks/ingredient/peeled_banana))
			B.happiness_mod = 3
			B.hunger_mod = 5
			B.feed_flags |= list("honk")

		else if (istype(F,/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken))
			var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E = F
			if(E.chicken_egg_props.chicken_id == "pet")
				B.feed_flags |= list("ageless")
			B.happiness_mod = 3
			B.hunger_mod = 8
			B.feed_flags |= list("chicken_egg")

		// Reagent Based

		if(F.reagents?.total_volume > 0)
			if(F.reagents.has_reagent("THC"))
				B.happiness_mod += 5
				B.hunger_mod -= 5 //munchies
				B.feed_flags |= list("stone") // peak comedy

			if(F.reagents.has_reagent("ethanol"))
				B.happiness_mod += 5
				B.hunger_mod -= 5 // burp

			if(F.reagents.has_reagent("psilocybin"))
				B.happiness_mod += 5
				B.hunger_mod = 0
				B.feed_flags |= "wizard"

			if(F.reagents.has_reagent("nanites")) // Need to clear this if we ever have feed transfer reagents
				B.happiness_mod -= 5
				B.hunger_mod -= 10 // not tasty :(
				B.feed_flags |= list("robot")

			if(F.reagents.has_reagent("capulettium"))
				B.happiness_mod += 3 // naptime
				B.hunger_mod -= 5
				B.feed_flags |= list("silkie_black")

			if(F.reagents.has_reagent("methamphetamine"))
				B.happiness_mod += 2
				B.hunger_mod -= 5 // SO HUNGRY
				B.feed_flags |= list("silkie_white")

			if(F.reagents.has_reagent("sugar"))
				B.happiness_mod += 3 // yummy
				B.hunger_mod += 3 // yay calories
				B.feed_flags |= list("sugar")

			if (F.reagents.has_reagent("nicotine"))
				B.happiness_mod = 6
				B.hunger_mod += 10 //nicotine makes you not hungry
				B.feed_flags |= list("nicotine")

		// Item Based

		if(istype(F,/obj/item/reagent_containers/food/ranch_food_proxy))
			var/obj/item/reagent_containers/food/ranch_food_proxy/R = F

			if(R.ranch_flag)
				switch(R.ranch_flag)
					if("helium")
						B.happiness_mod += -1 // gives me gas
						B.hunger_mod += 1
						B.feed_flags |= list("helium")

					if("hydrogen")
						B.happiness_mod += -1
						B.hunger_mod += 1
						B.feed_flags |= list("hydrogen")

					if ("lizard_tail")
						B.happiness_mod += 8
						B.hunger_mod += 8
						B.feed_flags |= list("lizard")

					if ("wheat_steel")
						B.happiness_mod += -7 // uhhh??? what the fuck did you just feed me?
						B.hunger_mod += -1
						B.feed_flags |= list("metal")

					if ("wheat")
						B.happiness_mod += 3
						B.hunger_mod += 5
						B.feed_flags |= list("wheat")

					if ("gold")
						B.happiness_mod -= 7 // FEEDING ME ROCKS??
						B.hunger_mod -= -1 // ROCKS????
						B.feed_flags |= list("gold")

			else
				// I have no idea what you are but you probably aren't food
				B.happiness_mod = -(2*R.force + R.throwforce)
				B.hunger_mod = -(R.force + 2*R.throwforce)

		B.set_loc(get_turf(src))
		qdel(F)

// Feed Bag

/obj/item/reagent_containers/food/snacks/ranch_feed_bag
	name = "feed bag"
	desc = "Has some feed in it"
	icon = 'icons/obj/ranch/ranch_obj.dmi'
	icon_state = "feed_bag"
	doants = 0
	bites_left = 10
	rand_pos = 0
	heal_amt = 0
	var/feed_color = "#FFFF00"
	var/happiness_mod = 0
	var/hunger_mod = 0
	var/list/feed_flags = null //future proofing i suppose!
	var/image/feed_overlay = null

	New()
		..()
		feed_flags = list()
		feed_overlay = image('icons/obj/ranch/ranch_obj.dmi',"feed_bag-overlay")
		feed_overlay.color = feed_color
		src.overlays += feed_overlay
		src.reagents.maximum_volume = 0

	proc/update_overlays()
		src.overlays -= feed_overlay
		feed_overlay.color = feed_color
		src.overlays += feed_overlay

	proc/make_feed(atom/target)
		var/obj/decal/cleanable/ranch_feed/feed = make_cleanable(/obj/decal/cleanable/ranch_feed,target)
		feed.color = src.feed_color
		feed.happiness_mod = src.happiness_mod
		feed.hunger_mod = src.hunger_mod
		feed.feed_flags |= src.feed_flags
		return feed

	proc/spread_feed(atom/target, mob/user)
		user.visible_message(SPAN_NOTICE("[user] spreads some feed onto the floor from [src]."), SPAN_NOTICE("You spread some feed onto the floor from [src]"))
		src.make_feed(target)
		bites_left--
		if(!bites_left)
			boutput(user, SPAN_NOTICE("<b>The feed bag runs out of feed and instantly biodegrades!</b>"))
			user.u_equip(src)
			src.set_loc(get_turf(user))
			qdel(src)

	afterattack(var/atom/target, mob/user, flag)
		if(istype(target,/turf/))
			var/turf/T = target
			if(!T.density)
				spread_feed(target, user)

	attack_self(mob/user)
		if(isturf(user.loc))
			spread_feed(user.loc, user)
		else
			. = ..()

/obj/decal/cleanable/ranch_feed
	name = "feed"
	icon = 'icons/obj/ranch/ranch_obj.dmi'
	icon_state = "feed_tile_1"
	color = "#FFFFFF"
	random_icon_states = list("feed_tile_1", "feed_tile_2", "feed_tile_3")
	var/happiness_mod = 0
	var/hunger_mod = 0
	var/list/feed_flags = null

	New()
		..()
		feed_flags = list()

	disposing()
		feed_flags = null
		happiness_mod = 0
		hunger_mod = 0
		. = ..()

// Chicken Nesting Box

TYPEINFO(/obj/chicken_nesting_box)
	mats = 4

/obj/chicken_nesting_box
	name = "nesting box"
	desc = "A nice place for a hen to lay her eggs. Hens will refuse to use it if there's too many eggs in it."
	icon = 'icons/obj/ranch/ranch_obj.dmi'
	icon_state = "box"
	density = 0
	anchored = 0
	deconstruct_flags = DECON_SCREWDRIVER

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/incubator_parts))
			if(!src.anchored)
				user.show_message(SPAN_ALERT("<b>The nesting box needs to be screwed down before you can attach an incubator!</b>"))
			else
				user.show_message("You begin to assemble the incubator.")
				var/turf/T = user.loc
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				sleep(2 SECONDS)
				if ((user.loc == T && user.equipped() == W))
					user.visible_message(SPAN_NOTICE("<b>[user]</b> assembles an incubator."),SPAN_NOTICE("You assemble an incubator."))
					new /obj/submachine/chicken_incubator(get_turf(src))
					user.u_equip(W)
					W.set_loc(get_turf(user))
					qdel(W)
					qdel(src)
				return

		if(isscrewingtool(W))
			if(src.anchored)
				user.show_message("You unscrew [src] from the floor.")
			else
				user.show_message("You screw [src] to the floor.")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			src.anchored = !src.anchored
			return

		. = ..()

/obj/item/old_grenade/chicken
	name = "Chicken Grenade"
	desc = "It is set to detonate in 3 seconds."
	icon_state = "chicken"
	icon_state_armed = "chicken1"
	det_time = 3 SECONDS
	org_det_time = 3 SECONDS
	alt_det_time = 6 SECONDS
	is_syndicate = 1
	sound_armed = 'sound/weapons/armbomb.ogg'
	tooltip_flags = REBUILD_ALWAYS
	is_dangerous = TRUE
	/// eggs loaded into the grenade
	var/list/loaded_eggs = list()
	/// number of eggs to allow
	var/max_eggs = 5
	/// distance to spawn chickens in from center
	var/spawn_radius = 2

	get_desc()
		. += "Features advanced egg care technology to keep up to [max_eggs] eggs safely cradled and warm. This device is capable of hatching mature roosters that will fiercely defend their master, dispatching any nearby threats or bystanders to the best of their abilities."
		. += "It contains [length(loaded_eggs)] egg\s."

	disposing()
		for (var/obj/egg as anything in loaded_eggs)
			qdel(egg)
		loaded_eggs = null
		. = ..()

	detonate(mob/user)
		var/turf/T = ..()
		if (T)
			playsound(T, 'sound/weapons/flashbang.ogg', 25, 1)
			for (var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E as anything in loaded_eggs)
				var/turf/dest_turf = locate(clamp(0, world.maxx, (T.x + rand(-spawn_radius,spawn_radius))), clamp(0, world.maxy, (T.y + rand(-spawn_radius,spawn_radius))), T.z)
				if (!isfloor(dest_turf))
					dest_turf = T
				var/mob/living/critter/small_animal/ranch_base/chicken/C = new E.chicken_egg_props.rooster_type(dest_turf)
				C.grow_up()
				C.update_friendlist(user, FALSE)
				C.hyperaggressive = TRUE
				C.xp = 10001
				C.ai.interrupt()
				loaded_eggs -= E
				qdel(E)
		qdel(src)
		return

	attackby(obj/item/W, mob/user)
		. = ..()
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken))
			var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E = W
			if (E.chicken_egg_props.unique) //space time power safety
				user.show_text("[src] rejects [W]! Looks like it isn't compatible. Darn!", "red")
				return
			if (length(src.loaded_eggs) >= src.max_eggs)
				user.show_text("[src] rejects [W]! Looks you can't fit any more eggs in it. Darn!", "red")
				return
			loaded_eggs += W
			user.drop_item()
			W.set_loc(src)
			user.show_text("You stuff [W] into [src]!", "red")
		else if (istool(W, TOOL_WRENCHING))
			var/user_inputer = tgui_alert(user, "Eject all of the eggs?", "[src]", list("Yes", "No"))
			if (user_inputer == "Yes")
				var/turf/T = get_turf(src)
				for (var/obj/egg as anything in loaded_eggs)
					egg.set_loc(T)
				loaded_eggs.len = 0

	attack_self(mob/user)
		if (!length(loaded_eggs))
			user.show_text("It would be a waste to use it without any eggs!", "red")
			return
		. = ..()

/*
 * Chicken Carrier
 */
/obj/item/chicken_carrier
	name = "chicken carrier"
	desc = "A simple yet comfortable chicken carrier."
	icon = 'icons/obj/ranch/ranch_obj.dmi'
	icon_state = "chicken-carrier"
	burn_possible = FALSE
	w_class = W_CLASS_NORMAL
	var/mob/living/critter/small_animal/ranch_base/chicken/chicken = null
	layer = OBJ_LAYER + 0.2

	disposing()
		src.chicken?.set_loc(src.loc)
		src.chicken = null
		. = ..()

	update_icon()
		if (src.chicken)
			if(!isturf(src.loc)) //in someones UI
				src.chicken.plane = PLANE_HUD
				SPAWN(0) //bleh
					src.chicken.layer = src.layer - 0.1
			else
				src.chicken.plane = PLANE_DEFAULT
				src.chicken.layer = OBJ_LAYER + 0.1
				SPAWN(0) //also bleh
					src.layer = OBJ_LAYER + 0.2

	set_loc(newloc)
		. = ..()
		src.UpdateIcon()

	attack_self(mob/user)
		for (var/atom/movable/AM in src)
			AM.set_loc(get_turf(src))
		if (src.chicken)
			user.visible_message("[user] releases [src.chicken] from [src].", "You release [src.chicken] from [src].", "You hear the ruffling of feathers.")
			src.chicken.set_loc(user.loc)
			src.remove_chicken()
		else
			. = ..()

	proc/remove_chicken()
		src.vis_contents -= src.chicken
		src.chicken.plane = PLANE_DEFAULT
		src.chicken.layer = MOB_LAYER
		REMOVE_ATOM_PROPERTY(src.chicken, PROP_MOB_BREATHLESS, src.type)
		UnregisterSignal(src.chicken, COMSIG_PARENT_PRE_DISPOSING)
		src.chicken = null
		src.UpdateIcon()
	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (!target) return
		if (!src.chicken && istype(target, /mob/living/critter/small_animal/ranch_base/chicken))
			actions.start(new/datum/action/bar/icon/scoop_chicken(target, src), user)
		else if (src.chicken)
			boutput(user, SPAN_ALERT("[src] is already holding [src.chicken]!"))
		else
			boutput(user, SPAN_ALERT("[target] does not appear to be a chicken!"))

//for use with /obj/item/chicken_carrier
/datum/action/bar/icon/scoop_chicken
	duration = 10
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	icon = 'icons/obj/ranch/ranch_obj.dmi'
	icon_state = "chicken-carrier"
	var/obj/item/chicken_carrier/carrier = null
	var/mob/living/critter/small_animal/ranch_base/chicken/target = null

	New(Target, Carrier)
		src.carrier = Carrier
		src.target = Target
		..()

	onUpdate()
		..()
		if(!in_interact_range(owner, target) || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if(carrier.loc != owner)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(!in_interact_range(owner, target) || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if(carrier.loc != owner)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		carrier.chicken = target
		carrier.chicken.set_loc(carrier)
		owner.visible_message("[owner] gently scoops [carrier.chicken] into [carrier].", "You carefully scoop [carrier.chicken] into [carrier].", "You hear the ruffling of feathers.")
		carrier.vis_contents += carrier.chicken
		carrier.UpdateIcon()
		APPLY_ATOM_PROPERTY(target, PROP_MOB_BREATHLESS, carrier.type)
		carrier.RegisterSignal(carrier.chicken, COMSIG_PARENT_PRE_DISPOSING, /obj/item/chicken_carrier/proc/remove_chicken)
