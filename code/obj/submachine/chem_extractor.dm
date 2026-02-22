////// Reagent Extractor

TYPEINFO(/obj/submachine/chem_extractor)
	mats = 6

/obj/submachine/chem_extractor
	name = "reagent extractor"
	desc = "A machine which can extract reagents from matter. Has a slot for a beaker and a chute to put things into."
	density = 1
	anchored = ANCHORED
	event_handler_flags = NO_MOUSEDROP_QOL
	deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	icon = 'icons/obj/objects.dmi'
	icon_state = "reex-off"
	flags = NOSPLASH | TGUI_INTERACTIVE
	var/mode = "overview"
	var/autoextract = FALSE
	var/nextingredientkey = 0
	var/obj/item/reagent_containers/glass/extract_to = null
	var/obj/item/reagent_containers/glass/inserted = null
	var/obj/item/reagent_containers/glass/storage_tank_1 = null
	var/obj/item/reagent_containers/glass/storage_tank_2 = null
	var/list/ingredients = list()
	var/list/allowed = list(/obj/item/reagent_containers/food/fish/, /obj/item/reagent_containers/food/snacks/,/obj/item/plant/,/obj/item/clothing/head/flower/,/obj/item/seashell)
	var/obj/item/robot_chemaster/prototype/parent_item = null

	New(var/loc, var/obj/item/robot_chemaster/prototype/parent_item = null)
		..()
		src.storage_tank_1 = new /obj/item/reagent_containers/glass/beaker/extractor_tank(src)
		src.storage_tank_2 = new /obj/item/reagent_containers/glass/beaker/extractor_tank(src)
		var/count = 1
		for (var/obj/item/reagent_containers/glass/beaker/extractor_tank/ST in src.contents)
			ST.name = "Storage Tank [count]"
			count++
		AddComponent(/datum/component/transfer_input/quickloading, allowed, "tryLoading")
		AddComponent(/datum/component/transfer_output)
		src.parent_item = parent_item

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	ui_interact(mob/user, datum/tgui/ui)
		remove_distant_beaker()
		if (src.inserted)
			SEND_SIGNAL(src.inserted.reagents, COMSIG_REAGENTS_ANALYZED, user)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ReagentExtractor", src.name)
			ui.open()

	ui_data(mob/user)
		. = list()
		var/list/containers = src.getContainers()

		var/list/containersData = list()
		// Container data
		for(var/container_id in containers)
			var/obj/item/reagent_containers/thisContainer = containers[container_id]
			if (!thisContainer)
				continue
			containersData[container_id] = ui_describe_reagents(thisContainer)
			containersData[container_id]["selected"] = src.extract_to == thisContainer
			containersData[container_id]["id"] = container_id

		.["containersData"] = containersData

		var/list/ingredientsData = list()
		// Ingredient/Extractable data
		for(var/ingredient_id in src.ingredients)
			var/obj/item/thisIngredient = src.ingredients[ingredient_id]
			if(thisIngredient)
				var/list/thisIngredientData = list(
					name = thisIngredient.name,
					id = ingredient_id
				)
				ingredientsData += list(thisIngredientData)

		.["ingredientsData"] = ingredientsData

		.["autoextract"] = src.autoextract



	ui_act(action, params)
		. = ..()
		if(.)
			return
		remove_distant_beaker()
		var/list/containers = src.getContainers()
		switch(action)
			if("ejectcontainer")
				var/obj/item/I = src.inserted
				if (!I)
					return
				if(src.inserted.loc == src)
					TRANSFER_OR_DROP(src, I) // causes Exited proc to be called
					usr.put_in_hand_or_eject(I)
				if (I == src.extract_to) src.extract_to = null
				src.inserted = null
				. = TRUE
			if("insertcontainer")
				if (src.inserted)
					return
				var/obj/item/inserting = usr.equipped()
				if(istype(inserting, /obj/item/reagent_containers/glass/) || istype(inserting, /obj/item/reagent_containers/food/drinks/))
					tryInsert(inserting, usr)
					. = TRUE
			if("ejectingredient")
				var/id = params["ingredient_id"]
				var/obj/item/ingredient = src.ingredients[id]
				if (istype(ingredient))
					src.ingredients.Remove(id)
					if (!src.parent_item)
						TRANSFER_OR_DROP(src, ingredient)
					else
						usr.put_in_hand_or_eject(ingredient)
					. = TRUE
			if("autoextract")
				src.autoextract = !src.autoextract
				. = TRUE
			if("flush_reagent")
				var/obj/item/reagent_containers/glass/target = containers[params["container_id"]]
				var/id = params["reagent_id"]
				if (target?.reagents)
					target.reagents.remove_reagent(id, 500)
					. = TRUE
			if("isolate")
				var/obj/item/reagent_containers/glass/target = containers[params["container_id"]]
				var/id = params["reagent_id"]
				if (target?.reagents)
					target.reagents.isolate_reagent(id)
					. = TRUE
			if("flush")
				var/obj/item/reagent_containers/glass/target = containers[params["container_id"]]
				if (target)
					target.reagents.clear_reagents()
					. = TRUE
			if("extractto")
				var/obj/item/reagent_containers/glass/target = containers[params["container_id"]]
				if (target)
					src.extract_to = target
					. = TRUE
			if("extractingredient")
				if (!src.extract_to || src.extract_to.reagents.total_volume >= src.extract_to.reagents.maximum_volume)
					return
				var/id = params["ingredient_id"]
				var/obj/item/ingredient = src.ingredients[id]
				if (!istype(ingredient) || !ingredient.reagents)
					return
				src.doExtract(ingredient)
				src.ingredients.Remove(id)
				qdel(ingredient)
				. = TRUE
			if("chemtransfer")
				var/obj/item/reagent_containers/glass/from = containers[params["container_id"]]
				var/obj/item/reagent_containers/glass/target = src.extract_to
				if (from?.reagents.total_volume && target && from != target)
					from.reagents.trans_to(target, clamp(params["amount"], 1, 500))
					. = TRUE
		src.UpdateIcon()

	ui_close(mob/user)
		. = ..()
		if(inserted?.loc != src)
			remove_distant_beaker(force = TRUE)

	attackby(var/obj/item/W, var/mob/user)
		if(istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/))
			tryInsert(W, user)

		..()

	proc/remove_distant_beaker(force = FALSE)
		// borgs and people with item arms don't insert the beaker into the machine itself
		// but whenever something would happen to the dispenser and the beaker is far it should disappear
		if(src.inserted && (BOUNDS_DIST(src.inserted, src) > 0 || force))
			if (src.inserted == src.extract_to) src.extract_to = null
			src.inserted = null
			src.UpdateIcon()

	proc/tryInsert(var/obj/item/W, var/mob/user)
		remove_distant_beaker()

		if(BOUNDS_DIST(user, src) > 0) // prevent message from appearing in case a borg inserts from afar
			return

		if(src.inserted)
			boutput(user, SPAN_ALERT("A container is already loaded into the machine."))
			return
		src.inserted =  W

		if(!W.cant_drop)
			user.drop_item()
			if(!QDELETED(W))
				W.set_loc(src)
		if(QDELETED(W))
			W = null
		else
			if(!src.extract_to) src.extract_to = W
			boutput(user, SPAN_NOTICE("You add [W] to the machine!"))
		src.ui_interact(user)

	Exited(Obj, newloc)
		if(Obj == src.inserted)
			src.inserted = null
			tgui_process.update_uis(src)

	ui_status()
		if (src.parent_item)
			return src.parent_item.ui_status(arglist(args))
		else
			return ..()

/obj/submachine/chem_extractor/proc/getContainers()
	. = list(
		inserted = src.inserted,
		storage_tank_1 = src.storage_tank_1,
		storage_tank_2 = src.storage_tank_2
	)

/obj/submachine/chem_extractor/update_icon()
	if (src.ingredients.len)
		src.icon_state = "reex-on"
	else
		src.icon_state = "reex-off"

/obj/submachine/chem_extractor/proc/doExtract(atom/movable/AM)
	// Welp -- we don't want anyone extracting these. They'll probably
	// feed them to monkeys and then exsanguinate them trying to get at the chemicals.
	if (istype(AM, /obj/item/reagent_containers/food/snacks/candy/jellybean/everyflavor))
		src.extract_to.reagents.add_reagent("sugar", 50)
		return
	AM.reagents.trans_to(src.extract_to, AM.reagents.total_volume)
	qdel(AM)
	src.UpdateIcon()

/obj/submachine/chem_extractor/proc/tryLoading(atom/movable/incoming)
	var/can_autoextract = src.autoextract && src.extract_to
	if (can_autoextract && src.extract_to.reagents.total_volume >= src.extract_to.reagents.maximum_volume)
		playsound(src, 'sound/machines/chime.ogg', 10, TRUE)
		src.visible_message(SPAN_ALERT("[src]'s tank over-fill alarm burps!"))
		can_autoextract = FALSE

	if (can_autoextract)
		doExtract(incoming)
	else
		src.ingredients["[nextingredientkey++]"] = incoming
		tgui_process.update_uis(src)
		src.UpdateIcon()
