ABSTRACT_TYPE(/obj/machinery/computer/pod_wars_minimap_controller)
/obj/machinery/computer/pod_wars_minimap_controller
	name = "debris field map controller"
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "pod_wars_minimap_controller"
	bound_width = 64
	bound_height = 32

	var/obj/minimap_controller/minimap_controller
	var/atom/movable/minimap_ui_handler/minimap_controller/minimap_ui
	var/team_num = null

/obj/machinery/computer/pod_wars_minimap_controller/New()
	. = ..()
	src.connect_to_minimap()

	var/image/screen_light = image('icons/obj/large/64x64.dmi', "minimap_controller_lights")
	screen_light.plane = PLANE_LIGHTING
	screen_light.blend_mode = BLEND_ADD
	screen_light.layer = LIGHTING_LAYER_BASE
	screen_light.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)
	src.AddOverlays(screen_light, "screen_light")

/obj/machinery/computer/pod_wars_minimap_controller/attack_hand(mob/user)
	if (src.status & (BROKEN|NOPOWER))
		return

	src.add_fingerprint(user)
	if (!src.minimap_controller || !src.minimap_ui)
		src.connect_to_minimap()
		if (!src.minimap_controller || !src.minimap_ui)
			return

	src.minimap_ui.ui_interact(user)

/obj/machinery/computer/pod_wars_minimap_controller/proc/connect_to_minimap()
	var/obj/minimap/map_computer/pod_wars/minimap
	switch(team_num)
		if (TEAM_NANOTRASEN)
			for_by_tcl(map, /obj/minimap/map_computer/pod_wars/nanotrasen)
				minimap = map

			if (minimap)
				src.minimap_controller = new(minimap)
				src.minimap_ui = new(src, "nt_debris_minimap", src.minimap_controller, "Debris Field Map Controller", "ntos")

		if (TEAM_SYNDICATE)
			for_by_tcl(map, /obj/minimap/map_computer/pod_wars/syndicate)
				minimap = map

			if (minimap)
				src.minimap_controller = new(minimap)
				src.minimap_ui = new(src, "synd_debris_minimap", src.minimap_controller, "Debris Field Map Controller", "syndicate")

		if (TEAM_NEUTRAL)
			for_by_tcl(map, /obj/minimap/map_computer/pod_wars/both_teams)
				minimap = map

			if (minimap)
				src.minimap_controller = new(minimap)
				src.minimap_ui = new(src, "neutral_debris_minimap", src.minimap_controller, "Debris Field Map Controller", "retro-dark")


/obj/machinery/computer/pod_wars_minimap_controller/nanotrasen
	team_num = TEAM_NANOTRASEN

/obj/machinery/computer/pod_wars_minimap_controller/syndicate
	team_num = TEAM_SYNDICATE

/obj/machinery/computer/pod_wars_minimap_controller/neutral
	team_num = TEAM_NEUTRAL
