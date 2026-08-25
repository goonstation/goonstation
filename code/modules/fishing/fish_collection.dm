
/mob/proc/add_to_fish_collection(atom/movable/fish)
	if (!src.client)
		return
	if (!istype(fish, /obj/item/reagent_containers/food/fish))
		return
	var/typeinfo/obj/item/reagent_containers/food/fish/info = get_type_typeinfo(fish.type)
	if (!info.appears_in_fish_collection)
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

	if (length(collection) >= length(get_singleton(/datum/fish_collection).fish_data))
		src.unlock_medal(get_singleton(/datum/fish_collection).medal_name, 1)

/datum/fish_collection
	// elements in the form of list("name" = name, "image" = image, "silhouette" = silhouette)
	var/list/fish_data = list()
	var/const/medal_name = "So Long, and Thanks for All the Fish"
	var/const/window_width = 420
	var/window_height = 64 // some padding

	proc/verify_fish_medal(datum/player/player)
		var/collection_data = player.cloudSaves.getData("fish_collection")
		var/list/user_fish = isnull(collection_data) ? list() : json_decode(collection_data)
		if (length(user_fish) < length(src.fish_data))
			player.clear_medal(src.medal_name)
		else //fallback in case we... delete fish I guess?
			player.unlock_medal(src.medal_name, 0)

	proc/getBase64Imgs(path)

		var/obj/fish = path
		var/icon/icon = icon(initial(fish.icon), initial(fish.icon_state), frame=1)
		var/fish_icon = icon2base64(icon)
		var/fish_silhouette = icon2base64(icon * "#000000")
		return list(fish_icon, fish_silhouette, icon.Width())

	proc/is_fish_in_collection(path)
		var/typeinfo/obj/item/reagent_containers/food/fish/info = get_type_typeinfo(path)
		return info.appears_in_fish_collection

	New()
		..()
		var/current_width = 0
		for (var/path in filtered_concrete_typesof(/obj/item/reagent_containers/food/fish, .proc/is_fish_in_collection))
			var/obj/fish = path
			var/result = src.getBase64Imgs(fish)
			current_width += result[3] + 10 // padding
			if (current_width > src.window_width)
				src.window_height += 42 // 32 image height + 10 padding
				current_width = result[3]
			src.fish_data.Add(list(list("name" = initial(fish.name), "image" = result[1], "silhouette" = result[2])))

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
			"fish_data" = src.fish_data,
			"width" = src.window_width,
			"height" = src.window_height
		)

	ui_status(mob/user, datum/ui_state/state)
		return tgui_always_state.can_use_topic(src, user)

/client/verb/fishcollection()
	set name = "Fish Collection"
	set desc = "See all the fish you have collected."
	set category = "Commands"
	get_singleton(/datum/fish_collection).ui_interact(usr)
