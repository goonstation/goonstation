/// COOKING RECODE ///
var/list/oven_recipes = list()

TYPEINFO(/obj/submachine/chef_oven)
	mats = 18

/obj/submachine/chef_oven
	name = "oven"
	desc = "A multi-cooking unit featuring a hob, grill, oven and more."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "oven_off"
	anchored = ANCHORED
	density = 1
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	flags = NOSPLASH
	object_flags = NO_GHOSTCRITTER
	var/emagged = 0
	var/working = 0
	var/time = 5
	var/heat = "Low"
	var/list/recipes = null
	//var/allowed = list(/obj/item/reagent_containers/food/, /obj/item/parts/robot_parts/head, /obj/item/clothing/head/butt, /obj/item/organ/brain/obj/item)
	var/allowed = list(/obj/item)
	var/static/tmp/recipe_html = null // see: create_oven_recipe_html()

	var/list/possible_recipe_icons = list()
	var/list/possible_recipe_names = list()
	var/output_icon
	var/output_name
	var/cooktime

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!emagged)
			emagged = 1
			if (user)
				boutput(user, SPAN_NOTICE("[src] produces a strange grinding noise."))
			return 1
		else
			return 0

	attack_hand(var/mob/user)
		if (isghostdrone(user))
			boutput(user, SPAN_ALERT("\The [src] refuses to interface with you, as you are not a properly trained chef!"))
			return
		src.ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "Oven")
			ui.open()

	ui_data(mob/user)
		src.get_recipes()
		. = list(
			"time" = src.time,
			"heat" = src.heat,
			"cooking" = src.working,
			"content_icons" = src.get_content_icons(),
			"content_names" = src.get_content_names(),
			"recipe_icons" = src.possible_recipe_icons,
			"recipe_names" = src.possible_recipe_names,
			"output_icon" = src.output_icon,
			"output_name" = src.output_name,
			"cook_time" = src.cooktime
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		. = TRUE
		switch (action)
			if ("set_time")
				src.time = params["time"]
			if ("set_heat")
				src.heat = params["heat"]
			if ("start")
				src.cook_food()
			if ("eject_all")
				for (var/obj/item/I in src.contents)
					I.set_loc(src.loc)
			if ("eject")
				var/obj/item/thing_to_eject = src.contents[params["ejected_item"]]
				if (thing_to_eject)
					thing_to_eject.set_loc(src.loc)
			if ("open_recipe_book")
				usr.Browse(recipe_html, "window=recipes;size=500x700")

	proc/get_content_icons()
		if (!length(src.contents))
			return
		var/list/contained = list()
		for (var/obj/item/I in src.contents)
			contained += icon2base64(getFlatIcon(I), "chef_oven-\ref[src]")
		return contained

	proc/get_content_names()
		if (!length(src.contents))
			return
		var/list/contained = list()
		for (var/obj/item/I in src.contents)
			contained += I.name
		return contained

	proc/get_recipes()
		src.possible_recipe_icons = list()
		src.possible_recipe_names = list()
		src.output_icon = null
		src.output_name = null
		src.cooktime = null

		var/datum/cookingrecipe/possible = src.OVEN_get_valid_recipe()
		if (!possible)
			return

		for(var/I in possible.ingredients)
			var/atom/item_path = I
			src.possible_recipe_icons += icon2base64(icon(initial(item_path.icon), initial(item_path.icon_state)), "chef_oven-\ref[src]")
			src.possible_recipe_names += "[initial(item_path.name)][possible.ingredients[I] > 1 ? " x[possible.ingredients[I]]" : ""]"

		if (ispath(possible.output))
			var/atom/item_path = possible.output
			src.output_icon = icon2base64(icon(initial(item_path.icon), initial(item_path.icon_state)), "chef_oven-\ref[src]")
			src.output_name = initial(item_path.name)

		if (possible.cookbonus < 10)
			src.cooktime = "[possible.cookbonus] seconds low"
		else
			src.cooktime = "[floor(possible.cookbonus/2)] seconds high"

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	New()
		..()
		// Note - The order these are placed in matters! Put more complex recipes before simpler ones, or the way the
		//        oven checks through the recipe list will make it pick the simple recipe and finish the cooking proc
		//        before it even gets to the more complex recipe, wasting the ingredients that would have gone to the
		//        more complicated one and pissing off the chef by giving something different than what he wanted!

		src.recipes = oven_recipes
		if (!src.recipes)
			src.recipes = list()

		if (!src.recipes.len)
			src.recipes += new /datum/cookingrecipe/oven/haggass(src)
			src.recipes += new /datum/cookingrecipe/oven/haggis(src)
			src.recipes += new /datum/cookingrecipe/oven/scotch_egg(src)
			src.recipes += new /datum/cookingrecipe/oven/omelette_bee(src)
			src.recipes += new /datum/cookingrecipe/oven/omelette(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/monster(src)
			src.recipes += new /datum/cookingrecipe/oven/c_butty(src)
			src.recipes += new /datum/cookingrecipe/oven/scarewich_h(src)
			src.recipes += new /datum/cookingrecipe/oven/scarewich_p_h(src)
			src.recipes += new /datum/cookingrecipe/oven/scarewich_p(src)
			src.recipes += new /datum/cookingrecipe/oven/scarewich_s(src)
			src.recipes += new /datum/cookingrecipe/oven/scarewich_m(src)
			src.recipes += new /datum/cookingrecipe/oven/scarewich_c(src)
			src.recipes += new /datum/cookingrecipe/oven/scarewich_blt(src)
			src.recipes += new /datum/cookingrecipe/oven/elviswich_m_h(src)
			src.recipes += new /datum/cookingrecipe/oven/elviswich_m_m(src)
			src.recipes += new /datum/cookingrecipe/oven/elviswich_m_s(src)
			src.recipes += new /datum/cookingrecipe/oven/elviswich_c(src)
			src.recipes += new /datum/cookingrecipe/oven/elviswich_p_h(src)
			src.recipes += new /datum/cookingrecipe/oven/elviswich_p(src)
			src.recipes += new /datum/cookingrecipe/oven/elviswich_blt(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich_mb(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich_mbalt(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich_egg(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich_bm(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich_bmalt(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich_m_h(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich_m_m(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich_m_s(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich_c(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich_p_h(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich_p(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich_blt(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich_custom(src)
			src.recipes += new /datum/cookingrecipe/oven/mapo_tofu_meat(src)
			src.recipes += new /datum/cookingrecipe/oven/mapo_tofu_synth(src)
			src.recipes += new /datum/cookingrecipe/oven/ramen_bowl(src)
			src.recipes += new /datum/cookingrecipe/oven/udon_bowl(src)
			src.recipes += new /datum/cookingrecipe/oven/curry_udon_bowl(src)
			src.recipes += new /datum/cookingrecipe/oven/coconutcurry(src)
			src.recipes += new /datum/cookingrecipe/oven/chickenpineapplecurry(src)
			src.recipes += new /datum/cookingrecipe/oven/tandoorichicken(src)
			src.recipes += new /datum/cookingrecipe/oven/potatocurry(src)
			src.recipes += new /datum/cookingrecipe/oven/onionchips(src)
			src.recipes += new /datum/cookingrecipe/oven/mint_chutney(src)
			src.recipes += new /datum/cookingrecipe/oven/refried_beans(src)
			src.recipes += new /datum/cookingrecipe/oven/ultrachili(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/aburgination(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/baconator(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/butterburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/cheeseburger_m(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/cheeseburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/wcheeseburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/tikiburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/luauburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/coconutburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/humanburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/monkeyburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/synthburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/slugburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/baconburger(src)
			src.recipes += new /datum/cookingrecipe/oven/spicychickensandwich_2(src)
			src.recipes += new /datum/cookingrecipe/oven/spicychickensandwich(src)
			src.recipes += new /datum/cookingrecipe/oven/chickensandwich(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/mysteryburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/synthbuttburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/cyberbuttburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/buttburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/synthheartburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/cyberheartburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/flockheartburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/heartburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/synthbrainburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/cyberbrainburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/flockbrainburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/flockburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/brainburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/fishburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/sloppyjoe(src)
			src.recipes += new /datum/cookingrecipe/oven/superchili(src)
			src.recipes += new /datum/cookingrecipe/oven/chili(src)
			src.recipes += new /datum/cookingrecipe/oven/chilifries(src)
			src.recipes += new /datum/cookingrecipe/oven/chilifries_alt(src)
			src.recipes += new /datum/cookingrecipe/oven/poutine(src)
			src.recipes += new /datum/cookingrecipe/oven/poutine_alt(src)
			src.recipes += new /datum/cookingrecipe/oven/fries(src)
			src.recipes += new /datum/cookingrecipe/oven/queso(src)
			src.recipes += new /datum/cookingrecipe/oven/creamofamanita(src)
			src.recipes += new /datum/cookingrecipe/oven/creamofpsilocybin(src)
			src.recipes += new /datum/cookingrecipe/oven/creamofmushroom(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/cheeseborger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/roburger(src)
			src.recipes += new /datum/cookingrecipe/oven/swede_mball(src)
			src.recipes += new /datum/cookingrecipe/oven/honkpocket(src)
			src.recipes += new /datum/cookingrecipe/oven/donkpocket(src)
			src.recipes += new /datum/cookingrecipe/oven/donkpocket2(src)
			src.recipes += new /datum/cookingrecipe/oven/cornbread4(src)
			src.recipes += new /datum/cookingrecipe/oven/cornbread3(src)
			src.recipes += new /datum/cookingrecipe/oven/cornbread2(src)
			src.recipes += new /datum/cookingrecipe/oven/cornbread1(src)
			src.recipes += new /datum/cookingrecipe/oven/elvis_bread(src)
			src.recipes += new /datum/cookingrecipe/oven/banana_bread(src)
			src.recipes += new /datum/cookingrecipe/oven/pumpkin_bread(src)
			src.recipes += new /datum/cookingrecipe/oven/spooky_bread(src)
			src.recipes += new /datum/cookingrecipe/oven/banana_bread_alt(src)
			src.recipes += new /datum/cookingrecipe/oven/honeywheat_bread(src)
			src.recipes += new /datum/cookingrecipe/oven/eggnog(src)
			src.recipes += new /datum/cookingrecipe/oven/meatloaf(src)
			src.recipes += new /datum/cookingrecipe/oven/brain_bread(src)
			src.recipes += new /datum/cookingrecipe/oven/toast_bread(src)
			src.recipes += new /datum/cookingrecipe/oven/donut(src)
			src.recipes += new /datum/cookingrecipe/oven/bagel(src)
			src.recipes += new /datum/cookingrecipe/oven/crumpet(src)
			src.recipes += new /datum/cookingrecipe/oven/ice_cream_cone(src)
			src.recipes += new /datum/cookingrecipe/oven/waffles(src)
			src.recipes += new /datum/cookingrecipe/oven/lasagna(src)
			src.recipes += new /datum/cookingrecipe/oven/chickenparm(src)
			src.recipes += new /datum/cookingrecipe/oven/chickenalfredo(src)
			src.recipes += new /datum/cookingrecipe/oven/alfredo(src)
			src.recipes += new /datum/cookingrecipe/oven/spaghetti_pg(src)
			src.recipes += new /datum/cookingrecipe/oven/spaghetti_m(src)
			src.recipes += new /datum/cookingrecipe/oven/spaghetti_s(src)
			src.recipes += new /datum/cookingrecipe/oven/spaghetti_t(src)
			src.recipes += new /datum/cookingrecipe/oven/spaghetti_p(src)
			src.recipes += new /datum/cookingrecipe/oven/breakfast(src)
			src.recipes += new /datum/cookingrecipe/oven/french_toast(src)
			src.recipes += new /datum/cookingrecipe/oven/elvischeesetoast(src)
			src.recipes += new /datum/cookingrecipe/oven/elvisbacontoast(src)
			src.recipes += new /datum/cookingrecipe/oven/elviseggtoast(src)
			src.recipes += new /datum/cookingrecipe/oven/cheesetoast(src)
			src.recipes += new /datum/cookingrecipe/oven/bacontoast(src)
			src.recipes += new /datum/cookingrecipe/oven/eggtoast(src)
			src.recipes += new /datum/cookingrecipe/oven/churro(src)
			src.recipes += new /datum/cookingrecipe/oven/nougat(src)
			src.recipes += new /datum/cookingrecipe/oven/candy_cane(src)
			src.recipes += new /datum/cookingrecipe/oven/cereal_box(src)
			src.recipes += new /datum/cookingrecipe/oven/cereal_honey(src)
			src.recipes += new /datum/cookingrecipe/oven/cereal_tanhony(src)
			src.recipes += new /datum/cookingrecipe/oven/cereal_roach(src)
			src.recipes += new /datum/cookingrecipe/oven/cereal_syndie(src)
			src.recipes += new /datum/cookingrecipe/oven/cereal_flock(src)
			src.recipes += new /datum/cookingrecipe/oven/b_cupcake(src)
			src.recipes += new /datum/cookingrecipe/oven/beefood(src)
			src.recipes += new /datum/cookingrecipe/oven/zongzi(src)

			src.recipes += new /datum/cookingrecipe/oven/baguette(src)
			src.recipes += new /datum/cookingrecipe/oven/garlicbread_ch(src)
			src.recipes += new /datum/cookingrecipe/oven/garlicbread(src)
			src.recipes += new /datum/cookingrecipe/oven/cinnamonbun(src)
			src.recipes += new /datum/cookingrecipe/oven/fairybread(src)
			src.recipes += new /datum/cookingrecipe/oven/chocolate_cherry(src)
			src.recipes += new /datum/cookingrecipe/oven/danish_apple(src)
			src.recipes += new /datum/cookingrecipe/oven/danish_cherry(src)
			src.recipes += new /datum/cookingrecipe/oven/danish_blueb(src)
			src.recipes += new /datum/cookingrecipe/oven/danish_weed(src)
			src.recipes += new /datum/cookingrecipe/oven/danish_cheese(src)
			src.recipes += new /datum/cookingrecipe/oven/painauchocolat(src)
			src.recipes += new /datum/cookingrecipe/oven/croissant(src)

			src.recipes += new /datum/cookingrecipe/oven/pie_anything/pie_cream(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_anything(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_cherry(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_blueberry(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_blackberry(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_raspberry(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_strawberry(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_apple(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_lime(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_lemon(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_slurry(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_pumpkin(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_custard(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_strawberry(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_bacon(src)
			src.recipes += new /datum/cookingrecipe/oven/pot_pie(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_chocolate(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_ass(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_fish(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_weed(src)
			src.recipes += new /datum/cookingrecipe/oven/candy_apple_poison(src)
			src.recipes += new /datum/cookingrecipe/oven/candy_apple(src)
			src.recipes += new /datum/cookingrecipe/oven/cake_bacon(src)
			src.recipes += new /datum/cookingrecipe/oven/cake_true_bacon(src)
			src.recipes += new /datum/cookingrecipe/oven/cake_meat(src)
			src.recipes += new /datum/cookingrecipe/oven/cake_chocolate(src)
			src.recipes += new /datum/cookingrecipe/oven/cake_cream(src)
			#ifdef XMAS
			src.recipes += new /datum/cookingrecipe/oven/cake_fruit(src)
			#endif
			src.recipes += new /datum/cookingrecipe/oven/cake_custom(src)
			src.recipes += new /datum/cookingrecipe/oven/stroopwafel(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_spooky(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_jaffa(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_bacon(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_oatmeal(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_chocolate_chip(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_iron(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_butter(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_peanut(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie(src)
			src.recipes += new /datum/cookingrecipe/oven/moon_pie_spooky(src)
			src.recipes += new /datum/cookingrecipe/oven/moon_pie_jaffa(src)
			src.recipes += new /datum/cookingrecipe/oven/moon_pie_bacon(src)
			src.recipes += new /datum/cookingrecipe/oven/moon_pie_chocolate(src)
			src.recipes += new /datum/cookingrecipe/oven/moon_pie_oatmeal(src)
			src.recipes += new /datum/cookingrecipe/oven/moon_pie_chips(src)
			src.recipes += new /datum/cookingrecipe/oven/moon_pie_iron(src)
			src.recipes += new /datum/cookingrecipe/oven/moon_pie(src)
			src.recipes += new /datum/cookingrecipe/oven/granola_bar(src)
			src.recipes += new /datum/cookingrecipe/oven/biscuit(src)
			src.recipes += new /datum/cookingrecipe/oven/dog_biscuit(src)
			src.recipes += new /datum/cookingrecipe/oven/hardtack(src)
			src.recipes += new /datum/cookingrecipe/oven/macguffin(src)
			src.recipes += new /datum/cookingrecipe/oven/eggsalad(src)
			src.recipes += new /datum/cookingrecipe/oven/lipstick(src)
			src.recipes += new /datum/cookingrecipe/oven/friedrice(src)
			src.recipes += new /datum/cookingrecipe/oven/risotto(src)
			src.recipes += new /datum/cookingrecipe/oven/omurice(src)
			src.recipes += new /datum/cookingrecipe/oven/riceandbeans(src)
			src.recipes += new /datum/cookingrecipe/oven/sushi_roll(src)
			src.recipes += new /datum/cookingrecipe/oven/nigiri_roll(src)
			src.recipes += new /datum/cookingrecipe/oven/porridge(src)
			src.recipes += new /datum/cookingrecipe/oven/ratatouille(src)
			src.recipes += new /datum/cookingrecipe/oven/flapjack_batch(src)
			// Put all single-ingredient recipes after this point
			src.recipes += new /datum/cookingrecipe/oven/pizza_custom(src)
			src.recipes += new /datum/cookingrecipe/oven/cake_custom_item(src)
			src.recipes += new /datum/cookingrecipe/oven/pancake(src)
			src.recipes += new /datum/cookingrecipe/oven/bread(src)
			src.recipes += new /datum/cookingrecipe/oven/oatmeal(src)
			src.recipes += new /datum/cookingrecipe/oven/salad(src)
			src.recipes += new /datum/cookingrecipe/oven/tomsoup(src)
			src.recipes += new /datum/cookingrecipe/oven/toasted_french(src)
			src.recipes += new /datum/cookingrecipe/oven/toast_brain(src)
			src.recipes += new /datum/cookingrecipe/oven/toast_banana(src)
			src.recipes += new /datum/cookingrecipe/oven/toast_elvis(src)
			src.recipes += new /datum/cookingrecipe/oven/toast_spooky(src)
			src.recipes += new /datum/cookingrecipe/oven/toast(src)
			src.recipes += new /datum/cookingrecipe/oven/taco_shell(src)
			src.recipes += new /datum/cookingrecipe/oven/bacon(src)
			src.recipes += new /datum/cookingrecipe/oven/steak_h(src)
			src.recipes += new /datum/cookingrecipe/oven/steak_m(src)
			src.recipes += new /datum/cookingrecipe/oven/steak_s(src)
			src.recipes += new /datum/cookingrecipe/oven/steak_ling(src)
			src.recipes += new /datum/cookingrecipe/oven/fish_fingers(src)
			src.recipes += new /datum/cookingrecipe/oven/shrimp(src)
			src.recipes += new /datum/cookingrecipe/oven/chocolate_egg(src)
			src.recipes += new /datum/cookingrecipe/oven/hardboiled(src)
			src.recipes += new /datum/cookingrecipe/oven/bakedpotato(src)
			src.recipes += new /datum/cookingrecipe/oven/rice_ball(src)
			src.recipes += new /datum/cookingrecipe/oven/hotdog(src)
			src.recipes += new /datum/cookingrecipe/oven/cheesewheel(src)
			src.recipes += new /datum/cookingrecipe/oven/turkey(src)
			src.recipes += new /datum/cookingrecipe/oven/melted_sugar(src)
			src.recipes += new /datum/cookingrecipe/oven/brownie_batch(src)

			// store the list for later
			oven_recipes = src.recipes

	proc/cook_food()
		var/amount = length(src.contents)
		if (!amount)
			boutput(usr, SPAN_ALERT("There's nothing in \the [src] to cook."))
			return
		var/output = null /// what path / item is (getting) created
		var/cook_amt = src.time * (src.heat == "High" ? 2 : 1) /// time the oven is set to cook
		var/bonus = 0 /// correct-cook-time bonus
		var/derivename = 0 /// if output should derive name from human meat inputs
		var/recipebonus = 0 /// the ideal amount of cook time for the bonus
		var/recook = 0
		// If emagged produce random output.
		if (emagged)
			// Enforce GIGO and prevent infinite reuse
			var/contentsok = 1
			for(var/obj/item/I in src.contents)
				if(istype(I, /obj/item/reagent_containers/food/snacks/yuck))
					contentsok = 0
					break
				if(istype(I, /obj/item/reagent_containers/food/snacks/yuck/burn))
					contentsok = 0
					break
				if(istype(I, /obj/item/reagent_containers/food))
					var/obj/item/reagent_containers/food/F = I
					if (F.from_emagged_oven) // hyphz checked heal_amt but I think this custom var is a nicer solution (also I'm not sure that valid food not from an emagged oven will never have a heal_amt of 0 (because I am lazy and don't want to read the code))
						contentsok = 0
						break
				// Pick a random recipe
			var/datum/cookingrecipe/xrecipe = pick(src.recipes)
			var/xrecipeok = 1
			// Don't choose recipes with human meat since we don't have a name for them
			if (xrecipe.useshumanmeat)
				xrecipeok = 0
			// Don't choose recipes with special outputs since we don't have valid inputs for them
			if (isnull(xrecipe.output))
				xrecipeok = 0
			// Bail out to a mess if we didn't get a valid recipe
			if (xrecipeok && contentsok)
				output = xrecipe.output
			else
				output = /obj/item/reagent_containers/food/snacks/yuck
			// Given the weird stuff coming out of the oven it presumably wouldn't be palatable..
			recipebonus = 0
			bonus = -1
		else
			// Non-emagged cooking
			var/datum/cookingrecipe/R = src.OVEN_get_valid_recipe()
			if (R)
				// this is null if it uses normal outputs (see below),
				// otherwise it will be the created item from this
				output = R.specialOutput(src)
				if (isnull(output))
					output = R.output
				if (R.useshumanmeat) derivename = 1
				// derive the bonus amount from cooking
				// being off by one in either direction is OK
				// being off by 5 either burns it or makes it taste like shit
				// "cookbonus" here is actually "amount of cooking needed for bonus"
				recipebonus = R.cookbonus
				if (abs(cook_amt - R.cookbonus) <= 1)
					// if -1, 0, or 1, you did ok
					bonus = 1
				else if (cook_amt <= R.cookbonus - 5)
					// severely undercooked
					bonus = -1
				else if (cook_amt >= R.cookbonus + 5)
					// severely overcooked and burnt
					output = /obj/item/reagent_containers/food/snacks/yuck/burn
					bonus = 0
			// the case where there are no valid recipies is handled below in the outer context
			// (namely it replaces them with yuck)
		if (isnull(output))
			output = /obj/item/reagent_containers/food/snacks/yuck
		// this only happens if the output is a yuck item, either from an
		// invalid recipe or otherwise...
		if (amount == 1 && output == /obj/item/reagent_containers/food/snacks/yuck)
			for (var/obj/item/reagent_containers/food/snacks/F in src)
				if(F.quality < 1)
					// @TODO cook_amt == F.quality can never happen here
					// (cook_amt is the time the oven is set to from 1-10,
					//  and F.quality has to be 0 or below to get here)
					recook = 1
					if (cook_amt == F.quality) F.quality = 1.5
					else if (cook_amt == F.quality + 1) F.quality = 1
					else if (cook_amt == F.quality - 1) F.quality = 1
					else if (cook_amt <= F.quality - 5) F.quality = 0.5
					else if (cook_amt >= F.quality + 5)
						output = /obj/item/reagent_containers/food/snacks/yuck/burn
						bonus = 0
		// start cooking animation
		src.working = 1
		src.icon_state = "oven_bake"

		// this is src.time seconds instead of cook_amt,
		// because cook_amount is x2 if on "high" mode,
		// and it seems pretty silly to make it take twice as long
		// instead of, idk, just giving the oven 20 buttons
		SPAWN(src.time SECONDS)
			// this is all stuff relating to re-cooking with yuck items
			// suitably it is very gross
			if(recook && bonus !=0)
				for (var/obj/item/reagent_containers/food/snacks/F in src)
					if (bonus == 1)
						if (F.quality != 1)
							F.quality = 1
					else if (bonus == -1)
						if (F.quality > 0.5)
							F.quality = 0.5
					if (src.emagged)
						F.from_emagged_oven = 1
					F.set_loc(src.loc)
					if (istype(F, /obj/item/reagent_containers/food/snacks/yuck))
						src.food_crime(usr, F)
			else
				// normal cooking here
				var/obj/item/reagent_containers/food/snacks/F
				if (ispath(output))
					F = new output(src.loc)
				else
					F = output
					F.set_loc( get_turf(src) )
				// if this was a yuck item, it's bad enough to be criminal
				if (istype(F, /obj/item/reagent_containers/food/snacks/yuck))
					src.food_crime(usr, F)
				// "bonus" is 1 if cook time is within 1 of the required time,
				// 0 if it was off by 2-4 or over by 5+
				// -1 if it was under by 5 or more
				// basically:
				// -5  4  3  2 -1  0 +1  2  3  4 +5   diff. from required time
				//                 |
				//  0  1  2  3  5  5  5  3  2  1  0   food quality
				if (bonus == 1)
					F.quality = 5
				else
					F.quality = clamp(5 - abs(recipebonus - cook_amt), 0, 5)
				// emagged ovens cannot re-cook their own outputs
				if (src.emagged && istype(F))
					F.from_emagged_oven = 1
				// used for dishes that have their human's name in them
				if (derivename)
					var/foodname = F.name
					for (var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/M in src.contents)
						F.name = "[M.subjectname] [foodname]"
						F.desc += " It sort of smells like [M.subjectjob ? M.subjectjob : "pig"]s."
						if(!isnull(F.unlock_medal_when_eaten))
							continue
						else if (M.subjectjob && M.subjectjob == "Clown")
							F.unlock_medal_when_eaten = "That tasted funny"
						else
							F.unlock_medal_when_eaten = "Space Ham" //replace the old fat person method
			// done with checking outputs...
			// change icon back, ding, and remove used ingredients
			src.icon_state = "oven_off"
			src.working = 0
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			for (var/atom/movable/I in src.contents)
				qdel(I)

	proc/food_crime(mob/user, obj/item/food)
		// logTheThing(LOG_STATION, src, "[key_name(user)] commits a horrible food crime, creating [food] with quality [food.quality].")

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] shoves [his_or_her(user)] head in the oven and turns it on.</b>"))
		src.icon_state = "oven_bake"
		user.TakeDamage("head", 0, 150)
		sleep(5 SECONDS)
		src.icon_state = "oven_off"
		SPAWN(55 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	attackby(obj/item/W, mob/user)
		if (isghostdrone(user))
			boutput(user, SPAN_ALERT("\The [src] refuses to interface with you, as you are not a properly trained chef!"))
			return
		if (W.cant_drop) //For borg held items
			boutput(user, SPAN_ALERT("You can't put that in [src] when it's attached to you!"))
			return
		if(W.w_class > W_CLASS_BULKY)
			boutput(user, SPAN_ALERT("[W] is far too large and unwieldly to fit in [src]!"))
			return
		if (src.working)
			boutput(user, SPAN_ALERT("It's already on! Putting a new thing in could result in a collapse of the cooking waveform into a really lousy eigenstate, like a vending machine chili dog."))
			return
		var/amount = length(src.contents)
		if (amount >= 8)
			boutput(user, SPAN_ALERT("\The [src] cannot hold any more items."))
			return

		var/proceed = 0
		for(var/check_path in src.allowed)
			if(istype(W, check_path))
				proceed = 1
				break
		if (istype(W, /obj/item/grab))
			proceed = 0
		if (istype(W, /obj/item/card/emag))
			..()
			return
		if (amount == 1)
			var/cakecount
			for (var/obj/item/reagent_containers/food/snacks/cake/cream/C in src.contents) cakecount++
			if (cakecount == 1) proceed = 1
		if (!proceed)
			boutput(user, SPAN_ALERT("You can't put that in [src]!"))
			return
		user.visible_message(SPAN_NOTICE("[user] loads [W] into [src]."))
		user.u_equip(W)
		W.set_loc(src)
		W.dropped(user)
		src.ui_interact(user)

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if (istype(W) && in_interact_range(W, user) && in_interact_range(src, user) && W.w_class <= W_CLASS_HUGE && !W.anchored && isalive(user) && !isintangible(user))
			return src.Attackby(W, user)
		return ..()

	proc/OVEN_get_valid_recipe()
		// For every recipe, check if we can make it with our current contents
		for (var/datum/cookingrecipe/R in src.recipes)
			if (src.OVEN_can_cook_recipe(R))
				return R
		return null

	proc/OVEN_can_cook_recipe(datum/cookingrecipe/recipe)
		for(var/I in recipe.ingredients)
			if (!OVEN_checkitem(I, recipe.ingredients[I])) return FALSE

		return TRUE

	proc/OVEN_checkitem(var/recipeitem, var/recipecount)
		if (!locate(recipeitem) in src.contents) return FALSE
		var/count = 0
		for(var/obj/item/I in src.contents)
			if(istype(I, recipeitem))
				count++
		if (count < recipecount)
			return FALSE
		return TRUE
