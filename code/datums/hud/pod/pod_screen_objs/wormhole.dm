/atom/movable/screen/hud/pod/wormhole
	name = "Create Wormhole"
	desc = "Open a wormhole to a beacon that you can fly through."
	icon_state = "wormhole"
	tooltip_options = list("theme" = "pod")
	pod_part_id = POD_PART_ENGINE
	dependent_parts = list(POD_PART_ENGINE, POD_PART_SENSORS)

/atom/movable/screen/hud/pod/wormhole/on_click(mob/user)
	src.pod_hud.master.create_wormhole()
	return TRUE
