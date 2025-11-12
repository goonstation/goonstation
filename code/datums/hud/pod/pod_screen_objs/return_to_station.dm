/atom/movable/screen/hud/pod/return_to_station
	name = "Return To Station"
	desc = "Using this will place you on the station Z-level the next time you fly off the edge of the current level."
	icon_state = "return-to-station"
	tooltip_options = list("theme" = "pod")
	pod_part_id = POD_PART_COMMS
	dependent_parts = list(POD_PART_COMMS)

/atom/movable/screen/hud/pod/return_to_station/New()
	src.name = "Return To [capitalize(global.station_or_ship())]"
	. = ..()

/atom/movable/screen/hud/pod/return_to_station/on_click(mob/user)
	src.pod_hud.master.return_to_station()
	return TRUE
