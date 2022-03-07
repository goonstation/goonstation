#define PLATE_COST 2

/datum/glass_product
	var/product_name = "generic"
	var/product_img
	var/product_type = "generic"
	var/atom/product_path = null
	var/product_cost

	var/static/list/product_name_cache = list()
	var/static/list/product_base64_cache = list()

	New(type, path, cost=1)
		..()
		src.product_type = type

		if (istext(path))
			path = text2path(path)
		if (!ispath(path))
			qdel(src)
			return
		src.product_path = path

		var/name_check = product_name_cache[path]
		if (name_check)
			src.product_name = name_check
		else
			var/p_name = initial(product_path.name)
			src.product_name = capitalize(p_name)
			product_name_cache[path] = src.product_name

		var/img_check = product_base64_cache[path]
		if (img_check)
			src.product_img = img_check
		else
			var/atom/dummy_atom = path
			var/icon/dummy_icon = icon(initial(dummy_atom.icon), initial(dummy_atom.icon_state))
			src.product_img = icon2base64(dummy_icon)
			product_base64_cache[path] = src.product_img

		src.product_cost = cost

/obj/machinery/glass_recycler
	name = "glass recycler"//"Kitchenware Recycler"
	desc = "A machine that recycles glass shards into drinking glasses, beakers, or other glass things."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "synthesizer"
	anchored = 1
	density = 0
	var/glass_amt = 0
	var/list/product_list = list()
	mats = 10
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_WIRECUTTERS

	New()
		..()
		src.get_products()
		UnsubscribeProcess()

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W.loc, /obj/item/storage))
			var/obj/item/storage/storage = W.loc
			storage.hud.remove_object(W)
		if(W.cant_drop)
			boutput(user, "<span class='alert'>You cannot put [W] into [src]!</span>")
			return
		if(istype(W, /obj/item/reagent_containers/glass/jar) && length(W.contents))
			boutput(user, "<span class='alert'>You need to empty [W] first!</span>")
			return


		var/success = FALSE //did we successfully recycle a thing?
		if(istype(W, /obj/item/reagent_containers/glass))
			if (istype(W, /obj/item/reagent_containers/glass/beaker))
				success = TRUE
				if (istype(W, /obj/item/reagent_containers/glass/beaker/large))
					glass_amt += 2
				else
					glass_amt += 1
			else
				var/obj/item/reagent_containers/glass/G = W
				if (G.can_recycle)
					success = TRUE
					glass_amt += 1
		else if (istype(W, /obj/item/reagent_containers/food/drinks/))
			var/obj/item/reagent_containers/food/drinks/D = W
			if (D.can_recycle)
				success = TRUE
				if (istype(W,/obj/item/reagent_containers/food/drinks/drinkingglass))
					var/obj/item/reagent_containers/food/drinks/drinkingglass/DG = W
					glass_amt += DG.shard_amt
				else
					if (istype(W,/obj/item/reagent_containers/food/drinks/bottle))
						var/obj/item/reagent_containers/food/drinks/bottle/B = W
						if (!B.broken) glass_amt += 2
					else
						glass_amt += W.amount
		else if (istype(W, /obj/item/material_piece) && W.material?.material_flags & MATERIAL_CRYSTAL && W.material?.alpha <= 180)
			success = TRUE
			glass_amt += W.amount * 10
		else if (istype(W, /obj/item/raw_material/shard))
			success = TRUE
			glass_amt += W.amount
		else if (istype(W, /obj/item/plate))
			success = TRUE
			glass_amt += PLATE_COST
		else if (istype(W, /obj/item/platestack))
			success = TRUE
			var/obj/item/platestack/PS = W
			var/plateCount = PS.platenum + 1
			glass_amt += plateCount * PLATE_COST
		else if (istype(W, /obj/item/storage/box))
			var/obj/item/storage/S = W
			for (var/obj/item/I in S.get_contents())
				if (!.(I, user))
					break

		if (success)
			user.visible_message("<span class='notice'>[user] inserts [W] into [src].</span>")
			user.u_equip(W)
			if (istype(W, /obj/item/raw_material/shard))
				qdel(W)
			else
				qdel(W)
			ui_interact(user)
			return 1
		else
			boutput(user, "<span class='alert'>You cannot put [W] into [src]!</span>")
			return 0

	proc/get_products()
		product_list += new /datum/glass_product("beaker", /obj/item/reagent_containers/glass/beaker, 1)
		product_list += new /datum/glass_product("largebeaker", /obj/item/reagent_containers/glass/beaker/large, 2)
		product_list += new /datum/glass_product("bottle", /obj/item/reagent_containers/glass/bottle, 1)
		product_list += new /datum/glass_product("vial", /obj/item/reagent_containers/glass/vial, 1)
		product_list += new /datum/glass_product("drinkbottle", /obj/item/reagent_containers/food/drinks/bottle/soda, 2)
		product_list += new /datum/glass_product("longbottle", /obj/item/reagent_containers/food/drinks/bottle/empty/long, 2)
		product_list += new /datum/glass_product("tallbottle", /obj/item/reagent_containers/food/drinks/bottle/empty/tall, 2)
		product_list += new /datum/glass_product("rectangularbottle", /obj/item/reagent_containers/food/drinks/bottle/empty/rectangular, 2)
		product_list += new /datum/glass_product("squarebottle", /obj/item/reagent_containers/food/drinks/bottle/empty/square, 2)
		product_list += new /datum/glass_product("masculinebottle", /obj/item/reagent_containers/food/drinks/bottle/empty/masculine, 2)
		product_list += new /datum/glass_product("mug", /obj/item/reagent_containers/food/drinks/mug/random_color, 1)
		product_list += new /datum/glass_product("plate", /obj/item/plate, PLATE_COST)
		product_list += new /datum/glass_product("bowl", /obj/item/reagent_containers/food/drinks/bowl, 1)
		product_list += new /datum/glass_product("drinking", /obj/item/reagent_containers/food/drinks/drinkingglass, 1)
		product_list += new /datum/glass_product("shot", /obj/item/reagent_containers/food/drinks/drinkingglass/shot, 1)
		product_list += new /datum/glass_product("oldf", /obj/item/reagent_containers/food/drinks/drinkingglass/oldf, 1)
		product_list += new /datum/glass_product("round", /obj/item/reagent_containers/food/drinks/drinkingglass/round, 2)
		product_list += new /datum/glass_product("wine", /obj/item/reagent_containers/food/drinks/drinkingglass/wine, 1)
		product_list += new /datum/glass_product("cocktail", /obj/item/reagent_containers/food/drinks/drinkingglass/cocktail, 1)
		product_list += new /datum/glass_product("flute", /obj/item/reagent_containers/food/drinks/drinkingglass/flute, 1)
		product_list += new /datum/glass_product("pitcher", /obj/item/reagent_containers/food/drinks/drinkingglass/pitcher, 2)

	proc/create(var/type)
		var/datum/glass_product/target_product = null
		for (var/datum/glass_product/product in product_list)
			if(product.product_type == type)
				target_product = product
				break

		if (!target_product)
			return

		if (src.glass_amt < target_product.product_cost)
			src.visible_message("<span class='alert'>[src] doesn't have enough glass to make that!</span>")
			return

		var/obj/item/G = new target_product.product_path(get_turf(src))
		src.glass_amt -= target_product.product_cost

		src.visible_message("<span class='notice'>[src] manufactures \a [G]!</span>")

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "GlassRecycler")
			ui.open()

	ui_static_data(mob/user)
		var/products = list()
		for (var/datum/glass_product/product in product_list)
			products += list(
				list(
					"name" = product.product_name,
					"type" = product.product_type,
					"cost" = product.product_cost,
					"img" = product.product_img,
				)
			)
		. = list(
			"products" = products,
		)


	ui_data(mob/user)
		. = list(
			"glassAmt" = glass_amt,
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch(action)
			if("create")
				var/product_type = params["type"]
				create(product_type)
				. = TRUE


/obj/machinery/glass_recycler/chemistry //Chemistry doesn't really need all of the drinking glass options and such so I'm limiting it down a notch.
	name = "chemistry glass recycler"

	get_products()
		product_list += new /datum/glass_product("beaker", /obj/item/reagent_containers/glass/beaker, 1)
		product_list += new /datum/glass_product("largebeaker", /obj/item/reagent_containers/glass/beaker/large, 2)
		product_list += new /datum/glass_product("bottle", /obj/item/reagent_containers/glass/bottle, 1)
		product_list += new /datum/glass_product("vial", /obj/item/reagent_containers/glass/vial, 1)
		product_list += new /datum/glass_product("flask", /obj/item/reagent_containers/glass/flask, 1)

#undef PLATE_COST
