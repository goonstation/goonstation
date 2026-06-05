
/mob/proc/add_to_fish_collection(atom/movable/fish)
	if (!src.client)
		return
	if (!istype(fish, /obj/item/reagent_containers/food/fish))
		return

	var/list/collection = src.client.player?.cloudSaves.getData("fish_collection")
	if (collection != null)
		if (collection.Find(initial(fish.name)))
			return
		collection = collection.Copy() // otherwise this will point to the list in the chache, which will stop it from saving
	else
		collection = list()
	collection.Add(initial(fish.name))
	src.client.player?.cloudSaves.putData("fish_collection", collection)

	if (length(collection) >= length(get_singleton(/datum/fish_collection).fish_data))
		src.unlock_medal(get_singleton(/datum/fish_collection).medal_name, 1)

/datum/fish_collection
	// elements in the form of list("name" = name, "image" = image, "silhouette" = silhouette)
	var/list/fish_data = list()
	var/const/medal_name = "So Long, and Thanks for All the Fish"

	proc/verify_fish_medal(datum/player/player)
		var/list/user_fish = player.cloudSaves.getData("fish_collection")
		if (length(user_fish) < length(src.fish_data))
			player.clear_medal(src.medal_name)
		else //fallback in case we... delete fish I guess?
			player.unlock_medal(src.medal_name, 0)

	proc/getBase64Imgs(path)

		var/obj/fish = path
		var/icon/icon = icon(initial(fish.icon), initial(fish.icon_state))
		var/fish_icon = icon2base64(icon)
		var/fish_silhouette = icon2base64(icon * "#000000")
		return list(fish_icon, fish_silhouette)

	proc/is_fish_in_collection(path)
		var/typeinfo/obj/item/reagent_containers/food/fish/info = get_type_typeinfo(path)
		return info.appears_in_fish_collection

	New()
		..()
		for (var/path in filtered_concrete_typesof(/obj/item/reagent_containers/food/fish, .proc/is_fish_in_collection))
			var/obj/fish = path
			var/result = src.getBase64Imgs(fish)
			src.fish_data.Add(list(list("name" = initial(fish.name), "image" = result[1], "silhouette" = result[2])))

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "FishCollection")
			ui.open()

	ui_data(mob/user)
		var/list/collected = user.client?.player.cloudSaves.getData("fish_collection")
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
