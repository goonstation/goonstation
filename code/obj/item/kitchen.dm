/*
CONTAINS:

CUTLERY
MISC KITCHENWARE
TRAYS
*/

/obj/item/kitchen
	icon = 'icons/obj/kitchen.dmi'

/obj/item/kitchen/rollingpin
	name = "rolling pin"
	icon_state = "rolling_pin"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	force = 8
	throwforce = 10
	throw_speed = 2
	throw_range = 7
	w_class = W_CLASS_NORMAL
	desc = "A wooden tube, used to roll dough flat in order to make various edible objects. It's pretty sturdy."
	stamina_damage = 40
	stamina_cost = 15
	stamina_crit_chance = 2

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_ROD)

/obj/item/kitchen/rollingpin/light
	name = "light rolling pin"
	force = 4
	throwforce = 5
	desc = "A hollowed out tube, to save on weight, used to roll dough flat in order to make various edible objects."
	stamina_damage = 10
	stamina_cost = 10

/obj/item/kitchen/utensil
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	force = 5
	w_class = W_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	stamina_damage = 5
	stamina_cost = 10
	stamina_crit_chance = 15
	dir = NORTH
	var/rotatable = 1 //just in case future utensils are added that dont wanna be rotated
	var/snapped

	New()
		..()
		if(prob(60))
			src.pixel_y = rand(0, 4)
		BLOCK_SETUP(BLOCK_KNIFE)
		return

	attack_self(mob/user as mob)
		src.rotate()

	proc/rotate()
		if(rotatable)
			//set src in oview(1)
			src.set_dir(turn(src.dir, -90))
		return

	proc/break_utensil(mob/living/carbon/user as mob, var/spawnatloc = 0)
		var/location = get_turf(src)
		user.visible_message("<span style=\"color:red\">[src] breaks!</span>")
		playsound(user.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 30, 1)
		user.u_equip(src)
		var/replacethis
		switch(src.type)
			if(/obj/item/kitchen/utensil/spoon/plastic)
				replacethis = "spoon_plastic_"
			if(/obj/item/kitchen/utensil/fork/plastic)
				replacethis = "fork_plastic_"
			if(/obj/item/kitchen/utensil/knife/plastic)
				if(src.snapped)
					qdel(src)
					return
				replacethis = "knife_plastic_"
		var/utensil_color = replacetext(src.icon_state,replacethis,"")
		var/obj/item/kitchen/utensil/knife/plastic/k = new /obj/item/kitchen/utensil/knife/plastic
		k.icon_state = "snapped_[utensil_color]"
		k.snapped = TRUE
		k.name = "snapped [src.name]"
		if(spawnatloc)
			k.set_loc(location)
		else
			user.put_in_hand_or_drop(k)
		qdel(src)
		return

/obj/item/kitchen/utensil/spoon
	name = "spoon"
	desc = "A metal object that has a handle and ends in a small concave oval. Used to carry liquid objects from the container to the mouth."
	icon_state = "spoon"
	tool_flags = TOOL_SPOONING

	attack(mob/living/carbon/M, mob/living/carbon/user)
		if (user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span style='color:red'><b>[user]</b> fumbles [src] and jabs [himself_or_herself(user)].</span>")
			random_brute_damage(user, 5)
		if (!spoon_surgery(M,user))
			return ..()

	custom_suicide = TRUE
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		var/hisher = his_or_her(user)
		user.visible_message("<span style='color:red'><b>[user] jabs [src] straight through [hisher] eye and into [hisher] brain!</b></span>")
		blood_slash(user, 25)
		playsound(user.loc, src.hitsound, 50, 1)
		user.TakeDamage("head", 150, 0)
		user.updatehealth()
		return 1

/obj/item/kitchen/utensil/fork
	name = "fork"
	icon_state = "fork"
	tool_flags = TOOL_SAWING
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
	desc = "A multi-pronged metal object, used to pick up objects by piercing them. Helps with eating some foods."
	dir = NORTH
	throwforce = 7

	attack(mob/living/carbon/M, mob/living/carbon/user)
		if(user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> fumbles [src] and stabs [himself_or_herself(user)].</span>")
			random_brute_damage(user, 10)
			JOB_XP(user, "Clown", 1)
		if(!saw_surgery(M,user)) // it doesn't make sense, no. but hey, it's something.
			return ..()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if(!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] stabs [src] right into [his_or_her(user)] heart!</b></span>")
		blood_slash(user, 25)
		playsound(user.loc, src.hitsound, 50, 1)
		user.TakeDamage("chest", 150, 0)
		return 1

/obj/item/kitchen/utensil/knife
	name = "knife"
	icon_state = "knife"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	object_flags = NO_GHOSTCRITTER
	tool_flags = TOOL_CUTTING
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
	force = 7
	throwforce = 10
	w_class = W_CLASS_SMALL
	desc = "A long bit of metal that is sharpened on one side, used for cutting foods. Also useful for butchering dead animals. And live ones."
	dir = NORTH

	New()
		..()
		src.setItemSpecial(/datum/item_special/double)

	attack(mob/living/carbon/M, mob/living/carbon/user)
		if(user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> fumbles [src] and cuts [himself_or_herself(user)].</span>")
			random_brute_damage(user, 20)
			JOB_XP(user, "Clown", 1)
		if(!scalpel_surgery(M,user))
			return ..()

	custom_suicide = TRUE
	suicide(var/mob/user as mob)
		if(!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] slashes [his_or_her(user)] own throat with [src]!</b></span>")
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		return 1

/obj/item/kitchen/utensil/spoon/plastic
	name = "plastic spoon"
	icon_state = "spoon_plastic"
	desc = "A cheap plastic spoon, prone to breaking. Used to carry liquid objects from the container to the mouth."
	force = 1
	throwforce = 1
	w_class = W_CLASS_TINY

	New()
		..()
		src.icon_state = pick("spoon_plastic_pink","spoon_plastic_yellow","spoon_plastic_green","spoon_plastic_blue")

	attack(mob/living/carbon/M, mob/living/carbon/user)
		if (user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span style=\"color:red\"><b>[user]</b> fumbles [src] and jabs [himself_or_herself(user)].</span>")
			random_brute_damage(user, 5)
		if (prob(20))
			src.break_utensil(user)
			return
		if (!spoon_surgery(M,user))
			return ..()

	suicide(var/mob/user as mob)
		user.visible_message("<span style=\"color:red\"><b>[user] tries to jab [src] straight through [his_or_her(user)] eye and into [his_or_her(user)] brain!</b></span>")
		src.break_utensil(user)
		spawn(100)
			if (user)
				user.suiciding = 0
		return 1

/obj/item/kitchen/utensil/fork/plastic
	name = "plastic fork"
	icon_state = "fork_plastic_pink"
	desc = "A cheap plastic fork, prone to breaking. Helps with eating some foods."
	force = 1
	throwforce = 1
	w_class = W_CLASS_TINY

	New()
		..()
		src.icon_state = pick("fork_plastic_pink","fork_plastic_yellow","fork_plastic_green","fork_plastic_blue")

	attack(mob/living/carbon/M, mob/living/carbon/user)
		if (user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span style=\"color:red\"><b>[user]</b> fumbles [src] and stabs [himself_or_herself(user)].</span>")
			random_brute_damage(user, 5)
		if (prob(20))
			src.break_utensil(user)
			return
		if (!saw_surgery(M,user))
			return ..()

	suicide(var/mob/user as mob)
		user.visible_message("<span style=\"color:red\"><b>[user] tries to stab [src] right into [his_or_her(user)] heart!</b></span>")
		src.break_utensil(user)
		spawn(100)
			if (user)
				user.suiciding = 0
		return 1

/obj/item/kitchen/utensil/knife/plastic
	name = "plastic knife"
	icon_state = "knife_plastic"
	desc = "A long bit plastic that is serrated on one side, prone to breaking. It is used for cutting foods. Also useful for butchering dead animals, somehow."
	force = 1
	throwforce = 1
	w_class = W_CLASS_TINY

	New()
		..()
		src.icon_state = pick("knife_plastic_pink","knife_plastic_yellow","knife_plastic_green","knife_plastic_blue")

	attack(mob/living/carbon/M, mob/living/carbon/user)
		if(user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> fumbles [src] and cuts [himself_or_herself(user)].</span>")
			random_brute_damage(user, 5)
			JOB_XP(user, "Clown", 1)
		if(prob(20))
			src.break_utensil(user)
			return
		if(!scalpel_surgery(M,user))
			return ..()

	suicide(var/mob/user as mob)
		user.visible_message("<span class='alert'><b>[user] tries to slash [his_or_her(user)] own throat with [src]!</b></span>")
		src.break_utensil(user)
		SPAWN(10 SECONDS)
			if(user)
				user.suiciding = 0
		return 1

/obj/item/kitchen/plasticpackage
	name = "package of plastic silverware"
	desc = "These don't look very clean..."
	icon_state = "plasticpackage"
	w_class = W_CLASS_TINY
	var/list/messages = list("The packaging decides to not open at this time. How rude.", "The plastic is just too strong for your fumbly fingers!", "Almost open! Wait...Nevermind.", "Almost there.....")

	attack_self(mob/user as mob)
		if(prob(40))
			var/obj/item/kitchen/utensil/fork/plastic/f = new /obj/item/kitchen/utensil/fork/plastic
			var/obj/item/kitchen/utensil/knife/plastic/k = new /obj/item/kitchen/utensil/knife/plastic
			var/obj/item/kitchen/utensil/spoon/plastic/s = new /obj/item/kitchen/utensil/spoon/plastic
			f.icon_state = "fork_plastic_white"
			k.icon_state = "knife_plastic_white"
			s.icon_state = "spoon_plastic_white"
			f.set_loc(get_turf(user))
			k.set_loc(get_turf(user))
			s.set_loc(get_turf(user))
			user.u_equip(src)
			if(prob(30))
				user.show_text("<b>The plastic silverware goes EVERYWHERE!</b>","red")
				var/list/throw_targets = list()
				for (var/i=1, i<=3, i++)
					throw_targets += get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))
				f.throw_at(pick(throw_targets), 5, 1)
				if(prob(20))
					f.break_utensil(user, 1)
				k.throw_at(pick(throw_targets), 5, 1)
				if(prob(20))
					k.break_utensil(user, 1)
				s.throw_at(pick(throw_targets), 5, 1)
				if(prob(20))
					s.break_utensil(user, 1)
			qdel(src)
		else
			user.visible_message("<b>[user]</b> comically struggles to open the [src]","<b>[pick(messages)]</b>")

//chopsticks
/obj/item/kitchen/chopsticks_package
	name = "chopsticks"
	desc = "cheap disposable chopsticks!"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	icon_state = "chop_closed"
	item_state = "chop"
	w_class = W_CLASS_TINY

	attack_self(mob/user as mob)
		if(src.icon_state == "chop_closed")
			user.visible_message("<b>[user.name]</b> unwraps the chopsticks!")
			src.icon_state = "chop_stowed"
			src.name = "stowed chopsticks"
		else if(src.icon_state == "chop_stowed")
			user.u_equip(src)
			user.put_in_hand_or_drop(new /obj/item/kitchen/utensil/fork/chopsticks)
			qdel(src)

	attackby(obj/item/weapon, mob/user)
		if(istype(weapon,/obj/item/paper))
			if(src.icon_state == "chop_stowed")
				user.u_equip(weapon)
				qdel(weapon)
				src.icon_state = "chop_closed"
				src.name = "chopsticks"
			else
				boutput(user,"<span style=\"color:red\"><b>The chopstics already have a wrapper!</b></span>")

/obj/item/kitchen/utensil/fork/chopsticks
	name = "chopsticks"
	desc = "cheap disposable chopsticks!"
	icon_state = "chop_open"
	item_state = "chop"
	rotatable = 0
	tool_flags = 0

	attack_self(mob/user as mob)
		var/obj/item/kitchen/chopsticks_package/chop = new /obj/item/kitchen/chopsticks_package
		chop.icon_state = "chop_stowed"
		chop.name = "stowed chopsticks"
		user.u_equip(src)
		user.put_in_hand_or_drop(chop)
		qdel(src)

/obj/item/kitchen/utensil/knife/cleaver
	name = "meatcleaver"
	icon_state = "cleaver"
	item_state = "cleaver"
	desc = "An extremely sharp cleaver in a rectangular shape. Only for the professionals."
	force = 12
	throwforce = 12
	w_class = W_CLASS_NORMAL
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Blade_Small_Bloody.ogg'

	throw_impact(atom/A, datum/thrown_thing/thr)
		if(iscarbon(A))
			var/mob/living/carbon/C = A
			if(ismob(usr))
				A:lastattacker = usr
				A:lastattackertime = world.time
			random_brute_damage(C, 15, 1)
			take_bleeding_damage(C, null, 10, DAMAGE_CUT)
			playsound(src, 'sound/impact_sounds/Flesh_Stab_3.ogg', 40, 1)

/obj/item/kitchen/utensil/knife/bread
	name = "bread knife"
	icon_state = "knife-bread"
	item_state = "knife"
	desc = "A rather blunt knife; it still cuts things, but not very effectively."
	force = 3
	throwforce = 3

	suicide(var/mob/user as mob)
		user.visible_message("<span class='alert'><b>[user] drags [src] over [his_or_her(user)] own throat!</b></span>")
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		return 1

/obj/item/kitchen/utensil/knife/pizza_cutter
	name = "pizza cutter"
	icon_state = "pizzacutter"
	force = 3.0 // it's a bladed instrument, sure, but you're not going to do much damage with it
	throwforce = 3
	desc = "A cutting tool with a rotary circular blade, designed to cut pizza. You can probably use it as a knife with enough patience."
	tool_flags = TOOL_SAWING

	attack(mob/living/carbon/M, mob/living/carbon/user)
		if(user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> fumbles [src] and pinches [his_or_her(user)] fingers against the blade guard.</span>")
			random_brute_damage(user, 5)
			JOB_XP(user, "Clown", 1)
		if(!saw_surgery(M,user))
			return ..()

	suicide(var/mob/user as mob)
		user.visible_message("<span class='alert'><b>[user] rolls [src] repeatedly over [his_or_her(user)] own throat and slices it wide open!</b></span>")
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		return 1

/obj/item/kitchen/utensil/knife/pizza_cutter/traitor
	var/sharpener_mode = FALSE

	attack_self(mob/user as mob)
		sharpener_mode = !sharpener_mode
		boutput(user, "You flip a hidden switch in the pizza cutter to the [sharpener_mode ? "ON" : "OFF"] position.")

/obj/item/kitchen/food_box // I came in here just to make donut/egg boxes put the things in your hand when you take one out and I end up doing this instead, kill me. -haine
	name = "food box"
	desc = "A box that can hold food! Well, not this one, I mean. You shouldn't be able to see this one."
	icon = 'icons/obj/foodNdrink/food_related.dmi'
	icon_state = "donutbox"
	uses_multiple_icon_states = 1
	var/count = 6
	var/max_count = 6
	var/box_type = "donutbox"
	var/has_closed_state = 1
	var/contained_food = /obj/item/reagent_containers/food/snacks/donut/custom/random
	var/allowed_food = /obj/item/reagent_containers/food/snacks/donut
	var/contained_food_name = "donut"
	tooltip_flags = REBUILD_DIST

	donut_box
		name = "donut box"
		desc = "A box for containing and transporting \"dough-nuts\", a popular ethnic food."

	egg_box
		name = "egg carton"
		desc = "A carton that holds a bunch of eggs. What kind of eggs? What grade are they? Are the eggs from space? Space chicken eggs?"
		icon_state = "eggbox"
		count = 12
		max_count = 12
		box_type = "eggbox"
		contained_food = /obj/item/reagent_containers/food/snacks/ingredient/egg
		allowed_food = /obj/item/reagent_containers/food/snacks/ingredient/egg
		contained_food_name = "egg"

	lollipop
		name = "lollipop bowl"
		desc = "A little bowl of sugar-free lollipops, totally healthy in every way! They're medicinal, after all!"
		icon_state = "lpop8"
		count = 8
		max_count = 8
		box_type = "lpop"
		has_closed_state = 0
		contained_food = /obj/item/reagent_containers/food/snacks/lollipop/random_medical
		allowed_food = /obj/item/reagent_containers/food/snacks/lollipop
		contained_food_name = "lollipop"
		w_class = W_CLASS_SMALL

	New()
		..()
		SPAWN(1 SECOND)
			if(!ispath(src.contained_food))
				logTheThing(LOG_DEBUG, src, "has a non-path contained_food, \"[src.contained_food]\", and is being disposed of to prevent errors")
				qdel(src)
				return

	get_desc(dist)
		if(dist <= 1)
			. += "There's [(src.count > 0) ? src.count : "no" ] [src.contained_food_name][s_es(src.count)] in [src]."

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/tongs))
			return src.Attackhand(user)
		if(src.count >= src.max_count)
			boutput(user, "You can't fit anything else in [src]!")
			return
		else
			if(istype(W, src.allowed_food))
				user.drop_item()
				W.set_loc(src)
				src.count ++
				tooltip_rebuild = 1
				boutput(user, "You place [W] into [src].")
				src.update()
			else return ..()

	mouse_drop(mob/user as mob) // no I ain't even touchin this mess it can keep doin whatever it's doin
		// I finally came back and touched that mess because it was broke - Haine
		if(user == usr && !user.restrained() && !user.stat && (user.contents.Find(src) || in_interact_range(src, user)))
			if(!user.put_in_hand(src))
				return ..()

	attack_hand(mob/user)
		if((!istype(src.loc, /turf) && !user.is_in_hands(src)) || src.count == 0)
			..()
			return
		src.add_fingerprint(user)
		var/list/obj/item/reagent_containers/food/snacks/myFoodList = src.contents
		if(myFoodList.len >= 1)
			var/obj/item/reagent_containers/food/snacks/myFood = myFoodList[myFoodList.len]
			if(src.count >= 1)
				src.count--
				tooltip_rebuild = 1
			user.put_in_hand_or_drop(myFood)
			boutput(user, "You take [myFood] out of [src].")
		else
			if(src.count >= 1)
				src.count--
				tooltip_rebuild = 1
				var/obj/item/reagent_containers/food/snacks/newFood = new src.contained_food(src.loc)
				user.put_in_hand_or_drop(newFood)
				boutput(user, "You take [newFood] out of [src].")
		src.update()

	attack_self(mob/user as mob)
		if(!src.has_closed_state) return
		if(src.icon_state == "[src.box_type]")
			src.icon_state = "[src.box_type][src.count]"
			boutput(user, "You open [src].")
		else
			src.icon_state = "[src.box_type]"
			boutput(user, "You close [src].")

	proc/update()
		src.icon_state = "[src.box_type][src.count]"
		return

//=-=-=-=-=-=-=-=-=-=-=-=-
//TRAYS AND PLATES OH MY||
//=-=-=-=-=-=-=-=-=-=-=-=-

/obj/item/plate
	name = "plate"
	desc = "It's like a frisbee, but more dangerous!"
	icon = 'icons/obj/foodNdrink/food_related.dmi'
	icon_state = "plate"
	item_state = "zippo"
	throwforce = 3
	throw_speed = 3
	throw_range = 8
	force = 2
	rand_pos = 0
	pickup_sfx = 'sound/items/pickup_plate.ogg'
	event_handler_flags = NO_MOUSEDROP_QOL
	tooltip_flags = REBUILD_DIST
	/// Will separate what we can put into plates/pizza boxes or not
	var/is_plate = TRUE
	/// The maximum amount of food you can fit on this plate
	var/max_food = 2
	/// Helps to track amount of food items inside the box
	var/foods_inside = list()
	/// The amount the plate contents are thrown when this plate is dropped or thrown
	var/throw_dist = 3
	/// The sound which is played when you plate someone on help intent, tapping them
	var/hit_sound = 'sound/items/plate_tap.ogg'
	/// Can this be stacked with other stackable plates?
	var/stackable = TRUE
	/// Do we have a plate stacked on us?
	var/plate_stacked = FALSE

	New()
		..()
		BLOCK_SETUP(BLOCK_BOOK)

	/// Attempts to add an item to the plate, if there's space. Returns TRUE if food is successfully added.
	proc/add_contents(obj/item/food, mob/user, click_params)
		. = FALSE
		if (istype(food, /obj/item/plate))
			if (food == src)
				boutput(user, "<span class='alert'>You can't stack a [src] on itself!</span>")
				return
			if (src.plate_stacked)
				boutput(user, "<span class='alert'>You can't stack anything on [src], it already has a plate stacked on it!</span>")
				return
			var/obj/item/plate/not_really_food = food
			. = src.stackable && not_really_food.stackable // . is TRUE if we can stack the other plate on this plate, FALSE otherwise

		if (length(src.foods_inside) == max_food && src.is_plate)
			boutput(user, "<span class='alert'>There's no more space on \the [src]!</span>")
			return
			                                    // anything that isn't a plate may as well hold anything that fits the "plate"
		if (!food.edible && !. && src.is_plate) // plates aren't edible, so we check if we're adding a valid plate as well (. is TRUE if so)
			boutput(user, "<span class='alert'>That's not food, it doesn't belong on \the [src]!</span>")
			return
		if (food.w_class > W_CLASS_NORMAL && !.) // same logic as above, but to check if we can stack it
			boutput(user, "You try to think of a way to put [food] [src.is_plate ? "on" : "in"] \the [src] but it's not possible! It's too large!")
			return
		if (food in src.vis_contents)
			boutput(user, "That's already on the [src]!")
			return

		. = TRUE // If we got this far it's a valid plate content

		if (istype(food, /obj/item/plate/))
			src.plate_stacked = TRUE
		else
			src.foods_inside += food

		src.place_on(food, user, click_params) // this handles pixel positioning
		food.set_loc(src)
		src.vis_contents += food
		food.appearance_flags |= RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		food.vis_flags |= VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
		food.event_handler_flags |= NO_MOUSEDROP_QOL
		RegisterSignal(food, COMSIG_ATOM_MOUSEDROP, .proc/indirect_pickup)
		RegisterSignal(food, COMSIG_MOVABLE_SET_LOC, .proc/remove_contents)
		RegisterSignal(food, COMSIG_ATTACKHAND, .proc/remove_contents)
		src.UpdateIcon()
		boutput(user, "You put [food] [src.is_plate ? "on" : "in"] \the [src].")

	/// Removes a piece of food from the plate.
	proc/remove_contents(obj/item/food)
		MOVE_OUT_TO_TURF_SAFE(food, src)
		src.vis_contents -= food
		food.appearance_flags = initial(food.appearance_flags)
		food.vis_flags = initial(food.vis_flags)
		food.event_handler_flags = initial(food.event_handler_flags)
		UnregisterSignal(food, COMSIG_ATOM_MOUSEDROP)
		UnregisterSignal(food, COMSIG_MOVABLE_SET_LOC)
		UnregisterSignal(food, COMSIG_ATTACKHAND)
		if (istype(food, /obj/item/plate/))
			src.plate_stacked = FALSE
		else
			src.foods_inside -= food

		src.UpdateIcon()

	/// Used to pick the plate up by click dragging some food to you, in case the plate is covered by big foods
	proc/indirect_pickup(var/food, mob/user, atom/over_object)
		if (user == over_object && in_interact_range(src, user) && can_act(user))
			src.Attackhand(user)

	/// Called when you throw or smash the plate, throwing the contents everywhere
	proc/shit_goes_everywhere(depth = 1)
		if (length(src.contents))
			src.visible_message("<span class='alert'>Everything [src.is_plate ? "on" : "in"] \the [src] goes flying!</span>")
		for (var/atom/movable/food in src)
			food.set_loc(get_turf(src))
			if (istype(food, /obj/item/plate))
				var/obj/item/plate/not_food = food
				SPAWN(0.1 SECONDS) // This is rude but I want a small delay in smashing nested plates. More satisfying
					not_food?.shatter(depth)
			else
				food.throw_at(get_offset_target_turf(src.loc, rand(throw_dist)-rand(throw_dist), rand(throw_dist)-rand(throw_dist)), 5, 1)

	/// Used to smash the plate over someone's head
	proc/unique_attack_garbage_fuck(mob/M, mob/user)
		attack_particle(user,M)
		M.TakeDamageAccountArmor("head", force, 0, 0, DAMAGE_BLUNT)

		if(src.cant_drop == TRUE)
			if (istype(user, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = user
				H.sever_limb(H.hand == LEFT_HAND ? "l_arm" : "r_arm")
		else
			user.drop_item()
			src.set_loc(get_turf(M))

		src.shatter()

	/// The plate shatters into shards and tosses its contents around.
	proc/shatter(depth = 1)
		playsound(src, 'sound/impact_sounds/plate_break.ogg', 50, 1)
		var/turf/T = get_turf(src)
		if(log(2, depth) == round(log(2, depth)))
			for (var/i in 1 to 2)
				var/obj/O = new /obj/item/raw_material/shard/glass
				O.set_loc(T)
				if(src.material)
					O.setMaterial(copyMaterial(src.material))
				O.throw_at(get_offset_target_turf(T, rand(-4,4), rand(-4,4)), 7, 1)

		src.shit_goes_everywhere(depth + 1)

		qdel(src)

	throw_impact(atom/A, datum/thrown_thing/thr)
		..()
		src.shatter()

	attackby(obj/item/W, mob/user, params)
		if (!src.add_contents(W, user, params))
			..()

	MouseDrop_T(atom/movable/a, mob/user, src_location, over_location, src_control, over_control, params)
		. = ..()
		if (isitem(a) && can_reach(user, src) && can_reach(user, a))
			src.add_contents(a, user, params2list(params))

	attack_self(mob/user) // in case you only have one arm or you stacked too many MONSTERs or something just dump a random piece of food
		. = ..()
		if (length(src.contents))
			src.remove_contents(pick(src.contents))

	attack(mob/M, mob/user)
		if(user.a_intent == INTENT_HARM && src.is_plate)
			if(M == user)
				boutput(user, "<span class='alert'><B>You smash [src] over your own head!</b></span>")
			else
				M.visible_message("<span class='alert'><B>[user] smashes [src] over [M]'s head!</B></span>")
				logTheThing(LOG_COMBAT, user, "smashes [src] over [constructTarget(M,"combat")]'s head! ")

			unique_attack_garbage_fuck(M, user)

			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(istype(H.head, /obj/item/clothing/head/helmet))
					M.do_disorient(stamina_damage = 150, weakened = 0.1 SECONDS, disorient = 1 SECOND)
				else
					M.changeStatus("weakened", 1 SECONDS)
					M.force_laydown_standup()
			else if(ismobcritter(M))
				var/mob/living/critter/L = M
				var/has_helmet = FALSE
				for(var/datum/equipmentHolder/head/head in L.equipment)
					if(istype(head.item, /obj/item/clothing/head/helmet))
						has_helmet = TRUE
						break
				if(has_helmet)
					M.do_disorient(stamina_damage = 150, weakened = 0.1 SECONDS, disorient = 1 SECOND)
				else
					M.changeStatus("weakened", 1 SECONDS)
					M.force_laydown_standup()
			else //borgs, ghosts, whatever
				M.do_disorient(stamina_damage = 150, weakened = 0.1 SECONDS, disorient = 1 SECOND)
		else
			M.visible_message("<span class='alert'>[user] taps [M] over the head with [src].</span>")
			playsound(src, src.hit_sound, 30, 1)
			logTheThing(LOG_COMBAT, user, "taps [constructTarget(M,"combat")] over the head with [src].")

	dropped(mob/user)
		..()
		if(user.lying)
			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				if (!H.limbs.r_leg && !H.limbs.l_leg)
					return // fix for legless players shattering plates when stacking and pulling disposed plates from null space
			user.visible_message("<span class='alert'>[user] drops \the [src]!</span>")
			src.shatter()

	Crossed(atom/movable/AM)
		. = ..()
		if (ishuman(AM) && AM.throwing) // only humans have the power to smash plates with their bodies
			src.shatter()

/obj/item/plate/pizza_box
	name = "pizza box"
	desc = "Can hold wedding rings, clothes, weaponry... and sometimes pizza."
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "pizzabox"
	pickup_sfx = 0 // to avoid using plate SFX
	w_class = W_CLASS_BULKY
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "pizza_box"
	is_plate = FALSE
	var/open = FALSE

	add_contents(obj/item/food, mob/user, click_params) // Due to non-plates skipping some checks in the original add_contents() we'll have to do our own checks.

		if (!src.open && !istype(food, /obj/item/plate/))
			boutput(user, "<span class='alert'>You have to open \the [src] to put something in it, silly!</span>")
			return

		if (src.open && istype(food, /obj/item/plate/))
			boutput(user, "<span class='alert'>You can only put \the [food] on top of \the [src] when it's closed!")
			return

		if (length(src.foods_inside) >= src.max_food && !istype(food, src.type))
			boutput(user, "<span class='alert'>There's no more space in \the [src]!</span>")
			return

		. = ..()

	proc/toggle_box(mob/user)
		if (length(src.contents - src.foods_inside) > 0)
			boutput(user, "<span class='alert'>You have to remove the boxes on \the [src] before you can open it!")
			return


		if (src.open)
			if(user.bioHolder.HasEffect("clumsy") && prob(10))
				user.visible_message("<span class='alert'>[user] gets their finger caught in \the [src] when closing it. That thing is made out of cardboard! How is that possible?!</span>", \
				"<span class='alert'>You close \the [src] with your finger in it! Yeow!</span>")
				user.setStatus("stunned", 1 SECOND)
				user.TakeDamage((pick(TRUE, FALSE) ? "l_arm" : "r_arm"), 2, 0, 0, DAMAGE_BLUNT)
				bleed(user, 1, 1)
				playsound(user.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 80, 0)
				user.emote("scream") // Sounds specially painful when you get your finger stuck in a steel pizza box
			else
				playsound(user.loc, 'sound/machines/click.ogg', 30, 0)


			src.vis_contents = list()
			icon_state = "pizzabox"
			open = FALSE
			src.UpdateIcon()

		else
			if (isnull(user))
				icon_state = "pizzabox_open"
				src.open = TRUE
				playsound(src.loc, 'sound/machines/click.ogg', 30, 0)
				src.UpdateIcon()
				return

			if (user.bioHolder.HasEffect("clumsy") && prob(33))
				user.visible_message("<span class='alert'>[user] hits their head on the back of \the [src].</span>", \
				"<span class='alert'>You hit the back of \the [src] on your own head! Ouch!</span>")
				user.setStatus("stunned", 1 SECOND)
				user.TakeDamage("head", 2, 0, 0, DAMAGE_BLUNT)
				playsound(user.loc, 'sound/impact_sounds/Metal_Clang_1.ogg', 80, 0)

			else
				playsound(user.loc, 'sound/machines/click.ogg', 30, 0)

			icon_state = "pizzabox_open"
			src.open = TRUE
			src.vis_contents = src.contents
			src.UpdateIcon()

	shatter()
		shit_goes_everywhere()
		return // Cardboard boxes don't shatter like plates.

	shit_goes_everywhere()
		if (!src.open)
			toggle_box(null)
		..()

	attack_self(mob/user)
		toggle_box(user)
		return TRUE

/obj/item/plate/tray //this is the big boy!
	name = "serving tray"
	desc = "It's a big flat tray for serving food upon."
	icon = 'icons/obj/foodNdrink/food_related.dmi'
	icon_state = "tray"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "tray"
	throwforce = 3
	throw_speed = 3
	throw_range = 4
	force = 10
	w_class = W_CLASS_BULKY //no trays of loaves in a backpack for you
	max_food = 30 // will look like an absolute shitshow but sure
	throw_dist = 5
	two_handed = TRUE

	hit_sound = "step_lattice"
	stackable = FALSE

	var/tray_health = 5 //number of times u can smash with a tray + 1, get_desc values are hardcoded so please adjust them (i know im a bad coder)

	New()
		..()
		BLOCK_SETUP(BLOCK_ALL)

	proc/update_inhand_icon()
		var/weighted_num = round(length(contents) / 5) //6 inhand sprites, 30 possible foods on the tray
		if(!length(src.contents))
			src.item_state = "tray"
			return

		switch (weighted_num)
			if (0)
				src.item_state = "tray_1"
			if (1)
				src.item_state = "tray_2"
			if (2)
				src.item_state = "tray_3"
			if (3)
				src.item_state = "tray_4"
			if (4)
				src.item_state = "tray_5"
			if (5)
				src.item_state = "tray_6"
			else
				src.item_state = "tray_6"

	update_icon()
		..()
		src.update_inhand_icon()

	get_desc()
		. = ..()
		if((5 >= tray_health) && (tray_health > 3)) //im using hardcoded values im so garbage
			. += "\The [src] seems nice and sturdy!"
		else if((3 >= tray_health) && (tray_health > 1)) //im a trash human
			. += "\The [src] is getting pretty warped and flimsy."
		else if((1 >= tray_health) && (tray_health >=0))  //im a bad coder
			. += "\The [src] is about to break, be careful!"

	unique_attack_garbage_fuck(mob/M as mob, mob/user as mob)
		M.TakeDamageAccountArmor("head", src.force, 0, 0, DAMAGE_BLUNT)
		playsound(src, 'sound/weapons/trayhit.ogg', 25, 1)
		src.visible_message("\The [src] falls out of [user]'s hands due to the impact!")
		user.drop_item(src)

		if(tray_health == 0) //breakable trays because you flew too close to the sun, you tried to have unlimited damage AND stuns you fool, your hubris is too fat, too wide
			src.visible_message("<b>\The [src] shatters!</b>")
			playsound(src, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 70, 1)
			new /obj/item/scrap(src.loc)
			qdel(src)
			return
		tray_health--

	shatter() // don't
		return

//sushiiiiiii
/obj/item/kitchen/sushi_roller
	name = "rolling mat"
	desc = "a bamboo mat for rolling sushi"
	icon_state = "roller-0"
	w_class = W_CLASS_SMALL

	var/seaweed //0 or 1, storage variable for checking if there's a seaweed overlay without using resources pulling image files
	var/rice //same :)
	var/toppings = 0 //amount of toppings on the sushi roller (up to 3)
	var/rolling = 0 //the progress of the rolling (used for the rolling interactivity)
	var/rolled //the status of the sushi being fully rolled
	var/fish //override for unique fish overlay handling
	var/swedish //override for unique swedish fish oberlay handling

	var/fishflag
	var/skip

	var/list/toppingdata = list() //(food_color)
	var/obj/item/reagent_containers/food/snacks/sushi_roll/custom/roll//= new /obj/item/reagent_containers/food/snacks/sushi_roll/custom

	New()
		..()
		BLOCK_SETUP(BLOCK_BOOK)

	attackby(obj/item/W, mob/user)

		if(!(locate(/obj/item/reagent_containers/food/snacks/sushi_roll/custom) in src))
			var/obj/item/reagent_containers/food/snacks/sushi_roll/custom/roll_internal = new /obj/item/reagent_containers/food/snacks/sushi_roll/custom(src)
			roll = roll_internal

		if(istype(W,/obj/item/reagent_containers/food/snacks) && !src.rolling && !(src.toppings>=3))
			var/obj/item/reagent_containers/food/snacks/FOOD = W
			if(istype(FOOD,/obj/item/reagent_containers/food/snacks/ingredient/seaweed)) //seaweed overlay handling
				if(!src.seaweed)
					var/image/seaweed = new /image('icons/obj/kitchen.dmi',"seaweed-0")
					seaweed.layer = (src.layer+1) //i had to use explicit layering to get the dynamic rolling to render properly
					src.UpdateOverlays(seaweed,"seaweed")
					src.seaweed = 1
				user.u_equip(FOOD)
				qdel(FOOD)
			else if(istype(FOOD,/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice) && src.seaweed) //rice overlay (requires seaweed)
				if(!src.rice)
					var/image/rice = new /image('icons/obj/kitchen.dmi',"rice-0")
					rice.layer = (src.layer+2)
					src.UpdateOverlays(rice,"rice")
					src.rice = 1
				user.u_equip(FOOD)
				qdel(FOOD)
			else if(src.seaweed && src.rice) //if its not a seaweed sheet or sticky rice, and theres seaweed and rice on the sheet
				src.toppings++
				if(istype(FOOD,/obj/item/reagent_containers/food/snacks/swedish_fish)) //setting overrides
					src.swedish = 1
					skip = "ALL"
				var/ingredienttype
				if(istype(FOOD,/obj/item/reagent_containers/food/snacks/ingredient/meat)) //setting ingredient type for the roller overlays
					if(istype(FOOD,/obj/item/reagent_containers/food/snacks/ingredient/meat/fish))
						if(!fishflag)
							if(istype(FOOD,/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/small))
								fishflag = "fillet-white"
							else
								fishflag = FOOD.icon_state
							skip = src.toppings
					ingredienttype="meat"
				else
					ingredienttype="nonmeat"
				var/image/foodoverlay = new /image('icons/obj/kitchen.dmi',"[ingredienttype]-[src.toppings]") //setting up an overlay image
				foodoverlay.color = FOOD.food_color
				foodoverlay.layer = (src.layer+3)
				toppingdata.Add(FOOD.food_color)
				FOOD.reagents?.trans_to(roll,FOOD.reagents.total_volume)
				for(var/food_effect in FOOD.food_effects)
					if(food_effect in roll.food_effects)
						continue
					roll.food_effects += food_effect
					roll.quality += FOOD.quality
				src.UpdateOverlays(foodoverlay,"topping-[src.toppings]")
				user.u_equip(FOOD)
				qdel(FOOD)
			else if(!src.seaweed)
				boutput(user,"<span class='alert'>You need a seaweed sheet on the roller first, silly.</span>")
			else
				boutput(user,"<span class='alert'>You need sticky rice!</span>")
		else
			..()

	attack_hand(mob/user)
		if(src.seaweed && src.rice)
			if(!src.toppings) //dependent on having toppings (empty sushi caused a lot of problems)
				..()
				return
			if(!src.rolled) //handling the rolling interactivity, basically switching overlays until eventually the item's overlays are wiped...
				src.rolling++
				if(src.toppings && (src.rolling<3))
					var/image/seaweed = new /image('icons/obj/kitchen.dmi',"seaweed-[src.rolling]")
					var/image/rice = new /image('icons/obj/kitchen.dmi',"rice-[src.rolling]")
					seaweed.layer = (src.layer+1)
					rice.layer = (src.layer+2)
					src.UpdateOverlays(seaweed,"seaweed")
					src.UpdateOverlays(rice,"rice")
					src.icon_state = "roller-[src.rolling]"
					for(var/i=1,i<=src.toppings,i++)
						if(src.GetOverlayImage("topping-[i]"))
							src.ClearSpecificOverlays("topping-[i]")
							break
					return
				if(src.rolling == 3)
					src.ClearAllOverlays()
					src.icon_state = "roller-[src.rolling]"
					return
				if(src.rolling > 3)
					src.rolling -= 2
					src.rolled = 1
					src.icon_state = "roller-[src.rolling]"
					src.UpdateOverlays(new /image('icons/obj/kitchen.dmi',"roller_roll"),"roll")
					for(var/i=1,i<=src.toppings,i++)
						var/image/rolltopping = new /image('icons/obj/kitchen.dmi',"roll_topping-[i]")
						rolltopping.color = toppingdata[i]
						src.UpdateOverlays(rolltopping,"roll_topping-[i]")
					src.rolling = 0
			else if(src.rolling == 0) //and out pops a sushi roll!
				src.icon_state = "roller-[src.rolling]"
				src.seaweed = 0
				src.rice = 0
				src.rolled = 0
				src.ClearAllOverlays()
				if(src.swedish) //setting actual overrides for sushi roll
					roll.UpdateOverlays(new /image('icons/obj/foodNdrink/food_sushi.dmi',"fisk"),"fisk")
				else if(src.fishflag) //fish overlays (there's two states, one for if the fish is the only ingredient, and one if there's other ingredients)
					roll.UpdateOverlays(new /image('icons/obj/foodNdrink/food_sushi.dmi',"[fishflag]-[src.toppings == 1 ? "s" : "m"]"),"[fishflag]")
				if(skip != "ALL") //in case of swedish fisk, that is the only overlay rendered, so everything else is skipped
					var/toppingoverlay = 0
					for(var/t,t<=toppingdata.len,t++)
						if(toppingdata[t] && (skip != t)) //its not the best way to do this, but im not sure if theres a decent way of dynamically referencing variables without a bunch of weird string conversions
							toppingoverlay++
							var/image/overlay = new /image('icons/obj/foodNdrink/food_sushi.dmi',"topping-[toppingoverlay]")
							overlay.color = toppingdata[t]
							roll.UpdateOverlays(overlay,"topping-[toppingoverlay]")
				if(src.toppings)
					roll.quality = (roll.quality/src.toppings)+1
				else
					roll.quality = 1
				user.put_in_hand_or_drop(roll)
				src.toppings = 0
				src.swedish = 0
				src.fish = 0
				src.toppingdata = list()
				src.fishflag = null
				src.skip = null
				src.roll = null
		else
			..()

//kitchen island
/obj/surgery_tray/kitchen_island
	name = "kitchen island"
	desc = "a table! with WHEELS!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "kitchen_island"

//kitchen island
/obj/surgery_tray/kitchen_island
	name = "kitchen island"
	desc = "a table! with wheels!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "kitchen_island"

/obj/item/fish/random // used by the Wholetuna Cordata plant
	New()
		..()
		SPAWN(0)
			var/fish = pick(/obj/item/fish/salmon,/obj/item/fish/carp,/obj/item/fish/bass)
			new fish(get_turf(src))
			qdel(src)

/obj/item/tongs
	name = "tongs"
	desc = "A device that allows you to use food items as if they were used in-hand, or get food items out of food boxes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "tongs"

	// used in attackby procs of /obj/item/reagent_containers/food/snacks and /obj/item/kitchen/food_box
