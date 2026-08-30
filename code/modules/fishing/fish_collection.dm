
/mob/proc/add_to_fish_collection(atom/movable/fish)
	if (!src.client)
		return
	if (!istype(fish, /obj/item/reagent_containers/food/fish))
		return

	var/collection_data = src.client.player?.cloudSaves.getData("fish_collection")
	var/list/collection = null
	if (collection_data != null)
		collection = json_decode(collection_data)
		if (collection.Find(initial(fish.name)))
			return
	else
		collection = list()
	collection.Add(initial(fish.name))
	src.client.player?.cloudSaves.putData("fish_collection", json_encode(collection))

	get_singleton(/datum/fish_collection).verify_fish_medal(src.client.player, TRUE)

/datum/fish_collection
	// elements in the form of list("name" = name, "image" = image, "silhouette" = silhouette, "collection" = fish_collection_type)
	var/list/fish_data = list()
	var/const/medal_name = "So Long, and Thanks for All the Fish"

	proc/verify_fish_medal(datum/player/player, announce)
		var/collection_data = player.cloudSaves.getData("fish_collection")
		var/list/user_fish = isnull(collection_data) ? list() : json_decode(collection_data)

		for (var/fish in src.fish_data)
			if (fish["collection"] != FISH_COLLECTION_NORMAL)
				continue
			if (!user_fish.Find(fish["name"]))
				SPAWN(0)
					player.clear_medal(src.medal_name)
				return
		player.unlock_medal(src.medal_name, announce)

	proc/getBase64Imgs(path)

		var/obj/fish = path
		var/icon/icon = icon(initial(fish.icon), initial(fish.icon_state), frame=1)
		var/fish_icon = icon2base64(icon)
		var/fish_silhouette = icon2base64(icon * "#000000")
		return list(fish_icon, fish_silhouette)

	New()
		..()
		for (var/path in concrete_typesof(/obj/item/reagent_containers/food/fish))
			var/typeinfo/obj/item/reagent_containers/food/fish/info = get_type_typeinfo(path)
			if (info.fish_collection_type == FISH_COLLECTION_NEVER)
				continue

			var/obj/fish = path
			var/result = src.getBase64Imgs(fish)
			src.fish_data.Add(list(list("name" = initial(fish.name), "image" = result[1], "silhouette" = result[2], "collection" = info.fish_collection_type)))

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "FishCollection")
			ui.open()

	ui_data(mob/user)
		var/collection_data = user.client?.player.cloudSaves.getData("fish_collection")
		var/list/collected = isnull(collection_data) ? list() : json_decode(collection_data)
		. = list(
			"collected" = collected
		)

	ui_static_data(mob/user)
		. = list(
			"fish_data" = src.fish_data
		)

	ui_status(mob/user, datum/ui_state/state)
		return tgui_always_state.can_use_topic(src, user)

/client/verb/fishcollection()
	set name = "Fish Collection"
	set desc = "See all the fish you have collected."
	set category = "Commands"
	get_singleton(/datum/fish_collection).ui_interact(usr)
