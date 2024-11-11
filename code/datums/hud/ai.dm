/datum/hud/silicon/ai
	var/mob/living/silicon/ai/master

	var/atom/movable/screen/hud
		health
		cell
		tracking
		deploy
		apc
		status
		radio
		pda
		laws
		viewport
		hologram
		map
		core
		coreatk

	var/list/spinner = list("/", "-", "\\", "|")
	var/spinner_num = 1

	New(M)
		..()
		master = M

		health = create_screen("health", "Core Health", 'icons/mob/hud_ai.dmi', "health", "EAST, NORTH+0.5", HUD_LAYER)
		health.underlays += "underlay"
		health.maptext_width = 96
		health.maptext_x = -96
		health.maptext_y = -1

		cell = create_screen("cell", "Core Cell Charge", 'icons/mob/hud_ai.dmi', "cell", "EAST, NORTH", HUD_LAYER)
		cell.underlays += "underlay"
		cell.maptext_width = 96
		cell.maptext_x = -96
		cell.maptext_y = -1

		status = create_screen("status", "Change Status", 'icons/mob/hud_ai.dmi', "status", "WEST, NORTH+0.5", HUD_LAYER)
		status.underlays += "button"

		deploy = create_screen("deploy", "Deploy to Shell", 'icons/mob/hud_ai.dmi', "deploy", "WEST, NORTH", HUD_LAYER)
		deploy.underlays += "button"

		apc = create_screen("apc", "Open Area APC", 'icons/mob/hud_ai.dmi', "apc", "WEST, NORTH-0.5", HUD_LAYER)
		apc.underlays += "button"

		radio = create_screen("radio", "Adjust Internal Radios", 'icons/mob/hud_ai.dmi', "radio", "WEST, NORTH-1", HUD_LAYER)
		radio.underlays += "button"

		pda = create_screen("pda", "AI PDA", 'icons/mob/hud_ai.dmi', "pda", "WEST, NORTH-1.5", HUD_LAYER)
		pda.underlays += "button"

		laws = create_screen("laws", "Show Laws", 'icons/mob/hud_ai.dmi', "laws", "WEST, NORTH-2", HUD_LAYER)
		laws.underlays += "button"

		viewport = create_screen("viewport", "Create Viewport", 'icons/mob/hud_ai.dmi', "viewport", "WEST, NORTH-2.5", HUD_LAYER)
		viewport.underlays += "button"

		hologram = create_screen("hologram", "Create Hologram", 'icons/mob/hud_ai.dmi', "hologram", "WEST, NORTH-3", HUD_LAYER)
		hologram.underlays += "button"

		map = create_screen("map", "Show Map", 'icons/mob/hud_ai.dmi', "map", "WEST, NORTH-3.5", HUD_LAYER)
		map.underlays += "button"

		core = create_screen("core", "Return to Core", 'icons/mob/hud_ai.dmi', "core", "WEST, NORTH-4", HUD_LAYER)
		core.underlays += "button"

		coreatk = create_screen("coreatk", "Core Damaged!", 'icons/mob/hud_ai.dmi', "core", "WEST, NORTH-4", HUD_LAYER)
		coreatk.underlays += "killswitchu"
		coreatk.invisibility = INVIS_ALWAYS

		tracking = create_screen("tracking", "Tracking", 'icons/mob/hud_ai.dmi', "track", "WEST, SOUTH", HUD_LAYER)
		tracking.underlays += "button"
		tracking.maptext_width = 32*15
		tracking.maptext_x = 34
		tracking.maptext_y = -1

		update()

	clear_master()
		master = null
		..()

	update_health()
		..()
		var/pct = round(100 * master.health/master.max_health, 1)
		health.maptext = "<span class='ol vga r' style='color: [rgb(255 * clamp((100 - pct) / 50, 0, 1), 255 * clamp(pct / 50, 1, 0), 0)];'>[pad_leading(pct, 3)]%</span>"
		if (pct > 25)
			core.invisibility = INVIS_NONE
			coreatk.invisibility = INVIS_ALWAYS
		else
			core.invisibility = INVIS_ALWAYS
			coreatk.invisibility = INVIS_NONE

	proc
		update()
			update_health()
			update_charge()
			update_tracking()

		update_charge()
			if (master.cell)
				var/powertext = ""
				switch (master.power_mode)
					if (1)
						// draining
						powertext = "<span style='color: red;'>↓</span> "
					if (0)
						if (master.cell.charge < master.cell.maxcharge)
							powertext = "<span style='color: yellow;'>↑</span> "

				var/pct = round(100 * master.cell.charge/master.cell.maxcharge, 1)
				cell.maptext = "<span class='ol vga r' style='color: [rgb(255 * clamp((100 - pct) / 50, 0, 1), 255 * clamp(pct / 50, 1, 0), 0)];'>[powertext][pad_leading(pct,3)]%</span>"

		update_tracking()
			if (master.tracker.tracking)
				tracking.icon_state = "track_stop"
				if (master.eyecam.loc != master.tracker.tracking)
					spinner_num = (spinner_num % spinner.len) + 1
					tracking.maptext = "<span class='ol vga' style='color: #bbb;'>[master.tracker.tracking] <span style='color: #c77;'>(Off camera [spinner[spinner_num]])</span></span>"
				else
					spinner_num = 0
					tracking.maptext = "<span class='ol vga'>[master.tracker.tracking]</span>"
			else
				tracking.icon_state = "track"
				tracking.maptext = ""


	relay_click(id, mob/user, list/params)
		switch (id)
			if ("health")
				//output health info
				boutput(user, SPAN_HINT("Health: [master.health]/[master.max_health] - Brute: [master.bruteloss] - Burn: [master.fireloss]"))

			if ("cell")
				// Output cell info
				boutput(user, SPAN_HINT("Cell: [master.cell.charge]/[master.cell.maxcharge]"))

			if ("status")
				// Change status
				master.ai_statuschange()
				master.ai_colorchange()
				update()
			if ("deploy")
				// Deploy menu
				master.deploy_to()

			if ("apc")
				// open APC
				master.eyecam.access_area_apc()

			if ("tracking")
				if (master.tracker.tracking)
					// stop
					master.tracker.cease_track()
				else
					master.ai_camera_track()
				update_tracking()

			if ("pda")
				master.access_internal_pda()

			if ("radio")
				master.access_internal_radio()

			if ("laws")
				master.show_laws()

			if ("viewport")
				if(master.deployed_to_eyecam)
					master.eyecam.create_viewport(VIEWPORT_ID_AI)
				else
					boutput(master, SPAN_ALERT("Deploy to an AI Eye first to create a viewport."))
			if ("hologram")
				if(master.deployed_to_eyecam)
					master.create_hologram()
				else
					boutput(master, SPAN_ALERT("Deploy to an AI Eye first to create a hologram."))
			if ("map")
				master.open_map()
			if ("core")
				master.return_to(user)
			if ("coreatk")
				master.return_to(user)
