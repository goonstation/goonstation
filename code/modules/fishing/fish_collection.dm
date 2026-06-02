/mob/proc/add_to_fish_collection(atom/movable/fish)
	if (!src.client)
		return
	if (!istype(fish, /obj/item/reagent_containers/food/fish))
		return

	var/list/collection = src.client.player?.cloudSaves.getData("fish_collection")
	collection = collection.Copy() // otherwise this will point to the list in the chache, which will stop it from saving
	if (collection == null)
		collection = list()
	else if (collection.Find(initial(fish.name)))
		return
	collection.Add(initial(fish.name))
	src.client.player?.cloudSaves.putData("fish_collection", collection)

	if (length(collection) >= length(get_singleton(/datum/fish_collection).names))
		src.unlock_medal("So Long, and Thanks for All the Fish", 1)

/datum/fish_collection
	var/list/names = list()
	var/list/images = list()
	var/list/silhouettes = list()

	proc/getBase64Imgs(path)
		// modified code from vending machine
		var/atom/dummy_atom = new path
		sleep(0) // give it a chance to do icon changes
		var/dummy_icon = icon2base64(getFlatIcon(dummy_atom,initial(dummy_atom.dir),no_anim=TRUE))
		dummy_atom.color = "#000000"
		var/dummy_icon_silhouette = icon2base64(getFlatIcon(dummy_atom,initial(dummy_atom.dir),no_anim=TRUE))
		qdel(dummy_atom) // above is a hack to get this to work. if anyone has any better way of doing this, go ahead.
		return list(dummy_icon, dummy_icon_silhouette)

	proc/is_fish_in_collection(path)
		var/typeinfo/obj/item/reagent_containers/food/fish/info = get_type_typeinfo(path)
		return info.appears_in_fish_collection

	New()
		..()
		for (var/path in filtered_concrete_typesof(/obj/item/reagent_containers/food/fish, .proc/is_fish_in_collection))
			var/obj/fish = path
			src.names.Add(initial(fish.name))
			var/result = src.getBase64Imgs(fish)
			src.images.Add(result[1])
			src.silhouettes.Add(result[2])

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "FishCollection")
			ui.open()

	ui_data(mob/user)
		var/list/collected = user?.client.player?.cloudSaves.getData("fish_collection")
		if (isnull(collected))
			collected = list()
		. = list(
			"collected" = collected
		)

	ui_static_data(mob/user)
		. = list(
			"names" = src.names,
			"images" = src.images,
			"silhouettes" = src.silhouettes
		)

	ui_status(mob/user, datum/ui_state/state)
		return tgui_always_state.can_use_topic(src, user)

/client/verb/fishcollection()
	set name = "Fish Collection"
	set desc = "See all the fish you have collected."
	set category = "Commands"
	get_singleton(/datum/fish_collection).ui_interact(usr)
