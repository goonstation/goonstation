/obj/item/reagent_containers/food/snacks/ingredient/pizza_base
	name = "pizza dough"
	desc = "A good start to a delicious pizza."
	icon_state = "pizzabase"
	initial_volume = 50
	custom_food = FALSE
	var/image/sauce = null
	var/sauce_color = "#d24300"
	var/image/cheese = null
	var/cheesy = 0
	flags = FPRINT | TABLEPASS | OPENCONTAINER | SUPPRESSATTACK
	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE | LONG_GLIDE
	w_class = W_CLASS_NORMAL

	var/max_topping_size = W_CLASS_SMALL
	/// How much w_class fits on the pizza
	var/max_topping_space = 10
	/// How much w_class remains
	var/topping_space_left = 10
	/// How much to scale toppings by
	var/topping_scale = 0.5
	/// how many times this dough was flourished
	var/fancy_spins = 0

	get_desc(dist, mob/user)
		if(dist > 2)
			return
		if(src.reagents?.total_volume)
			var/datum/color/c = src.reagents.get_average_color()
			var/nearest_color_text = get_nearest_color(c)
			. = "The sauce is [nearest_color_text]."
			. += src.reagents.get_exact_description(user)
		else
			. = "There is no sauce."

	on_reagent_change(add)
		. = ..()
		src.sauce_color = src.reagents.get_average_rgb()
		UpdateIcon()

	update_icon()
		if(src.reagents.total_volume)
			src.sauce = SafeGetOverlayImage("sauce", 'icons/obj/foodNdrink/food_ingredient.dmi', "pizzasauce")
			sauce.appearance_flags = RESET_COLOR | PIXEL_SCALE
			sauce.color = src.sauce_color
		else
			src.sauce = null
		if(src.cheesy)
			src.cheese = SafeGetOverlayImage("cheese", 'icons/obj/foodNdrink/food_ingredient.dmi', "pizzacheese[src.cheesy]")
		UpdateOverlays(src.sauce, "sauce", TRUE)
		UpdateOverlays(src.cheese, "cheese", TRUE)

	attackby(obj/item/W, mob/user, params)
		if (!src.custom_food && (iscuttingtool(W) || issawingtool(W) || issnippingtool(W))) // make tortillas if untouched
			boutput(user, SPAN_NOTICE("You cut [src] into smaller pieces."))
			for(var/i = 1, i <= 3, i++)
				new /obj/item/reagent_containers/food/snacks/ingredient/tortilla(get_turf(src))
			qdel(src)
			if (prob(25))
				JOB_XP(user, "Chef", 1)
			return

		if ((src.reagents.maximum_volume != src.reagents.total_volume) && (istype(W, /obj/item/reagent_containers/food/snacks/condiment/) || W.is_open_container()) && W.reagents.total_volume) // add sauce from open reagent container
			src.custom_food = TRUE
			return ..()
		else if (!src.cheesy)
			if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/cheese))
				src.custom_food = TRUE
				if (prob(25))
					JOB_XP(user, "Chef", 1)
				src.cheesy = 1
				boutput(user, SPAN_NOTICE("You add \the [W] to \the [src]."))
				user.u_equip(W)
				qdel(W)
				src.UpdateIcon()
				return ..()
			else if (istype(W, /obj/item/reagent_containers/food/snacks/cheesewheel))
				src.custom_food = TRUE
				JOB_XP(user, "Chef", 1)
				src.cheesy = 2
				boutput(user, SPAN_NOTICE("You add \the [W] to \the [src]. Holy shit!"))
				user.u_equip(W)
				qdel(W)
				src.UpdateIcon()
				return ..()
		if (W.w_class <= src.max_topping_size && W.w_class <= src.topping_space_left)
			src.add_topping(W, user, params)
		return ..()

	/// Used to pick the pizza up by click dragging some food to you, in case the pizza is covered in toppings
	proc/indirect_pickup(var/topping, mob/user, atom/over_object)
		if (user == over_object && in_interact_range(src, user) && can_act(user))
			src.Attackhand(user)

	/// Adds a topping to the pizza
	proc/add_topping(var/obj/item/topping, var/mob/user, var/list/params = null)
		if(src.place_on(topping, user, params))
			boutput(user, SPAN_NOTICE("You add \the [topping] to \the [src]."))
			src.custom_food = TRUE
			src.topping_space_left -= topping.w_class
			topping.set_loc(src)
			topping.transform = matrix(matrix(src.transform, src.topping_scale, src.topping_scale, MATRIX_SCALE), rand(-180,180), MATRIX_ROTATE)
			topping.appearance_flags |= RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			topping.vis_flags |= VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
			topping.event_handler_flags |= NO_MOUSEDROP_QOL
			src.vis_contents += topping
			RegisterSignal(topping, COMSIG_ATOM_MOUSEDROP, PROC_REF(indirect_pickup))
			RegisterSignal(topping, COMSIG_ATTACKHAND, PROC_REF(remove_topping))
			src.UpdateIcon()
		else
			boutput(user, SPAN_ALERT("You can't do that, [topping] is attached to you!"))

	/// Removes a topping from the pizza.
	proc/remove_topping(var/obj/item/topping)
		MOVE_OUT_TO_TURF_SAFE(topping, src)
		src.vis_contents -= topping
		src.topping_space_left += topping.w_class
		topping.transform = initial(topping.transform)
		topping.appearance_flags = initial(topping.appearance_flags)
		topping.vis_flags = initial(topping.vis_flags)
		topping.event_handler_flags = initial(topping.event_handler_flags)
		UnregisterSignal(topping, COMSIG_ATOM_MOUSEDROP)
		UnregisterSignal(topping, COMSIG_ATTACKHAND)

		src.UpdateIcon()

	attack_self(var/mob/user as mob)
		if(user.traitHolder.hasTrait("training_chef") || prob(60))
			src.custom_food = TRUE
			user.visible_message(SPAN_NOTICE("[user] [pick("expertly", "acrobatically", "deftly", "masterfully")] spins \the [src]."), group = "pizzaspin")
			src.fancy_spins++
			if(src.fancy_spins == 10)
				boutput(user,SPAN_ALERT("\The [src] is spun to perfection."))
				if (prob(50))
					JOB_XP(user, "Chef", 1)
		else
			user.visible_message(SPAN_ALERT("[user] [pick("clumsily", "catastrophically", "shamefully")] fumbles \the [src]."), group = "pizzaspin")
			src.fancy_spins = 0
			user.u_equip(src)
			src.set_loc(user.loc)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (user == target)
			boutput(user, SPAN_ALERT("You need to at least bake it, you greedy beast!"))
			user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
			return
		else
			user.visible_message(SPAN_ALERT("<b>[user]</b> futilely attempts to shove [src] into [target]'s mouth!"))
			return

	Eat(mob/M as mob, mob/user, by_matter_eater = TRUE)
		if(!by_matter_eater)
			return 0
		var/obj/item/reagent_containers/food/snacks/pizza/unbaked_pizza = src.bake_pizza(TRUE)
		return unbaked_pizza.Eat(M, user, TRUE)


	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if (temperature >= T0C+3200) // syndicate zippos and raging plasmafires, for laughs
			src.bake_pizza()
		. = ..()

	proc/bake_pizza(var/matter_eater_fake_bake = FALSE)
		var/obj/item/reagent_containers/food/snacks/pizza/baked_pizza = new(src.loc)

		if(matter_eater_fake_bake)
			baked_pizza.icon = 'icons/obj/foodNdrink/food_ingredient.dmi'
			baked_pizza.icon_state = "pizzabase"
			baked_pizza.reagents.add_reagent("salmonella",20)

		var/list/temp_food_effects = list("food_deep_burp" = 2)

		var/nearest_color_text
		if(src.reagents.total_volume)
			baked_pizza.UpdateOverlays(src.sauce, "sauce")
			var/datum/color/c = src.reagents.get_average_color()
			nearest_color_text = get_nearest_color(c)
			baked_pizza.name = "pizza marinara"
			baked_pizza.desc = "A delicious cheeseless pizza marinara!<br>The sauce is [nearest_color_text]."

			baked_pizza.reagents.maximum_volume += src.reagents.total_volume
			src.reagents.trans_to(baked_pizza, 50)
		else
			baked_pizza.name = "none pizza"

		if (src.cheesy == 1)
			baked_pizza.UpdateOverlays(src.cheese, "cheese")
			baked_pizza.reagents.maximum_volume += 5
			baked_pizza.reagents.add_reagent("cheese", 5)
			temp_food_effects["food_hp_up"] = 2
			baked_pizza.name = "cheese pizza"
			baked_pizza.desc = "A delicious cheesy pizza!<br>The sauce is [nearest_color_text]."
		else if (src.cheesy > 1)
			baked_pizza.UpdateOverlays(src.cheese, "cheese")
			baked_pizza.reagents.maximum_volume += 40
			baked_pizza.reagents.add_reagent("cheese", 40)
			temp_food_effects["food_hp_up_big"] = 2
			baked_pizza.name = "deep dish pizza"
			baked_pizza.desc = "A delicious deep dish pizza piled high with cheese!<br>The sauce is [nearest_color_text]."

		var/topping_iterator = 0
		var/topping_total = length(src.contents)
		if(topping_total)
			for (var/obj/item/topping in src.contents)
				var/obj/item/reagent_containers/food/snacks/food = topping
				var/topping_name_truncated = copytext(topping.name, 1, 128)
				if(!topping_iterator)
					baked_pizza.name += " with [copytext(topping.name, 1, 64)]"
					baked_pizza.desc += "<br>It is topped with "
				topping_iterator++
				if(topping_iterator == topping_total)
					if(topping_total > 1)
						baked_pizza.desc += "and \an [topping_name_truncated]."
					else
						baked_pizza.desc += "\an [topping_name_truncated]."
				else if (topping_total != 2)
					baked_pizza.desc += "\an [topping_name_truncated], "
				else
					baked_pizza.desc += "\an [topping_name_truncated] "

				if (istype(food))
					for (var/effect in food.food_effects)
						if (temp_food_effects[effect])
							temp_food_effects[effect]++
						else
							temp_food_effects[effect] = 1
					baked_pizza.heal_amt += food.heal_amt / 12
					baked_pizza.fill_amt += food.fill_amt
				else
					baked_pizza.heal_amt -= topping.w_class / 18
					baked_pizza.fill_amt += topping.w_class / 2

				var/image/topping_image = SafeGetOverlayImage("topping_\ref[topping]", topping.icon, topping.icon_state, pixel_x = topping.pixel_x, pixel_y = topping.pixel_y)
				topping_image.transform = topping.transform
				topping_image.appearance_flags = topping.appearance_flags
				baked_pizza.UpdateOverlays(topping_image, "topping_\ref[topping]")

				if (topping.reagents) // no more than 100 units per topping
					baked_pizza.reagents.maximum_volume += min(topping.reagents.total_volume, 100)
					topping.reagents.trans_to(baked_pizza, 100)
				qdel(topping)

		if(length(temp_food_effects) > 4)
			sortList(temp_food_effects, cmp = /proc/cmp_numeric_dsc, associative = 1)

		for (var/i in 1 to min(4,length(temp_food_effects))) // the four most represented effects are chosen
			baked_pizza.food_effects += temp_food_effects[i]

		if (src.fancy_spins >= 10)
			baked_pizza.heal_amt *= 1.1
			baked_pizza.name = "fancy " + baked_pizza.name

		if(src.material)
			baked_pizza.setMaterial(src.material)
			baked_pizza.quality = 1
			baked_pizza.mat_changeappearance = 1
			baked_pizza.mat_changename = 1
			baked_pizza.mat_changedesc = 1
		qdel(src)

		return baked_pizza

/obj/item/reagent_containers/food/snacks/pizza
	name = "pizza"
	desc = "A sauceless, cheeseless pizza."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "pizzacrust"
	fill_amt = 1
	bites_left = 12
	heal_amt = 3
	w_class = W_CLASS_NORMAL
	slice_amount = 6
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/pizzaslice
	initial_volume = 60 // 40 units will be available to stuff the crust
	initial_reagents = list("bread" = 20)
	mat_changeappearance = 0
	mat_changename = 0
	mat_changedesc = 0
	var/sharpened = FALSE

	custom_food = 0

	food_effects = list()

	New()
		..()
		src.setMaterial(getMaterial("pizza"), appearance = 0, setname = 0)
		// this is a funny workaround for the fact that any pizza not made by cooking will have quality reset to 0 from the above call
		src.quality = 1

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/kitchen/utensil/knife/pizza_cutter/traitor))
			var/obj/item/kitchen/utensil/knife/pizza_cutter/traitor/cutter = W
			if (cutter.sharpener_mode)
				src.sharpened = TRUE
		..()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (user == target)
			boutput(user, SPAN_ALERT("You can't just cram that in your mouth, you greedy beast!"))
			user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
			return
		else
			user.visible_message(SPAN_ALERT("<b>[user]</b> futilely attempts to shove [src] into [target]'s mouth!"))
			return

	attack_self(mob/user as mob)
		attack(user, user)

	throw_impact(atom/A)
		if (!sharpened || isnull(A))
			..()

	process_sliced_products(obj/item/reagent_containers/food/slice, amount_to_transfer)
		var/obj/item/reagent_containers/food/snacks/pizzaslice/pizza_slice = slice
		pizza_slice.heal_amt = src.heal_amt
		pizza_slice.food_effects = src.food_effects
		pizza_slice.reagents.maximum_volume = max(10, amount_to_transfer)
		pizza_slice.name = "slice of " + src.name
		pizza_slice.desc = src.desc
		pizza_slice.sharpened = src.sharpened
		..()

/obj/item/reagent_containers/food/snacks/pizzaslice
	name = "pizza slice"
	desc = "A slice of cheeseless, sauceless pizza."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "pslice"
	fill_amt = 1
	bites_left = 2
	heal_amt = 1
	initial_reagents = 10
	w_class = W_CLASS_TINY
	var/sharpened = FALSE

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (src.sharpened)
			boutput(target, SPAN_ALERT("The pizza was too pointy!"))
			take_bleeding_damage(target, user, 50, DAMAGE_CUT)
		..()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/kitchen/utensil/knife/pizza_cutter/traitor))
			var/obj/item/kitchen/utensil/knife/pizza_cutter/traitor/cutter = W
			if (cutter.sharpener_mode)
				src.sharpened = TRUE
		..()

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if(src.sharpened)
			if (iscarbon(hit_atom))
				var/mob/living/carbon/human/H = hit_atom
				H.implant.Add(src)
				src.visible_message(SPAN_ALERT("[src] gets embedded in [H]!"))
				playsound(src.loc, 'sound/impact_sounds/Flesh_Cut_1.ogg', 100, 1)
				H.changeStatus("weakened", 2 SECONDS)
				src.set_loc(H)
				src.transfer_all_reagents(H)
			random_brute_damage(hit_atom, 11)
			take_bleeding_damage(hit_atom, null, 25, DAMAGE_STAB)
		. = ..()

/obj/item/reagent_containers/food/snacks/pizza/pepperoni
	name = "pepperoni pizza"
	desc = "A typical pepperoni pizza."
	initial_volume = 80
	initial_reagents = list("juice_tomato" = 50, "cheese" = 10, "pepperoni" = 20)

/obj/item/reagent_containers/food/snacks/pizza/meatball
	name = "meatball pizza"
	desc = "A typical meatball pizza."
	initial_volume = 80
	initial_reagents = list("juice_tomato" = 50, "cheese" = 10, "beff" = 20)

/obj/item/reagent_containers/food/snacks/pizza/mushroom
	name = "mushroom pizza"
	desc = "A typical mushroom pizza."
	initial_volume = 80
	initial_reagents = list("juice_tomato" = 50, "cheese" = 10, "space_fungus" = 20)

/obj/item/reagent_containers/food/snacks/pizza/xmas
	name = "\improper Spacemas pizza"
	desc = "A traditional Spacemas pizza! It has ham, mashed potatoes, gingerbread and candy canes on it, with eggnog sauce and a fruitcake crust! Yum!"

/obj/item/reagent_containers/food/snacks/pizza/pineapple
	name = "pineapple pizza"
	desc = "A typical pineapple pizza. Some people have strong opinions about it."
	contraband = 2

/obj/item/reagent_containers/food/snacks/pizza/fresh
    name = "fresh pizza"
    desc = "A cheesy pizza pie with thick tomato sauce."
    icon_state = "cheesy"

/obj/item/reagent_containers/food/snacks/pizza/ball
    name = "fresh meatball pizza"
    desc = "A fresh pizza pie topped with succulent meatballs."
    icon_state = "meatball"

/obj/item/reagent_containers/food/snacks/pizza/pepper
    name = "fresh pepperoni pizza"
    desc = "A cheesy pizza pie toped with bright red sizzling pepperoni slices."
    icon_state = "peper"

/obj/item/reagent_containers/food/snacks/pizza/shroom
    name = "fresh mushroom pizza"
    desc = "A pizza pie toped fresh picked mushrooms."
    icon_state = "shroom"

/obj/item/reagent_containers/food/snacks/pizza/bad
    name = "soft serve cheese pizza"
    desc = "A pizza shipped from god knows where straight to cargo."
    icon_state = "pizza-b"

/obj/item/reagent_containers/food/snacks/pizza/pepperbad
    name = "soft serve pepperoni pizza"
    desc = "A pizza shipped from god knows where straight to cargo."
    icon_state = "pizza_m"

/obj/item/reagent_containers/food/snacks/pizza/mushbad
    name = "soft serve mushroom pizza"
    desc = "A pizza shipped from god knows where straight to cargo."
    icon_state = "pizza_v"
