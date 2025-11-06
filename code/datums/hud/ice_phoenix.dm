/datum/hud/critter/space_phoenix
	New()
		..()
		var/atom/movable/screen/map = src.create_screen("map", "Show Map", 'icons/mob/critter/nonhuman/spacephoenix.dmi', "map", "SOUTH,EAST", HUD_LAYER_1,
			tooltip_options = list("align" = TOOLTIP_LEFT | TOOLTIP_CENTER))
		map.desc = "Show a map of the space Z level."

		var/atom/movable/screen/hud/phoenix_return_to_station/return_to_stat = src.create_screen("return_to_station", "Return to Station Z Level", \
			'icons/mob/critter/nonhuman/spacephoenix.dmi', "return_to_station", "SOUTH+1,EAST", HUD_LAYER_1,
			tooltip_options = list("align" = TOOLTIP_LEFT | TOOLTIP_CENTER))
		return_to_stat.desc = "Toggle if you'll travel to the station Z level upon exiting the current level."

	relay_click(id, mob/user, list/params)
		var/mob/living/critter/space_phoenix/phoenix = src.master
		if (id == "map")
			phoenix.show_map()
		else if (id == "return_to_station")
			phoenix.toggle_return_to_station()
		else
			..(id, user, params)

/atom/movable/screen/hud/phoenix_return_to_station
	desc = "Toggles if you'll return to the station Z level when exiting the current level.<br><br>Currently toggled off."
	var/toggled_on = FALSE

	clicked(list/params)
		src.toggled_on = !src.toggled_on
		src.desc = "Toggles if you'll return to the station Z level when exiting the current level.<br><br>Currently toggled " + \
			"[src.toggled_on ? "off" : "on"]."
		..()
